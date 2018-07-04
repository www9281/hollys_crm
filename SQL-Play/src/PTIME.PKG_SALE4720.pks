CREATE OR REPLACE PACKAGE       PKG_SALE4720 AS
    -----------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4720
    --  Description      : 매출관리> 매출분석 > 영업일보
    -- Ref. Table        :
    -----------------------------------------------------------------------------
    --  Create Date      : 2011-06-29
    --  Modify Date      :
    -----------------------------------------------------------------------------

    PROCEDURE SP_SALE
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

    PROCEDURE SP_PAY
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TIME
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_LCLASS
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_MCLASS
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_BEST
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_WORST
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE4720;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4720 AS

    PROCEDURE SP_SALE
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SALE       매출액 대비 실적 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_SALE
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    PSV_PREV_DAY    VARCHAR2(20);          -- 하루전
    PSV_PREV_WEEK   VARCHAR2(20);          -- 7일전
    PSV_PREV_MONTH  VARCHAR2(20);          -- 전월동일
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        -- 1일전
        SELECT TO_CHAR(TO_DATE(PSV_SALE_DT, 'YYYYMMDD') - 1, 'YYYYMMDD') INTO PSV_PREV_DAY FROM DUAL;
        -- 7일전
        SELECT TO_CHAR(TO_DATE(PSV_SALE_DT, 'YYYYMMDD') - 7, 'YYYYMMDD') INTO PSV_PREV_WEEK FROM DUAL;
        -- 전월 동일
        SELECT TO_CHAR(ADD_MONTHS(TO_DATE(PSV_SALE_DT, 'YYYYMMDD'), -1), 'YYYYMMDD') INTO PSV_PREV_MONTH FROM DUAL;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT DIV ]'
        ||CHR(13)||CHR(10)||Q'[      , TOT_GRD_AMT AS TOT_SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(NUM, '2', DECODE(TOT_GRD_AMT, 0, 0, ROUND((LAG(TOT_GRD_AMT , 1) OVER(ORDER BY NUM) - TOT_GRD_AMT) / TOT_GRD_AMT * 100, 2))||'%',                                ]'
        ||CHR(13)||CHR(10)||Q'[                    '3', DECODE(TOT_GRD_AMT, 0, 0, ROUND((LAG(TOT_GRD_AMT , 2) OVER(ORDER BY NUM) - TOT_GRD_AMT) / TOT_GRD_AMT * 100, 2))||'%',                                ]'
        ||CHR(13)||CHR(10)||Q'[                    '4', DECODE(TOT_GRD_AMT, 0, 0, ROUND((LAG(TOT_GRD_AMT , 3) OVER(ORDER BY NUM) - TOT_GRD_AMT) / TOT_GRD_AMT * 100, 2))||'%') AS GRD_AMT_RATE               ]'
        ||CHR(13)||CHR(10)||Q'[      , TOT_CUST_CNT AS TOT_CUST_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(NUM, '2', DECODE(TOT_CUST_CNT, 0, 0, ROUND((LAG(TOT_CUST_CNT, 1) OVER(ORDER BY NUM) - TOT_CUST_CNT) / TOT_CUST_CNT * 100, 2))||'%',                               ]'
        ||CHR(13)||CHR(10)||Q'[                    '3', DECODE(TOT_CUST_CNT, 0, 0, ROUND((LAG(TOT_CUST_CNT, 2) OVER(ORDER BY NUM) - TOT_CUST_CNT) / TOT_CUST_CNT * 100, 2))||'%',                               ]'
        ||CHR(13)||CHR(10)||Q'[                    '4', DECODE(TOT_CUST_CNT, 0, 0, ROUND((LAG(TOT_CUST_CNT, 3) OVER(ORDER BY NUM) - TOT_CUST_CNT) / TOT_CUST_CNT * 100, 2))||'%') AS CUST_RATE                 ]'
        ||CHR(13)||CHR(10)||Q'[      , TOT_CUST_AMT AS TOT_CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[  FROM (                             ]'
        ||CHR(13)||CHR(10)||Q'[        SELECT DECODE(DIV, '1', Y.D_DAY || ' (' || TO_CHAR(TO_DATE(:PSV_SALE_DT   , 'YYYYMMDD'), 'YYYY-MM-DD') || ')' ]'
        ||CHR(13)||CHR(10)||Q'[                         , '2', Y.D_1   || ' (' || TO_CHAR(TO_DATE(:PSV_PREV_DAY  , 'YYYYMMDD'), 'YYYY-MM-DD') || ')' ]'
        ||CHR(13)||CHR(10)||Q'[                         , '3', Y.D_7   || ' (' || TO_CHAR(TO_DATE(:PSV_PREV_WEEK , 'YYYYMMDD'), 'YYYY-MM-DD') || ')' ]'
        ||CHR(13)||CHR(10)||Q'[                         , '4', Y.M_1   || ' (' || TO_CHAR(TO_DATE(:PSV_PREV_MONTH, 'YYYYMMDD'), 'YYYY-MM-DD') || ')') AS DIV ]'
        ||CHR(13)||CHR(10)||Q'[             , TOT_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[             , TOT_GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[             , TOT_CUST_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[             , TOT_CUST_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[             , DIV AS NUM    ]'
        ||CHR(13)||CHR(10)||Q'[         FROM (              ]'
        ||CHR(13)||CHR(10)||Q'[                SELECT DIV   ]'-- 구분
        ||CHR(13)||CHR(10)||Q'[                     , SALE_AMT     AS TOT_SALE_AMT ]'-- 총매출액
        ||CHR(13)||CHR(10)||Q'[                     , GRD_AMT      AS TOT_GRD_AMT  ]'-- 실매출액
        ||CHR(13)||CHR(10)||Q'[                     , TOT_CUST_CNT AS TOT_CUST_CNT ]'-- 고객수
        ||CHR(13)||CHR(10)||Q'[                     , DECODE(TOT_CUST_CNT, 0, 0, GRD_AMT/TOT_CUST_CNT) AS TOT_CUST_AMT ]'-- 객단가
        ||CHR(13)||CHR(10)||Q'[                  FROM (   ]'
        ||CHR(13)||CHR(10)||Q'[                        SELECT  A.DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  NVL(B.SALE_AMT, 0)      AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  NVL(B.GRD_AMT, 0)       AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  NVL(B.TOT_CUST_CNT, 0)  AS TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                          FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                                    SELECT  CASE WHEN YMD = :PSV_SALE_DT     THEN '1'  ]'-- 당일
        ||CHR(13)||CHR(10)||Q'[                                                 WHEN YMD = :PSV_PREV_DAY    THEN '2'  ]'-- 전일
        ||CHR(13)||CHR(10)||Q'[                                                 WHEN YMD = :PSV_PREV_WEEK   THEN '3'  ]'-- 전주동요일
        ||CHR(13)||CHR(10)||Q'[                                                 WHEN YMD = :PSV_PREV_MONTH  THEN '4'  ]'-- 전월동일
        ||CHR(13)||CHR(10)||Q'[                                            END AS DIV ]'
        ||CHR(13)||CHR(10)||Q'[                                      FROM  CALENDAR ]'
        ||chr(13)||chr(10)||Q'[                                     WHERE  YMD IN ( :PSV_SALE_DT, :PSV_PREV_DAY, :PSV_PREV_WEEK, :PSV_PREV_MONTH ) ]'
        ||CHR(13)||CHR(10)||Q'[                                ) A ]'
        ||CHR(13)||CHR(10)||Q'[                             ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[                                    SELECT CASE WHEN SALE_DT = :PSV_SALE_DT      THEN '1'  ]'-- 당일계
        ||CHR(13)||CHR(10)||Q'[                                                WHEN SALE_DT = :PSV_PREV_DAY     THEN '2'  ]'-- 전일계
        ||CHR(13)||CHR(10)||Q'[                                                WHEN SALE_DT = :PSV_PREV_WEEK    THEN '3'  ]'-- 전주동요일
        ||CHR(13)||CHR(10)||Q'[                                                WHEN SALE_DT = :PSV_PREV_MONTH   THEN '4'  ]'-- 전월동요일
        ||CHR(13)||CHR(10)||Q'[                                            END AS DIV ]'
        ||CHR(13)||CHR(10)||Q'[                                         ,  SUM(A.SALE_AMT) AS SALE_AMT                                 ]'
        ||CHR(13)||CHR(10)||Q'[                                         ,  SUM(A.GRD_AMT) AS GRD_AMT                                   ]'
        ||chr(13)||chr(10)||Q'[                                         ,  SUM(DECODE(:PSV_CUST_DIV, 'C', ETC_M_CNT + ETC_F_CNT, BILL_CNT - RTN_BILL_CNT)) AS TOT_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                                      FROM  SALE_JDS A, S_STORE B   ]'
        ||CHR(13)||CHR(10)||Q'[                                     WHERE  A.COMP_CD  = B.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                       AND  A.BRAND_CD = B.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                                       AND  A.STOR_CD  = B.STOR_CD  ]'
        ||chr(13)||chr(10)||Q'[                                       AND  A.COMP_CD  = :PSV_COMP_CD    ]'
        ||chr(13)||chr(10)||Q'[                                       AND  A.SALE_DT IN ( :PSV_SALE_DT, :PSV_PREV_DAY, :PSV_PREV_WEEK, :PSV_PREV_MONTH ) ]'
        ||CHR(13)||CHR(10)||Q'[                                     GROUP BY SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                                ) B ]'
        ||CHR(13)||CHR(10)||Q'[                         WHERE  A.DIV = B.DIV(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                       ) ]'
        ||CHR(13)||CHR(10)||Q'[                ) X, ]'
        ||CHR(13)||CHR(10)||Q'[                (SELECT D_DAY, D_1, D_7, M_1, MT, LMT         ]'
        ||CHR(13)||CHR(10)||Q'[                  FROM (   ]'
        ||chr(13)||chr(10)||Q'[                        SELECT FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'TOT') AS TOT           ]'-- 계
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'D-DAY') AS D_DAY       ]'-- 당일
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'D-1') AS D_1           ]'-- 전일
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'D-7') AS D_7           ]'-- 전주동요일
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'PREV_SAME_DAY') AS M_1 ]'-- 전월동일
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'MONTH_TOT') AS MT      ]'-- 당월계
        ||chr(13)||chr(10)||Q'[                             , FC_GET_WORDPACK  (:PSV_COMP_CD, :PSV_LANG_CD, 'LAST_MONTH_TOT') AS LMT]'-- 전월계
        ||CHR(13)||CHR(10)||Q'[                          FROM DUAL) ]'
        ||CHR(13)||CHR(10)||Q'[                ) Y  ]'
        ||CHR(13)||CHR(10)||Q'[     ) ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY NUM ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_SALE_DT, PSV_PREV_DAY, PSV_PREV_WEEK, PSV_PREV_MONTH, PSV_SALE_DT, PSV_PREV_DAY, PSV_PREV_WEEK, PSV_PREV_MONTH
                       , PSV_SALE_DT, PSV_PREV_DAY, PSV_PREV_WEEK, PSV_PREV_MONTH, PSV_SALE_DT, PSV_PREV_DAY, PSV_PREV_WEEK, PSV_PREV_MONTH
                       , PSV_CUST_DIV, PSV_COMP_CD, PSV_SALE_DT, PSV_PREV_DAY, PSV_PREV_WEEK, PSV_PREV_MONTH
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD;

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

    PROCEDURE SP_PAY
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_PAY       결제수단별 매출실적 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_PAY
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
        ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||chr(13)||chr(10)||Q'[ SELECT DECODE(Y.NO, '1', FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL'), FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'OCCU_RATE'))    AS DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_10_AMT + PAY_30_AMT , DECODE(PAY_AMT, 0, 0, (PAY_10_AMT + PAY_30_AMT)   / PAY_AMT * 100))) AS PAY_10_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_20_AMT           , DECODE(PAY_AMT, 0, 0, PAY_20_AMT               / PAY_AMT * 100))) AS PAY_20_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_30_AMT           , DECODE(PAY_AMT, 0, 0, PAY_30_AMT               / PAY_AMT * 100))) AS PAY_30_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_40_AMT           , DECODE(PAY_AMT, 0, 0, PAY_40_AMT               / PAY_AMT * 100))) AS PAY_40_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_50_AMT           , DECODE(PAY_AMT, 0, 0, PAY_50_AMT               / PAY_AMT * 100))) AS PAY_50_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_60_AMT           , DECODE(PAY_AMT, 0, 0, PAY_60_AMT               / PAY_AMT * 100))) AS PAY_60_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_67_AMT           , DECODE(PAY_AMT, 0, 0, PAY_67_AMT               / PAY_AMT * 100))) AS PAY_67_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_68_AMT           , DECODE(PAY_AMT, 0, 0, PAY_68_AMT               / PAY_AMT * 100))) AS PAY_68_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_69_AMT           , DECODE(PAY_AMT, 0, 0, PAY_69_AMT               / PAY_AMT * 100))) AS PAY_69_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_6A_AMT           , DECODE(PAY_AMT, 0, 0, PAY_6A_AMT               / PAY_AMT * 100))) AS PAY_6A_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_70_AMT           , DECODE(PAY_AMT, 0, 0, PAY_70_AMT               / PAY_AMT * 100))) AS PAY_70_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_7A_AMT           , DECODE(PAY_AMT, 0, 0, PAY_7A_AMT               / PAY_AMT * 100))) AS PAY_7A_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_7B_AMT           , DECODE(PAY_AMT, 0, 0, PAY_7B_AMT               / PAY_AMT * 100))) AS PAY_7B_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_7C_AMT           , DECODE(PAY_AMT, 0, 0, PAY_7C_AMT               / PAY_AMT * 100))) AS PAY_7C_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_7D_AMT           , DECODE(PAY_AMT, 0, 0, PAY_7D_AMT               / PAY_AMT * 100))) AS PAY_7D_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_82_AMT           , DECODE(PAY_AMT, 0, 0, PAY_82_AMT               / PAY_AMT * 100))) AS PAY_82_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_83_AMT           , DECODE(PAY_AMT, 0, 0, PAY_83_AMT               / PAY_AMT * 100))) AS PAY_83_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_90_AMT           , DECODE(PAY_AMT, 0, 0, PAY_90_AMT               / PAY_AMT * 100))) AS PAY_90_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_93_AMT           , DECODE(PAY_AMT, 0, 0, PAY_93_AMT               / PAY_AMT * 100))) AS PAY_93_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(DECODE(Y.NO, '1', PAY_A0_AMT           , DECODE(PAY_AMT, 0, 0, PAY_A0_AMT               / PAY_AMT * 100))) AS PAY_A0_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (   ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT NVL(SUM(DECODE(A.PAY_DIV,'10',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_10_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'20',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_20_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'30',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_30_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'40',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_40_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'50',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_50_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'60',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_60_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'67',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_67_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'68',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_68_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'69',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_69_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'6A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_6A_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'70',A.PAY_AMT                                )),0) AS PAY_70_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'7A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7A_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'7B',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7B_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'7C',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7C_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'7D',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7D_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'82',A.PAY_AMT                                )),0) AS PAY_82_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'83',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_83_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'90',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_90_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'93',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_93_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                NVL(SUM(DECODE(A.PAY_DIV,'A0',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_A0_AMT, ]'
        ||CHR(13)||CHR(10)||Q'[                (NVL(SUM(DECODE(A.PAY_DIV,'10',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'20',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'30',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'40',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'50',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'60',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'67',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'68',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'69',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'6A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'70',A.PAY_AMT                                )), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'7A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'7B',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'7C',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'7D',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'82',A.PAY_AMT                                )), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'83',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'90',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'93',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
        ||CHR(13)||CHR(10)||Q'[                 NVL(SUM(DECODE(A.PAY_DIV,'A0',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) ) AS PAY_AMT ]'
        ||CHR(13)||CHR(10)||Q'[           FROM SALE_JDP A , S_STORE S       ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE A.COMP_CD  = S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[            AND A.BRAND_CD = S.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[            AND A.STOR_CD  = S.STOR_CD       ]'
        ||chr(13)||chr(10)||Q'[            AND A.COMP_CD  = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[            AND A.SALE_DT  = :PSV_SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[        ) X, (SELECT '1' AS NO FROM DUAL UNION ALL SELECT '2' FROM DUAL) Y   ]'
        ||chr(13)||chr(10)||Q'[  GROUP BY Y.NO ]'
        ;

        ls_sql := ls_sql || ls_sql_main;
 
        dbms_output.put_line( ls_sql );
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_SALE_DT;

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



    PROCEDURE SP_TIME
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_TIME       시간대별 실적 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TIME
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT DIV                                                                                                                                                                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[      , SUM(CUST_CNT)                    AS CUST_CNT                                                                   ]'-- 고객수
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(CUST_CNT_RATE), 2)     AS CUST_CNT_RATE                                                              ]'-- 고객수점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(SALE_AMT)                    AS SALE_AMT                                                                   ]'-- 매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(SALE_AMT_RATE), 2)     AS SALE_AMT_RATE                                                              ]'-- 총매출액점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(DC_AMT)                      AS DC_AMT                                                                     ]'-- 할인금액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(DC_AMT_RATE), 2)       AS DC_AMT_RATE                                                                ]'-- 할인금액점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(GRD_AMT)                     AS GRD_AMT                                                                    ]'-- 실매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(GRD_AMT_RATE), 2)      AS GRD_AMT_RATE                                                               ]'-- 실매출액점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(NET_AMT)                     AS NET_AMT                                                                    ]'-- 순매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(NET_AMT_RATE), 2)      AS NET_AMT_RATE                                                               ]'-- 순매출액점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(VAT_AMT)                     AS VAT_AMT                                                                    ]'-- 부가세
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(VAT_AMT_RATE), 2)      AS VAT_AMT_RATE                                                               ]'-- 부가세점유비
        ||CHR(13)||CHR(10)||Q'[   FROM (                                                                                                              ]'
        ||CHR(13)||CHR(10)||Q'[           SELECT Y.START_TIME || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'FROM_TIME')||' ~ '||  ]'
        ||CHR(13)||CHR(10)||Q'[                  Y.CLOSE_TIME || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BEFORE_TIME') AS DIV  ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(CUST_CNT, 0)    AS CUST_CNT                                                                       ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(SALE_AMT, 0)    AS SALE_AMT                                                                       ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(DC_AMT, 0)      AS DC_AMT                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(GRD_AMT, 0)     AS GRD_AMT                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(NET_AMT, 0)     AS NET_AMT                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[               , NVL(VAT_AMT, 0)     AS VAT_AMT                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(CUST_CNT, 0), 0, 0, NVL(CUST_CNT, 0) / SUM(CUST_CNT) OVER() * 100) AS CUST_CNT_RATE        ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(SALE_AMT, 0), 0, 0, NVL(SALE_AMT, 0) / SUM(SALE_AMT) OVER() * 100) AS SALE_AMT_RATE        ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(DC_AMT, 0), 0, 0, NVL(DC_AMT, 0) / SUM(DC_AMT) OVER() * 100)       AS DC_AMT_RATE          ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(GRD_AMT, 0), 0, 0, NVL(GRD_AMT, 0) / SUM(GRD_AMT) OVER() * 100)    AS GRD_AMT_RATE         ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(NET_AMT, 0), 0, 0, NVL(NET_AMT, 0) / SUM(NET_AMT) OVER() * 100)    AS NET_AMT_RATE         ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NVL(VAT_AMT, 0), 0, 0, NVL(VAT_AMT, 0) / SUM(VAT_AMT) OVER() * 100)    AS VAT_AMT_RATE         ]'
        ||CHR(13)||CHR(10)||Q'[            FROM (SELECT SEC_DIV                                                                                       ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DECODE(:PSV_CUST_DIV, 'C', ETC_M_CNT + ETC_F_CNT, BILL_CNT - RTN_BILL_CNT)) AS CUST_CNT   ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(SALE_AMT)           AS SALE_AMT                                                           ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(DC_AMT + ENR_AMT)   AS DC_AMT                                                             ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(GRD_AMT)            AS GRD_AMT                                                            ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(GRD_AMT - VAT_AMT)  AS NET_AMT                                                            ]'
        ||CHR(13)||CHR(10)||Q'[                       , SUM(VAT_AMT)            AS VAT_AMT                                                            ]'
        ||CHR(13)||CHR(10)||Q'[                    FROM SALE_JTO S , S_STORE B                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[                   WHERE S.COMP_CD  = B.COMP_CD                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[                     AND S.BRAND_CD = B.BRAND_CD                                                                       ]'
        ||CHR(13)||CHR(10)||Q'[                     AND S.STOR_CD  = B.STOR_CD                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[                     AND S.COMP_CD  = :PSV_COMP_CD                                                                     ]'
        ||CHR(13)||CHR(10)||Q'[                     AND S.SALE_DT  = :PSV_SALE_DT                                                                     ]'
        ||CHR(13)||CHR(10)||Q'[                     AND S.SEC_FG   = :PSV_SEC_FG                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                   GROUP BY SEC_DIV                                                                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 ) X,                                                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[                 (SELECT LPAD(LEVEL-02, 2, '0') AS START_TIME, LPAD(LEVEL, 2, '0') AS CLOSE_TIME                       ]'
        ||CHR(13)||CHR(10)||Q'[                    FROM DUAL WHERE MOD(LEVEL/2, 1) = 0 CONNECT BY LEVEL <= 24 ) Y                                     ]'
        ||CHR(13)||CHR(10)||Q'[           WHERE X.SEC_DIV(+) >= Y.START_TIME AND X.SEC_DIV(+) < Y.CLOSE_TIME                                          ]'
        ||CHR(13)||CHR(10)||Q'[        )                                                                                                              ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP BY DIV                                                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY DIV                                                                                                         ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_CUST_DIV, PSV_COMP_CD, PSV_SALE_DT, PSV_SEC_FG;

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


    PROCEDURE SP_LCLASS
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_LCLASS       대분류별 실적 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_LCLASS
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT L_CLASS_NM                                                                                                                                                                                    ]'-- 대분류
        ||CHR(13)||CHR(10)||Q'[      , SUM(SALE_QTY)                    AS SALE_QTY                                                     ]'-- 수량
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(SALE_QTY_RATE), 2)     AS SALE_QTY_RATE                                                ]'-- 고객 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(SALE_AMT)                    AS SALE_AMT                                                     ]'-- 총매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(SALE_AMT_RATE), 2)     AS SALE_AMT_RATE                                                ]'-- 총매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(DC_AMT)                      AS DC_AMT                                                       ]'-- 할인금액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(DC_AMT_RATE), 2)       AS DC_AMT_RATE                                                  ]'-- 할인금액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(GRD_AMT)                     AS GRD_AMT                                                      ]'-- 실매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(GRD_AMT_RATE), 2)      AS GRD_AMT_RATE                                                 ]'-- 실매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(NET_AMT)                     AS NET_AMT                                                      ]'-- 순매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(NET_AMT_RATE), 2)      AS NET_AMT_RATE                                                 ]'-- 순매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(VAT_AMT)                     AS VAT_AMT                                                      ]'-- 부가세
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(VAT_AMT_RATE), 2)      AS VAT_AMT_RATE                                                 ]'-- 부가세 점유비
        ||CHR(13)||CHR(10)||Q'[   FROM (                                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT L_CLASS_NM                                                                              ]'
        ||CHR(13)||CHR(10)||Q'[               , SALE_QTY                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(SALE_QTY, 0, 0, SALE_QTY / SUM(SALE_QTY) OVER()) * 100 AS SALE_QTY_RATE          ]'
        ||CHR(13)||CHR(10)||Q'[               , SALE_AMT                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(SALE_AMT, 0, 0, SALE_AMT / SUM(SALE_AMT) OVER()) * 100 AS SALE_AMT_RATE          ]'
        ||CHR(13)||CHR(10)||Q'[               , DC_AMT                                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(DC_AMT, 0, 0, DC_AMT / SUM(DC_AMT) OVER()) * 100 AS DC_AMT_RATE                  ]'
        ||CHR(13)||CHR(10)||Q'[               , GRD_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(GRD_AMT, 0, 0, GRD_AMT / SUM(GRD_AMT) OVER()) * 100 AS GRD_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[               , NET_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NET_AMT, 0, 0, NET_AMT / SUM(NET_AMT) OVER()) * 100 AS NET_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[               , VAT_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(VAT_AMT, 0, 0, VAT_AMT / SUM(VAT_AMT) OVER()) * 100 AS VAT_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[            FROM ( SELECT  I.L_CLASS_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                         , SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                         , SALE_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                         , DC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                         , GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                         , NET_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                         , VAT_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                     FROM (SELECT  S.ITEM_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(SALE_QTY)            AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(SALE_AMT)            AS SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(DC_AMT + ENR_AMT)    AS DC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(GRD_AMT)             AS GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(GRD_AMT - VAT_AMT)   AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(VAT_AMT)             AS VAT_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                             FROM SALE_JDM S, S_STORE B                  ]'
        ||CHR(13)||CHR(10)||Q'[                            WHERE S.COMP_CD  = B.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.BRAND_CD = B.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.STOR_CD  = B.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.COMP_CD  = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.SALE_DT  = :PSV_SALE_DT              ]'
        ||CHR(13)||CHR(10)||Q'[                            GROUP BY S.ITEM_CD                           ]'
        ||CHR(13)||CHR(10)||Q'[                          ) A , S_ITEM I                                 ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE A.ITEM_CD = I.ITEM_CD(+)                      ]'
        ||CHR(13)||CHR(10)||Q'[                ) A   ]'
        ||CHR(13)||CHR(10)||Q'[        )                                                                ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP BY L_CLASS_NM                                                    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY L_CLASS_NM                                                    ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT;

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


    PROCEDURE SP_MCLASS
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_MCLASS       중분류별 실적 
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_MCLASS
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT M_CLASS_NM                                                                                                                                                                                    ]'-- 대분류
        ||CHR(13)||CHR(10)||Q'[      , SUM(SALE_QTY)                    AS SALE_QTY                                                     ]'-- 수량
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(SALE_QTY_RATE), 2)     AS SALE_QTY_RATE                                                ]'-- 고객 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(SALE_AMT)                    AS SALE_AMT                                                     ]'-- 총매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(SALE_AMT_RATE), 2)     AS SALE_AMT_RATE                                                ]'-- 총매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(DC_AMT)                      AS DC_AMT                                                       ]'-- 할인금액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(DC_AMT_RATE), 2)       AS DC_AMT_RATE                                                  ]'-- 할인금액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(GRD_AMT)                     AS GRD_AMT                                                      ]'-- 실매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(GRD_AMT_RATE), 2)      AS GRD_AMT_RATE                                                 ]'-- 실매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(NET_AMT)                     AS NET_AMT                                                      ]'-- 순매출액
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(NET_AMT_RATE), 2)      AS NET_AMT_RATE                                                 ]'-- 순매출액 점유비
        ||CHR(13)||CHR(10)||Q'[      , SUM(VAT_AMT)                     AS VAT_AMT                                                      ]'-- 부가세
        ||CHR(13)||CHR(10)||Q'[      , ROUND(SUM(VAT_AMT_RATE), 2)      AS VAT_AMT_RATE                                                 ]'-- 부가세 점유비
        ||CHR(13)||CHR(10)||Q'[   FROM (                                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT M_CLASS_NM                                                                              ]'
        ||CHR(13)||CHR(10)||Q'[               , SALE_QTY                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(SALE_QTY, 0, 0, SALE_QTY / SUM(SALE_QTY) OVER()) * 100 AS SALE_QTY_RATE          ]'
        ||CHR(13)||CHR(10)||Q'[               , SALE_AMT                                                                                ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(SALE_AMT, 0, 0, SALE_AMT / SUM(SALE_AMT) OVER()) * 100 AS SALE_AMT_RATE          ]'
        ||CHR(13)||CHR(10)||Q'[               , DC_AMT                                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(DC_AMT, 0, 0, DC_AMT / SUM(DC_AMT) OVER()) * 100 AS DC_AMT_RATE                  ]'
        ||CHR(13)||CHR(10)||Q'[               , GRD_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(GRD_AMT, 0, 0, GRD_AMT / SUM(GRD_AMT) OVER()) * 100 AS GRD_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[               , NET_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(NET_AMT, 0, 0, NET_AMT / SUM(NET_AMT) OVER()) * 100 AS NET_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[               , VAT_AMT                                                                                 ]'
        ||CHR(13)||CHR(10)||Q'[               , DECODE(VAT_AMT, 0, 0, VAT_AMT / SUM(VAT_AMT) OVER()) * 100 AS VAT_AMT_RATE              ]'
        ||CHR(13)||CHR(10)||Q'[            FROM ( SELECT  I.M_CLASS_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                         , SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[                         , SALE_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                         , DC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[                         , GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                         , NET_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                         , VAT_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                     FROM (SELECT  S.ITEM_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(SALE_QTY)            AS SALE_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(SALE_AMT)            AS SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(DC_AMT + ENR_AMT)    AS DC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(GRD_AMT)             AS GRD_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(GRD_AMT - VAT_AMT)   AS NET_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                                 , SUM(VAT_AMT)             AS VAT_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                             FROM SALE_JDM S, S_STORE B                  ]'
        ||CHR(13)||CHR(10)||Q'[                            WHERE S.COMP_CD  = B.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.BRAND_CD = B.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.STOR_CD  = B.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.COMP_CD  = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                              AND S.SALE_DT  = :PSV_SALE_DT              ]'
        ||CHR(13)||CHR(10)||Q'[                            GROUP BY S.ITEM_CD                           ]'
        ||CHR(13)||CHR(10)||Q'[                          ) A , S_ITEM I                                 ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE A.ITEM_CD = I.ITEM_CD(+)                      ]'
        ||CHR(13)||CHR(10)||Q'[                ) A   ]'
        ||CHR(13)||CHR(10)||Q'[        )                                                                ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP BY M_CLASS_NM                                                    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY M_CLASS_NM                                                    ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT;

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

    PROCEDURE SP_BEST
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_BEST       판매메뉴별 BEST매출
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_BEST
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT I.ITEM_CD                                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[      , I.ITEM_NM                                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[      , SALE_QTY                                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(SALE_QTY, 0, 0, ROUND((SALE_QTY / SUM(SALE_QTY) OVER()) * 100, 4))    AS SALE_QTY_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      , SALE_AMT                                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(SALE_AMT, 0, 0, ROUND((SALE_AMT / SUM(SALE_AMT) OVER()) * 100, 4))    AS SALE_AMT_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      , DC_AMT                                                                                           ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(DC_AMT, 0, 0, ROUND((DC_AMT / SUM(DC_AMT) OVER()) * 100, 4))          AS DC_AMT_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      , GRD_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(GRD_AMT, 0, 0, ROUND((GRD_AMT / SUM(GRD_AMT) OVER()) * 100, 4))       AS GRD_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      , NET_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(NET_AMT, 0, 0, ROUND((NET_AMT / SUM(NET_AMT) OVER()) * 100, 4))       AS NET_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      , VAT_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(VAT_AMT, 0, 0, ROUND((VAT_AMT / SUM(VAT_AMT) OVER()) * 100, 4))       AS VAT_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (SELECT ITEM_CD                                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(SALE_QTY)            AS SALE_QTY                                                     ]' -- 수량
        ||CHR(13)||CHR(10)||Q'[              , SUM(SALE_AMT)            AS SALE_AMT                                                     ]' -- 판매금액
        ||CHR(13)||CHR(10)||Q'[              , SUM(DC_AMT + ENR_AMT)    AS DC_AMT                                                       ]' -- 할인금액 + 에누리할인금액
        ||CHR(13)||CHR(10)||Q'[              , SUM(GRD_AMT)             AS GRD_AMT                                                      ]' -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[              , SUM(GRD_AMT- VAT_AMT)    AS NET_AMT                                                      ]' -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[              , SUM(VAT_AMT)             AS VAT_AMT                                                      ]' -- 부가세
        ||CHR(13)||CHR(10)||Q'[              , ROW_NUMBER() OVER(PARTITION BY SALE_DT, S.BRAND_CD, S.STOR_CD ORDER BY SALE_AMT DESC) AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[           FROM SALE_JDM S, S_STORE B                                                                    ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE S.COMP_CD  = B.COMP_CD                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.BRAND_CD = B.BRAND_CD                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.STOR_CD  = B.STOR_CD                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.COMP_CD  = :PSV_COMP_CD                                                                ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.SALE_DT  = :PSV_SALE_DT                                                                ]'
        ||CHR(13)||CHR(10)||Q'[          GROUP BY ITEM_CD, SALE_DT, S.BRAND_CD, S.STOR_CD, SALE_AMT                                     ]'
        ||CHR(13)||CHR(10)||Q'[        ) A , S_ITEM I                                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE A.ITEM_CD = I.ITEM_CD                                                                            ]'
        ||CHR(13)||CHR(10)||Q'[    AND ( A.SALE_QTY <> 0 OR A.SALE_AMT <> 0 )                                                           ]'
        ||CHR(13)||CHR(10)||Q'[    AND A.SEQ <= 20                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP BY I.ITEM_CD, I.ITEM_NM, SALE_QTY, SALE_AMT, DC_AMT, GRD_AMT, NET_AMT, VAT_AMT                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY SALE_AMT DESC                                                                                 ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT;

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

    PROCEDURE SP_WORST
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 조회일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_WORST       판매메뉴별 WORST매출
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_WORST
            SYSDATE     :   2014-08-26
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
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
    
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );
    
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT I.ITEM_CD                                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[      , I.ITEM_NM                                                                                        ]'
        ||CHR(13)||CHR(10)||Q'[      , SALE_QTY                                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(SALE_QTY, 0, 0, ROUND((SALE_QTY / SUM(SALE_QTY) OVER()) * 100, 4))    AS SALE_QTY_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      , SALE_AMT                                                                                         ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(SALE_AMT, 0, 0, ROUND((SALE_AMT / SUM(SALE_AMT) OVER()) * 100, 4))    AS SALE_AMT_RATE    ]'
        ||CHR(13)||CHR(10)||Q'[      , DC_AMT                                                                                           ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(DC_AMT, 0, 0, ROUND((DC_AMT / SUM(DC_AMT) OVER()) * 100, 4))          AS DC_AMT_RATE      ]'
        ||CHR(13)||CHR(10)||Q'[      , GRD_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(GRD_AMT, 0, 0, ROUND((GRD_AMT / SUM(GRD_AMT) OVER()) * 100, 4))       AS GRD_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      , NET_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(NET_AMT, 0, 0, ROUND((NET_AMT / SUM(NET_AMT) OVER()) * 100, 4))       AS NET_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[      , VAT_AMT                                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[      , DECODE(VAT_AMT, 0, 0, ROUND((VAT_AMT / SUM(VAT_AMT) OVER()) * 100, 4))       AS VAT_AMT_RATE     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM (SELECT ITEM_CD                                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[              , SUM(SALE_QTY)            AS SALE_QTY                                                     ]' -- 수량
        ||CHR(13)||CHR(10)||Q'[              , SUM(SALE_AMT)            AS SALE_AMT                                                     ]' -- 판매금액
        ||CHR(13)||CHR(10)||Q'[              , SUM(DC_AMT + ENR_AMT)    AS DC_AMT                                                       ]' -- 할인금액 + 에누리할인금액
        ||CHR(13)||CHR(10)||Q'[              , SUM(GRD_AMT)             AS GRD_AMT                                                      ]' -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[              , SUM(GRD_AMT- VAT_AMT)    AS NET_AMT                                                      ]' -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[              , SUM(VAT_AMT)             AS VAT_AMT                                                      ]' -- 부가세
        ||CHR(13)||CHR(10)||Q'[              , ROW_NUMBER() OVER(PARTITION BY SALE_DT, S.BRAND_CD, S.STOR_CD ORDER BY SALE_AMT) AS SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[           FROM SALE_JDM S, S_STORE B                                                                    ]'
        ||CHR(13)||CHR(10)||Q'[          WHERE S.COMP_CD  = B.COMP_CD                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.BRAND_CD = B.BRAND_CD                                                                  ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.STOR_CD  = B.STOR_CD                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.COMP_CD  = :PSV_COMP_CD                                                                ]'
        ||CHR(13)||CHR(10)||Q'[            AND S.SALE_DT  = :PSV_SALE_DT                                                                ]'
        ||CHR(13)||CHR(10)||Q'[          GROUP BY ITEM_CD, SALE_DT, S.BRAND_CD, S.STOR_CD, SALE_AMT                                     ]'
        ||CHR(13)||CHR(10)||Q'[        ) A , S_ITEM I                                                                                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE A.ITEM_CD = I.ITEM_CD                                                                            ]'
        ||CHR(13)||CHR(10)||Q'[    AND ( A.SALE_QTY <> 0 OR A.SALE_AMT <> 0 )                                                           ]'
        ||CHR(13)||CHR(10)||Q'[    AND A.SEQ <= 20                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP BY I.ITEM_CD, I.ITEM_NM, SALE_QTY, SALE_AMT, DC_AMT, GRD_AMT, NET_AMT, VAT_AMT                   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER BY SALE_AMT                                                                                      ]';
               
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_SALE_DT;

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

END PKG_SALE4720;

/
