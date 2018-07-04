CREATE OR REPLACE PACKAGE       PKG_SALE4450 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4450
    --  Description      : 점포별 평균 매출현황 
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

END PKG_SALE4450;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4450 AS

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
        NAME:       SP_MAIN     점포별 평균 매출 현황
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.BRAND_CD                          ]'  -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                           ]'  -- 부서코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'  -- 부서명
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                           ]'  -- 팀코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'  -- 팀명
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                        ]'  -- 담당자ID
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]' -- 담당자명
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD                           ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM      ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA                         ]'  -- 상권코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TRAD_AREA_NM) AS TRAD_AREA_NM ]'  -- 상권명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'   -- 매출 : 총매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT       ]'   -- 매출 : 할인액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'   -- 매출 : 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'   -- 매출 : 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.SALE_DT)      AS SALE_DAY_CNT ]'   -- 매출 : 영업일수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) AS CUST_CNT ]'  -- 매출 : 객수
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)), 0, 0, SUM(SJ.GRD_AMT) / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)))    AS CUST_AMT ]'  -- 매출 : 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))                AS SALE_AMT_AVG ]'  -- 평균매출 : 총매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))     AS DC_AMT_AVG   ]'  -- 평균매출 : 할인액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)  / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))                AS GRD_AMT_AVG  ]'  -- 평균매출 : 순출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)/ (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT))     AS NET_AMT_AVG  ]'  -- 평균매출 : 순출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) / (COUNT(DISTINCT SJ.STOR_CD) * COUNT(DISTINCT SJ.SALE_DT)) AS CUST_CNT_AVG ]'  -- 평균매출 : 평균객수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.SALE_AMT             ELSE 0 END) AS DAY_SALE_AMT   ]'  -- 주중 : 총출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.DC_AMT + SJ.ENR_AMT  ELSE 0 END) AS DAY_DC_AMT     ]'  -- 주중 : 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT              ELSE 0 END) AS DAY_GRD_AMT    ]'  -- 주중 : 순출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT - SJ.VAT_AMT ELSE 0 END) AS DAY_NET_AMT    ]'  -- 주중 : 순출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)    AS DAY_CUST_CNT ]'  -- 매출 : 주중 객수
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END), 0, 0,  ]'
        ||CHR(13)||CHR(10)||Q'[           SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN GRD_AMT  ELSE 0 END)  / ]'
        ||CHR(13)||CHR(10)||Q'[           SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)) AS DAY_CUST_AMT ]'  -- 매출 : 주중 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1            ELSE 0 END)  AS DAY_CNT      ]'      -- 주중 : 영업일수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN SJ.SALE_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END),0 ,1 ,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_SALE_AVG ]'  -- 주중 : 평균총매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END),0 ,1 ,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_GRD_AVG  ]'  -- 주중 : 평균순매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('2', '3', '4', '5', '6') THEN SJ.GRD_AMT - SJ.VAT_AMT  ELSE 0 END)     ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END), 0, 1,             ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('2', '3', '4', '5', '6') THEN 1 ELSE 0 END))   AS DAY_NET_AVG  ]'  -- 주중 : 평균순매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.SALE_AMT              ELSE 0 END)     AS WEEK_SALE_AMT]'  -- 주말 : 총매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.DC_AMT + SJ.ENR_AMT   ELSE 0 END)     AS WEEK_DC_AMT  ]'  -- 주말 : 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT               ELSE 0 END)     AS WEEK_GRD_AMT ]'  -- 주말 : 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT - SJ.VAT_AMT  ELSE 0 END)     AS WEEK_NET_AMT ]'  -- 주말 : 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END)   AS WEEK_CUST_CNT    ]'  -- 주말 객수
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END), 0, 0, ]'
        ||CHR(13)||CHR(10)||Q'[         SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT ELSE 0 END) / ]'
        ||CHR(13)||CHR(10)||Q'[         SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT) ELSE 0 END))  AS WEEK_CUST_AMT    ]'  -- 주말 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1           ELSE 0 END)  AS WEEK_CNT     ]'  -- 주말 : 영업일수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.SALE_AMT ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END), 0, 1,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END)) AS WEEK_SALE_AVG]'  -- 주말 : 평균매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SJ.GRD_AMT  ELSE 0 END)                  ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('1', '7') THEN 1 ELSE 0 END),0 ,1 ,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN  ('1', '7') THEN 1 ELSE 0 END)) AS WEEK_GRD_AVG ]'  -- 주말 : 평균매출액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN  SJ.GRD_AMT - SJ.VAT_AMT ELSE 0 END)     ]'
        ||CHR(13)||CHR(10)||Q'[         / DECODE(SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1  ELSE 0 END),0 ,1 ,           ]'
        ||CHR(13)||CHR(10)||Q'[                  SUM(CASE WHEN TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN 1 ELSE 0 END))  AS WEEK_NET_AVG ]'  -- 주말 : 평균매출액
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)        AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT)          AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ENR_AMT)         AS ENR_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)         AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)         AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT)       AS ETC_M_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_F_CNT)       AS ETC_F_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)        AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.RTN_BILL_CNT)    AS RTN_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT, SJ.BRAND_CD, SJ.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         )   SJ          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV
                       , PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
END PKG_SALE4450;

/
