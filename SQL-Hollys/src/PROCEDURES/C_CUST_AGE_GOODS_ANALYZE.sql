--------------------------------------------------------
--  DDL for Procedure C_CUST_AGE_GOODS_ANALYZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_AGE_GOODS_ANALYZE" (
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    N_SEX_DIV      IN  VARCHAR2,
    N_AGE_DIV      IN  VARCHAR2,
    N_ITEM_L_CLASS IN  VARCHAR2,
    N_ITEM_M_CLASS IN  VARCHAR2,
    N_ITEM_S_CLASS IN  VARCHAR2,
    N_RANK_STR     IN  VARCHAR2,
    N_RANK_END     IN  VARCHAR2,
    N_SORT_DIV     IN  VARCHAR2,
    N_MARK_CD      IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_query varchar2(30000);
BEGIN
--------------------------------- 연령대 선호상품 분석 ----------------------------------
    v_query := 
              'SELECT  V02.COMP_CD
                      , V02.BRAND_CD
                      , V02.BRAND_NM
                      , V02.AGE_GRP
                      , GET_COMMON_CODE_NM(''01760'', V02.AGE_GRP, '''||P_LANGUAGE_TP||''')               AS AGE_GRP_NM
                      , CASE WHEN '''||N_SORT_DIV||''' = ''01'' THEN RANK_OF_QTY ELSE RANK_OF_AMT END AS RANK
                      , V02.L_CLASS_CD
                      , V02.M_CLASS_CD
                      , V02.S_CLASS_CD
                      , V02.L_CLASS_NM
                      , V02.M_CLASS_NM
                      , V02.S_CLASS_NM
                      , V02.ITEM_CD
                      , V02.ITEM_NM
                      , V02.ITM_SUM_QTY
                      , V02.ITM_SUM_GRD
                      , NVL(TO_CHAR(ROUND(CASE WHEN V02.AGE_SUM_GRD = 0 THEN 0 ELSE V02.ITM_SUM_GRD / V02.AGE_SUM_GRD  * 100 END, 2), ''990.99''), 0) AS GRD_RATE
                FROM   (
                        SELECT  V01.COMP_CD
                              , V01.BRAND_CD
                              , V01.BRAND_NM
                              , V01.AGE_GRP
                              , V01.L_CLASS_CD
                              , V01.M_CLASS_CD
                              , V01.S_CLASS_CD
                              , V01.L_CLASS_NM
                              , V01.M_CLASS_NM
                              , V01.S_CLASS_NM
                              , V01.ITEM_CD
                              , V01.ITEM_NM
                              , V01.SALE_QTY    AS ITM_SUM_QTY
                              , V01.GRD_AMT     AS ITM_SUM_GRD
                              , SUM(V01.GRD_AMT ) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP                                    ) AGE_SUM_GRD
                              , ROW_NUMBER()        OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP ORDER BY SALE_QTY DESC) RANK_OF_QTY
                              , ROW_NUMBER()        OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP ORDER BY GRD_AMT  DESC) RANK_OF_AMT
                        FROM   (
                                SELECT  MMS.COMP_CD
                                      , STO.BRAND_CD
                             , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = STO.BRAND_CD) AS BRAND_NM
                                      , GET_AGE_GROUP(MMS.CUST_AGE) AS AGE_GRP
                                      , ITM.L_CLASS_CD
                                      , ITM.M_CLASS_CD
                                      , ITM.S_CLASS_CD
                                      , (SELECT L_CLASS_NM FROM ITEM_L_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD) AS L_CLASS_NM
                                      , (SELECT M_CLASS_NM FROM ITEM_M_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD AND M_CLASS_CD = ITM.M_CLASS_CD) AS M_CLASS_NM
                                      , (SELECT S_CLASS_NM FROM ITEM_S_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD AND M_CLASS_CD = ITM.M_CLASS_CD AND S_CLASS_CD = ITM.S_CLASS_CD) AS S_CLASS_NM
                                      , MMS.ITEM_CD
                                      , ITM.ITEM_NM
                                      , SUM(MMS.SALE_QTY) AS SALE_QTY
                                      , SUM(MMS.GRD_AMT ) AS GRD_AMT
                                FROM    C_CUST_MMS  MMS
                                      , ITEM      ITM
                                      , STORE     STO
                                WHERE   MMS.COMP_CD = ''016''
                                AND     MMS.BRAND_CD = STO.BRAND_CD
                                AND     MMS.STOR_CD  = STO.STOR_CD
                                AND     MMS.ITEM_CD  = ITM.ITEM_CD
                                AND     (''' || N_MARK_CD || ''' IS NULL OR MMS.CUST_ID IN (SELECT CUST_ID FROM MARKETING_GP A, MARKETING_GP_CUST B
                                                                                            WHERE A.CUST_GP_ID = ''' || N_MARK_CD || ''' AND A.CUST_GP_ID = B.CUST_GP_ID))
                                AND     (''' || N_STOR_CD || ''' IS NULL OR STO.STOR_CD = ''' || N_STOR_CD || ''')
                                AND     (STO.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                        AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = STO.BRAND_CD AND USE_YN = ''Y'')))
                                AND     MMS.SALE_YM >= '''||P_START_DT||'''
                                AND     MMS.SALE_YM <= '''||P_END_DT||'''
                                AND     MMS.CUST_SEX = NVL('''||N_SEX_DIV||''', MMS.CUST_SEX)
                                AND     MMS.CUST_LVL = NVL('''||N_CUST_GRADE||''', MMS.CUST_LVL)
                                AND     (''' || N_ITEM_L_CLASS || ''' IS NULL OR ITM.L_CLASS_CD = ''' || N_ITEM_L_CLASS || ''')
                                AND     (''' || N_ITEM_M_CLASS || ''' IS NULL OR ITM.M_CLASS_CD = ''' || N_ITEM_M_CLASS || ''')
                                AND     (''' || N_ITEM_S_CLASS || ''' IS NULL OR ITM.S_CLASS_CD = ''' || N_ITEM_S_CLASS || ''')
                                GROUP BY
                                        MMS.COMP_CD
                                      , STO.BRAND_CD
                                      , GET_AGE_GROUP(MMS.CUST_AGE)
                                      , ITM.L_CLASS_CD
                                      , ITM.M_CLASS_CD
                                      , ITM.S_CLASS_CD
                                      , MMS.ITEM_CD
                                      , ITM.ITEM_NM
                               ) V01
                        WHERE  V01.AGE_GRP = NVL('''||N_AGE_DIV||''', V01.AGE_GRP)
                       ) V02
                WHERE   1 = (CASE WHEN '''||N_SORT_DIV||''' = ''01'' AND V02.RANK_OF_QTY BETWEEN '''||N_RANK_STR||''' AND '''||N_RANK_END||''' THEN 1 ELSE 0 END)
                OR      1 = (CASE WHEN '''||N_SORT_DIV||''' = ''02'' AND V02.RANK_OF_AMT BETWEEN '''||N_RANK_STR||''' AND '''||N_RANK_END||''' THEN 1 ELSE 0 END)
                ORDER BY
                        V02.COMP_CD
                      , V02.AGE_GRP
                      , CASE WHEN '''||N_SORT_DIV||''' = ''01'' THEN RANK_OF_QTY ELSE RANK_OF_AMT END';
              
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_AGE_GOODS_ANALYZE;

/
