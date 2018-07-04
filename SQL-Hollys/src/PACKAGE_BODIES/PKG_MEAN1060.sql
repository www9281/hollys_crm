--------------------------------------------------------
--  DDL for Package Body PKG_MEAN1060
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEAN1060" AS

    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
   NAME:       PKG_MEAN1060.SP_TAB01      회원관리지표-고객창출관점-기간
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     PKG_MEAN1060.SP_TAB01
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
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        --    dbms_output.enable( 1000000 ) ;
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store; -- S_STORE
        /*       
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        */       

        -- 조회기간 처리---------------------------------------------------------------
        --ls_sql_date := ' DL.APPR_DT ' || ls_date1;
        --IF ls_ex_date1 IS NOT NULL THEN
        --   ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
        --END IF;
        ------------------------------------------------------------------------------
        ls_sql_main :=      Q'[ SELECT  /*+ NO_MERGE LEADING(CST) */            ]'
        ||chr(13)||chr(10)||Q'[         CST.SALE_YM                             ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_CUST_CNT                        ]'
        ||chr(13)||chr(10)||Q'[       , CST.TOT_CUST_CNT                        ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE     ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT  ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_GRD_AMT                         ]'
        ||chr(13)||chr(10)||Q'[       , JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT AS TOT_GRD_AMT        ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN JDS.TOT_GRD_AMT  = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / JDS.TOT_GRD_AMT  *100  END AS CST_SALE_RATE ]'
        ||chr(13)||chr(10)||Q'[ FROM   (                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  /*+ NO_MERGE */                 ]'
        ||chr(13)||chr(10)||Q'[                 MVL.COMP_CD                         ]'
        ||chr(13)||chr(10)||Q'[               , MVL.SALE_YM                         ]'
        ||chr(13)||chr(10)||Q'[               , COUNT(*) AS TOT_CUST_CNT        ]'
        ||chr(13)||chr(10)||Q'[         FROM    C_CUST_MLVL MVL                 ]'
        ||chr(13)||chr(10)||Q'[               ,(                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  CST.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                      ,  CST.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                      ,  CST.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST      CST         ]'
        ||chr(13)||chr(10)||Q'[                      ,  S_STORE     STO         ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   CST.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     CST.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     CST.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     SUBSTR(NVL(CST.LEAVE_DT,'99991231'), 1, 8) >= :PSV_STR_YM||'31'   ]'
        ||chr(13)||chr(10)||Q'[                ) CST                            ]'
        ||chr(13)||chr(10)||Q'[         WHERE   CST.COMP_CD  = MVL.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[         AND     CST.BRAND_CD = MVL.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[         AND     CST.CUST_ID  = MVL.CUST_ID      ]'
        ||chr(13)||chr(10)||Q'[         AND     MVL.SALE_YM >= :PSV_STR_YM      ]'
        ||chr(13)||chr(10)||Q'[         AND     MVL.SALE_YM <= :PSV_END_YM      ]'
        ||chr(13)||chr(10)||Q'[         AND    (:PSV_CUST_GRADE IS NULL OR MVL.CUST_LVL = :PSV_CUST_GRADE) ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                                ]'
        ||chr(13)||chr(10)||Q'[                 MVL.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , MVL.SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[        ) CST                                    ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  /*+ NO_MERGE LEADING(MSS) */    ]'
        ||chr(13)||chr(10)||Q'[                 MSS.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , MSS.SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.BILL_CNT) AS CST_BILL_CNT]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.SALE_QTY) AS CST_SALE_QTY]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.GRD_AMT)  AS CST_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  /*+ NO_MERGE */         ]'
        ||chr(13)||chr(10)||Q'[                         MSS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BILL_CNT            ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_QTY            ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.GRD_AMT             ]'
        ||chr(13)||chr(10)||Q'[                       , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MSS MSS          ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO          ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = MSS.COMP_CD    ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = MSS.BRAND_CD   ]'        
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = MSS.STOR_CD    ]' 
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM >= :PSV_STR_YM    ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM <= :PSV_END_YM    ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_GRADE IS NULL OR MSS.CUST_LVL = :PSV_CUST_GRADE)]'
        ||chr(13)||chr(10)||Q'[                ) MSS                            ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                                ]'
        ||chr(13)||chr(10)||Q'[                   MSS.COMP_CD                   ]'
        ||chr(13)||chr(10)||Q'[                 , MSS.SALE_YM                   ]'
        ||chr(13)||chr(10)||Q'[        ) MSS                                    ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  /*+ NO_MERGE LEADING(JDS) */    ]'
        ||chr(13)||chr(10)||Q'[                 JDS.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , SUBSTR(JDS.SALE_DT, 1, 6)  AS SALE_YM     ]'
        ||chr(13)||chr(10)||Q'[               , SUM(JDS.BILL_CNT)          AS TOT_BILL_CNT]'
        ||chr(13)||chr(10)||Q'[               , SUM(JDS.SALE_QTY)          AS TOT_SALE_QTY]'
        ||chr(13)||chr(10)||Q'[               , SUM(JDS.GRD_AMT)           AS TOT_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[         FROM    SALE_JDS JDS                    ]'
        ||chr(13)||chr(10)||Q'[               , S_STORE  STO                    ]'
        ||chr(13)||chr(10)||Q'[         WHERE   STO.COMP_CD  = JDS.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[         AND     STO.BRAND_CD = JDS.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[         AND     STO.STOR_CD  = JDS.STOR_CD      ]'
        ||chr(13)||chr(10)||Q'[         AND     JDS.SALE_DT >= :PSV_STR_YM||'01']'
        ||chr(13)||chr(10)||Q'[         AND     JDS.SALE_DT <= :PSV_END_YM||'31']'
        ||chr(13)||chr(10)||Q'[         GROUP BY                                ]'
        ||chr(13)||chr(10)||Q'[                 JDS.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , SUBSTR(JDS.SALE_DT, 1, 6 )      ]'
        ||chr(13)||chr(10)||Q'[          ) JDS                                  ]'
        ||chr(13)||chr(10)||Q'[   WHERE   CST.COMP_CD   = MSS.COMP_CD(+)        ]'
        ||chr(13)||chr(10)||Q'[   AND     CST.SALE_YM   = MSS.SALE_YM(+)        ]'
        ||chr(13)||chr(10)||Q'[   AND     CST.COMP_CD   = JDS.COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[   AND     CST.SALE_YM   = JDS.SALE_YM           ]'
        ||chr(13)||chr(10)||Q'[   ORDER BY CST.SALE_YM                          ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_STR_YM, PSV_STR_YM, PSV_END_YM, PSV_CUST_GRADE, PSV_CUST_GRADE,
                         PSV_STR_YM, PSV_END_YM, PSV_CUST_GRADE, PSV_CUST_GRADE,  
                         PSV_STR_YM, PSV_END_YM;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;

END PKG_MEAN1060;

/
