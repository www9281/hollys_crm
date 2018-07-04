--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1010
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1010" AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_G_YM        IN  VARCHAR2 ,                -- 조회 년월
        PSV_D_YM        IN  VARCHAR2 ,                -- 대비 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    자재원가차이 - 전체
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  V2.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_NM                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM          AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.ITEM_NM          AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.DO_UNIT_NM       AS C_ITEM_UNIT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST   AS DEF_C_QTY_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_AMT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST + CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_TOT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM          C1          ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM          C2          ]'  -- 원자재
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_QTY )  AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_AMT )  AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_COST)  AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_QTY )  AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_AMT )  AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_COST)  AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_REC_CNT   )  AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD    ]'    
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD   ]'                                    
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_G_YM             ]' 
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  COUNT(*) OVER(PARTITION BY STR.COMP_CD, STR.BRAND_CD, STR.STOR_CD, ICR.P_ITEM_CD)   AS CMP_REC_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_D_YM             ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                     )   V1                                          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         )   V2                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V2.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.COMP_CD      = C2.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.C_ITEM_CD    = C2.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_G_YM, PSV_COMP_CD, PSV_D_YM;

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
        PSV_G_YM        IN  VARCHAR2 ,                -- 조회 년월
        PSV_D_YM        IN  VARCHAR2 ,                -- 대비 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     자재원가차이 - 메뉴분석
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  V2.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_NM                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM          AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.ITEM_NM          AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.DO_UNIT_NM       AS C_ITEM_UNIT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST   AS DEF_C_QTY_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_AMT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST + CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_TOT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM          C1          ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM          C2          ]'  -- 원자재
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_QTY )  AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_AMT )  AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_COST)  AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_QTY )  AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_AMT )  AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_COST)  AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_REC_CNT   )  AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD    ]'    
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD   ]'                                    
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_G_YM             ]' 
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  EXISTS (                            ]'
        ||CHR(13)||CHR(10)||Q'[                                             SELECT  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                                               FROM  SALE_JDM        ]'
        ||CHR(13)||CHR(10)||Q'[                                              WHERE  COMP_CD  = ICR.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  SALE_DT  BETWEEN ICR.CALC_YM||'01' AND ICR.CALC_YM||'31'    ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  BRAND_CD = ICR.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  STOR_CD  = ICR.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  ITEM_CD  = ICR.P_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                                         )                           ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  COUNT(*) OVER(PARTITION BY STR.COMP_CD, STR.BRAND_CD, STR.STOR_CD, ICR.P_ITEM_CD)   AS CMP_REC_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_D_YM             ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  EXISTS (                            ]'
        ||CHR(13)||CHR(10)||Q'[                                             SELECT  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                                               FROM  SALE_JDM        ]'
        ||CHR(13)||CHR(10)||Q'[                                              WHERE  COMP_CD  = ICR.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  SALE_DT  BETWEEN ICR.CALC_YM||'01' AND ICR.CALC_YM||'31'    ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  BRAND_CD = ICR.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  STOR_CD  = ICR.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  ITEM_CD  = ICR.P_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                                         )                           ]'
        ||CHR(13)||CHR(10)||Q'[                     )   V1                                          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         )   V2                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V2.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.COMP_CD      = C2.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.C_ITEM_CD    = C2.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_G_YM, PSV_COMP_CD, PSV_D_YM;

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
        PSV_G_YM        IN  VARCHAR2 ,                -- 조회 년월
        PSV_D_YM        IN  VARCHAR2 ,                -- 대비 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03    자재원가차이 - 자재분석
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
               || ls_sql_store -- S_STORE
               || ', '
               || ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V2.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_NM                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM          AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.ITEM_NM          AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.DO_UNIT_NM       AS C_ITEM_UNIT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_QTY            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_C_RUN_COST           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST   AS DEF_C_QTY_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_AMT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_C_RUN_QTY - V2.CMP_C_RUN_QTY) * V2.CUR_C_RUN_COST + CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_C_RUN_COST - V2.CMP_C_RUN_COST) * V2.CUR_C_RUN_QTY END AS DEF_C_TOT_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM          C1          ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM          C2          ]'  -- 원자재
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_QTY )  AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_AMT )  AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_C_RUN_COST)  AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_QTY )  AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_AMT )  AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_C_RUN_COST)  AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_REC_CNT   )  AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD    ]'    
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD   ]'                                    
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_G_YM             ]' 
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  NOT EXISTS (                        ]'
        ||CHR(13)||CHR(10)||Q'[                                             SELECT  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                                               FROM  SALE_JDM        ]'
        ||CHR(13)||CHR(10)||Q'[                                              WHERE  COMP_CD  = ICR.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  SALE_DT  BETWEEN ICR.CALC_YM||'01' AND ICR.CALC_YM||'31'    ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  BRAND_CD = ICR.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  STOR_CD  = ICR.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  ITEM_CD  = ICR.P_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                                         )                           ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.P_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.C_ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0               AS CUR_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_QTY     AS CMP_C_RUN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_AMT     AS CMP_C_RUN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICR.RUN_COST    AS CMP_C_RUN_COST   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  COUNT(*) OVER(PARTITION BY STR.COMP_CD, STR.BRAND_CD, STR.STOR_CD, ICR.P_ITEM_CD)   AS CMP_REC_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  ITEM_CHAIN_RCP ICR                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE        STR                  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD = ICR.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD= ICR.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD = ICR.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICR.CALC_YM = :PSV_D_YM             ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  NOT EXISTS (                        ]'
        ||CHR(13)||CHR(10)||Q'[                                             SELECT  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                                               FROM  SALE_JDM        ]'
        ||CHR(13)||CHR(10)||Q'[                                              WHERE  COMP_CD  = ICR.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  SALE_DT  BETWEEN ICR.CALC_YM||'01' AND ICR.CALC_YM||'31'    ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  BRAND_CD = ICR.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  STOR_CD  = ICR.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                AND  ITEM_CD  = ICR.P_ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                                         )                           ]'
        ||CHR(13)||CHR(10)||Q'[                     )   V1                                          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.P_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.C_ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         )   V2                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V2.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.COMP_CD      = C2.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.C_ITEM_CD    = C2.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.C_ITEM_CD    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_G_YM, PSV_COMP_CD, PSV_D_YM;

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

END PKG_ANAL1010;

/
