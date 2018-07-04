--------------------------------------------------------
--  DDL for Package Body PKG_STCK1070
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK1070" AS

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
        PSV_SURV_GRP    IN  VARCHAR2 ,                -- 실사구분
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 자재코드/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    재고실사현황 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-11-03         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-11-03
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  SD.SURV_DT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP)      AS STOR_TP      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_TP_NM)   AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CASE WHEN SD.SURV_GRP = '02' THEN 'Y' ELSE 'N' END) AS SURV_GRP_02  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CASE WHEN SD.SURV_GRP = '03' THEN 'Y' ELSE 'N' END) AS SURV_GRP_03  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CASE WHEN SD.SURV_GRP = '01' THEN 'Y' ELSE 'N' END) AS SURV_GRP_01  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SURV_STOCK_DT   SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM          I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SURV_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_SURV_GRP IS NULL OR SD.SURV_GRP = :PSV_SURV_GRP)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (SD.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SD.BRAND_CD, SD.STOR_CD, SD.SURV_DT, SD.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SD.BRAND_CD, SD.STOR_CD, SD.SURV_DT, SD.ITEM_CD  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SURV_GRP, PSV_SURV_GRP, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

END PKG_STCK1070;

/
