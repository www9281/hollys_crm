--------------------------------------------------------
--  DDL for Package Body PKG_STCK1050
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK1050" AS

    PROCEDURE SP_MAIN
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
        PSV_ADJ_UNIT    IN  VARCHAR2 ,                -- 손실단위
        PSV_ADJ_DIV     IN  VARCHAR2 ,                -- 손실유형
        PSV_ADJ_SUB_DIV IN  VARCHAR2 ,                -- 손실상세유형
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 자재코드/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    손실현황 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-07         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-11-07
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DA.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_DT           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_DIV          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_SUB_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_UNIT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DA.ADJ_REMARK       ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  DSTOCK_ADJ      DA  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM          I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DA.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DA.ADJ_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ADJ_UNIT    IS NULL OR DA.ADJ_UNIT = :PSV_ADJ_UNIT)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ADJ_DIV     IS NULL OR DA.ADJ_DIV  = :PSV_ADJ_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ADJ_SUB_DIV IS NULL OR DA.ADJ_SUB_DIV = :PSV_ADJ_SUB_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (DA.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY DA.BRAND_CD, DA.STOR_CD, DA.ADJ_DT, DA.ITEM_CD  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ADJ_UNIT, PSV_ADJ_UNIT, PSV_ADJ_DIV, PSV_ADJ_DIV, PSV_ADJ_SUB_DIV, PSV_ADJ_SUB_DIV, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

END PKG_STCK1050;

/
