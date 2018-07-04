--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1120
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1120" AS

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
        NAME:       SP_MAIN         손익-브랜-매장
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  V01.ACC_CD          ]'
        ||CHR(13)||CHR(10)|| '       ,  ''[''||V01.ACC_CD||'']''||V01.ACC_NM    AS ACC_NM   '
        ||CHR(13)||CHR(10)||Q'[      ,  V01.ACC_LVL         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.R_NUM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.LST_Y_M_GRD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.LST_Y_M_STD_GRD) OVER()) != 0 THEN V01.LST_Y_M_GRD / (SUM(V01.LST_Y_M_STD_GRD) OVER()) * 100 ELSE NULL END AS LST_Y_M_GRD_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.LST_M_GRD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.LST_M_STD_GRD) OVER())   != 0 THEN V01.LST_M_GRD   / (SUM(V01.LST_M_STD_GRD) OVER())   * 100 ELSE NULL END AS LST_M_GRD_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_M_GRD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.CUR_M_STD_GRD) OVER())   != 0 THEN V01.CUR_M_GRD   / (SUM(V01.CUR_M_STD_GRD) OVER())   * 100 ELSE NULL END AS CUR_M_GRD_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_M_PLN       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.CUR_M_STD_PLN) OVER())   != 0 THEN V01.CUR_M_PLN   / (SUM(V01.CUR_M_STD_PLN) OVER())   * 100 ELSE NULL END AS CUR_M_PLN_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_M_GRD - V01.LST_Y_M_GRD    AS LST_Y_M_GRD_CMP   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V01.LST_Y_M_GRD != 0 THEN (V01.CUR_M_GRD - V01.LST_Y_M_GRD) / V01.LST_Y_M_GRD * 100 ELSE NULL END AS LST_Y_M_PM_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_M_GRD - V01.LST_M_GRD      AS LST_M_GRD_CMP     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V01.LST_M_GRD != 0   THEN (V01.CUR_M_GRD - V01.LST_M_GRD)   / V01.LST_M_GRD * 100   ELSE NULL END AS LST_M_PM_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_M_GRD - V01.CUR_M_PLN      AS CUR_M_PLN_CMP     ]'  
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V01.CUR_M_PLN != 0   THEN (V01.CUR_M_GRD - V01.CUR_M_PLN)   / V01.CUR_M_PLN * 100   ELSE NULL END AS PLN_M_PM_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.LST_Y_ADD_GRD                  AS LST_Y_ADD_GRD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.LST_Y_ADD_STD_GRD) OVER()) != 0 THEN V01.LST_Y_ADD_GRD / (SUM(V01.LST_Y_ADD_STD_GRD) OVER()) * 100 ELSE NULL END AS LST_Y_ADD_GRD_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_Y_ADD_GRD                  AS CUR_Y_ADD_GRD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.CUR_Y_ADD_STD_GRD) OVER()) != 0 THEN V01.CUR_Y_ADD_GRD / (SUM(V01.CUR_Y_ADD_STD_GRD) OVER()) * 100 ELSE NULL END AS CUR_Y_ADD_GRD_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_Y_ADD_PLN                  AS CUR_Y_ADD_PLN     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V01.ACC_CD) >= 10800 AND (SUM(V01.CUR_Y_ADD_STD_PLN) OVER()) != 0 THEN V01.CUR_Y_ADD_PLN / (SUM(V01.CUR_Y_ADD_STD_PLN) OVER()) * 100 ELSE NULL END AS CUR_Y_ADD_PLN_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_Y_ADD_GRD - V01.LST_Y_ADD_GRD  AS LST_Y_ADD_GRD_CMP     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V01.LST_Y_ADD_GRD != 0 THEN (V01.CUR_Y_ADD_GRD - V01.LST_Y_ADD_GRD) / V01.LST_Y_ADD_GRD * 100 ELSE NULL END AS LST_Y_ADD_PM_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.CUR_Y_ADD_GRD - V01.CUR_Y_ADD_PLN  AS PLN_Y_ADD_GRD_CMP     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V01.CUR_Y_ADD_PLN !=0 THEN (V01.CUR_Y_ADD_GRD - V01.CUR_Y_ADD_PLN) / V01.CUR_Y_ADD_PLN * 100 ELSE NULL END AS PLN_Y_ADD_PM_RATE  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'    
        ||CHR(13)||CHR(10)||Q'[             SELECT  D01.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D01.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D01.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D01.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.LST_Y_M_GRD, 0))    AS LST_Y_M_GRD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.LST_Y_M_GRD, 0) ELSE 0 END)   AS LST_Y_M_STD_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.LST_M_GRD, 0))      AS LST_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.LST_M_GRD, 0) ELSE 0 END)     AS LST_M_STD_GRD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.CUR_M_GRD, 0))      AS CUR_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.CUR_M_GRD, 0) ELSE 0 END)     AS CUR_M_STD_GRD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.CUR_M_PLN, 0))      AS CUR_M_PLN    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.CUR_M_PLN, 0) ELSE 0 END)     AS CUR_M_STD_PLN      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.LST_Y_ADD_GRD, 0))  AS LST_Y_ADD_GRD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.LST_Y_ADD_GRD, 0) ELSE 0 END) AS LST_Y_ADD_STD_GRD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.CUR_Y_ADD_GRD, 0))  AS CUR_Y_ADD_GRD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.CUR_Y_ADD_GRD, 0) ELSE 0 END) AS CUR_Y_ADD_STD_GRD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(NVL(D01.CUR_Y_ADD_PLN, 0))  AS CUR_Y_ADD_PLN]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN D01.ACC_CD = '10800' THEN NVL(D01.CUR_Y_ADD_PLN, 0) ELSE 0 END) AS CUR_Y_ADD_STD_PLN  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '3' AND PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN PGD.G_SUM  ELSE 0 END)   AS LST_Y_M_GRD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '3' AND PGD.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'),  -1), 'YYYYMM') THEN PGD.G_SUM  ELSE 0 END)   AS LST_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '3' AND PGD.GOAL_YM = :PSV_YM THEN PGD.G_SUM  ELSE 0 END)  AS CUR_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '1' AND PGD.GOAL_YM = :PSV_YM THEN PGD.G_SUM  ELSE 0 END)  AS CUR_M_PLN    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '3' AND PGD.GOAL_YM BETWEEN SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM'), 1, 4)||'01' AND :PSV_YM THEN PGD.G_SUM  ELSE 0 END) AS LST_Y_ADD_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '3' AND PGD.GOAL_YM BETWEEN SUBSTR(:PSV_YM, 1, 4)||'01' AND :PSV_YM THEN PGD.G_SUM  ELSE 0 END)    AS CUR_Y_ADD_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGD.GOAL_DIV = '1' AND PGD.GOAL_YM BETWEEN SUBSTR(:PSV_YM, 1, 4)||'01' AND :PSV_YM THEN PGD.G_SUM  ELSE 0 END)    AS CUR_Y_ADD_PLN    ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  PGD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGD.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGD.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGD.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGD.G_SUM   ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  PL_GOAL_DD  PGD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  STR.COMP_CD = PGD.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.BRAND_CD= PGD.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.STOR_CD = PGD.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PGD.GOAL_YM BETWEEN SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM'), 1, 4)||'01' AND :PSV_YM  ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   PGD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                             PAM.COMP_CD ]'      
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.TERM_DIV]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  ROWNUM R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PAM.USE_YN  = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                                      START  WITH PAM.REF_ACC_CD = 0     ]'
        ||CHR(13)||CHR(10)||Q'[                                    CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                      ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = PGD.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.ACC_CD  = PGD.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                         UNION ALL           ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '3' AND PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END) AS LST_Y_M_GRD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '3' AND PGY.GOAL_YM = TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'),  -1), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END) AS LST_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '3' AND PGY.GOAL_YM = :PSV_YM THEN PGY.GOAL_AMT ELSE 0 END)    AS CUR_M_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '1' AND PGY.GOAL_YM = :PSV_YM THEN PGY.GOAL_AMT ELSE 0 END)    AS CUR_M_PLN    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '3' AND PGY.GOAL_YM BETWEEN SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM'), 1, 4)||'01' AND TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM') THEN PGY.GOAL_AMT ELSE 0 END)   AS LST_Y_ADD_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '3' AND PGY.GOAL_YM BETWEEN SUBSTR(:PSV_YM, 1, 4)||'01' AND :PSV_YM THEN PGY.GOAL_AMT ELSE 0 END)  AS CUR_Y_ADD_GRD    ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(CASE WHEN PGY.GOAL_DIV = '1' AND PGY.GOAL_YM BETWEEN SUBSTR(:PSV_YM, 1, 4)||'01' AND :PSV_YM THEN PGY.GOAL_AMT ELSE 0 END)  AS CUR_Y_ADD_PLN    ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  PGY.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGY.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGY.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGY.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PGY.GOAL_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  PL_GOAL_YM  PGY ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  STR.COMP_CD = PGY.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.BRAND_CD= PGY.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.STOR_CD = PGY.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  STR.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PGY.GOAL_YM BETWEEN SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_YM, 'YYYYMM'), -12), 'YYYYMM'), 1, 4)||'01' AND :PSV_YM  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PGY.COST_DIV= '3'           ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   PGY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                             PAM.COMP_CD ]'      
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.TERM_DIV]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  ROWNUM R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PAM.USE_YN  = 'Y'   ]'
        ||CHR(13)||CHR(10)||Q'[                                      START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                                    CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                      ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                 )   PAM ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = PGY.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PAM.ACC_CD  = PGY.ACC_CD (+)]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY PAM.ACC_CD, PAM.ACC_NM, PAM.ACC_LVL, PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                     )   D01 ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY D01.ACC_CD, D01.ACC_NM, D01.ACC_LVL, D01.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[         )   V01 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY V01.R_NUM    ]';

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD
                       , PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_YM, PSV_COMP_CD, PSV_YM, PSV_YM, PSV_COMP_CD;

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

END PKG_ANAL1120;

/
