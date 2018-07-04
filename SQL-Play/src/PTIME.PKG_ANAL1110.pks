CREATE OR REPLACE PACKAGE       PKG_ANAL1110 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ANAL1110
    --  Description      : 자재수불
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
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_ANAL1110;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ANAL1110 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN         자재수불
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD           AS C_L_CLS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM           AS C_L_CLS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD           AS C_M_CLS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM           AS C_M_CLS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD           AS C_S_CLS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM           AS C_S_CLS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_ITEM_CD            AS C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM              AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.DO_UNIT_NM           AS C_ITEM_UNIT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M1.BEGIN_QTY            AS C_BASE_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M1.BEGIN_QTY * V1.COST  AS C_BASE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V3.ORD_QTY - V3.RTN_QTY + V3.MV_IN_QTY - V3.MV_OUT_QTY)                            AS C_CURT_IN_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (V3.ORD_QTY - V3.RTN_QTY + V3.MV_IN_QTY - V3.MV_OUT_QTY) * V1.COST                  AS C_CURT_IN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_STO_QTY / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_STD_STO_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_STO_QTY / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_STD_STO_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_HQ_QTY  / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_STD_HQ_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STD_HQ_QTY  / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_STD_HQ_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CLAIM_QTY   / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_CLAIM_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CLAIM_QTY   / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_CLAIM_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.HALL_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_HALL_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.HALL_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_HALL_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.DISU_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_DISU_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.DISU_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_DISU_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.TEST_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_TEST_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.TEST_QTY    / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_TEST_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ETC_OUT_QTY / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_ETC_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ETC_OUT_QTY / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT) * V1.COST     AS C_ETC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STD_QTY     / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_STD_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STD_AMT                                                                          AS C_STD_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.RUN_QTY     / DECODE(C1.STOCK_UNIT, C1.DO_UNIT, 1, C1.WEIGHT_UNIT)               AS C_RUN_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.RUN_AMT                                                                          AS C_RUN_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M1.END_QTY                                                                          AS C_END_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M1.END_QTY * V1.COST                                                                AS C_END_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MSTOCK      M1  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ LEADING(STO) */             ]'
        ||CHR(13)||CHR(10)||Q'[                     STO.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.BRAND_CD                    ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STO.BRAND_NM)   AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.STOR_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STO.STOR_NM)    AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.CALC_YM                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.C_ITEM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(ICR.COST)       AS COST     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.STD_QTY)    AS STD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.STD_AMT)    AS STD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.RUN_QTY)    AS RUN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.RUN_AMT)    AS RUN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ITEM_CHAIN_RCP  ICR             ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         STO             ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  STO.COMP_CD     = ICR.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.BRAND_CD    = ICR.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.STOR_CD     = ICR.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICR.CALC_YM     = :PSV_YM       ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY STO.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.BRAND_CD                    ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.STOR_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.CALC_YM                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.C_ITEM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[         )   V1  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ LEADING(STO)    */          ]'
        ||CHR(13)||CHR(10)||Q'[                     STO.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.BRAND_CD                    ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STO.BRAND_NM)   AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.STOR_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STO.STOR_NM)    AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  :PSV_YM             AS SALE_YM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CDR.C_ITEM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '02' THEN CDR.DO_QTY ELSE 0 END)    AS STD_STO_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '02' THEN CDR.DO_AMT ELSE 0 END)    AS STD_STO_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '03' THEN CDR.DO_QTY ELSE 0 END)    AS STD_HQ_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '03' THEN CDR.DO_AMT ELSE 0 END)    AS STD_HQ_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '01' THEN CDR.DO_QTY ELSE 0 END)    AS CLAIM_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '01' THEN CDR.DO_AMT ELSE 0 END)    AS CLAIM_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '05' AND CDR.ADJ_COST_DIV = '1' THEN CDR.DO_QTY ELSE 0 END) AS HALL_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '05' AND CDR.ADJ_COST_DIV = '1' THEN CDR.DO_AMT ELSE 0 END) AS HALL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '05' AND CDR.ADJ_COST_DIV = '2' THEN CDR.DO_QTY ELSE 0 END) AS COOK_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '05' AND CDR.ADJ_COST_DIV = '2' THEN CDR.DO_AMT ELSE 0 END) AS COOK_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '06' THEN CDR.DO_QTY ELSE 0 END)    AS DISU_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '06' THEN CDR.DO_AMT ELSE 0 END)    AS DISU_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '04' THEN CDR.DO_QTY ELSE 0 END)    AS TEST_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '04' THEN CDR.DO_AMT ELSE 0 END)    AS TEST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '99' THEN CDR.DO_QTY ELSE 0 END)    AS ETC_OUT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN CDR.ADJ_DIV = '99' THEN CDR.DO_AMT ELSE 0 END)    AS ETC_OUT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_CDR    CDR ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     STO ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  STO.COMP_CD     = CDR.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.BRAND_CD    = CDR.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.STOR_CD     = CDR.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STO.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CDR.SALE_DT     LIKE :PSV_YM||'%'   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY STO.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.BRAND_CD    ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  STO.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CDR.C_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[          )  V2  ]'
        ||CHR(13)||CHR(10)||Q'[       ,  (      ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ LEADING(STO) */                 ]'
        ||CHR(13)||CHR(10)||Q'[                     DST.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  :PSV_YM                 AS PRC_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.ITEM_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DST.ORD_QTY)        AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DST.MV_IN_QTY)      AS MV_IN_QTY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DST.MV_OUT_QTY)     AS MV_OUT_QTY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DST.RTN_QTY)        AS RTN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  DSTOCK      DST ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     STO ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  DST.COMP_CD     = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  DST.BRAND_CD    = STO.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  DST.STOR_CD     = STO.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  DST.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  DST.PRC_DT      LIKE :PSV_YM||'%'   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY DST.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DST.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         )   V3  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = C1.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.C_ITEM_CD    = C1.ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = M1.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = M1.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.STOR_CD      = M1.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.CALC_YM      = M1.PRC_YM         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.C_ITEM_CD    = M1.ITEM_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = V2.COMP_CD   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = V2.BRAND_CD  (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.STOR_CD      = V2.STOR_CD   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.CALC_YM      = V2.SALE_YM   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.C_ITEM_CD    = V2.C_ITEM_CD (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = V3.COMP_CD   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = V3.BRAND_CD  (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.STOR_CD      = V3.STOR_CD   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.CALC_YM      = V3.PRC_YM    (+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.C_ITEM_CD    = V3.ITEM_CD   (+)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_ITEM_CD                        ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM;

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
    
END PKG_ANAL1110;

/
