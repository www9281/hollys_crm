--------------------------------------------------------
--  DDL for Package Body PKG_MEPA1010
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEPA1010" AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 종료일자
        PSV_CUST_LVL    IN  VARCHAR2 ,                -- 고객등급
        PSV_CUST_SEX    IN  VARCHAR2 ,                -- 고객성별
        PSV_CUST_AGE    IN  VARCHAR2 ,                -- 고객연령대
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01      일별 조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DAY     VARCHAR2(8)
        ,   SALE_DAY_NM  VARCHAR2(12)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(10000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);

    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;

    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER         EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        /* 가로축 데이타 FETCH */
        ls_sql := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  TO_CHAR(TO_DATE(YMD, 'YYYYMMDD'), 'MMDD')       AS SALE_DAY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(TO_CHAR(TO_DATE(YMD, 'YYYYMMDD'), 'MM-DD')) AS SALE_DAY_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  CALENDAR ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  YMD BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY TO_CHAR(TO_DATE(YMD, 'YYYYMMDD'), 'MMDD') ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY TO_CHAR(TO_DATE(YMD, 'YYYYMMDD'), 'MMDD') ]';

        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'VISIT_CUST_CNT')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SAV_PT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AVG_SAV_PT')    ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB  := V_CROSSTAB || Q'[, ]';
                END IF;
                V_CROSSTAB  := V_CROSSTAB  || Q'[']' || qry_hd(i).SALE_DAY || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VISIT_CUST_CNT') || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AVG_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := ''
        ||CHR(13)||CHR(10)|| V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  MAX(V03.BRAND_NM)           AS BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.STOR_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(V03.STOR_NM)            AS STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUBSTR(V03.USE_DT, 5, 4)    AS USE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(V03.DAY_CUST_CNT)) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(V03.DAY_SAV_PT  )) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(SUM(V03.DAY_CUST_CNT)) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(SUM(V03.DAY_SAV_PT  )) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) / SUM(SUM(V03.DAY_CUST_CNT)) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS TOT_AVG_SAV_PT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_CUST_CNT)       AS DAY_CUST_CNT           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_SAV_PT)         AS DAY_SAV_PT             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(V03.DAY_CUST_CNT) = 0 THEN 0            ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(V03.DAY_SAV_PT) / SUM(V03.DAY_CUST_CNT) ]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS DAY_AVG_SAV_PT         ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  CSH.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.USE_DT          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(COUNT(*)) OVER (PARTITION  BY CSH.COMP_CD, CSH.USE_DT, CSH.BRAND_CD, CSH.STOR_CD, CRD.CUST_ID)  AS DAY_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CSH.SAV_PT)             AS DAY_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD_SAV_HIS  CSH ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD          CRD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[                        SELECT  COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  GET_AGE_GROUP(COMP_CD, CUST_AGE) AGE_GROUP ]'
        ||CHR(13)||CHR(10)||Q'[                          FROM  (        ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 ]'
        ||CHR(13)||CHR(10)||Q'[                                                  THEN TRUNC((TO_NUMBER(SUBSTR(:PSV_GTO_DATE, 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, 1, 6))) / 100 + 1) ]'
        ||CHR(13)||CHR(10)||Q'[                                             ELSE 999 END AS CUST_AGE ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  C_CUST]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  COMP_CD  =  :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_LVL IS NULL OR LVL_CD  = :PSV_CUST_LVL )]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_SEX IS NULL OR SEX_DIV = :PSV_CUST_SEX )]'
        ||CHR(13)||CHR(10)||Q'[                                 ) C]'
        ||CHR(13)||CHR(10)||Q'[                     ) C]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  CSH.COMP_CD    = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.BRAND_CD   = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.STOR_CD    = S.STOR_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.COMP_CD    = CRD.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.CARD_ID    = CRD.CARD_ID]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.COMP_CD    = C.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.CUST_ID    = C.CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ( :PSV_CUST_AGE IS NULL OR C.AGE_GROUP = :PSV_CUST_AGE ) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.SAV_USE_FG = '1'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_YN     = 'Y'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY CSH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.USE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CRD.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[         ) V03  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY V03.BRAND_CD, V03.STOR_CD, SUBSTR(V03.USE_DT, 5, 4)]';

        V_SQL := ''
        ||CHR(13)||CHR(10)|| ls_sql 
        ||CHR(13)||CHR(10)||Q'[ SELECT *     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (     ]'
        || ls_sql_main
        ||CHR(13)||CHR(10)||Q'[        ) SCM ]'
        ||CHR(13)||CHR(10)||Q'[  PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[  (]'
        ||CHR(13)||CHR(10)||Q'[       SUM(DAY_CUST_CNT  ) VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DAY_SAV_PT    ) VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , AVG(DAY_AVG_SAV_PT) VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[   FOR (USE_DT) IN ( ]'
        || V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[  ) ) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY 1,2,3 ASC]';

        dbms_output.put_line(V_HD) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_GTO_DATE
                      , PSV_COMP_CD
                      , PSV_CUST_LVL, PSV_CUST_LVL
                      , PSV_CUST_SEX, PSV_CUST_SEX
                      , PSV_CUST_AGE, PSV_CUST_AGE
                      , PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 종료일자
        PSV_CUST_LVL    IN  VARCHAR2 ,                -- 고객등급
        PSV_CUST_SEX    IN  VARCHAR2 ,                -- 고객성별
        PSV_CUST_AGE    IN  VARCHAR2 ,                -- 고객연령대
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02      회원등급 조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            LVL_CD    VARCHAR2(10)
        ,   LVL_NM    VARCHAR2(100)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(10000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);

    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;

    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER         EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        /* 가로축 데이타 FETCH */
        ls_sql := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  LVL_CD                                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(L.LANG_NM, CL.LVL_NM)    AS LVL_NM    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  C_CUST_LVL CL                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                         ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD, PK_COL, LANG_NM      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  LANG_TABLE                    ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TABLE_NM    = 'C_CUST_LVL'    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  COL_NM      = 'LVL_NM'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'             ]'
        ||CHR(13)||CHR(10)||Q'[         )   L                                     ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CL.COMP_CD||CL.LVL_CD = L.PK_COL(+)       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.COMP_CD  = :PSV_COMP_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.USE_YN   = 'Y'                         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ( :PSV_CUST_LVL IS NULL OR LVL_CD = :PSV_CUST_LVL ) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CL.LVL_RANK                            ]';

        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD,
                  PSV_CUST_LVL, PSV_CUST_LVL;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'VISIT_CUST_CNT')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SAV_PT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AVG_SAV_PT')    ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB  := V_CROSSTAB || Q'[, ]';
                END IF;
                V_CROSSTAB  := V_CROSSTAB  || Q'[']' || qry_hd(i).LVL_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).LVL_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).LVL_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).LVL_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VISIT_CUST_CNT') || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AVG_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := ''
        ||CHR(13)||CHR(10)|| V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V03.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.LVL_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) / SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS TOT_AVG_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.DAY_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.DAY_SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V03.DAY_CUST_CNT = 0 THEN 0         ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE V03.DAY_SAV_PT / V03.DAY_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS DAY_AVG_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  CSH.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.LVL_CD            ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(COUNT(*)) OVER (PARTITION  BY CSH.COMP_CD, CSH.USE_DT, CSH.BRAND_CD, CSH.STOR_CD, CRD.CUST_ID)  AS DAY_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CSH.SAV_PT)             AS DAY_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD_SAV_HIS  CSH ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD          CRD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[                        SELECT  COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  LVL_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  GET_AGE_GROUP(COMP_CD, CUST_AGE) AGE_GROUP ]'
        ||CHR(13)||CHR(10)||Q'[                          FROM  (        ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  LVL_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 ]'
        ||CHR(13)||CHR(10)||Q'[                                                  THEN TRUNC((TO_NUMBER(SUBSTR(:PSV_GTO_DATE, 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, 1, 6))) / 100 + 1) ]'
        ||CHR(13)||CHR(10)||Q'[                                             ELSE 999 END AS CUST_AGE ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  C_CUST]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  COMP_CD  =  :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_LVL IS NULL OR LVL_CD  = :PSV_CUST_LVL )]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_SEX IS NULL OR SEX_DIV = :PSV_CUST_SEX )]'
        ||CHR(13)||CHR(10)||Q'[                                 ) C]'
        ||CHR(13)||CHR(10)||Q'[                     ) C]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  CSH.COMP_CD    = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.BRAND_CD   = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.STOR_CD    = S.STOR_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.COMP_CD    = CRD.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.CARD_ID    = CRD.CARD_ID]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.COMP_CD    = C.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.CUST_ID    = C.CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ( :PSV_CUST_AGE IS NULL OR C.AGE_GROUP = :PSV_CUST_AGE ) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.SAV_USE_FG = '1'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_YN     = 'Y'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY CSH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.LVL_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.USE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CRD.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[         ) V03  ]';

        V_SQL := ''
        ||CHR(13)||CHR(10)|| ls_sql 
        ||CHR(13)||CHR(10)||Q'[ SELECT *     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (     ]'
        || ls_sql_main
        ||CHR(13)||CHR(10)||Q'[        ) SCM ]'
        ||CHR(13)||CHR(10)||Q'[  PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[  (]'
        ||CHR(13)||CHR(10)||Q'[       SUM(DAY_CUST_CNT  ) VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DAY_SAV_PT    ) VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , AVG(DAY_AVG_SAV_PT) VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[   FOR (LVL_CD) IN ( ]'
        || V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[  ) ) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY 1,2,3 ASC]';

        dbms_output.put_line(V_HD) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_GTO_DATE
                      , PSV_COMP_CD
                      , PSV_CUST_LVL, PSV_CUST_LVL
                      , PSV_CUST_SEX, PSV_CUST_SEX
                      , PSV_CUST_AGE, PSV_CUST_AGE
                      , PSV_GFR_DATE, PSV_GTO_DATE;

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

    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 종료일자
        PSV_CUST_LVL    IN  VARCHAR2 ,                -- 고객등급
        PSV_CUST_SEX    IN  VARCHAR2 ,                -- 고객성별
        PSV_CUST_AGE    IN  VARCHAR2 ,                -- 고객연령대
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03      연령대 조회
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DAY     VARCHAR2(8)
        ,   SALE_DAY_NM  VARCHAR2(12)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB          VARCHAR2(10000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);

    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000) ;
    ls_sql_main         VARCHAR2(20000) ;

    ls_sql_store        VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_cm           VARCHAR2(1000) ;    -- 공통코드 참조 Table 
    ERR_HANDLER         EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01760') ;
        -------------------------------------------------------------------------------

        /* 가로축 데이타 FETCH */
        ls_sql := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CODE_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CODE_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ]' || ls_sql_cm || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ( :PSV_CUST_AGE IS NULL OR CODE_CD = :PSV_CUST_AGE ) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SORT_SEQ, CODE_CD ]';

        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd
            USING PSV_CUST_AGE, PSV_CUST_AGE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'VISIT_CUST_CNT')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SAV_PT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AVG_SAV_PT')    ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB  := V_CROSSTAB || Q'[, ]';
                END IF;
                V_CROSSTAB  := V_CROSSTAB  || Q'[']' || qry_hd(i).SALE_DAY || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DAY_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VISIT_CUST_CNT') || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AVG_SAV_PT'    ) || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := ''
        ||CHR(13)||CHR(10)|| V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V03.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.AGE_GROUP  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)     AS TOT_SAV_PT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE SUM(V03.DAY_SAV_PT  ) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD) / SUM(V03.DAY_CUST_CNT) OVER(PARTITION BY V03.BRAND_CD, V03.STOR_CD)]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS TOT_AVG_SAV_PT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.DAY_CUST_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V03.DAY_SAV_PT          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V03.DAY_CUST_CNT = 0 THEN 0         ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE V03.DAY_SAV_PT / V03.DAY_CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[         END                         AS DAY_AVG_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  CSH.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.AGE_GROUP         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(COUNT(*)) OVER (PARTITION  BY CSH.COMP_CD, CSH.USE_DT, CSH.BRAND_CD, CSH.STOR_CD, CRD.CUST_ID)  AS DAY_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CSH.SAV_PT)             AS DAY_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  S_STORE         S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD_SAV_HIS  CSH ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C_CARD          CRD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[                        SELECT  COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  GET_AGE_GROUP(COMP_CD, CUST_AGE) AGE_GROUP ]'
        ||CHR(13)||CHR(10)||Q'[                          FROM  (        ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 ]'
        ||CHR(13)||CHR(10)||Q'[                                                  THEN TRUNC((TO_NUMBER(SUBSTR(:PSV_GTO_DATE, 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, 1, 6))) / 100 + 1) ]'
        ||CHR(13)||CHR(10)||Q'[                                             ELSE 999 END AS CUST_AGE ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  C_CUST]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  COMP_CD  =  :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_LVL IS NULL OR LVL_CD  = :PSV_CUST_LVL )]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  ( :PSV_CUST_SEX IS NULL OR SEX_DIV = :PSV_CUST_SEX )]'
        ||CHR(13)||CHR(10)||Q'[                                 ) C]'
        ||CHR(13)||CHR(10)||Q'[                     ) C]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  CSH.COMP_CD    = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.BRAND_CD   = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.STOR_CD    = S.STOR_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.COMP_CD    = CRD.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.CARD_ID    = CRD.CARD_ID]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.COMP_CD    = C.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CRD.CUST_ID    = C.CUST_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  ( :PSV_CUST_AGE IS NULL OR C.AGE_GROUP = :PSV_CUST_AGE ) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.SAV_USE_FG = '1'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_YN     = 'Y'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CSH.USE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY CSH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  C.AGE_GROUP     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CSH.USE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CRD.CUST_ID     ]'
        ||CHR(13)||CHR(10)||Q'[         ) V03  ]';

        V_SQL := ''
        ||CHR(13)||CHR(10)|| ls_sql 
        ||CHR(13)||CHR(10)||Q'[ SELECT *     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (     ]'
        || ls_sql_main
        ||CHR(13)||CHR(10)||Q'[        ) SCM ]'
        ||CHR(13)||CHR(10)||Q'[  PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[  (]'
        ||CHR(13)||CHR(10)||Q'[       SUM(DAY_CUST_CNT  ) VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DAY_SAV_PT    ) VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , AVG(DAY_AVG_SAV_PT) VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[   FOR (AGE_GROUP) IN ( ]'
        || V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[  ) ) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY 1,2,3 ASC]';

        dbms_output.put_line(V_HD) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_GTO_DATE
                      , PSV_COMP_CD
                      , PSV_CUST_LVL, PSV_CUST_LVL
                      , PSV_CUST_SEX, PSV_CUST_SEX
                      , PSV_CUST_AGE, PSV_CUST_AGE
                      , PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_MEPA1010;

/
