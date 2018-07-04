CREATE OR REPLACE PACKAGE       PKG_SALE1280 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1280
   --  Description      : 모바일 쿠폰 승인 조회 
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE1280;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1280 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     모바일 쿠폰 승인 조회(유통사)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- 쿠폰구분
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- 사용건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     모바일 쿠폰 승인 조회(영업조직)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- 쿠폰구분
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- 사용건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03     모바일 쿠폰 승인 조회(점포)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD                                                      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM                              ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- 쿠폰구분
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- 사용건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04     모바일 쿠폰 승인 조회(일자)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                                     ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)     AS DSTN_COMP_NM                         ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD                                                     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)         AS BRAND_NM                             ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD                                                      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM                              ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_DT                                                       ]'  -- 사용일자
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, CH.USE_DT, :PSV_LANG_CD)  AS USE_DY   ]'  -- 요일
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV                                                   ]'  -- 쿠폰구분
        ||CHR(13)||CHR(10)||Q'[      ,  COUNT(CH.CERT_NO)                                   AS USE_CNT  ]'  -- 사용건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT))   AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CI.SALE_AMT)                                    AS SALE_AMT ]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_COUPON_DIV      IN  VARCHAR2 ,                  -- 쿠폰구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05     모바일 쿠폰 승인 조회(상세정보)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-06-03
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP         ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.DSTN_COMP_NM      ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM          ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM           ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_DT           ]'  -- 사용일자
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, CH.USE_DT, :PSV_LANG_CD)  AS USE_DY  ]'  -- 요일
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_TM           ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[      ,  CM.COUPON_DIV       ]'  -- 쿠폰구분
        ||CHR(13)||CHR(10)||Q'[      ,  CH.USE_STAT         ]'  -- 사용상태
        ||CHR(13)||CHR(10)||Q'[      ,  CH.CERT_NO          ]'  -- 쿠폰번호
        ||CHR(13)||CHR(10)||Q'[      ,  DECRYPT(M.MEMBER_NM)                                AS CUST_NM  ]'  -- 회원명
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(DECRYPT(CH.MOBILE))             AS MOBILE   ]'  -- 핸드폰
        ||CHR(13)||CHR(10)||Q'[      ,  ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT)        AS USE_AMT  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CI.SALE_AMT                                         AS SALE_AMT ]'  -- 판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  CH.RETURN_MSG       ]'  -- 결과메세지
        ||CHR(13)||CHR(10)||Q'[   FROM  M_COUPON_CUST_HIS   CH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_MST        CM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_COUPON_ITEM       CI  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE             S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_ST             ST  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CS_MEMBER           M   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CH.COMP_CD  = CM.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CM.COUPON_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = CI.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COUPON_CD= CI.COUPON_CD  ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.ITEM_CD  = CI.ITEM_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = S.COMP_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = S.BRAND_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = S.STOR_CD     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = ST.COMP_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   = ST.SALE_DT    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BRAND_CD = ST.BRAND_CD   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.STOR_CD  = ST.STOR_CD    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.POS_NO   = ST.POS_NO     ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.BILL_NO  = ST.BILL_NO    ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CERT_NO  = ST.CERT_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = M.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CH.CUST_ID  = M.MEMBER_NO   ]'  
        ||CHR(13)||CHR(10)||Q'[    AND  CH.COMP_CD  = :PSV_COMP_CD  ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_STAT IN ('10', '11', '12', '13') ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  CH.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_COUPON_DIV IS NULL OR CM.COUPON_DIV = :PSV_COUPON_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV  = :PSV_RENTAL_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, CH.BRAND_CD, CH.STOR_CD, CH.USE_DT, CM.COUPON_DIV, CH.USE_TM ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COUPON_DIV, PSV_COUPON_DIV, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE1280;

/
