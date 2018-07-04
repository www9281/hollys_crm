CREATE OR REPLACE PACKAGE       PKG_MEPA1040 AS
/******************************************************************************
   NAME:       PKG_MEPA1040
   PURPOSE:    소멸예정 포인트 조회   

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2016-03-25      KKJ       1. Created this package.
******************************************************************************/

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_MEPA1040;

/

CREATE OR REPLACE PACKAGE BODY       PKG_MEPA1040 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회일자
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      소멸예정 포인트 조회 
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-03-24         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-03-24
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
    
    ERR_HANDLER         EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01725') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CRD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(CRD.CARD_ID)    AS CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(CST.CUST_NM)    AS CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(REPLACE(decrypt(CST.MOBILE), '-', '')) AS MOBILE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.USE_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.LOS_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT    AS VAL_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(CASE WHEN NVL(CSH.T_SAV_PT, 0) > NVL(CSH.T_USE_PT, 0) THEN  NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) END, 0) AS TERM_PLAN_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT - ]' 
        ||CHR(13)||CHR(10)||Q'[         NVL(CASE WHEN NVL(CSH.T_SAV_PT, 0) > NVL(CSH.T_USE_PT, 0) THEN  NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) END, 0) AS REM_VAL_PT ]' 
        ||CHR(13)||CHR(10)||Q'[   FROM  C_CARD  CRD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_CUST  CST ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ( ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT  COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[               ,  CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[               ,  SUM(CASE WHEN LOS_MLG_DT <= :PSV_GFR_DATE THEN C_SAV_PT ELSE 0 END) AS T_SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[               ,  SUM(C_USE_PT)                                                      AS T_USE_PT ]'
        ||CHR(13)||CHR(10)||Q'[            FROM  ( ]'
        ||CHR(13)||CHR(10)||Q'[                    SELECT  CSH.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  CSH.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  CSH.LOS_MLG_DT ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN ABS(CSH.USE_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 ELSE 0 ]'
        ||CHR(13)||CHR(10)||Q'[                            END                                                 AS C_SAV_PT ]'         -- 실제 적립포인트
        ||CHR(13)||CHR(10)||Q'[                         ,  CASE WHEN CSH.SAV_USE_DIV IN ('102', '202')                  THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) > 0 THEN ABS(CSH.USE_PT) ]'
        ||CHR(13)||CHR(10)||Q'[                                 ELSE 0 ]'
        ||CHR(13)||CHR(10)||Q'[                            END                                                 AS C_USE_PT ]'         -- 실제 사용포인트
        ||CHR(13)||CHR(10)||Q'[                      FROM  C_CARD_SAV_HIS CSH ]'
        ||CHR(13)||CHR(10)||Q'[                         ,  S_STORE        S   ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE  CSH.COMP_CD    = S.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                     AND    CSH.BRAND_CD   = S.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                     AND    CSH.STOR_CD    = S.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                     AND    CSH.COMP_CD    = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                     AND    CSH.LOS_MLG_YN = 'N'          ]'
        ||CHR(13)||CHR(10)||Q'[                  )  CSH ]'
        ||CHR(13)||CHR(10)||Q'[           GROUP  BY COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[               ,  CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[         )  CSH ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CRD.COMP_CD       = CST.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.CUST_ID       = CST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.COMP_CD       = CSH.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.CARD_ID       = CSH.CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.COMP_CD       = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.USE_YN        = 'Y' ]'
        ||CHR(13)||CHR(10)||Q'[    AND  NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) > 0 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CRD.CARD_ID ]';
        
        ls_sql := ''||CHR(13)||CHR(10)|| ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING  PSV_GFR_DATE,  
                          PSV_COMP_CD,  PSV_COMP_CD; 
     
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
    
END PKG_MEPA1040;

/
