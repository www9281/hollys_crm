CREATE OR REPLACE PACKAGE       PKG_MEAN1020 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MEAN1010
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
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );
    
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
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );
    
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
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );
        
END PKG_MEAN1020;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEAN1020 AS

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
        ls_sql_main :=      Q'[ SELECT  CST.CODE_NM                 ]'
        ||chr(13)||chr(10)||Q'[       , CST.TOT_CUST_CNT            ]'
        ||chr(13)||chr(10)||Q'[       , CST.NEW_CUST_CNT            ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_CUST_CNT            ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE      ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT   ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_SALE_QTY            ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_GRD_AMT             ]'
        ||chr(13)||chr(10)||Q'[ FROM   (                            ]'   
        ||chr(13)||chr(10)||Q'[         SELECT  V01.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[               , V02.CODE_CD         ]'
        ||chr(13)||chr(10)||Q'[               , V02.CODE_NM         ]'
        ||chr(13)||chr(10)||Q'[               , V01.TOT_CUST_CNT    ]'
        ||chr(13)||chr(10)||Q'[               , V01.NEW_CUST_CNT    ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                    ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , AGE_GRP     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT_CUST_CNT) AS TOT_CUST_CNT   ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(NEW_CUST_CNT) AS NEW_CUST_CNT   ]'
        ||chr(13)||chr(10)||Q'[                 FROM   (            ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  CST.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , CST.CUST_ID                 ]'
        ||chr(13)||chr(10)||Q'[                               , GET_AGE_GROUP (             ]'
        ||chr(13)||chr(10)||Q'[                                                 CST.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                                               , CASE WHEN REGEXP_INSTR(CASE WHEN CST.LUNAR_DIV = 'L' THEN UF_LUN2SOL(CST.BIRTH_DT, '0') ELSE CST.BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 ]'
        ||chr(13)||chr(10)||Q'[                                                      THEN  TRUNC((TO_NUMBER(:PSV_END_YM) - TO_NUMBER(SUBSTR(CASE WHEN CST.LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE CST.BIRTH_DT END, 1, 6))) / 100 + 1)            ]'
        ||chr(13)||chr(10)||Q'[                                                      ELSE 999 ]'
        ||chr(13)||chr(10)||Q'[                                                 END         ]'
        ||chr(13)||chr(10)||Q'[                                               ) AS AGE_GRP  ]'
        ||chr(13)||chr(10)||Q'[                               , CASE WHEN JOIN_DT <= :PSV_END_YM||'31'  AND NVL(LEAVE_DT, '99991231') >= :PSV_END_YM||'31' THEN 1 ELSE 0 END AS TOT_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[                               , CASE WHEN JOIN_DT LIKE :PSV_END_YM||'%' AND NVL(LEAVE_DT, '99991231') >= :PSV_END_YM||'31' THEN 1 ELSE 0 END AS NEW_CUST_CNT ]'
        ||chr(13)||chr(10)||Q'[                         FROM    C_CUST     CST              ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO              ]'  
        ||chr(13)||chr(10)||Q'[                         WHERE   CST.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     CST.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     CST.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     CST.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND    (:PSV_CUST_GRADE IS NULL OR CST.LVL_CD    = :PSV_CUST_GRADE  )   ]'
        ||chr(13)||chr(10)||Q'[                         AND    (CST.LEAVE_DT    IS NULL OR CST.LEAVE_DT >= :PSV_STR_YM||'01')   ]'
        ||chr(13)||chr(10)||Q'[                         AND     CST.CUST_STAT IN ('2', '9')     ]'
        ||chr(13)||chr(10)||Q'[                         AND     CST.JOIN_DT <= :PSV_END_YM||'31' ]'
        ||chr(13)||chr(10)||Q'[                        )            ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY            ]'
        ||chr(13)||chr(10)||Q'[                         COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , AGE_GRP     ]'
        ||chr(13)||chr(10)||Q'[                ) V01                ]'
        ||chr(13)||chr(10)||Q'[               ,(                    ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  COM.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_CD ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_NM ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N1  ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N2  ]'
        ||chr(13)||chr(10)||Q'[                 FROM    COMMON  COM ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   COM.COMP_CD = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.CODE_TP = '01760'       ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.USE_YN  = 'Y'           ]'
        ||chr(13)||chr(10)||Q'[                ) V02                                ]'
        ||chr(13)||chr(10)||Q'[         WHERE   V01.COMP_CD = V02.COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[         AND     V01.AGE_GRP = V02.CODE_CD           ]'
        ||chr(13)||chr(10)||Q'[        ) CST                                        ]'
        ||chr(13)||chr(10)||Q'[       ,(                                            ]'
        ||chr(13)||chr(10)||Q'[         SELECT  MSS.COMP_CD                         ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_CD                         ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN R_NUM = 1 AND MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2 THEN 1            ELSE 0 END) CST_CUST_CNT   ]' 
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.BILL_CNT ELSE 0 END) CST_BILL_CNT   ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.SALE_QTY ELSE 0 END) CST_SALE_QTY   ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.GRD_AMT  ELSE 0 END) CST_GRD_AMT    ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                    ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  MSS.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_AGE                ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_ID                 ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BILL_CNT                ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_QTY                ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.GRD_AMT                 ]'
        ||chr(13)||chr(10)||Q'[                       , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY  MSS.CUST_LVL) R_NUM ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MSS MSS              ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = MSS.COMP_CD  ]'        
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = MSS.BRAND_CD ]'        
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = MSS.STOR_CD  ]' 
        ||chr(13)||chr(10)||Q'[                 AND     MSS.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_GRADE IS NULL OR MSS.CUST_LVL = :PSV_CUST_GRADE)  ]'
        ||chr(13)||chr(10)||Q'[                ) MSS                                ]'
        ||chr(13)||chr(10)||Q'[               ,(                                    ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  COM.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_NM     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N1      ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N2      ]'
        ||chr(13)||chr(10)||Q'[                 FROM    COMMON  COM     ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   COM.COMP_CD = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.CODE_TP = '01760'       ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.USE_YN  = 'Y'           ]'
        ||chr(13)||chr(10)||Q'[                ) V03                                ]'
        ||chr(13)||chr(10)||Q'[         WHERE   MSS.COMP_CD = V03.COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                 MSS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_CD             ]'
        ||chr(13)||chr(10)||Q'[        ) MSS                            ]'
        ||chr(13)||chr(10)||Q'[ WHERE   CST.COMP_CD   = MSS.COMP_CD(+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     CST.CODE_CD   = MSS.CODE_CD(+)  ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY CST.CODE_CD                    ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_END_YM, PSV_END_YM, PSV_END_YM, PSV_END_YM, PSV_END_YM,
                         PSV_COMP_CD, PSV_CUST_GRADE, PSV_CUST_GRADE, PSV_STR_YM, PSV_END_YM,
                         PSV_COMP_CD, PSV_COMP_CD, PSV_STR_YM, PSV_END_YM, 
                         PSV_CUST_GRADE, PSV_CUST_GRADE, PSV_COMP_CD;

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
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
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
        
        ls_sql_main :=      Q'[ SELECT  MSS.STOR_CD                 ]'
        ||chr(13)||chr(10)||Q'[       , STO.STOR_NM                 ]'
        ||chr(13)||chr(10)||Q'[       , MSS.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CODE_CD                 ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CODE_NM                 ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_CUST_CNT            ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ]'
        ||chr(13)||chr(10)||Q'[              ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT    ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_SALE_QTY            ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CST_GRD_AMT             ]'
        ||chr(13)||chr(10)||Q'[ FROM    S_STORE STO                 ]'
        ||chr(13)||chr(10)||Q'[       ,(                            ]'
        ||chr(13)||chr(10)||Q'[         SELECT  MSS.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[               , MSS.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[               , MSS.STOR_CD         ]'
        ||chr(13)||chr(10)||Q'[               , MSS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_CD         ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_NM         ]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN R_NUM = 1 AND MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2 THEN 1            ELSE 0 END) CST_CUST_CNT]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.BILL_CNT ELSE 0 END) CST_BILL_CNT]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.SALE_QTY ELSE 0 END) CST_SALE_QTY]'
        ||chr(13)||chr(10)||Q'[               , SUM(CASE WHEN MSS.CUST_AGE BETWEEN V03.VAL_N1 AND V03.VAL_N2               THEN MSS.GRD_AMT  ELSE 0 END) CST_GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                        ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  MSS.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.STOR_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_YM     ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_AGE    ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.CUST_ID     ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.BILL_CNT    ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.SALE_QTY    ]'
        ||chr(13)||chr(10)||Q'[                       , MSS.GRD_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.STOR_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MSS MSS  ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO  ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = MSS.COMP_CD  ]'        
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = MSS.BRAND_CD ]'        
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = MSS.STOR_CD  ]' 
        ||chr(13)||chr(10)||Q'[                 AND     MSS.COMP_CD  = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MSS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_GRADE IS NULL OR MSS.CUST_LVL = :PSV_CUST_GRADE) ]'
        ||chr(13)||chr(10)||Q'[                ) MSS                    ]'
        ||chr(13)||chr(10)||Q'[               ,(                        ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  COM.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_CD     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.CODE_NM     ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N1      ]'
        ||chr(13)||chr(10)||Q'[                       , COM.VAL_N2      ]'
        ||chr(13)||chr(10)||Q'[                 FROM    COMMON     COM  ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   COM.COMP_CD = :PSV_COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.CODE_TP = '01760'       ]'
        ||chr(13)||chr(10)||Q'[                 AND     COM.USE_YN  = 'Y'           ]'
        ||chr(13)||chr(10)||Q'[                ) V03                                ]'
        ||chr(13)||chr(10)||Q'[         WHERE   MSS.COMP_CD = V03.COMP_CD           ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                 MSS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MSS.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[               , MSS.STOR_CD             ]'
        ||chr(13)||chr(10)||Q'[               , MSS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_CD             ]'
        ||chr(13)||chr(10)||Q'[               , V03.CODE_NM             ]'
        ||chr(13)||chr(10)||Q'[        ) MSS                            ]'
        ||chr(13)||chr(10)||Q'[ WHERE   MSS.COMP_CD  = STO.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.BRAND_CD = STO.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[ AND     MSS.STOR_CD  = STO.STOR_CD      ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY                                ]'
        ||chr(13)||chr(10)||Q'[         MSS.STOR_CD                     ]'
        ||chr(13)||chr(10)||Q'[       , MSS.SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[       , MSS.CODE_CD                     ]'
        ;
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_STR_YM, PSV_END_YM, PSV_CUST_GRADE, PSV_CUST_GRADE,
                         PSV_COMP_CD;

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
    PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
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
        
        ls_sql_main :=      Q'[ SELECT  TOT.COMP_CD               ]'
        ||chr(13)||chr(10)||Q'[       , TOT.STOR_CD               ]'      
        ||chr(13)||chr(10)||Q'[       , STO.STOR_NM               ]'
        ||chr(13)||chr(10)||Q'[       , TOT.SALE_YM               ]'
        ||chr(13)||chr(10)||Q'[       , V03.CODE_CD               ]'
        ||chr(13)||chr(10)||Q'[       , V03.CODE_NM               ]'                                
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_ID               ]'    
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_ID               ]'    
        ||chr(13)||chr(10)||Q'[       , decrypt(CST.CUST_NM) AS CUST_NM  ]'                                
        ||chr(13)||chr(10)||Q'[       , TOT.ITEM_CD               ]'
        ||chr(13)||chr(10)||Q'[       , ITM.ITEM_NM               ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_SALE_QTY          ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_SALE_AMT          ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_DC_AMT            ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CST_GRD_AMT           ]'
        ||chr(13)||chr(10)||Q'[ FROM    S_STORE STO               ]'
        ||chr(13)||chr(10)||Q'[       , S_ITEM ITM                ]'
        ||chr(13)||chr(10)||Q'[       , C_CUST CST                ]'                                
        ||chr(13)||chr(10)||Q'[       ,(                          ]'
        ||chr(13)||chr(10)||Q'[         SELECT  MMS.COMP_CD       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.BRAND_CD      ]'
        ||chr(13)||chr(10)||Q'[               , MMS.STOR_CD       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.SALE_YM       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_AGE      ]'                                
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_ID       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.ITEM_CD       ]'                
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.SALE_QTY) AS CST_SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.SALE_AMT) AS CST_SALE_AMT ]'         
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.DC_AMT)   AS CST_DC_AMT   ]'                                           
        ||chr(13)||chr(10)||Q'[               , SUM(MMS.GRD_AMT)  AS CST_GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                  ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  MS.COMP_CD                ]'
        ||chr(13)||chr(10)||Q'[                       , MS.BRAND_CD               ]'
        ||chr(13)||chr(10)||Q'[                       , MS.STOR_CD                ]'
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_YM                ]'
        ||chr(13)||chr(10)||Q'[                       , MS.CUST_AGE               ]'
        ||chr(13)||chr(10)||Q'[                       , MS.CUST_ID                ]'
        ||chr(13)||chr(10)||Q'[                       , MS.ITEM_CD                ]'                                
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_QTY               ]'
        ||chr(13)||chr(10)||Q'[                       , MS.SALE_AMT               ]'      
        ||chr(13)||chr(10)||Q'[                       , MS.DC_AMT + MS.ENR_AMT AS DC_AMT  ]'                                                
        ||chr(13)||chr(10)||Q'[                       , MS.GRD_AMT                        ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MMS MS                     ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    ST                     ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   ST.COMP_CD  = MS.COMP_CD  ]'        
        ||chr(13)||chr(10)||Q'[                 AND     ST.BRAND_CD = MS.BRAND_CD ]'        
        ||chr(13)||chr(10)||Q'[                 AND     ST.STOR_CD  = MS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.COMP_CD  = :PSV_COMP_CD]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.SALE_YM >= :PSV_STR_YM ]'
        ||chr(13)||chr(10)||Q'[                 AND     MS.SALE_YM <= :PSV_END_YM ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_GRADE IS NULL OR MS.CUST_LVL = :PSV_CUST_GRADE) ]'
        ||chr(13)||chr(10)||Q'[                ) MMS                              ]'
        ||chr(13)||chr(10)||Q'[         GROUP BY                                  ]'
        ||chr(13)||chr(10)||Q'[                 MMS.COMP_CD                       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.BRAND_CD                      ]'
        ||chr(13)||chr(10)||Q'[               , MMS.STOR_CD                       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.SALE_YM                       ]'        
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_ID                       ]'                                
        ||chr(13)||chr(10)||Q'[               , MMS.ITEM_CD                       ]'
        ||chr(13)||chr(10)||Q'[               , MMS.CUST_AGE                      ]'                
        ||chr(13)||chr(10)||Q'[        ) TOT                                      ]'
        ||chr(13)||chr(10)||Q'[      , (                                          ]'
        ||chr(13)||chr(10)||Q'[         SELECT  COM.COMP_CD          ]'
        ||chr(13)||chr(10)||Q'[               , COM.CODE_CD          ]'
        ||chr(13)||chr(10)||Q'[               , COM.CODE_NM          ]'
        ||chr(13)||chr(10)||Q'[               , COM.VAL_N1           ]'
        ||chr(13)||chr(10)||Q'[               , COM.VAL_N2           ]'
        ||chr(13)||chr(10)||Q'[         FROM    COMMON     COM       ]'
        ||chr(13)||chr(10)||Q'[         WHERE   COM.COMP_CD = :PSV_COMP_CD ]'
        ||chr(13)||chr(10)||Q'[         AND     COM.CODE_TP = '01760']'
        ||chr(13)||chr(10)||Q'[         AND     COM.USE_YN  = 'Y'    ]'
        ||chr(13)||chr(10)||Q'[        ) V03                         ]'
        ||chr(13)||chr(10)||Q'[ WHERE   TOT.COMP_CD  = STO.COMP_CD   ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.BRAND_CD = STO.BRAND_CD  ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.STOR_CD  = STO.STOR_CD   ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.COMP_CD  = V03.COMP_CD   ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.CUST_AGE  BETWEEN V03.VAL_N1 AND V03.VAL_N2 ]'                                
        ||chr(13)||chr(10)||Q'[ AND     TOT.CUST_ID  = CST.CUST_ID   ]'
        ||chr(13)||chr(10)||Q'[ AND     TOT.ITEM_CD  = ITM.ITEM_CD   ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY                             ]'
        ||chr(13)||chr(10)||Q'[         TOT.COMP_CD                  ]'
        ||chr(13)||chr(10)||Q'[       , TOT.STOR_CD                  ]'
        ||chr(13)||chr(10)||Q'[       , TOT.SALE_YM                  ]'
        ||chr(13)||chr(10)||Q'[       , V03.CODE_CD                  ]'
        ||chr(13)||chr(10)||Q'[       , TOT.CUST_ID                  ]'
        ||chr(13)||chr(10)||Q'[       , TOT.ITEM_CD                  ]'
        ;
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
         OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_STR_YM, PSV_END_YM, PSV_CUST_GRADE, PSV_CUST_GRADE,
                         PSV_COMP_CD;

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
    
END PKG_MEAN1020;

/
