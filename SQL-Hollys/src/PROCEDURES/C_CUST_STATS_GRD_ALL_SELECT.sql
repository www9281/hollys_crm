--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_GRD_ALL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_GRD_ALL_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_BRAND_CD  IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query varchar2(30000);
BEGIN
--------------------------------- 등급별 회원 현황 (전체 탭) ----------------------------------
    v_query := 
              'SELECT  MSC.CUST_LVL
                      , MSC.LVL_NM
                      , MSC.TOT_CUST_CNT
                      , MSS.CST_CUST_CNT
                      , NVL(TO_CHAR(ROUND(CASE WHEN MSC.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / MSC.TOT_CUST_CNT * 100 END, 2), ''990.99''), ''0'') AS OPER_RATE
                      , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT
                      , MSS.CST_BILL_CNT
                      , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0
                             ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT
                      , MSS.CST_SALE_QTY
                      , MSS.CST_GRD_AMT
                FROM   (
                        SELECT  MSC.COMP_CD
                              , MSC.CUST_LVL
                              , LVL.LVL_NM
                              , LVL.LVL_RANK
                              , SUM(MSC.CUST_CNT) AS TOT_CUST_CNT		-- 레벨 진입 회원수
                        FROM    C_CUST_MSC MSC
                              , C_CUST_LVL LVL
                        WHERE   MSC.COMP_CD  = LVL.COMP_CD
                        AND     MSC.CUST_LVL = LVL.LVL_CD
                        AND     MSC.COMP_CD  = ''' || P_COMP_CD || '''
                        AND     MSC.SALE_YM  = ''' || P_END_DT || '''
                        GROUP BY
                                MSC.COMP_CD
                              , MSC.CUST_LVL
                              , LVL.LVL_NM
                              , LVL.LVL_RANK
                       ) MSC
                      ,(
                        SELECT  MSS.COMP_CD
                              , MSS.CUST_LVL
                              , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT
                              , SUM(MSS.BILL_CNT) AS CST_BILL_CNT
                              , SUM(MSS.SALE_QTY) AS CST_SALE_QTY
                              , SUM(MSS.GRD_AMT ) AS CST_GRD_AMT
                        FROM   (
                                SELECT  MSS.COMP_CD
                                      , MSS.CUST_LVL
                                      , MSS.BILL_CNT
                                      , MSS.SALE_QTY
                                      , MSS.GRD_AMT
                                      , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.CUST_ID ORDER BY MSS.SALE_YM DESC, MSS.CUST_LVL DESC) R_NUM
                                FROM    C_CUST_MSS MSS
                                      , STORE    STO
                                WHERE   STO.BRAND_CD = MSS.BRAND_CD
                                AND     STO.STOR_CD  = MSS.STOR_CD
                                AND     MSS.COMP_CD  = ''' || P_COMP_CD ||'''
                                AND     (''' || N_STOR_CD || ''' IS NULL OR STO.STOR_CD = ''' || N_STOR_CD || ''')
                                AND     (''001'' = '''||N_BRAND_CD||''' OR STO.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND STO.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                                AND     MSS.SALE_YM >= ''' || P_START_DT ||'''
                                AND     MSS.SALE_YM <= ''' || P_END_DT ||'''
                               ) MSS
                        GROUP BY
                                MSS.COMP_CD
                              , MSS.CUST_LVL
                       ) MSS
                WHERE   MSC.COMP_CD  = MSS.COMP_CD (+)
                AND     MSC.CUST_LVL = MSS.CUST_LVL(+)
                ORDER BY MSC.LVL_RANK';
                
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_GRD_ALL_SELECT;

/
