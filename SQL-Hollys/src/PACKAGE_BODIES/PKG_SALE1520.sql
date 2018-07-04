--------------------------------------------------------
--  DDL for Package Body PKG_SALE1520
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1520" AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    머그컵 사용 월별 조회(월별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7)  := '0';
    ls_err_msg      VARCHAR2(500);
    --ls_outer        VARCHAR2(10) := '(+)';
    ls_outer        VARCHAR2(10) := '';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[  SELECT                  ]'
        ||CHR(13)||CHR(10)||Q'[          SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  TO_CHAR( TO_DATE(SJ.SALE_DT), 'YYYY-MM')  AS YEAR_MONTH   ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SUM(SJ.DSP_CNT)                           AS DSP_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SUM(SJ.MUG_CNT)                           AS MUG_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  ROUND(SUM(SJ.MUG_CNT) / NULLIF(SUM(SJ.DSP_CNT),0) * 100,2)   AS MUG_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[    FROM  SALE_JDS_M  SJ  , S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[   WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[   GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  TO_CHAR( TO_DATE(SJ.SALE_DT), 'YYYY-MM' ) ]'
        ||CHR(13)||CHR(10)||Q'[   ORDER  BY S.STOR_NM, TO_CHAR( TO_DATE(SJ.SALE_DT), 'YYYY-MM' )  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    머그컵 사용 월별 조회(매장별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2018-01-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7) := '0';
    ls_err_msg      VARCHAR2(500);
    ls_outer        VARCHAR2(10) := '';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''   
        ||CHR(13)||CHR(10)||Q'[  SELECT                  ]'
        ||CHR(13)||CHR(10)||Q'[          SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SUM(SJ.DSP_CNT)                           AS DSP_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SUM(SJ.MUG_CNT)                           AS MUG_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  ROUND(SUM(SJ.MUG_CNT) / NULLIF(SUM(SJ.DSP_CNT),0) * 100,2)   AS MUG_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[    FROM  SALE_JDS_M  SJ  , S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[   WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[   GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[   ORDER  BY S.STOR_NM    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

END PKG_SALE1520;

/
