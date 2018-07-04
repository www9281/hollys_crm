--------------------------------------------------------
--  DDL for Package Body PKG_SALE1390
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1390" AS

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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_MAIN       모바일쿠폰집계현황(일자대비)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-14         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-12-14
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            MOBILE_DIV     VARCHAR2(8)
        ,   MOBILE_NM  VARCHAR2(20)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB       VARCHAR2(30000);
    V_SQL            VARCHAR2(30000);
    V_HD             VARCHAR2(30000);
    V_HD1            VARCHAR2(20000);
    V_HD2            VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql           VARCHAR2(30000);
    ls_sql_with      VARCHAR2(30000);
    ls_sql_main      VARCHAR2(30000);
    ls_sql_date      VARCHAR2(1000);
    ls_sql_store     VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item      VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1         VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2         VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1      VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2      VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main  VARCHAR2(30000);    -- CORSSTAB TITLE
    V_COMP_CD        VARCHAR2(10);
    V_LANG_CD        VARCHAR2(10);

    ERR_HANDLER     EXCEPTION;

    ls_err_cd        VARCHAR2(7) := '0';
    ls_err_msg       VARCHAR2(500);


    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT MOBILE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOBILE_NM     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG    ML, STORE S  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.MOBILE_DIV NOT IN ('75','93','94','83')  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY ML.COMP_CD, MOBILE_DIV, ML.MOBILE_NM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.MOBILE_DIV ]'
        ;

        ls_sql := ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DAY' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL') ]';


        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DAY' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_SALE_AMT' )        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005' )        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT1' )           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JOSU' )                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JODANGA' )             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'QTY' )                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_PRC' )            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PURCHASE_PROFIT_COST') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'COOP_COMP_AMT' )       ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).MOBILE_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')                  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_PRC')             || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'PURCHASE_PROFIT_COST') || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'COOP_COMP_AMT')        || Q'[' AS CT]' || TO_CHAR(i*4);

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[   SELECT            ]'
        ||CHR(13)||CHR(10)||Q'[          SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[        , MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(NET_AMT))      OVER(PARTITION BY COMP_CD,  SALE_DT)     AS  NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(CUST_CNT))     OVER(PARTITION BY COMP_CD,  SALE_DT)     AS  CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(NET_AMT))      OVER(PARTITION BY COMP_CD,  SALE_DT)   ]'
        ||CHR(13)||CHR(10)||Q'[ / NULLIF(SUM(SUM(CUST_CNT))     OVER(PARTITION BY COMP_CD,  SALE_DT), 0) AS  PER_NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(BILL_CNT))     OVER(PARTITION BY COMP_CD,  SALE_DT)     AS  BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(NET_AMT))      OVER(PARTITION BY COMP_CD,  SALE_DT)   ]'
        ||CHR(13)||CHR(10)||Q'[ / NULLIF(SUM(SUM(BILL_CNT))     OVER(PARTITION BY COMP_CD,  SALE_DT), 0) AS  PER_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(M_QTY))        OVER(PARTITION BY COMP_CD, SALE_DT)  AS M_QTY             ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(M_SALE_AMT))   OVER(PARTITION BY COMP_CD, SALE_DT)  AS M_SALE_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(M_SALE_H))     OVER(PARTITION BY COMP_CD, SALE_DT)  AS M_SALE_H          ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(SUM(M_SALE_C))     OVER(PARTITION BY COMP_CD, SALE_DT)  AS M_SALE_C          ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(M_QTY)             AS MX_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(M_SALE_AMT)        AS MX_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(M_SALE_H)          AS MX_SALE_H    ]'
        ||CHR(13)||CHR(10)||Q'[        , SUM(M_SALE_C)          AS MX_SALE_C    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM(                        ]'
        ||CHR(13)||CHR(10)||Q'[       SELECT     ML.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                , SH.NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                , SH.CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                , SH.BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                , M_SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                , M_SALE_H      ]'
        ||CHR(13)||CHR(10)||Q'[                , M_SALE_C      ]'
        ||CHR(13)||CHR(10)||Q'[                , M_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[       FROM(                    ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT ML.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                , ML.MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                , SUM(M_SALE_AMT)   AS  M_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                , SUM(M_SALE_H)     AS  M_SALE_H   ]'
        ||CHR(13)||CHR(10)||Q'[                , SUM(M_SALE_C)     AS  M_SALE_C   ]'
        ||CHR(13)||CHR(10)||Q'[                , SUM(M_QTY)        AS  M_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  MOBILE_LOG ML                   ]'
        ||CHR(13)||CHR(10)||Q'[            WHERE  ML.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  ML.SALE_DIV = '1'                                   ]'
        ||CHR(13)||CHR(10)||Q'[              AND  ML.MOBILE_DIV NOT IN ('75','93','94','83')          ]'
        ||CHR(13)||CHR(10)||Q'[              AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[           GROUP BY ML.COMP_CD, ML.SALE_DT, ML.BRAND_CD, ML.STOR_CD, ML.POS_NO, ML.MOBILE_DIV, ML.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[       ) ML ]'
        ||CHR(13)||CHR(10)||Q'[       ,(   ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(SH.CUST_M_CNT  + SH.CUST_F_CNT)                                                               AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  COUNT(BILL_NO)                                                                                    AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                ,  SUM(SH.GRD_I_AMT   + SH.GRD_O_AMT) - SUM(SH.VAT_I_AMT + SH.VAT_O_AMT)                             AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[             FROM  SALE_HD     SH                  ]'
        ||CHR(13)||CHR(10)||Q'[            WHERE  SH.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              AND  SH.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              AND  SH.SALE_DIV = '1'               ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP  BY SH.COMP_CD, SH.SALE_DT, SH.BRAND_CD, SH.STOR_CD, SH.POS_NO, SH.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[       ) SH ]'
        ||CHR(13)||CHR(10)||Q'[       WHERE ML.COMP_CD    = SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND ML.SALE_DT    = SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[         AND ML.BRAND_CD   = SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         AND ML.STOR_CD    = SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND ML.POS_NO     = SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         AND ML.BILL_NO    = SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[   ) X     ]'
        ||CHR(13)||CHR(10)||Q'[   GROUP BY  COMP_CD, SALE_DT      , MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[   ORDER BY  COMP_CD, SALE_DT DESC , MOBILE_DIV ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(MX_QTY)        AS VCOL1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_AMT)   AS VCOL2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_H)     AS VCOL3  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_C)     AS VCOL4  ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (MOBILE_DIV) IN            ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y  ORDER BY SALE_DT DESC         ]';

        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;

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
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING
                          PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV 
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB        모바일쿠폰집계현황(매장대비)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-14         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2017-12-14
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            MOBILE_DIV     VARCHAR2(8)
        ,   MOBILE_NM  VARCHAR2(20)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd;

    V_CROSSTAB       VARCHAR2(30000);
    V_SQL            VARCHAR2(30000);
    V_HD             VARCHAR2(30000);
    V_HD1            VARCHAR2(20000);
    V_HD2            VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql           VARCHAR2(30000);
    ls_sql_with      VARCHAR2(30000);
    ls_sql_main      VARCHAR2(30000);
    ls_sql_date      VARCHAR2(1000);
    ls_sql_store     VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item      VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1         VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2         VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1      VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2      VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main  VARCHAR2(30000);    -- CORSSTAB TITLE
    V_COMP_CD        VARCHAR2(10);
    V_LANG_CD        VARCHAR2(10);

    ERR_HANDLER     EXCEPTION;

    ls_err_cd        VARCHAR2(7) := '0';
    ls_err_msg       VARCHAR2(500);


    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT MOBILE_DIV        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MOBILE_NM     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG    ML, STORE S  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD  = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.BRAND_CD = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.STOR_CD  = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.MOBILE_DIV NOT IN ('75','93','94','83')  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY  ML.COMP_CD, MOBILE_DIV, ML.MOBILE_NM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.MOBILE_DIV ]'
        ;

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES' )    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')     ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM' )  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_SALE_AMT' )        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT_005' )        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT1' )           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JOSU' )                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'JODANGA' )             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'QTY' )                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_PRC' )            ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PURCHASE_PROFIT_COST') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'COOP_COMP_AMT' )       ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).MOBILE_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).MOBILE_NM  || Q'[' AS CT]' || TO_CHAR(i*4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')                  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_PRC')             || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'PURCHASE_PROFIT_COST') || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'COOP_COMP_AMT')        || Q'[' AS CT]' || TO_CHAR(i*4);

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[  SELECT  ]'
        ||CHR(13)||CHR(10)||Q'[        BRAND_NM               ]'
        ||CHR(13)||CHR(10)||Q'[      , STOR_TP_NM             ]'
        ||CHR(13)||CHR(10)||Q'[      , TEAM_NM                AS SC_TEAM  ]'
        ||CHR(13)||CHR(10)||Q'[      , SV_USER_NM             AS SC_USER  ]'
        ||CHR(13)||CHR(10)||Q'[      , STOR_CD                ]'
        ||CHR(13)||CHR(10)||Q'[      , STOR_NM                ]'
        ||CHR(13)||CHR(10)||Q'[      , MOBILE_DIV             ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(NET_AMT))      OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(CUST_CNT))     OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)    AS CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(NET_AMT))      OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)  ]'
        ||CHR(13)||CHR(10)||Q'[ / NULLIF(SUM(SUM(CUST_CNT))   OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM), 0) AS  PER_NET_AMT ]' 
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(BILL_CNT))     OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)     AS BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(NET_AMT))      OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)  ]'
        ||CHR(13)||CHR(10)||Q'[ / NULLIF(SUM(SUM(BILL_CNT))   OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM), 0) AS  PER_BILL_CNT]' 
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(M_QTY))        OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)     AS M_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(M_SALE_AMT))   OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)     AS M_SALE_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(M_SALE_H))     OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)     AS M_SALE_H     ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(SUM(M_SALE_C))     OVER (PARTITION BY  BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM)     AS M_SALE_C     ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(M_QTY)             AS MX_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(M_SALE_AMT)        AS MX_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(M_SALE_H)          AS MX_SALE_H   ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(M_SALE_C)          AS MX_SALE_C   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM(           ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT     ML.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              , S.BRAND_NM    ]'
        ||CHR(13)||CHR(10)||Q'[              , S.STOR_TP_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              , S.TEAM_NM     ]'
        ||CHR(13)||CHR(10)||Q'[              , S.SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              , S.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              , SH.NET_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[              , SH.CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[              , SH.BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[              , M_QTY         ]'
        ||CHR(13)||CHR(10)||Q'[              , M_SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[              , M_SALE_H      ]'
        ||CHR(13)||CHR(10)||Q'[              , M_SALE_C      ]'
        ||CHR(13)||CHR(10)||Q'[     FROM(                    ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT ML.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[              , ML.MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(M_QTY)        AS  M_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(M_SALE_AMT)   AS  M_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(M_SALE_H)     AS  M_SALE_H   ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(M_SALE_C)     AS  M_SALE_C   ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  MOBILE_LOG ML               ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE  ML.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[            AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[            AND  ML.SALE_DIV = '1'           ]'
        ||CHR(13)||CHR(10)||Q'[            AND  ML.MOBILE_DIV NOT IN ('75','93','94','83')                   ]'
        ||CHR(13)||CHR(10)||Q'[            AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY ML.COMP_CD, ML.SALE_DT, ML.BRAND_CD, ML.STOR_CD, ML.POS_NO, ML.MOBILE_DIV, ML.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[ ) ML   ]'
        ||CHR(13)||CHR(10)||Q'[ ,(                          ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[              , COUNT(BILL_NO) AS BILL_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(SH.CUST_M_CNT + SH.CUST_F_CNT) AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(SH.GRD_I_AMT  + SH.GRD_O_AMT) - SUM(SH.VAT_I_AMT + SH.VAT_O_AMT) AS NET_AMT           ]'
        ||CHR(13)||CHR(10)||Q'[           FROM  SALE_HD     SH              ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[            AND  SH.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[            AND  SH.SALE_DIV = '1'           ]'
        ||CHR(13)||CHR(10)||Q'[            GROUP BY SH.COMP_CD, SH.SALE_DT, SH.BRAND_CD, SH.STOR_CD, SH.POS_NO, SH.BILL_NO ]'
        ||CHR(13)||CHR(10)||Q'[   ) SH , S_STORE S]'
        ||CHR(13)||CHR(10)||Q'[   WHERE ML.COMP_CD    = SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.SALE_DT    = SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.BRAND_CD   = SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.STOR_CD    = SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.POS_NO     = SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.BILL_NO    = SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.COMP_CD    = S.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.BRAND_CD   = S.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[     AND ML.STOR_CD    = S.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ ) X ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP BY  COMP_CD, BRAND_CD, BRAND_NM, STOR_TP_NM, STOR_TP_NM, TEAM_NM, SV_USER_NM, X.STOR_CD, STOR_NM, MOBILE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY  COMP_CD, BRAND_CD, STOR_TP_NM,  TEAM_NM, SV_USER_NM, X.STOR_CD, MOBILE_DIV ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(MX_QTY)        AS VCOL1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_AMT)   AS VCOL2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_H)     AS VCOL3  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(MX_SALE_C)     AS VCOL4  ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (MOBILE_DIV) IN            ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y  ORDER BY STOR_NM DESC         ]';

        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;

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

        OPEN PR_RESULT FOR
            V_SQL USING
                          PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV 
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE1390;

/
