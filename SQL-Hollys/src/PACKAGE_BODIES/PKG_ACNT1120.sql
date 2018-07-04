--------------------------------------------------------
--  DDL for Package Body PKG_ACNT1120
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ACNT1120" AS

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
        PSV_TEXT        IN  VARCHAR2 ,                -- 
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    매장 방문 이동 현황조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
        OBJECT NAME :   SP_MAIN
        SYSDATE     :  
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
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''


        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DT   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A4.CODE_NM    AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A5.CODE_NM    AS ETC_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.ETC_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A7.RMK_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   NVL(A6.USER_NM, A1.USER_ID) AS USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT_HQ   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.REMARKS   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   STORE_ETC_AMT    A1   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   S_STORE          A2   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ACC_MST          A3   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   COMMON           A4   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   COMMON           A5   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STORE_USER       A6   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ACC_RMK          A7   ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_DIV    = '02'         ]'
        --||CHR(13)||CHR(10)||Q'[ AND    A1.CONFIRM_YN = 'Y'          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.PRC_DT     BETWEEN :PSV_GFR_DATE AND : PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_CD     = A3.ETC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.STOR_TP    = A3.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.COMP_CD    = A4.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A4.CODE_TP(+) = '00565'      ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.STOR_TP    = A4.CODE_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A5.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A5.CODE_TP(+) = '00820'      ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_DIV    = A5.CODE_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A6.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A6.BRAND_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A6.STOR_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A6.USER_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A7.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.STOR_TP    = A7.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_CD     = A7.ETC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.RMK_SEQ    = A7.RMK_SEQ   ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY A1.BRAND_CD, A1.STOR_CD, A1.PRC_DT   ]'
        ;    

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR

            ls_sql USING PSV_COMP_CD , PSV_GFR_DATE, PSV_GTO_DATE;


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

END PKG_ACNT1120;

/
