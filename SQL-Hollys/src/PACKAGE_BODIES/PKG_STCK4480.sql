--------------------------------------------------------
--  DDL for Package Body PKG_STCK4480
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK4480" AS
/******************************************************************************
   NAME:       PKG_STCK4480
   PURPOSE:    수주관리> 생산현황

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2011-07-28  최창록           1. Created this package.

   NOTES:
******************************************************************************/


---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_STORE_BY_ITEM_BY
--  Description      : 점포별 품목별
-- Ref. Table        : PRODUCT_DT
---------------------------------------------------------------------------------------------------
    PROCEDURE SP_STORE_BY_ITEM_BY
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    lsLine varchar2(3) := '000';

    TYPE  rec_ct_hd IS RECORD
    ( STOR_CD  VARCHAR2(10),
      STOR_TXT VARCHAR2(72)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;
    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_CNT          PLS_INTEGER;


    BEGIN

        dbms_output.enable( 1000000 ) ;

    --    lsLIne := '010';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );



        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := 'S.PRD_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
           ls_sql_date := ls_sql_date || ' AND S.PRD_DT ' || ls_ex_date1 ;
        END IF;
        ------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
        || ls_sql_store -- S_STORE
        || chr(13)||chr(10) || ','
        || ls_sql_item -- S_ITEM
        ;


        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main := ''
        || chr(13)||chr(10) ||  q'[ SELECT S.STOR_CD AS STOR_CD                               ]'
        || chr(13)||chr(10) ||  q'[      , '(' || S.STOR_CD || ')' || B.STOR_NM AS STOR_TXT   ]'
        || chr(13)||chr(10) ||  q'[   FROM PRODUCT_DT S                                       ]'
        || chr(13)||chr(10) ||  q'[      , S_STORE B                                          ]'
        || chr(13)||chr(10) ||  q'[      , S_ITEM I                                           ]'
        || chr(13)||chr(10) ||  q'[  WHERE S.COMP_CD  = B.COMP_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = B.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.STOR_CD  = B.STOR_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = I.COMP_CD                             ]'
        --|| chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = I.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.ITEM_CD  = I.ITEM_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['            ]'
        || chr(13)||chr(10) ||   '     AND ' ||  ls_sql_date
        || chr(13)||chr(10) ||  q'[  GROUP BY S.STOR_CD, B.STOR_NM                            ]'
        || chr(13)||chr(10) ||  q'[  ORDER BY S.STOR_CD                                       ]'
        ;

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        || chr(13)||chr(10) || ' SELECT L_CLASS_NM, M_CLASS_NM, S_CLASS_NM, ITEM_CD, ITEM_NM, SALE_PRC, TOTAL,  '  ;


        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).STOR_CD || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).STOR_TXT  || ''' CT  ' ;

            END;
        END LOOP;


        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD   := ' WITH S_HD AS ( '
        || chr(13)||chr(10) || '  SELECT FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''L_CLASS_NM'') AS L_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''M_CLASS_NM'') AS M_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''S_CLASS_NM'') AS S_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''ITEM_CD'') AS ITEM_CD            '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''ITEM_NM'') AS ITEM_NM            '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''SALE_PRC'') AS SALE_PRC          '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''TOTAL'') AS TOTAL                '
        || chr(13)||chr(10) || '    FROM DUAL                                                                     '
        || chr(13)||chr(10) || ' )                                                                                '
        ||  V_HD1
        ;


        /* MAIN SQL */
        ls_sql_main := ''
        ||chr(13)||chr(10)|| q'[    SELECT I.L_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , I.M_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , I.S_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , S.ITEM_CD                                                          ]'
        ||chr(13)||chr(10)|| q'[         , I.ITEM_NM                                                          ]'
        ||chr(13)||chr(10)|| q'[         , I.SALE_PRC                                                         ]'
        ||chr(13)||chr(10)|| q'[         , SUM(SUM(S.PROD_QTY)) OVER(PARTITION BY S.ITEM_CD) AS TOTAL_QTY     ]'
        ||chr(13)||chr(10)|| q'[         , SUM(S.PROD_QTY)  AS PROD_QTY                                       ]'
        ||chr(13)||chr(10)|| q'[         , S.STOR_CD                                                          ]'
        ||chr(13)||chr(10)|| q'[      FROM PRODUCT_DT S                                                       ]'
        ||chr(13)||chr(10)|| q'[         , S_STORE B                                                          ]'
        ||chr(13)||chr(10)|| q'[         , S_ITEM I                                                           ]'
        ||chr(13)||chr(10)|| q'[     WHERE S.COMP_CD  = B.COMP_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = B.BRAND_CD                                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.STOR_CD  = B.STOR_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = I.COMP_CD                                             ]'
        --||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = I.BRAND_CD                                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.ITEM_CD  = I.ITEM_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['                            ]'
        ||chr(13)||chr(10)||  '        AND ' ||  ls_sql_date
        ||chr(13)||chr(10)|| q'[     GROUP BY I.L_CLASS_NM, I.M_CLASS_NM, I.S_CLASS_NM, S.ITEM_CD             ]'
        ||chr(13)||chr(10)|| q'[            , I.ITEM_NM, I.SALE_PRC, S.STOR_CD                    ]'
        ;


        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        || chr(13)||chr(10) || ' SELECT *                            '
        || chr(13)||chr(10) || ' FROM (                              '
        || chr(13)||chr(10) ||         ls_sql
        || chr(13)||chr(10) || '      ) S_STOR                       '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' (                                   '
        || chr(13)||chr(10) || '  SUM(PROD_QTY) VCOL1                '
        || chr(13)||chr(10) || '  FOR (STOR_CD) IN (                 '
        || chr(13)||chr(10) ||                      V_CROSSTAB
        || chr(13)||chr(10) || '                   )                 '
        || chr(13)||chr(10) || ' )                                   '
        || chr(13)||chr(10) || ' ORDER BY L_CLASS_NM, M_CLASS_NM, S_CLASS_NM, ITEM_CD  '
        ;

        dbms_output.put_line( V_SQL) ;
        dbms_output.put_line( V_HD) ;


        OPEN PR_HEADER FOR
          V_HD;
        OPEN PR_RESULT FOR
          V_SQL;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
           dbms_output.put_line( PR_RTN_MSG ) ;
        WHEN OTHERS THEN
            dbms_output.put_line('line [' || lsLine || '] ' || sqlerrm(sqlcode) );
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;

    END ;


---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_DAYS_BY_ITEM_BY
--  Description      : 일자별 품목별
-- Ref. Table        : PRODUCT_DT
---------------------------------------------------------------------------------------------------
    PROCEDURE SP_DAYS_BY_ITEM_BY
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    lsLine varchar2(3) := '000';

    TYPE  rec_ct_hd IS RECORD
    ( PRD_DT  VARCHAR2(8)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;
    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_CNT          PLS_INTEGER;

      BEGIN

        dbms_output.enable( 1000000 ) ;

    --    lsLIne := '010';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );



        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := 'S.PRD_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
           ls_sql_date := ls_sql_date || ' AND S.PRD_DT ' || ls_ex_date1 ;
        END IF;
        ------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
        || ls_sql_store -- S_STORE
        || chr(13)||chr(10) || ','
        || ls_sql_item -- S_ITEM
        ;

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main := ''
        || chr(13)||chr(10) ||  q'[ SELECT S.PRD_DT AS PRD_DT                                 ]'
        || chr(13)||chr(10) ||  q'[   FROM PRODUCT_DT S                                       ]'
        || chr(13)||chr(10) ||  q'[      , S_STORE B                                          ]'
        || chr(13)||chr(10) ||  q'[      , S_ITEM I                                           ]'
        || chr(13)||chr(10) ||  q'[  WHERE S.COMP_CD  = B.COMP_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = B.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.STOR_CD  = B.STOR_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = I.COMP_CD                             ]'
        --|| chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = I.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.ITEM_CD  = I.ITEM_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['            ]'
        || chr(13)||chr(10) ||   '     AND ' ||  ls_sql_date
        || chr(13)||chr(10) ||  q'[  GROUP BY S.PRD_DT                                        ]'
        || chr(13)||chr(10) ||  q'[  ORDER BY S.PRD_DT                                        ]'
        ;

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
--        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        || chr(13)||chr(10) || ' SELECT L_CLASS_NM, M_CLASS_NM, S_CLASS_NM, ITEM_CD, ITEM_NM, SALE_PRC, TOTAL,  '  ;


        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).PRD_DT || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).PRD_DT  || ''' CT  ' ;

            END;
        END LOOP;


        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD   := ' WITH S_HD AS ( '
        || chr(13)||chr(10) || '  SELECT FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''L_CLASS_NM'') AS L_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''M_CLASS_NM'') AS M_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''S_CLASS_NM'') AS S_CLASS_NM      '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''ITEM_CD'') AS ITEM_CD            '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''ITEM_NM'') AS ITEM_NM            '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''SALE_PRC'') AS SALE_PRC          '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''TOTAL'') AS TOTAL                '
        || chr(13)||chr(10) || '    FROM DUAL                                                                     '
        || chr(13)||chr(10) || ' )                                                                                '
        ||  V_HD1
        ;


        /* MAIN SQL */
        ls_sql_main := ''
        ||chr(13)||chr(10)|| q'[    SELECT I.L_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , I.M_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , I.S_CLASS_NM                                                       ]'
        ||chr(13)||chr(10)|| q'[         , S.ITEM_CD                                                          ]'
        ||chr(13)||chr(10)|| q'[         , I.ITEM_NM                                                          ]'
        ||chr(13)||chr(10)|| q'[         , SUM(S.PROD_QTY) AS PROD_QTY                                        ]'
        ||chr(13)||chr(10)|| q'[         , I.SALE_PRC                                                         ]'
        ||chr(13)||chr(10)|| q'[         , SUM(SUM(S.PROD_QTY)) OVER(PARTITION BY S.ITEM_CD) AS TOTAL_QTY     ]'
        ||chr(13)||chr(10)|| q'[         , S.PRD_DT                                                           ]'
        ||chr(13)||chr(10)|| q'[      FROM PRODUCT_DT S                                                       ]'
        ||chr(13)||chr(10)|| q'[         , S_STORE B                                                          ]'
        ||chr(13)||chr(10)|| q'[         , S_ITEM I                                                           ]'
        ||chr(13)||chr(10)|| q'[     WHERE S.COMP_CD  = B.COMP_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = B.BRAND_CD                                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.STOR_CD  = B.STOR_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = I.COMP_CD                                             ]'
        --||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = I.BRAND_CD                                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.ITEM_CD  = I.ITEM_CD                                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['                            ]'
        ||chr(13)||chr(10)||  '        AND ' ||  ls_sql_date
        ||chr(13)||chr(10)|| q'[     GROUP BY I.L_CLASS_NM, I.M_CLASS_NM, I.S_CLASS_NM, S.ITEM_CD             ]'
        ||chr(13)||chr(10)|| q'[            , I.ITEM_NM, I.SALE_PRC, S.PRD_DT                     ]'
        ;


        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        || chr(13)||chr(10) || ' SELECT *                            '
        || chr(13)||chr(10) || ' FROM (                              '
        || chr(13)||chr(10) ||         ls_sql
        || chr(13)||chr(10) || '      ) S_STOR                       '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' (                                   '
        || chr(13)||chr(10) || '  SUM(PROD_QTY) VCOL1                '
        || chr(13)||chr(10) || '  FOR (PRD_DT) IN (                  '
        || chr(13)||chr(10) ||                      V_CROSSTAB
        || chr(13)||chr(10) || '                   )                 '
        || chr(13)||chr(10) || ' )                                   '
        || chr(13)||chr(10) || ' ORDER BY L_CLASS_NM, M_CLASS_NM, S_CLASS_NM, ITEM_CD  '
        ;

        dbms_output.put_line( V_SQL) ;
        dbms_output.put_line( V_HD) ;


        OPEN PR_HEADER FOR
          V_HD;
        OPEN PR_RESULT FOR
          V_SQL;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
           dbms_output.put_line( PR_RTN_MSG ) ;
        WHEN OTHERS THEN
            dbms_output.put_line('line [' || lsLine || '] ' || sqlerrm(sqlcode) );
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;

    END ;


---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_STORE_BY_DAYS_BY
--  Description      : 점포별 일자별
-- Ref. Table        : PRODUCT_DT
---------------------------------------------------------------------------------------------------
    PROCEDURE SP_STORE_BY_DAYS_BY
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    lsLine varchar2(3) := '000';

    TYPE  rec_ct_hd IS RECORD
    ( STOR_CD  VARCHAR2(10),
      STOR_TXT VARCHAR2(72)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;
    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_CNT          PLS_INTEGER;


    BEGIN

        dbms_output.enable( 1000000 ) ;

    --    lsLIne := '010';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );



        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := 'S.PRD_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
           ls_sql_date := ls_sql_date || ' AND S.PRD_DT ' || ls_ex_date1 ;
        END IF;
        ------------------------------------------------------------------------------

        ls_sql_with := ' WITH  '
        || ls_sql_store -- S_STORE
        || chr(13)||chr(10) || ','
        || ls_sql_item -- S_ITEM
        ;


        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main := ''
        || chr(13)||chr(10) ||  q'[ SELECT S.STOR_CD AS STOR_CD                               ]'
        || chr(13)||chr(10) ||  q'[      , '(' || S.STOR_CD || ')' || B.STOR_NM AS STOR_TXT   ]'
        || chr(13)||chr(10) ||  q'[   FROM PRODUCT_DT S                                       ]'
        || chr(13)||chr(10) ||  q'[      , S_STORE B                                          ]'
        || chr(13)||chr(10) ||  q'[      , S_ITEM I                                           ]'
        || chr(13)||chr(10) ||  q'[  WHERE S.COMP_CD  = B.COMP_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = B.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.STOR_CD  = B.STOR_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = I.COMP_CD                             ]'
        --|| chr(13)||chr(10) ||  q'[    AND S.BRAND_CD = I.BRAND_CD                            ]'
        || chr(13)||chr(10) ||  q'[    AND S.ITEM_CD  = I.ITEM_CD                             ]'
        || chr(13)||chr(10) ||  q'[    AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['            ]'
        || chr(13)||chr(10) ||   '     AND ' ||  ls_sql_date
        || chr(13)||chr(10) ||  q'[  GROUP BY S.STOR_CD, B.STOR_NM                            ]'
        || chr(13)||chr(10) ||  q'[  ORDER BY S.STOR_CD                                       ]'
        ;

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
    --    dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        || chr(13)||chr(10) || ' SELECT YMD, TOTAL,  '  ;


        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).STOR_CD || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).STOR_TXT  || ''' CT  ' ;

            END;
        END LOOP;


        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD   := ' WITH S_HD AS ( '
        || chr(13)||chr(10) || '  SELECT FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''YMD'') AS YMD                   '
        || chr(13)||chr(10) || '       , FC_GET_HEADER('''||PSV_COMP_CD||''', '''||PSV_LANG_CD||''' , ''TOTAL'') AS TOTAL                '
        || chr(13)||chr(10) || '    FROM DUAL                                                                     '
        || chr(13)||chr(10) || ' )                                                                                '
        ||  V_HD1
        ;


        /* MAIN SQL */
        ls_sql_main := ''
        ||chr(13)||chr(10)|| q'[    SELECT S.PRD_DT                                                           ]'
        ||chr(13)||chr(10)|| q'[         , SUM(SUM(S.PROD_QTY)) OVER(PARTITION BY S.PRD_DT) AS TOTAL_QTY      ]'
        ||chr(13)||chr(10)|| q'[         , SUM(S.PROD_QTY)   AS PROD_QTY                                      ]'
        ||chr(13)||chr(10)|| q'[         , S.STOR_CD                                                          ]'
        ||chr(13)||chr(10)|| q'[      FROM PRODUCT_DT S                                                       ]'
        ||chr(13)||chr(10)|| q'[         , S_STORE B                                                          ]'
        ||chr(13)||chr(10)|| q'[         , S_ITEM I                                                           ]'
        ||chr(13)||chr(10)|| q'[     WHERE S.COMP_CD  = B.COMP_CD                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = B.BRAND_CD                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.STOR_CD  = B.STOR_CD                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = I.COMP_CD                             ]'
        --||chr(13)||chr(10)|| q'[       AND S.BRAND_CD = I.BRAND_CD                            ]'
        ||chr(13)||chr(10)|| q'[       AND S.ITEM_CD  = I.ITEM_CD                             ]'
        ||chr(13)||chr(10)|| q'[       AND S.COMP_CD  = ']' || PSV_COMP_CD || q'['            ]'
        ||chr(13)||chr(10)||  '        AND ' ||  ls_sql_date
        ||chr(13)||chr(10)|| q'[     GROUP BY S.PRD_DT, S.STOR_CD                                             ]'
        ;


        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        || chr(13)||chr(10) || ' SELECT *                            '
        || chr(13)||chr(10) || ' FROM   (                            '
        || chr(13)||chr(10) ||           ls_sql
        || chr(13)||chr(10) || '        ) S_STOR                     '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' (                                   '
        || chr(13)||chr(10) || '  SUM(PROD_QTY) VCOL1                '
        || chr(13)||chr(10) || '  FOR (STOR_CD) IN (                 '
        || chr(13)||chr(10) ||                      V_CROSSTAB
        || chr(13)||chr(10) || '                   )                 '
        || chr(13)||chr(10) || ' )                                   '
        || chr(13)||chr(10) || ' ORDER BY PRD_DT                     '
        ;

        dbms_output.put_line( V_SQL) ;
        dbms_output.put_line( V_HD) ;


        OPEN PR_HEADER FOR
          V_HD;
        OPEN PR_RESULT FOR
          V_SQL;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
           dbms_output.put_line( PR_RTN_MSG ) ;
        WHEN OTHERS THEN
            dbms_output.put_line('line [' || lsLine || '] ' || sqlerrm(sqlcode) );
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;

    END ;

END PKG_STCK4480;

/
