--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ALL_STORE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ALL_STORE_SELECT" (
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
--------------------------------- 전체회원 현황 (매장 탭) ----------------------------------
    v_query := 
              'SELECT  MSS.COMP_CD
                      , NVL(MSS.STOR_CD, JDS.STOR_CD) as STOR_CD
                      , STO.STOR_NM
                      , NVL(MSS.SALE_YM, JDS.SALE_YM) as SALE_YM
                      , MSS.CST_CUST_CNT
                      , CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT
                      , CASE WHEN (SUM(CST_BILL_CNT) OVER()) = 0 THEN 0
                             ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT
                      , CASE WHEN (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0) ) = 0 THEN 0
                             ELSE  (NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)) / (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0))  END AS NCST_BILL_AMT
                      , MSS.CST_SALE_QTY
                      , NVL(JDS.TOT_SALE_QTY,0) - NVL(MSS.CST_SALE_QTY,0) AS NCST_SALE_QTY
                      , MSS.CST_GRD_AMT
                      , NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)  AS NCST_GRD_AMT
                      , NVL(TO_CHAR(ROUND(MSS.CST_SALE_QTY/JDS.TOT_SALE_QTY *100, 2), ''990.99''), ''0'')                     AS CST_SALE_RATE
                      , NVL(TO_CHAR(ROUND((JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY)/JDS.TOT_SALE_QTY*100, 2), ''990.99''), ''0'') AS NCST_SALE_RATE
                      , NVL(TO_CHAR(ROUND(MSS.CST_GRD_AMT/JDS.TOT_GRD_AMT*100, 2), ''990.99''), ''0'')                        AS CST_GRD_RATE
                      , NVL(TO_CHAR(ROUND((JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT)/JDS.TOT_GRD_AMT*100, 2), ''990.99''), ''0'')   AS NCST_GRD_RATE
                FROM  STORE STO
                      ,(
                        SELECT  MSS.COMP_CD
                              , MSS.BRAND_CD
                              , MSS.STOR_CD
                              , MSS.SALE_YM
                              , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT
                              , SUM(MSS.BILL_CNT)           AS CST_BILL_CNT
                              , SUM(MSS.SALE_QTY)           AS CST_SALE_QTY
                              , SUM(MSS.GRD_AMT)            AS CST_GRD_AMT
                        FROM   (
                                SELECT  MSS.COMP_CD
                                      , MSS.BRAND_CD
                                      , MSS.STOR_CD
                                      , MSS.SALE_YM
                                      , MSS.CUST_ID
                                      , MSS.BILL_CNT
                                      , MSS.SALE_QTY
                                      , MSS.GRD_AMT
                                      , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.STOR_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM
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
                        GROUP BY
                                MSS.COMP_CD
                              , MSS.BRAND_CD
                              , MSS.STOR_CD
                              , MSS.SALE_YM
                       ) MSS
                      ,(
                        SELECT  '''||P_COMP_CD||''' AS COMP_CD
                            ,   JDS.BRAND_CD
                            ,   JDS.STOR_CD
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
                        GROUP BY
                                JDS.BRAND_CD
                              , JDS.STOR_CD
                              , SUBSTR(JDS.SALE_DT, 1, 6 )
                       ) JDS
                WHERE  STO.BRAND_CD = JDS.BRAND_CD
                AND    STO.STOR_CD  = JDS.STOR_CD
                AND    JDS.BRAND_CD = MSS.BRAND_CD(+)
                AND    JDS.STOR_CD  = MSS.STOR_CD (+)
                AND    JDS.SALE_YM  = MSS.SALE_YM (+)
                ORDER BY NVL(MSS.STOR_CD, JDS.STOR_CD), NVL(MSS.SALE_YM, JDS.SALE_YM)';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_ALL_STORE_SELECT;

/
