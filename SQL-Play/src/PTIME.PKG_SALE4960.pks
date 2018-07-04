CREATE OR REPLACE PACKAGE       PKG_SALE4960 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4960
    --  Description      : 상품별 전년/전월대비 매출 
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
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
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
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
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
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB06
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB07
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE4960;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4960 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    상품별 전년/전월대비 매출(영업조직)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    상품별 전년/전월대비 매출(부서)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03    상품별 전년/전월대비 매출(팀)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04    상품별 전년/전월대비 매출(영업담당자)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_ID          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;
              
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
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05    상품별 전년/전월대비 매출(점포)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_ID      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.DEPT_NM)      AS DEPT_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.TEAM_NM)      AS TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.DEPT_CD, S.TEAM_CD, S.SV_USER_ID, SJ.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DEPT_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TEAM_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_ID          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
    PROCEDURE SP_TAB06
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB06    상품별 전년/전월대비 매출(지역)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB06
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  REGION_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  REGION_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.REGION_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.REGION_NM)    AS REGION_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.REGION_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  REGION_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
    PROCEDURE SP_TAB07
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회년월
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB07    상품별 전년/전월대비 매출(상권)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB07
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TRAD_AREA       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TRAD_AREA_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PM_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PM_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PM_QTY) / PM_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PM_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PM_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PM_AMT) / PM_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PM_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PY_AMT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_QTY = 0 AND PY_QTY = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_QTY = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_QTY - PY_QTY) / PY_QTY * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_QTY_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CM_AMT = 0 AND PY_AMT = 0 THEN 0      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN PY_AMT = 0                THEN 100    ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND((CM_AMT - PY_AMT) / PY_AMT * 100, 2)    ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS PY_AMT_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.TRAD_AREA     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.TRAD_AREA_NM) AS TRAD_AREA_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN SJ.SALE_QTY ELSE 0 END)  AS CM_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = :PSV_YM THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END) AS CM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)   AS PM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)   AS PM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN SJ.SALE_QTY ELSE 0 END)  AS PY_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SJ.SALE_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT) ELSE 0 END)  AS PY_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_YM  IN (:PSV_YM, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM'), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM')) ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, S.TRAD_AREA ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[         )                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TRAD_AREA           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  L_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_SORT_ORDER        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_YM, PSV_YM, PSV_FILTER, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_YM
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

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
    
END PKG_SALE4960;

/
