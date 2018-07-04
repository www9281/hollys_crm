--------------------------------------------------------
--  DDL for Package Body PKG_SALE4900
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4900" AS

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
        NAME:       SP_TAB01    요일별 매출현황(영업조직)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
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
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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
        NAME:       SP_TAB02    요일별 매출현황(부서)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB03
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
        NAME:       SP_TAB03    요일별 매출현황(팀)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB04
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
        NAME:       SP_TAB04    요일별 매출현황(영업담당자)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB05
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
        NAME:       SP_TAB05    요일별 매출현황(점포)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB06
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
        NAME:       SP_TAB06    요일별 매출현황(지역)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB06
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.REGION_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.REGION_NM)    AS REGION_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.REGION_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.REGION_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.REGION_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.REGION_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB07
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
        NAME:       SP_TAB07    요일별 매출현황(상권)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB07
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TRAD_AREA_NM) AS TRAD_AREA_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.QTY))   AS SUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT))   AS SUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '1', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SUN_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.QTY))   AS MON_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT))   AS MON_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '2', S.AMT)) / SUM(S.AMT) * 100  ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS MON_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.QTY))   AS TUE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT))   AS TUE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '3', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS TUE_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.QTY))   AS WED_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT))   AS WED_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '4', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS WED_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.QTY))   AS THU_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT))   AS THU_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '5', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS THU_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.QTY))   AS FRI_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT))   AS FRI_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '6', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS FRI_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.QTY))   AS SAT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT))   AS SAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(S.AMT) = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(DECODE(TO_CHAR(TO_DATE(S.SALE_DT, 'YYYYMMDD'), 'D'), '7', S.AMT)) / SUM(S.AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS SAT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.QTY)          AS TOT_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.AMT)          AS TOT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, SJ.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TRAD_AREA     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TRAD_AREA_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_QTY AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  S.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER)         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE4900;

/
