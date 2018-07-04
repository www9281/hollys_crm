--------------------------------------------------------
--  DDL for Package Body PKG_SALE1460
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1460" AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    종합 매출현황(상권)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-27         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-12-27
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
    --ls_outer      VARCHAR2(10) := '(+)';
    ls_outer      VARCHAR2(10) := '';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (SJ.NET_AMT / NULLIF(SJ.CUST_CNT,0) ) AS CUST_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (SJ.NET_AMT / NULLIF(SJ.BILL_CNT,0) ) AS BILL_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT/NULLIF(SJ.SALE_DT_CNT,0) AS DAY_AVG_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT       AS PAY_10_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_10_AMT + SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_10_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_20_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_20_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_30_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_40_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_40_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_50_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_50_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_62_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_62_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_68_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_68_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_69_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_69_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_70_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_70_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_71_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_71_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_72_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_72_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_73_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_73_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_74_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_74_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_75_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_75_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_76_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_76_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_77_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_77_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_83_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_83_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_93_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_93_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_94_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_94_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (SELECT  SUM(COUNT(DISTINCT SALE_DT))  ]' -- 매장을 DISTINCT 한후 COUNT ???
        ||CHR(13)||CHR(10)||Q'[                        FROM  SALE_JDS    SJX               ]'
        ||CHR(13)||CHR(10)||Q'[                       WHERE  SJX.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                         AND  SJX.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE           ]'
        ||CHR(13)||CHR(10)||Q'[                         AND  (:PSV_GIFT_DIV IS NULL OR SJX.GIFT_DIV = :PSV_GIFT_DIV)        ]'
        ||CHR(13)||CHR(10)||Q'[                       GROUP BY SALE_DT                     ]'
        ||CHR(13)||CHR(10)||Q'[                     )                                  AS SALE_DT_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                   AS SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT  + SJ.ENR_AMT)       AS DC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                    AS GRD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)       AS NET_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                    AS VAT_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.R_GRD_AMT)                  AS RTN_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT) AS CUST_CNT    ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)   AS BILL_CNT ]'                 -- R_BILL_CNT 는 ??? 
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS  SJ  , S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )) ,0) AS PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  , S_STORE S     ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP   , S_STORE S        ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD    = SP.COMP_CD  ]' || ls_outer 
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD   = SP.BRAND_CD ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD    = SP.STOR_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD    = S.COMP_CD   ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD   = S.BRAND_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD    = S.STOR_CD   ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                       ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    종합 매출현황(직가맹)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-27         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-12-27
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
    --ls_outer      VARCHAR2(10) := '(+)';
    ls_outer      VARCHAR2(10) := '';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_AMT        )   AS SALE_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT          )   AS DC_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(GRD_AMT         )   AS GRD_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NET_AMT         )   AS NET_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(VAT_AMT         )   AS VAT_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(RTN_AMT         )   AS RTN_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT        )   AS CUST_CNT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NET_AMT) / NULLIF(SUM(CUST_CNT),0)       AS CUST_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(BILL_CNT        )   AS BILL_CNT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NET_AMT) / NULLIF(SUM(BILL_CNT),0)       AS BILL_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SALE_DT_CNT     )   AS SALE_DT_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NET_AMT) / NULLIF(SUM(SALE_DT_CNT),0)    AS DAY_AVG_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_10_AMT      )   AS PAY_10_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_10_RATE     )   AS PAY_10_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_20_AMT      )   AS PAY_20_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_20_RATE     )   AS PAY_20_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_30_AMT      )   AS PAY_30_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_30_RATE     )   AS PAY_30_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_40_AMT      )   AS PAY_40_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_40_RATE     )   AS PAY_40_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_50_AMT      )   AS PAY_50_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_50_RATE     )   AS PAY_50_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_62_AMT      )   AS PAY_62_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_62_RATE     )   AS PAY_62_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_68_AMT      )   AS PAY_68_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_68_RATE     )   AS PAY_68_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_69_AMT      )   AS PAY_69_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_69_RATE     )   AS PAY_69_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_70_AMT      )   AS PAY_70_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_70_RATE     )   AS PAY_70_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_71_AMT      )   AS PAY_71_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_71_RATE     )   AS PAY_71_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_72_AMT      )   AS PAY_72_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_72_RATE     )   AS PAY_72_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_73_AMT      )   AS PAY_73_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_73_RATE     )   AS PAY_73_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_74_AMT      )   AS PAY_74_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_74_RATE     )   AS PAY_74_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_75_AMT      )   AS PAY_75_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_75_RATE     )   AS PAY_75_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_76_AMT      )   AS PAY_76_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_76_RATE     )   AS PAY_76_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_77_AMT      )   AS PAY_77_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_77_RATE     )   AS PAY_77_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_83_AMT      )   AS PAY_83_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_83_RATE     )   AS PAY_83_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_93_AMT      )   AS PAY_93_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_93_RATE     )   AS PAY_93_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_94_AMT      )   AS PAY_94_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_94_RATE     )   AS PAY_94_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(PAY_AMT         )   AS PAY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[ FROM( ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (SELECT  SUM(COUNT(DISTINCT SALE_DT))  ]' -- 매장을 DISTINCT 한후 COUNT ???
        ||CHR(13)||CHR(10)||Q'[            FROM  SALE_JDS    SJX               ]'
        ||CHR(13)||CHR(10)||Q'[           WHERE  SJX.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[             AND  SJX.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE           ]'
        ||CHR(13)||CHR(10)||Q'[             AND  (:PSV_GIFT_DIV IS NULL OR SJX.GIFT_DIV = :PSV_GIFT_DIV)        ]'
        ||CHR(13)||CHR(10)||Q'[           GROUP BY SALE_DT                     ]'
        ||CHR(13)||CHR(10)||Q'[         )                                   AS SALE_DT_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT       AS PAY_10_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_10_AMT + SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_10_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_20_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_20_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_30_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_40_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_40_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_50_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_50_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_62_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_62_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_68_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_68_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_69_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_69_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_70_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_70_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_71_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_71_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_72_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_72_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_73_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_73_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_74_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_74_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_75_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_75_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_76_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_76_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_77_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_77_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_83_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_83_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_93_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_93_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_94_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_94_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_TP_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                   AS SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT  + SJ.ENR_AMT)       AS DC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                    AS GRD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)       AS NET_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                    AS VAT_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.R_GRD_AMT)                  AS RTN_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT) AS CUST_CNT    ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)   AS BILL_CNT ]'                 -- R_BILL_CNT 는 ??? 
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS  SJ  , S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD    = S.COMP_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD   = S.BRAND_CD ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD    = S.STOR_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )) ,0) AS PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  , S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP                          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD    = SP.COMP_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD   = SP.BRAND_CD ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD    = SP.STOR_CD  ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[)]'
        ||CHR(13)||CHR(10)||Q'[GROUP  BY COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,  BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    ,  BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[    ,  STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[ORDER  BY COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,  BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    ,  STOR_TP_NM   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03    종합 매출현황(팀)
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
    --ls_outer      VARCHAR2(10) := '(+)';
    ls_outer      VARCHAR2(10) := '';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR( TO_DATE(SJ.SALE_DT,'YYYYMMDD'), 'DY' ) AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT / NULLIF(SJ.CUST_CNT,0)             AS CUST_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT / NULLIF(SJ.BILL_CNT,0)             AS BILL_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT / NULLIF(SJ.SALE_DT_CNT,0)          AS DAY_AVG_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT                  AS PAY_10_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_10_AMT + SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_10_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_20_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_20_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_30_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_30_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_40_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_40_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_50_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_50_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_62_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_62_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_68_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_68_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_69_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_69_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_70_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_70_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_71_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_71_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_72_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_72_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_73_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_73_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_74_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_74_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_75_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_75_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_76_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_76_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_77_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_77_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_83_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_83_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_93_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_93_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_94_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_94_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.SALE_DT                                          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT( DISTINCT SALE_DT )          AS SALE_DT_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                   AS SALE_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT  + SJ.ENR_AMT)       AS DC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                    AS GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)       AS NET_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                    AS VAT_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.R_GRD_AMT)                  AS RTN_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT) AS CUST_CNT      ]' 
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)                   AS BILL_CNT      ]'          -- R_BILL_CNT 는 ??? 
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS  SJ , S_STORE S    ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_62_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )) ,0) AS PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_71_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_72_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_73_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_74_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_75_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_76_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_77_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_94_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                   + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  , S_STORE S    ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = S.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD, SP.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP                        ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.SALE_DT   = SP.SALE_DT ]' || ls_outer
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT   ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

END PKG_SALE1460;

/
