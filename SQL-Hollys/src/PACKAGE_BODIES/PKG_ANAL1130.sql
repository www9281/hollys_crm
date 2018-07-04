--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1130
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1130" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN         손익추이분석
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  D01.ACC_CD      ]'
        ||CHR(13)||CHR(10)|| '       ,  ''[''||D01.ACC_CD||'']''||D01.ACC_NM    AS ACC_NM   '
        ||CHR(13)||CHR(10)||Q'[      ,  D01.ACC_LVL     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D01.R_NUM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M01)    AS ACC_GRD_M01  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M02)    AS ACC_GRD_M02  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M03)    AS ACC_GRD_M03  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M04)    AS ACC_GRD_M04  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M05)    AS ACC_GRD_M05  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M06)    AS ACC_GRD_M06  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M07)    AS ACC_GRD_M07  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M08)    AS ACC_GRD_M08  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M09)    AS ACC_GRD_M09  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M10)    AS ACC_GRD_M10  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M11)    AS ACC_GRD_M11  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_M12)    AS ACC_GRD_M12  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ACC_GRD_TOT)    AS ACC_GRD_TOT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -11), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M01  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -10), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M02  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -09), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M03  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -08), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M04  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -07), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M05  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -06), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M06  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -05), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M07  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -04), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M08  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -03), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M09  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -02), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M10  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -01), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M11  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -00), 'YYYYMM') THEN PGD.G_SUM ELSE 0 END)   AS ACC_GRD_M12  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(PGD.G_SUM)  AS ACC_GRD_TOT  ]'
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
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_YM     BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -11), 'YYYYMM') AND :PSV_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_DIV    = '3'           ]'
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
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_ACC_MST PAM  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                          START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                        CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                     )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  PAM.COMP_CD = PGD.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PAM.ACC_CD  = PGD.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -11), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M01  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -10), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M02  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -09), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M03  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -08), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M04  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -07), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M05  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -06), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M06  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -05), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M07  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -04), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M08  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -03), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M09  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -02), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M10  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -01), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M11  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -00), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)    AS ACC_GRD_M12  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(PGY.GOAL_AMT)   AS ACC_GRD_TOT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PGD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_AMT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_GOAL_YM  PGD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD     = PGD.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD    = PGD.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD     = PGD.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_YM     BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -11), 'YYYYMM') AND :PSV_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_DIV    = '3'           ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.COST_DIV    = '3'           ]'
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
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_ACC_MST PAM  ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                          START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                        CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                          ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                     )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  PAM.COMP_CD = PGY.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  PAM.ACC_CD  = PGY.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[         )   D01 ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY D01.ACC_CD, D01.ACC_NM, D01.ACC_LVL, D01.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY D01.R_NUM    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD
                       , PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD;

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

END PKG_ANAL1130;

/
