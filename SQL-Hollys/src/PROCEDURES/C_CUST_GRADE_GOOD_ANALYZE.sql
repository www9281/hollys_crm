--------------------------------------------------------
--  DDL for Procedure C_CUST_GRADE_GOOD_ANALYZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_GRADE_GOOD_ANALYZE" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_SEX_DIV      IN  VARCHAR2,
    N_AGE_DIV      IN  VARCHAR2,
    N_ITEM_L_CLASS IN  VARCHAR2,
    N_ITEM_M_CLASS IN  VARCHAR2,
    N_ITEM_S_CLASS IN  VARCHAR2,
    N_RANK_STR     IN  VARCHAR2,
    N_RANK_END     IN  VARCHAR2,
    N_SORT_DIV     IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    TYPE  rec_ct_hd IS RECORD
       ( 
        LVL_CD     VARCHAR2(10),
        LVL_CD_NM  VARCHAR2(100)
       );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd  tb_ct_hd;
    
    -- 가로축 데이터 추출
    ls_sql VARCHAR2(30000) ;
    V_CROSSTAB VARCHAR2(30000);
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    
    v_query VARCHAR2(30000);
    V_SQL VARCHAR2(30000);
BEGIN
--------------------------------- 회원등급 상품분류별 구매분석 ----------------------------------
    ls_sql_crosstab_main :=
          ' SELECT  ''9'' || LVL_CD  AS LVL_CD,  '
        ||'         LVL_NM  AS LVL_CD_NM'
        ||' FROM    C_CUST_LVL          '
        ||' WHERE   COMP_CD = '''||P_COMP_CD||''''
        ||' AND     USE_YN = ''Y''      '
        ||' ORDER BY                    '
        ||'         LVL_RANK            '
        ;

    ls_sql := ls_sql_crosstab_main ;
    EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;
    
    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
            END IF;
            V_CROSSTAB := V_CROSSTAB || qry_hd(i).LVL_CD;
        END;
    END LOOP;
    
    v_query := 
              'SELECT  V02.COMP_CD
                    , ''9''|| V02.LVL_CD AS LVL_CD
                    , CASE WHEN '''||N_SORT_DIV||''' = ''01'' THEN RANK_OF_QTY ELSE RANK_OF_AMT END AS ITM_RANK
                    , V02.ITEM_CD
                    , V02.ITEM_NM
                    , V02.ITM_SUM_QTY
                    , V02.ITM_SUM_GRD
                    , NVL(TO_CHAR(ROUND(CASE WHEN V02.AGE_SUM_GRD = 0 THEN 0 ELSE V02.ITM_SUM_GRD / V02.AGE_SUM_GRD  * 100 END, 2), ''990.99''), 0) AS GRD_RATE
              FROM   (
                      SELECT  V01.COMP_CD
                            , V01.LVL_CD
                            , V01.ITEM_CD
                            , V01.ITEM_NM
                            , V01.SALE_QTY     AS ITM_SUM_QTY
                            , V01.GRD_AMT      AS ITM_SUM_GRD
                            , SUM(V01.GRD_AMT) OVER(PARTITION BY V01.COMP_CD, V01.LVL_CD                       ) AS AGE_SUM_GRD
                            , ROW_NUMBER()     OVER(PARTITION BY V01.COMP_CD, V01.LVL_CD  ORDER BY SALE_QTY DESC) AS RANK_OF_QTY
                            , ROW_NUMBER()     OVER(PARTITION BY V01.COMP_CD, V01.LVL_CD  ORDER BY GRD_AMT  DESC) AS RANK_OF_AMT
                      FROM   (
                              SELECT  MMS.COMP_CD
                                    , MMS.CUST_LVL      AS LVL_CD
                                    , MMS.ITEM_CD
                                    , ITM.ITEM_NM
                                    , SUM(MMS.SALE_QTY) AS SALE_QTY
                                    , SUM(MMS.GRD_AMT ) AS GRD_AMT
                              FROM    C_CUST_MMS  MMS
                                    , ITEM      ITM
                                    , STORE     STO
                              WHERE   MMS.BRAND_CD = STO.BRAND_CD
                              AND     MMS.STOR_CD  = STO.STOR_CD
                              AND     MMS.ITEM_CD  = ITM.ITEM_CD
                              AND     (''' || N_STOR_CD || ''' IS NULL OR STO.STOR_CD = ''' || N_STOR_CD || ''')     
                              AND     (STO.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                                      AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = STO.BRAND_CD AND USE_YN = ''Y'')))
                              AND     MMS.SALE_YM >= '''||P_START_DT||'''
                              AND     MMS.SALE_YM <= '''||P_END_DT||'''
                              AND     ( DECODE(''' || N_SEX_DIV      || ''','''',NULL, ''' || N_SEX_DIV      || ''') IS NULL OR MMS.CUST_SEX = ''' || N_SEX_DIV || ''')
                              AND     GET_AGE_GROUP(MMS.CUST_AGE) = NVL('''||N_AGE_DIV||''', GET_AGE_GROUP(MMS.CUST_AGE))
                              AND     (''' || N_ITEM_L_CLASS || ''' IS NULL OR ITM.L_CLASS_CD = ''' || N_ITEM_L_CLASS || ''')
                              AND     (''' || N_ITEM_M_CLASS || ''' IS NULL OR ITM.M_CLASS_CD = ''' || N_ITEM_M_CLASS || ''')
                              AND     (''' || N_ITEM_S_CLASS || ''' IS NULL OR ITM.S_CLASS_CD = ''' || N_ITEM_S_CLASS || ''')
                              GROUP BY
                                      MMS.COMP_CD
                                    , MMS.CUST_LVL
                                    , MMS.ITEM_CD
                                    , ITM.ITEM_NM
                             ) V01
                     ) V02
              WHERE   1 = (CASE WHEN '''||N_SORT_DIV||''' = ''01'' AND V02.RANK_OF_QTY BETWEEN '||N_RANK_STR||' AND '||N_RANK_END||' THEN 1 ELSE 0 END)
              OR      1 = (CASE WHEN '''||N_SORT_DIV||''' = ''02'' AND V02.RANK_OF_AMT BETWEEN '||N_RANK_STR||' AND '||N_RANK_END||' THEN 1 ELSE 0 END)
              ORDER BY
                      V02.COMP_CD
                    , V02.LVL_CD
                    , CASE WHEN '''||N_SORT_DIV||''' = ''01'' THEN RANK_OF_QTY ELSE RANK_OF_AMT END';

    V_SQL :=   ' SELECT *   '
            || ' FROM (     '
            || v_query
            || ' ) SCM      '
            || ' PIVOT      '
            || ' (          '
            || '    MAX(ITEM_CD    )    VCOL1 '
            || ' ,  MAX(ITEM_NM    )    VCOL2 '
            || ' ,  SUM(ITM_SUM_QTY)    VCOL3 '
            || ' ,  SUM(ITM_SUM_GRD)    VCOL4 '
            || ' ,  MAX(GRD_RATE   )    VCOL5 '
            || ' FOR (LVL_CD ) IN ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2 ASC';
    DBMS_OUTPUT.PUT_LINE(V_SQL);      
    OPEN O_CURSOR FOR V_SQL;
    
END C_CUST_GRADE_GOOD_ANALYZE;

/
