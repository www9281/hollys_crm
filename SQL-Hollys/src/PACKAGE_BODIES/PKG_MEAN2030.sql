--------------------------------------------------------
--  DDL for Package Body PKG_MEAN2030
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEAN2030" AS

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
    PSV_RANK_STR    IN  VARCHAR2 ,                -- 순위시작
    PSV_RANK_END    IN  VARCHAR2 ,                -- 순위종료
    PSV_CUST_AGE    IN  VARCHAR2 ,                -- 연령대
    PSV_CUST_LVL    IN  VARCHAR2 ,                -- 회원등급
    PSV_CUST_SEX    IN  VARCHAR2 ,                -- 성별  
    PSV_SORT_DIV    IN  VARCHAR2 ,                -- 정렬기준
    PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   ) IS
    /******************************************************************************
   NAME:       PKG_MEAN2030.SP_TAB01       연령대별 선호상품 분석 
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     PKG_MEAN2030.SP_TAB01
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
        ls_sql_main :=      Q'[ SELECT  V02.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[       , V02.BRAND_CD            ]'                
        ||chr(13)||chr(10)||Q'[       , V02.BRAND_NM            ]'       
        ||chr(13)||chr(10)||Q'[       , V02.AGE_GRP             ]'
        ||chr(13)||chr(10)||Q'[       , GET_COMMON_CODE_NM(V02.COMP_CD, '01760', V02.AGE_GRP, :PSV_LANG_CD)  AS AGE_GRP_NM  ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN :PSV_SORT_DIV = '01' THEN RANK_OF_QTY ELSE RANK_OF_AMT END AS RANK        ]'                  
        ||chr(13)||chr(10)||Q'[       , V02.L_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[       , V02.M_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[       , V02.S_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[       , V02.L_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[       , V02.M_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[       , V02.S_CLASS_NM          ]'                                                                 
        ||chr(13)||chr(10)||Q'[       , V02.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[       , V02.ITEM_NM             ]'
        ||chr(13)||chr(10)||Q'[       , V02.ITM_SUM_QTY         ]'
        ||chr(13)||chr(10)||Q'[       , V02.ITM_SUM_GRD         ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN V02.AGE_SUM_GRD = 0 THEN 0 ELSE V02.ITM_SUM_GRD / V02.AGE_SUM_GRD  * 100 END AS GRD_RATE ]'
        ||chr(13)||chr(10)||Q'[ FROM   (                        ]'
        ||chr(13)||chr(10)||Q'[         SELECT  V01.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[               , V01.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[               , V01.BRAND_NM    ]'                      
        ||chr(13)||chr(10)||Q'[               , V01.AGE_GRP     ]'      
        ||chr(13)||chr(10)||Q'[               , V01.L_CLASS_CD  ]'
        ||chr(13)||chr(10)||Q'[               , V01.M_CLASS_CD  ]'                
        ||chr(13)||chr(10)||Q'[               , V01.S_CLASS_CD  ]'              
        ||chr(13)||chr(10)||Q'[               , V01.L_CLASS_NM  ]'
        ||chr(13)||chr(10)||Q'[               , V01.M_CLASS_NM  ]'                
        ||chr(13)||chr(10)||Q'[               , V01.S_CLASS_NM  ]'                                                              
        ||chr(13)||chr(10)||Q'[               , V01.ITEM_CD     ]'
        ||chr(13)||chr(10)||Q'[               , V01.ITEM_NM     ]'
        ||chr(13)||chr(10)||Q'[               , V01.SALE_QTY    AS ITM_SUM_QTY  ]'
        ||chr(13)||chr(10)||Q'[               , V01.GRD_AMT     AS ITM_SUM_GRD  ]'
        ||chr(13)||chr(10)||Q'[               , SUM(V01.GRD_AMT) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP                       ) AGE_SUM_GRD ]'
        ||chr(13)||chr(10)||Q'[               , ROW_NUMBER()     OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP ORDER BY SALE_QTY DESC) RANK_OF_QTY ]'
        ||chr(13)||chr(10)||Q'[               , ROW_NUMBER()     OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.AGE_GRP ORDER BY GRD_AMT  DESC) RANK_OF_AMT ]'
        ||chr(13)||chr(10)||Q'[         FROM   (                                ]'
        ||chr(13)||chr(10)||Q'[                 SELECT  /*+ LEADING(STO) INDEX(MMS IDX02_C_CUST_MMS) */     ]'
        ||chr(13)||chr(10)||Q'[                         MMS.COMP_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_CD            ]'
        ||chr(13)||chr(10)||Q'[                       , STO.BRAND_NM            ]'                    
        ||chr(13)||chr(10)||Q'[                       , GET_AGE_GROUP(MMS.COMP_CD, MMS.CUST_AGE) AS AGE_GRP ]'                         
        ||chr(13)||chr(10)||Q'[                       , ITM.L_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.M_CLASS_CD          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.S_CLASS_CD          ]'                                                                
        ||chr(13)||chr(10)||Q'[                       , ITM.L_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.M_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.S_CLASS_NM          ]'                      
        ||chr(13)||chr(10)||Q'[                       , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.ITEM_NM             ]'
        ||chr(13)||chr(10)||Q'[                       , SUM(MMS.SALE_QTY) AS SALE_QTY]'
        ||chr(13)||chr(10)||Q'[                       , SUM(MMS.GRD_AMT ) AS GRD_AMT ]'
        ||chr(13)||chr(10)||Q'[                 FROM    C_CUST_MMS  MMS         ]'
        ||chr(13)||chr(10)||Q'[                       , S_ITEM      ITM         ]'
        ||chr(13)||chr(10)||Q'[                       , S_STORE     STO         ]'
        ||chr(13)||chr(10)||Q'[                 WHERE   MMS.COMP_CD  = STO.COMP_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.BRAND_CD = STO.BRAND_CD ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.STOR_CD  = STO.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                 AND     MMS.COMP_CD  = ITM.COMP_CD  ]'
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
        ||chr(13)||chr(10)||Q'[                       , ITM.L_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.M_CLASS_NM          ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.S_CLASS_NM          ]'                                      
        ||chr(13)||chr(10)||Q'[                       , MMS.ITEM_CD             ]'
        ||chr(13)||chr(10)||Q'[                       , ITM.ITEM_NM             ]'
        ||chr(13)||chr(10)||Q'[                ) V01                            ]'
        ||chr(13)||chr(10)||Q'[         WHERE :PSV_CUST_AGE IS NULL OR V01.AGE_GRP = :PSV_CUST_AGE ]'
        ||chr(13)||chr(10)||Q'[        ) V02                                    ]'
        ||chr(13)||chr(10)||Q'[ WHERE   1 = (CASE WHEN :PSV_SORT_DIV = '01' AND V02.RANK_OF_QTY BETWEEN :PSV_RANK_STR AND :PSV_RANK_END THEN 1 ELSE 0 END) ]'
        ||chr(13)||chr(10)||Q'[ OR      1 = (CASE WHEN :PSV_SORT_DIV = '02' AND V02.RANK_OF_AMT BETWEEN :PSV_RANK_STR AND :PSV_RANK_END THEN 1 ELSE 0 END) ]'
        ||chr(13)||chr(10)||Q'[ ORDER BY                ]'
        ||chr(13)||chr(10)||Q'[         V02.COMP_CD     ]'
        ||chr(13)||chr(10)||Q'[       , V02.BRAND_CD    ]'
        ||chr(13)||chr(10)||Q'[       , V02.AGE_GRP     ]'
        ||chr(13)||chr(10)||Q'[       , CASE WHEN :PSV_SORT_DIV = '01' THEN RANK_OF_QTY ELSE RANK_OF_AMT END ]'
        ;

        --dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR ls_sql 
            USING PSV_LANG_CD, PSV_SORT_DIV, PSV_STR_YM, PSV_END_YM, 
                  PSV_CUST_SEX, PSV_CUST_SEX, PSV_CUST_LVL, PSV_CUST_LVL, PSV_CUST_AGE, PSV_CUST_AGE, 
                  PSV_SORT_DIV, PSV_RANK_STR, PSV_RANK_END,
                  PSV_SORT_DIV, PSV_RANK_STR, PSV_RANK_END, PSV_SORT_DIV;

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

END PKG_MEAN2030;

/
