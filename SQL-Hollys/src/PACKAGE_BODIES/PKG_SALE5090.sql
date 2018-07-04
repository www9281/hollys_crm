--------------------------------------------------------
--  DDL for Package Body PKG_SALE5090
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE5090" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01        일/월별 매출집계(일별) 
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-26         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB01
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SALE_DT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN GRD_AMT  / STORE_CNT ELSE 0 END     AS AVG_GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CUST_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN CUST_CNT / STORE_CNT ELSE 0 END    AS AVG_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CUST_CNT  > 0 THEN GRD_AMT  / CUST_CNT  ELSE 0 END    AS CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BILL_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN BILL_CNT / STORE_CNT ELSE 0 END    AS AVG_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN BILL_CNT  > 0 THEN GRD_AMT  / BILL_CNT  ELSE 0 END    AS BILL_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD')              AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))  AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT - SJ.R_BILL_CNT)    AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.SALE_DT               ]'
        ||CHR(13)||CHR(10)||Q'[         )               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DT      ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
        PSV_GFR_YM      IN  VARCHAR2 ,                -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                -- 조회 종료년월
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     일/월별 매출집계(월별)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-19         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_TAB02
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SALE_DT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE_CNT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN GRD_AMT  / STORE_CNT ELSE 0 END    AS AVG_GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CUST_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN CUST_CNT / STORE_CNT ELSE 0 END    AS AVG_CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CUST_CNT  > 0 THEN GRD_AMT  / CUST_CNT  ELSE 0 END    AS CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  BILL_CNT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN STORE_CNT > 0 THEN BILL_CNT / STORE_CNT ELSE 0 END    AS AVG_BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN BILL_CNT  > 0 THEN GRD_AMT  / BILL_CNT  ELSE 0 END    AS BILL_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM') AS SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))  AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(DISTINCT SJ.STOR_CD)          AS STORE_CNT]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT - SJ.R_BILL_CNT)    AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SUBSTR(SJ.SALE_DT, 1, 6) BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'YYYY-MM') ]'
        ||CHR(13)||CHR(10)||Q'[         )               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SALE_DT      ]';

        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM, PSV_GIFT_DIV, PSV_GIFT_DIV;

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

END PKG_SALE5090;

/
