--------------------------------------------------------
--  DDL for Package Body PKG_SALE1190
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1190" AS

    PROCEDURE SP_TAB01  /* 점포ABC분석 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_LFR_DATE    IN  VARCHAR2 ,                  -- 전월 시작일자
        PSV_LTO_DATE    IN  VARCHAR2 ,                  -- 전월 종료일자
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )   IS
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ST.COMP_CD, ST.BRAND_CD, ST.STOR_CD, ST.STOR_NM, ST.STOR_TP, ST.OPEN_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DAY_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AVG_DAY_SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_TOT_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  AMT_RANK            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RATIO               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STACK_RATIO         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN STACK_RATIO <= 70 THEN 'A'                       ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN STACK_RATIO  > 70 AND STACK_RATIO <= 90 THEN 'B' ]'
        ||CHR(13)||CHR(10)||Q'[               ELSE 'C' END)   AS  ABC_GROUP                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_SALE_DAY_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_AMT_RANK           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_RATIO              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  LAST_STACK_RATIO        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN LAST_STACK_RATIO <= 70 THEN 'A'                              ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN LAST_STACK_RATIO  > 70 AND LAST_STACK_RATIO <= 90 THEN 'B'   ]'
        ||CHR(13)||CHR(10)||Q'[               ELSE 'C' END)   AS  LAST_ABC_GROUP                                ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  JDS.COMP_CD, JDS.BRAND_CD, JDS.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.SALE_DAY_CNT                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.AVG_DAY_SALE_AMT                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.GRD_TOT_AMT                          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.AMT_RANK                             ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.RATIO                                ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS.STACK_RATIO                          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.SALE_DAY_CNT        AS  LAST_SALE_DAY_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.AVG_DAY_SALE_AMT    AS  LAST_AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.GRD_TOT_AMT         AS  LAST_GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.AMT_RANK            AS  LAST_AMT_RANK           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.RATIO               AS  LAST_RATIO              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDS_LAST.STACK_RATIO         AS  LAST_STACK_RATIO        ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (    ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD, BRAND_CD, STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SALE_DAY_CNT                 ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AVG_DAY_SALE_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  GRD_TOT_AMT                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AMT_RANK                     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(RATIO, 2)      AS  RATIO   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC),2)   AS  STACK_RATIO ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (    ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD, BRAND_CD, STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SALE_DAY_CNT                ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  AVG_DAY_SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT                 ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  AMT_RANK                    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / (SUM(GRD_TOT_AMT) OVER()) * 100   AS  RATIO   ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  (    ]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  COMP_CD, BRAND_CD, STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  COUNT(DISTINCT SALE_DT)  AS  SALE_DAY_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  ROUND(AVG(GRD_AMT), 0)   AS  AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  SUM(GRD_AMT)             AS  GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  RANK() OVER (ORDER BY SUM(GRD_AMT) DESC) AMT_RANK   ]'
        ||CHR(13)||CHR(10)||Q'[                                                   FROM  SALE_JDS    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  WHERE  COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  GROUP  BY COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ) JDS    ]'
        ||CHR(13)||CHR(10)||Q'[                              ) JDS    ]'
        ||CHR(13)||CHR(10)||Q'[                  )  JDS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (    ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD, BRAND_CD, STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SALE_DAY_CNT                 ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AVG_DAY_SALE_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  GRD_TOT_AMT                  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AMT_RANK                     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(RATIO, 2)      AS  RATIO   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC),2)   AS  STACK_RATIO ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD, BRAND_CD, STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SALE_DAY_CNT                ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  AVG_DAY_SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT                 ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  AMT_RANK                    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / (SUM(GRD_TOT_AMT) OVER()) * 100   AS  RATIO   ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  COMP_CD, BRAND_CD, STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  COUNT(DISTINCT SALE_DT)  AS  SALE_DAY_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  ROUND(AVG(GRD_AMT), 0)   AS  AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  SUM(GRD_AMT)             AS  GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  RANK() OVER (ORDER BY SUM(GRD_AMT) DESC) AMT_RANK   ]'
        ||CHR(13)||CHR(10)||Q'[                                                   FROM  SALE_JDS    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  WHERE  COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  SALE_DT  BETWEEN :PSV_LFR_DATE AND :PSV_LTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  GROUP  BY COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          )  JDS ]'
        ||CHR(13)||CHR(10)||Q'[                              )  JDS ]'
        ||CHR(13)||CHR(10)||Q'[                  )  JDS_LAST ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  JDS.COMP_CD  = JDS_LAST.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  JDS.BRAND_CD = JDS_LAST.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  JDS.STOR_CD  = JDS_LAST.STOR_CD(+)  ]'         
        ||CHR(13)||CHR(10)||Q'[      )  JDS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.COMP_CD   ]'       
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_CD  ]'      
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.OPEN_DT   ]'                         
        ||CHR(13)||CHR(10)||Q'[               FROM  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COMMON      C   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  S.COMP_CD       = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_TP       = C.CODE_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.CODE_TP       = '00565'   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.VAL_C1        = 'S'       ]'
        ||CHR(13)||CHR(10)||Q'[         )  ST   ]'        
        ||CHR(13)||CHR(10)||Q'[  WHERE  ST.COMP_CD   = JDS.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ST.BRAND_CD  = JDS.BRAND_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ST.STOR_CD   = JDS.STOR_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY AMT_RANK  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD      ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_LFR_DATE, PSV_LTO_DATE;

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

    PROCEDURE SP_TAB02  /* 메뉴ABC분석 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_LFR_DATE    IN  VARCHAR2 ,                  -- 전월 시작일자
        PSV_LTO_DATE    IN  VARCHAR2 ,                  -- 전월 종료일자
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )   IS
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  I.COMP_CD, I.BRAND_CD, I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  I.SALE_START_DT]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.SALE_PRC     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.SALE_DAY_ITEM_CNT    AS SALE_DAY_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.SALE_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.GRD_TOT_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.AVG_DAY_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.RATIO           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.STACK_RATIO     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.AMT_RANK        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN STACK_RATIO <= 70 THEN 'A'                       ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN STACK_RATIO  > 70 AND STACK_RATIO <= 90 THEN 'B' ]'
        ||CHR(13)||CHR(10)||Q'[               ELSE 'C' END)   AS  ABC_GROUP                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_SALE_DAY_ITEM_CNT    AS LAST_SALE_DAY_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_SALE_QTY           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_RATIO              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_STACK_RATIO        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  JDM.LAST_AMT_RANK           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (CASE WHEN LAST_STACK_RATIO <= 70 THEN 'A'                              ]'
        ||CHR(13)||CHR(10)||Q'[               WHEN LAST_STACK_RATIO  > 70 AND LAST_STACK_RATIO <= 90 THEN 'B'   ]'
        ||CHR(13)||CHR(10)||Q'[               ELSE 'C' END)   AS  LAST_ABC_GROUP                                ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  JDM.COMP_CD, JDM.BRAND_CD, JDM.ITEM_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM.SALE_DAY_ITEM_CNT, JDM.SALE_QTY, JDM.GRD_TOT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM.AVG_DAY_SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM.RATIO       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM.STACK_RATIO ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM.AMT_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.SALE_DAY_ITEM_CNT      AS  LAST_SALE_DAY_ITEM_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.SALE_QTY               AS  LAST_SALE_QTY           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.GRD_TOT_AMT            AS  LAST_GRD_TOT_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.AVG_DAY_SALE_AMT       AS  LAST_AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.RATIO                  AS  LAST_RATIO              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.STACK_RATIO            AS  LAST_STACK_RATIO        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  JDM_LAST.AMT_RANK               AS  LAST_AMT_RANK           ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD, BRAND_CD, ITEM_CD, SALE_DAY_ITEM_CNT, SALE_QTY, GRD_TOT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(AVG_DAY_SALE_AMT, 0)                      AS  AVG_DAY_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(RATIO, 2)                                 AS  RATIO           ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC), 2) AS  STACK_RATIO     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AMT_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD, BRAND_CD, ITEM_CD, SALE_DAY_ITEM_CNT, SALE_QTY, GRD_TOT_AMT        ]' 
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / SALE_DAY_CNT                           AS  AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / (SUM(GRD_TOT_AMT) OVER ()) * 100       AS  RATIO              ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  RANK() OVER (ORDER BY GRD_TOT_AMT DESC)              AS  AMT_RANK           ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                               SELECT  DISTINCT JDM.COMP_CD, JDM.BRAND_CD, JDM.ITEM_CD   ]' 
        ||CHR(13)||CHR(10)||Q'[                                                    ,  SUM(SALE_QTY) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)  AS  SALE_QTY     ]'     
        ||CHR(13)||CHR(10)||Q'[                                                    ,  SUM(GRD_AMT) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)   AS  GRD_TOT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  COUNT(DISTINCT(SALE_DT)) OVER ()  AS  SALE_DAY_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  COUNT(DISTINCT(SALE_DT)) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)  AS  SALE_DAY_ITEM_CNT]'
        ||CHR(13)||CHR(10)||Q'[                                                 FROM  SALE_JDM  JDM ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  S_STORE   S   ]'
        ||CHR(13)||CHR(10)||Q'[                                                WHERE  JDM.COMP_CD    = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  JDM.BRAND_CD   = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  JDM.STOR_CD    = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'                                                     
        ||CHR(13)||CHR(10)||Q'[                                           )  JDM    ]'
        ||CHR(13)||CHR(10)||Q'[                                 )  JDM  ]'
        ||CHR(13)||CHR(10)||Q'[                     )  JDM  ]' 
        ||CHR(13)||CHR(10)||Q'[                   , (       ]'        
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD, BRAND_CD, ITEM_CD, SALE_DAY_ITEM_CNT, SALE_QTY, GRD_TOT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(AVG_DAY_SALE_AMT, 0)                      AS  AVG_DAY_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(RATIO, 2)                                 AS  RATIO           ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC), 2) AS  STACK_RATIO     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  AMT_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD, BRAND_CD, ITEM_CD, SALE_DAY_ITEM_CNT, SALE_QTY, GRD_TOT_AMT        ]' 
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / SALE_DAY_CNT                           AS  AVG_DAY_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  GRD_TOT_AMT / (SUM(GRD_TOT_AMT) OVER ()) * 100       AS  RATIO      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  RANK() OVER (ORDER BY GRD_TOT_AMT DESC)              AS  AMT_RANK   ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                               SELECT  DISTINCT JDM.COMP_CD, JDM.BRAND_CD, JDM.ITEM_CD   ]' 
        ||CHR(13)||CHR(10)||Q'[                                                    ,  SUM(SALE_QTY) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)    AS  SALE_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  SUM(GRD_AMT) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)     AS  GRD_TOT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  COUNT(DISTINCT(SALE_DT)) OVER ()  AS  SALE_DAY_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  COUNT(DISTINCT(SALE_DT)) OVER (PARTITION BY JDM.BRAND_CD, JDM.ITEM_CD)  AS  SALE_DAY_ITEM_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                                 FROM  SALE_JDM  JDM ]'
        ||CHR(13)||CHR(10)||Q'[                                                    ,  S_STORE   S   ]'
        ||CHR(13)||CHR(10)||Q'[                                                WHERE  JDM.COMP_CD    = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  JDM.BRAND_CD   = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  JDM.STOR_CD    = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  AND  SALE_DT BETWEEN :PSV_LFR_DATE AND :PSV_LTO_DATE    ]'                                                     
        ||CHR(13)||CHR(10)||Q'[                                           )  JDM    ]'
        ||CHR(13)||CHR(10)||Q'[                                 )  JDM  ]'
        ||CHR(13)||CHR(10)||Q'[                     )  JDM_LAST ]' 
        ||CHR(13)||CHR(10)||Q'[                 WHERE  JDM.COMP_CD  = JDM_LAST.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                   AND  JDM.BRAND_CD = JDM_LAST.BRAND_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                   AND  JDM.ITEM_CD  = JDM_LAST.ITEM_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[         )           JDM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  TS.COMP_CD, TS.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TS.TOUCH_CD     ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              FROM  TOUCH_STORE_UI   TS      ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  S_STORE          S       ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  TS.COMP_CD   = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[               AND  TS.BRAND_CD  = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  TS.STOR_CD   = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[               AND  TS.TOUCH_DIV = '1'       ]'
        ||CHR(13)||CHR(10)||Q'[               AND  TS.USE_YN    = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[             GROUP  BY TS.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TS.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TS.TOUCH_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         )           TC  ]'   
        ||CHR(13)||CHR(10)||Q'[  WHERE  JDM.COMP_CD   = I.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDM.ITEM_CD   = I.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDM.COMP_CD   = TC.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDM.BRAND_CD  = TC.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDM.ITEM_CD   = TC.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  JDM.GRD_TOT_AMT <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY JDM.AMT_RANK ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_CD       ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE, PSV_LFR_DATE, PSV_LTO_DATE;

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


    PROCEDURE SP_TAB03  /* 메뉴분석 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD  IN  VARCHAR2 ,                  -- 대분류코드
        PSV_M_CLASS_CD  IN  VARCHAR2 ,                  -- 중분류코드
        PSV_S_CLASS_CD  IN  VARCHAR2 ,                  -- 소분류코드
        PSV_D_CLASS_CD  IN  VARCHAR2 ,                  -- 세분류코드
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 점포코드
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )   IS

    ERR_HANDLER     EXCEPTION;
    LS_STOR_TP      STORE.STOR_TP%TYPE;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        IF PSV_STOR_CD IS NOT NULL THEN
            BEGIN
                SELECT  S.STOR_TP
                  INTO  LS_STOR_TP
                  FROM  STORE S
                 WHERE  S.COMP_CD  = PSV_COMP_CD
                   AND  S.BRAND_CD = PSV_BRAND_CD
                   AND  S.STOR_CD  = PSV_STOR_CD;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        LS_ERR_CD  := '4000002' ;
                        LS_ERR_MSG := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , LS_ERR_CD) ;
                        RAISE ERR_HANDLER ;

                    WHEN OTHERS THEN
                        LS_ERR_CD := '4999999' ;
                        LS_ERR_MSG := SQLERRM ;
                        RAISE ERR_HANDLER ;
            END;
        ELSE
            LS_STOR_TP := '10';
        END IF;

        OPEN PR_RESULT FOR
        SELECT  MG.*
             ,  CASE WHEN MG.COST_RATE_DIV = 'High' AND MG.MIX_DIV = 'High' THEN 'Marginal'
                     WHEN MG.COST_RATE_DIV = 'Low'  AND MG.MIX_DIV = 'High' THEN 'Winner' 
                     WHEN MG.COST_RATE_DIV = 'High' AND MG.MIX_DIV = 'Low'  THEN 'Loser'
                     WHEN MG.COST_RATE_DIV = 'Low'  AND MG.MIX_DIV = 'Low'  THEN 'Marginal'
                     ELSE '-'
                     END  AS MIL_MENU_STATS
             ,  CASE WHEN MG.COST_RATE_DIV = 'High' AND MG.MIX_DIV = 'High' THEN '가격 재조정'
                     WHEN MG.COST_RATE_DIV = 'Low'  AND MG.MIX_DIV = 'High' THEN '유지' 
                     WHEN MG.COST_RATE_DIV = 'High' AND MG.MIX_DIV = 'Low'  THEN '메뉴 교체'
                     WHEN MG.COST_RATE_DIV = 'Low'  AND MG.MIX_DIV = 'Low'  THEN '가격 재조정'
                     ELSE '-'
                     END  AS MIL_JUDGMENT
             ,  CASE WHEN MG.MG_DIV = 'High' AND MG.MIX70_DIV = 'High' THEN 'Star'
                     WHEN MG.MG_DIV = 'Low'  AND MG.MIX70_DIV = 'High' THEN 'Plowhorse' 
                     WHEN MG.MG_DIV = 'High' AND MG.MIX70_DIV = 'Low'  THEN 'Puzzle'
                     WHEN MG.MG_DIV = 'Low'  AND MG.MIX70_DIV = 'Low'  THEN 'Dog'
                     ELSE '-'
                     END  AS MENU_STATS
             ,  CASE WHEN MG.MG_DIV = 'High' AND MG.MIX70_DIV = 'High' THEN '유지'
                     WHEN MG.MG_DIV = 'Low'  AND MG.MIX70_DIV = 'High' THEN '가격 재조정' 
                     WHEN MG.MG_DIV = 'High' AND MG.MIX70_DIV = 'Low'  THEN '메뉴위치 조정'
                     WHEN MG.MG_DIV = 'Low'  AND MG.MIX70_DIV = 'Low'  THEN '메뉴 교체'
                     ELSE '-'
                     END  AS JUDGMENT
             ,  CASE WHEN MG.CMA_DIV = 'High' AND MG.MG_DIV = 'High' THEN 'Standard'
                     WHEN MG.CMA_DIV = 'Low'  AND MG.MG_DIV = 'High' THEN 'Prime' 
                     WHEN MG.CMA_DIV = 'High' AND MG.MG_DIV = 'Low'  THEN 'Problem'
                     WHEN MG.CMA_DIV = 'Low'  AND MG.MG_DIV = 'Low'  THEN 'Sleeper'
                     ELSE '-'
                     END  AS CMA_MENU_STATS
             ,  CASE WHEN MG.CMA_DIV = 'High' AND MG.MG_DIV = 'High' THEN '가격 재조정'
                     WHEN MG.CMA_DIV = 'Low'  AND MG.MG_DIV = 'High' THEN '유지' 
                     WHEN MG.CMA_DIV = 'High' AND MG.MG_DIV = 'Low'  THEN '메뉴 교체'
                     WHEN MG.CMA_DIV = 'Low'  AND MG.MG_DIV = 'Low'  THEN '메뉴위치 조정'
                     ELSE '-'
                     END  AS CMA_JUDGMENT
             ,  MG_DIV    AS CMA_MG_DIV
             ,  L_CLASS_CD, L_CLASS_NM
             ,  M_CLASS_CD, M_CLASS_NM
             ,  S_CLASS_CD, S_CLASS_NM
             ,  D_CLASS_CD, D_CLASS_NM
             ,  ITEM_NM        
             ,  RANK() OVER (ORDER BY COST_RATE)         AS  COST_RATE_RANK
             ,  RANK() OVER (ORDER BY DTR_MG DESC)       AS  DTR_MG_RANK
             ,  RANK() OVER (ORDER BY MENU_DTR_MG DESC)  AS  MENU_DTR_MG_RANK
          FROM  (             
                    SELECT  COMP_CD, BRAND_CD, STOR_CD, ITEM_CD, SALE_QTY, MENU_PROFIT, MENU_COST, MENU_COUNT, TOT_QTY
                         ,  PROFIT_COST, SALE_PRC, DTR_MG
                         ,  SUM(MENU_PROFIT) OVER ()                     AS SUM_MENU_PROFIT
                         ,  SUM(MENU_COST) OVER ()                       AS SUM_MENU_COST
                         ,  SUM(MENU_PROFIT - MENU_COST) OVER ()         AS SUM_MENU_DTR_MG
                         ,  ROUND(SUM(DTR_MG) OVER () / MENU_COUNT, 2)   AS AVG_DTR_MG
                         --Miller Analysis
                         ,  ROUND(COST_RATE, 2)                                                                   AS  COST_RATE
                         ,  ROUND(AVG_COST_RATE, 2)                                                               AS  AVG_COST_RATE
                         ,  CASE WHEN COST_RATE >= AVG_COST_RATE THEN 'High' ELSE 'Low' END                       AS  COST_RATE_DIV 
                         ,  ROUND(MENU_MIX, 2)                                                                    AS  MENU_MIX
                         ,  ROUND(SUM(MENU_MIX) OVER () / MENU_COUNT, 2)                                          AS  AVG_MENU_MIX
                         ,  CASE WHEN MENU_MIX  >= SUM(MENU_MIX) OVER () / MENU_COUNT THEN 'High' ELSE 'Low' END  AS  MIX_DIV
                         --Kasavana/Smith
                         ,                                                                                            MENU_DTR_MG
                         ,  ROUND(AVG_MENU_DTR_MG, 2)                                                             AS  AVG_MENU_DTR_MG
                         ,  CASE WHEN MENU_DTR_MG >= AVG_MENU_DTR_MG THEN 'High' ELSE 'Low' END                   AS  MG_DIV
                         ,  ROUND(MENU_MIX_70, 2)                                                                 AS  MENU_MIX_70 
                         ,  CASE WHEN MENU_MIX    >= MENU_MIX_70     THEN 'High' ELSE 'Low' END                   AS  MIX70_DIV
                         --Cost Margin Analysis
                         ,  ROUND(CMA_RATE, 2)                                                                    AS  CMA_RATE
                         ,  ROUND(AVG_CMA_RATE, 2)                                                                AS  AVG_CMA_RATE
                         ,  CASE WHEN CMA_RATE >= AVG_CMA_RATE THEN 'High' ELSE 'Low' END                         AS  CMA_DIV 
                      FROM  (
                                SELECT  SALE.COMP_CD, SALE.BRAND_CD, SALE.STOR_CD, SALE.ITEM_CD, SALE.SALE_QTY, SALE.MENU_PROFIT, SALE.MENU_COST
                                     ,  COUNT(SALE.ITEM_CD) OVER ()                      AS  MENU_COUNT
                                     ,  SUM(SALE.SALE_QTY) OVER ()                       AS  TOT_QTY 
                                     ,  COST                                             AS  PROFIT_COST
                                     ,  GRD_AMT                                          AS  SALE_PRC
                                     ,  GRD_AMT - COST                                   AS  DTR_MG
                                     ,  DECODE(GRD_AMT, 0, 0, COST / GRD_AMT * 100)                                                          AS  COST_RATE
                                     ,  SUM(DECODE(GRD_AMT, 0, 0, COST / GRD_AMT * 100)) OVER () / COUNT(SALE.ITEM_CD) OVER ()               AS  AVG_COST_RATE
                                     ,  SALE_QTY / SUM(SALE.SALE_QTY) OVER () * 100                                                          AS  MENU_MIX
                                     ,  MENU_PROFIT - MENU_COST                                                                              AS  MENU_DTR_MG
                                     ,  SUM(MENU_PROFIT - MENU_COST) OVER ()                                                                 AS  SUM_MENU_DTR_MG
                                     ,  SUM(MENU_PROFIT - MENU_COST) OVER () / COUNT(SALE.ITEM_CD) OVER ()                                   AS  AVG_MENU_DTR_MG
                                     ,  (1 / COUNT(SALE.ITEM_CD) OVER () * 70)                                                               AS  MENU_MIX_70
                                     ,  DECODE(MENU_PROFIT, 0, 0, MENU_COST / MENU_PROFIT * 100)                                             AS  CMA_RATE
                                     ,  SUM(DECODE(MENU_PROFIT, 0, 0, MENU_COST / MENU_PROFIT * 100)) OVER () / COUNT(SALE.ITEM_CD) OVER ()  AS  AVG_CMA_RATE
                                  FROM  (       
                                            SELECT  SALE.COMP_CD
                                                 ,  SALE.BRAND_CD
                                                 ,  SALE.STOR_CD
                                                 ,  SALE.ITEM_CD
                                                 ,  SUM(SALE.SALE_QTY) SALE_QTY
                                                 ,  DECODE(SUM(SALE.SALE_QTY), 0, 0, SUM(PRIC.COST * SALE.SALE_QTY) / SUM(SALE.SALE_QTY)) COST
                                                 ,  DECODE(SUM(SALE.SALE_QTY), 0, 0, SUM(SALE.GRD_AMT) / SUM(SALE.SALE_QTY)) GRD_AMT
                                                 ,  SUM(SALE.GRD_AMT) MENU_PROFIT
                                                 ,  SUM(PRIC.COST * SALE.SALE_QTY) MENU_COST
                                              FROM  ( 
                                                        SELECT  COMP_CD, BRAND_CD, STOR_CD, ITEM_CD, SALE_DT, SALE_QTY, GRD_AMT
                                                          FROM  SALE_JDM
                                                         WHERE  COMP_CD  = PSV_COMP_CD
                                                           AND  BRAND_CD = PSV_BRAND_CD
                                                           AND  SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                                           AND  STOR_CD  = PSV_STOR_CD
                                                    ) SALE
                                                 ,  (
                                                        SELECT  ICH.ITEM_CD, ICH.SALE_DT, NVL(RCP.COST, ICH.COST) COST
                                                          FROM  (
                                                                    SELECT  SALE.ITEM_CD, SALE.SALE_DT
                                                                         ,  PRIC.COST / DECODE(ORD_UNIT_QTY, 0, 1, ORD_UNIT_QTY) * DECODE(SALE_UNIT_QTY, 0 ,1, SALE_UNIT_QTY) AS COST
                                                                      FROM  (
                                                                                SELECT  I.ITEM_CD
                                                                                     ,  ICH.START_DT
                                                                                     ,  NVL(ICH.COST, 0) COST
                                                                                     ,  I.ORD_UNIT_QTY
                                                                                     ,  I.SALE_UNIT_QTY 
                                                                                  FROM  ITEM           I
                                                                                     ,  ITEM_CHAIN_HIS ICH
                                                                                 WHERE  I.COMP_CD    = ICH.COMP_CD(+)
                                                                                   AND  I.ITEM_CD    = ICH.ITEM_CD(+)
                                                                                   AND  I.COMP_CD    = PSV_COMP_CD
                                                                                   AND  I.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                                                                                   AND  ICH.BRAND_CD = PSV_BRAND_CD
                                                                                   AND  ICH.STOR_TP  = LS_STOR_TP
                                                                            ) PRIC     
                                                                         ,  ( 
                                                                                SELECT  SALE.ITEM_CD, SALE.SALE_DT
                                                                                     ,  MAX(PRIC.START_DT) AS  START_DT
                                                                                  FROM  (
                                                                                            SELECT  ITEM_CD, SALE_DT
                                                                                              FROM  SALE_JDM
                                                                                             WHERE  COMP_CD   = PSV_COMP_CD
                                                                                               AND  BRAND_CD  = PSV_BRAND_CD
                                                                                               AND  SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                                                                               AND  STOR_CD   = PSV_STOR_CD
                                                                                        ) SALE
                                                                                     ,  (   
                                                                                            SELECT  ITEM_CD, START_DT 
                                                                                              FROM  ITEM_CHAIN_HIS 
                                                                                             WHERE  COMP_CD  = PSV_COMP_CD
                                                                                               AND  BRAND_CD = PSV_BRAND_CD
                                                                                               AND  STOR_TP  = LS_STOR_TP
                                                                                        ) PRIC
                                                                                 WHERE  SALE.ITEM_CD  = PRIC.ITEM_CD(+)
                                                                                   AND  SALE.SALE_DT >= PRIC.START_DT(+)
                                                                                 GROUP  BY SALE.ITEM_CD
                                                                                     ,  SALE.SALE_DT
                                                                            )  SALE
                                                                     WHERE  PRIC.ITEM_CD  = SALE.ITEM_CD
                                                                       AND  PRIC.START_DT = SALE.START_DT
                                                                ) ICH
                                                             ,  ( 
                                                                    SELECT  SALE.SALE_DT
                                                                         ,  PRIC.R_ITEM_CD    AS ITEM_CD
                                                                         ,  SUM(PRIC.DO_COST) AS COST
                                                                      FROM  (
                                                                            SELECT  SALE_DT 
                                                                              FROM  SALE_JDS
                                                                             WHERE  COMP_CD   = PSV_COMP_CD
                                                                               AND  BRAND_CD  = PSV_BRAND_CD
                                                                               AND  STOR_CD   = PSV_STOR_CD
                                                                               AND  SALE_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE
                                                                             GROUP  BY COMP_CD
                                                                                 ,  BRAND_CD
                                                                                 ,  STOR_CD
                                                                                 ,  SALE_DT
                                                                            ) SALE
                                                                         ,  TABLE(FN_RCP_STD_0072(PSV_COMP_CD,
                                                                                                  PSV_BRAND_CD,
                                                                                                  SALE.SALE_DT)
                                                                            ) PRIC
                                                                     WHERE  PRIC.STOR_TP   = LS_STOR_TP
                                                                     GROUP  BY SALE.SALE_DT
                                                                         ,  PRIC.R_ITEM_CD
                                                                )  RCP
                                                         WHERE  ICH.ITEM_CD   = RCP.ITEM_CD(+)
                                                           AND  ICH.SALE_DT   = RCP.SALE_DT(+)
                                                     ) PRIC
                                             WHERE  SALE.ITEM_CD  = PRIC.ITEM_CD
                                               AND  SALE.SALE_DT  = PRIC.SALE_DT
                                             GROUP  BY SALE.COMP_CD, SALE.BRAND_CD, SALE.STOR_CD, SALE.ITEM_CD
                                        )  SALE
                                     ,  (
                                           SELECT  COMP_CD
                                                ,  BRAND_CD        
                                                ,  TOUCH_CD      ITEM_CD   
                                             FROM  TOUCH_STORE_UI
                                            WHERE  COMP_CD   = PSV_COMP_CD
                                              AND  BRAND_CD  = PSV_BRAND_CD
                                              AND  STOR_CD   = PSV_STOR_CD
                                              AND  TOUCH_DIV = '1'
                                              AND  USE_YN    = 'Y'
                                            GROUP  BY COMP_CD
                                                ,  BRAND_CD
                                                ,  TOUCH_CD
                                        )  TC
                                 WHERE  SALE.COMP_CD   = TC.COMP_CD
                                   AND  SALE.BRAND_CD  = TC.BRAND_CD
                                   AND  SALE.ITEM_CD   = TC.ITEM_CD
                                   AND  SALE.SALE_QTY  <> 0
                                ) DTR
                ) MG
             ,  (
                    SELECT  I.COMP_CD   
                         ,  PSV_BRAND_CD   AS  BRAND_CD
                         ,  I.ITEM_CD,   I.ITEM_NM
                         ,  L.L_CLASS_CD, L.L_CLASS_NM
                         ,  M.M_CLASS_CD, M.M_CLASS_NM
                         ,  S.S_CLASS_CD, S.S_CLASS_NM
                         ,  D.D_CLASS_CD, D.D_CLASS_NM
                      FROM  ITEM I   
                         ,  (
                               SELECT   L.COMP_CD
                                    ,   L.L_CLASS_CD
                                    ,   NVL(LL.L_CLASS_NM, L.L_CLASS_NM)  AS L_CLASS_NM
                                 FROM   ITEM_L_CLASS L
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS L_CLASS_CD
                                                ,   LANG_NM  AS L_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_L_CLASS'
                                              AND   COL_NM      = 'L_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) LL
                                WHERE   L.COMP_CD      = LL.COMP_CD(+)
                                  AND   L.ORG_CLASS_CD||L.L_CLASS_CD = LL.L_CLASS_CD(+)
                                  AND   L.COMP_CD      = PSV_COMP_CD
                                  AND   L.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   L.USE_YN       = 'Y'
                            ) L
                         ,  (
                               SELECT   M.COMP_CD
                                    ,   M.L_CLASS_CD
                                    ,   M.M_CLASS_CD
                                    ,   NVL(ML.M_CLASS_NM, M.M_CLASS_NM)  AS M_CLASS_NM
                                 FROM   ITEM_M_CLASS M
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS M_CLASS_CD
                                                ,   LANG_NM  AS M_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_M_CLASS'
                                              AND   COL_NM      = 'M_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) ML
                                WHERE   M.COMP_CD      = ML.COMP_CD(+)   
                                  AND   M.ORG_CLASS_CD||M.L_CLASS_CD||M.L_CLASS_CD = ML.M_CLASS_CD(+)
                                  AND   M.COMP_CD      = PSV_COMP_CD
                                  AND   M.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   M.USE_YN       = 'Y'
                            ) M
                         ,  (
                               SELECT   S.COMP_CD
                                    ,   S.L_CLASS_CD
                                    ,   S.M_CLASS_CD
                                    ,   S.S_CLASS_CD
                                    ,   NVL(SL.S_CLASS_NM, S.S_CLASS_NM)  AS S_CLASS_NM
                                 FROM   ITEM_S_CLASS S
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS S_CLASS_CD
                                                ,   LANG_NM  AS S_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_S_CLASS'
                                              AND   COL_NM      = 'S_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) SL
                                WHERE   S.COMP_CD      = SL.COMP_CD(+)
                                  AND   S.ORG_CLASS_CD||S.L_CLASS_CD||S.M_CLASS_CD||S.S_CLASS_CD = SL.S_CLASS_CD(+)
                                  AND   S.COMP_CD      = PSV_COMP_CD
                                  AND   S.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   S.USE_YN       = 'Y'
                            ) S
                         ,  (
                               SELECT   D.COMP_CD
                                    ,   D.L_CLASS_CD
                                    ,   D.M_CLASS_CD
                                    ,   D.S_CLASS_CD
                                    ,   D.D_CLASS_CD
                                    ,   NVL(SL.D_CLASS_NM, D.D_CLASS_NM)  AS D_CLASS_NM
                                 FROM   ITEM_D_CLASS D
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS D_CLASS_CD
                                                ,   LANG_NM  AS D_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_D_CLASS'
                                              AND   COL_NM      = 'D_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) SL
                                WHERE   D.COMP_CD      = SL.COMP_CD(+)
                                  AND   D.ORG_CLASS_CD||D.L_CLASS_CD||D.M_CLASS_CD||D.S_CLASS_CD||D.D_CLASS_CD = SL.D_CLASS_CD(+)
                                  AND   D.COMP_CD      = PSV_COMP_CD
                                  AND   D.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   D.USE_YN       = 'Y'
                            ) D
                     WHERE  I.COMP_CD    = L.COMP_CD(+)
                       AND  I.L_CLASS_CD = L.L_CLASS_CD(+)
                       AND  I.COMP_CD    = M.COMP_CD(+)
                       AND  I.L_CLASS_CD = M.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = M.M_CLASS_CD(+)
                       AND  I.COMP_CD    = S.COMP_CD(+)
                       AND  I.L_CLASS_CD = S.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = S.M_CLASS_CD(+)
                       AND  I.S_CLASS_CD = S.S_CLASS_CD(+)
                       AND  I.COMP_CD    = D.COMP_CD(+)
                       AND  I.L_CLASS_CD = D.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = D.M_CLASS_CD(+)
                       AND  I.S_CLASS_CD = D.S_CLASS_CD(+)
                       AND  I.D_CLASS_CD = D.D_CLASS_CD(+)
                       AND  I.COMP_CD    = PSV_COMP_CD
                       AND  I.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                )  IT
         WHERE  MG.COMP_CD   = IT.COMP_CD
           AND  MG.BRAND_CD  = IT.BRAND_CD
           AND  MG.ITEM_CD   = IT.ITEM_CD
           AND  (PSV_L_CLASS_CD IS NULL OR IT.L_CLASS_CD = PSV_L_CLASS_CD)
           AND  (PSV_M_CLASS_CD IS NULL OR IT.M_CLASS_CD = PSV_M_CLASS_CD)
           AND  (PSV_S_CLASS_CD IS NULL OR IT.S_CLASS_CD = PSV_S_CLASS_CD)
           AND  (PSV_D_CLASS_CD IS NULL OR IT.D_CLASS_CD = PSV_D_CLASS_CD)
         ORDER  BY MENU_DTR_MG DESC
             ,  L_CLASS_CD
             ,  M_CLASS_CD
             ,  S_CLASS_CD
             ,  D_CLASS_CD
             ,  MG.ITEM_CD;            
        dbms_output.put_line( 'SUCCESS' );

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


    PROCEDURE SP_TAB04  /* 자재ABC분석 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD  IN  VARCHAR2 ,                  -- 대분류코드
        PSV_M_CLASS_CD  IN  VARCHAR2 ,                  -- 중분류코드
        PSV_S_CLASS_CD  IN  VARCHAR2 ,                  -- 소분류코드
        PSV_D_CLASS_CD  IN  VARCHAR2 ,                  -- 세분류코드
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 점포코드
        PSV_VENDOR_CD   IN  VARCHAR2 ,                  -- 공급사코드
        PSV_LFR_DATE    IN  VARCHAR2 ,                  -- 전월 시작일자
        PSV_LTO_DATE    IN  VARCHAR2 ,                  -- 전월 종료일자
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )   IS
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        OPEN PR_RESULT FOR
        SELECT  IT.COMP_CD, IT.BRAND_CD, IT.ITEM_CD
             ,  IT.L_CLASS_NM
             ,  IT.M_CLASS_NM
             ,  IT.S_CLASS_NM
             ,  IT.D_CLASS_NM
             ,  IT.ITEM_NM 
             ,  IT.ORD_START_DT
             ,  DTV.ORD_COST
             ,  DTV.ORD_QTY
             ,  DTV.ORD_AMT 
             ,  DTV.ORD_VAT
             ,  DTV.RATIO
             ,  DTV.STACK_RATIO
             ,  DTV.AMT_RANK
             ,  (CASE WHEN STACK_RATIO <= 70 THEN 'A'
                      WHEN STACK_RATIO  > 70 AND STACK_RATIO <= 90 THEN 'B'
                      ELSE 'C' END)   AS  ABC_GROUP
             ,  DTV.LAST_ORD_COST
             ,  DTV.LAST_ORD_QTY
             ,  DTV.LAST_ORD_AMT 
             ,  DTV.LAST_ORD_VAT
             ,  DTV.LAST_RATIO
             ,  DTV.LAST_STACK_RATIO
             ,  DTV.LAST_AMT_RANK
             ,  (CASE WHEN LAST_STACK_RATIO <= 70 THEN 'A'
                      WHEN LAST_STACK_RATIO  > 70 AND LAST_STACK_RATIO <= 90 THEN 'B'
                      ELSE 'C' END)   AS  LAST_ABC_GROUP
             ,  DTV_D.AVG_ORD_CQTY_SEQ
             ,  DTV_D.AVG_LEAD_TIME_SEQ
          FROM  (
                    SELECT  DTV.COMP_CD, DTV.BRAND_CD, DTV.ITEM_CD 
                         ,  DTV.ORD_QTY
                         ,  DTV.ORD_AMT
                         ,  DTV.ORD_VAT
                         ,  DTV.ORD_COST
                         ,  DTV.RATIO
                         ,  DTV.STACK_RATIO
                         ,  DTV.AMT_RANK
                         ,  DTV_LAST.ORD_QTY       AS  LAST_ORD_QTY
                         ,  DTV_LAST.ORD_AMT       AS  LAST_ORD_AMT
                         ,  DTV_LAST.ORD_VAT       AS  LAST_ORD_VAT
                         ,  DTV_LAST.ORD_COST      AS  LAST_ORD_COST
                         ,  DTV_LAST.RATIO         AS  LAST_RATIO
                         ,  DTV_LAST.STACK_RATIO   AS  LAST_STACK_RATIO
                         ,  DTV_LAST.AMT_RANK      AS  LAST_AMT_RANK
                      FROM  (
                                SELECT  COMP_CD, BRAND_CD, ITEM_CD, ORD_QTY, ORD_AMT, ORD_VAT
                                     ,  ROUND(ORD_COST / ORD_QTY, 0)                    AS  ORD_COST
                                     ,  ROUND(RATIO, 2)                                 AS  RATIO
                                     ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC), 2) AS  STACK_RATIO
                                     ,  AMT_RANK
                                  FROM  ( 
                                            SELECT  COMP_CD, BRAND_CD, ITEM_CD, ORD_QTY, ORD_COST, ORD_AMT, ORD_VAT
                                                 ,  ORD_AMT / (SUM(ORD_AMT) OVER ()) * 100       AS  RATIO
                                                 ,  RANK() OVER (ORDER BY ORD_AMT DESC)          AS  AMT_RANK
                                              FROM  (
                                                        SELECT  COMP_CD, BRAND_CD, ITEM_CD
                                                             ,  SUM(ORD_CQTY)                   AS ORD_QTY
                                                             ,  SUM(ORD_COST)                   AS ORD_COST
                                                             ,  SUM(ORD_CAMT)                   AS ORD_AMT
                                                             ,  SUM(ORD_CVAT)                   AS ORD_VAT
                                                          FROM  ORDER_DTV
                                                         WHERE  COMP_CD   = PSV_COMP_CD
                                                           AND  BRAND_CD  = PSV_BRAND_CD
                                                           AND  (PSV_STOR_CD IS NULL  OR  STOR_CD    = PSV_STOR_CD)
                                                           AND  STK_DT BETWEEN PSV_GFR_DATE AND PSV_GTO_DATE 
                                                           AND  (PSV_VENDOR_CD IS NULL OR  VENDOR_CD   = PSV_VENDOR_CD)
                                                         GROUP  BY COMP_CD
                                                             ,  BRAND_CD
                                                             ,  ITEM_CD
                                                    )  DTV
                                             WHERE  ORD_QTY<>0
                                        )   DTV
                            )   DTV
                         ,  (
                                SELECT  COMP_CD, BRAND_CD, ITEM_CD, ORD_QTY, ORD_AMT, ORD_VAT
                                     ,  ROUND(ORD_COST / ORD_QTY, 0)                    AS  ORD_COST
                                     ,  ROUND(RATIO, 2)                                 AS  RATIO
                                     ,  ROUND(SUM(RATIO) OVER (ORDER BY RATIO DESC), 2) AS  STACK_RATIO
                                     ,  AMT_RANK
                                  FROM  ( 
                                            SELECT  COMP_CD, BRAND_CD, ITEM_CD, ORD_QTY, ORD_COST, ORD_AMT, ORD_VAT
                                                 ,  ORD_AMT / (SUM(ORD_AMT) OVER ()) * 100       AS  RATIO
                                                 ,  RANK() OVER (ORDER BY ORD_AMT DESC)          AS  AMT_RANK
                                              FROM  (
                                                        SELECT  COMP_CD, BRAND_CD, ITEM_CD
                                                             ,  SUM(ORD_CQTY)                   AS ORD_QTY
                                                             ,  SUM(ORD_COST)                   AS ORD_COST
                                                             ,  SUM(ORD_CAMT)                   AS ORD_AMT
                                                             ,  SUM(ORD_CVAT)                   AS ORD_VAT
                                                          FROM  ORDER_DTV
                                                         WHERE  COMP_CD   = PSV_COMP_CD
                                                           AND  BRAND_CD  = PSV_BRAND_CD
                                                           AND  (PSV_STOR_CD IS NULL  OR  STOR_CD    = PSV_STOR_CD)
                                                           AND  STK_DT BETWEEN PSV_LFR_DATE AND PSV_LTO_DATE 
                                                           AND  (PSV_VENDOR_CD IS NULL OR  VENDOR_CD   = PSV_VENDOR_CD)
                                                         GROUP  BY COMP_CD
                                                             ,  BRAND_CD
                                                             ,  ITEM_CD
                                                    )  DTV
                                             WHERE  ORD_QTY<>0
                                        )   DTV
                            )   DTV_LAST
                        WHERE  DTV.COMP_CD   = DTV_LAST.COMP_CD(+)
                          AND  DTV.BRAND_CD  = DTV_LAST.BRAND_CD(+)
                          AND  DTV.ITEM_CD   = DTV_LAST.ITEM_CD(+)
                )   DTV
             ,  (
                    SELECT  I.COMP_CD
                         ,  PSV_BRAND_CD   AS  BRAND_CD
                         ,  I.ITEM_CD,   I.ITEM_NM,  I.ORD_START_DT
                         ,  I.SALE_PRC
                         ,  L.L_CLASS_CD, L.L_CLASS_NM
                         ,  M.M_CLASS_CD, M.M_CLASS_NM
                         ,  S.S_CLASS_CD, S.S_CLASS_NM
                         ,  D.D_CLASS_CD, D.D_CLASS_NM
                      FROM  ITEM I   
                         ,  (
                               SELECT   L.COMP_CD
                                    ,   L.L_CLASS_CD
                                    ,   NVL(LL.L_CLASS_NM, L.L_CLASS_NM)  AS L_CLASS_NM
                                 FROM   ITEM_L_CLASS L
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS L_CLASS_CD
                                                ,   LANG_NM  AS L_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_L_CLASS'
                                              AND   COL_NM      = 'L_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) LL
                                WHERE   L.COMP_CD     = LL.COMP_CD(+)
                                  AND   L.ORG_CLASS_CD||L.L_CLASS_CD = LL.L_CLASS_CD(+)
                                  AND   L.COMP_CD      = PSV_COMP_CD
                                  AND   L.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   L.USE_YN       = 'Y'
                            ) L
                         ,  (
                               SELECT   M.COMP_CD
                                    ,   M.L_CLASS_CD
                                    ,   M.M_CLASS_CD
                                    ,   NVL(ML.M_CLASS_NM, M.M_CLASS_NM)  AS M_CLASS_NM
                                 FROM   ITEM_M_CLASS M
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS M_CLASS_CD
                                                ,   LANG_NM  AS M_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_M_CLASS'
                                              AND   COL_NM      = 'M_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) ML
                                WHERE   M.COMP_CD     = ML.COMP_CD(+)
                                  AND   M.ORG_CLASS_CD||M.L_CLASS_CD||M.L_CLASS_CD = ML.M_CLASS_CD(+)
                                  AND   M.COMP_CD      = PSV_COMP_CD
                                  AND   M.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   M.USE_YN       = 'Y'
                            ) M
                         ,  (
                               SELECT   S.COMP_CD
                                    ,   S.L_CLASS_CD
                                    ,   S.M_CLASS_CD
                                    ,   S.S_CLASS_CD
                                    ,   NVL(SL.S_CLASS_NM, S.S_CLASS_NM)  AS S_CLASS_NM
                                 FROM   ITEM_S_CLASS S
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS S_CLASS_CD
                                                ,   LANG_NM  AS S_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_S_CLASS'
                                              AND   COL_NM      = 'S_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) SL
                                WHERE   S.COMP_CD     = SL.COMP_CD(+)
                                  AND   S.ORG_CLASS_CD||S.L_CLASS_CD||S.M_CLASS_CD||S.S_CLASS_CD = SL.S_CLASS_CD(+)
                                  AND   S.COMP_CD      = PSV_COMP_CD
                                  AND   S.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   S.USE_YN       = 'Y'
                            ) S
                         ,  (
                               SELECT   D.COMP_CD
                                    ,   D.L_CLASS_CD
                                    ,   D.M_CLASS_CD
                                    ,   D.S_CLASS_CD
                                    ,   D.D_CLASS_CD
                                    ,   NVL(SL.D_CLASS_NM, D.D_CLASS_NM)  AS D_CLASS_NM
                                 FROM   ITEM_D_CLASS D
                                    ,   (
                                           SELECT   COMP_CD
                                                ,   PK_COL   AS D_CLASS_CD
                                                ,   LANG_NM  AS D_CLASS_NM
                                             FROM   LANG_TABLE
                                            WHERE   COMP_CD     = PSV_COMP_CD
                                              AND   TABLE_NM    = 'ITEM_D_CLASS'
                                              AND   COL_NM      = 'D_CLASS_NM'
                                              AND   LANGUAGE_TP = PSV_LANG_CD
                                              AND   USE_YN      = 'Y'
                                        ) SL
                                WHERE   D.COMP_CD     = SL.COMP_CD(+)
                                  AND   D.ORG_CLASS_CD||D.L_CLASS_CD||D.M_CLASS_CD||D.S_CLASS_CD||D.D_CLASS_CD = SL.D_CLASS_CD(+)
                                  AND   D.COMP_CD      = PSV_COMP_CD
                                  AND   D.ORG_CLASS_CD = PSV_ORG_CLASS
                                  AND   D.USE_YN       = 'Y'
                            ) D
                     WHERE  I.COMP_CD    = L.COMP_CD(+)
                       AND  I.L_CLASS_CD = L.L_CLASS_CD(+)
                       AND  I.COMP_CD    = M.COMP_CD(+)
                       AND  I.L_CLASS_CD = M.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = M.M_CLASS_CD(+)
                       AND  I.COMP_CD    = S.COMP_CD(+)
                       AND  I.L_CLASS_CD = S.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = S.M_CLASS_CD(+)
                       AND  I.S_CLASS_CD = S.S_CLASS_CD(+)
                       AND  I.COMP_CD    = D.COMP_CD(+)
                       AND  I.L_CLASS_CD = D.L_CLASS_CD(+)
                       AND  I.M_CLASS_CD = D.M_CLASS_CD(+)
                       AND  I.S_CLASS_CD = D.S_CLASS_CD(+)
                       AND  I.D_CLASS_CD = D.D_CLASS_CD(+)
                       AND  I.COMP_CD    = PSV_COMP_CD
                       AND  I.BRAND_CD   IN ('0000', PSV_BRAND_CD)
                )  IT
             ,  (
                    SELECT  COMP_CD, BRAND_CD, ITEM_CD
                         ,  ROUND(SUM(ORD_CQTY)/SUM(ORD_SEQ), 2)                                      AS AVG_ORD_CQTY_SEQ
                         ,  CASE WHEN MIN(DT_CNT) > 0 THEN ROUND(SUM(LEAD_TIME_SEQ)/MIN(DT_CNT), 2) 
                                 ELSE 0 END                                                           AS AVG_LEAD_TIME_SEQ
                      FROM  (
                              SELECT  COMP_CD, BRAND_CD, ITEM_CD, ORD_DT, COUNT(ORD_SEQ) ORD_SEQ, SUM(ORD_CQTY) ORD_CQTY
                                   ,  SUM(COUNT(DISTINCT ORD_DT)) OVER (PARTITION BY BRAND_CD, ITEM_CD) - 1  AS DT_CNT
                                   ,  (TO_DATE(LEAD(ORD_DT, 1) OVER(PARTITION BY BRAND_CD, ITEM_CD ORDER BY BRAND_CD, ITEM_CD, ORD_DT), 'YYYYMMDD') - TO_DATE(ORD_DT, 'YYYYMMDD')) / COUNT(ORD_SEQ)  AS LEAD_TIME_SEQ
                                FROM  ORDER_DTV
                               WHERE  COMP_CD   = PSV_COMP_CD
                                 AND  BRAND_CD  = PSV_BRAND_CD
                                 AND  (PSV_STOR_CD IS NULL  OR  STOR_CD    = PSV_STOR_CD)
                                 AND  ORD_DT  BETWEEN PSV_LFR_DATE AND PSV_GTO_DATE 
                                 AND  STK_DT  IS NOT NULL
                               GROUP  BY COMP_CD, BRAND_CD, ITEM_CD, ORD_DT
                               ORDER  BY COMP_CD, BRAND_CD, ITEM_CD, ORD_DT
                            )
                     GROUP  BY COMP_CD
                         ,  BRAND_CD
                         ,  ITEM_CD               
                ) DTV_D
         WHERE  DTV.COMP_CD   = IT.COMP_CD
           AND  DTV.BRAND_CD  = IT.BRAND_CD
           AND  DTV.ITEM_CD   = IT.ITEM_CD        
           AND  DTV.COMP_CD   = DTV_D.COMP_CD        
           AND  DTV.BRAND_CD  = DTV_D.BRAND_CD        
           AND  DTV.ITEM_CD   = DTV_D.ITEM_CD
           AND  DTV.COMP_CD   = PSV_COMP_CD
           AND  DTV.BRAND_CD  = PSV_BRAND_CD
           AND  DTV.ORD_AMT <> 0
           AND  (PSV_L_CLASS_CD IS NULL OR IT.L_CLASS_CD = PSV_L_CLASS_CD)
           AND  (PSV_M_CLASS_CD IS NULL OR IT.M_CLASS_CD = PSV_M_CLASS_CD)
           AND  (PSV_S_CLASS_CD IS NULL OR IT.S_CLASS_CD = PSV_S_CLASS_CD)
           AND  (PSV_D_CLASS_CD IS NULL OR IT.D_CLASS_CD = PSV_D_CLASS_CD)
         ORDER  BY DTV.AMT_RANK    
             ,  IT.ITEM_CD;

        dbms_output.put_line( 'SUCCESS' );

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

    PROCEDURE SP_TAB05  /* 자재상세 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ITEM_CD     IN  VARCHAR2 ,                  -- 자재코드
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 영업조직
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 점포코드
        PSV_LFR_DATE    IN  VARCHAR2 ,                  -- 전월 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )   IS
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        OPEN PR_RESULT FOR
        SELECT  ORD_DT
             ,  ORD_SEQ
             ,  ORD_UNIT_QTY
             ,  ORD_COST
             ,  ORD_CQTY                      AS ORD_CQTY_DAY
             ,  ROUND(ORD_CQTY / ORD_SEQ, 2)  AS ORD_CQTY_SEQ
             ,  ORD_CAMT
             ,  LEAD_TIME_DAY
             ,  LEAD_TIME_SEQ
             ,  CASE WHEN DT_CNT = 1 THEN 0 
                     ELSE SUM(LEAD_TIME_DAY) OVER () / (DT_CNT - 1) END  AS  AVG_LEAD_TIME_DAY
             ,  CASE WHEN DT_CNT = 1 THEN 0 
                     ELSE SUM(LEAD_TIME_SEQ) OVER () / (SEQ_CNT - 1) END  AS  AVG_LEAD_TIME_SEQ
          FROM  (
                    SELECT  ORD_DT, COUNT(ORD_SEQ) ORD_SEQ, MAX(ORD_UNIT_QTY) ORD_UNIT_QTY, MAX(ORD_COST) ORD_COST
                         ,  SUM(ORD_CQTY) ORD_CQTY, SUM(ORD_CAMT) ORD_CAMT
                         ,  COUNT(DISTINCT ORD_DT) OVER () DT_CNT
                         ,  COUNT(ORD_DT) OVER () SEQ_CNT
                         ,  TO_DATE(LEAD(ORD_DT, 1) OVER(ORDER BY ORD_DT), 'YYYYMMDD') - TO_DATE(ORD_DT, 'YYYYMMDD')                     AS LEAD_TIME_DAY
                         ,  (TO_DATE(LEAD(ORD_DT, 1) OVER(ORDER BY ORD_DT), 'YYYYMMDD') - TO_DATE(ORD_DT, 'YYYYMMDD')) / COUNT(ORD_SEQ)  AS LEAD_TIME_SEQ
                      FROM  ORDER_DTV
                     WHERE  COMP_CD   = PSV_COMP_CD
                       AND  BRAND_CD  = PSV_BRAND_CD
                       AND  ORD_DT  BETWEEN PSV_LFR_DATE AND PSV_GTO_DATE
                       AND  (PSV_STOR_CD IS NULL OR STOR_CD = PSV_STOR_CD)
                       AND  ITEM_CD = PSV_ITEM_CD
                       AND  STK_DT  IS NOT NULL
                     GROUP  BY ORD_DT
                     ORDER  BY ORD_DT
                );

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

END PKG_SALE1190;

/
