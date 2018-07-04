--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_AGE_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_AGE_USER_SELECT" (
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
--------------------------------- 연령별 회원현황 (회원 탭) ----------------------------------
    v_query := 
              'SELECT  TOT.COMP_CD
                      , TOT.STOR_CD
                      , STO.STOR_NM
                      , TOT.SALE_YM
                      , V03.CODE_CD
                      , V03.CODE_NM
                      , TOT.CUST_ID
                      , TOT.CUST_ID
                      , decrypt(CUST.CUST_NM) as CUST_NM
                      , TOT.ITEM_CD
                      , ITM.ITEM_NM
                      , TOT.CST_SALE_QTY
                      , TOT.CST_SALE_AMT
                      , TOT.CST_DC_AMT
                      , TOT.CST_GRD_AMT
                FROM    STORE STO
                      ,     ITEM ITM
                      ,     C_CUST CUST
                      ,(
                        SELECT  MMS.COMP_CD
                              , MMS.BRAND_CD
                              , MMS.STOR_CD
                              , MMS.SALE_YM
                              , MMS.CUST_AGE
                              , MMS.CUST_ID
                              , MMS.ITEM_CD
                              , SUM(MMS.SALE_QTY)           AS CST_SALE_QTY
                              , SUM(MMS.SALE_AMT)           AS CST_SALE_AMT
                              , SUM(MMS.DC_AMT)              AS CST_DC_AMT
                              , SUM(MMS.GRD_AMT)            AS CST_GRD_AMT
                        FROM   (
                                SELECT  MS.COMP_CD
                                      , MS.BRAND_CD
                                      , MS.STOR_CD
                                      , MS.SALE_YM
                                      , MS.CUST_AGE
                                      , MS.CUST_ID
                                      , MS.ITEM_CD
                                      , MS.SALE_QTY
                                      , MS.SALE_AMT
                                      , MS.DC_AMT + MS.ENR_AMT as DC_AMT
                                      , MS.GRD_AMT
                                FROM    C_CUST_MMS MS
                                      , STORE    ST
                                WHERE   ST.BRAND_CD = MS.BRAND_CD
                                AND     ST.STOR_CD  = MS.STOR_CD
                                AND     MS.COMP_CD  = '''||P_COMP_CD||'''
                                AND     (''' || N_STOR_CD || ''' IS NULL OR ST.STOR_CD = ''' || N_STOR_CD || ''')
                                AND     (''001'' = '''||N_BRAND_CD||''' OR ST.BRAND_CD = '''||N_BRAND_CD||''' OR ('''||N_BRAND_CD||''' IS NULL AND ST.BRAND_CD = '''||P_MY_BRAND_CD||'''))
                                AND     MS.SALE_YM >= '''||P_START_DT ||'''
                                AND     MS.SALE_YM <= '''||P_END_DT ||'''
                                AND     MS.CUST_LVL = NVL('''||N_CUST_GRADE||''', MS.CUST_LVL)
                               ) MMS
                        GROUP BY
                                MMS.COMP_CD
                              , MMS.BRAND_CD
                              , MMS.STOR_CD
                              , MMS.SALE_YM
                              , MMS.CUST_ID
                              , MMS.ITEM_CD
                              , MMS.CUST_AGE
                       ) TOT
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
                WHERE   TOT.BRAND_CD = STO.BRAND_CD
                AND     TOT.STOR_CD  = STO.STOR_CD
                AND     TOT.COMP_CD  = V03.COMP_CD
                AND      TOT.CUST_AGE  BETWEEN V03.VAL_N1 AND V03.VAL_N2
                AND     TOT.CUST_ID   = CUST.CUST_ID
                AND     TOT.ITEM_CD   = ITM.ITEM_CD
                ORDER BY TOT.COMP_CD, TOT.STOR_CD, TOT.SALE_YM, V03.CODE_CD,  TOT.CUST_ID, TOT.ITEM_CD';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_STATS_AGE_USER_SELECT;

/
