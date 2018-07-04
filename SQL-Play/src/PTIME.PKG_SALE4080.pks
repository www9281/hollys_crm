CREATE OR REPLACE PACKAGE       PKG_SALE4080 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4080
    --  Description      : 대비 월/주 매출 신장률
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
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
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
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
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE4080;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4080 AS

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
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     대비 월/주 매출 신장률(주)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.SALE_DY                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SALE_DY_NM)   AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_SALE_AMT)   AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_DC_AMT)     AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_GRD_AMT)    AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_NET_AMT)    AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_CUST_CNT)   AS G_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 THEN 0 ELSE SUM(S.G_GRD_AMT) / SUM(S.G_CUST_CNT) END ,2)  AS G_CUST_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(S.G_GRD_AMT)) OVER () * 100, 2)   AS G_COMP_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_SALE_AMT)   AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_DC_AMT)     AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_GRD_AMT)    AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_NET_AMT)    AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_CUST_CNT)   AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.D_CUST_CNT) = 0 THEN 0 ELSE SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT) END ,2)  AS D_CUST_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(S.D_GRD_AMT)) OVER () * 100, 2)   AS D_COMP_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_SALE_AMT) = 0 AND SUM(S.D_SALE_AMT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_SALE_AMT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_SALE_AMT) - SUM(S.D_SALE_AMT)) / SUM(S.D_SALE_AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_DC_AMT)   = 0 AND SUM(S.D_DC_AMT)   = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_DC_AMT)   = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_DC_AMT) - SUM(S.D_DC_AMT)) / SUM(S.D_DC_AMT) * 100 ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_GRD_AMT)  = 0 AND SUM(S.D_GRD_AMT)  = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_GRD_AMT)  = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_GRD_AMT) - SUM(S.D_GRD_AMT)) / SUM(S.D_GRD_AMT) * 100      ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_NET_AMT)  = 0 AND SUM(S.D_NET_AMT)  = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_NET_AMT)  = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_NET_AMT) - SUM(S.D_NET_AMT)) / SUM(S.D_NET_AMT) * 100      ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_CUST_CNT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_CUST_CNT) - SUM(S.D_CUST_CNT)) / SUM(S.D_CUST_CNT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT)<> 0 THEN -100   ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_CUST_CNT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE ((SUM(S.G_GRD_AMT) / SUM(S.G_CUST_CNT)) - (SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT))) / (SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT)) * 100 ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.GFR_DATE)     AS GFR_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.GTO_DATE)     AS GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DFR_DATE)     AS DFR_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DTO_DATE)     AS DTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  C.WEEK_IN_MONTH AS SALE_DY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.WEEK_IN_MONTH || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'WEEK')  AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.SALE_AMT, 0))                        AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.DC_AMT, 0) + NVL(SJ.ENR_AMT, 0))     AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0))                         AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0) - NVL(SJ.VAT_AMT, 0))    AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', NVL(SJ.ETC_M_CNT, 0) + NVL(SJ.ETC_F_CNT, 0), NVL(SJ.BILL_CNT, 0) - NVL(SJ.RTN_BILL_CNT, 0))) AS G_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.GFR_DATE              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.GTO_DATE              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''          AS DFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''          AS DTO_DATE ]'
        ||CHR(13)||CHR(10)||q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  WEEK_IN_MONTH                       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  MAX(WEEK_STARTING_DT)   AS GFR_DATE ]'
        ||CHR(13)||CHR(10)||q'[                              ,  MAX(WEEK_ENDING_DT)     AS GTO_DATE ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  CALENDAR    ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  YMD BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||q'[                          GROUP  BY WEEK_IN_MONTH    ]'
        ||CHR(13)||CHR(10)||q'[                     )   C           ]'
        ||CHR(13)||CHR(10)||q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ENR_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_M_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_F_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.RTN_BILL_CNT ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||q'[                     )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.SALE_DT(+)  BETWEEN C.GFR_DATE AND C.GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY C.WEEK_IN_MONTH          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.GFR_DATE                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.GTO_DATE                  ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  C.WEEK_IN_MONTH AS SALE_DY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.WEEK_IN_MONTH || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'WEEK')  AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                               AS G_CUST_CNT   ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.SALE_AMT, 0))                        AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.DC_AMT, 0) + NVL(SJ.ENR_AMT, 0))     AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0))                         AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0) - NVL(SJ.VAT_AMT, 0))    AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', NVL(SJ.ETC_M_CNT, 0) + NVL(SJ.ETC_F_CNT, 0), NVL(SJ.BILL_CNT, 0) - NVL(SJ.RTN_BILL_CNT, 0))) AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''          AS GFR_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''          AS GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.DFR_DATE              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.DTO_DATE              ]'
        ||CHR(13)||CHR(10)||q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  WEEK_IN_MONTH                       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  MAX(WEEK_STARTING_DT)   AS DFR_DATE ]'
        ||CHR(13)||CHR(10)||q'[                              ,  MAX(WEEK_ENDING_DT)     AS DTO_DATE ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  CALENDAR    ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  YMD BETWEEN :PSV_DFR_DATE AND :PSV_DTO_DATE ]'
        ||CHR(13)||CHR(10)||q'[                          GROUP  BY WEEK_IN_MONTH    ]'
        ||CHR(13)||CHR(10)||q'[                     )           C   ]'
        ||CHR(13)||CHR(10)||q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ENR_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_M_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_F_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.RTN_BILL_CNT ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN :PSV_DFR_DATE AND :PSV_DTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||q'[                     )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.SALE_DT(+)  BETWEEN C.DFR_DATE AND C.DTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY C.WEEK_IN_MONTH          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.DFR_DATE                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.DTO_DATE                  ]'
        ||CHR(13)||CHR(10)||Q'[         )   S           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_DY      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DY      ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD,  PSV_CUST_DIV, PSV_GFR_DATE, PSV_GTO_DATE 
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV
                       , PSV_COMP_CD, PSV_LANG_CD,  PSV_CUST_DIV, PSV_DFR_DATE, PSV_DTO_DATE
                       , PSV_COMP_CD, PSV_DFR_DATE, PSV_DTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     대비 월/주 매출 신장률(요일)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.SALE_DY                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SALE_DY_NM)   AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_SALE_AMT)   AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_DC_AMT)     AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_GRD_AMT)    AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_NET_AMT)    AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.G_CUST_CNT)   AS G_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 THEN 0 ELSE SUM(S.G_GRD_AMT) / SUM(S.G_CUST_CNT) END ,2)  AS G_CUST_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(S.G_GRD_AMT)) OVER () * 100, 2)   AS G_COMP_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_SALE_AMT)   AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_DC_AMT)     AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_GRD_AMT)    AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_NET_AMT)    AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(S.D_CUST_CNT)   AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.D_CUST_CNT) = 0 THEN 0 ELSE SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT) END ,2)  AS D_CUST_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(S.D_GRD_AMT)) OVER () * 100, 2)   AS D_COMP_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_SALE_AMT) = 0 AND SUM(S.D_SALE_AMT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_SALE_AMT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_SALE_AMT) - SUM(S.D_SALE_AMT)) / SUM(S.D_SALE_AMT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_DC_AMT)   = 0 AND SUM(S.D_DC_AMT)   = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_DC_AMT)   = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_DC_AMT) - SUM(S.D_DC_AMT)) / SUM(S.D_DC_AMT) * 100 ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_GRD_AMT)  = 0 AND SUM(S.D_GRD_AMT)  = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_GRD_AMT)  = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_GRD_AMT) - SUM(S.D_GRD_AMT)) / SUM(S.D_GRD_AMT) * 100      ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_NET_AMT)  = 0 AND SUM(S.D_NET_AMT)  = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_NET_AMT)  = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_NET_AMT) - SUM(S.D_NET_AMT)) / SUM(S.D_NET_AMT) * 100      ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_CUST_CNT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(S.G_CUST_CNT) - SUM(S.D_CUST_CNT)) / SUM(S.D_CUST_CNT) * 100   ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT) = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.G_CUST_CNT) = 0 AND SUM(S.D_CUST_CNT)<> 0 THEN -100   ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(S.D_CUST_CNT) = 0                           THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE ((SUM(S.G_GRD_AMT) / SUM(S.G_CUST_CNT)) - (SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT))) / (SUM(S.D_GRD_AMT) / SUM(S.D_CUST_CNT)) * 100 ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS IR_CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D')               AS SALE_DY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD))    AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.SALE_AMT, 0))                            AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.DC_AMT, 0) + NVL(SJ.ENR_AMT, 0))         AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0))                             AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0) - NVL(SJ.VAT_AMT, 0))        AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', NVL(SJ.ETC_M_CNT, 0) + NVL(SJ.ETC_F_CNT, 0), NVL(SJ.BILL_CNT, 0) - NVL(SJ.RTN_BILL_CNT, 0))) AS G_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ENR_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_M_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_F_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.RTN_BILL_CNT ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||q'[                     )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D')   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D')               AS SALE_DY      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD))    AS SALE_DY_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS G_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS G_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS G_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS G_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                                   AS G_CUST_CNT   ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.SALE_AMT, 0))                            AS D_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.DC_AMT, 0) + NVL(SJ.ENR_AMT, 0))         AS D_DC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0))                             AS D_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(SJ.GRD_AMT, 0) - NVL(SJ.VAT_AMT, 0))        AS D_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', NVL(SJ.ETC_M_CNT, 0) + NVL(SJ.ETC_F_CNT, 0), NVL(SJ.BILL_CNT, 0) - NVL(SJ.RTN_BILL_CNT, 0))) AS D_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||q'[                         SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ENR_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_M_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.ETC_F_CNT    ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||q'[                              ,  SJ.RTN_BILL_CNT ]'
        ||CHR(13)||CHR(10)||q'[                           FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||q'[                            AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN :PSV_DFR_DATE AND :PSV_DTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||q'[                     )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D')    ]'
        ||CHR(13)||CHR(10)||Q'[         )   S           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_DY      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DY      ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV 
                       , PSV_COMP_CD, PSV_DFR_DATE, PSV_DTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
END PKG_SALE4080;

/
