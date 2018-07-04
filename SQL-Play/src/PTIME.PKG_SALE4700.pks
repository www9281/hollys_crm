CREATE OR REPLACE PACKAGE       PKG_SALE4700 AS
    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4700
    --  Description      : 일별 매출추이
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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

    PROCEDURE SP_SUB
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE4700;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4700 AS
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      일별 매출추이
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
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT     VARCHAR2(8)
        ,   SALE_DT_NM  VARCHAR2(20)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(30000);
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
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT, SUBSTR(SJ.SALE_DT, 5, 2) || '-' || SUBSTR(SJ.SALE_DT, 7, 2) || '(' || FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) || ')'    AS SALE_DT_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT   ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')  ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DIV')  ]';
        
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD := V_HD || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]';
            END;
        END LOOP;
    
        V_HD :=  V_HD || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CASE WHEN NO = 1 THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT')   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 2 THEN DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_CNT'))   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 3 THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALES_QTY')      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 4 THEN DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_AMT'))   ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 5 THEN 'D-1' ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 6 THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'INCS_RATE')      ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 7 THEN 'D-7' ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NO = 8 THEN FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'INCS_RATE')      ]'
        ||CHR(13)||CHR(10)||Q'[         END     AS DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROW_NUMBER() OVER (PARTITION BY S.SALE_DT ORDER BY Y.NO)    AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(Y.NO, 1, S.SALE_AMT, 2, S.CUST_CNT, 3, S.SALE_QTY, 4, S.CUST_AMT, 5, S.BEF_1DAY_AMT, 6, S.BEF_1DAY_RTO, 7, S.BEF_7DAY_AMT, 8, S.BEF_7DAY_RTO)    AS VALUE    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SALE_DT         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CUST_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_QTY        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CUST_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LAG(SALE_AMT, 1) OVER (ORDER BY SALE_DT)    AS BEF_1DAY_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN LAG(SALE_AMT, 1) OVER (ORDER BY SALE_DT) <> 0 THEN (ROUND(SALE_AMT / LAG(SALE_AMT, 1) OVER (ORDER BY SALE_DT) * 100, 2) - 100) ELSE 100 END AS BEF_1DAY_RTO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LAG(SALE_AMT, 7) OVER (ORDER BY SALE_DT)    AS BEF_7DAY_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN LAG(SALE_AMT, 7) OVER (ORDER BY SALE_DT) <> 0 THEN (ROUND(SALE_AMT / LAG(SALE_AMT, 7) OVER (ORDER BY SALE_DT) * 100, 2) - 100) ELSE 100 END AS BEF_7DAY_RTO   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) OVER (PARTITION BY SJ.SALE_DT)         AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) OVER (PARTITION BY SJ.SALE_DT)  AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_QTY) OVER (PARTITION BY SJ.SALE_DT)     AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROUND(DECODE(SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) OVER (PARTITION BY SJ.SALE_DT), 0, 0,  ]'
        ||CHR(13)||CHR(10)||Q'[                                              SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) OVER (PARTITION BY SJ.SALE_DT)                ]'
        ||CHR(13)||CHR(10)||Q'[                                              / SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + SJ.ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT)) OVER (PARTITION BY SJ.SALE_DT)         ]'
        ||CHR(13)||CHR(10)||Q'[                                 ))  AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  ROW_NUMBER() OVER(ORDER BY SJ.SALE_DT)  AS ROW_NUM  ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.SALE_QTY)        AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.SALE_AMT)        AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.GRD_AMT)         AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.VAT_AMT)         AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.ETC_M_CNT)       AS ETC_M_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.ETC_F_CNT)       AS ETC_F_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.BILL_CNT)        AS BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SUM(SJ.RTN_BILL_CNT)    AS RTN_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  SJ.SALE_DT  BETWEEN TO_CHAR(TO_DATE(:PSV_GFR_DATE, 'YYYYMMDD') - 7, 'YYYYMMDD') AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                                      GROUP  BY SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  SJ.SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[                                 )       SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                     )       ]'
        ||CHR(13)||CHR(10)||Q'[         )   S               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  LEVEL   AS NO   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  DUAL    ]'
        ||CHR(13)||CHR(10)||Q'[            CONNECT  BY LEVEL <= 8   ]'
        ||CHR(13)||CHR(10)||Q'[         )   Y               ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  S.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(VALUE)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ROW_NUM ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING   PSV_COMP_CD, PSV_LANG_CD
                        , PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_COMP_CD, PSV_LANG_CD
                        , PSV_FILTER, PSV_CUST_DIV, PSV_CUST_DIV, PSV_FILTER, PSV_CUST_DIV
                        , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE 
                        , PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_GFR_DATE, PSV_GTO_DATE;
     
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

   PROCEDURE SP_SUB
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB       세트상품 선호도 붆석(옵션상품) 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DIV  ]' -- 구분
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM ]' -- 항목
        ||CHR(13)||CHR(10)||Q'[      ,  CUR_MONTH  ]' -- 당월
        ||CHR(13)||CHR(10)||Q'[      ,  BEF_MONTH  ]' -- 전월
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(CUR_MONTH, 0) <> 0 AND NVL(BEF_MONTH, 0) = 0 THEN 100 ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NVL(CUR_MONTH, 0) = 0  AND NVL(BEF_MONTH, 0) = 0 THEN 0 ]'
        ||CHR(13)||CHR(10)||Q'[              WHEN NVL(CUR_MONTH, 0) = 0  AND NVL(BEF_MONTH, 0) <> 0 THEN -100 ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND(NVL(CUR_MONTH, 0) / NVL(BEF_MONTH, 0) * 100 - 100, 2) END AS BEF_MON_CONT_RTO  ]'
        ||CHR(13)||CHR(10)||Q'[  FROM (  ]'
        ||CHR(13)||CHR(10)||Q'[        SELECT DECODE(Z.NO, 1, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_AMT_MONTH_SUM')     ]'
        ||CHR(13)||CHR(10)||Q'[                          , 2, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_AMT_LAST_YEAR_SUM') ]'
        ||CHR(13)||CHR(10)||Q'[               ) AS DIV  ]'
        ||CHR(13)||CHR(10)||Q'[             , DECODE(Y.NO, 1, DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_CNT')) ]'
        ||CHR(13)||CHR(10)||Q'[                          , 2, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT')   ]'
        ||CHR(13)||CHR(10)||Q'[                          , 3, DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_AMT')))    AS ITEM ]'
        ||CHR(13)||CHR(10)||Q'[             , DECODE(Z.NO, 1, DECODE(Y.NO, 1, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), CUST_CNT1))          ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), SALE_AMT1))          ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), SALE_AMT1)),   ]'
        ||CHR(13)||CHR(10)||Q'[                                                    SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), CUST_CNT1)), 2))   ]'
        ||CHR(13)||CHR(10)||Q'[                               )                                                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[                          , 2, DECODE(Y.NO, 1, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), CUST_CNT1))          ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), SALE_AMT1))          ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), SALE_AMT1)),   ]'
        ||CHR(13)||CHR(10)||Q'[                                                    SUM(DECODE(SUBSTR(SALE_DT, 1, 6), SUBSTR(:PSV_GTO_DATE, 1, 6), CUST_CNT1)), 2))   ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[                          , 3, DECODE(Y.NO, 1, ROUND(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') BETWEEN '2' AND '6' THEN CUST_CNT1 END)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, ROUND(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') BETWEEN '2' AND '6' THEN SALE_AMT1 END)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') BETWEEN '2' AND '6' THEN SALE_AMT1 END),  ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') BETWEEN '2' AND '6' THEN CUST_CNT1 END), 2)) ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[                          , 4, DECODE(Y.NO, 1, ROUND(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN CUST_CNT1 END)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, ROUND(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SALE_AMT1 END)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN SALE_AMT1 END), ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AVG(CASE WHEN TO_CHAR(TO_DATE(SALE_DT, 'YYYYMMDD'), 'D') IN ('1', '7') THEN CUST_CNT1 END), 2)) ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]' -- 당월
        ||CHR(13)||CHR(10)||Q'[               ) AS CUR_MONTH     ]'
        ||CHR(13)||CHR(10)||Q'[             , DECODE(Z.NO, 1, DECODE(Y.NO, 1, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), CUST_CNT2)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), SALE_AMT2)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), SALE_AMT2)), ]'
        ||CHR(13)||CHR(10)||Q'[                                                    SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), CUST_CNT2)), 2))  ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[                          , 2, DECODE(Y.NO, 1, SUM(DECODE(SALE_DT, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -12), 'YYYYMMDD'), CUST_CNT3)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, SUM(DECODE(SALE_DT, TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -12), 'YYYYMMDD'), SALE_AMT3)) ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), SALE_AMT3)), ]'
        ||CHR(13)||CHR(10)||Q'[                                                    SUM(DECODE(SUBSTR(SALE_DT, 1, 6), TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM'), CUST_CNT3)), 2))  ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[                          , 3, DECODE(Y.NO, 1, ROUND(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') BETWEEN '2' AND '6' THEN CUST_CNT2 END))  ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, ROUND(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') BETWEEN '2' AND '6' THEN SALE_AMT2 END))  ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') BETWEEN '2' AND '6' THEN SALE_AMT2 END), ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') BETWEEN '2' AND '6' THEN CUST_CNT2 END), 2))  ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[                          , 4, DECODE(Y.NO, 1, ROUND(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') IN ('1', '7') THEN CUST_CNT2 END))  ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 2, ROUND(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') IN ('1', '7') THEN SALE_AMT2 END))  ]'
        ||CHR(13)||CHR(10)||Q'[                                          , 3, ROUND(DIVIDE_ZERO_DEF(AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') IN ('1', '7') THEN SALE_AMT2 END), ]'
        ||CHR(13)||CHR(10)||Q'[                                                    AVG(CASE WHEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'D') IN ('1', '7') THEN CUST_CNT2 END), 2))  ]'
        ||CHR(13)||CHR(10)||Q'[                               )  ]'
        ||CHR(13)||CHR(10)||Q'[               ) AS BEF_MONTH  ]' -- 전월
        ||CHR(13)||CHR(10)||Q'[          FROM ( ]'
        ||CHR(13)||CHR(10)||Q'[               SELECT SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_CUST_DIV, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)) OVER(PARTITION BY S.SALE_DT) AS CUST_CNT1 ]' -- 고객수
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_FILTER, 'T', S.SALE_AMT, 'G', S.GRD_AMT, S.GRD_AMT - S.VAT_AMT)) OVER(PARTITION BY S.SALE_DT) AS SALE_AMT1 ]' -- 일매출
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT2 ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS SALE_AMT2 ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT3 ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS SALE_AMT3 ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM (  ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_QTY)      AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.GRD_AMT)       AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_AMT)      AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.VAT_AMT)       AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_M_CNT)     AS ETC_M_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_F_CNT)     AS ETC_F_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.BILL_CNT)      AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.RTN_BILL_CNT)  AS RTN_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  SALE_JDS  SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE   S   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN SUBSTR(:PSV_GTO_DATE, 1, 6)||'01' AND SUBSTR(:PSV_GTO_DATE, 1, 6)||'31' ]'
        ||CHR(13)||CHR(10)||Q'[                            AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY SJ.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[                      ) S                   ]'
        ||CHR(13)||CHR(10)||Q'[               UNION ALL ]'
        ||CHR(13)||CHR(10)||Q'[               SELECT SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT1 ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS SALE_AMT1 ]'
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_CUST_DIV, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)) OVER(PARTITION BY S.SALE_DT) AS CUST_CNT2 ]' -- 고객수
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_FILTER, 'T', S.SALE_AMT, 'G', S.GRD_AMT, S.GRD_AMT - S.VAT_AMT)) OVER(PARTITION BY S.SALE_DT)        AS SALE_AMT2 ]' -- 일매출
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT3 ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS SALE_AMT3 ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM (  ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_QTY)      AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.GRD_AMT)       AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_AMT)      AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.VAT_AMT)       AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_M_CNT)     AS ETC_M_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_F_CNT)     AS ETC_F_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.BILL_CNT)      AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.RTN_BILL_CNT)  AS RTN_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  SALE_JDS  SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE   S   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT  BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM')||'01' ]' -- 전월 매출데이터
        ||CHR(13)||CHR(10)||Q'[                                                 AND TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -1), 'YYYYMM')||'31' ]'
        ||CHR(13)||CHR(10)||Q'[                            AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                            ) S                  ]'
        ||CHR(13)||CHR(10)||Q'[               UNION ALL  ]'
        ||CHR(13)||CHR(10)||Q'[               SELECT :PSV_GTO_DATE AS SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_AMT1  ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS CUST_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[                    , TO_NUMBER(NULL) AS SALE_AMT2  ]'
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_CUST_DIV, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)) AS CUST_CNT3 ]' -- 고객수
        ||CHR(13)||CHR(10)||Q'[                    , SUM(DECODE(:PSV_FILTER, 'T', S.SALE_AMT, 'G', S.GRD_AMT, S.GRD_AMT - S.VAT_AMT))        AS SALE_AMT3 ]' -- 일매출
        ||CHR(13)||CHR(10)||Q'[                 FROM (  ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  SJ.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_QTY)      AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.GRD_AMT)       AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.SALE_AMT)      AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.VAT_AMT)       AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_M_CNT)     AS ETC_M_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.ETC_F_CNT)     AS ETC_F_CNT]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.BILL_CNT)      AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SUM(SJ.RTN_BILL_CNT)  AS RTN_BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  SALE_JDS  SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  S_STORE   S   ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.COMP_CD  = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  SJ.SALE_DT BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -12), 'YYYYMM')||'01' ]' -- 전년도시점 매출데이터
        ||CHR(13)||CHR(10)||Q'[                                                AND TO_CHAR(ADD_MONTHS(TO_DATE(:PSV_GTO_DATE, 'YYYYMMDD'), -12), 'YYYYMMDD') ]'
        ||CHR(13)||CHR(10)||Q'[                            AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[                          GROUP  BY SJ.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                            ) S                  ]'
        ||CHR(13)||CHR(10)||Q'[                GROUP  BY :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[              ) X ]'
        ||CHR(13)||CHR(10)||Q'[            , (SELECT LEVEL NO FROM DUAL CONNECT BY LEVEL <= 3) Y  ]' -- 항목을 만들기 위한 임시 복제 테이블
        ||CHR(13)||CHR(10)||Q'[            , (SELECT LEVEL NO FROM DUAL CONNECT BY LEVEL <= 2) Z  ]' -- 구분을 만들기 위한 임시 복제 테이블
        ||CHR(13)||CHR(10)||Q'[        GROUP BY DECODE(Z.NO, 1, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_AMT_MONTH_SUM')     ]' -- 구분 : 총매출[월누계]
        ||CHR(13)||CHR(10)||Q'[                            , 2, FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_AMT_LAST_YEAR_SUM'))]' -- 구분 : 시점누계매출
        ||CHR(13)||CHR(10)||Q'[                            , Z.NO  ]' -- 구분 : 주말평균매출
        ||CHR(13)||CHR(10)||Q'[               , DECODE(Y.NO, 1, DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_CNT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_CNT')) ]'
        ||CHR(13)||CHR(10)||Q'[                            , 2, FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT')   ]'
        ||CHR(13)||CHR(10)||Q'[                            , 3, DECODE(:PSV_CUST_DIV, 'C', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CUST_AMT'), 'B', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_AMT'))), Y.NO ]' -- 항목 : 객단가
        ||CHR(13)||CHR(10)||Q'[       ORDER BY Z.NO, Y.NO  ]'
        ||CHR(13)||CHR(10)||Q'[  ) ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING   PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                         , PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                         , PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE
                         , PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE
                         , PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GTO_DATE
                         , PSV_CUST_DIV, PSV_FILTER, PSV_COMP_CD, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV
                         , PSV_CUST_DIV, PSV_FILTER, PSV_COMP_CD, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV
                         , PSV_GTO_DATE, PSV_CUST_DIV, PSV_FILTER, PSV_COMP_CD, PSV_GTO_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_GTO_DATE
                         , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                         , PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

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

END PKG_SALE4700;

/
