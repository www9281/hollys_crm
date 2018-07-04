--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1040
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1040" AS

    PROCEDURE SP_MAIN
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
        NAME:       SP_MAIN          표준원가대비
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V2.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.CUR_SALE_AMT <> 0 THEN V2.CUR_COST_AMT / V2.CUR_SALE_AMT * 100 ELSE 0 END  AS CUR_COST_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CUR_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.CMP_SALE_AMT <> 0 THEN V2.CMP_COST_AMT / V2.CMP_SALE_AMT * 100 ELSE 0 END  AS CMP_COST_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CMP_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_PRC   AS DEF_CMP_QTY_AMT  ]'                                                          /* 매출분석 > 전월대비 > 수량차이 */  
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_UNIT_PRC - V2.CMP_UNIT_PRC) * V2.CUR_SALE_QTY END)            AS DEF_CMP_AMT_AMT  ]'  /* 매출분석 > 전월대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_PRC + (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_UNIT_PRC - V2.CMP_UNIT_PRC) * V2.CUR_SALE_QTY END)    AS DEF_CMP_TOT_AMT  ]'  /* 매출분석 > 전월대비 > 합계     */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_PRC   AS DEF_STD_QTY_AMT  ]'                                                          /* 매출분석 > 표준원가대비 > 수량차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_UNIT_PRC - V2.STD_UNIT_PRC) * V2.CUR_SALE_QTY   AS DEF_STD_AMT_AMT  ]'                                                          /* 매출분석 > 표준원가대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_PRC + (V2.CUR_UNIT_PRC - V2.STD_UNIT_PRC) * V2.CUR_SALE_QTY   AS DEF_STD_TOT_AMT  ]'  /* 매출분석 > 표준원가대비 > 합계     */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_COST  AS COST_DEF_CMP_QTY ]'                                                          /* 매출원가 > 전월대비 > 수량차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_UNIT_COST - V2.CMP_UNIT_COST) * V2.CUR_SALE_QTY END)          AS COST_DEF_CMP_AMT ]'  /* 매출원가 > 전월대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_COST + (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_UNIT_COST - V2.CMP_UNIT_COST) * V2.CUR_SALE_QTY END) AS COST_DEF_CMP_TOT ]'  /* 매출원가 > 전월대비 > 합계     */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_COST  AS COST_DEF_STD_QTY ]'                                                          /* 매출원가 > 표준원가대비 > 수량차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_UNIT_COST - V2.STD_UNIT_COST) * V2.CUR_SALE_QTY AS COST_DEF_STD_AMT ]'                                                          /* 매출원가 > 표준원가대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_COST + (V2.CUR_COST_AMT - V2.STD_COST_AMT) * V2.CUR_SALE_QTY  AS COST_DEF_STD_TOT ]'  /* 매출원가 > 표준원가대비 > 합계     */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_PRC - (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_COST  AS PRO_DEF_CMP_QTY  ]'  /* 매출총이익 > 전월대비 > 수량차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE (V2.CUR_UNIT_PRC - V2.CMP_UNIT_PRC) * V2.CUR_SALE_QTY - (V2.CUR_UNIT_COST - V2.CMP_UNIT_COST) * V2.CUR_SALE_QTY END)  AS PRO_DEF_CMP_AMT  ]'  /* 매출총이익 > 전월대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  ((V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_PRC - (V2.CUR_SALE_QTY - V2.CMP_SALE_QTY) * V2.CUR_UNIT_COST) +                  ]'
        ||CHR(13)||CHR(10)||Q'[         (CASE WHEN V2.CMP_REC_CNT = 0 THEN 0 ELSE ((V2.CUR_UNIT_PRC - V2.CMP_UNIT_PRC) * V2.CUR_SALE_QTY - (V2.CUR_UNIT_COST - V2.CMP_UNIT_COST) * V2.CUR_SALE_QTY) END)AS PRO_DEF_CMP_TOT  ]'  /* 매출총이익 > 전월대비 > 합계    */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_PRC - (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_COST  AS PRO_DEF_STD_QTY  ]'  /* 매출총이익 > 표준원가대비 > 수량차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  (V2.CUR_UNIT_PRC - V2.STD_UNIT_PRC) * V2.CUR_SALE_QTY - (V2.CUR_UNIT_COST - V2.STD_UNIT_COST) * V2.CUR_SALE_QTY AS PRO_DEF_STD_AMT  ]'  /* 매출총이익 > 표준원가대비 > 단가차이 */
        ||CHR(13)||CHR(10)||Q'[      ,  ((V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_PRC - (V2.CUR_SALE_QTY - V2.STD_SALE_QTY) * V2.CUR_UNIT_COST) +                  ]'
        ||CHR(13)||CHR(10)||Q'[         ((V2.CUR_UNIT_PRC - V2.STD_UNIT_PRC) * V2.CUR_SALE_QTY - (V2.CUR_UNIT_COST - V2.STD_UNIT_COST) * V2.CUR_SALE_QTY)   AS PRO_DEF_STD_TOT  ]'  /* 매출총이익 > 표준원가대비 > 합계     */
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1      ]'      -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_SALE_QTY)    AS CUR_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_SALE_AMT)    AS CUR_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_UNIT_PRC)    AS CUR_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_COST_AMT)    AS CUR_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_UNIT_COST)   AS CUR_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CUR_TOT_PRO)     AS CUR_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_SALE_QTY)    AS CMP_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_SALE_AMT)    AS CMP_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_UNIT_PRC)    AS CMP_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_COST_AMT)    AS CMP_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_UNIT_COST)   AS CMP_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_TOT_PRO)     AS CMP_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_SALE_QTY)    AS STD_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_SALE_AMT)    AS STD_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_UNIT_PRC)    AS STD_UNIT_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_COST_AMT)    AS STD_COST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_UNIT_COST)   AS STD_UNIT_COST    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.STD_TOT_PRO)     AS STD_TOT_PRO      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(V1.CMP_REC_CNT)     AS CMP_REC_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_QTY                 AS CUR_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  JMM.GRD_AMT - JMM.VAT_AMT   AS CUR_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN ICS.RUN_QTY <> 0 THEN (JMM.GRD_AMT - JMM.VAT_AMT) / ICS.RUN_QTY ELSE 0 END    AS CUR_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_AMT                 AS CUR_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_COST                AS CUR_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (JMM.GRD_AMT - JMM.VAT_AMT - ICS.RUN_AMT)   AS CUR_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.STD_QTY                 AS STD_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  JMM.SALE_AMT - (CASE WHEN ITM.SALE_VAT_YN = 'Y' THEN JMM.SALE_AMT / ((1 + ITM.SALE_VAT_IN_RATE) * 10) ELSE 0 END)   AS STD_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN ICS.STD_QTY = 0 THEN 0 ELSE (JMM.SALE_AMT - (CASE WHEN ITM.SALE_VAT_YN = 'Y' THEN JMM.SALE_AMT / ((1 + ITM.SALE_VAT_IN_RATE) * 10) ELSE 0 END)) / ICS.STD_QTY END AS STD_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.STD_AMT                 AS STD_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.STD_COST                AS STD_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  JMM.SALE_AMT - (CASE WHEN ITM.SALE_VAT_YN = 'Y' THEN JMM.SALE_AMT / ((1 + ITM.SALE_VAT_IN_RATE) * 10) ELSE 0 END) - ICS.STD_AMT AS STD_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CMP_REC_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  S_STORE         STR     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ITEM            ITM     ]'                                
        ||CHR(13)||CHR(10)||Q'[                              ,  ITEM_CHAIN_STD  ICS     ]'                                  
        ||CHR(13)||CHR(10)||Q'[                              ,  SALE_JMM        JMM     ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  ICS.COMP_CD = STR.COMP_CD   ]'                     
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.BRAND_CD= STR.BRAND_CD  ]'                    
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.STOR_CD = STR.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.COMP_CD = ITM.COMP_CD   ]'                   
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.ITEM_CD = ITM.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.COMP_CD = JMM.COMP_CD   ]'                   
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.BRAND_CD= JMM.BRAND_CD  ]'                    
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.STOR_CD = JMM.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.ITEM_CD = JMM.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.CALC_YM = JMM.SALE_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.CALC_YM = :PSV_G_YM     ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STR.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS CUR_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_QTY                 AS CMP_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  JMM.GRD_AMT - JMM.VAT_AMT   AS CMP_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  CASE WHEN ICS.RUN_QTY <> 0 THEN (JMM.GRD_AMT - JMM.VAT_AMT) / ICS.RUN_QTY ELSE 0 END    AS CMP_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_AMT                 AS CMP_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ICS.RUN_COST                AS CMP_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (JMM.GRD_AMT - JMM.VAT_AMT - ICS.RUN_AMT)   AS CMP_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_UNIT_PRC ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_COST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_UNIT_COST]'
        ||CHR(13)||CHR(10)||Q'[                              ,  0                           AS STD_TOT_PRO  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  COUNT(*) OVER (PARTITION BY STR.COMP_CD, STR.BRAND_CD, STR.STOR_CD, ICS.ITEM_CD)    AS CMP_REC_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  S_STORE         STR ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ITEM_CHAIN_STD  ICS ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SALE_JMM        JMM ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  ICS.COMP_CD = STR.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.BRAND_CD= STR.BRAND_CD  ]'                    
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.STOR_CD = STR.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.COMP_CD = JMM.COMP_CD   ]'                   
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.BRAND_CD= JMM.BRAND_CD  ]'                    
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.STOR_CD = JMM.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.ITEM_CD = JMM.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.CALC_YM = JMM.SALE_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  ICS.CALC_YM = :PSV_D_YM     ]'
        ||CHR(13)||CHR(10)||Q'[                     )   V1          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY V1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  V1.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         )   V2      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V2.COMP_CD  = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V2.ITEM_CD  = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V2.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ITEM_CD                  ]';

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

END PKG_ANAL1040;

/
