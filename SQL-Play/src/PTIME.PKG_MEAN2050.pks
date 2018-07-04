CREATE OR REPLACE PACKAGE       PKG_MEAN2050 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MEAN2050
    --  Description      : 회원 vs 비회원 비교분석  
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
   );
   
    PROCEDURE SP_TAB02
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
   );
   
END PKG_MEAN2050;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEAN2050 AS

    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
   ) IS
    /******************************************************************************
    NAME:       PKG_MEAN2050.SP_TAB01   회원 vs 비회원 비교분석 - 전체 
    PURPOSE:

    REVISIONS:
    VER        DATE        AUTHOR           DESCRIPTION
    ---------  ----------  ---------------  ------------------------------------
    1.0        2014-07-11         1. CREATED THIS PROCEDURE.

    NOTES:
      OBJECT NAME:     PKG_MEAN2050.SP_TAB01
      SYSDATE:
      USERNAME:
      TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
       ( 
        SALE_YM     VARCHAR2(10),
        SALE_YM_NM  VARCHAR2(100)
       );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_HD2         VARCHAR2(20000);
    V_CNT          PLS_INTEGER;
    
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        --    dbms_output.enable( 1000000 ) ;
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
           ||  ls_sql_store; -- S_STORE
        /*       
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;
        */

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main :=
          Q'[ SELECT  TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), ROWNUM - 1), 'YYYYMM' ) AS SALE_YM,    ]'
        ||Q'[         TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), ROWNUM - 1), 'YYYY-MM') AS SALE_YM_NM  ]'
        ||Q'[ FROM    TAB   ]'
        ||Q'[ WHERE   ROWNUM <= 1 + MONTHS_BETWEEN(TO_DATE(:PSV_END_YM, 'YYYYMM'), TO_DATE(:PSV_STR_YM, 'YYYYMM'))  ]'
        ||Q'[ ORDER BY 1    ]';

        ls_sql := ls_sql_crosstab_main ;

        dbms_output.put_line(ls_sql) ;

        BEGIN
            EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_STR_YM, PSV_STR_YM, PSV_END_YM, PSV_STR_YM;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            END IF ;
        EXCEPTION
            WHEN ERR_HANDLER THEN
                RAISE ERR_HANDLER ;
            WHEN NO_DATA_FOUND THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            WHEN OTHERS THEN
                ls_err_cd := '4999999' ;
                ls_err_msg := SQLERRM ;
                RAISE ERR_HANDLER ;
        END;

       V_HD1 := ' SELECT '        
            || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_CD')||''', '
            || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_NM')||''', '          
            || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
            || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
            ;
        V_HD2 := V_HD1;

        FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB|| '''' || qry_hd(i).SALE_YM || '''';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 3) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 2) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 1) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4)  ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBER'   )|| ''' CT' || TO_CHAR(i*4 - 3 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )|| ''' CT' || TO_CHAR(i*4 - 2 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NONMEMBER')|| ''' CT' || TO_CHAR(i*4 - 1 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )||'''  CT' || TO_CHAR(i*4)   ;
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD, PSV_LANG_CD)  ||  V_HD1 || ' UNION ALL ' || V_HD2 ;
        
        /* MAIN SQL */
        ls_sql_main :=      Q'[ SELECT  JDS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[       , JDS.BRAND_CD        ]'   
        ||chr(13)||chr(10)||Q'[       , JDS.BRAND_NM        ]'                 
        ||chr(13)||chr(10)||Q'[       , JDS.COL_ID          ]'   
        ||chr(13)||chr(10)||Q'[       , GET_COMMON_CODE_NM(JDS.COMP_CD, '12180', JDS.COL_ID, :PSV_LANG_CD) AS COL_ID_NM ]'
        ||chr(13)||chr(10)||Q'[       , NVL(MAS.COL_VAL, 0)  AS CST_SALE_VAL    ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID NOT IN('2', '3') THEN (CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(MAS.COL_VAL, 0) / TOT.COL_VAL * 100, 2) END) ELSE 0 END AS CST_RATE  ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID = '2' AND TOT.COL_VAL = 0 THEN NULL ELSE JDS.COL_VAL END AS NCST_SALE_VAL ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID NOT IN('2', '3') THEN (CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(JDS.COL_VAL, 0) / TOT.COL_VAL * 100, 2) END) END AS NCST_RATE ]'
        ||chr(13)||chr(10)||Q'[ FROM   (                    ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *           ]'
        ||chr(13)||chr(10)||Q'[         FROM   (            ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  JDS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.BRAND_NM            ]'                                
        ||chr(13)||chr(10)||Q'[                       , JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)  AS BILL_CNT]'
        ||chr(13)||chr(10)||Q'[                       , NVL(MSS.CST_CNT, 0)                  AS CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                       , CASE WHEN (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)) = 0 THEN 0 ]'
        ||chr(13)||chr(10)||Q'[                              ELSE ROUND((JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0)) / (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)), 0) ]'
        ||chr(13)||chr(10)||Q'[                         END AS BILL_CST_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.SALE_QTY - NVL(MAS.SALE_QTY, 0) AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.SALE_AMT - NVL(MAS.SALE_AMT, 0) AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.DC_AMT   - NVL(MAS.DC_AMT  , 0) AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0) AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                 FROM   (                        ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  SUBSTR(JDS.SALE_DT, 1, 6)   AS SALE_YM      ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'                
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.BILL_CNT)           AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS CST_CNT      ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.SALE_QTY)           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.SALE_AMT)           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.DC_AMT+JDS.ENR_AMT) AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.GRD_AMT)            AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM    SALE_JDS   JDS  ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO  ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = JDS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = JDS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = JDS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     JDS.SALE_DT >= :PSV_STR_YM||'01' ]'
        ||chr(13)||chr(10)||Q'[                         AND     JDS.SALE_DT <= :PSV_END_YM||'31' ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SUBSTR(SALE_DT, 1, 6) ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'
        ||chr(13)||chr(10)||Q'[                        ) JDS                    ]'        
        ||chr(13)||chr(10)||Q'[                       ,(                        ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  MAS.SALE_YM     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.BILL_CNT)           AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_QTY)           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_AMT)           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.DC_AMT+MAS.ENR_AMT) AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.GRD_AMT)            AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM    C_CUST_MAS MAS              ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = MAS.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = MAS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = MAS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'
        ||chr(13)||chr(10)||Q'[                        ) MAS                    ]'
        ||chr(13)||chr(10)||Q'[                       ,(                        ]' 
        ||chr(13)||chr(10)||Q'[                         SELECT  SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                         FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                                 SELECT  MSS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                                       , ROW_NUMBER() OVER(PARTITION BY MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'      
        ||chr(13)||chr(10)||Q'[                                 FROM    C_CUST_MSS MSS      ]'
        ||chr(13)||chr(10)||Q'[                                       , S_STORE    STO      ]'
        ||chr(13)||chr(10)||Q'[                                 WHERE   STO.COMP_CD  = MSS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.BRAND_CD = MSS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.STOR_CD  = MSS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MSS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MSS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                                )                ]'         
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'                         
        ||chr(13)||chr(10)||Q'[                        ) MSS                    ]'
        ||chr(13)||chr(10)||Q'[                 WHERE    JDS.SALE_YM  = MAS.SALE_YM (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.COMP_CD  = MAS.COMP_CD (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.BRAND_CD = MAS.BRAND_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.SALE_YM  = MSS.SALE_YM (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.COMP_CD  = MSS.COMP_CD (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.BRAND_CD = MSS.BRAND_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                ) JDS                            ]'  
        ||chr(13)||chr(10)||Q'[                 UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7)) ]'
        ||chr(13)||chr(10)||Q'[        ) JDS                                    ]'     
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *                               ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                       , COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(BILL_CNT    )   AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(CST_CNT     )   AS CST_CNT      ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(BILL_CST_AMT)   AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(SALE_QTY    )   AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(SALE_AMT    )   AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(DC_AMT      )   AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(GRD_AMT     )   AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                 FROM   (                                    ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  MAS.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.BILL_CNT)               AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                               , 0                               AS CST_CNT  ]'
        ||chr(13)||chr(10)||Q'[                               , CASE WHEN SUM(MAS.BILL_CNT) = 0 THEN 0      ]'
        ||chr(13)||chr(10)||Q'[                                      ELSE ROUND(SUM(MAS.GRD_AMT) / SUM(MAS.BILL_CNT), 0) ]'
        ||chr(13)||chr(10)||Q'[                                 END AS BILL_CST_AMT         ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_QTY)               AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_AMT)               AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.DC_AMT + MAS.ENR_AMT)   AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.GRD_AMT)                AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                         FROM    C_CUST_MAS MAS              ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = MAS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = MAS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = MAS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                            ]'
        ||chr(13)||chr(10)||Q'[                                 MAS.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                         UNION ALL                           ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD                    ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS BILL_CNT     ]'  
        ||chr(13)||chr(10)||Q'[                               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) AS CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                                 SELECT  MMS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                                       , ROW_NUMBER() OVER(PARTITION BY MMS.SALE_YM, MMS.CUST_ID ORDER BY MMS.CUST_LVL) R_NUM ]'      
        ||chr(13)||chr(10)||Q'[                                 FROM    C_CUST_MSS MMS      ]'
        ||chr(13)||chr(10)||Q'[                                       , S_STORE    STO      ]'       
        ||chr(13)||chr(10)||Q'[                                 WHERE   STO.COMP_CD  = MMS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.BRAND_CD = MMS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.STOR_CD  = MMS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MMS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MMS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                                )                ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                )                                ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                         SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                       , COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[            ) MAS                                ]'
        ||chr(13)||chr(10)||Q'[         UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7)) ]'
        ||chr(13)||chr(10)||Q'[        ) MAS                                    ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *                               ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  SUBSTR(TOT.SALE_DT,1,6)         AS SALE_YM  ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.BILL_CNT)               AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                       , 0                               AS CST_CNT  ]'
        ||chr(13)||chr(10)||Q'[                       , CASE WHEN SUM(TOT.BILL_CNT) = 0 THEN 0 ELSE ROUND(SUM(TOT.GRD_AMT) / SUM(TOT.BILL_CNT), 0) END AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.SALE_QTY)               AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.SALE_AMT)               AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.DC_AMT + TOT.ENR_AMT)   AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.GRD_AMT)                AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                 FROM    SALE_JDS   TOT                              ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO                              ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = TOT.COMP_CD                  ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = TOT.BRAND_CD                 ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = TOT.STOR_CD                  ]'
        ||chr(13)||chr(10)||Q'[                 AND     TOT.SALE_DT >= :PSV_STR_YM||'01'            ]'
        ||chr(13)||chr(10)||Q'[                 AND     TOT.SALE_DT <= :PSV_END_YM||'31'            ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                                            ]'
        ||chr(13)||chr(10)||Q'[                         SUBSTR(TOT.SALE_DT,1,6) ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                ) TOT                                                ]'
        ||chr(13)||chr(10)||Q'[         UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7))  ]'
        ||chr(13)||chr(10)||Q'[        ) TOT                            ]'
        ||chr(13)||chr(10)||Q'[ WHERE   JDS.SALE_YM  = TOT.SALE_YM      ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COMP_CD  = TOT.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.BRAND_CD = TOT.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COL_ID   = TOT.COL_ID       ]'      
        ||chr(13)||chr(10)||Q'[ AND     JDS.SALE_YM  = MAS.SALE_YM (+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COMP_CD  = MAS.COMP_CD (+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.BRAND_CD = MAS.BRAND_CD(+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COL_ID   = MAS.COL_ID  (+)  ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
    
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   ' SELECT *   '
            || ' FROM (     '
            || ls_sql
            || ' ) SCM      '
            || ' PIVOT      '
            || ' (          '
            || '    SUM(CST_SALE_VAL )  VCOL1 '
            || ' ,  SUM(CST_RATE     )  VCOL2 '
            || ' ,  SUM(NCST_SALE_VAL)  VCOL3 '
            || ' ,  MAX(NCST_RATE    )  VCOL4 '
            || ' FOR (SALE_YM ) IN   ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2 ASC';

        --dbms_output.put_line( V_HD) ;
        --dbms_output.put_line( V_SQL) ;
        --dbms_output.put_line( V_CROSSTAB) ;
    
        OPEN PR_HEADER FOR      V_HD;
        OPEN PR_RESULT FOR      V_SQL
            USING PSV_LANG_CD, PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM,
                  PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM, 
                  PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM;

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
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
   ) IS
    /******************************************************************************
    NAME:       PKG_MEAN2050.SP_TAB02   회원 vs 비회원 비교분석 - 점포 
    PURPOSE:

    REVISIONS:
    VER        DATE        AUTHOR           DESCRIPTION
    ---------  ----------  ---------------  ------------------------------------
    1.0        2014-07-11         1. CREATED THIS PROCEDURE.

    NOTES:
      OBJECT NAME:     PKG_MEAN2050.SP_TAB02
      SYSDATE:
      USERNAME:
      TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
       ( 
        SALE_YM     VARCHAR2(10),
        SALE_YM_NM  VARCHAR2(100)
       );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_HD2         VARCHAR2(20000);
    V_CNT          PLS_INTEGER;
    
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        --    dbms_output.enable( 1000000 ) ;
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
           ||  ls_sql_store; -- S_STORE
        /*       
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;
        */

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main :=
          Q'[ SELECT  TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), ROWNUM - 1), 'YYYYMM' ) AS SALE_YM,    ]'
        ||Q'[         TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_STR_YM, 'YYYYMM'), ROWNUM - 1), 'YYYY-MM') AS SALE_YM_NM  ]'
        ||Q'[ FROM    TAB   ]'
        ||Q'[ WHERE   ROWNUM <= 1 + MONTHS_BETWEEN(TO_DATE(:PSV_END_YM, 'YYYYMM'), TO_DATE(:PSV_STR_YM, 'YYYYMM'))  ]'
        ||Q'[ ORDER BY 1    ]';

        ls_sql := ls_sql_crosstab_main ;

        dbms_output.put_line(ls_sql) ;

        BEGIN
            EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_STR_YM, PSV_STR_YM, PSV_END_YM, PSV_STR_YM;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            END IF ;
        EXCEPTION
            WHEN ERR_HANDLER THEN
                RAISE ERR_HANDLER ;
            WHEN NO_DATA_FOUND THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
                RAISE ERR_HANDLER ;
            WHEN OTHERS THEN
                ls_err_cd := '4999999' ;
                ls_err_msg := SQLERRM ;
                RAISE ERR_HANDLER ;
        END;

        V_HD1 := ' SELECT '        
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_CD')||''', '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_NM')||''', '   
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'STOR_CD' )||''', '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'STOR_NM' )||''', '                  
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
              || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
              ;
        V_HD2 := V_HD1;

        FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB|| '''' || qry_hd(i).SALE_YM || '''';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 3) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 2) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 1) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4)  ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBER'   )|| ''' CT' || TO_CHAR(i*4 - 3 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )|| ''' CT' || TO_CHAR(i*4 - 2 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NONMEMBER')|| ''' CT' || TO_CHAR(i*4 - 1 ) || ',' ;
                V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )||'''  CT' || TO_CHAR(i*4)   ;
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD, PSV_LANG_CD)  ||  V_HD1 || ' UNION ALL ' || V_HD2 ;
        
        /* MAIN SQL */
        ls_sql_main :=      Q'[ SELECT  JDS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[       , JDS.BRAND_CD        ]'   
        ||chr(13)||chr(10)||Q'[       , JDS.BRAND_NM        ]'
        ||chr(13)||chr(10)||Q'[       , JDS.STOR_CD         ]'          
        ||chr(13)||chr(10)||Q'[       , JDS.STOR_NM         ]'                                  
        ||chr(13)||chr(10)||Q'[       , JDS.COL_ID          ]'   
        ||chr(13)||chr(10)||Q'[       , GET_COMMON_CODE_NM(JDS.COMP_CD, '12180', JDS.COL_ID, :PSV_LANG_CD) AS COL_ID_NM ]'
        ||chr(13)||chr(10)||Q'[       , NVL(MAS.COL_VAL, 0)  AS CST_SALE_VAL    ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID NOT IN('2', '3') THEN (CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(MAS.COL_VAL, 0) / TOT.COL_VAL * 100, 2) END) ELSE 0 END AS CST_RATE  ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID = '2' AND TOT.COL_VAL = 0 THEN NULL ELSE JDS.COL_VAL END AS NCST_SALE_VAL ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN  JDS.COL_ID NOT IN('2', '3') THEN (CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(JDS.COL_VAL, 0) / TOT.COL_VAL * 100, 2) END) END AS NCST_RATE ]'
        ||chr(13)||chr(10)||Q'[ FROM   (                    ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *           ]'
        ||chr(13)||chr(10)||Q'[         FROM   (            ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  JDS.SALE_YM             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.BRAND_NM            ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.STOR_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.STOR_NM             ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)  AS BILL_CNT]'
        ||chr(13)||chr(10)||Q'[                       , NVL(MSS.CST_CNT, 0)                  AS CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                       , CASE WHEN (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)) = 0 THEN 0 ]'
        ||chr(13)||chr(10)||Q'[                              ELSE ROUND((JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0)) / (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)), 0) ]'
        ||chr(13)||chr(10)||Q'[                         END AS BILL_CST_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.SALE_QTY - NVL(MAS.SALE_QTY, 0) AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.SALE_AMT - NVL(MAS.SALE_AMT, 0) AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.DC_AMT   - NVL(MAS.DC_AMT  , 0) AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                       , JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0) AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                 FROM   (                        ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  SUBSTR(JDS.SALE_DT, 1, 6)   AS SALE_YM  ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'
        ||chr(13)||chr(10)||Q'[                               , JDS.STOR_CD     ]'      
        ||chr(13)||chr(10)||Q'[                               , STO.STOR_NM     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.BILL_CNT)           AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS CST_CNT      ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.SALE_QTY)           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.SALE_AMT)           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.DC_AMT+JDS.ENR_AMT) AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(JDS.GRD_AMT)            AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM    SALE_JDS   JDS  ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO  ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = JDS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = JDS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = JDS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     JDS.SALE_DT >= :PSV_STR_YM||'01' ]'
        ||chr(13)||chr(10)||Q'[                         AND     JDS.SALE_DT <= :PSV_END_YM||'31' ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SUBSTR(SALE_DT, 1, 6) ]'
        ||chr(13)||chr(10)||Q'[                               , STO.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , STO.BRAND_NM    ]'
        ||chr(13)||chr(10)||Q'[                               , JDS.STOR_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , STO.STOR_NM     ]'
        ||chr(13)||chr(10)||Q'[                        ) JDS                    ]'        
        ||chr(13)||chr(10)||Q'[                       ,(                        ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  MAS.SALE_YM     ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.STOR_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.BILL_CNT)           AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0                           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_QTY)           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_AMT)           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.DC_AMT+MAS.ENR_AMT) AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.GRD_AMT)            AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM    C_CUST_MAS MAS              ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = MAS.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = MAS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = MAS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.STOR_CD     ]'
        ||chr(13)||chr(10)||Q'[                        ) MAS                    ]'
        ||chr(13)||chr(10)||Q'[                       ,(                        ]' 
        ||chr(13)||chr(10)||Q'[                         SELECT  SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                               , STOR_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                         FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                                 SELECT  MSS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.STOR_CD         ]'
        ||chr(13)||chr(10)||Q'[                                       , MSS.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                                       , ROW_NUMBER() OVER(PARTITION BY MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM ]'      
        ||chr(13)||chr(10)||Q'[                                 FROM    C_CUST_MSS MSS      ]'
        ||chr(13)||chr(10)||Q'[                                       , S_STORE    STO      ]'
        ||chr(13)||chr(10)||Q'[                                 WHERE   STO.COMP_CD  = MSS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.BRAND_CD = MSS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.STOR_CD  = MSS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MSS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MSS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                                )                ]'         
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                               , STOR_CD         ]'                         
        ||chr(13)||chr(10)||Q'[                        ) MSS                    ]'
        ||chr(13)||chr(10)||Q'[                 WHERE    JDS.SALE_YM  = MAS.SALE_YM (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.COMP_CD  = MAS.COMP_CD (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.BRAND_CD = MAS.BRAND_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.STOR_CD  = MAS.STOR_CD (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.SALE_YM  = MSS.SALE_YM (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.COMP_CD  = MSS.COMP_CD (+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.BRAND_CD = MSS.BRAND_CD(+) ]'
        ||chr(13)||chr(10)||Q'[                 AND      JDS.STOR_CD  = MSS.STOR_CD(+)  ]'
        ||chr(13)||chr(10)||Q'[                ) JDS                            ]'  
        ||chr(13)||chr(10)||Q'[                 UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7)) ]'
        ||chr(13)||chr(10)||Q'[        ) JDS                                    ]'     
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *                               ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                       , COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                       , STOR_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(BILL_CNT    )   AS BILL_CNT     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(CST_CNT     )   AS CST_CNT      ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(BILL_CST_AMT)   AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(SALE_QTY    )   AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(SALE_AMT    )   AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(DC_AMT      )   AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(GRD_AMT     )   AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                 FROM   (                                    ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  MAS.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.STOR_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.BILL_CNT)               AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                               , 0                               AS CST_CNT  ]'
        ||chr(13)||chr(10)||Q'[                               , CASE WHEN SUM(MAS.BILL_CNT) = 0 THEN 0      ]'
        ||chr(13)||chr(10)||Q'[                                      ELSE ROUND(SUM(MAS.GRD_AMT) / SUM(MAS.BILL_CNT), 0) ]'
        ||chr(13)||chr(10)||Q'[                                 END AS BILL_CST_AMT         ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_QTY)               AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.SALE_AMT)               AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.DC_AMT + MAS.ENR_AMT)   AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                               , SUM(MAS.GRD_AMT)                AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                         FROM    C_CUST_MAS MAS              ]'
        ||chr(13)||chr(10)||Q'[                               , S_STORE    STO              ]'
        ||chr(13)||chr(10)||Q'[                         WHERE   STO.COMP_CD  = MAS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.BRAND_CD = MAS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                         AND     STO.STOR_CD  = MAS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                         AND     MAS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                            ]'
        ||chr(13)||chr(10)||Q'[                                 MAS.SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                               , MAS.STOR_CD                 ]'
        ||chr(13)||chr(10)||Q'[                         UNION ALL                           ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  SALE_YM                     ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD                    ]'
        ||chr(13)||chr(10)||Q'[                               , STOR_CD                    ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS BILL_CNT     ]'  
        ||chr(13)||chr(10)||Q'[                               , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) AS CST_CNT ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS SALE_QTY     ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS SALE_AMT     ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS DC_AMT       ]'
        ||chr(13)||chr(10)||Q'[                               , 0           AS GRD_AMT      ]'
        ||chr(13)||chr(10)||Q'[                         FROM   (                            ]'
        ||chr(13)||chr(10)||Q'[                                 SELECT  MMS.SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.STOR_CD        ]'
        ||chr(13)||chr(10)||Q'[                                       , MMS.CUST_ID         ]'
        ||chr(13)||chr(10)||Q'[                                       , ROW_NUMBER() OVER(PARTITION BY MMS.SALE_YM, MMS.CUST_ID ORDER BY MMS.CUST_LVL) R_NUM ]'      
        ||chr(13)||chr(10)||Q'[                                 FROM    C_CUST_MSS MMS      ]'
        ||chr(13)||chr(10)||Q'[                                       , S_STORE    STO      ]'       
        ||chr(13)||chr(10)||Q'[                                 WHERE   STO.COMP_CD  = MMS.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.BRAND_CD = MMS.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                                 AND     STO.STOR_CD  = MMS.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MMS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                                 AND     MMS.SALE_YM <= :PSV_END_YM  ]'
        ||chr(13)||chr(10)||Q'[                                )                ]'
        ||chr(13)||chr(10)||Q'[                         GROUP BY                ]'
        ||chr(13)||chr(10)||Q'[                                 SALE_YM         ]'
        ||chr(13)||chr(10)||Q'[                               , COMP_CD         ]'
        ||chr(13)||chr(10)||Q'[                               , BRAND_CD        ]'
        ||chr(13)||chr(10)||Q'[                               , STOR_CD         ]'
        ||chr(13)||chr(10)||Q'[                )                                ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                         SALE_YM                 ]'
        ||chr(13)||chr(10)||Q'[                       , COMP_CD                 ]'
        ||chr(13)||chr(10)||Q'[                       , BRAND_CD                ]'
        ||chr(13)||chr(10)||Q'[                       , STOR_CD                 ]'
        ||chr(13)||chr(10)||Q'[            ) MAS                                ]'
        ||chr(13)||chr(10)||Q'[         UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7)) ]'
        ||chr(13)||chr(10)||Q'[        ) MAS                                    ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  *                               ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  SUBSTR(TOT.SALE_DT,1,6)         AS SALE_YM  ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.STOR_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.BILL_CNT)               AS BILL_CNT ]'
        ||chr(13)||chr(10)||Q'[                       , 0                               AS CST_CNT  ]'
        ||chr(13)||chr(10)||Q'[                       , CASE WHEN SUM(TOT.BILL_CNT) = 0 THEN 0 ELSE ROUND(SUM(TOT.GRD_AMT) / SUM(TOT.BILL_CNT), 0) END AS BILL_CST_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.SALE_QTY)               AS SALE_QTY ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.SALE_AMT)               AS SALE_AMT ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.DC_AMT + TOT.ENR_AMT)   AS DC_AMT   ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(TOT.GRD_AMT)                AS GRD_AMT  ]'
        ||chr(13)||chr(10)||Q'[                 FROM    SALE_JDS   TOT                              ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE    STO                              ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   STO.COMP_CD  = TOT.COMP_CD                  ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.BRAND_CD = TOT.BRAND_CD                 ]'
        ||chr(13)||chr(10)||Q'[                 AND     STO.STOR_CD  = TOT.STOR_CD                  ]'
        ||chr(13)||chr(10)||Q'[                 AND     TOT.SALE_DT >= :PSV_STR_YM||'01'            ]'
        ||chr(13)||chr(10)||Q'[                 AND     TOT.SALE_DT <= :PSV_END_YM||'31'            ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                                            ]'
        ||chr(13)||chr(10)||Q'[                         SUBSTR(TOT.SALE_DT,1,6) ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , TOT.STOR_CD            ]'
        ||chr(13)||chr(10)||Q'[                ) TOT                                                ]'
        ||chr(13)||chr(10)||Q'[         UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7))  ]'
        ||chr(13)||chr(10)||Q'[        ) TOT                            ]'
        ||chr(13)||chr(10)||Q'[ WHERE   JDS.SALE_YM  = TOT.SALE_YM      ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COMP_CD  = TOT.COMP_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.BRAND_CD = TOT.BRAND_CD     ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.STOR_CD  = TOT.STOR_CD      ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COL_ID   = TOT.COL_ID       ]'      
        ||chr(13)||chr(10)||Q'[ AND     JDS.SALE_YM  = MAS.SALE_YM (+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COMP_CD  = MAS.COMP_CD (+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.BRAND_CD = MAS.BRAND_CD(+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.STOR_CD  = MAS.STOR_CD (+)  ]'
        ||chr(13)||chr(10)||Q'[ AND     JDS.COL_ID   = MAS.COL_ID  (+)  ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
    
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   ' SELECT *   '
            || ' FROM (     '
            || ls_sql
            || ' ) SCM      '
            || ' PIVOT      '
            || ' (          '
            || '    SUM(CST_SALE_VAL )  VCOL1 '
            || ' ,  SUM(CST_RATE     )  VCOL2 '
            || ' ,  SUM(NCST_SALE_VAL)  VCOL3 '
            || ' ,  MAX(NCST_RATE    )  VCOL4 '
            || ' FOR (SALE_YM ) IN   ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2 ASC';

        --dbms_output.put_line( V_HD) ;
        --dbms_output.put_line( V_SQL) ;
        --dbms_output.put_line( V_CROSSTAB) ;
    
        OPEN PR_HEADER FOR      V_HD;
        OPEN PR_RESULT FOR      V_SQL
            USING PSV_LANG_CD, PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM,
                  PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM, 
                  PSV_STR_YM, PSV_END_YM, PSV_STR_YM, PSV_END_YM;

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
    
END PKG_MEAN2050;

/
