--------------------------------------------------------
--  DDL for Package Body PKG_SALE4741
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4741" AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4741
   --  Description      : 현금영수증 승인 조회(점포별 누계)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     현금영수증 승인 조회(점포별 누계)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-18
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_NM         AS  BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD          AS   STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM          AS   STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DT          AS   SALE_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.POS_NO           AS    POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_NO          AS   BILL_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_NO          AS   APPR_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_DT          AS   APPR_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_TM          AS   APPR_TM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN A.SALE_DIV = '1' THEN A.APPR_AMT ELSE A.APPR_AMT * (-1) END  AS  APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.CARD_NO          AS   CARD_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DIV         AS  SALE_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL2(H.CANCEL_DT, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N'), FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR')) AS  APPR_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  H.CANCEL_DT        AS CANCEL_DT       ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    CASH_LOG    A, S_STORE    S,          ]'
        ||CHR(13)||CHR(10)||Q'[      (                                        ]'
        ||CHR(13)||CHR(10)||Q'[      SELECT  H.SALE_DT     AS CANCEL_DT       ]'
        ||CHR(13)||CHR(10)||Q'[           ,  C.COMP_CD     AS COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[           ,  C.BRAND_CD    AS BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[           ,  C.STOR_CD     AS STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[           ,  C.POS_NO      AS POS_NO          ]'
        ||CHR(13)||CHR(10)||Q'[           ,  H.VOID_BEFORE_NO     AS BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  H.VOID_BEFORE_DT     AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      FROM    CASH_LOG C, SALE_HD H, S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[      WHERE   C.COMP_CD  = S.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.BRAND_CD = S.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.STOR_CD  = S.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.COMP_CD  = H.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.BRAND_CD = H.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.STOR_CD  = H.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.POS_NO   = H.POS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.BILL_NO  = H.VOID_BEFORE_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.SALE_DT  = H.VOID_BEFORE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.COMP_CD  = :PSV_COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[      AND     C.USE_YN   = 'Y'                 ]'
        ||CHR(13)||CHR(10)||Q'[      )  H                                     ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   S.COMP_CD   = A.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.BRAND_CD  = A.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.STOR_CD   = A.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.COMP_CD   = H.COMP_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.BRAND_CD  = H.BRAND_CD(+)           ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.STOR_CD   = H.STOR_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.POS_NO    = H.POS_NO(+)             ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.BILL_NO   = H.BILL_NO(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.SALE_DT   = H.SALE_DT(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.COMP_CD   = :PSV_COMP_CD            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.SALE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[ AND     A.USE_YN    = 'Y'                     ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                                     ]'
        ||CHR(13)||CHR(10)||Q'[         S.STOR_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[       , A.SALE_DT                             ]';


        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD,
                         PSV_COMP_CD, PSV_LANG_CD,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE4741;

/
