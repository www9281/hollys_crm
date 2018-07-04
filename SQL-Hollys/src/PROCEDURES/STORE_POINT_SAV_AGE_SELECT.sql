--------------------------------------------------------
--  DDL for Procedure STORE_POINT_SAV_AGE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_POINT_SAV_AGE_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_BRAND_CD  IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_CUST_GRADE   IN  VARCHAR2,
    N_SEX_DIV      IN  VARCHAR2,
    N_AGE_DIV      IN  VARCHAR2,
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
--------------------------------- 매장별 크라운 적립현황(연령대) ----------------------------------
    ls_sql_crosstab_main :=
          ' SELECT  CODE_CD,  '
        ||'         CODE_NM'
        ||' FROM    COMMON                                                                                 '
        ||' WHERE   CODE_TP = ''01760'''
        ||' AND     USE_YN  = ''Y'''
        ||' ORDER BY CODE_CD';
 
    ls_sql := ls_sql_crosstab_main ;
    EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;
    
    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ', ';
            END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || 'C' || qry_hd(i).SALE_DAY ||'''';
        END;
    END LOOP;
    
    v_query := 
              '
              SELECT  V03.BRAND_CD
                    , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = V03.BRAND_CD AND ROWNUM = 1) AS BRAND_NM
                    , V03.STOR_CD
                    , V03.STOR_NM
                    , ''C'' || V03.AGE_GROUP AS AGE_GROUP
                    , SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.STOR_CD) AS TOT_CUST_CNT
                    , SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.STOR_CD) AS TOT_SAV_PT
                    , CASE WHEN SUM(V03.DAY_CUST_CNT) OVER() = 0 THEN 0
                           ELSE SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.STOR_CD) / SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.STOR_CD)
                      END  AS TOT_AVG_SAV_PT
                    , V03.DAY_CUST_CNT
                    , V03.DAY_SAV_PT
                    , CASE WHEN V03.DAY_CUST_CNT = 0 THEN 0
                           ELSE V03.DAY_SAV_PT / V03.DAY_CUST_CNT
                      END  AS DAY_AVG_SAV_PT
              FROM   (
                      SELECT  STO.BRAND_CD
                            , CSH.STOR_CD
                            , STO.STOR_NM
                            , V02.AGE_GROUP
                            , COUNT(DISTINCT CSH.CARD_ID) AS DAY_CUST_CNT
                            , SUM(CSH.SAV_PT)             AS DAY_SAV_PT
                      FROM    STORE         STO
                            , C_CARD_SAV_HIS  CSH
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
                                      AND     CST.LVL_CD  = NVL('''||N_CUST_GRADE||''', CST.LVL_CD )
                                      AND     CST.SEX_DIV = NVL('''||N_SEX_DIV||''', CST.SEX_DIV)
                                     ) V01
                                 ) V02
                      WHERE   CSH.BRAND_CD   = STO.BRAND_CD
                      AND     CSH.STOR_CD    = STO.STOR_CD
                      AND     CSH.COMP_CD    = CRD.COMP_CD
                      AND     CSH.CARD_ID    = CRD.CARD_ID
                      AND     CRD.COMP_CD    = V02.COMP_CD
                      AND     CRD.CUST_ID    = V02.CUST_ID
                      AND     V02.AGE_GROUP  = NVL('''||N_AGE_DIV||''', V02.AGE_GROUP)
                      AND     CSH.SAV_USE_FG IN(''3'', ''4'')
                      AND     CSH.USE_DT >= '''||P_START_DT||'''
                      AND     CSH.USE_DT <= '''||P_END_DT||'''
                      GROUP BY
                              STO.BRAND_CD
                            , CSH.STOR_CD
                            , STO.STOR_NM
                            , V02.AGE_GROUP
                    ) V03
              ';

    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || v_query
            || ' ) SCM '
            || ' PIVOT '
            || ' ( SUM(DAY_CUST_CNT  ) CT1 '
            || ' , SUM(DAY_SAV_PT    ) CT2 '
            || ' , AVG(DAY_AVG_SAV_PT) CT3 '
            || ' FOR (AGE_GROUP) IN ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2,3 ASC';
          
    OPEN O_CURSOR FOR V_SQL;
    
END STORE_POINT_SAV_AGE_SELECT;

/
