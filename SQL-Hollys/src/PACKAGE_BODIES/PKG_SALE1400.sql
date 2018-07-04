--------------------------------------------------------
--  DDL for Package Body PKG_SALE1400
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1400" AS

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
        PSV_COND_DIV    IN  VARCHAR2 ,                -- 조회구분[01:전년동요일. 02:전년동일자]
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     일일 실적 보고서
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-09-33         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-09-13
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    CMP_GFR_DATE    SALE_HD.SALE_DT%TYPE;
    CMP_GTO_DATE    SALE_HD.SALE_DT%TYPE;

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;

        IF PSV_COND_DIV = '01' THEN
            CMP_GFR_DATE := TO_CHAR(NEXT_DAY(ADD_MONTHS(TO_DATE(PSV_GFR_DATE, 'YYYYMMDD'), -12) -1 , TO_CHAR(TO_DATE(PSV_GFR_DATE, 'YYYYMMDD'), 'DY')), 'YYYYMMDD');
            CMP_GTO_DATE := TO_CHAR(NEXT_DAY(ADD_MONTHS(TO_DATE(PSV_GTO_DATE, 'YYYYMMDD'), -12) -1 , TO_CHAR(TO_DATE(PSV_GTO_DATE, 'YYYYMMDD'), 'DY')), 'YYYYMMDD');
        ELSE
            CMP_GFR_DATE := TO_CHAR(ADD_MONTHS(TO_DATE(PSV_GFR_DATE,'YYYYMMDD'), -12), 'YYYYMMDD');
            CMP_GTO_DATE := TO_CHAR(ADD_MONTHS(TO_DATE(PSV_GTO_DATE,'YYYYMMDD'), -12), 'YYYYMMDD');
        END IF;

        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[, ST AS (                                        ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  V.COMP_CD                           ]'
        ||CHR(13)||CHR(10)||Q'[           , V.BRAND_CD        , V.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[           , V.STOR_TP         , V.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           , V.STOR_TG         , V.STOR_TG_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           , V.REP_STOR_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           , V.REP_STOR_NM                       ]'
        ||CHR(13)||CHR(10)||Q'[           , T.STOR_CD         , T.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           , V.DEPT_CD         , V.DEPT_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           , V.TEAM_CD         , V.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           , V.SV_USER_ID      , V.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           , V.SIDO_CD         , V.SIDO_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           , V.REGION_CD       , V.REGION_NM     ]'
        ||CHR(13)||CHR(10)||Q'[           , V.TRAD_AREA       , V.TRAD_AREA_NM  ]'
        ||CHR(13)||CHR(10)||Q'[           , V.APP_DIV         , V.APP_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           , V.BUSI_NO                           ]'
        ||CHR(13)||CHR(10)||Q'[           , V.TABLE_NO        , V.SEAT          ]'
        ||CHR(13)||CHR(10)||Q'[           , V.OPEN_DT                           ]'
        ||CHR(13)||CHR(10)||Q'[           , V.CLOSE_DT, V.USE_YN                ]'
        ||CHR(13)||CHR(10)||Q'[           , ROW_NUMBER() OVER(PARTITION BY V.COMP_CD, V.BRAND_CD, V.REP_STOR_CD ORDER BY V.ORG_OPEN_DT DESC) R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[     FROM    STORE T                             ]'
        ||CHR(13)||CHR(10)||Q'[           ,(                                    ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                   , BRAND_CD     , BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                   , STOR_TP      , STOR_TP_NM]'
        ||CHR(13)||CHR(10)||Q'[                   , STOR_TG      , STOR_TG_NM]'
        ||CHR(13)||CHR(10)||Q'[                   , REP_STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                   , STOR_NM     AS REP_STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                   , STOR_CD      , STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                   , DEPT_CD      , DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                   , TEAM_CD      , TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                   , SV_USER_ID   , SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                   , SIDO_CD      , SIDO_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                   , REGION_CD    , REGION_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                   , TRAD_AREA    , TRAD_AREA_NM ]'
        ||CHR(13)||CHR(10)||Q'[                   , APP_DIV      , APP_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                   , BUSI_NO                     ]'
        ||CHR(13)||CHR(10)||Q'[                   , TABLE_NO     , SEAT         ]'
        ||CHR(13)||CHR(10)||Q'[                   , MIN(OPEN_DT) OVER(PARTITION BY COMP_CD, BRAND_CD, REP_STOR_CD) OPEN_DT ]'
        ||CHR(13)||CHR(10)||Q'[                   , OPEN_DT AS ORG_OPEN_DT  , NVL(CLOSE_DT, '99991231') AS CLOSE_DT, USE_YN]'
        ||CHR(13)||CHR(10)||Q'[                   , ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, REP_STOR_CD ORDER BY OPEN_DT DESC) R_NUM ]'
        ||CHR(13)||CHR(10)||Q'[             FROM    S_STORE                     ]'
        ||CHR(13)||CHR(10)||Q'[            ) V                                  ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE   V.COMP_CD     = T.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[     AND     V.BRAND_CD    = T.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[     AND     V.REP_STOR_CD = T.REP_STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[     AND     V.R_NUM       = 1                   ]'
        ||CHR(13)||CHR(10)||Q'[    )                                            ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_TP          ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.STOR_TP_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.TEAM_NM          ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.SV_USER_NM       ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.TRAD_AREA_NM     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.REP_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.REP_STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[       , ST.OPEN_DT          ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN SUBSTR(ST.OPEN_DT, 1, 4) = TO_CHAR(SYSDATE, 'YYYY') THEN FC_GET_WORDPACK(V1.COMP_CD, :PSV_LANG_CD,'NEW') ELSE FC_GET_WORDPACK(V1.COMP_CD, :PSV_LANG_CD,'OLD') END AS OLD_NEW_DIV]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V3.CUR_PLAN_AMT, 0) AS CUR_PLAN_AMT ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUR_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V3.CUR_PLAN_AMT, 0) = 0 THEN 0 ELSE V1.CUR_NET_AMT / NVL(V3.CUR_PLAN_AMT, 0) * 100 END AS ACOM_RATE ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.LST_NET_AMT, 0) AS LST_NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN SSS_CUR_NET_DIV            > 0 AND SSS_LST_NET_DIV            > 0 THEN V1.SSS_CUR_NET_AMT ELSE 0 END AS SSS_CUR_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.SSS_LST_NET_AMT, 0) > 0 AND NVL(V2.SSS_LST_NET_AMT, 0) > 0 THEN V2.SSS_LST_NET_AMT ELSE 0 END AS SSS_LST_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.SSS_LST_NET_AMT, 0) = 0 THEN 0 ELSE (V1.SSS_CUR_NET_AMT - NVL(V2.SSS_LST_NET_AMT, 0)) / NVL(V2.SSS_LST_NET_AMT, 0) * 100 END AS SSS_INCS_RATE ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.PSA_CUR_DAY_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.PSA_LST_DAY_AMT, 0) AS PSA_LST_DAY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUR_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.LST_CUST_CNT, 0) AS LST_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.LST_CUST_CNT, 0) = 0 THEN 0 ELSE (V1.CUR_CUST_CNT - NVL(V2.LST_CUST_CNT, 0)) / NVL(V2.LST_CUST_CNT, 0) * 100 END AS CUST_CNT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUST_DAY_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUR_CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.LST_CUST_AMT, 0) AS LST_CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.LST_CUST_AMT, 0) = 0 THEN 0 ELSE (V1.CUR_CUST_AMT - NVL(V2.LST_CUST_AMT, 0)) / NVL(V2.LST_CUST_AMT, 0) * 100 END AS CUST_AMT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUR_BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.LST_BILL_CNT, 0) AS LST_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.LST_BILL_CNT, 0) = 0 THEN 0 ELSE (V1.CUR_BILL_CNT - NVL(V2.LST_BILL_CNT, 0)) / NVL(V2.LST_BILL_CNT, 0) * 100 END AS BILL_CNT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.BILL_DAY_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[       , V1.CUR_BILL_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[       , NVL(V2.LST_BILL_AMT, 0) AS LST_BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[       , CASE WHEN NVL(V2.LST_BILL_AMT, 0) = 0 THEN 0 ELSE (V1.CUR_BILL_AMT - NVL(V2.LST_BILL_AMT, 0)) / NVL(V2.LST_BILL_AMT, 0) * 100 END AS BILL_AMT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ST                      ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[               , BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[               , REP_STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[               , CUR_CUST_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[               , CUR_BILL_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[               , CUR_NET_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CUR_DAY_CNT = 0 THEN 0 ELSE CUR_NET_AMT  / CUR_DAY_CNT  END AS PSA_CUR_DAY_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CUR_DAY_CNT = 0 THEN 0 ELSE CUR_CUST_CNT / CUR_DAY_CNT  END AS CUST_DAY_CNT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CUR_DAY_CNT = 0 THEN 0 ELSE CUR_NET_AMT  / CUR_CUST_CNT END AS CUR_CUST_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CUR_DAY_CNT = 0 THEN 0 ELSE CUR_BILL_CNT / CUR_DAY_CNT  END AS BILL_DAY_CNT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN CUR_BILL_CNT= 0 THEN 0 ELSE CUR_NET_AMT  / CUR_BILL_CNT END AS CUR_BILL_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , SSS_CUR_NET_DIV ]'
        ||CHR(13)||CHR(10)||Q'[               , SSS_CUR_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  J.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                       , J.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                       , S.REP_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.CUST_M_CNT + J.CUST_F_CNT)    AS CUR_CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.BILL_CNT)                     AS CUR_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.GRD_AMT - J.VAT_AMT)          AS CUR_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                       , COUNT(DISTINCT J.SALE_DT)           AS CUR_DAY_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN S.OPEN_DT <= :PSV_GFR_DATE AND S.CLOSE_DT >= :PSV_GTO_DATE THEN 1                     ELSE 0 END) AS SSS_CUR_NET_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN S.OPEN_DT <= :PSV_GFR_DATE AND S.CLOSE_DT >= :PSV_GTO_DATE THEN J.GRD_AMT - J.VAT_AMT ELSE 0 END) AS SSS_CUR_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_JDS    J   ]'
        ||CHR(13)||CHR(10)||Q'[                       , ST          S   ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   J.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                ]'
        ||CHR(13)||CHR(10)||Q'[                         J.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                       , J.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                       , S.REP_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                )                        ]'
        ||CHR(13)||CHR(10)||Q'[        ) V1                     ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[               , BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[               , REP_STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[               , LST_CUST_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[               , LST_BILL_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[               , LST_NET_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN LST_DAY_CNT = 0 THEN 0 ELSE LST_NET_AMT  / LST_DAY_CNT  END AS PSA_LST_DAY_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN LST_CUST_CNT= 0 THEN 0 ELSE LST_NET_AMT  / LST_CUST_CNT END AS LST_CUST_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , CASE WHEN LST_BILL_CNT= 0 THEN 0 ELSE LST_NET_AMT  / LST_BILL_CNT END AS LST_BILL_AMT]'
        ||CHR(13)||CHR(10)||Q'[               , SSS_LST_NET_DIV ]'
        ||CHR(13)||CHR(10)||Q'[               , SSS_LST_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  J.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                       , J.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                       , S.REP_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.CUST_M_CNT + J.CUST_F_CNT)    AS LST_CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.BILL_CNT)                     AS LST_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(J.GRD_AMT - J.VAT_AMT)          AS LST_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                       , COUNT(DISTINCT J.SALE_DT)           AS LST_DAY_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN S.OPEN_DT <= :CMP_GFR_DATE AND S.CLOSE_DT >= :CMP_GTO_DATE THEN 1                     ELSE 0 END) AS SSS_LST_NET_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN S.OPEN_DT <= :CMP_GFR_DATE AND S.CLOSE_DT >= :CMP_GTO_DATE THEN J.GRD_AMT - J.VAT_AMT ELSE 0 END) AS SSS_LST_NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_JDS    J   ]'
        ||CHR(13)||CHR(10)||Q'[                       , ST          S   ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   J.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     J.SALE_DT BETWEEN :CMP_GFR_DATE AND :CMP_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                ]'
        ||CHR(13)||CHR(10)||Q'[                         J.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                       , J.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                       , S.REP_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                )                        ]'
        ||CHR(13)||CHR(10)||Q'[        ) V2                             ]'
        ||CHR(13)||CHR(10)||Q'[       ,(                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  GL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[               , GL.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[               , ST.REP_STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(GL.GOAL_AMT) CUR_PLAN_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE       ST]'
        ||CHR(13)||CHR(10)||Q'[               , SALE_GOAL_YMD GL]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   GL.COMP_CD  = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.BRAND_CD = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.STOR_CD  = ST.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     GL.GOAL_YMD BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                        ]'
        ||CHR(13)||CHR(10)||Q'[                 GL.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[               , GL.BRAND_CD             ]'
        ||CHR(13)||CHR(10)||Q'[               , ST.REP_STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[        ) V3                             ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = ST.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = ST.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.REP_STOR_CD  = ST.REP_STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = V2.COMP_CD    (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = V2.BRAND_CD   (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.REP_STOR_CD  = V2.REP_STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = V3.COMP_CD    (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.BRAND_CD     = V3.BRAND_CD   (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.REP_STOR_CD  = V3.REP_STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ST.R_NUM        = 1                 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD, V1.BRAND_CD, V1.REP_STOR_CD]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_LANG_CD, PSV_LANG_CD
                       , PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       , CMP_GFR_DATE, CMP_GTO_DATE, CMP_GFR_DATE, CMP_GTO_DATE, PSV_COMP_CD, CMP_GFR_DATE, CMP_GTO_DATE
                       , PSV_COMP_CD , PSV_GFR_DATE, PSV_GTO_DATE;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

END PKG_SALE1400;

/
