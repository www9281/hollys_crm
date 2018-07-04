--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_AGE_ALL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_AGE_ALL_SELECT" (
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
--------------------------------- 연령별 회원현황 (전체 탭) ----------------------------------
    v_query := 
              'SELECT  CST.CODE_NM
                    , CST.TOT_CUST_CNT
                    , CST.NEW_CUST_CNT
                    , MSS.CST_CUST_CNT
                    , CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE
                    , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT
                    , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT
                    , MSS.CST_SALE_QTY
                    , MSS.CST_GRD_AMT
              FROM   (
                      SELECT  V01.COMP_CD
                            , V02.CODE_CD
                            , V02.CODE_NM
                            , V01.TOT_CUST_CNT
                            , V01.NEW_CUST_CNT
                      FROM   (
                              SELECT  COMP_CD
                                    , AGE_GRP
                                    , SUM(TOT_CUST_CNT) AS TOT_CUST_CNT
                                    , SUM(NEW_CUST_CNT) AS NEW_CUST_CNT
                              FROM   (
                                      SELECT  CST.COMP_CD
                                            , CST.CUST_ID
                                            , GET_AGE_GROUP (
                                                              CASE WHEN REGEXP_INSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(CST.BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1
                                                                   THEN  TRUNC((TO_NUMBER('''||P_END_DT||''') - TO_NUMBER(SUBSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, 1, 6))) / 100 + 1)
                                                                   ELSE 999
                                                              END
                                                            ) AS AGE_GRP
                                            , CASE WHEN JOIN_DT <=  '''||P_END_DT||'''||''31'' AND NVL(LEAVE_DT, ''99991231'') >= '''||P_END_DT||'''||''31'' THEN 1 ELSE 0 END AS TOT_CUST_CNT
                                            , CASE WHEN JOIN_DT LIKE'''||P_END_DT||'''||''%''  AND NVL(LEAVE_DT, ''99991231'') >= '''||P_END_DT||'''||''31'' THEN 1 ELSE 0 END AS NEW_CUST_CNT
                                      FROM    C_CUST     CST
                                      WHERE   CST.COMP_CD = '''||P_COMP_CD||'''
                                      AND    ('''||N_STOR_CD||''' IS NULL OR CST.STOR_CD='''||N_STOR_CD||''')
                                      AND    (''001'' = '''||N_BRAND_CD||''' OR CST.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND CST.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                                      AND    ('''||N_CUST_GRADE||''' IS NULL OR CST.LVL_CD    = '''||N_CUST_GRADE||''')
                                      AND    (CST.LEAVE_DT             IS NULL OR CST.LEAVE_DT >= '''||P_START_DT||'''||''01'')
                                      AND     CST.CUST_STAT IN (''2'', ''9'')
                                      AND     CST.JOIN_DT<= '''||P_END_DT||'''||''31''
                                     )
                              GROUP BY
                                      COMP_CD
                                    , AGE_GRP
                             ) V01
                            ,(
                              SELECT  '''|| P_COMP_CD ||''' AS COMP_CD
                                    , COM.CODE_CD
                                    , COM.CODE_NM
                                    , COM.VAL_N1
                                    , COM.VAL_N2
                              FROM    COMMON     COM
                              WHERE   COM.CODE_TP = ''01760''
                              AND     COM.USE_YN  = ''Y''
                             ) V02
                      WHERE   V01.COMP_CD = V02.COMP_CD
                      AND     V01.AGE_GRP = V02.CODE_CD
                     ) CST
                    ,(
                      SELECT  MSS.COMP_CD
                            , V03.CODE_CD
                            , SUM(CASE WHEN R_NUM = 1 AND MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2 THEN 1            ELSE 0 END) CST_CUST_CNT
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.BILL_CNT ELSE 0 END) CST_BILL_CNT
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.SALE_QTY ELSE 0 END) CST_SALE_QTY
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.GRD_AMT  ELSE 0 END) CST_GRD_AMT
                      FROM   (
                              SELECT  MSS.COMP_CD
                                    , MSS.CUST_AGE
                                    , MSS.CUST_ID
                                    , MSS.BILL_CNT
                                    , MSS.SALE_QTY
                                    , MSS.GRD_AMT
                                    , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY  MSS.CUST_LVL) R_NUM
                              FROM    C_CUST_MSS MSS
                                    , STORE    STO
                              WHERE   STO.BRAND_CD = MSS.BRAND_CD
                              AND     STO.STOR_CD  = MSS.STOR_CD
                              AND     MSS.COMP_CD  = '''||P_COMP_CD||'''
                              AND     ('''||N_STOR_CD||''' IS NULL OR STO.STOR_CD='''||N_STOR_CD||''')
                              AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                              AND     MSS.SALE_YM >= '''||P_START_DT||'''
                              AND     MSS.SALE_YM <= '''||P_END_DT||'''
                              AND    ('''||N_CUST_GRADE||''' IS NULL OR MSS.CUST_LVL = '''||N_CUST_GRADE||''')
                             ) MSS
                            ,(
                              SELECT  '''|| P_COMP_CD ||''' AS COMP_CD
                                    , COM.CODE_CD
                                    , COM.CODE_NM
                                    , COM.VAL_N1
                                    , COM.VAL_N2
                              FROM    COMMON     COM
                              WHERE   COM.CODE_TP = ''01760''
                              AND     COM.USE_YN  = ''Y''
                             ) V03
                      WHERE   MSS.COMP_CD = V03.COMP_CD
                      GROUP BY
                              MSS.COMP_CD
                            , V03.CODE_CD
                     ) MSS
              WHERE   CST.COMP_CD   = MSS.COMP_CD(+)
              AND     CST.CODE_CD   = MSS.CODE_CD(+)
              ORDER BY CST.CODE_CD';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_AGE_ALL_SELECT;

/
