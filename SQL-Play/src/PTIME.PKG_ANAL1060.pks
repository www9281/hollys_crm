CREATE OR REPLACE PACKAGE      PKG_ANAL1060 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ANAL1060
    --  Description      : 사용자재실적
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_ANAL1060;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ANAL1060 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YM          IN  VARCHAR2 ,                -- 조회 년월
        PSV_ITEM_TXT    IN  VARCHAR2 ,                -- 상품코드/명
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN          사용자재실적
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
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
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_CD   AS C_L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_NM   AS C_L_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_CD   AS C_M_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_NM   AS C_M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_CD   AS C_S_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_NM   AS C_S_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_ITEM_CD    AS C_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.ITEM_NM      AS C_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.DO_UNIT_NM   AS C_ITEM_UNIT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_CD   AS P_L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.L_CLASS_NM   AS P_L_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_CD   AS P_M_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.M_CLASS_NM   AS P_M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_CD   AS P_S_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.S_CLASS_NM   AS P_S_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.P_ITEM_CD    AS P_ITEM_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C1.ITEM_NM      AS P_ITEM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_QTY_M0 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_AMT_M0 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_COST_M0]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_QTY_M1 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_AMT_M1 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_COST_M1]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_QTY_M2 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_AMT_M2 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_COST_M2]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_QTY_M3 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_AMT_M3 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_COST_M3]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_QTY_TT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_RUN_AMT_TT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V1.C_RUN_QTY_TT = 0 THEN 0 ELSE V1.C_RUN_AMT_TT / V1.C_RUN_QTY_TT END     AS C_RUN_COST_TT    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  S_ITEM      C1  ]'  -- 상품
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      C2  ]'  -- 원자재
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  STR.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STR.BRAND_NM)   AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(STR.STOR_NM)    AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.C_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.P_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -0), 'YYYYMM') THEN ICR.RUN_QTY  ELSE 0 END) AS C_RUN_QTY_M0 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -0), 'YYYYMM') THEN ICR.RUN_AMT  ELSE 0 END) AS C_RUN_AMT_M0 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  AVG(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -0), 'YYYYMM') THEN ICR.RUN_COST ELSE 0 END) AS C_RUN_COST_M0]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN ICR.RUN_QTY  ELSE 0 END) AS C_RUN_QTY_M1 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN ICR.RUN_AMT  ELSE 0 END) AS C_RUN_AMT_M1 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  AVG(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -1), 'YYYYMM') THEN ICR.RUN_COST ELSE 0 END) AS C_RUN_COST_M1]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -2), 'YYYYMM') THEN ICR.RUN_QTY  ELSE 0 END) AS C_RUN_QTY_M2 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -2), 'YYYYMM') THEN ICR.RUN_AMT  ELSE 0 END) AS C_RUN_AMT_M2 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  AVG(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -2), 'YYYYMM') THEN ICR.RUN_COST ELSE 0 END) AS C_RUN_COST_M2]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -3), 'YYYYMM') THEN ICR.RUN_QTY  ELSE 0 END) AS C_RUN_QTY_M3 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -3), 'YYYYMM') THEN ICR.RUN_AMT  ELSE 0 END) AS C_RUN_AMT_M3 ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  AVG(CASE WHEN ICR.CALC_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -3), 'YYYYMM') THEN ICR.RUN_COST ELSE 0 END) AS C_RUN_COST_M3]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.RUN_QTY)    AS C_RUN_QTY_TT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(ICR.RUN_AMT)    AS C_RUN_AMT_TT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  ITEM_CHAIN_RCP  ICR             ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE         STR             ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  ICR.COMP_CD     = STR.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICR.BRAND_CD    = STR.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICR.STOR_CD     = STR.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICR.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ICR.CALC_YM     BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -3), 'YYYYMMDD') AND :PSV_YM ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (ICR.RUN_QTY <> 0 OR ICR.RUN_AMT <> 0)  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY STR.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.BRAND_CD    ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  STR.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.C_ITEM_CD   ]'    
        ||CHR(13)||CHR(10)||Q'[                  ,  ICR.P_ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         )   V1      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  V1.COMP_CD      = C1.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.P_ITEM_CD    = C1.ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.COMP_CD      = C2.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  V1.C_ITEM_CD    = C2.ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (V1.C_ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR C2.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.BRAND_CD     ]'    
        ||CHR(13)||CHR(10)||Q'[      ,  V1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C2.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V1.C_ITEM_CD    ]'
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
            ls_sql USING PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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
    
END PKG_ANAL1060;

/
