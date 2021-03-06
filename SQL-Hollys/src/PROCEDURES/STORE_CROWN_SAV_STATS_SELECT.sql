--------------------------------------------------------
--  DDL for Procedure STORE_CROWN_SAV_STATS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_CROWN_SAV_STATS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    N_SEX_DIV      IN  VARCHAR2,
    N_AGE_DIV      IN  VARCHAR2,
    N_MARK_CD      IN  VARCHAR2,
    P_MY_USER_ID   IN  VARCHAR2,
    P_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
    TYPE  rec_ct_hd IS RECORD
        ( SALE_DAY     VARCHAR2(8),
          SALE_DAY_NM  VARCHAR2(12)
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
--------------------------------- 매장별 왕관 적립현황 ----------------------------------
    ls_sql_crosstab_main :=
          ' SELECT TO_CHAR(TO_DATE('''||P_START_DT||''', ''YYYYMMDD'') + ROWNUM - 1, ''MMDD'' ) AS SALE_DAY,  '
        ||'        TO_CHAR(TO_DATE('''||P_START_DT||''', ''YYYYMMDD'') + ROWNUM - 1, ''MM/DD'') AS SALE_DAY_NM'
        ||' FROM    TAB                                                                                 '
        ||' WHERE   ROWNUM <= 1 + (TO_DATE('''||P_END_DT||''', ''YYYYMMDD'') - TO_DATE('''||P_START_DT||''', ''YYYYMMDD''))'
        ||' ORDER BY ROWNUM';
 
    ls_sql := ls_sql_crosstab_main ;
    EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;
    
    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ', ';
            END IF;
            V_CROSSTAB := V_CROSSTAB || qry_hd(i).SALE_DAY;
        END;
    END LOOP;
    
    v_query := 
              '
              SELECT  V03.BRAND_CD
                    , NVL(V03.BRAND_NM, (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = V03.BRAND_CD AND ROWNUM = 1)) AS BRAND_NM
                    , V03.STOR_CD
                    , NVL(V03.STOR_NM, FC_GET_WORDPACK('''||P_LANGUAGE_TP||''', ''ADMIN_YN'')) AS STOR_NM
                    , TO_NUMBER(SUBSTR(V03.USE_DT, 5, 4)) AS USE_DT
                    , SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.STOR_CD) AS TOT_CUST_CNT
                    , SUM(V03.DAY_SAV_MLG  ) OVER(PARTITION BY V03.STOR_CD) AS TOT_SAV_MLG
                    , CASE WHEN SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.STOR_CD) = 0 THEN ''0''
                           ELSE NVL(TO_CHAR(ROUND(SUM(V03.DAY_SAV_MLG  ) OVER(PARTITION BY V03.STOR_CD) / SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.STOR_CD), 2), ''990.99''), 0)
                      END AS TOT_AVG_SAV_MLG
                    , V03.DAY_CUST_CNT
                    , V03.DAY_SAV_MLG
                    , CASE WHEN V03.DAY_CUST_CNT = 0 THEN 0
                           ELSE V03.DAY_SAV_MLG / V03.DAY_CUST_CNT
                      END AS DAY_AVG_SAV_MLG
              FROM   (
                      SELECT
                              CSH.BRAND_CD
                             , '''' AS BRAND_NM
                            , CSH.STOR_CD
                            , STO.STOR_NM
                            , CSH.USE_DT
                            , COUNT(DISTINCT CRD.CUST_ID) AS DAY_CUST_CNT
                            , SUM(CSH.SAV_MLG)             AS DAY_SAV_MLG
                      FROM    STORE         STO
                            , C_CUST_CROWN  CSH
                            , C_CARD          CRD
                            ,(
                              SELECT  V01.COMP_CD
                                    , V01.CUST_ID
                                    , GET_AGE_GROUP(V01.CUST_AGE) AGE_GROUP
                              FROM   (
                                      SELECT  CST.COMP_CD
                                            , CST.CUST_ID
                                            , CASE WHEN REGEXP_INSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(CST.BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1
                                                   THEN  TRUNC((TO_NUMBER(SUBSTR('''||P_END_DT||''', 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, 1, 6))) / 100 + 1)
                                              ELSE 999 END AS CUST_AGE
                                      FROM    C_CUST     CST
                                      WHERE   CST.COMP_CD = '''||P_COMP_CD||'''
                                      AND    ('''||N_CUST_GRADE||''' IS NULL OR CST.LVL_CD  = '''||N_CUST_GRADE||''')
                                      AND    ('''||N_SEX_DIV||''' IS NULL OR CST.SEX_DIV = '''||N_SEX_DIV||''')
                                     ) V01
                                 ) V02
                      WHERE   CSH.BRAND_CD   = STO.BRAND_CD(+)
                      AND     CSH.STOR_CD    = STO.STOR_CD (+)
                      AND     (''' || N_STOR_CD || ''' IS NULL OR CSH.STOR_CD = ''' || N_STOR_CD || ''')
                      AND (CSH.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                           AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || P_MY_USER_ID || ''' AND BRAND_CD = CSH.BRAND_CD AND USE_YN = ''Y'')))
                      AND     CSH.COMP_CD    = CRD.COMP_CD
                      AND     CSH.CARD_ID    = CRD.CARD_ID
                      AND     (''' || N_MARK_CD || ''' IS NULL OR CRD.CUST_ID IN (SELECT CUST_ID FROM MARKETING_GP A, MARKETING_GP_CUST B
                                                                                  WHERE A.CUST_GP_ID = ''' || N_MARK_CD || ''' AND A.CUST_GP_ID = B.CUST_GP_ID))
                      AND     CRD.COMP_CD    = V02.COMP_CD
                      AND     CRD.CUST_ID    = V02.CUST_ID
                      AND    ('''||N_AGE_DIV||''' IS NULL OR V02.AGE_GROUP  = '''||N_AGE_DIV||''')
                      AND     CSH.USE_DT >= '''||P_START_DT||'''
                      AND     CSH.USE_DT <= '''||P_END_DT||'''
                      GROUP BY
                              CSH.BRAND_CD
                            , CSH.STOR_CD
                            , STO.STOR_NM
                            , CSH.USE_DT
                    ) V03';

    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || v_query
            || ' ) SCM '
            || ' PIVOT '
            || ' ( SUM(DAY_CUST_CNT   ) CT1 '
            || ' , SUM(DAY_SAV_MLG    ) CT2 '
            || ' , AVG(DAY_AVG_SAV_MLG) CT3 '
            || ' FOR (USE_DT) IN ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY STOR_NM ASC';
          
    OPEN O_CURSOR FOR V_SQL;
    
END STORE_CROWN_SAV_STATS_SELECT;

/
