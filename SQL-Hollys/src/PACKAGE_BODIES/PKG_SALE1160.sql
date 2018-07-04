--------------------------------------------------------
--  DDL for Package Body PKG_SALE1160
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1160" AS

    PROCEDURE SP_MAIN01         /* 일자별 매출현황 */
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SALE1160L0     일자별 매출현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2015-05-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SALE1160L0
            SYSDATE     :   2015-05-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
    --    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
           ;

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=      Q'[  SELECT  A.STOR_CD, A.STOR_NM, A.SALE_DT, A.SALE_DY, A.BILL_CNT, A.SALE_AMT, A.DC_AMT, A.GRD_AMT, A.VAT_AMT, A.NET_AMT, A.R_SALE_QTY, A.R_GRD_AMT, A.CUST_CNT, A.CUST_AMT ]'
    ||chr(13)||chr(10)||Q'[    FROM  (  ]'
    ||chr(13)||chr(10)||Q'[             SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, MAX(S.STOR_NM) AS STOR_NM, A.SALE_DT, FC_GET_WEEK(A.COMP_CD , A.SALE_DT, :PSV_LANG_CD) AS SALE_DY    ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(A.BILL_CNT + A.R_BILL_CNT) AS BILL_CNT, DECODE(:PSV_CUST_DIV, 'C', SUM(A.ETC_M_CNT + A.ETC_F_CNT), SUM(A.BILL_CNT - A.R_BILL_CNT)) AS CUST_CNT, SUM(A.SALE_AMT) AS SALE_AMT, SUM(A.GRD_AMT) AS GRD_AMT, SUM(A.VAT_AMT) AS VAT_AMT, SUM(A.GRD_AMT - A.VAT_AMT) AS NET_AMT, SUM(A.DC_AMT + A.ENR_AMT) AS DC_AMT, SUM(A.R_SALE_QTY) AS RTN_QTY, SUM(A.R_GRD_AMT) AS RTN_AMT, DECODE(DECODE(:PSV_CUST_DIV, 'C', SUM(A.ETC_M_CNT + A.ETC_F_CNT), SUM(A.BILL_CNT - A.R_BILL_CNT)), 0, 0, SUM(A.GRD_AMT) / ( DECODE(:PSV_CUST_DIV, 'C', SUM(A.ETC_M_CNT + A.ETC_F_CNT), SUM(A.BILL_CNT - A.R_BILL_CNT)))) AS CUST_AMT ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_JDS A, S_STORE S   ]'
    ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD   = S.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD  = S.BRAND_CD]'
    ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD   = S.STOR_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.COMP_CD   = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  >= :PSV_GFR_DATE]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  <= :PSV_GTO_DATE]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
    ||chr(13)||chr(10)||Q'[          )  A   ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY A.BRAND_CD, A.STOR_CD, A.SALE_DT DESC   ]';

    --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR
       ls_sql USING PSV_LANG_CD, PSV_CUST_DIV, PSV_CUST_DIV, PSV_CUST_DIV, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_MAIN02         /* 지불수단별 매출현황 */
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
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 객수구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SALE1160L3     지불수단별별 매출현황
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2015-05-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SALE1160L3
            SYSDATE     :   2015-05-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
    --    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
           ;

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' A.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND A.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=      Q'[  SELECT  A.STOR_CD, A.STOR_NM, A.SALE_DT, A.SALE_DY ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_10_AMT + B.PAY_30_AMT - PAY_40_CHANGE_AMT    AS PAY_10_AMT   ]' -- 10:현금
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_10_AMT + B.PAY_30_AMT - PAY_40_CHANGE_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_10_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_20_AMT   AS PAY_20_AMT   ]' -- 20:카드
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_20_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_20_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_30_AMT   AS PAY_30_AMT   ]' -- 30:수표
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_30_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_30_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_40_AMT   AS PAY_40_AMT   ]' -- 40:상품권
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_40_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_40_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_50_AMT   AS PAY_50_AMT   ]' -- 50:식권
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_50_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_50_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_60_AMT   AS PAY_60_AMT   ]' --  60:POINT
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_60_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_60_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_67_AMT   AS PAY_67_AMT   ]' --  67:멤버십
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_67_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_67_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_68_AMT   AS PAY_68_AMT   ]' --   68:멤버십포인트
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_68_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_68_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_70_AMT   AS PAY_70_AMT   ]' --   70:기프티콘
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_70_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_70_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_7A_AMT   AS PAY_7A_AMT   ]' --   7A:모바일쿠폰
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_7A_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_7A_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_7B_AMT   AS PAY_7B_AMT   ]' --   7B:쿠팡
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_7B_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_7B_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_7C_AMT   AS PAY_7C_AMT   ]' --   7C:티몬
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_7C_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_7C_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_82_AMT   AS PAY_82_AMT   ]' --   82:카카오톡
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_82_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_82_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_83_AMT   AS PAY_83_AMT   ]' --   83:멤버십쿠폰
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_83_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_83_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_90_AMT   AS PAY_90_AMT   ]' --   90:쿠폰
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_90_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_90_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_91_AMT   AS PAY_91_AMT   ]' --   91:위메프
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_91_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_91_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_92_AMT   AS PAY_92_AMT   ]' --   92:외상대
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_92_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_92_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_A0_AMT   AS PAY_A0_AMT   ]' --   A0:외상
    ||chr(13)||chr(10)||Q'[       ,  ROUND(CASE WHEN NVL(B.PAY_AMT, 0) = 0 THEN 0 ELSE ( B.PAY_A0_AMT) / B.PAY_AMT * 100 END ,1) AS PAY_A0_RATIO ]'
    ||chr(13)||chr(10)||Q'[       ,  B.PAY_AMT      AS PAY_AMT      ]'
    ||chr(13)||chr(10)||Q'[    FROM  (  ]'
    ||chr(13)||chr(10)||Q'[             SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, MAX(S.STOR_NM) AS STOR_NM, A.SALE_DT, FC_GET_WEEK(A.COMP_CD , A.SALE_DT, :PSV_LANG_CD) AS SALE_DY    ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_JDS A, S_STORE S   ]'
    ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD   = S.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD  = S.BRAND_CD]'
    ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD   = S.STOR_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.COMP_CD   = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  >= :PSV_GFR_DATE]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT  <= :PSV_GTO_DATE]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
    ||chr(13)||chr(10)||Q'[          )  A   ]'
    ||chr(13)||chr(10)||Q'[       ,  (      ]'
    ||chr(13)||chr(10)||Q'[             SELECT  A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT    ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'10',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_10_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'20',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_20_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'30',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_30_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'40',A.PAY_AMT                                )),0) AS PAY_40_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'40',A.CHANGE_AMT + A.REMAIN_AMT              )),0) AS PAY_40_CHANGE_AMT ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'50',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_50_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'60',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_60_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'67',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_67_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'68',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_68_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'70',A.PAY_AMT                                )),0) AS PAY_70_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'7A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7A_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'7B',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7B_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'7C',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_7C_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'82',A.PAY_AMT                                )),0) AS PAY_82_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'83',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_83_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'90',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_90_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'91',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_91_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'92',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_92_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(SUM(DECODE(A.PAY_DIV,'A0',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))),0) AS PAY_A0_AMT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (NVL(SUM(DECODE(A.PAY_DIV,'10',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'20',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'30',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'40',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'50',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'60',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'67',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'68',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'70',A.PAY_AMT                                )), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'7A',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'7B',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'7C',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'82',A.PAY_AMT                                )), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'83',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'90',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'91',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'92',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) +    ]'
    ||chr(13)||chr(10)||Q'[                      NVL(SUM(DECODE(A.PAY_DIV,'A0',A.PAY_AMT - (A.CHANGE_AMT + A.REMAIN_AMT))), 0) ) AS PAY_AMT ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_JDP   A, S_STORE  S   ]'
    ||chr(13)||chr(10)||Q'[              WHERE  A.COMP_CD  = S.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.BRAND_CD = S.BRAND_CD]'
    ||chr(13)||chr(10)||Q'[                AND  A.STOR_CD  = S.STOR_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.COMP_CD  = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT >= :PSV_GFR_DATE]'
    ||chr(13)||chr(10)||Q'[                AND  A.SALE_DT <= :PSV_GTO_DATE]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
    ||chr(13)||chr(10)||Q'[          )  B   ]'
    ||chr(13)||chr(10)||Q'[   WHERE  A.COMP_CD  = B.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[     AND  A.BRAND_CD = B.BRAND_CD(+) ]'
    ||chr(13)||chr(10)||Q'[     AND  A.STOR_CD  = B.STOR_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[     AND  A.SALE_DT  = B.SALE_DT(+)  ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY A.BRAND_CD, A.STOR_CD, A.SALE_DT DESC   ]';

    --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR
       ls_sql USING PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_MAIN03         /* 결제수단별 매출실적(Sales) */
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
        PSV_PAY_DIV     IN  VARCHAR2 ,                -- 결제수단
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SALE1160L1     결제수단별 매출실적(Sales)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2015-05-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SALE1160L1
            SYSDATE     :   2015-05-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
    --    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
           ;

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' SS.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SS.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=      Q'[  SELECT  BRAND_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_CD  ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_NM  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  CNT ]'
    ||chr(13)||chr(10)||Q'[       ,  AMT ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_CD||STOR_CD||PAY_DIV AS SUBSUM_SEQ ]'
    ||chr(13)||chr(10)||Q'[    FROM  ( ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 현금 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  '10'                AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_10_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''                  AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''                  AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.PAY_DIV <> '40' THEN SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT) ELSE -1*(SS.CHANGE_AMT + SS.REMAIN_AMT) END) AS AMT]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST  SS                 ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  IN ('10', '30', '40') ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV IS NULL OR SS.PAY_DIV = :PSV_PAY_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD              ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  COMP_CD             ]'                  -- 카드 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  BRAND_CD            ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(BRAND_NM)   AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  STOR_CD             ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(STOR_NM)    AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DIV         AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DIV_NM) AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DTL_CD      AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DTL_NM) AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CNT)        AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(AMT)        AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  (   ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  SS.COMP_CD          ]'                  -- 카드 결제수단 매출
    ||chr(13)||chr(10)||Q'[                              ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.BRAND_NM          ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.STOR_NM           ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.PAY_DIV          ]'
    ||chr(13)||chr(10)||Q'[                              ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_20_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN NVL(SF.STOR_DT_CD, '06') = '05' THEN '99'  ]'
    ||chr(13)||chr(10)||Q'[                                      ELSE SS.APPR_MAEIP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                 END AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN NVL(SF.STOR_DT_CD, '06') = '05' THEN ''  ]'
    ||chr(13)||chr(10)||Q'[                                      ELSE C.CARD_NM ]'
    ||chr(13)||chr(10)||Q'[                                 END AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END  AS CNT  ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)    AS AMT  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  SALE_ST     SS  ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_STORE     S   ]'
    ||chr(13)||chr(10)||Q'[                              ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.CARD_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  NVL(L.LANG_NM, C.CARD_NM)   AS CARD_NM  ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  CARD        C   ]'
    ||chr(13)||chr(10)||Q'[                                          ,  LANG_TABLE  L   ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  LPAD(C.BRAND_CD,4,' ') || LPAD(C.CARD_DIV,1,' ') || LPAD(C.CARD_CD,10,' ') = L.PK_COL(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.TABLE_NM(+) = 'CARD' ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.COL_NM(+) = 'CARD_NM' ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                                 )           C  ]'
    ||chr(13)||chr(10)||Q'[                              ,  STORE_FLAG  SF ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = C.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.APPR_MAEIP_CD = C.CARD_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = SF.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.BRAND_CD = SF.BRAND_CD(+)]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.STOR_CD  = SF.STOR_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.PAY_DIV  = '20' ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                            AND  (:PSV_PAY_DIV IS NULL OR SS.PAY_DIV = :PSV_PAY_DIV) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SF.STOR_FG(+) = '01']'
    ||chr(13)||chr(10)||Q'[                            AND  SF.USE_YN(+)  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )   ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY COMP_CD, BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD  ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 상품권 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_40_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.APPR_MAEIP_CD    AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(G.GIFT_NM)      AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SS.PAY_AMT)     AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  G.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  G.GIFT_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.LANG_NM, G.GIFT_NM)   AS GIFT_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  GIFT_CODE_MST   G ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_TABLE  L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  G.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  LPAD(G.GIFT_CD, 2, ' ') = L.PK_COL(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  G.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  G.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.TABLE_NM(+) = 'GIFT_CODE_MST' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.COL_NM(+) = 'GIFT_NM' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           G  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = G.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.APPR_MAEIP_CD = G.GIFT_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = '40' ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV IS NULL OR SS.PAY_DIV = :PSV_PAY_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV, SS.APPR_MAEIP_CD ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 식권 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_50_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.APPR_MAEIP_CD    AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(C.CODE_NM)      AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))           AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  COMMON      C   ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_COMMON L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP = L.CODE_TP(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_CD = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP   = '01155' ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           C  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = C.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.APPR_MAEIP_CD = C.CODE_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = '50' ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV IS NULL OR SS.PAY_DIV = :PSV_PAY_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV, SS.APPR_MAEIP_CD ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 현금, 카드, 상품권, 식권을 제외한 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(C.CODE_NM)  AS PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''              AS PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''              AS PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)     AS CNT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN PAY_DIV IN ('70', '82') THEN SS.PAY_AMT ]'
    ||chr(13)||chr(10)||Q'[                              ELSE SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT) ]'
    ||chr(13)||chr(10)||Q'[                         END)        AS AMT  ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  COMMON      C   ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_COMMON L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP = L.CODE_TP(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_CD = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP   = '00490' ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           C  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = C.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = C.CODE_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  NOT IN ('10', '20', '30', '40', '50') ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV IS NULL OR SS.PAY_DIV = :PSV_PAY_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV ]'
    ||chr(13)||chr(10)||Q'[          ) ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD]';

    --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR
       ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_PAY_DIV, PSV_PAY_DIV, 
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_PAY_DIV, PSV_PAY_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_PAY_DIV, PSV_PAY_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_PAY_DIV, PSV_PAY_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_PAY_DIV, PSV_PAY_DIV;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

    PROCEDURE SP_MAIN04         /* 결제수단별 매출실적(Non Sales) */
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
        PSV_PAY_DIV     IN  VARCHAR2 ,                -- 결제수단
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SALE1160L2     결제수단별 매출실적(Non Sales)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2015-05-08         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SALE1160L2
            SYSDATE     :   2015-05-08
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
    --    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' SD.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SD.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=      Q'[  SELECT  BRAND_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_CD  ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_NM  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  QTY ]'
    ||chr(13)||chr(10)||Q'[       ,  AMT ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_CD||STOR_CD||PAY_DIV AS SUBSUM_SEQ ]'
    ||chr(13)||chr(10)||Q'[    FROM  ( ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SD.COMP_CD          ]'                  -- 할인수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SD.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SD.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  '10'                AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DC')           AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  TO_CHAR(SD.DC_DIV)  AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(D.DC_NM)        AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SD.SALE_QTY)    AS QTY          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SD.DC_AMT + SD.ENR_AMT)      AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_JDD  SD                ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  D.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  D.BRAND_CD      ]'
    ||chr(13)||chr(10)||Q'[                              ,  D.DC_DIV        ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM]'
    ||chr(13)||chr(10)||Q'[                           FROM  DC      D       ]'
    ||chr(13)||chr(10)||Q'[                              ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                                          ,  PK_COL      ]'
    ||chr(13)||chr(10)||Q'[                                          ,  LANG_NM     ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  LANG_TABLE  ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                        AND  TABLE_NM    = 'DC'          ]'
    ||chr(13)||chr(10)||Q'[                                        AND  COL_NM      = 'DC_NM'       ]'
    ||chr(13)||chr(10)||Q'[                                        AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||Q'[                                        AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||Q'[                                 )       L       ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  L.COMP_CD(+) = D.COMP_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.PK_COL(+)  = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ') ]'
    ||chr(13)||chr(10)||Q'[                            AND  D.COMP_CD    = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                     )           D               ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SD.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.COMP_CD  = D.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.BRAND_CD = CASE WHEN D.BRAND_CD = '0000' THEN SD.BRAND_CD ELSE D.BRAND_CD END ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.DC_DIV   = D.DC_DIV      ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.FREE_DIV = '0'           ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SD.COMP_CD, SD.BRAND_CD, SD.STOR_CD, SD.DC_DIV   ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                  ,  BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(BRAND_NM)       AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(STOR_NM)        AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DIV     ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DIV_NM)     AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DTL_CD  ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DTL_NM)     AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(QTY)            AS QTY          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(AMT)            AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  (           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  SD.COMP_CD      ]'                  -- 서비스 매출
    ||chr(13)||chr(10)||Q'[                              ,  SD.BRAND_CD     ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.BRAND_NM      ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.STOR_CD      ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.STOR_NM       ]'
    ||chr(13)||chr(10)||Q'[                              ,  '20'            AS PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[                              ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SERVICE')  AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.FREE_DIV     AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_NM       AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.SALE_QTY     AS QTY  ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.SALE_AMT     AS AMT  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  SALE_JDD  SD                ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_ITEM    I                 ]'
    ||chr(13)||chr(10)||Q'[                              ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM    ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.VAL_C1        ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  COMMON  C       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                                 SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                                                      ,  CODE_CD     ]'
    ||chr(13)||chr(10)||Q'[                                                      ,  CODE_NM     ]'
    ||chr(13)||chr(10)||Q'[                                                   FROM  LANG_COMMON ]'
    ||chr(13)||chr(10)||Q'[                                                  WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  CODE_TP     = '00460'       ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||Q'[                                             )       L       ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  C.COMP_CD   = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.CODE_CD   = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.COMP_CD   = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.CODE_TP   = '00460'      ]'
    ||chr(13)||chr(10)||Q'[                                 )           C               ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  SD.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = I.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.ITEM_CD  = I.ITEM_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = C.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.FREE_DIV = C.CODE_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.FREE_DIV NOT IN ('0', '1', '9', '10') ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.SALE_DT >= :PSV_GFR_DATE ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.SALE_DT <= :PSV_GTO_DATE ]'
    ||chr(13)||chr(10)||Q'[                     )          ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY COMP_CD, BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[          ) ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD]';

    --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR
       ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
END PKG_SALE1160;

/
