--------------------------------------------------------
--  DDL for Package Body PKG_SALE1370
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1370" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_MAIN       세트상품 선호도 붆석(세트상품) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  D1.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_TP          ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_TP_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.TEAM_NM          ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.SV_USER_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.SEASON_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.ITEM_NM          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_DT          ]'
        ||CHR(13)||CHR(10)||Q'[       , '('||TO_CHAR(TO_DATE(D1.SALE_DT, 'YYYYMMDD'), 'DY')||')' AS DAY_NAME ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.FREE_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.DC_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.GRD_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.NET_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.VAT_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.DC_QTY           ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_STORE ST  ]'
        ||CHR(13)||CHR(10)||Q'[       , S_ITEM  IT  ]'
        ||CHR(13)||CHR(10)||Q'[       ,(            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  SJ.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.BRAND_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.STOR_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.ITEM_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.SALE_DT                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.SALE_QTY)             AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.FREE_QTY)             AS FREE_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.SALE_AMT)             AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)  AS DC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.GRD_AMT)              AS GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.VAT_AMT)              AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.DC_QTY)               AS DC_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  COUNT(DISTINCT SJ.SALE_DT)   AS DAY_CNT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_JDM   SJ                           ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE    SS                           ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   SJ.COMP_CD  = SS.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.BRAND_CD = SS.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.STOR_CD  = SS.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.COMP_CD  = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.GIFT_DIV = '0'                       ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY                                       ]'
        ||CHR(13)||CHR(10)||Q'[                 SJ.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.BRAND_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.STOR_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.ITEM_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.SALE_DT                              ]'
        ||CHR(13)||CHR(10)||Q'[         )   D1                                          ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   ST.COMP_CD  = D1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     ST.BRAND_CD = D1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     ST.STOR_CD  = D1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     D1.COMP_CD  = IT.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     D1.ITEM_CD  = IT.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                           ]'
        ||CHR(13)||CHR(10)||Q'[         D1.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_TP          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_DT          ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD , PSV_GFR_DATE, PSV_GTO_DATE;

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB       세트상품 선호도 붆석(옵션상품) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  D1.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_CLASS_CD       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_CLASS_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.SEASON_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.ITEM_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.ITEM_NM          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_DT          ]'
        ||CHR(13)||CHR(10)||Q'[       , '('||TO_CHAR(TO_DATE(D1.SALE_DT, 'YYYYMMDD'), 'DY')||')' AS DAY_NAME ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.FREE_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.SALE_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.DC_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.GRD_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.NET_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.VAT_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.DC_QTY           ]'
        ||CHR(13)||CHR(10)||Q'[       , MAX(D1.STOR_CNT) OVER(PARTITION BY D1.COMP_CD, D1.BRAND_CD) AS STOR_CNT ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_ITEM  IT  ]'
        ||CHR(13)||CHR(10)||Q'[       ,(            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  SJ.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.BRAND_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.ITEM_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.SALE_DT                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.SALE_QTY)             AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.FREE_QTY)             AS FREE_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.SALE_AMT)             AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)  AS DC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.GRD_AMT)              AS GRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.VAT_AMT)              AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SJ.DC_QTY)               AS DC_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  COUNT(DISTINCT SJ.STOR_CD)   AS STOR_CNT]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_JDM   SJ                           ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE    SS                           ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   SJ.COMP_CD  = SS.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.BRAND_CD = SS.BRAND_CD               ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.STOR_CD  = SS.STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.COMP_CD  = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SJ.GIFT_DIV = '0'                       ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY                                       ]'
        ||CHR(13)||CHR(10)||Q'[                 SJ.COMP_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.BRAND_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.ITEM_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SJ.SALE_DT                              ]'
        ||CHR(13)||CHR(10)||Q'[         )   D1                                          ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   D1.COMP_CD  = IT.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     D1.ITEM_CD  = IT.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                           ]'
        ||CHR(13)||CHR(10)||Q'[         D1.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.L_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.M_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.S_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , IT.D_SORT_ORDER     ]'
        ||CHR(13)||CHR(10)||Q'[       , D1.ITEM_CD          ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD , PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE1370;

/
