--------------------------------------------------------
--  DDL for Package Body PKG_SALE1530
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1530" AS

    PROCEDURE SP_MAIN
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
        NAME:       SP_MAIN    특수매장 매출 현황(한점포)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2018-01-10         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2018-01-10
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
        ||CHR(13)||CHR(10)||Q'[   SELECT  DISTINCT T.SALE_DT, SUBSTR(T.SALE_DT,1,4) || '-' || SUBSTR(T.SALE_DT,5,2) || '-' || SUBSTR(T.SALE_DT,7,2) || '(' || FC_GET_WEEK(T.COMP_CD, T.SALE_DT, ']' || PSV_LANG_CD || q'[' ) || ')'  SALE_DT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[     FROM  SALE_CT T, SALE_HD H, S_STORE S, COST_GRP G, COST_MST M ]'
        ||CHR(13)||CHR(10)||Q'[    WHERE  T.COMP_CD       = H.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = H.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.STOR_CD       = H.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.POS_NO        = H.POS_NO         ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BILL_NO       = H.BILL_NO        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.SALE_DT       = H.SALE_DT        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = S.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = S.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.STOR_CD       = S.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = G.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = G.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.GRP_CD        = G.COST_GRP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = M.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = M.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.CUST_TYPE_CD  = M.COST_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[      AND  (:PSV_GIFT_DIV IS NULL OR T.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[      AND  G.USE_YN = M.USE_YN  ]'
        ||CHR(13)||CHR(10)||Q'[      AND  G.USE_YN = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[    ORDER  BY T.SALE_DT         ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;      

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

        dbms_output.put_line(ls_sql) ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;  

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'EXT_GROUP_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CODE_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'EXT_GROUP_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CODE_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  '' AS NO     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'EXT_GROUP_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CODE_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'QTY')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_SALE_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NET_SALE_AMT') ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL')        || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL')        || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL')        || Q'[' AS CT]' || TO_CHAR(i*3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*3 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'GRD_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*3 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*3);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD  :=  V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;                    

        dbms_output.put_line(V_HD) ;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[     SELECT                ]'
        ||CHR(13)||CHR(10)||Q'[            G.COST_GRP_NM  ]'
        ||CHR(13)||CHR(10)||Q'[           ,M.COST_NM      ]'
        ||CHR(13)||CHR(10)||Q'[           ,T.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(SUM(H.SALE_QTY))                                        OVER(PARTITION BY G.COST_GRP_NM , M.COST_NM) AS QTY       ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(SUM(H.GRD_I_AMT + H.GRD_O_AMT))                         OVER(PARTITION BY G.COST_GRP_NM , M.COST_NM) AS GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(SUM(H.GRD_I_AMT + H.GRD_O_AMT - VAT_I_AMT + VAT_O_AMT)) OVER(PARTITION BY G.COST_GRP_NM , M.COST_NM) AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(H.SALE_QTY)                                             AS XQTY     ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(H.GRD_I_AMT + H.GRD_O_AMT)                              AS XGRD_AMT ]'
        ||CHR(13)||CHR(10)||Q'[           ,SUM(H.GRD_I_AMT + H.GRD_O_AMT - VAT_I_AMT + VAT_O_AMT)      AS XNET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[     FROM  SALE_CT T, SALE_HD H, S_STORE S, COST_GRP G, COST_MST M ]'
        ||CHR(13)||CHR(10)||Q'[    WHERE  T.COMP_CD       = H.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = H.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.STOR_CD       = H.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.POS_NO        = H.POS_NO         ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BILL_NO       = H.BILL_NO        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.SALE_DT       = H.SALE_DT        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = S.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = S.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.STOR_CD       = S.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = G.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = G.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.GRP_CD        = G.COST_GRP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = M.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.BRAND_CD      = M.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.CUST_TYPE_CD  = M.COST_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.COMP_CD       = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      AND  T.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[      AND  (:PSV_GIFT_DIV IS NULL OR T.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[      AND  G.USE_YN = M.USE_YN  ]'
        ||CHR(13)||CHR(10)||Q'[      AND  G.USE_YN = 'Y'       ]'
        ||CHR(13)||CHR(10)||Q'[    GROUP  BY G.COST_GRP_NM , M.COST_NM, T.SALE_DT               ]';

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
        ||CHR(13)||CHR(10)||Q'[       SUM(XQTY)       AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(XGRD_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(XNET_AMT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN           ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y          ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY  COST_GRP_NM        ]';

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

END PKG_SALE1530;

/
