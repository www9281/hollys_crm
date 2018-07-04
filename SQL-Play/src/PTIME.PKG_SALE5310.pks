CREATE OR REPLACE PACKAGE       PKG_SALE5310 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE5310
    --  Description      : 일별 TREND 매출현황
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
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
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
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
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB05
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB06
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB07
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE5310;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE5310 AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    일별 TREND 매출현황(영업조직)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    일별 TREND 매출현황(부서)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)  AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, DEPT_CD ]';
        
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
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03    일별 TREND 매출현황(팀)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)  AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)  AS TEAM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, DEPT_CD, TEAM_CD ]';
        
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
        PSV_ORDER_BY    IN  VARCHAR2,                 -- 일자 정렬(ASC,DESC)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04    일별 TREND 매출현황(영업담당자)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT          AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, DEPT_CD, TEAM_CD, SV_USER_ID ]';
        
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
    
    PROCEDURE SP_TAB05
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05    일별 TREND 매출현황(점포)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DEPT_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TEAM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_USER_ID')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DEPT_NM)      AS DEPT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TEAM_NM)      AS TEAM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.SV_USER_NM)   AS SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT          AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.DEPT_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD      ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, DEPT_CD, TEAM_CD, SV_USER_ID, STOR_CD ]';
        
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
    
    PROCEDURE SP_TAB06
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB06    일별 TREND 매출현황(지역)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB06
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGION')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGION')       ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGION')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'REGION')       ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.REGION_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.REGION_NM)    AS REGION_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT          AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.REGION_CD     ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, REGION_CD ]';
        
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
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
    
    PROCEDURE SP_TAB07
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB07    일별 TREND 매출현황(상권)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB07
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT       VARCHAR2(8)
        ,   SALE_DT_NM    VARCHAR2(20)
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
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;
               
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')   AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_DT ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRAD_AREA')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRAD_AREA')    ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRAD_AREA')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRAD_AREA')    ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*7 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_CNT')    || Q'[' AS CT]' || TO_CHAR(i*7 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STORE_DAYS_AVG_SALE') || Q'[' AS CT]' || TO_CHAR(7*7 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*7 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_AMT')     || Q'[' AS CT]' || TO_CHAR(i*7);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.TRAD_AREA_NM) AS TRAD_AREA_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT          AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))                          AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN COUNT(DISTINCT SJ.STOR_CD) > 0 THEN ROUND(SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / COUNT(DISTINCT SJ.STOR_CD)) ELSE 0 END AS AVG_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))       AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT)  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT)) / SUM(SJ.BILL_CNT + SJ.RTN_BILL_CNT))   AS BILL_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TRAD_AREA     ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(GRD_AMT)      AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(STORE_CNT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AVG_AMT)      AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)     AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_CNT)     AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(BILL_AMT)     AS VCOL7 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, TRAD_AREA ]';
        
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
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
    
END PKG_SALE5310;

/
