--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ALL_TEMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ALL_TEMP" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_BRAND_CD  IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query varchar2(30000);
BEGIN
--------------------------------- 전체회원 현황 (전체 탭) ----------------------------------
    v_query := 
              'SELECT  /*+ NO_MERGE LEADING(CST) */
                      CST.STD_YM
                    , CST.TOT_CUST_CNT
                    , CST.NEW_CUST_CNT
                    , MSS.CST_CUST_CNT
                    , CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE
                    , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT
                    , CASE WHEN (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) = 0 THEN 0
                           ELSE (JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT) / (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT)
                      END AS NCST_BILL_AMT
                    , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT
                    , CASE WHEN (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER()) = 0 THEN 0
                           ELSE (SUM(JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT)OVER()) / (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER())
                      END AS T_NCST_BILL_AMT
                    , MSS.CST_SALE_QTY
                    , NVL(TO_CHAR(ROUND(MSS.CST_SALE_QTY/JDS.TOT_SALE_QTY *100, 2), ''990.99''), ''0'')    as   CST_SALE_RATE
                    , JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY AS NCST_SALE_QTY
                    , NVL(TO_CHAR(ROUND((JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY)/JDS.TOT_SALE_QTY*100, 2), ''990.99''), ''0'') as NCST_SALE_RATE
                    , MSS.CST_GRD_AMT
                    , NVL(TO_CHAR(ROUND(MSS.CST_GRD_AMT/JDS.TOT_GRD_AMT*100, 2), ''990.99''), ''0'')  as  CST_GRD_RATE
                    , JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT  AS NCST_GRD_AMT
                    , NVL(TO_CHAR(ROUND((JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT)/JDS.TOT_GRD_AMT*100, 2), ''990.99''), ''0'')  AS NCST_GRD_RATE
              FROM   (
                      SELECT  /*+ NO_MERGE LEADING(CST) */
                              V01.COMP_CD
                            , V01.STD_YM
                            , SUM(CASE WHEN CST.JOIN_DT <=   V01.STD_YM||''31'' AND SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8) >= V01.STD_YM||''31'' THEN 1 ELSE 0 END) TOT_CUST_CNT
                            , SUM(CASE WHEN CST.JOIN_DT LIKE V01.STD_YM||''%''  AND SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8) >= V01.STD_YM||''31'' THEN 1 ELSE 0 END) NEW_CUST_CNT
                      FROM    C_CUST     CST
                            ,(
                              SELECT  '''||P_COMP_CD||''' AS COMP_CD
                                   ,  TO_CHAR(ADD_MONTHS(TO_DATE('''||P_START_DT||''', ''YYYYMM''), ROWNUM - 1), ''YYYYMM'') STD_YM
                              FROM    TAB
                              WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE('''||P_END_DT||''', ''YYYYMM''),
                                                               TO_DATE('''||P_START_DT||''', ''YYYYMM'')) + 1)
                             ) V01
                      WHERE   CST.COMP_CD = V01.COMP_CD
                      AND     CST.COMP_CD = '''||P_COMP_CD||'''
                      AND     (''' || N_STOR_CD || ''' IS NULL OR CST.STOR_CD = ''' || N_STOR_CD || ''')
                      AND     (''001'' = '''||N_BRAND_CD||''' OR CST.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND CST.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                      AND     SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8)  >= '''||P_START_DT||'''||''01''
                      AND     CST.CUST_STAT IN (''2'', ''9'')
                      AND     CST.JOIN_DT<= '''||P_END_DT||''' || ''31''
                      GROUP BY
                              V01.COMP_CD, V01.STD_YM
                     ) CST
                    ,(
                      SELECT  /*+ NO_MERGE LEADING(MSS) */
                              MSS.COMP_CD
                            , MSS.SALE_YM
                            , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT
                            , SUM(MSS.BILL_CNT)           AS CST_BILL_CNT
                            , SUM(MSS.SALE_QTY)           AS CST_SALE_QTY
                            , SUM(MSS.GRD_AMT)            AS CST_GRD_AMT 
                      FROM   (
                              SELECT  /*+ NO_MERGE */
                                      MSS.COMP_CD
                                    , MSS.SALE_YM
                                    , MSS.CUST_ID
                                    , MSS.BILL_CNT
                                    , MSS.SALE_QTY
                                    , MSS.GRD_AMT
                                    , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM
                              FROM    C_CUST_MSS MSS
                                    , STORE    STO
                              WHERE   STO.BRAND_CD = MSS.BRAND_CD
                              AND     STO.STOR_CD  = MSS.STOR_CD
                              AND     MSS.COMP_CD  = '''||P_COMP_CD||'''
                              AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                              AND     (''' || N_STOR_CD || ''' IS NULL OR MSS.STOR_CD = ''' || N_STOR_CD || ''')
                              AND     MSS.SALE_YM >= '''||P_START_DT||'''
                              AND     MSS.SALE_YM <= '''||P_END_DT||'''
                              AND     MSS.CUST_LVL = NVL('''||N_CUST_GRADE||''', MSS.CUST_LVL)
                             ) MSS
                      GROUP BY MSS.COMP_CD, MSS.SALE_YM
                     ) MSS
                    ,(
                      SELECT  /*+ NO_MERGE LEADING(JDS) */
                              '''||P_COMP_CD||'''       AS COMP_CD
                          ,   SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM
                          ,   SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT
                          ,   SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY
                          ,   SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT
                      FROM    SALE_JDS JDS
                            , STORE  STO
                      WHERE   STO.BRAND_CD = JDS.BRAND_CD
                      AND     STO.STOR_CD  = JDS.STOR_CD
                      AND     (''' || N_STOR_CD || ''' IS NULL OR STO.STOR_CD = ''' || N_STOR_CD || ''')
                      AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                      AND     JDS.SALE_DT  >= '''||P_START_DT||''' || ''01''
                      AND     JDS.SALE_DT  <= '''||P_END_DT||''' || ''31''
                      GROUP BY SUBSTR(JDS.SALE_DT, 1, 6 )
                     ) JDS
              WHERE   CST.COMP_CD   = MSS.COMP_CD(+)
              AND     CST.STD_YM    = MSS.SALE_YM(+)
              AND     CST.COMP_CD   = JDS.COMP_CD
              AND     CST.STD_YM    = JDS.SALE_YM
              ORDER BY CST.STD_YM';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_ALL_TEMP;

/
