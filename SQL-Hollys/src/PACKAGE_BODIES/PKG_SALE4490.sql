--------------------------------------------------------
--  DDL for Package Body PKG_SALE4490
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4490" AS

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
        PSV_SOGAE_YN    IN  VARCHAR2 ,                -- 취소구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     결제전 취소현황(한점포) - 목록
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


        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DD.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SALE_DT                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.STOR_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.POS_NO                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(FC_GET_WEEK(:PSV_COMP_CD, DD.SALE_DT, :PSV_LANG_CD))    AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SOGAE_YN                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DD.SALE_QTY)    AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DD.SALE_AMT)    AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  DEL_DT      DD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DD.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_SOGAE_YN IS NULL OR DD.SOGAE_YN = :PSV_SOGAE_YN)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR DD.GIFT_DIV = :PSV_GIFT_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY DD.COMP_CD, DD.SALE_DT, DD.BRAND_CD, DD.STOR_CD, DD.POS_NO, DD.SOGAE_YN  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY DD.COMP_CD, DD.SALE_DT, DD.BRAND_CD, DD.STOR_CD, DD.POS_NO, DD.SOGAE_YN  ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                         PSV_SOGAE_YN, PSV_SOGAE_YN, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

    PROCEDURE SP_TAB02_MAIN
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
        PSV_SOGAE_YN    IN  VARCHAR2 ,                -- 취소구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02_MAIN     결제전 취소현황(한점포) 상세 - 메인
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02_MAIN
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

    ls_sql_cm_00440 VARCHAR2(1000) ;    -- 공통코드SQL

    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DD.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SALE_DT                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.POS_NO                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.BILL_NO                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.CODE_NM           AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SOGAE_YN                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.CASHIER_ID                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SU.USER_NM)     AS CASHIER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DD.SALE_QTY)    AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DD.SALE_AMT)    AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  DEL_DT      DD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  U           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L           ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   SU                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00440 || Q'[ D        ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DD.COMP_CD  = S.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.BRAND_CD = S.BRAND_CD            ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.STOR_CD  = S.STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.COMP_CD  = SU.COMP_CD(+)         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.BRAND_CD = SU.BRAND_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.STOR_CD  = SU.STOR_CD(+)         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.CASHIER_ID = SU.USER_ID(+)       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.GIFT_DIV = D.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.COMP_CD  = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_SOGAE_YN IS NULL OR DD.SOGAE_YN = :PSV_SOGAE_YN)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR DD.GIFT_DIV = :PSV_GIFT_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY DD.COMP_CD, DD.SALE_DT, DD.BRAND_CD, DD.STOR_CD, DD.POS_NO, DD.BILL_NO, D.CODE_NM, DD.CASHIER_ID, DD.SOGAE_YN  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY DD.COMP_CD, DD.SALE_DT, DD.BRAND_CD, DD.STOR_CD, DD.POS_NO, DD.BILL_NO, D.CODE_NM, DD.CASHIER_ID, DD.SOGAE_YN  ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                         PSV_SOGAE_YN, PSV_SOGAE_YN, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

    PROCEDURE SP_TAB02_SUB
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 판매일자
        PSV_POS_NO      IN  VARCHAR2 ,                -- 포스번호
        PSV_BILL_NO     IN  VARCHAR2 ,                -- 영수번호
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02_SUB     결제전 취소현황(한점포) 상세 - 서브
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02_MAIN
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


        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DD.ITEM_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(DD.DEL_DT, 'HH24:MI:SS') AS DEL_TM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SALE_QTY                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DD.SALE_AMT                     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  DEL_DT      DD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  DD.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.COMP_CD  = I.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.ITEM_CD  = I.ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.SALE_DT  = :PSV_SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.POS_NO   = :PSV_POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DD.BILL_NO  = :PSV_BILL_NO      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR DD.GIFT_DIV = :PSV_GIFT_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY DD.SEQ                       ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT, PSV_POS_NO, PSV_BILL_NO,
                         PSV_GIFT_DIV, PSV_GIFT_DIV;

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

END PKG_SALE4490;

/
