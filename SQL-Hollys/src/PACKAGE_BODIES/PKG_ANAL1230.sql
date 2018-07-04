--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1230
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1230" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN         매출액 대비 원가분석
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
    ls_sql_main     VARCHAR2(30000);
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
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN S.CUST_CNT <> 0 THEN ROUND(S.NET_AMT / S.CUST_CNT) ELSE 0 END         AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.COST_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN S.NET_AMT <> 0 THEN C.COST_AMT / S.NET_AMT * 100 ELSE 0 END, 2) AS COST_RATE]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'B', SJ.CUST_M_CNT + SJ.CUST_F_CNT, SJ.ETC_M_CNT + SJ.ETC_F_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                                                                            AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)                                                                AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_YM||'01' AND :PSV_YM||'31'   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   S       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_QTY * (CASE WHEN C.RUN_QTY <> 0 THEN C.RUN_AMT / C.RUN_QTY ELSE 0 END)) AS COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM        SJ          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         S           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ITEM_CHAIN_STD  C           ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = C.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = C.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = C.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_YM||'01' AND :PSV_YM||'31'   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.CALC_YM   = :PSV_YM       ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[         )   C       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = C.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.SALE_DT   = C.SALE_DT                 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.SALE_DT                            ]'
        ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM;


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

END PKG_ANAL1230;

/
