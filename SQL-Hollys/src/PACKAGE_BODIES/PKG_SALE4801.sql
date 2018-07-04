--------------------------------------------------------
--  DDL for Package Body PKG_SALE4801
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4801" AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    금액대별 판매 현황(일자) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        2.0        2017-12-28         2. Tab1 Modified, Tab2 Created.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2017-12-28
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            AMT_DIV       VARCHAR2(10)
        ,   AMT_DIV_NM    VARCHAR2(60)
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
    ls_sql_main         VARCHAR2(20000);
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

    ls_sql_cm_17210 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_17210 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '17210') ;
        -------------------------------------------------------------------------------

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END    AS AMT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS AMT_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDA    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_17210 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END = C.VAL_N1 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END ]'||PSV_ORDER_BY ;

        ls_sql := ls_sql_with || ls_sql_tab_main ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
        dbms_output.put_line(ls_sql) ;


        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ;

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT1')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JOSU')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JODANGA')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NET_SALE_AMT')  ]'
        ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).AMT_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005')  || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1')     || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'JOSU')          || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'JODANGA')       || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT')  || Q'[' AS CT]' || TO_CHAR(i*4);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        OPEN PR_HEADER FOR
            V_HD USING  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END    AS AMT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))                                                       OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT) AS CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT)    ]'
        ||CHR(13)||CHR(10)||Q'[/NULLIF( SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))                                                       OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT), 0) AS CUST_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.BILL_CNT))                                                                         OVER (PARTITION BY  S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT) AS BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT)    ]'
        ||CHR(13)||CHR(10)||Q'[/NULLIF( SUM(SUM(SJ.BILL_CNT))                                                                         OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT), 0) AS BILL_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT) AS NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT)                                                            AS X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    / NULLIF(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT), 0) AS X_CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT)                                                                              AS X_BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    / NULLIF(SUM(SJ.BILL_CNT), 0)                   AS X_BILL_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    AS X_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDA    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_17210 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END = C.VAL_N1 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END]' ;

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
        ||CHR(13)||CHR(10)||Q'[       SUM(X_CUST_CNT)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_AMT)  AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_BILL_CNT)  AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_BILL_AMT)  AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_NET_AMT)   AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (AMT_DIV) IN            ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DT ]' ;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING     PSV_FILTER, PSV_FILTER,   PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER,
                            PSV_COMP_CD,PSV_GFR_DATE, PSV_GTO_DATE;

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    금액대별 판매 현황(매장) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        2.0        2017-12-28         2. Tab1 Modified, Tab2 Created.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2017-12-28
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            AMT_DIV       VARCHAR2(10)
        ,   AMT_DIV_NM    VARCHAR2(60)
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
    ls_sql_main         VARCHAR2(20000);
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

    ls_sql_cm_17210 VARCHAR2(1000) ;    -- 공통코드SQL

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_17210 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '17210') ;
        -------------------------------------------------------------------------------

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END    AS AMT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS AMT_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDA    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_17210 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END = C.VAL_N1 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END ]'||PSV_ORDER_BY ;

        ls_sql := ls_sql_with || ls_sql_tab_main ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
        dbms_output.put_line(ls_sql) ;


        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')         ]'
        ;

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT1')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JOSU')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JODANGA')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NET_SALE_AMT')  ]'
        ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).AMT_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).AMT_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005')  || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1')     || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'JOSU')          || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'JODANGA')       || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT')  || Q'[' AS CT]' || TO_CHAR(i*4);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        OPEN PR_HEADER FOR
            V_HD USING  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD,
                        PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END    AS AMT_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))                                                       OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)    AS CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)   ]'
        ||CHR(13)||CHR(10)||Q'[/NULLIF( SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))                                                       OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM), 0) AS CUST_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.BILL_CNT))                                                                         OVER (PARTITION BY  S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM) AS BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)   ]'
        ||CHR(13)||CHR(10)||Q'[/NULLIF( SUM(SUM(SJ.BILL_CNT))                                                                         OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM), 0) AS BILL_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM((DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,  'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)     AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT)                                                                                                          AS X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))  / NULLIF(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT), 0) AS X_CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT)                                                                                                                            AS X_BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))  / NULLIF(SUM(SJ.BILL_CNT), 0)                   AS X_BILL_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT,       'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                                                  AS X_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDA    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_17210 || Q'[ C]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END = C.VAL_N1 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN SJ.AMT_DIV >= 100000 THEN 100000 ELSE SJ.AMT_DIV END]' ;

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

        ||CHR(13)||CHR(10)||Q'[       SUM(X_CUST_CNT)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_AMT)  AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_BILL_CNT)  AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_BILL_AMT)  AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_NET_AMT)   AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (AMT_DIV) IN            ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_NM ]' ;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING     PSV_FILTER, PSV_FILTER,   PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER,
                            PSV_COMP_CD,PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE4801;

/
