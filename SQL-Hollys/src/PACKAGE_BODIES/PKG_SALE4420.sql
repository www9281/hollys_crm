--------------------------------------------------------
--  DDL for Package Body PKG_SALE4420
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4420" AS

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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    종합 매출현황(영업조직)
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
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD, SJ.BRAND_CD, SJ.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT   AS PAY_10_AMT   ]'
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
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.BRAND_CD, MAX(S.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.R_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.R_GRD_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.BRAND_CD  ]'
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
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    종합 매출현황(부서)
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD, SJ.BRAND_CD, SJ.BRAND_NM, SJ.DEPT_CD, SJ.DEPT_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT   AS PAY_10_AMT   ]'
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
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.BRAND_CD, MAX(S.BRAND_NM) AS BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD, MAX(S.DEPT_NM) AS DEPT_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.R_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.R_GRD_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD               ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.BRAND_CD, S.DEPT_CD  ]'
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
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD, S.DEPT_CD               ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DEPT_CD  = SP.DEPT_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DEPT_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
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

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD, SJ.BRAND_CD, SJ.BRAND_NM, SJ.DEPT_CD, SJ.DEPT_NM, SJ.TEAM_CD, SJ.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT   AS PAY_10_AMT   ]'
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
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.BRAND_CD, MAX(S.BRAND_NM) AS BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD, MAX(S.DEPT_NM) AS DEPT_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD, MAX(S.TEAM_NM) AS TEAM_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.R_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.R_GRD_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD   ]'
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
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD, S.DEPT_CD, S.TEAM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DEPT_CD  = SP.DEPT_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.TEAM_CD  = SP.TEAM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DEPT_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.TEAM_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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

    PROCEDURE SP_TAB04
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04    종합 매출현황(영업담당자)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB04
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD, SJ.BRAND_CD, SJ.BRAND_NM, SJ.DEPT_CD, SJ.DEPT_NM, SJ.TEAM_CD, SJ.TEAM_NM, SJ.SV_USER_ID, SJ.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT   AS PAY_10_AMT   ]'
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
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.BRAND_CD, MAX(S.BRAND_NM) AS BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD, MAX(S.DEPT_NM) AS DEPT_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD, MAX(S.TEAM_NM) AS TEAM_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID, MAX(S.SV_USER_NM) AS SV_USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.R_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.R_GRD_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID            ]'
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
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DEPT_CD  = SP.DEPT_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.TEAM_CD  = SP.TEAM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SV_USER_ID = SP.SV_USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DEPT_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.TEAM_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SV_USER_ID               ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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

    PROCEDURE SP_TAB05
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05    종합 매출현황(점포)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB05
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD, SJ.BRAND_CD, SJ.BRAND_NM, SJ.DEPT_CD, SJ.DEPT_NM, SJ.TEAM_CD, SJ.TEAM_NM, SJ.SV_USER_ID, SJ.SV_USER_NM, SJ.STOR_CD, SJ.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_10_AMT + SP.PAY_30_AMT   AS PAY_10_AMT   ]'
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
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.BRAND_CD, MAX(S.BRAND_NM) AS BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD, MAX(S.DEPT_NM) AS DEPT_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD, MAX(S.TEAM_NM) AS TEAM_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID, MAX(S.SV_USER_NM) AS SV_USER_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD, MAX(S.STOR_NM)  AS STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.R_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.R_GRD_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.R_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID, SJ.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SP.STOR_CD  ]'
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
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '62', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '71', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '72', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '73', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '74', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '75', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '76', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '77', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '94', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID, SP.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = SP.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.DEPT_CD  = SP.DEPT_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.TEAM_CD  = SP.TEAM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SV_USER_ID = SP.SV_USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = SP.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.DEPT_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.TEAM_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SV_USER_ID               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                  ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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

END PKG_SALE4420;

/
