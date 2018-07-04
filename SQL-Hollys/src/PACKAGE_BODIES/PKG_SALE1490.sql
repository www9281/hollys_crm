--------------------------------------------------------
--  DDL for Package Body PKG_SALE1490
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1490" AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    메뉴별 시간대별 매출현황(매장별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2018-01-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SEC_DIV       VARCHAR2(10)
        ,   SEC_DIV_NM    VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd          tb_ct_hd;
    V_CROSSTAB      VARCHAR2(30000);
    V_SQL           VARCHAR2(30000);
    V_HD            VARCHAR2(30000);
    V_HD1           VARCHAR2(20000);
    V_HD2           VARCHAR2(20000);
    V_HD3           VARCHAR2(20000);
    V_CNT           PLS_INTEGER;

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
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7)  := '0';
    ls_err_msg      VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT TO_NUMBER(S.SEC_DIV) AS SEC_DIV , TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTS  S, ]'
            ||CHR(13)||CHR(10)||Q'[         S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = '2'          ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[     AND (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;      

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD,PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

        dbms_output.put_line(ls_sql) ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;  

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SEC_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALES_VOL')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD  :=  V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT      ]'
        ||CHR(13)||CHR(10)||Q'[         S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.SALE_QTY))                    OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)  AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.GRD_AMT - SJ.VAT_AMT))        OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)  AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM)  AS CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                         AS   X_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                         AS   X_SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT)       AS   X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTS   SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND SJ.SEC_FG   = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)       ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.STOR_NM, SJ.SEC_DIV  ]';   

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;     


        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(X_SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_CNT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEC_DIV) IN             ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_NM      ]';

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;    

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    메뉴별 시간대별 매출현황(매장별 일별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2018-01-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SEC_DIV       VARCHAR2(10)
        ,   SEC_DIV_NM    VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd          tb_ct_hd;
    V_CROSSTAB      VARCHAR2(30000);
    V_SQL           VARCHAR2(30000);
    V_HD            VARCHAR2(30000);
    V_HD1           VARCHAR2(20000);
    V_HD2           VARCHAR2(20000);
    V_HD3           VARCHAR2(20000);
    V_CNT           PLS_INTEGER;

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
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7)  := '0';
    ls_err_msg      VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT TO_NUMBER(S.SEC_DIV) AS SEC_DIV , TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTS  S, ]'
            ||CHR(13)||CHR(10)||Q'[         S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = '2'          ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[     AND (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV)]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;      

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD,PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

        dbms_output.put_line(ls_sql) ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;  

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SEC_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALES_VOL')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD  :=  V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT      ]'
        ||CHR(13)||CHR(10)||Q'[         S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.SALE_QTY))                    OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT)  AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.GRD_AMT - SJ.VAT_AMT))        OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT)  AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT))  OVER (PARTITION BY SJ.BRAND_CD, S.BRAND_NM, S.STOR_TP_NM, S.STOR_TP_NM, S.TEAM_NM, S.SV_USER_NM, SJ.STOR_CD, S.STOR_NM, SJ.SALE_DT)  AS CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                         AS   X_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)             AS   X_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.CUST_M_CNT + SJ.CUST_F_CNT)       AS   X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTS   SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND SJ.SEC_FG   = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)       ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.STOR_NM, SJ.SEC_DIV  ]';   

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main; 

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(X_SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_NET_AMT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_CNT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEC_DIV) IN             ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_NM , SALE_DT     ]';

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;    

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03    메뉴별 시간대별 매출현황(메뉴별 )
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2018-01-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SEC_DIV       VARCHAR2(10)
        ,   SEC_DIV_NM    VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd          tb_ct_hd;
    V_CROSSTAB      VARCHAR2(30000);
    V_SQL           VARCHAR2(30000);
    V_HD            VARCHAR2(30000);
    V_HD1           VARCHAR2(20000);
    V_HD2           VARCHAR2(20000);
    V_HD3           VARCHAR2(20000);
    V_CNT           PLS_INTEGER;

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
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7)  := '0';
    ls_err_msg      VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT TO_NUMBER(S.SEC_DIV) AS SEC_DIV , TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM   SALE_JTM  S ]'
            ||CHR(13)||CHR(10)||Q'[       ,  S_STORE   B ]'
            ||CHR(13)||CHR(10)||Q'[       ,  S_ITEM    I ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = I.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.ITEM_CD  = I.ITEM_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = '2'          ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;      

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD,PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        dbms_output.put_line(ls_sql) ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            dbms_output.put_line('--->'||ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;  

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'

        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SEC_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALES_VOL')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD  :=  V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT      ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.SALE_QTY))                    OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.GRD_AMT - SJ.VAT_AMT))        OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(I.CUST_STD_CNT * SJ.SALE_QTY))   OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                         AS   X_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)             AS   X_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(I.CUST_STD_CNT * SJ.SALE_QTY)        AS   X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTM   SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND SJ.SEC_FG   = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY             ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY             ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]';   

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;     


        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(X_SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_NET_AMT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_CNT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEC_DIV) IN             ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y          ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY  ]'
        ||CHR(13)||CHR(10)||Q'[         L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM      ]';   

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;    

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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    메뉴별 시간대별 매출현황(매장별 일별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-02         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2018-01-02
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SEC_DIV       VARCHAR2(10)
        ,   SEC_DIV_NM    VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd          tb_ct_hd;
    V_CROSSTAB      VARCHAR2(30000);
    V_SQL           VARCHAR2(30000);
    V_HD            VARCHAR2(30000);
    V_HD1           VARCHAR2(20000);
    V_HD2           VARCHAR2(20000);
    V_HD3           VARCHAR2(20000);
    V_CNT           PLS_INTEGER;

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
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd       VARCHAR2(7)  := '0';
    ls_err_msg      VARCHAR2(500);

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;

        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT TO_NUMBER(S.SEC_DIV) AS SEC_DIV , TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM   SALE_JTM  S ]'
            ||CHR(13)||CHR(10)||Q'[       ,  S_STORE   B ]'
            ||CHR(13)||CHR(10)||Q'[       ,  S_ITEM    I ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = I.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.ITEM_CD  = I.ITEM_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = '2'          ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;      

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD,PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        dbms_output.put_line(ls_sql) ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            dbms_output.put_line('--->'||ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;  

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'

        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'D_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MENU_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_DT')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_VOL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005') ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SEC_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SEC_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALES_VOL')    || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT_005') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD  :=  V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT      ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.SALE_QTY))                    OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(SJ.GRD_AMT - SJ.VAT_AMT))        OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(I.CUST_STD_CNT * SJ.SALE_QTY))   OVER (PARTITION BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, I.D_CLASS_CD, SJ.ITEM_CD, I.ITEM_NM)  AS CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                         AS   X_SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)             AS   X_NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(I.CUST_STD_CNT * SJ.SALE_QTY)        AS   X_CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JTM   SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND SJ.SEC_FG   = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY             ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY             ]'
        ||CHR(13)||CHR(10)||Q'[         I.L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SEC_DIV     ]';   

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;     


        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(X_SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_NET_AMT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(X_CUST_CNT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SEC_DIV) IN             ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y          ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY  ]'
        ||CHR(13)||CHR(10)||Q'[         L_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D_CLASS_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT      ]';   

        dbms_output.put_line(V_SQL) ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;    

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

END PKG_SALE1490;

/
