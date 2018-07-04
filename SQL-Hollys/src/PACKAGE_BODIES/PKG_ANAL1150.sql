--------------------------------------------------------
--  DDL for Package Body PKG_ANAL1150
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ANAL1150" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     매장손익분석
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_MAIN
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            STOR_CD     VARCHAR2(10)
        ,   STOR_NM     VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(10000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
                    ;


        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  PGY.STOR_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STO.STOR_NM)    AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  PL_GOAL_YM  PGY                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     STO                 ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  PGY.COMP_CD     = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PGY.BRAND_CD    = STO.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PGY.STOR_CD     = STO.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PGY.COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PGY.GOAL_DIV    = '3'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PGY.GOAL_YM     BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY PGY.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY PGY.STOR_CD                  ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACC_TITLE')    ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).STOR_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).STOR_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).STOR_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT'  ) || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  '%' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)|| '  SELECT  ''[''||V03.ACC_CD||'']''||V03.ACC_NM    AS ACC_NM    '
        ||CHR(13)||CHR(10)||Q'[      ,  V03.ACC_CD, V03.ACC_LVL, V03.STOR_CD, V03.R_NUM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.ACC_GRD_TOT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN TO_NUMBER(V03.ACC_CD) >= 10800 AND SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD) > 0    ]'
        ||CHR(13)||CHR(10)||Q'[              THEN V03.ACC_GRD_TOT / SUM(V03.ACC_GRD_STD) OVER(PARTITION BY V03.STOR_CD) ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE NULL  ]'
        ||CHR(13)||CHR(10)||Q'[         END * 100   AS ACC_GRD_TOT_RATE ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V02.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V02.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V02.ACC_GRD_TOT)    AS ACC_GRD_TOT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN V02.ACC_CD = '10800' THEN V02.ACC_GRD_TOT ELSE 0 END)  AS ACC_GRD_STD  ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  NVL(PGD.G_SUM, 0)   AS ACC_GRD_TOT  ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PGD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGD.G_SUM   ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_GOAL_DD  PGD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD   = PGD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD  = PGD.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD   = PGD.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD   = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_YM   BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGD.GOAL_DIV  = '3' ]'
        ||CHR(13)||CHR(10)||Q'[                         ) PGD   ]' 
        ||CHR(13)||CHR(10)||Q'[                      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STO.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STO.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STO.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  S_STORE STO ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  EXISTS (    ]'
        ||CHR(13)||CHR(10)||Q'[                                                 SELECT  1   ]'
        ||CHR(13)||CHR(10)||Q'[                                                   FROM  PL_GOAL_YM  PGY ]'
        ||CHR(13)||CHR(10)||Q'[                                                  WHERE  PGY.COMP_CD  = STO.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  PGY.BRAND_CD = STO.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  PGY.STOR_CD  = STO.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  PGY.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  PGY.GOAL_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM    ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AND  PGY.GOAL_DIV = '3'          ]'
        ||CHR(13)||CHR(10)||Q'[                                                )    ]'
        ||CHR(13)||CHR(10)||Q'[                                 ) STO   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                         PAM.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_LVL     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.TERM_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  ROWNUM R_NUM    ]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PAM.ACC_CD <= '30000'   ]'
        ||CHR(13)||CHR(10)||Q'[                                  START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                                CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                  ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                 ) PAM   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                         ) V01   ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.COMP_CD = PGD.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                    AND  V01.STOR_CD = PGD.STOR_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                    AND  V01.ACC_CD  = PGD.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL   ]'          
        ||CHR(13)||CHR(10)||Q'[                 SELECT  V01.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_CD ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_NM ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.ACC_LVL]'
        ||CHR(13)||CHR(10)||Q'[                      ,  V01.R_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  NVL(PGY.GOAL_AMT ,0)   AS ACC_GRD_TOT  ]'
        ||CHR(13)||CHR(10)||Q'[                   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  PGY.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_YM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.COST_DIV]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PGY.GOAL_AMT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  PL_GOAL_YM  PGY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE     STR ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  STR.COMP_CD   = PGY.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.BRAND_CD  = PGY.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.STOR_CD   = PGY.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  STR.COMP_CD   = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGY.GOAL_YM   BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGY.GOAL_DIV  = '3' ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  PGY.COST_DIV  = '3' ]'
        ||CHR(13)||CHR(10)||Q'[                         ) PGY   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  STO.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STO.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STO.STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.ACC_LVL ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  PAM.R_NUM   ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  S_STORE STO ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  EXISTS (    ]'
        ||CHR(13)||CHR(10)||Q'[                                                  SELECT  1  ]'
        ||CHR(13)||CHR(10)||Q'[                                                    FROM  PL_GOAL_YM PGY ]'
        ||CHR(13)||CHR(10)||Q'[                                                   WHERE  PGY.COMP_CD  = STO.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.BRAND_CD = STO.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.STOR_CD  = STO.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.COMP_CD  = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.GOAL_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM   ]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.GOAL_DIV = '3' ]'
        ||CHR(13)||CHR(10)||Q'[                                                     AND  PGY.COST_DIV = '3' ]'
        ||CHR(13)||CHR(10)||Q'[                                                 )   ]'
        ||CHR(13)||CHR(10)||Q'[                                 ) STO   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  /*+ INDEX(PAM PK_PL_ACC_MST) */ ]'
        ||CHR(13)||CHR(10)||Q'[                                         PAM.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_LVL     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.REF_ACC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.TERM_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PAM.ACC_SEQ     ]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  ROWNUM  AS R_NUM]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  PL_ACC_MST  PAM ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  PAM.COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PAM.USE_YN  = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PAM.ACC_CD <= '30000'   ]'
        ||CHR(13)||CHR(10)||Q'[                                  START  WITH PAM.REF_ACC_CD = 0 ]'
        ||CHR(13)||CHR(10)||Q'[                                CONNECT  BY PRIOR PAM.ACC_CD = PAM.REF_ACC_CD]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  PRIOR PAM.COMP_CD   = PAM.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                                  ORDER  SIBLINGS BY PAM.ACC_CD, PAM.ACC_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[                                 ) PAM   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  PAM.COMP_CD = STO.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                         ) V01   ]'
        ||CHR(13)||CHR(10)||Q'[                  WHERE  V01.COMP_CD = PGY.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                    AND  V01.STOR_CD = PGY.STOR_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[                    AND  V01.ACC_CD  = PGY.ACC_CD (+)    ]'
        ||CHR(13)||CHR(10)||Q'[                 ) V02   ]'
        ||CHR(13)||CHR(10)||Q'[          GROUP  BY V02.STOR_CD, V02.ACC_CD, V02.ACC_NM, V02.ACC_LVL, V02.R_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[         ) V03   ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(ACC_GRD_TOT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(ACC_GRD_TOT_RATE) AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (STOR_CD) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY R_NUM ]';

        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM, PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM, PSV_COMP_CD
                      , PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM, PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM, PSV_COMP_CD;

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

END PKG_ANAL1150;

/
