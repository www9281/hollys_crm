--------------------------------------------------------
--  DDL for Procedure C_CUST_GRADE_BUY_ANALYZE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_GRADE_BUY_ANALYZE" (
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
    N_MARK_CD      IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    P_MY_USER_ID	 IN  VARCHAR2,
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
                    , V02.BRAND_CD
                    , V02.BRAND_NM
                    , V02.L_CLASS_CD
                    , V02.L_CLASS_NM
                    , V02.M_CLASS_CD
                    , V02.M_CLASS_NM
                    , V02.S_CLASS_CD
                    , V02.S_CLASS_NM
                    , TO_NUMBER(''9'' || V02.LVL_CD) AS LVL_CD
                    , V02.BILL_QTY
                    , NVL(TO_CHAR(ROUND(CASE WHEN V02.BILL_QTY = 0 THEN 0 ELSE V02.LVL_SUM_QTY / V02.BILL_QTY END, 2), ''990.99''), 0) AS CST_SALE_RATE
                    , NVL(V02.LVL_SUM_QTY, 0) AS LVL_SUM_QTY
                    , NVL(V02.LVL_SUM_GRD, 0) AS LVL_SUM_GRD
                    , NVL(TO_CHAR(ROUND(CASE WHEN V02.CLS_SUM_GRD = 0 THEN 0 ELSE V02.LVL_SUM_GRD / V02.CLS_SUM_GRD  * 100 END, 2), ''990.99''), 0) AS GRD_RATE
              FROM   (
               SELECT  V01.COMP_CD
                     , V01.BRAND_CD
                     , V01.BRAND_NM
                     , V01.L_CLASS_CD
                     , V01.L_CLASS_NM
                     , V01.M_CLASS_CD
                     , V01.M_CLASS_NM
                     , V01.S_CLASS_CD
                     , V01.S_CLASS_NM
                     , V01.LVL_CD
                     , V01.LVL_SUM_QTY
                     , V01.LVL_SUM_GRD
                     , V01.BILL_QTY
                     , SUM(V01.LVL_SUM_GRD) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD) CLS_SUM_GRD
               FROM   (
                       SELECT  MMS.COMP_CD
                             , STO.BRAND_CD
                             , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = STO.BRAND_CD) AS BRAND_NM
                             , ITM.L_CLASS_CD
                             , (SELECT L_CLASS_NM FROM ITEM_L_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD) AS L_CLASS_NM
                             , ITM.M_CLASS_CD
                             , (SELECT M_CLASS_NM FROM ITEM_M_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD AND M_CLASS_CD = ITM.M_CLASS_CD) AS M_CLASS_NM
                             , ITM.S_CLASS_CD
                             , (SELECT S_CLASS_NM FROM ITEM_S_CLASS WHERE L_CLASS_CD = ITM.L_CLASS_CD AND M_CLASS_CD = ITM.M_CLASS_CD AND S_CLASS_CD = ITM.S_CLASS_CD) AS S_CLASS_NM
                             , MMS.CUST_LVL      AS LVL_CD
                             , COUNT(*) AS BILL_QTY
                             , SUM(NVL(MMS.SALE_QTY,0))  AS LVL_SUM_QTY
                             , SUM(NVL(MMS.GRD_AMT,0)) AS LVL_SUM_GRD
                       FROM    C_CUST_MMS  MMS
                             , ITEM      ITM
                             , STORE     STO
                       WHERE   MMS.COMP_CD = ''' || P_COMP_CD || '''
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
                       AND     ( DECODE(''' || N_SEX_DIV      || ''','''',NULL, ''' || N_SEX_DIV      || ''') IS NULL OR MMS.CUST_SEX = ''' || N_SEX_DIV || ''')
                       AND     GET_AGE_GROUP(MMS.CUST_AGE) = NVL('''||N_AGE_DIV||''', GET_AGE_GROUP(MMS.CUST_AGE))
                       AND     (''' || N_ITEM_L_CLASS || ''' IS NULL OR ITM.L_CLASS_CD = ''' || N_ITEM_L_CLASS || ''')
                       AND     (''' || N_ITEM_M_CLASS || ''' IS NULL OR ITM.M_CLASS_CD = ''' || N_ITEM_M_CLASS || ''')
                       AND     (''' || N_ITEM_S_CLASS || ''' IS NULL OR ITM.S_CLASS_CD = ''' || N_ITEM_S_CLASS || ''')
                       GROUP BY
                               MMS.COMP_CD
                             , STO.BRAND_CD
                             , ITM.L_CLASS_CD
                             , ITM.M_CLASS_CD
                             , ITM.S_CLASS_CD
                             , MMS.CUST_LVL
                      ) V01
              ) V02';

    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || v_query
            || ' ) SCM '
            || ' PIVOT '
            || ' ( SUM(NVL(BILL_QTY, 0)) VCOL1 '
            || ' , AVG(CST_SALE_RATE) VCOL2 '
            || ' , SUM(NVL(LVL_SUM_QTY, 0)) VCOL3 '
            || ' , SUM(NVL(LVL_SUM_GRD, 0)) VCOL4 '
            || ' , AVG(GRD_RATE)  VCOL5 '
            || ' FOR LVL_CD IN ( '
            || V_CROSSTAB
            || ' ) )'
            || 'ORDER BY 1,2,3,4,5 ASC';
            
    Dbms_Output.Put_Line(V_SQL);
          
    OPEN O_CURSOR FOR V_SQL;
    
END C_CUST_GRADE_BUY_ANALYZE;

/
