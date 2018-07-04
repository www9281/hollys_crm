--------------------------------------------------------
--  DDL for Package Body PKG_SALE1440
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1440" AS

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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     POSA 기프트카드 세부현황(충전) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-22         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-12-22
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
    ls_err_cd       VARCHAR2(7) := '0';
    ls_err_msg      VARCHAR2(500);

    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_sql_cm_00945 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00945 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00945') ;
        -------------------------------------------------------------------------------        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ]'
        ||CHR(13)||CHR(10)||Q'[         ML.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.SALE_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.CODE_NM AS SALE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.POS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.RSV_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.CODE_NM  AS RSV_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.PAY_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  P.PAY_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.APPR_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.CARD_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.M_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_TM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(RSV_DIV, '8',-1, 1) * ML.APPR_AMT AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  HD.CUST_ID   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(HD.CUST_NM)                      AS  CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE( ML.USE_YN ,'N',FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N') , NVL2(H.CANCEL_DT, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N'), FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR'))) AS  APPR_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG ML ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST    ST ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_HD    HD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PAY_MST    P  ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00435 || Q'[ C1        ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00945 || Q'[ C2        ]'
        ||CHR(13)||CHR(10)||Q'[      ,(           ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  /*+ INDEX(H IDX01_SALE_HD) */   ]'
        ||CHR(13)||CHR(10)||Q'[                 H.SALE_DT         AS CANCEL_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.COMP_CD         AS COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.BRAND_CD        AS BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.STOR_CD         AS STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.POS_NO          AS POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.VOID_BEFORE_NO  AS BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.VOID_BEFORE_DT  AS SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  MOBILE_LOG M, SALE_HD H, S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE  M.COMP_CD     = S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BRAND_CD    = S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.STOR_CD     = S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.COMP_CD     = H.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BRAND_CD    = H.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.STOR_CD     = H.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.POS_NO      = H.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BILL_NO     = H.VOID_BEFORE_NO]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.SALE_DT     = H.VOID_BEFORE_DT]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.COMP_CD     = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.MOBILE_DIV IN ('93','94')]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.USE_YN   = 'Y'                ]'
        ||CHR(13)||CHR(10)||Q'[       ) H                             ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD    = ST.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = ST.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = ST.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = ST.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = ST.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.APPR_DT    = ST.APPR_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.APPR_TM    = ST.APPR_TM    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = ST.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = HD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = HD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = HD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = HD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = HD.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = HD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = P.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.MOBILE_DIV = P.PAY_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = H.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = H.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = H.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = H.POS_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = H.BILL_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = H.SALE_DT(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DIV   = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = C2.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.RSV_DIV    = C2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.MOBILE_DIV IN ('93', '94') ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.RSV_DIV    IN ('8', '9')   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.GIFT_DIV   <> '0'          ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  AND    (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ST.SEQ = 1                    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.SALE_DT DESC            ]'  
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE 
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV;

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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     POSA 기프트카드 세부현황(사용) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-22         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-12-22
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
    ls_err_cd       VARCHAR2(7) := '0';
    ls_err_msg      VARCHAR2(500);

    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드SQL
    ls_sql_cm_00945 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00945 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00945') ;
        -------------------------------------------------------------------------------        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ]'
        ||CHR(13)||CHR(10)||Q'[         ML.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.CODE_NM  AS SALE_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.POS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.CODE_NM  AS RSV_DIV_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.CARD_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_NO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.APPR_TM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE( ML.SALE_DIV, '2',-1, 1) * ML.APPR_AMT AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE( ML.USE_YN ,'N',FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N') , NVL2(H.CANCEL_DT, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_N'), FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR'))) AS  APPR_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ML.BRAND_CD AS BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG ML ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST    ST ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_HD    HD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PAY_MST    P  ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00435 || Q'[ C1        ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00945 || Q'[ C2        ]'
        ||CHR(13)||CHR(10)||Q'[      ,(           ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  /*+ INDEX(H IDX01_SALE_HD) */   ]'
        ||CHR(13)||CHR(10)||Q'[                 H.SALE_DT         AS CANCEL_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.COMP_CD         AS COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.BRAND_CD        AS BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.STOR_CD         AS STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  M.POS_NO          AS POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.VOID_BEFORE_NO  AS BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.VOID_BEFORE_DT  AS SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  MOBILE_LOG M, SALE_HD H, S_STORE S ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE  M.COMP_CD     = S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BRAND_CD    = S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.STOR_CD     = S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.COMP_CD     = H.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BRAND_CD    = H.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.STOR_CD     = H.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.POS_NO      = H.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.BILL_NO     = H.VOID_BEFORE_NO]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.SALE_DT     = H.VOID_BEFORE_DT]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.COMP_CD     = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.MOBILE_DIV IN ('75','93','94')]'
        ||CHR(13)||CHR(10)||Q'[           AND   M.USE_YN   = 'Y'                ]'
        ||CHR(13)||CHR(10)||Q'[       ) H                             ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD    = ST.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = ST.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = ST.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = ST.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = ST.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.APPR_DT    = ST.APPR_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.APPR_TM    = ST.APPR_TM    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = ST.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = HD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = HD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = HD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = HD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = HD.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = HD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = P.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = P.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.MOBILE_DIV = P.PAY_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = H.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BRAND_CD   = H.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.STOR_CD    = H.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.POS_NO     = H.POS_NO(+)   ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.BILL_NO    = H.BILL_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT    = H.SALE_DT(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DIV   = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = C2.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.RSV_DIV    = C2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.MOBILE_DIV IN ('75', '93', '94') ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.GIFT_DIV   = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.COMP_CD    = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ML.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  AND    (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  AND    ST.SEQ = 1                    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.SALE_DT DESC            ]'  
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE 
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV;

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

END PKG_SALE1440;

/
