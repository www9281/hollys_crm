--------------------------------------------------------
--  DDL for Package Body PKG_ORDR1360
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ORDR1360" AS

    PROCEDURE SP_TAB01    /* 매장별 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 기준 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 기준 종료일자
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자        
        PSV_L_CLASS_CD  IN  VARCHAR2 ,                -- 대분류
        PSV_M_CLASS_CD  IN  VARCHAR2 ,                -- 중분류
        PSV_S_CLASS_CD  IN  VARCHAR2 ,                -- 소분류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01        매장별
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-05         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-12-05
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT ]'
        ||CHR(13)||CHR(10)||Q'[         A1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A1.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A3.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A3.STOR_TP     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A3.STOR_TP_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A3.SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A1.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A3.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(REQ_CNT1  ) AS REQ_CNT1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CLOSE_CNT1) AS CLOSE_CNT1 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ROUND(NVL(CLOSE_CNT1 / DECODE(REQ_CNT1, 0, NULL, REQ_CNT1), 0) * 100 ,2) ) AS RATIO1     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_1  ) AS SATI_1_1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_2  ) AS SATI_1_2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_3  ) AS SATI_1_3   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_4  ) AS SATI_1_4   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_5  ) AS SATI_1_5   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(REQ_CNT2  ) AS REQ_CNT2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CLOSE_CNT2) AS CLOSE_CNT2 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ROUND(NVL(CLOSE_CNT2 / DECODE(REQ_CNT2, 0, NULL, REQ_CNT2), 0) * 100 ,2)   ) AS RATIO2     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_1  ) AS SATI_2_1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_2  ) AS SATI_2_2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_3  ) AS SATI_2_3   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_4  ) AS SATI_2_4   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_5  ) AS SATI_2_5   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM                                      ]'
        ||CHR(13)||CHR(10)||Q'[ (                                         ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  BRAND_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[          ,  STOR_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[          ,  COUNT(*)                                                         AS REQ_CNT1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN PROC_STAT = '4' THEN 1 ELSE 0 END)                 AS CLOSE_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '1' THEN 1 ELSE 0 END)                 AS SATI_1_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '2' THEN 1 ELSE 0 END)                 AS SATI_1_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '3' THEN 1 ELSE 0 END)                 AS SATI_1_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '4' THEN 1 ELSE 0 END)                 AS SATI_1_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '5' THEN 1 ELSE 0 END)                 AS SATI_1_5    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS REQ_CNT2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS CLOSE_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_5    ]'        
        ||CHR(13)||CHR(10)||Q'[     FROM  STORE_CLAIM                     ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE COMP_CD = :PSV_COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[     AND   USE_YN = 'Y'      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   CLAIM_DT BETWEEN :PSV_GFR_DATE     AND :PSV_GTO_DATE      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_L_CLASS_CD IS NULL OR L_CLASS_CD = :PSV_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_M_CLASS_CD IS NULL OR M_CLASS_CD = :PSV_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_S_CLASS_CD IS NULL OR S_CLASS_CD = :PSV_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP BY COMP_CD, BRAND_CD, STOR_CD                           ]'
        ||CHR(13)||CHR(10)||Q'[     UNION ALL                                                     ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  COMP_CD                                               ]'
        ||CHR(13)||CHR(10)||Q'[          ,  BRAND_CD                                              ]'
        ||CHR(13)||CHR(10)||Q'[          ,  STOR_CD                                               ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS REQ_CNT1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS CLOSE_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_5    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  COUNT(*)                                                         AS REQ_CNT2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN PROC_STAT = '4' THEN 1 ELSE 0 END)                 AS CLOSE_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '1' THEN 1 ELSE 0 END)                 AS SATI_2_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '2' THEN 1 ELSE 0 END)                 AS SATI_2_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '3' THEN 1 ELSE 0 END)                 AS SATI_2_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '4' THEN 1 ELSE 0 END)                 AS SATI_2_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '5' THEN 1 ELSE 0 END)                 AS SATI_2_5    ]'
        ||CHR(13)||CHR(10)||Q'[     FROM  STORE_CLAIM                     ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE COMP_CD = :PSV_COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[     AND   USE_YN = 'Y'      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   CLAIM_DT BETWEEN :PSV_DFR_DATE     AND :PSV_DTO_DATE      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_L_CLASS_CD IS NULL OR L_CLASS_CD = :PSV_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_M_CLASS_CD IS NULL OR M_CLASS_CD = :PSV_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_S_CLASS_CD IS NULL OR S_CLASS_CD = :PSV_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP BY COMP_CD, BRAND_CD, STOR_CD                           ]'
        ||CHR(13)||CHR(10)||Q'[ )   A1,  S_STORE A3              ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE 1 = 1                      ]'
        ||CHR(13)||CHR(10)||Q'[ AND A1.COMP_CD  = A3.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND A1.BRAND_CD = A3.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND A1.STOR_CD  = A3.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP BY A1.COMP_CD, A1.BRAND_CD, A3.BRAND_NM, A3.STOR_TP, A3.STOR_TP_NM, A3.SV_USER_NM, A1.STOR_CD, A3.STOR_NM    ]'
        ;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_L_CLASS_CD, PSV_L_CLASS_CD, PSV_M_CLASS_CD, PSV_M_CLASS_CD, PSV_S_CLASS_CD, PSV_S_CLASS_CD,
                         PSV_COMP_CD, PSV_DFR_DATE, PSV_DTO_DATE, PSV_L_CLASS_CD, PSV_L_CLASS_CD, PSV_M_CLASS_CD, PSV_M_CLASS_CD, PSV_S_CLASS_CD, PSV_S_CLASS_CD;

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

    PROCEDURE SP_TAB02    /* 클레임유형 */
    (  
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 기준 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 기준 종료일자
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자        
        PSV_L_CLASS_CD  IN  VARCHAR2 ,                -- 대분류
        PSV_M_CLASS_CD  IN  VARCHAR2 ,                -- 중분류
        PSV_S_CLASS_CD  IN  VARCHAR2 ,                -- 소분류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     클레임유형
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-05         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-12-05
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ]'
        ||CHR(13)||CHR(10)||Q'[         A1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A1.L_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A1.M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A1.S_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L.L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M.M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(REQ_CNT1  ) AS REQ_CNT1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CLOSE_CNT1) AS CLOSE_CNT1 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ROUND(NVL(CLOSE_CNT1 / DECODE(REQ_CNT1, 0, NULL, REQ_CNT1), 0)  * 100, 2) ) AS RATIO1     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_1  ) AS SATI_1_1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_2  ) AS SATI_1_2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_3  ) AS SATI_1_3   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_4  ) AS SATI_1_4   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_1_5  ) AS SATI_1_5   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(REQ_CNT2  ) AS REQ_CNT2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CLOSE_CNT2) AS CLOSE_CNT2 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ROUND(NVL(CLOSE_CNT2 / DECODE(REQ_CNT2, 0, NULL, REQ_CNT2), 0)  * 100, 2) ) AS RATIO2     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_1  ) AS SATI_2_1   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_2  ) AS SATI_2_2   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_3  ) AS SATI_2_3   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_4  ) AS SATI_2_4   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SATI_2_5  ) AS SATI_2_5   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM                                      ]'
        ||CHR(13)||CHR(10)||Q'[ (                                         ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  A1.COMP_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  L_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  S_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  COUNT(*)                                                         AS REQ_CNT1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN PROC_STAT = '4' THEN 1 ELSE 0 END)                 AS CLOSE_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '1' THEN 1 ELSE 0 END)                 AS SATI_1_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '2' THEN 1 ELSE 0 END)                 AS SATI_1_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '3' THEN 1 ELSE 0 END)                 AS SATI_1_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '4' THEN 1 ELSE 0 END)                 AS SATI_1_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '5' THEN 1 ELSE 0 END)                 AS SATI_1_5    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS REQ_CNT2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS CLOSE_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_2_5    ]'
        ||CHR(13)||CHR(10)||Q'[     FROM  STORE_CLAIM A1, S_STORE     A3                  ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE A1.COMP_CD     = :PSV_COMP_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.USE_YN      = 'Y'      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.COMP_CD  = A3.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.BRAND_CD = A3.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.STOR_CD  = A3.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   CLAIM_DT BETWEEN :PSV_GFR_DATE     AND :PSV_GTO_DATE       ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_L_CLASS_CD IS NULL OR L_CLASS_CD = :PSV_L_CLASS_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_M_CLASS_CD IS NULL OR M_CLASS_CD = :PSV_M_CLASS_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_S_CLASS_CD IS NULL OR S_CLASS_CD = :PSV_S_CLASS_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP BY A1.COMP_CD, L_CLASS_CD, M_CLASS_CD, S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[     UNION ALL                             ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT  A1.COMP_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  L_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  M_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  S_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS REQ_CNT1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS CLOSE_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  0                                                                AS SATI_1_5    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  COUNT(*)                                                         AS REQ_CNT2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN PROC_STAT = '4' THEN 1 ELSE 0 END)                 AS CLOSE_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '1' THEN 1 ELSE 0 END)                 AS SATI_2_1    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '2' THEN 1 ELSE 0 END)                 AS SATI_2_2    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '3' THEN 1 ELSE 0 END)                 AS SATI_2_3    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '4' THEN 1 ELSE 0 END)                 AS SATI_2_4    ]'
        ||CHR(13)||CHR(10)||Q'[          ,  SUM(CASE WHEN SATI_DIV  = '5' THEN 1 ELSE 0 END)                 AS SATI_2_5    ]'               
        ||CHR(13)||CHR(10)||Q'[     FROM  STORE_CLAIM A1, S_STORE     A3                  ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE A1.COMP_CD     = :PSV_COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.USE_YN      = 'Y'      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.COMP_CD  = A3.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.BRAND_CD = A3.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[     AND   A1.STOR_CD  = A3.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND   CLAIM_DT BETWEEN :PSV_DFR_DATE     AND :PSV_DTO_DATE      ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_L_CLASS_CD IS NULL OR L_CLASS_CD = :PSV_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_M_CLASS_CD IS NULL OR M_CLASS_CD = :PSV_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     AND   (:PSV_S_CLASS_CD IS NULL OR S_CLASS_CD = :PSV_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP BY A1.COMP_CD, L_CLASS_CD, M_CLASS_CD, S_CLASS_CD         ]'
        ||CHR(13)||CHR(10)||Q'[ ) A1 ,          ]'
        ||CHR(13)||CHR(10)||Q'[       (                                                             ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT                                                     ]'
        ||CHR(13)||CHR(10)||Q'[                LC.COMP_CD                                           ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.L_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,NVL(L.LANG_NM, LC.L_CLASS_NM)   AS L_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          FROM  CLAIM_L_CLASS   LC                                   ]'
        ||CHR(13)||CHR(10)||Q'[             ,  LANG_TABLE      L                                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE  L.COMP_CD(+)    = LC.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.PK_COL(+)     = LPAD(LC.L_CLASS_CD, 3, ' ')        ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.COMP_CD      = :PSV_COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.USE_YN       = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.TABLE_NM(+)   = 'CLAIM_L_CLASS'                    ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.COL_NM(+)     = 'L_CLASS_NM'                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.USE_YN(+)     = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[      ) L                                                            ]'
        ||CHR(13)||CHR(10)||Q'[      ,(                                                             ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT                                                     ]'
        ||CHR(13)||CHR(10)||Q'[                 LC.COMP_CD                                           ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.L_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.M_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,NVL(L.LANG_NM, LC.M_CLASS_NM)   AS M_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          FROM  CLAIM_M_CLASS   LC                                   ]'
        ||CHR(13)||CHR(10)||Q'[             ,  LANG_TABLE      L                                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE  L.COMP_CD(+)    = LC.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.PK_COL(+)     = LPAD(LC.M_CLASS_CD, 3, ' ')        ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.COMP_CD      = :PSV_COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.USE_YN       = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.TABLE_NM(+)   = 'CLAIM_M_CLASS'                    ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.COL_NM(+)     = 'M_CLASS_NM'                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.USE_YN(+)     = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[      ) M                                                            ]'
        ||CHR(13)||CHR(10)||Q'[      ,(                                                             ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT                                                     ]'
        ||CHR(13)||CHR(10)||Q'[                 LC.COMP_CD                                           ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.L_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.M_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,LC.S_CLASS_CD                                        ]'
        ||CHR(13)||CHR(10)||Q'[                ,NVL(L.LANG_NM, LC.S_CLASS_NM)   AS S_CLASS_NM        ]'
        ||CHR(13)||CHR(10)||Q'[          FROM  CLAIM_S_CLASS   LC                                   ]'
        ||CHR(13)||CHR(10)||Q'[             ,  LANG_TABLE      L                                    ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE  L.COMP_CD(+)    = LC.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.PK_COL(+)     = LPAD(LC.S_CLASS_CD, 3, ' ')        ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.COMP_CD      = :PSV_COMP_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  LC.USE_YN       = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.TABLE_NM(+)   = 'CLAIM_S_CLASS'                    ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.COL_NM(+)     = 'S_CLASS_NM'                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[           AND  L.USE_YN(+)     = 'Y'                                ]'
        ||CHR(13)||CHR(10)||Q'[      ) S                                                            ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE A1.COMP_CD     = L.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.COMP_CD     = M.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.COMP_CD     = S.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.L_CLASS_CD = L.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.L_CLASS_CD = M.L_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.M_CLASS_CD = M.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.L_CLASS_CD = S.L_CLASS_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.M_CLASS_CD = S.M_CLASS_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ AND   A1.S_CLASS_CD = S.S_CLASS_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP BY A1.COMP_CD , A1.L_CLASS_CD, L.L_CLASS_NM, A1.M_CLASS_CD, M.M_CLASS_NM , A1.S_CLASS_CD, S.S_CLASS_NM       ]'
        ;

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_L_CLASS_CD, PSV_L_CLASS_CD, PSV_M_CLASS_CD, PSV_M_CLASS_CD, PSV_S_CLASS_CD, PSV_S_CLASS_CD,
                         PSV_COMP_CD, PSV_DFR_DATE, PSV_DTO_DATE, PSV_L_CLASS_CD, PSV_L_CLASS_CD, PSV_M_CLASS_CD, PSV_M_CLASS_CD, PSV_S_CLASS_CD, PSV_S_CLASS_CD,
                         PSV_COMP_CD, PSV_LANG_CD,  PSV_COMP_CD, PSV_LANG_CD,     PSV_COMP_CD, PSV_LANG_CD 
                         ;

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

END PKG_ORDR1360;

/
