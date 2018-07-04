--------------------------------------------------------
--  DDL for Package Body PKG_SALE1450
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1450" AS

    PROCEDURE SP_GRID01
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
        NAME:       SP_GRID01    일일 정산 레포트 - 시간대별 매출 실적
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID01
            SYSDATE     :   2017-12-20
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
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SEC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.RTN_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(V1.CUST_CNT) OVER(ORDER BY V1.COMP_CD, V1.BRAND_CD, V1.STOR_CD, V1.SEC_DIV) AS ACC_CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN V1.CUST_CNT = 0 THEN 0 ELSE V1.NET_AMT / V1.CUST_CNT END              AS CUST_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(V1.BILL_CNT) OVER(ORDER BY V1.COMP_CD, V1.BRAND_CD, V1.STOR_CD, V1.SEC_DIV) AS ACC_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN V1.BILL_CNT = 0 THEN 0 ELSE V1.NET_AMT / V1.BILL_CNT END              AS BILL_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SAV_PT       ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SAV_MLG      ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  JT.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.SEC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.SALE_QTY)                    AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.SALE_AMT)                    AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.DC_AMT + JT.ENR_AMT)         AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.GRD_AMT)                     AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.VAT_AMT)                     AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.GRD_AMT - JT.VAT_AMT)        AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.R_SALE_QTY)                  AS RTN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.R_GRD_AMT  - JT.R_VAT_AMT)   AS RTN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.CUST_M_CNT + JT.CUST_F_CNT)  AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.BILL_CNT)                    AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.SAV_PT)                      AS SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(JT.SAV_MLG)                     AS SAV_MLG  ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_JTS JT                 ]'
        ||CHR(13)||CHR(10)||Q'[               , S_STORE S                   ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   JT.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     JT.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     JT.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     JT.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     JT.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     JT.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[                 JT.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , JT.SEC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                     ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_GRID02
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
        NAME:       SP_GRID01    일일 정산 레포트 - 분류별 매출 실적
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID01
            SYSDATE     :   2017-12-20
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SI.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[       , SI.L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(JD.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(JD.GRD_AMT - JD.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    SALE_JDM JD                 ]'
        ||CHR(13)||CHR(10)||Q'[       , S_ITEM   SI                 ]'
        ||CHR(13)||CHR(10)||Q'[       , S_STORE  SS                 ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   JD.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = SI.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.ITEM_CD  = SI.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SI.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[       , SI.L_CLASS_NM   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_GRID03
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
        NAME:       SP_GRID03    일일 정산 레포트 - 할인내역
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID03
            SYSDATE     :   2017-12-20
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.DC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[       , DC.DC_NM        ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(SD.SALE_QTY)            AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(SD.DC_AMT + SD.ENR_AMT) AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    SALE_DC  SD                 ]'
        ||CHR(13)||CHR(10)||Q'[       , DC       DC                 ]'
        ||CHR(13)||CHR(10)||Q'[       , S_STORE  SS                 ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   SD.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.COMP_CD  = DC.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.DC_DIV   = DC.DC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SD.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         SD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SD.DC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[       , DC.DC_NM        ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_GRID04
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
        NAME:       SP_GRID04    일일 정산 레포트 - 결제수단
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID04
            SYSDATE     :   2017-12-20
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.PAY_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.PAY_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(JD.PAY_AMT) AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_STORE  SS                 ]'
        ||CHR(13)||CHR(10)||Q'[       , SALE_JDP JD                 ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  PM.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[               , PM.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[               , PM.PAY_DIV          ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(L.LANG_NM, PM.PAY_NM) AS PAY_NM ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    PAY_MST  PM         ]'
        ||CHR(13)||CHR(10)||Q'[               ,(                    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                       , PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                       , LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     TABLE_NM    = 'PAY_MST'     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     COL_NM      = 'PAY_NM'      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                ) L                                  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   L.COMP_CD(+) = PM.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     L.PK_COL(+)  = LPAD(PM.COMP_CD, 3, ' ')||LPAD(PM.BRAND_CD, 4, ' ')||LPAD(PM.PAY_DIV, 2, ' ') ]' 
        ||CHR(13)||CHR(10)||Q'[         AND     PM.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                            ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   JD.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = V1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.BRAND_CD = V1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.PAY_DIV  = V1.PAY_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.PAY_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.PAY_NM       ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, 
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

    PROCEDURE SP_GRID05
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
        NAME:       SP_GRID05    일일 정산 레포트 - 신용카드
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID05
            SYSDATE     :   2017-12-20
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CARD_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(JD.GC_QTY ) AS GC_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(JD.PAY_AMT) AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_STORE  SS                 ]'
        ||CHR(13)||CHR(10)||Q'[       , SALE_JDC JD                 ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CD.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[               , CD.VAN_CD           ]'
        ||CHR(13)||CHR(10)||Q'[               , CD.CARD_CD          ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(L.LANG_NM, CD.CARD_NM) AS CARD_NM ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    CARD  CD            ]'
        ||CHR(13)||CHR(10)||Q'[               ,(                    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                       , PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                       , LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     TABLE_NM    = 'CARD'        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     COL_NM      = 'CARD_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                ) L                                  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   L.COMP_CD(+) = CD.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     L.PK_COL(+) = LPAD(CD.VAN_CD,2,' ') || LPAD(CD.CARD_DIV,1,' ') || LPAD(CD.CARD_CD,10,' ') ]' 
        ||CHR(13)||CHR(10)||Q'[         AND     CD.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                         ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   JD.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = V1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.VAN_CD   = V1.VAN_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.CARD_CD  = V1.CARD_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     JD.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         JD.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , JD.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CARD_NM      ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, 
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

    PROCEDURE SP_GRID06
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
        NAME:       SP_GRID06    일일 정산 레포트 - 신용카드
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID06
            SYSDATE     :   2017-12-20
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SO.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.YMD          ]'
        ||CHR(13)||CHR(10)||Q'[       ,  MAX(CASE WHEN SO.JOB_DIV IN ('100', '101') THEN TO_CHAR(TO_DATE(SO.EVALU_TM, 'YYYYMMDDHH24MISS'), 'HH24:MI') END)  AS OPEN_TM  ]'
        ||CHR(13)||CHR(10)||Q'[       ,  MAX(CASE WHEN SO.JOB_DIV IN ('200', '201') THEN TO_CHAR(TO_DATE(SO.EVALU_TM, 'YYYYMMDDHH24MISS'), 'HH24:MI') END)  AS CLOSE_TM ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_STORE  SS                 ]'
        ||CHR(13)||CHR(10)||Q'[       , STORE_OC SO                 ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   SO.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SO.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SO.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SO.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     SO.YMD  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         SO.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.YMD          ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         SO.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , SO.YMD          ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_GRID07
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
        NAME:       SP_GRID07    일일 정산 레포트 - 신용카드
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-20         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_GRID07
            SYSDATE     :   2017-12-20
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

    ls_sql_cm_01415 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01415 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01415') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.GUBUN        ]'
        ||CHR(13)||CHR(10)||Q'[       , C1.CODE_NM  AS GUBUN_NM     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.AMT          ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   ]' || ls_sql_cm_01415 || Q'[ C1 ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CL.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[               , CL.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[               , CL.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CL.GUBUN = '022' THEN '021' ELSE CL.GUBUN END AS GUBUN ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(CL.AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               , MAX(                ]'
        ||CHR(13)||CHR(10)||Q'[                     CASE WHEN CL.GUBUN = '001' THEN 1   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '021' THEN 2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '022' THEN 2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '058' THEN 2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '059' THEN 2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '076' THEN 5   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '079' THEN 2   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN CL.GUBUN = '074' THEN 7   ]'
        ||CHR(13)||CHR(10)||Q'[                     END             ]'
        ||CHR(13)||CHR(10)||Q'[                    ) AS SORT_SEQ    ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_CL CL          ]'
        ||CHR(13)||CHR(10)||Q'[               , S_STORE SS          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CL.COMP_CD  = SS.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.BRAND_CD = SS.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.STOR_CD  = SS.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.GUBUN IN ('001','021','022','057','058','076','079','074')   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CL.SEQ = '99'   ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[                 CL.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , CL.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[               , CL.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CL.GUBUN = '022' THEN '021' ELSE CL.GUBUN END ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1             ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   V1.COMP_CD  = C1.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V1.GUBUN    = C1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY               ]'
        ||CHR(13)||CHR(10)||Q'[         V1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.SORT_SEQ     ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE1450;

/
