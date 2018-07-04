CREATE OR REPLACE PACKAGE       PKG_MEAN1090 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MEAN1080
    --  Description      : 전체회원 현황
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
    PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회시작일자
    PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회종료일자
    PSV_CFR_DATE    IN  VARCHAR2 ,                -- 비교시작일자
    PSV_CTO_DATE    IN  VARCHAR2 ,                -- 비교종료일자
    PSV_CUST_STAT   IN  VARCHAR2 ,                -- 회원상태
    PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );
        
END PKG_MEAN1090;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEAN1090 AS

    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회시작일자
    PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회종료일자
    PSV_CFR_DATE    IN  VARCHAR2 ,                -- 비교시작일자
    PSV_CTO_DATE    IN  VARCHAR2 ,                -- 비교종료일자
    PSV_CUST_STAT   IN  VARCHAR2 ,                -- 회원상태
    PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
    NAME:       PKG_MEAN1090      회원통계정보-전체회원분석
    PURPOSE:

    REVISIONS:
    VER        DATE        AUTHOR           DESCRIPTION
    ---------  ----------  ---------------  ------------------------------------
    1.0        2014-07-11         1. CREATED THIS PROCEDURE.

    NOTES:

      OBJECT NAME:     PKG_MEAN1090
      SYSDATE:
      USERNAME:
      TABLE NAME:
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
        --    dbms_output.enable( 1000000 ) ;
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
           ||  ls_sql_store; -- S_STORE
         --||  ', '
         --||  ls_sql_item  -- S_ITEM
         --;

        -- 조회기간 처리---------------------------------------------------------------
        --ls_sql_date := ' DL.APPR_DT ' || ls_date1;
        --IF ls_ex_date1 IS NOT NULL THEN
        --   ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
        --END IF;
        ------------------------------------------------------------------------------
        ls_sql_main :=      Q'[ SELECT  CU.CUST_ID                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(CU.CUST_NM) AS CUST_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CU.LVL_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.LVL_NM                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CU.CUST_STAT                            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CU.JOIN_DT                              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUB.DIFF > 0 THEN TO_CHAR(SUB.DIFF) ELSE '-' END AS JOIN_DAYS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.BILL_CNT        AS  BILL_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.BILL_RANK       AS  BILL_RANK       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.BILL_CNT        AS  C_BILL_CNT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.BILL_RANK       AS  C_BILL_RANK     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.SALE_QTY        AS  SALE_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.GRD_AMT         AS  GRD_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.GRD_RANK        AS  GRD_RANK        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.SALE_QTY        AS  C_SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.GRD_AMT         AS  C_GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.GRD_RANK        AS  C_GRD_RANK      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_QTY          AS  MD_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_AMT          AS  MD_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_RANK         AS  MD_RANK         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_AVG_WEEK     AS  MD_AVG_WEEK     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_DAYS         AS  MD_DAYS         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.MD_AVG_QTY      AS  MD_AVG_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_QTY          AS  C_MD_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_AMT          AS  C_MD_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_RANK         AS  C_MD_RANK       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_AVG_WEEK     AS  C_MD_AVG_WEEK   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_DAYS         AS  C_MD_DAYS       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.MD_AVG_QTY      AS  C_MD_AVG_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.EP_QTY          AS  EP_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.EP_AMT          AS  EP_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUB.EP_RANK         AS  EP_RANK         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.EP_QTY          AS  C_EP_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.EP_AMT          AS  C_EP_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COP.EP_RANK         AS  C_EP_RANK       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  :PSV_GFR_DATE       AS  SCH_GFR_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  :PSV_GTO_DATE       AS  SCH_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  :PSV_CFR_DATE       AS  SCH_CFR_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  :PSV_CTO_DATE       AS  SCH_CTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    C_CUST CU                               ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CU.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CU.CUST_ID                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CU.DIFF                         ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CU.DIFF_RANGE                   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DSS.BILL_CNT                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DSS.BILL_CNT DESC NULLS LAST) AS BILL_RANK   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.SALE_QTY                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.GRD_AMT                     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.GRD_AMT DESC NULLS LAST)  AS GRD_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_QTY                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_AMT                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.MD_AMT DESC NULLS LAST)   AS MD_RANK     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CU.DIFF_RANGE <= 0 THEN 0                                 ]' 
        ||CHR(13)||CHR(10)||Q'[                      ELSE ROUND(DMS.MD_QTY / CU.DIFF_RANGE * CASE WHEN CU.DIFF_RANGE < 7 THEN CU.DIFF_RANGE ELSE 7 END, 2)]'
        ||CHR(13)||CHR(10)||Q'[                 END                                                  AS MD_AVG_WEEK ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_DAYS                     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DECODE(DMS.MD_DAYS, 0, 0, ROUND(DMS.MD_QTY / DMS.MD_DAYS, 2)) AS MD_AVG_QTY ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.EP_QTY                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.EP_AMT                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.EP_AMT DESC NULLS LAST)   AS  EP_RANK    ]'           
        ||CHR(13)||CHR(10)||Q'[         FROM   (                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  CU.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                       , CU.CUST_ID              ]'
        ||CHR(13)||CHR(10)||Q'[                       , TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(CU.JOIN_DT, 'YYYYMMDD') + 1  AS  DIFF ]'
        ||CHR(13)||CHR(10)||Q'[                       , CASE WHEN JOIN_DT < :PSV_GFR_DATE THEN TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD')  ]'
        ||CHR(13)||CHR(10)||Q'[                               ELSE TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(CU.JOIN_DT, 'YYYYMMDD')    ]'
        ||CHR(13)||CHR(10)||Q'[                         END + 1                                      AS  DIFF_RANGE ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CUST  CU              ]'
        ||CHR(13)||CHR(10)||Q'[                       , S_STORE ST              ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   CU.COMP_CD  = ST.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.BRAND_CD = ST.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.STOR_CD  = ST.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_CUST_STAT IS NULL OR CU.CUST_STAT = :PSV_CUST_STAT)    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_LVL_CD    IS NULL OR CU.LVL_CD    = :PSV_LVL_CD)       ]'
        ||CHR(13)||CHR(10)||Q'[                )  CU                            ]'
        ||CHR(13)||CHR(10)||Q'[              , (                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  DSS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                       , DSS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DSS.BILL_CNT - DSS.RTN_BILL_CNT) BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CUST_DSS DSS          ]'
        ||CHR(13)||CHR(10)||Q'[                       , S_STORE    STO          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   STO.COMP_CD  = DSS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     STO.BRAND_CD = DSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     STO.STOR_CD  = DSS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DSS.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DSS.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP  BY                       ]'
        ||CHR(13)||CHR(10)||Q'[                         DSS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  DSS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                )  DSS                           ]'
        ||CHR(13)||CHR(10)||Q'[              , (                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  DMS.COMP_CD             ]'             
        ||CHR(13)||CHR(10)||Q'[                       , DMS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.SALE_QTY)   AS SALE_QTY ]'   
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.GRD_AMT)    AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.MD_QTY)     AS MD_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(MD_AMT)         AS MD_AMT   ]'  
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN R_NUM = 1 THEN DMS.MD_DAYS ELSE 0 END) AS MD_DAYS ]'  
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.EP_QTY)    AS EP_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.EP_AMT)    AS EP_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                FROM    (                        ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  DMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                               , DMS.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[                               , SALE_QTY  AS SALE_QTY   ]'   
        ||CHR(13)||CHR(10)||Q'[                               , GRD_AMT   AS GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN SALE_QTY ELSE 0 END AS MD_QTY   ]'  
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN GRD_AMT  ELSE 0 END AS MD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN 1        ELSE 0 END AS MD_DAYS  ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN SALE_QTY ELSE 0 END AS EP_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN GRD_AMT  ELSE 0 END AS EP_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                               , ROW_NUMBER() OVER(PARTITION BY DMS.COMP_CD, DMS.CUST_ID, DMS.SALE_DT ORDER BY SALE_DT) R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                          FROM   C_CUST_DMS DMS  ]'
        ||CHR(13)||CHR(10)||Q'[                               , S_STORE    STO  ]'
        ||CHR(13)||CHR(10)||Q'[                               , ITEM       IT   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  DMS.COMP_CD  = STO.COMP_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.BRAND_CD = STO.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.STOR_CD  = STO.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.COMP_CD  = IT.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.ITEM_CD  = IT.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                         ) DMS                   ]'
        ||CHR(13)||CHR(10)||Q'[                  GROUP BY                       ]'
        ||CHR(13)||CHR(10)||Q'[                         DMS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                       , DMS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                 )  DMS                          ]'
        ||CHR(13)||CHR(10)||Q'[           WHERE CU.COMP_CD  = DSS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   CU.CUST_ID  = DSS.CUST_ID       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   CU.COMP_CD  = DMS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[           AND   CU.CUST_ID  = DMS.CUST_ID       ]'
        ||CHR(13)||CHR(10)||Q'[        )  SUB                                   ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CU.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CU.CUST_ID                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DSS.BILL_CNT                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DSS.BILL_CNT DESC NULLS LAST) AS BILL_RANK   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.SALE_QTY                    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.GRD_AMT                     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.GRD_AMT DESC NULLS LAST)  AS GRD_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_QTY                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_AMT                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.MD_AMT DESC NULLS LAST)   AS  MD_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CASE WHEN CU.DIFF_RANGE <= 0 THEN 0                                 ]' 
        ||CHR(13)||CHR(10)||Q'[                      ELSE ROUND(DMS.MD_QTY / CU.DIFF_RANGE * CASE WHEN CU.DIFF_RANGE < 7 THEN CU.DIFF_RANGE ELSE 7 END, 2)]'
        ||CHR(13)||CHR(10)||Q'[                 END                                                  AS  MD_AVG_WEEK]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.MD_DAYS                     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DECODE(DMS.MD_DAYS, 0, 0, ROUND(DMS.MD_QTY / DMS.MD_DAYS, 2)) AS MD_AVG_QTY]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.EP_QTY                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  DMS.EP_AMT                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  RANK () OVER (ORDER BY DMS.EP_AMT DESC NULLS LAST)   AS EP_RANK     ]'           
        ||CHR(13)||CHR(10)||Q'[         FROM   (                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  CU.COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CU.CUST_ID              ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  TO_DATE(:PSV_CTO_DATE, 'YYYYMMDD') - TO_DATE(CU.JOIN_DT, 'YYYYMMDD') + 1 AS DIFF    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CASE WHEN JOIN_DT < :PSV_CFR_DATE THEN TO_DATE(:PSV_CTO_DATE, 'YYYYMMDD') - TO_DATE(:PSV_CFR_DATE, 'YYYYMMDD')]'
        ||CHR(13)||CHR(10)||Q'[                              ELSE TO_DATE(:PSV_CTO_DATE, 'YYYYMMDD') - TO_DATE(CU.JOIN_DT, 'YYYYMMDD')      ]'
        ||CHR(13)||CHR(10)||Q'[                         END + 1                                                    AS  DIFF_RANGE           ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CUST  CU              ]'
        ||CHR(13)||CHR(10)||Q'[                       , S_STORE ST              ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   CU.COMP_CD  = ST.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.BRAND_CD = ST.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.STOR_CD  = ST.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     CU.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_CUST_STAT IS NULL OR CU.CUST_STAT = :PSV_CUST_STAT)    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_LVL_CD    IS NULL OR CU.LVL_CD    = :PSV_LVL_CD   )    ]'
        ||CHR(13)||CHR(10)||Q'[                )  CU                            ]' 
        ||CHR(13)||CHR(10)||Q'[               ,(                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  DSS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                       , DSS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DSS.BILL_CNT - DSS.RTN_BILL_CNT) BILL_CNT]' 
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CUST_DSS  DSS         ]'
        ||CHR(13)||CHR(10)||Q'[                       , S_STORE     STO         ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   STO.BRAND_CD = DSS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     STO.STOR_CD  = DSS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DSS.COMP_CD   = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                 AND     DSS.SALE_DT BETWEEN :PSV_CFR_DATE AND :PSV_CTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP  BY                       ]'
        ||CHR(13)||CHR(10)||Q'[                         DSS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                       , DSS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                )  DSS                           ]'
        ||CHR(13)||CHR(10)||Q'[               ,(                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  DMS.COMP_CD             ]'             
        ||CHR(13)||CHR(10)||Q'[                       , DMS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.SALE_QTY)   AS SALE_QTY ]'   
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.GRD_AMT)    AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.MD_QTY)     AS MD_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(MD_AMT)         AS MD_AMT   ]'  
        ||CHR(13)||CHR(10)||Q'[                       , SUM(CASE WHEN R_NUM = 1 THEN DMS.MD_DAYS ELSE 0 END) AS MD_DAYS ]'  
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.EP_QTY)    AS EP_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DMS.EP_AMT)    AS EP_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                FROM    (                        ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  DMS.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                               , DMS.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[                               , SALE_QTY  AS SALE_QTY   ]'   
        ||CHR(13)||CHR(10)||Q'[                               , GRD_AMT   AS GRD_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN SALE_QTY ELSE 0 END AS MD_QTY   ]'  
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN GRD_AMT  ELSE 0 END AS MD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN 1        ELSE 0 END AS MD_DAYS  ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN SALE_QTY ELSE 0 END AS EP_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                               , CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN GRD_AMT  ELSE 0 END AS EP_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                               , ROW_NUMBER() OVER(PARTITION BY DMS.COMP_CD, DMS.CUST_ID, DMS.SALE_DT ORDER BY SALE_DT) R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                          FROM   C_CUST_DMS DMS  ]'
        ||CHR(13)||CHR(10)||Q'[                               , S_STORE    STO  ]'
        ||CHR(13)||CHR(10)||Q'[                               , ITEM       IT   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  DMS.COMP_CD  = STO.COMP_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.BRAND_CD = STO.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.STOR_CD  = STO.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.COMP_CD  = IT.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.ITEM_CD  = IT.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                          AND    DMS.SALE_DT BETWEEN :PSV_CFR_DATE AND :PSV_CTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                         ) DMS                   ]'
        ||CHR(13)||CHR(10)||Q'[                  GROUP BY                       ]'
        ||CHR(13)||CHR(10)||Q'[                         DMS.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                       , DMS.CUST_ID             ]'
        ||CHR(13)||CHR(10)||Q'[                )  DMS                           ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CU.COMP_CD  = DSS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CU.CUST_ID  = DSS.CUST_ID       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CU.COMP_CD  = DMS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CU.CUST_ID  = DMS.CUST_ID       ]'
        ||CHR(13)||CHR(10)||Q'[        )  COP                                   ]'
        ||CHR(13)||CHR(10)||Q'[     ,  (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CL.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CL.LVL_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  NVL(L.LANG_NM, CL.LVL_NM) AS LVL_NM]'
        ||CHR(13)||CHR(10)||Q'[         FROM    C_CUST_LVL  CL                  ]'
        ||CHR(13)||CHR(10)||Q'[              , (                                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  PK_COL                  ]'
        ||CHR(13)||CHR(10)||Q'[                       , LANG_NM                 ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    LANG_TABLE              ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   TABLE_NM    = 'C_CUST_LVL']'
        ||CHR(13)||CHR(10)||Q'[                 AND     COL_NM      = 'LVL_NM'  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     LANGUAGE_TP = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                 AND     USE_YN      = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                ) L                              ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE  L.PK_COL(+)     = LPAD(CL.LVL_CD, 10, ' ')]'
        ||CHR(13)||CHR(10)||Q'[         AND  CL.COMP_CD      = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND  CL.USE_YN       = 'Y'              ]'
        ||CHR(13)||CHR(10)||Q'[        )  CL                                    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   CU.COMP_CD  = SUB.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CU.CUST_ID  = SUB.CUST_ID               ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CU.COMP_CD  = COP.COMP_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CU.CUST_ID  = COP.CUST_ID(+)            ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CU.COMP_CD  = CL.COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[ AND     CU.LVL_CD   = CL.LVL_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                                       ]'
        ||CHR(13)||CHR(10)||Q'[         SUB.BILL_RANK                           ]'
        ||CHR(13)||CHR(10)||Q'[       , SUB.DIFF                                ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE, PSV_CFR_DATE, PSV_CTO_DATE,
                         PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD,
                         PSV_CUST_STAT, PSV_CUST_STAT, PSV_LVL_CD, PSV_LVL_CD,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_CTO_DATE, PSV_CFR_DATE, PSV_CTO_DATE, PSV_CFR_DATE, PSV_CTO_DATE, PSV_COMP_CD,
                         PSV_CUST_STAT, PSV_CUST_STAT, PSV_LVL_CD, PSV_LVL_CD,
                         PSV_COMP_CD, PSV_CFR_DATE, PSV_CTO_DATE,
                         PSV_COMP_CD, PSV_CFR_DATE, PSV_CTO_DATE,
                         PSV_LANG_CD, PSV_COMP_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
    END ;

END PKG_MEAN1090;

/
