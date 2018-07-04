CREATE OR REPLACE PACKAGE       PKG_MEAN2010 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_MEAN2010
    --  Description      :  연령대 상품분류별 구매분석  
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
    PSV_CUST_AGE    IN  VARCHAR2 ,                -- 연령대
    PSV_CUST_LVL    IN  VARCHAR2 ,                -- 회원등급
    PSV_CUST_SEX    IN  VARCHAR2 ,                -- 성별
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );

END PKG_MEAN2010;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEAN2010 AS

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
    PSV_CUST_AGE    IN  VARCHAR2 ,                -- 연령대
    PSV_CUST_LVL    IN  VARCHAR2 ,                -- 회원등급
    PSV_CUST_SEX    IN  VARCHAR2 ,                -- 성별
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
   NAME:       PKG_MEAN2010.SP_TAB01       연령대 상품분류별 구매분석 
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     PKG_MEAN2010.SP_TAB01
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
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        -- 조회기간 처리---------------------------------------------------------------
        --ls_sql_date := ' DL.APPR_DT ' || ls_date1;
        --IF ls_ex_date1 IS NOT NULL THEN
        --   ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
        --END IF;
        ------------------------------------------------------------------------------
        ls_sql_main :=      Q'[ SELECT  V02.COMP_CD                             ]'
        ||chr(13)||chr(10)||Q'[       , V02.BRAND_CD                            ]'                
        ||chr(13)||chr(10)||Q'[       , V02.BRAND_NM                            ]'
        ||chr(13)||chr(10)||Q'[       , V02.AGE_GRP                             ]'
        ||chr(13)||chr(10)||Q'[       , GET_COMMON_CODE_NM(V02.COMP_CD, '01760', V02.AGE_GRP, :PSV_LANG_CD) AS AGE_GRP_NM ]'                
        ||chr(13)||chr(10)||Q'[       , V02.L_CLASS_CD                          ]'
        ||chr(13)||chr(10)||Q'[       , ITM.L_CLASS_NM                          ]'
        ||chr(13)||chr(10)||Q'[       , V02.M_CLASS_CD                          ]'
        ||chr(13)||chr(10)||Q'[       , ITM.M_CLASS_NM                          ]'
        ||chr(13)||chr(10)||Q'[       , V02.S_CLASS_CD                          ]'
        ||chr(13)||chr(10)||Q'[       , ITM.S_CLASS_NM                          ]'
        ||chr(13)||chr(10)||Q'[       , V02.CLS_SUM_QTY                         ]'
        ||chr(13)||chr(10)||Q'[       , V02.CLS_SUM_GRD                         ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN V02.AGE_SUM_GRD = 0 THEN 0    ]'
        ||chr(13)||chr(10)||Q'[              ELSE V02.CLS_SUM_GRD / V02.AGE_SUM_GRD  * 100 ]'
        ||chr(13)||chr(10)||Q'[         END AS GRD_RATE                         ]'
        ||chr(13)||chr(10)||Q'[       , V02.ITEM_CD                             ]'
        ||chr(13)||chr(10)||Q'[       , '('||V02.ITEM_CD||')'||ITM.ITEM_NM AS TOP_ITEM_CD]'            
        ||chr(13)||chr(10)||Q'[ FROM    S_ITEM ITM                              ]'
        ||chr(13)||chr(10)||Q'[       ,(                                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  V01.COMP_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , V01.BRAND_CD                    ]'
        ||chr(13)||chr(10)||Q'[               , V01.BRAND_NM                    ]'
        ||chr(13)||chr(10)||Q'[               , V01.AGE_GRP                     ]'
        ||chr(13)||chr(10)||Q'[               , V01.L_CLASS_CD                  ]'
        ||chr(13)||chr(10)||Q'[               , V01.M_CLASS_CD                  ]'
        ||chr(13)||chr(10)||Q'[               , V01.S_CLASS_CD                  ]'
        ||chr(13)||chr(10)||Q'[               , V01.ITEM_CD                     ]'
        ||chr(13)||chr(10)||Q'[               , SUM(V01.SALE_QTY) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD) CLS_SUM_QTY]'
        ||chr(13)||chr(10)||Q'[               , SUM(V01.GRD_AMT ) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD) CLS_SUM_GRD]'
        ||chr(13)||chr(10)||Q'[               , SUM(V01.GRD_AMT ) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP ) AGE_SUM_GRD  ]'
        ||chr(13)||chr(10)||Q'[               , ROW_NUMBER()      OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD ORDER BY GRD_AMT DESC) R_NUM ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  /*+ LEADING(STO) */     ]'
        ||chr(13)||chr(10)||Q'[                         MMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_NM            ]'                                
        ||chr(13)||chr(10)||Q'[                       , GET_AGE_GROUP(MMS.COMP_CD, MMS.CUST_AGE) AS AGE_GRP ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.L_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.M_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.S_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(MMS.SALE_QTY) AS SALE_QTY]'
        ||chr(13)||chr(10)||Q'[                       , SUM(MMS.GRD_AMT ) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MMS  MMS         ]'
        ||chr(13)||chr(10)||Q'[                       , ITEM        ITM         ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE     STO         ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   MMS.COMP_CD  = STO.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.COMP_CD  = ITM.COMP_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.ITEM_CD  = ITM.ITEM_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.SALE_YM >= :PSV_STR_YM  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.SALE_YM <= :PSV_END_YM  ]'                
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_SEX IS NULL OR MMS.CUST_SEX = :PSV_CUST_SEX) ]'
        ||chr(13)||chr(10)||Q'[                 AND    (:PSV_CUST_LVL IS NULL OR MMS.CUST_LVL = :PSV_CUST_LVL) ]'
        ||chr(13)||chr(10)||Q'[                 GROUP BY                        ]'
        ||chr(13)||chr(10)||Q'[                         MMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_NM            ]'                                
        ||chr(13)||chr(10)||Q'[                       , GET_AGE_GROUP(MMS.COMP_CD, MMS.CUST_AGE)]'
        ||chr(13)||chr(10)||Q'[                       , ITM.L_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.M_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.S_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[                ) V01                            ]'
        ||chr(13)||chr(10)||Q'[         WHERE  (:PSV_CUST_AGE IS NULL OR V01.AGE_GRP = :PSV_CUST_AGE)]'
        ||chr(13)||chr(10)||Q'[        ) V02                                    ]'
        ||chr(13)||chr(10)||Q'[ WHERE   ITM.COMP_CD = V02.COMP_CD               ]'
        ||chr(13)||chr(10)||Q'[ AND     ITM.ITEM_CD = V02.ITEM_CD               ]'
        ||chr(13)||chr(10)||Q'[ AND     V02.R_NUM = 1                           ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY                                        ]'
        ||chr(13)||chr(10)||Q'[         V02.COMP_CD                             ]'
        ||chr(13)||chr(10)||Q'[       , V02.AGE_GRP                             ]'
        ||chr(13)||chr(10)||Q'[       , V02.S_CLASS_CD                          ]'
        ;

        --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR ls_sql 
            USING PSV_LANG_CD, PSV_STR_YM, PSV_END_YM, 
                  PSV_CUST_SEX, PSV_CUST_SEX, PSV_CUST_LVL, PSV_CUST_LVL,
                  PSV_CUST_AGE, PSV_CUST_AGE;

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

END PKG_MEAN2010;

/
