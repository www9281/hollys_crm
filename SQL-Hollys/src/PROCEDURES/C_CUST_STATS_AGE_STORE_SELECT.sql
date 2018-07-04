--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_AGE_STORE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_AGE_STORE_SELECT" (
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
--------------------------------- 연령별 회원현황 (매장 탭) ----------------------------------
    v_query := 
              'SELECT  MSS.STOR_CD
                    , STO.STOR_NM
                    , MSS.SALE_YM
                    , MSS.CODE_CD
                    , MSS.CODE_NM
                    , MSS.CST_CUST_CNT
                    , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT
                    , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0
                           ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT
                    , MSS.CST_SALE_QTY
                    , MSS.CST_GRD_AMT
              FROM  STORE STO
                    ,(
                      SELECT  MSS.COMP_CD
                            , MSS.BRAND_CD
                            , MSS.STOR_CD
                            , MSS.SALE_YM
                            , V03.CODE_CD
                            , V03.CODE_NM
                            , SUM(CASE WHEN R_NUM = 1 AND MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2 THEN 1            ELSE 0 END) CST_CUST_CNT
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.BILL_CNT ELSE 0 END) CST_BILL_CNT
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.SALE_QTY ELSE 0 END) CST_SALE_QTY
                            , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.GRD_AMT  ELSE 0 END) CST_GRD_AMT
                      FROM   (
                              SELECT  MSS.COMP_CD
                                    , MSS.BRAND_CD
                                    , MSS.STOR_CD
                                    , MSS.SALE_YM
                                    , MSS.CUST_AGE
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
                              AND     (''' || N_STOR_CD || ''' IS NULL OR STO.STOR_CD = ''' || N_STOR_CD || ''')
                              AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                              AND     MSS.SALE_YM >= '''||P_START_DT||'''
                              AND     MSS.SALE_YM <= '''||P_END_DT||'''
                              AND     MSS.CUST_LVL = NVL('''||N_CUST_GRADE||''', MSS.CUST_LVL)
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
                            , MSS.BRAND_CD
                            , MSS.STOR_CD
                            , MSS.SALE_YM
                            , V03.CODE_CD
                            , V03.CODE_NM
                     ) MSS
              WHERE   MSS.BRAND_CD = STO.BRAND_CD
              AND     MSS.STOR_CD  = STO.STOR_CD
              ORDER BY MSS.STOR_CD, MSS.SALE_YM, MSS.CODE_CD';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_AGE_STORE_SELECT;

/
