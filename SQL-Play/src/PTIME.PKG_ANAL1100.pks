CREATE OR REPLACE PACKAGE      PKG_ANAL1100 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ANAL1100
    --  Description      : 원가 시뮬레이션(메뉴)
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN_01        -- 표준원가
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_MAIN_02        -- 실행원가
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_MAIN_03        -- 가상원가
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PSV_RECIPE_VER  IN  VARCHAR2 ,                -- 레시피 기준 Version
        PSV_MENU_VER    IN  VARCHAR2 ,                -- 메뉴 기준 Version
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_ANAL1100;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ANAL1100 AS

    PROCEDURE SP_MAIN_01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN_01        원가 시뮬레이션(메뉴) - 표준원가
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-15         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN_01
            SYSDATE     :   2016-03-15
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   AS P_L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM   AS P_L_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   AS P_M_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM   AS P_M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   AS P_S_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM   AS P_S_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM      AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT                  AS P_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT - V1.P_ITEM_AMT  AS P_ITEM_PRO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V1.NET_AMT = 0 THEN 0 ELSE V1.P_ITEM_AMT / V1.NET_AMT * 100 END   AS P_PRO_PER    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1  ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  ICS.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.ITEM_CD         AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STD_QTY         AS P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STD_AMT         AS P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STD_COST        AS P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.NET_AMT                         ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ITEM_CHAIN_STD  ICS                 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         STR                 ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  ICS.COMP_CD     = STR.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.BRAND_CD    = STR.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.STOR_CD     = STR.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.COMP_CD     = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.CALC_YM     = :PSV_YM           ]'
        ||CHR(13)||CHR(10)||Q'[         )   V1      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_CD     ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_YM;

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
    
    PROCEDURE SP_MAIN_02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN_02        원가 시뮬레이션(메뉴) - 실행원가
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-15         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN_02
            SYSDATE     :   2016-03-15
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   AS P_L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM   AS P_L_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   AS P_M_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM   AS P_M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   AS P_S_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM   AS P_S_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM      AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT                  AS P_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT - V1.P_ITEM_AMT  AS P_ITEM_PRO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V1.NET_AMT = 0 THEN 0 ELSE V1.P_ITEM_AMT / V1.NET_AMT * 100 END   AS P_PRO_PER    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1  ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  ICS.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.ITEM_CD         AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.RUN_QTY         AS P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.RUN_AMT         AS P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.RUN_COST        AS P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.NET_AMT                         ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ITEM_CHAIN_STD  ICS                 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         STR                 ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  ICS.COMP_CD     = STR.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.BRAND_CD    = STR.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.STOR_CD     = STR.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.COMP_CD     = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.CALC_YM     = :PSV_YM           ]'
        ||CHR(13)||CHR(10)||Q'[         )   V1      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_CD     ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_YM;

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
    
    PROCEDURE SP_MAIN_03
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PSV_RECIPE_VER  IN  VARCHAR2 ,                -- 레시피 기준 Version
        PSV_MENU_VER    IN  VARCHAR2 ,                -- 메뉴 기준 Version
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN_03        원가 시뮬레이션(메뉴) - 가상원가
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-15         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN_03
            SYSDATE     :   2016-03-15
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   AS P_L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM   AS P_L_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   AS P_M_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM   AS P_M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   AS P_S_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM   AS P_S_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM      AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT                  AS P_NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.NET_AMT - V1.P_ITEM_AMT  AS P_ITEM_PRO   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V1.NET_AMT = 0 THEN 0 ELSE V1.P_ITEM_AMT / V1.NET_AMT * 100 END   AS P_PRO_PER    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1  ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  ICS.COMP_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.BRAND_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.BRAND_NM                        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.STOR_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.STOR_NM                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.ITEM_CD                 AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.RUN_QTY                 AS P_ITEM_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.RUN_QTY * VER.DO_COST   AS P_ITEM_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  VER.DO_COST                 AS P_ITEM_COST  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICS.NET_AMT                         ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ITEM_CHAIN_STD  ICS                 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         STR                 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                                   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_TP                 ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  P_ITEM_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(DO_COST)    AS DO_COST  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  TABLE(FN_ALAL1090F0(:PSV_COMP_CD, :PSV_YM, :PSV_RECIPE_VER, :PSV_MENU_VER)) ]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_TP                 ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  P_ITEM_CD               ]'
        ||CHR(13)||CHR(10)||Q'[                     )   VER                             ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  ICS.COMP_CD     = STR.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.BRAND_CD    = STR.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.STOR_CD     = STR.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STR.COMP_CD     = VER.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STR.BRAND_CD    = VER.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  STR.STOR_TP     = VER.STOR_TP       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.ITEM_CD     = VER.P_ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.COMP_CD     = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICS.CALC_YM     = :PSV_YM           ]'
        ||CHR(13)||CHR(10)||Q'[         )   V1      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.P_ITEM_CD    = C1.ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_CD     ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_YM, PSV_RECIPE_VER, PSV_MENU_VER, PSV_COMP_CD, PSV_YM;

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
    
END PKG_ANAL1100;

/
