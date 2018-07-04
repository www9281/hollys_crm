--------------------------------------------------------
--  DDL for Package Body PKG_SALE1180
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1180" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_BRAND_CD    IN  VARCHAR2 ,                -- 영업조직
        PSV_C_ITEM_CD   IN  VARCHAR2 ,                -- 역전개구성품
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     레시피 소모량 분석
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               || ls_sql_store -- S_STORE
               || ', '
               || ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  R.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.ITEM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.SALE_QTY)    AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(R.DO_QTY)       AS DO_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_QTY, 0) * NVL(R.DO_QTY, 0)) AS RCP_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  BRAND_CD            ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  R_ITEM_CD   AS ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DO_QTY) AS DO_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  TABLE(FN_RCP_STD_0073(:PSV_COMP_CD, :PSV_BRAND_CD, :PSV_SALE_DT))   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  BRAND_CD    = :PSV_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STOR_TP     = '10'          ]' 
        ||CHR(13)||CHR(10)||Q'[                AND  C_ITEM_CD   = :PSV_C_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  DO_YN       = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY COMP_CD, BRAND_CD, R_ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )           R   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT     SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  R.COMP_CD   = SD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.BRAND_CD  = SD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  R.ITEM_CD   = SD.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT  = :PSV_SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (SD.SALE_QTY <> 0 OR SALE_AMT <> 0) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (SD.SALE_DIV = '1' OR (SD.SALE_DIV = '2' AND SD.RTN_DIV = '2')) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_SET_DIV = '0'       ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY R.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.ITEM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY R.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R.ITEM_CD                   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_BRAND_CD, PSV_SALE_DT, PSV_COMP_CD, PSV_BRAND_CD, PSV_C_ITEM_CD, PSV_COMP_CD, PSV_SALE_DT;

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

END PKG_SALE1180;

/
