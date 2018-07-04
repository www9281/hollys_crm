CREATE OR REPLACE PACKAGE       PKG_MEPA1060 AS
/******************************************************************************
   NAME:       PKG_MEPA1060
   PURPOSE:    월별 포인트 적립현황   

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2016-03-25      KKJ       1. Created this package.
******************************************************************************/

    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_GFR_YM      IN  VARCHAR2 ,                -- 조회시작일자
    PSV_GTO_YM      IN  VARCHAR2 ,                -- 조회종료일자
    PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   );
   
END PKG_MEPA1060;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEPA1060 AS

    PROCEDURE SP_TAB01
   ( 
    PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_GFR_YM      IN  VARCHAR2 ,                -- 조회시작일자
    PSV_GTO_YM      IN  VARCHAR2 ,                -- 조회종료일자
    PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      월별 포인트 적립현황 
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-24         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-03-24
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    
    ls_sql_cm       VARCHAR2(1000) ;    -- 공통코드SQL
    
    ERR_HANDLER         EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01725') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SEQ_NO                      ]'
        ||CHR(13)||CHR(10)||Q'[       , USE_YM                      ]'
        ||CHR(13)||CHR(10)||Q'[       , SAV_PT                      ]'
        ||CHR(13)||CHR(10)||Q'[       , USE_PT                      ]'
        ||CHR(13)||CHR(10)||Q'[       , LOS_PT                      ]'
        ||CHR(13)||CHR(10)||Q'[       , SUM(REM_PT) OVER(ORDER BY SEQ_NO) REM_PT]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (                            ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V01.SEQ_NO          ]'
        ||CHR(13)||CHR(10)||Q'[               , V01.USE_YM          ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(V01.SAV_PT) AS SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(V01.USE_PT) AS USE_PT   ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(V01.LOS_PT) AS LOS_PT   ]'
        ||CHR(13)||CHR(10)||Q'[               , SUM(V01.REM_PT) AS REM_PT   ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE STO         ]'
        ||CHR(13)||CHR(10)||Q'[               ,(                    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  /*+ INDEX(HIS IDX02_C_CARD_SAV_HIS) */              ]'
        ||CHR(13)||CHR(10)||Q'[                         0                                       AS SEQ_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                       , FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'LAST_MONTH_REM') AS USE_YM]'
        ||CHR(13)||CHR(10)||Q'[                       , HIS.COMP_CD                             AS COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.BRAND_CD, CRD.BRAND_CD)         AS BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.STOR_CD , CRD.STOR_CD )         AS STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0                                       AS SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0                                       AS USE_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , 0                                       AS LOS_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT), 0) AS REM_PT]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CARD_SAV_HIS HIS              ]'
        ||CHR(13)||CHR(10)||Q'[                       , C_CARD         CRD              ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   HIS.COMP_CD   = CRD.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.CARD_ID   = CRD.CARD_ID     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.COMP_CD   = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.USE_DT    < :PSV_GFR_YM||'01']'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.LOS_PT_YN = 'N'             ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.USE_YN    = 'Y'             ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                         HIS.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.BRAND_CD, CRD.BRAND_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.STOR_CD , CRD.STOR_CD ) ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                               ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  /*+ INDEX(HIS IDX02_C_CARD_SAV_HIS) */  ]'
        ||CHR(13)||CHR(10)||Q'[                         TO_NUMBER(SUBSTR(HIS.USE_DT ,1 ,6))     AS SEQ_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUBSTR(HIS.USE_DT ,1 ,6)                AS USE_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                       , HIS.COMP_CD                             AS COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.BRAND_CD, CRD.BRAND_CD)         AS BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.STOR_CD , CRD.STOR_CD )         AS STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(HIS.SAV_PT)                         AS SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(HIS.USE_PT)                         AS USE_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(HIS.LOS_PT)                         AS LOS_PT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT) AS REM_PT ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    C_CARD_SAV_HIS HIS              ]'
        ||CHR(13)||CHR(10)||Q'[                       , C_CARD         CRD              ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   HIS.COMP_CD   = CRD.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.CARD_ID   = CRD.CARD_ID     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.COMP_CD   = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.USE_DT   >= :PSV_GFR_YM||'01']'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.USE_DT   <= :PSV_GTO_YM||'31']'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.LOS_PT_YN = 'N'             ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HIS.USE_YN    = 'Y'             ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                         SUBSTR(HIS.USE_DT, 1 ,6)        ]'
        ||CHR(13)||CHR(10)||Q'[                       , HIS.COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.BRAND_CD, CRD.BRAND_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                       , NVL(HIS.STOR_CD , CRD.STOR_CD ) ]'
        ||CHR(13)||CHR(10)||Q'[            ) V01                                ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   STO.COMP_CD  = V01.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     STO.BRAND_CD = V01.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     STO.STOR_CD  = V01.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                ]'
        ||CHR(13)||CHR(10)||Q'[                 V01.SEQ_NO                      ]'
        ||CHR(13)||CHR(10)||Q'[               , V01.USE_YM                      ]'
        ||CHR(13)||CHR(10)||Q'[        )                                        ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SEQ_NO                                  ]'
        ;
        
        ls_sql := ''||CHR(13)||CHR(10)|| ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_YM,  
                          PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM; 
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
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
    
END PKG_MEPA1060;

/
