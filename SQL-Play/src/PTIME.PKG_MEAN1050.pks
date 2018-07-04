CREATE OR REPLACE PACKAGE       PKG_MEAN1050 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MEAN1050
    --  Description      : 고객육성관점-유지율 등업율 
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
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );

END PKG_MEAN1050;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEAN1050 AS

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
   NAME:       PKG_MEAN1050.SP_TAB01      회원관리지표-고객창출관점-기간
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     PKG_MEAN1050.SP_TAB01
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
        ls_sql_main :=      Q'[   , W_CUST AS                                   ]'
        ||chr(13)||chr(10)||Q'[    (                                            ]'
        ||chr(13)||chr(10)||Q'[     SELECT  MVL.COMP_CD                         ]'
        ||chr(13)||chr(10)||Q'[           , MVL.SALE_YM                         ]'
        ||chr(13)||chr(10)||Q'[           , MVL.BRAND_CD                        ]'
        ||chr(13)||chr(10)||Q'[           , MVL.CUST_ID                         ]'
        ||chr(13)||chr(10)||Q'[           , MVL.CUST_LVL                        ]'
        ||chr(13)||chr(10)||Q'[     FROM    C_CUST_MLVL MVL                     ]'
        ||chr(13)||chr(10)||Q'[           ,(                                    ]'
        ||chr(13)||chr(10)||Q'[             SELECT  CST.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                  ,  CST.BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                  ,  CST.CUST_ID                 ]'
        ||chr(13)||chr(10)||Q'[             FROM    C_CUST      CST             ]'
        ||chr(13)||chr(10)||Q'[                  ,  S_STORE     STO             ]'
        ||chr(13)||chr(10)||Q'[             WHERE   CST.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[             AND     CST.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[             AND     CST.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[             AND     SUBSTR(NVL(CST.LEAVE_DT,'99991231'), 1, 8) >= :PSV_STR_YM||'31'   ]'
        ||chr(13)||chr(10)||Q'[            ) CST                                ]'
        ||chr(13)||chr(10)||Q'[     WHERE   CST.COMP_CD  = MVL.COMP_CD          ]'
        ||chr(13)||chr(10)||Q'[     AND     CST.BRAND_CD = MVL.BRAND_CD         ]'
        ||chr(13)||chr(10)||Q'[     AND     CST.CUST_ID  = MVL.CUST_ID          ]'
        ||chr(13)||chr(10)||Q'[     AND     MVL.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), -1), 'YYYYMM') ]'
        ||chr(13)||chr(10)||Q'[     AND     MVL.SALE_YM <= :PSV_END_YM          ]'
        ||chr(13)||chr(10)||Q'[    )                                            ]'
        ||chr(13)||chr(10)||Q'[     SELECT  W03.COMP_CD                         ]'
        ||chr(13)||chr(10)||Q'[           , W03.SALE_YM                         ]'
        ||chr(13)||chr(10)||Q'[           , W03.LVL_ST_CNT                      ]'
        ||chr(13)||chr(10)||Q'[           , V04.LST_LVL_CNT                     ]'
        ||chr(13)||chr(10)||Q'[           , CASE WHEN V04.LST_LVL_CNT = 0 THEN 0 ELSE W03.LVL_ST_CNT / V04.LST_LVL_CNT * 100 END AS LVL_ST_RATE ]'
        ||chr(13)||chr(10)||Q'[           , W03.LVL_UP_CNT                      ]'
        ||chr(13)||chr(10)||Q'[           , V04.LOW_LVL_CNT                     ]'
        ||chr(13)||chr(10)||Q'[           , CASE WHEN V04.LOW_LVL_CNT = 0 THEN 0 ELSE W03.LVL_UP_CNT / V04.LOW_LVL_CNT * 100 END AS LVL_UP_RATE ]'
        ||chr(13)||chr(10)||Q'[     FROM   (                                    ]'
        ||chr(13)||chr(10)||Q'[             SELECT  W01.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                   , W01.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                   , SUM(CASE WHEN W01.LVL_RANK > W02.LVL_RANK AND W01.CUST_LVL = :PSV_CUST_GRADE THEN 1 ELSE 0 END) AS LVL_UP_CNT ]'
        ||chr(13)||chr(10)||Q'[                   , SUM(CASE WHEN W01.LVL_RANK = W02.LVL_RANK AND W01.CUST_LVL = :PSV_CUST_GRADE THEN 1 ELSE 0 END) AS LVL_ST_CNT ]'
        ||chr(13)||chr(10)||Q'[             FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                     SELECT  W01.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                           , W01.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                           , W01.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                           , W01.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                           , W01.CUST_LVL        ]'
        ||chr(13)||chr(10)||Q'[                           , LVL.LVL_RANK        ]'
        ||chr(13)||chr(10)||Q'[                     FROM    W_CUST W01          ]'
        ||chr(13)||chr(10)||Q'[                           , C_CUST_LVL LVL      ]'
        ||chr(13)||chr(10)||Q'[                     WHERE   W01.COMP_CD  = LVL.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                     AND     W01.CUST_LVL = LVL.LVL_CD   ]'
        ||chr(13)||chr(10)||Q'[                     AND     W01.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                     AND     W01.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                     AND     W01.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                     AND     LVL.USE_YN  = 'Y'   ]'
        ||chr(13)||chr(10)||Q'[                    ) W01                        ]'
        ||chr(13)||chr(10)||Q'[                  , (                            ]'
        ||chr(13)||chr(10)||Q'[                     SELECT  W02.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                           , TO_CHAR(ADD_MONTHS(TO_DATE(W02.SALE_YM, 'YYYYMM'), 1), 'YYYYMM') AS SALE_YM ]'
        ||chr(13)||chr(10)||Q'[                           , W02.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                           , W02.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                           , W02.CUST_LVL        ]'
        ||chr(13)||chr(10)||Q'[                           , LVL.LVL_RANK        ]'
        ||chr(13)||chr(10)||Q'[                     FROM    W_CUST     W02      ]'
        ||chr(13)||chr(10)||Q'[                           , C_CUST_LVL LVL      ]'
        ||chr(13)||chr(10)||Q'[                     WHERE   W02.COMP_CD  = LVL.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                     AND     W02.CUST_LVL = LVL.LVL_CD  ]'
        ||chr(13)||chr(10)||Q'[                     AND     W02.COMP_CD  = :PSV_COMP_CD]'
        ||chr(13)||chr(10)||Q'[                     AND     W02.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), -1), 'YYYYMM') ]'
        ||chr(13)||chr(10)||Q'[                     AND     W02.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_END_YM, 'YYYYMM'), -1), 'YYYYMM') ]'
        ||chr(13)||chr(10)||Q'[                     AND     LVL.USE_YN  = 'Y'   ]'
        ||chr(13)||chr(10)||Q'[                    ) W02                        ]'
        ||chr(13)||chr(10)||Q'[             WHERE   W01.COMP_CD  = W02.COMP_CD(+) ]'
        ||chr(13)||chr(10)||Q'[             AND     W01.SALE_YM  = W02.SALE_YM(+) ]'
        ||chr(13)||chr(10)||Q'[             AND     W01.CUST_ID  = W02.CUST_ID(+) ]'
        ||chr(13)||chr(10)||Q'[             GROUP BY                            ]'
        ||chr(13)||chr(10)||Q'[                     W01.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                   , W01.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[            ) W03                                ]'
        ||chr(13)||chr(10)||Q'[           ,(                                    ]'
        ||chr(13)||chr(10)||Q'[             SELECT  V03.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                   , V03.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                   , SUM(CASE WHEN V03.STD_LVL_RANK > V03.LVL_RANK THEN 1 ELSE 0 END) AS LOW_LVL_CNT ]'
        ||chr(13)||chr(10)||Q'[                   , SUM(CASE WHEN V03.STD_LVL_RANK = V03.LVL_RANK THEN 1 ELSE 0 END) AS LST_LVL_CNT ]'
        ||chr(13)||chr(10)||Q'[             FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                     SELECT  V01.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                           , TO_CHAR(ADD_MONTHS(TO_DATE(V01.SALE_YM, 'YYYYMM'), 1), 'YYYYMM') AS SALE_YM ]'
        ||chr(13)||chr(10)||Q'[                           , V01.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                           , V01.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                           , V01.CUST_LVL        ]'
        ||chr(13)||chr(10)||Q'[                           , LVL.LVL_RANK        ]'
        ||chr(13)||chr(10)||Q'[                           , V02.STD_LVL_CD      ]'
        ||chr(13)||chr(10)||Q'[                           , V02.STD_LVL_RANK    ]'
        ||chr(13)||chr(10)||Q'[                     FROM    W_CUST     V01      ]'
        ||chr(13)||chr(10)||Q'[                           , C_CUST_LVL LVL      ]'
        ||chr(13)||chr(10)||Q'[                           ,(                    ]'
        ||chr(13)||chr(10)||Q'[                             SELECT  COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                                   , LVL_CD      AS STD_LVL_CD   ]'
        ||chr(13)||chr(10)||Q'[                                   , LVL_RANK    AS STD_LVL_RANK ]'
        ||chr(13)||chr(10)||Q'[                             FROM    C_CUST_LVL                  ]'
        ||chr(13)||chr(10)||Q'[                             WHERE   COMP_CD = :PSV_COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[                             AND     LVL_CD  = :PSV_CUST_GRADE   ]'
        ||chr(13)||chr(10)||Q'[                             AND     USE_YN  = 'Y'               ]'
        ||chr(13)||chr(10)||Q'[                            ) V02                ]'   
        ||chr(13)||chr(10)||Q'[                     WHERE   V01.COMP_CD  = LVL.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                     AND     V01.CUST_LVL = LVL.LVL_CD  ]'
        ||chr(13)||chr(10)||Q'[                     AND     V01.COMP_CD  = V02.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                     AND     V01.COMP_CD  = :PSV_COMP_CD]'
        ||chr(13)||chr(10)||Q'[                     AND     V01.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), -1), 'YYYYMM') ]'
        ||chr(13)||chr(10)||Q'[                     AND     V01.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_END_YM, 'YYYYMM'), -1), 'YYYYMM') ]'
        ||chr(13)||chr(10)||Q'[                  ) V03                          ]'
        ||chr(13)||chr(10)||Q'[             GROUP BY                            ]'
        ||chr(13)||chr(10)||Q'[                     V03.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                   , V03.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[          ) V04                                  ]'
        ||chr(13)||chr(10)||Q'[     WHERE   W03.COMP_CD = V04.COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[     AND     W03.SALE_YM = V04.SALE_YM           ]'
        ||chr(13)||chr(10)||Q'[     ORDER BY                                    ]'
        ||chr(13)||chr(10)||Q'[             W03.SALE_YM                         ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_STR_YM, PSV_STR_YM,  PSV_END_YM, 
                         PSV_CUST_GRADE, PSV_CUST_GRADE, PSV_COMP_CD, PSV_STR_YM, PSV_END_YM, 
                         PSV_COMP_CD, PSV_STR_YM, PSV_END_YM,
                         PSV_COMP_CD, PSV_CUST_GRADE, PSV_COMP_CD, PSV_STR_YM, PSV_END_YM;

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

END PKG_MEAN1050;

/
