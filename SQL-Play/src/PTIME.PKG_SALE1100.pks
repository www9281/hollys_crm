CREATE OR REPLACE PACKAGE      PKG_SALE1100 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE1100
    --  Description      : 일 실적 보고서 
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
    
END PKG_SALE1100;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1100 AS

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
        NAME:       SP_MAIN    일 실적 보고서
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
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SALE_DT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(COMP_CD, SALE_DT, :PSV_LANG_CD) AS WEEK_DAY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_BILL_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_CUST_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_GRD_AMT_ADD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  P_GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ACH_RATE        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  P_GRD_AMT_ADD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE  WHEN C_GRD_AMT_ADD IS NULL THEN NULL  ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN C_GRD_AMT_ADD =  0 AND P_GRD_AMT_ADD  = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN C_GRD_AMT_ADD =  0 AND P_GRD_AMT_ADD <> 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN C_GRD_AMT_ADD <> 0 AND P_GRD_AMT_ADD  = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[               ELSE ROUND(C_GRD_AMT_ADD / P_GRD_AMT_ADD * 100, 2)      ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS ACH_RATE_ADD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_BILL_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CUST_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  INCS_RATE       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_LAST_DT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_LAST_DT       ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_BILL_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(C_GRD_AMT, 0)) OVER (ORDER BY SALE_DT)  AS C_GRD_AMT_ADD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  P_GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN C_GRD_AMT IS NULL THEN NULL  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT  = 0 AND NVL(P_GRD_AMT, 0)  = 0 THEN 0  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT  = 0 AND NVL(P_GRD_AMT, 0) <> 0 THEN 0  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT <> 0 AND NVL(P_GRD_AMT, 0)  = 0 THEN 0  ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE ROUND(C_GRD_AMT / P_GRD_AMT * 100, 2)     ]'
        ||CHR(13)||CHR(10)||Q'[                     END         AS ACH_RATE ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(P_GRD_AMT, 0)) OVER(ORDER BY SALE_DT)   AS P_GRD_AMT_ADD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  L_BILL_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  L_CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  L_GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN C_GRD_AMT IS NULL THEN NULL  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT  = 0 AND L_GRD_AMT  = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT  = 0 AND L_GRD_AMT <> 0 THEN -100   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN C_GRD_AMT <> 0 AND L_GRD_AMT  = 0 THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE ROUND(C_GRD_AMT / L_GRD_AMT * 100, 2)         ]'
        ||CHR(13)||CHR(10)||Q'[                     END         AS INCS_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_LAST_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  L_LAST_DT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  S.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN S.SALE_DT <= S.STRD_DT THEN NVL(C.BILL_CNT, 0) ELSE C.BILL_CNT END)   AS C_BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN S.SALE_DT <= S.STRD_DT THEN NVL(C.CUST_CNT, 0) ELSE C.CUST_CNT END)   AS C_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN S.SALE_DT <= S.STRD_DT THEN NVL(C.GRD_AMT , 0) ELSE C.GRD_AMT  END)   AS C_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN SUBSTR(S.SALE_DT, 7, 2) = '01' THEN P.GOAL_D01    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '02' THEN P.GOAL_D02    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '03' THEN P.GOAL_D03    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '04' THEN P.GOAL_D04    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '05' THEN P.GOAL_D05    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '06' THEN P.GOAL_D06    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '07' THEN P.GOAL_D07    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '08' THEN P.GOAL_D08    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '09' THEN P.GOAL_D09    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '10' THEN P.GOAL_D10    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '11' THEN P.GOAL_D11    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '12' THEN P.GOAL_D12    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '13' THEN P.GOAL_D13    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '14' THEN P.GOAL_D14    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '15' THEN P.GOAL_D15    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '16' THEN P.GOAL_D16    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '17' THEN P.GOAL_D17    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '18' THEN P.GOAL_D18    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '19' THEN P.GOAL_D19    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '20' THEN P.GOAL_D20    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '21' THEN P.GOAL_D21    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '22' THEN P.GOAL_D22    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '23' THEN P.GOAL_D23    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '24' THEN P.GOAL_D24    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '25' THEN P.GOAL_D25    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '26' THEN P.GOAL_D26    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '27' THEN P.GOAL_D27    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '28' THEN P.GOAL_D28    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '29' THEN P.GOAL_D29    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '30' THEN P.GOAL_D30    ]'
        ||CHR(13)||CHR(10)||Q'[                                          WHEN SUBSTR(S.SALE_DT, 7, 2) = '31' THEN P.GOAL_D31    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ELSE 0 ]'
        ||CHR(13)||CHR(10)||Q'[                                 END)    AS P_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(NVL(L.BILL_CNT, 0))     AS L_BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(NVL(L.CUST_CNT, 0))     AS L_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(NVL(L.GRD_AMT , 0))     AS L_GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.C_LAST_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.L_LAST_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  S.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  C.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  C.STRD_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  MAX(C.C_LAST_DT)    AS C_LAST_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  MAX(C.L_LAST_DT)    AS L_LAST_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  :PSV_COMP_CD                        AS COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  :PSV_YM||TO_CHAR(ROWNUM, 'FM00')    AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  TO_CHAR(SYSDATE, 'YYYYMMDD')        AS STRD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  TO_CHAR(LAST_DAY(TO_DATE(:PSV_YM||'01', 'YYYYMMDD')), 'YYYYMMDD')   AS C_LAST_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  NULL                                AS L_LAST_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                                   FROM  TAB ]'
        ||CHR(13)||CHR(10)||Q'[                                                  WHERE  ROWNUM <= TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(:PSV_YM, 'YYYYMM')), 'DD'))    ]'
        ||CHR(13)||CHR(10)||Q'[                                                 UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  :PSV_COMP_CD                        AS COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  :PSV_YM||TO_CHAR(ROWNUM, 'FM00')    AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  TO_CHAR(SYSDATE, 'YYYYMMDD')        AS STRD_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  NULL                                AS C_LAST_DT]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(:PSV_YM||'01', 'YYYYMMDD'), -12)), 'YYYYMMDD')   AS L_LAST_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                                                   FROM  TAB ]'
        ||CHR(13)||CHR(10)||Q'[                                                  WHERE  ROWNUM <= TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12)), 'DD'))   ]'
        ||CHR(13)||CHR(10)||Q'[                                             )   C   ]'
        ||CHR(13)||CHR(10)||Q'[                                      GROUP  BY S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  C.SALE_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  C.STRD_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                                      ORDER  BY C.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   S   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.BILL_CNT  - SJ.RTN_BILL_CNT)     AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT   )     AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  SJ.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.SALE_DT  LIKE :PSV_YM||'%'   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.GIFT_DIV = '0'               ]'
        ||CHR(13)||CHR(10)||Q'[                                      GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   C   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  :PSV_YM||SUBSTR(SJ.SALE_DT, 7, 2)       AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.BILL_CNT  - SJ.RTN_BILL_CNT)     AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT   )     AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.SALE_DT LIKE TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')||'%' ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.GIFT_DIV = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[                                      GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUBSTR(SJ.SALE_DT, 7, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   L   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  SALE_GOAL_DAY   P           ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  P.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  P.GOAL_YM   = :PSV_YM       ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   P   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  S.COMP_CD   = C.COMP_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.BRAND_CD  = C.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.STOR_CD   = C.STOR_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.SALE_DT   = C.SALE_DT (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.COMP_CD   = L.COMP_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.BRAND_CD  = L.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.STOR_CD   = L.STOR_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.SALE_DT   = L.SALE_DT (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.COMP_CD   = P.COMP_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.BRAND_CD  = P.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  S.STOR_CD   = P.STOR_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.SALE_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.C_LAST_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S.L_LAST_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                     )   ]'
        ||CHR(13)||CHR(10)||Q'[         )               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DT      ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_LANG_CD, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_COMP_CD, PSV_YM;

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
    
END PKG_SALE1100;

/
