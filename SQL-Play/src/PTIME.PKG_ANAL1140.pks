CREATE OR REPLACE PACKAGE      PKG_ANAL1140 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ANAL1140
    --  Description      : 손익시뮬레이션
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
        PSV_YEAR        IN  VARCHAR2 ,                -- 조회년도
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_ANAL1140;

/

CREATE OR REPLACE PACKAGE BODY      PKG_ANAL1140 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YEAR        IN  VARCHAR2 ,                -- 조회년도
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN         손익시뮬레이션
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
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ACC_CD  ]'
        ||CHR(13)||CHR(10)|| '       ,  ''[''||ACC_CD||'']''||ACC_NM    AS ACC_NM   '
        ||CHR(13)||CHR(10)||Q'[      ,  ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[      ,  R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M01_LY) AS ACC_GRD_M01_LY, SUM(M01_PL) AS ACC_GRD_M01_PL, SUM(M01_PS) AS ACC_GRD_M01_PS, SUM(M01_RS) AS ACC_GRD_M01_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M02_LY) AS ACC_GRD_M02_LY, SUM(M02_PL) AS ACC_GRD_M02_PL, SUM(M02_PS) AS ACC_GRD_M02_PS, SUM(M02_RS) AS ACC_GRD_M02_RS   ]'      
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M03_LY) AS ACC_GRD_M03_LY, SUM(M03_PL) AS ACC_GRD_M03_PL, SUM(M03_PS) AS ACC_GRD_M03_PS, SUM(M03_RS) AS ACC_GRD_M03_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M04_LY) AS ACC_GRD_M04_LY, SUM(M04_PL) AS ACC_GRD_M04_PL, SUM(M04_PS) AS ACC_GRD_M04_PS, SUM(M04_RS) AS ACC_GRD_M04_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M05_LY) AS ACC_GRD_M05_LY, SUM(M05_PL) AS ACC_GRD_M05_PL, SUM(M05_PS) AS ACC_GRD_M05_PS, SUM(M05_RS) AS ACC_GRD_M05_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M06_LY) AS ACC_GRD_M06_LY, SUM(M06_PL) AS ACC_GRD_M06_PL, SUM(M06_PS) AS ACC_GRD_M06_PS, SUM(M06_RS) AS ACC_GRD_M06_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M07_LY) AS ACC_GRD_M07_LY, SUM(M07_PL) AS ACC_GRD_M07_PL, SUM(M07_PS) AS ACC_GRD_M07_PS, SUM(M07_RS) AS ACC_GRD_M07_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M08_LY) AS ACC_GRD_M08_LY, SUM(M08_PL) AS ACC_GRD_M08_PL, SUM(M08_PS) AS ACC_GRD_M08_PS, SUM(M08_RS) AS ACC_GRD_M08_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M09_LY) AS ACC_GRD_M09_LY, SUM(M09_PL) AS ACC_GRD_M09_PL, SUM(M09_PS) AS ACC_GRD_M09_PS, SUM(M09_RS) AS ACC_GRD_M09_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M10_LY) AS ACC_GRD_M10_LY, SUM(M10_PL) AS ACC_GRD_M10_PL, SUM(M10_PS) AS ACC_GRD_M10_PS, SUM(M10_RS) AS ACC_GRD_M10_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M11_LY) AS ACC_GRD_M11_LY, SUM(M11_PL) AS ACC_GRD_M11_PL, SUM(M11_PS) AS ACC_GRD_M11_PS, SUM(M11_RS) AS ACC_GRD_M11_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(M12_LY) AS ACC_GRD_M12_LY, SUM(M12_PL) AS ACC_GRD_M12_PL, SUM(M12_PS) AS ACC_GRD_M12_PS, SUM(M12_RS) AS ACC_GRD_M12_RS   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(TOT_LY) AS ACC_GRD_TOT_LY, SUM(TOT_PL) AS ACC_GRD_TOT_PL, SUM(TOT_PS) AS ACC_GRD_TOT_PS, SUM(TOT_RS) AS ACC_GRD_TOT_RS   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -11), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M01_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M01_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M01_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M01_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -10), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M02_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M02_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M02_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M02_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -9), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M03_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M03_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M03_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M03_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -8), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M04_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M04_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M04_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M04_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -7), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M05_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M05_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M05_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M05_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -6), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M06_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M06_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M06_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M06_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -5), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M07_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M07_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M07_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M07_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -4), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M08_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M08_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M08_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M08_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -3), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M09_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M09_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M09_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M09_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -2), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M10_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M10_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M10_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M10_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -1), 'YYYYMM') THEN G_SUM  ELSE 0 END) AS M11_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M11_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M11_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M11_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),   0), 'YYYYMM') THEN G_SUM  ELSE 0 END) AS M12_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M12_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M12_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN G_SUM ELSE 0 END) AS M12_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM LIKE TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYY')||'%' THEN G_SUM ELSE 0 END) AS TOT_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN G_SUM ELSE 0 END) AS TOT_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN G_SUM ELSE 0 END) AS TOT_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN G_SUM ELSE 0 END) AS TOT_RS]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PGD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.G_SUM   ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_GOAL_DD  PGD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD     = PGD.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD    = PGD.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD     = PGD.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_YM     BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -11), 'YYYYMM') AND :PSV_YEAR||'12']'
        ||CHR(13)||CHR(10)||Q'[                     )   PGD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                 PAM.COMP_CD     ]'      
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.TERM_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROWNUM  AS R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                          START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                        CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                     )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  PAM.COMP_CD = PGD.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PAM.ACC_CD  = PGD.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -11), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M01_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M01_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M01_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -11), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M01_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -10), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M02_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M02_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M02_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -10), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M02_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -9), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M03_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M03_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M03_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -9), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M03_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -8), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M04_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M04_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M04_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -8), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M04_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -7), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M05_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M05_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M05_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -7), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M05_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -6), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M06_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M06_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M06_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -6), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M06_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -5), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M07_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M07_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M07_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -5), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M07_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -4), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M08_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M08_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M08_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -4), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M08_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -3), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M09_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M09_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M09_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -3), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M09_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -2), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M10_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M10_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M10_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -2), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M10_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),  -1), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M11_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M11_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M11_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),  -1), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M11_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'),   0), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M12_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M12_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M12_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'),   0), 'YYYYMM') THEN GOAL_AMT ELSE 0 END) AS M12_RS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM LIKE TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYY')||'%' THEN GOAL_AMT ELSE 0 END) AS TOT_LY]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '1' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN GOAL_AMT ELSE 0 END) AS TOT_PL]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '2' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN GOAL_AMT ELSE 0 END) AS TOT_PS]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN GOAL_DIV = '3' AND GOAL_YM LIKE :PSV_YEAR||'%' THEN GOAL_AMT ELSE 0 END) AS TOT_RS]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PGY.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_AMT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_GOAL_YM  PGY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD     = PGY.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD    = PGY.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD     = PGY.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGY.GOAL_YM     BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YEAR||'12', 'YYYYMM'), -12), 'YYYYMM'), 'YYYYMM'), -11), 'YYYYMM') AND :PSV_YEAR||'12']'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGY.COST_DIV    = '3'   ]'
        ||CHR(13)||CHR(10)||Q'[                     )   PGY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                 PAM.COMP_CD     ]'      
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.TERM_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROWNUM  AS R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                          START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                        CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                     )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  PAM.COMP_CD = PGY.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[                AND  PAM.ACC_CD  = PGY.ACC_CD (+)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[         )   D01 ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY D01.ACC_CD, D01.ACC_NM, D01.ACC_LVL, D01.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY D01.R_NUM    ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_COMP_CD, PSV_YEAR, PSV_YEAR, PSV_COMP_CD
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_YEAR, PSV_YEAR, PSV_YEAR, PSV_YEAR
                       , PSV_COMP_CD, PSV_YEAR, PSV_YEAR, PSV_COMP_CD;

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
    
END PKG_ANAL1140;

/
