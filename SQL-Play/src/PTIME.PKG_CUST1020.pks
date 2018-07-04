CREATE OR REPLACE PACKAGE      PKG_CUST1020 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_CUST1020
    --  Description      : 매장별 회원 판매현황
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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
        
END PKG_CUST1020;

/

CREATE OR REPLACE PACKAGE BODY      PKG_CUST1020 AS

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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01    점포
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    
    ls_sql_cm       VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01760') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BRAND_NM)           AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)            AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT)           AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(BILL_CNT)           AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_QTY)           AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_AMT)           AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT)             AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AFTER_DC_AMT)       AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.BRAND_NM)                                     AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.STOR_NM)                                      AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM') AS SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  SUM(SUM(1)) OVER (PARTITION  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.STOR_CD, CM.CUST_ID)  AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.BILL_CNT), 0)                            AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_QTY), 0)                            AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0)                            AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0)    AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0) - (NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0))   AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[              FROM  THE ( SELECT CAST(FC_GET_AUTH_STORE_INFO(:PSV_COMP_CD, :PSV_USER) AS TBL_STORE_INFO ) FROM DUAL ) A]'
        ||CHR(13)||CHR(10)||Q'[                 ,  C_CUST_DSS  CM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  ]'||ls_sql_cm||Q'[     C   ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  A.COMP_CD  = CM.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = S.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = S.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.COMP_CD = C.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.CUST_AGE BETWEEN C.VAL_N1 AND C.VAL_N2]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_LVL_CD    IS NULL OR CM.CUST_LVL = :PSV_LVL_CD)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_SEX_DIV   IS NULL OR CM.CUST_SEX = :PSV_SEX_DIV)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_AGE_GROUP IS NULL OR C.CODE_CD   = :PSV_AGE_GROUP)]'
        ||CHR(13)||CHR(10)||Q'[             GROUP  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.BRAND_CD, CM.STOR_CD, CM.CUST_ID]'
        ||CHR(13)||CHR(10)||Q'[          )]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_YM, BRAND_CD, STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, STOR_CD, SALE_YM]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_USER,
                         PSV_COMP_CD, 
                         PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_LVL_CD, PSV_LVL_CD, 
                         PSV_SEX_DIV, PSV_SEX_DIV,
                         PSV_AGE_GROUP, PSV_AGE_GROUP;

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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02    회원등급
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM

    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_cm       VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01760') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BRAND_NM)           AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)            AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[      ,  CUST_LVL]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(CUST_LVL_NM)        AS CUST_LVL_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT)           AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(BILL_CNT)           AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_QTY)           AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_AMT)           AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT)             AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AFTER_DC_AMT)       AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.BRAND_NM)                                     AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.STOR_NM)                                      AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM') AS SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CM.CUST_LVL]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(CL.LVL_NM)                                      AS CUST_LVL_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  SUM(SUM(1)) OVER (PARTITION  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.STOR_CD, CM.CUST_ID, CM.CUST_LVL)  AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.BILL_CNT), 0)                            AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_QTY), 0)                            AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0)                            AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0)    AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0) - (NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0))   AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[              FROM  THE ( SELECT CAST(FC_GET_AUTH_STORE_INFO(:PSV_COMP_CD, :PSV_USER) AS TBL_STORE_INFO ) FROM DUAL ) A]'
        ||CHR(13)||CHR(10)||Q'[                 ,  C_CUST_DSS  CM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  ]'||ls_sql_cm||Q'[     C   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  (]'
        ||CHR(13)||CHR(10)||Q'[                       SELECT  CL.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                            ,  CL.LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[                            ,  NVL(L.LANG_NM, CL.LVL_NM)   AS LVL_NM]'
        ||CHR(13)||CHR(10)||Q'[                         FROM  C_CUST_LVL  CL]'
        ||CHR(13)||CHR(10)||Q'[                            ,  (]'
        ||CHR(13)||CHR(10)||Q'[                                 SELECT  COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  PK_COL]'
        ||CHR(13)||CHR(10)||Q'[                                      ,  LANG_NM]'
        ||CHR(13)||CHR(10)||Q'[                                   FROM  LANG_TABLE]'
        ||CHR(13)||CHR(10)||Q'[                                  WHERE  COMP_CD     = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  TABLE_NM    = 'C_CUST_LVL']'
        ||CHR(13)||CHR(10)||Q'[                                    AND  COL_NM      = 'LVL_NM']'
        ||CHR(13)||CHR(10)||Q'[                                    AND  LANGUAGE_TP = :PSV_LANG_CD]'
        ||CHR(13)||CHR(10)||Q'[                                    AND  USE_YN      = 'Y']'
        ||CHR(13)||CHR(10)||Q'[                               )           L]'
        ||CHR(13)||CHR(10)||Q'[                        WHERE  L.COMP_CD(+)    = CL.COMP_CD]' 
        ||CHR(13)||CHR(10)||Q'[                          AND  L.PK_COL(+)     = LPAD(CL.LVL_CD, 10, ' ')]'
        ||CHR(13)||CHR(10)||Q'[                          AND  CL.COMP_CD      = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                          AND  CL.USE_YN       = 'Y']'
        ||CHR(13)||CHR(10)||Q'[                    )           CL]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  A.COMP_CD  = CM.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = S.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = S.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.COMP_CD = C.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.CUST_AGE BETWEEN C.VAL_N1 AND C.VAL_N2]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.COMP_CD = CL.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.CUST_LVL= CL.LVL_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_LVL_CD    IS NULL OR CM.CUST_LVL = :PSV_LVL_CD)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_SEX_DIV   IS NULL OR CM.CUST_SEX = :PSV_SEX_DIV)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_AGE_GROUP IS NULL OR C.CODE_CD   = :PSV_AGE_GROUP)]'
        ||CHR(13)||CHR(10)||Q'[             GROUP  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.BRAND_CD, CM.STOR_CD, CM.CUST_ID, CM.CUST_LVL]'
        ||CHR(13)||CHR(10)||Q'[          )]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_YM, BRAND_CD, STOR_CD, CUST_LVL]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, STOR_CD, SALE_YM, CUST_LVL]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_USER,
                         PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD,
                         PSV_COMP_CD, 
                         PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_LVL_CD, PSV_LVL_CD, 
                         PSV_SEX_DIV, PSV_SEX_DIV,
                         PSV_AGE_GROUP, PSV_AGE_GROUP;

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
        PSV_LVL_CD      IN  VARCHAR2 ,                -- 회원등급
        PSV_SEX_DIV     IN  VARCHAR2 ,                -- 성별 
        PSV_AGE_GROUP   IN  VARCHAR2 ,                -- 연령대
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03   연령대
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-23         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-03-23
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_cm       VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01760') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BRAND_NM)           AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)            AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[      ,  CODE_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(AGE_GROUP)          AS AGE_GROUP]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT)           AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(BILL_CNT)           AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_QTY)           AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_AMT)           AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT)             AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AFTER_DC_AMT)       AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (]'
        ||CHR(13)||CHR(10)||Q'[            SELECT  CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.BRAND_NM)                                     AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(S.STOR_NM)                                      AS STOR_NM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM') AS SALE_YM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  C.CODE_CD]'
        ||CHR(13)||CHR(10)||Q'[                 ,  MAX(C.CODE_NM)                                      AS AGE_GROUP]'
        ||CHR(13)||CHR(10)||Q'[                 ,  SUM(SUM(1)) OVER (PARTITION  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.STOR_CD, CM.CUST_ID, C.CODE_CD)  AS CUST_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.BILL_CNT), 0)                            AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_QTY), 0)                            AS SALE_QTY]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0)                            AS SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0)    AS DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[                 ,  NVL(SUM(CM.SALE_AMT), 0) - (NVL(SUM(CM.DC_AMT), 0) + NVL(SUM(CM.ENR_AMT), 0))   AS AFTER_DC_AMT]'
        ||CHR(13)||CHR(10)||Q'[              FROM  THE ( SELECT CAST(FC_GET_AUTH_STORE_INFO(:PSV_COMP_CD, :PSV_USER) AS TBL_STORE_INFO ) FROM DUAL ) A]'
        ||CHR(13)||CHR(10)||Q'[                 ,  C_CUST_DSS  CM]'
        ||CHR(13)||CHR(10)||Q'[                 ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                 ,  ]'||ls_sql_cm||Q'[     C   ]'
        ||CHR(13)||CHR(10)||Q'[             WHERE  A.COMP_CD  = CM.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = CM.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = CM.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = S.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.STOR_CD  = S.STOR_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.COMP_CD = C.COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.CUST_AGE BETWEEN C.VAL_N1 AND C.VAL_N2]'
        ||CHR(13)||CHR(10)||Q'[               AND  A.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[               AND  CM.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_LVL_CD    IS NULL OR CM.CUST_LVL = :PSV_LVL_CD)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_SEX_DIV   IS NULL OR CM.CUST_SEX = :PSV_SEX_DIV)]'
        ||CHR(13)||CHR(10)||Q'[               AND  (:PSV_AGE_GROUP IS NULL OR C.CODE_CD   = :PSV_AGE_GROUP)]'
        ||CHR(13)||CHR(10)||Q'[             GROUP  BY CM.COMP_CD, TO_CHAR(TO_DATE(CM.SALE_DT, 'YYYYMMDD'), 'YYYY-MM'), CM.BRAND_CD, CM.STOR_CD, C.CODE_CD, CM.CUST_ID]'
        ||CHR(13)||CHR(10)||Q'[          )]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_YM, BRAND_CD, STOR_CD, CODE_CD]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, STOR_CD, SALE_YM, CODE_CD]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
         OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_USER,
                         PSV_COMP_CD, 
                         PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_LVL_CD, PSV_LVL_CD, 
                         PSV_SEX_DIV, PSV_SEX_DIV,
                         PSV_AGE_GROUP, PSV_AGE_GROUP;

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
    
END PKG_CUST1020;

/
