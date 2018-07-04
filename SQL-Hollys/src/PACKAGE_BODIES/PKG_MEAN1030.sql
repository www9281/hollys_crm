--------------------------------------------------------
--  DDL for Package Body PKG_MEAN1030
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEAN1030" AS

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
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
    NAME:       SP_MEAN1010L0      회원통계정보-연령대회원현황(전체)
    PURPOSE:

    REVISIONS:
    VER        DATE        AUTHOR           DESCRIPTION
    ---------  ----------  ---------------  ------------------------------------
    1.0        2014-07-11         1. CREATED THIS PROCEDURE.

    NOTES:

      OBJECT NAME:     SP_MEAN1020L0
      SYSDATE:         2014-07-11
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
        ls_sql_main :=      Q'[   SELECT  MSC.CUST_LVL                                  ]'
        ||chr(13)||chr(10)||Q'[         , MSC.LVL_NM                                    ]'
        ||chr(13)||chr(10)||Q'[         , MSC.TOT_CUST_CNT                              ]'
        ||chr(13)||chr(10)||Q'[         , MSS.CST_CUST_CNT                              ]'
        ||chr(13)||chr(10)||Q'[         , CASE WHEN MSC.TOT_CUST_CNT = 0 THEN 0         ]'
        ||chr(13)||chr(10)||Q'[                ELSE MSS.CST_CUST_CNT / MSC.TOT_CUST_CNT * 100                       ]'
        ||chr(13)||chr(10)||Q'[           END AS OPER_RATE                              ]'
        ||chr(13)||chr(10)||Q'[         , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0         ]'
        ||chr(13)||chr(10)||Q'[                ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[           END AS CST_BILL_AMT                           ]'
        ||chr(13)||chr(10)||Q'[         , MSS.CST_BILL_CNT                              ]'
        ||chr(13)||chr(10)||Q'[         , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0                       ]'
        ||chr(13)||chr(10)||Q'[                ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER())  ]'
        ||chr(13)||chr(10)||Q'[           END AS T_CST_BILL_AMT                         ]'
        ||chr(13)||chr(10)||Q'[         , MSS.CST_SALE_QTY                              ]'
        ||chr(13)||chr(10)||Q'[         , MSS.CST_GRD_AMT                               ]'
        ||chr(13)||chr(10)||Q'[   FROM   (                                              ]'
        ||chr(13)||chr(10)||Q'[           SELECT  MSC.COMP_CD                           ]'
        ||chr(13)||chr(10)||Q'[                 , MSC.CUST_LVL                          ]'
        ||chr(13)||chr(10)||Q'[                 , LVL.LVL_NM                            ]'
        ||chr(13)||chr(10)||Q'[                 , LVL.LVL_RANK                          ]'
        ||chr(13)||chr(10)||Q'[                 , SUM(MSC.CUST_CNT) AS TOT_CUST_CNT     ]' -- 레벨 진입 회원수
        ||chr(13)||chr(10)||Q'[           FROM    C_CUST_MSC MSC                        ]'
        ||chr(13)||chr(10)||Q'[                 , C_CUST_LVL LVL                        ]'
        ||chr(13)||chr(10)||Q'[                 , S_STORE    STO                        ]'
        ||chr(13)||chr(10)||Q'[           WHERE   STO.COMP_CD  = MSC.COMP_CD            ]'
        ||chr(13)||chr(10)||Q'[           AND     STO.BRAND_CD = MSC.BRAND_CD           ]'
        ||chr(13)||chr(10)||Q'[           AND     STO.STOR_CD  = MSC.STOR_CD            ]'
        ||chr(13)||chr(10)||Q'[           AND     MSC.COMP_CD  = LVL.COMP_CD            ]'
        ||chr(13)||chr(10)||Q'[           AND     MSC.CUST_LVL = LVL.LVL_CD             ]'
        ||chr(13)||chr(10)||Q'[           AND     MSC.COMP_CD  = :PSV_COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[           AND     MSC.SALE_YM  = :PSV_END_YM            ]'
        ||chr(13)||chr(10)||Q'[           GROUP BY                                      ]'
        ||chr(13)||chr(10)||Q'[                   MSC.COMP_CD                           ]'
        ||chr(13)||chr(10)||Q'[                 , MSC.CUST_LVL                          ]'
        ||chr(13)||chr(10)||Q'[                 , LVL.LVL_NM                            ]'
        ||chr(13)||chr(10)||Q'[                 , LVL.LVL_RANK                          ]'
        ||chr(13)||chr(10)||Q'[          ) MSC                                          ]'
        ||chr(13)||chr(10)||Q'[         ,(                                              ]'
        ||chr(13)||chr(10)||Q'[           SELECT  MSS.COMP_CD                           ]'
        ||chr(13)||chr(10)||Q'[                 , MSS.CUST_LVL                          ]'
        ||chr(13)||chr(10)||Q'[                 , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[                 , SUM(MSS.BILL_CNT) AS CST_BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                 , SUM(MSS.SALE_QTY) AS CST_SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                 , SUM(MSS.GRD_AMT ) AS CST_GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[           FROM   (                                      ]'
        ||chr(13)||chr(10)||Q'[                   SELECT  MSS.COMP_CD                   ]'
        ||chr(13)||chr(10)||Q'[                         , MSS.CUST_LVL                  ]'
        ||chr(13)||chr(10)||Q'[                         , MSS.BILL_CNT                  ]'
        ||chr(13)||chr(10)||Q'[                         , MSS.SALE_QTY                  ]'
        ||chr(13)||chr(10)||Q'[                         , MSS.GRD_AMT                   ]'
        ||chr(13)||chr(10)||Q'[                         , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.CUST_ID ORDER BY MSS.SALE_YM DESC, MSS.CUST_LVL DESC) R_NUM ]'
        ||chr(13)||chr(10)||Q'[                   FROM    C_CUST_MSS MSS                ]'
        ||chr(13)||chr(10)||Q'[                         , S_STORE    STO                ]'
        ||chr(13)||chr(10)||Q'[                   WHERE   STO.COMP_CD  = MSS.COMP_CD    ]'
        ||chr(13)||chr(10)||Q'[                   AND     STO.BRAND_CD = MSS.BRAND_CD   ]'
        ||chr(13)||chr(10)||Q'[                   AND     STO.STOR_CD  = MSS.STOR_CD    ]'
        ||chr(13)||chr(10)||Q'[                   AND     MSS.COMP_CD  = :PSV_COMP_CD   ]'
        ||chr(13)||chr(10)||Q'[                   AND     MSS.SALE_YM >= :PSV_STR_YM    ]'
        ||chr(13)||chr(10)||Q'[                   AND     MSS.SALE_YM <= :PSV_END_YM    ]'
        ||chr(13)||chr(10)||Q'[                  ) MSS                                  ]'
        ||chr(13)||chr(10)||Q'[           GROUP BY                                      ]'
        ||chr(13)||chr(10)||Q'[                   MSS.COMP_CD                           ]'
        ||chr(13)||chr(10)||Q'[                 , MSS.CUST_LVL                          ]'
        ||chr(13)||chr(10)||Q'[          ) MSS                                          ]'
        ||chr(13)||chr(10)||Q'[   WHERE   MSC.COMP_CD  = MSS.COMP_CD (+)                ]'
        ||chr(13)||chr(10)||Q'[   AND     MSC.CUST_LVL = MSS.CUST_LVL(+)                ]'
        ||chr(13)||chr(10)||Q'[   ORDER BY MSC.LVL_RANK                                 ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_END_YM, 
                         PSV_COMP_CD, PSV_STR_YM, PSV_END_YM;

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

    PROCEDURE SP_TAB02
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
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    점포
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-31         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-03-31
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);

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
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main :=      Q'[ SELECT  MSS.STOR_CD                                         ]'
        ||chr(13)||chr(10)||Q'[       , STO.STOR_NM                                         ]'
        ||chr(13)||chr(10)||Q'[       , MSS.SALE_YM                                         ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CUST_LVL                                        ]'
        ||chr(13)||chr(10)||Q'[       , LVL.LVL_NM                                          ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_CUST_CNT                                    ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0               ]'
        ||chr(13)||chr(10)||Q'[              ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT        ]'
        ||chr(13)||chr(10)||Q'[         END AS CST_BILL_AMT                                 ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ]'
        ||chr(13)||chr(10)||Q'[              ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) ]'
        ||chr(13)||chr(10)||Q'[         END AS T_CST_BILL_AMT                               ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_SALE_QTY                                    ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_GRD_AMT                                     ]'
        ||chr(13)||chr(10)||Q'[ FROM    S_STORE    STO                                      ]'
        ||chr(13)||chr(10)||Q'[       , C_CUST_LVL LVL                                      ]'
        ||chr(13)||chr(10)||Q'[       ,(                                                    ]'
        ||chr(13)||chr(10)||Q'[         SELECT  MSS.COMP_CD                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.BRAND_CD                                ]'
        ||chr(13)||chr(10)||Q'[               , MSS.STOR_CD                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.SALE_YM                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.CUST_LVL                                ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.BILL_CNT) CST_BILL_CNT              ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.SALE_QTY) CST_SALE_QTY              ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MSS.GRD_AMT ) CST_GRD_AMT               ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                            ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  MSS.COMP_CD                         ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BRAND_CD                        ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.STOR_CD                         ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_YM                         ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_LVL                        ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BILL_CNT                        ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_QTY                        ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.GRD_AMT                         ]'
        ||chr(13)||chr(10)||Q'[                       , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.CUST_ID, MSS.CUST_LVL ORDER BY MSS.SALE_YM) R_NUM ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MSS MSS                      ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO                      ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = MSS.COMP_CD          ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = MSS.BRAND_CD         ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = MSS.STOR_CD          ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.COMP_CD  = :PSV_COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM >= :PSV_STR_YM          ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM <= :PSV_END_YM          ]'
        ||chr(13)||chr(10)||Q'[                ) MSS                                        ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                                            ]'
        ||chr(13)||chr(10)||Q'[                 MSS.COMP_CD                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.BRAND_CD                                ]'
        ||chr(13)||chr(10)||Q'[               , MSS.STOR_CD                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.SALE_YM                                 ]'
        ||chr(13)||chr(10)||Q'[               , MSS.CUST_LVL                                ]'
        ||chr(13)||chr(10)||Q'[        ) MSS                                                ]'
        ||chr(13)||chr(10)||Q'[ WHERE   MSS.COMP_CD  = STO.COMP_CD                          ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.BRAND_CD = STO.BRAND_CD                         ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.STOR_CD  = STO.STOR_CD                          ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.COMP_CD  = LVL.COMP_CD                          ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.CUST_LVL = LVL.LVL_CD                           ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY MSS.STOR_CD, MSS.SALE_YM, LVL.LVL_RANK             ]'
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_STR_YM, PSV_END_YM;

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
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   )
    IS
    /******************************************************************************
        NAME:       SP_TAB03   회원
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-31         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-03-31
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);

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
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main :=      Q'[ SELECT  TOT.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.STOR_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , STO.STOR_NM                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_LVL                    ]'
        ||chr(13)||chr(10)||Q'[       , LVL.LVL_NM                      ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_ID                     ]'
        ||chr(13)||chr(10)||Q'[       , decrypt(CUST.CUST_NM) AS CUST_NM]'
        ||chr(13)||chr(10)||Q'[       , TOT.ITEM_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , ITM.ITEM_NM                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_SALE_QTY                ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_SALE_AMT                ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_DC_AMT                  ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_GRD_AMT                 ]'
        ||chr(13)||chr(10)||Q'[ FROM    S_STORE STO                     ]'
        ||chr(13)||chr(10)||Q'[       , S_ITEM ITM                      ]'
        ||chr(13)||chr(10)||Q'[       , C_CUST_LVL LVL                  ]'
        ||chr(13)||chr(10)||Q'[       , C_CUST  CUST                    ]'
        ||chr(13)||chr(10)||Q'[       ,(                                ]'
        ||chr(13)||chr(10)||Q'[         SELECT  MMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[               , MMS.STOR_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_LVL            ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.SALE_QTY) AS CST_SALE_QTY]'
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.SALE_AMT) AS CST_SALE_AMT]'
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.DC_AMT)   AS CST_DC_AMT  ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.GRD_AMT)  AS CST_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                 ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  MS.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[                       , MS.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , MS.STOR_CD      ]'
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_YM      ]'
        ||chr(13)||chr(10)||Q'[                       , MS.CUST_LVL     ]'
        ||chr(13)||chr(10)||Q'[                       , MS.CUST_ID      ]'
        ||chr(13)||chr(10)||Q'[                       , MS.ITEM_CD      ]'
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , MS.DC_AMT + MS.ENR_AMT as DC_AMT]'
        ||chr(13)||chr(10)||Q'[                       , MS.GRD_AMT                      ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MMS MS                   ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    ST                   ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   ST.COMP_CD  = MS.COMP_CD        ]'
        ||chr(13)||chr(10)||Q'[                 AND     ST.BRAND_CD = MS.BRAND_CD       ]'
        ||chr(13)||chr(10)||Q'[                 AND     ST.STOR_CD  = MS.STOR_CD        ]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.COMP_CD  = :PSV_COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.SALE_YM >= :PSV_STR_YM       ]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.SALE_YM <= :PSV_END_YM       ]'
        ||chr(13)||chr(10)||Q'[                ) MMS                    ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                 MMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[               , MMS.STOR_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_ID             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_LVL            ]'
        ||chr(13)||chr(10)||Q'[        ) TOT                            ]'
        ||chr(13)||chr(10)||Q'[ WHERE   TOT.COMP_CD  = STO.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.BRAND_CD = STO.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.STOR_CD  = STO.STOR_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.COMP_CD  = LVL.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.CUST_LVL = LVL.LVL_CD       ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.CUST_ID   = CUST.CUST_ID    ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.ITEM_CD   = ITM.ITEM_CD     ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY                                ]'
        ||chr(13)||chr(10)||Q'[         TOT.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.STOR_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[       , LVL.LVL_RANK                    ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_ID                     ]'
        ||chr(13)||chr(10)||Q'[       , TOT.ITEM_CD                     ]'
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

         OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_STR_YM, PSV_END_YM;

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

END PKG_MEAN1030;

/
