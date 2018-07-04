--------------------------------------------------------
--  DDL for Package Body PKG_SALE4390
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4390" AS

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
        PSV_POS_NO      IN  VARCHAR2 ,                -- 포스번호
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종료
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     영수증 재발행 조회
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

    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  RL.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.BILL_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_TM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(:PSV_COMP_CD, '00435', SH.SALE_DIV, :PSV_LANG_CD)  AS SALE_DIV_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(:PSV_COMP_CD, '00440', SH.GIFT_DIV, :PSV_LANG_CD)  AS GIFT_DIV_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SU.USER_NM                  AS CASHIER_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.GRD_I_AMT + SH.GRD_O_AMT AS GRD_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.PRT_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.PRT_TM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RU.USER_NM                  AS PRT_CASHIER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  REPRINT_LOG     RL  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_HD         SH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  U       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   SU                          ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  U       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   RU                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  RL.COMP_CD  = SH.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.SALE_DT  = SH.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BRAND_CD = SH.BRAND_CD   ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  RL.STOR_CD  = SH.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.POS_NO   = SH.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BILL_NO  = SH.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BRAND_CD = S.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  RL.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = SU.BRAND_CD(+)]' 
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = SU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.CASHIER_ID = SU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.COMP_CD  = RU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BRAND_CD = RU.BRAND_CD(+)]' 
        ||CHR(13)||CHR(10)||Q'[    AND  RL.STOR_CD  = RU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.CASHIER  = RU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.SALE_DT  = :PSV_SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BILL_DIV = '1'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_POS_NO   IS NULL OR RL.POS_NO   = :PSV_POS_NO)       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR RL.GIFT_DIV = :PSV_GIFT_DIV)     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.POS_NO, SH.BILL_NO, SH.SALE_TM, RL.PRT_DT, RL.PRT_TM ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                         PSV_COMP_CD, PSV_SALE_DT, PSV_POS_NO, PSV_POS_NO, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

END PKG_SALE4390;

/
