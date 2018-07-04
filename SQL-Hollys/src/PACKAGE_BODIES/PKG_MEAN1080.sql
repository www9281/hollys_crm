--------------------------------------------------------
--  DDL for Package Body PKG_MEAN1080
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEAN1080" AS

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
    PSV_CUST_STAT   IN  VARCHAR2 ,                -- 회원상태
    PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
    NAME:       PKG_MEAN1080      회원통계정보-전체회원분석
    PURPOSE:

    REVISIONS:
    VER        DATE        AUTHOR           DESCRIPTION
    ---------  ----------  ---------------  ------------------------------------
    1.0        2014-07-11         1. CREATED THIS PROCEDURE.

    NOTES:

      OBJECT NAME:     PKG_MEAN1080
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
        ||chr(13)||chr(10)||Q'[      ,  DECRYPT(CU.CUST_NM) AS CUST_NM          ]'
        ||chr(13)||chr(10)||Q'[      ,  CU.LVL_CD                               ]'
        ||chr(13)||chr(10)||Q'[      ,  CL.LVL_NM                               ]'
        ||chr(13)||chr(10)||Q'[      ,  CU.CUST_STAT                            ]'
        ||chr(13)||chr(10)||Q'[      ,  CU.JOIN_DT                              ]'
        ||chr(13)||chr(10)||Q'[      ,  DIFF                AS JOIN_DAYS        ]'
        ||chr(13)||chr(10)||Q'[      ,  BILL_CNT                                ]'
        ||chr(13)||chr(10)||Q'[      ,  RANK () OVER (ORDER BY BILL_CNT DESC NULLS LAST) BILL_RANK  ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(DIFF_RANGE, 0, 0, ROUND(BILL_CNT / DIFF_RANGE * CASE WHEN DIFF_RANGE < 7 THEN DIFF_RANGE ELSE 7 END, 2)) AS  BILL_AVG_WEEK ]'
        ||chr(13)||chr(10)||Q'[      ,  SALE_QTY                                ]'
        ||chr(13)||chr(10)||Q'[      ,  GRD_AMT                                 ]'
        ||chr(13)||chr(10)||Q'[      ,  RANK () OVER (ORDER BY GRD_AMT DESC NULLS LAST) GRD_RANK    ]'
        ||chr(13)||chr(10)||Q'[      ,  MD_QTY                                  ]'
        ||chr(13)||chr(10)||Q'[      ,  MD_AMT                                  ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(MD_QTY, 0, 0, ROUND(MD_AMT / MD_QTY, 2)) AS  MD_AVG_PRIC ]'
        ||chr(13)||chr(10)||Q'[      ,  RANK () OVER (ORDER BY MD_AMT DESC NULLS LAST)  AS  MD_RANK     ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(DIFF_RANGE, 0, 0, ROUND(MD_QTY / DIFF_RANGE * CASE WHEN DIFF_RANGE < 7 THEN DIFF_RANGE ELSE 7 END, 2))   AS  MD_AVG_WEEK ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(BILL_CNT, 0, 0, ROUND(MD_QTY / BILL_CNT, 2)) AS MD_BILL_QTY  ]'
        ||chr(13)||chr(10)||Q'[      ,  EP_QTY                                  ]'
        ||chr(13)||chr(10)||Q'[      ,  EP_AMT                                  ]'
        ||chr(13)||chr(10)||Q'[      ,  DECODE(EP_QTY, 0, 0, ROUND(EP_AMT / EP_QTY, 2))     AS EP_AVG_PRIC  ]'
        ||chr(13)||chr(10)||Q'[      ,  RANK () OVER (ORDER BY EP_AMT DESC NULLS LAST)      AS EP_RANK      ]'
        ||chr(13)||chr(10)||Q'[ FROM    C_CUST CU                               ]'
        ||chr(13)||chr(10)||Q'[      , (                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  CU.COMP_CD                      ]'
        ||chr(13)||chr(10)||Q'[              ,  CU.CUST_ID                      ]'
        ||chr(13)||chr(10)||Q'[              ,  CU.DIFF                         ]'
        ||chr(13)||chr(10)||Q'[              ,  CU.DIFF_RANGE                   ]'
        ||chr(13)||chr(10)||Q'[              ,  DSS.BILL_CNT                    ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.SALE_QTY                    ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.GRD_AMT                     ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.MD_QTY                      ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.MD_AMT                      ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.EP_QTY                      ]'
        ||chr(13)||chr(10)||Q'[              ,  DMS.EP_AMT                      ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  CST.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                      ,  CST.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                      ,  TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(JOIN_DT, 'YYYYMMDD') + 1  AS  DIFF ]'
        ||chr(13)||chr(10)||Q'[                      ,  CASE WHEN CST.JOIN_DT < :PSV_GFR_DATE THEN TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') ]'
        ||chr(13)||chr(10)||Q'[                              ELSE TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD') - TO_DATE(CST.JOIN_DT, 'YYYYMMDD') ]'
        ||chr(13)||chr(10)||Q'[                         END + 1 AS  DIFF_RANGE  ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST   CST            ]'
        ||chr(13)||chr(10)||Q'[                      ,  S_STORE  STO            ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   CST.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     CST.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     CST.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     CST.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_STAT IS NULL OR CST.CUST_STAT = :PSV_CUST_STAT)]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_LVL_CD    IS NULL OR CST.LVL_CD    = :PSV_LVL_CD)   ]'
        ||chr(13)||chr(10)||Q'[                )  CU                            ]'
        ||chr(13)||chr(10)||Q'[               ,(                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  DSS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                      ,  DSS.CUST_ID             ]'    
        ||chr(13)||chr(10)||Q'[                      ,  SUM(DSS.BILL_CNT - DSS.RTN_BILL_CNT) AS BILL_CNT        ]' 
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_DSS DSS          ]'
        ||chr(13)||chr(10)||Q'[                      ,  S_STORE    STO          ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = DSS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = DSS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = DSS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     DSS.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     DSS.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||chr(13)||chr(10)||Q'[                 GROUP  BY                       ]'
        ||chr(13)||chr(10)||Q'[                         DSS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , DSS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                )  DSS                           ]'
        ||chr(13)||chr(10)||Q'[               ,(                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  DMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                      ,  DMS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(SALE_QTY) AS  SALE_QTY  ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(GRD_AMT)  AS  GRD_AMT   ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN SALE_QTY ELSE 0 END) AS MD_QTY  ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(CASE WHEN IT.SERVICE_ITEM_YN = 'Y' THEN GRD_AMT  ELSE 0 END) AS MD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN SALE_QTY ELSE 0 END) AS EP_QTY  ]'
        ||chr(13)||chr(10)||Q'[                      ,  SUM(CASE WHEN IT.SERVICE_ITEM_YN = 'N' THEN GRD_AMT  ELSE 0 END) AS EP_AMT  ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_DMS DMS              ]'
        ||chr(13)||chr(10)||Q'[                      ,  S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                      ,  ITEM       IT               ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   DMS.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.COMP_CD  = IT.COMP_CD   ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.ITEM_CD  = IT.ITEM_CD   ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     DMS.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                         DMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , DMS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                )  DMS                           ]'
        ||chr(13)||chr(10)||Q'[         WHERE   CU.COMP_CD  = DSS.COMP_CD       ]'
        ||chr(13)||chr(10)||Q'[         AND     CU.CUST_ID  = DSS.CUST_ID       ]'
        ||chr(13)||chr(10)||Q'[         AND     CU.COMP_CD  = DMS.COMP_CD       ]'
        ||chr(13)||chr(10)||Q'[         AND     CU.CUST_ID  = DMS.CUST_ID       ]'
        ||chr(13)||chr(10)||Q'[        )    SUB                                 ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  CL.COMP_CD                      ]'
        ||chr(13)||chr(10)||Q'[              ,  CL.LVL_CD                       ]'
        ||chr(13)||chr(10)||Q'[              ,  NVL(L.LANG_NM, CL.LVL_NM) AS LVL_NM ]'
        ||chr(13)||chr(10)||Q'[         FROM    C_CUST_LVL  CL                  ]'
        ||chr(13)||chr(10)||Q'[              , (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  PK_COL                  ]'
        ||chr(13)||chr(10)||Q'[                      ,  LANG_NM                 ]'
        ||chr(13)||chr(10)||Q'[                 FROM    LANG_TABLE              ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   TABLE_NM    = 'C_CUST_LVL'  ]'
        ||chr(13)||chr(10)||Q'[                 AND     COL_NM      = 'LVL_NM'      ]'
        ||chr(13)||chr(10)||Q'[                 AND     LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     USE_YN      = 'Y'       ]'
        ||chr(13)||chr(10)||Q'[                ) L                              ]'
        ||chr(13)||chr(10)||Q'[         WHERE   L.PK_COL(+) = LPAD(CL.LVL_CD, 10, ' ')]'
        ||chr(13)||chr(10)||Q'[         AND     CL.COMP_CD  = :PSV_COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[         AND     CL.USE_YN   = 'Y'               ]'
        ||chr(13)||chr(10)||Q'[        )    CL                                  ]'
        ||chr(13)||chr(10)||Q'[ WHERE   CU.COMP_CD  = SUB.COMP_CD               ]'
        ||chr(13)||chr(10)||Q'[ AND     CU.CUST_ID  = SUB.CUST_ID               ]'
        ||chr(13)||chr(10)||Q'[ AND     CU.COMP_CD  = CL.COMP_CD                ]'
        ||chr(13)||chr(10)||Q'[ AND     CU.LVL_CD   = CL.LVL_CD                 ]'
        ||chr(13)||chr(10)||Q'[ AND     CU.COMP_CD  = :PSV_COMP_CD              ]'
        ||chr(13)||chr(10)||Q'[ ORDER  BY                                       ]'
        ||chr(13)||chr(10)||Q'[         SUB.GRD_AMT DESC NULLS LAST             ]'
        ||chr(13)||chr(10)||Q'[      ,  DIFF                                    ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD,
                         PSV_CUST_STAT, PSV_CUST_STAT, PSV_LVL_CD, PSV_LVL_CD,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD;

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

END PKG_MEAN1080;

/
