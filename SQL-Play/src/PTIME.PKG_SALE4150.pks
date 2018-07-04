CREATE OR REPLACE PACKAGE       PKG_SALE4150 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4150
    --  Description      : 일별 매출현황 
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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE4150;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4150 AS

    PROCEDURE SP_MAIN
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
        NAME:       SP_MAIN     일별 매출 현황
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.WEEK_DAY     ]'
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
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_60_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_60_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_60_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_67_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_67_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_67_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_68_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_68_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_69_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_69_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_6A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_6A_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_6A_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_70_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_70_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_7A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_7A_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_7A_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_7B_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_7B_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_7B_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_7C_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_7C_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_7C_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_7D_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_7D_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_7D_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_82_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_82_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_82_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_83_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_83_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_90_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_90_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_90_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_93_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_93_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_A0_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN NVL(SP.PAY_AMT, 0) = 0 THEN 0 ELSE (SP.PAY_A0_AMT) / SP.PAY_AMT * 100 END, 2) AS PAY_A0_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SP.PAY_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD, SJ.SALE_DT, FC_GET_WEEK(SJ.COMP_CD, SJ.SALE_DT, :PSV_LANG_CD)   AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT) AS BILL_CNT, SUM(SJ.SALE_AMT) AS SALE_AMT, SUM(SJ.DC_AMT + SJ.ENR_AMT) AS DC_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT) AS GRD_AMT, SUM(SJ.GRD_AMT - SJ.VAT_AMT) AS NET_AMT, SUM(SJ.VAT_AMT) AS VAT_AMT, SUM(SJ.RTN_AMT) AS RTN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT))) AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SP.COMP_CD, SP.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_10_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_20_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_30_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_40_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_50_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '60', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_60_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '67', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_67_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_68_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_69_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '6A', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_6A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )) ,0) AS PAY_70_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '7A', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_7A_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '7B', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_7B_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '7C', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_7C_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '7D', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_7D_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '82', SP.PAY_AMT                                  )) ,0) AS PAY_82_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_83_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '90', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_90_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_93_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SP.PAY_DIV, 'A0', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))) ,0) AS PAY_A0_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ( NVL(SUM(DECODE(SP.PAY_DIV, '10', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '20', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '30', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '40', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '50', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '60', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '67', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '68', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '69', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '6A', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '70', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '7A', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '7B', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '7C', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '7D', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '82', SP.PAY_AMT                                  )), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '83', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '90', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, '93', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0)   ]'
        ||CHR(13)||CHR(10)||Q'[                     + NVL(SUM(DECODE(SP.PAY_DIV, 'A0', SP.PAY_AMT - (SP.CHANGE_AMT + SP.REMAIN_AMT))), 0))  AS PAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SP  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SP.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SP.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SP.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SP.COMP_CD, SP.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SP          ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = SP.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  = SP.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                  ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_LANG_CD, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, 
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
    
END PKG_SALE4150;

/
