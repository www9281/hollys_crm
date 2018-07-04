--------------------------------------------------------
--  DDL for Package Body PKG_MEPA1030
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MEPA1030" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹        
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_CARD_ID     IN  VARCHAR2 ,                -- 고객카드번호
        PSV_CARD_STAT   IN  VARCHAR2 ,                -- 카드상태
        PSV_USE_YN      IN  VARCHAR2 ,                -- 미사용포함
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      카드현황[포인트] 
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
        ls_sql_cm := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01725') ;
        -------------------------------------------------------------------------------

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT   /*+ INDEX(CST PK_C_CUST) INDEX(CRD IDX01_C_CARD) */ ]'
        ||CHR(13)||CHR(10)||Q'[         CRD.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(CRD.CARD_ID)    AS CARD_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CST.CUST_ID ]'
        ||CHR(13)||CHR(10)||Q'[      ,  decrypt(CST.CUST_NM)    AS CUST_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FN_GET_FORMAT_HP_NO(REPLACE(decrypt(CST.MOBILE), '-', '')) AS MOBILE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.ISSUE_STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN CRD.ISSUE_STOR_CD IS NULL THEN '' ELSE S.STOR_NM END STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUBSTR(CRD.ISSUE_DT, 1, 8) AS ISSUE_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.CARD_STAT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_NM  AS CARD_STAT_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(CRD.UPD_DT, 'YYYYMMDD') AS UPD_DT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.SAV_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.USE_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.LOS_PT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT AS VAL_PT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  C_CARD  CRD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C_CUST  CST ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE   S ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ]' || ls_sql_cm || Q'[ C]'    
        ||CHR(13)||CHR(10)||Q'[  WHERE  CRD.COMP_CD       = S.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.ISSUE_BRAND_CD= S.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.ISSUE_STOR_CD = S.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.COMP_CD       = CST.COMP_CD (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.CUST_ID       = CST.CUST_ID (+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.COMP_CD       = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CARD_ID IS NULL OR CRD.CARD_ID = encrypt(:PSV_CARD_ID)) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CARD_STAT IS NULL OR CRD.CARD_STAT = :PSV_CARD_STAT) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_USE_YN = 'A' OR CRD.USE_YN = :PSV_USE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CRD.CARD_STAT  = C.CODE_CD(+) ]';
        --||CHR(13)||CHR(10)||Q'[  ORDER  BY decrypt(CRD.CARD_ID) ]';

        ls_sql := ''||CHR(13)||CHR(10)|| ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD,
                         PSV_CARD_ID,   PSV_CARD_ID, 
                         PSV_CARD_STAT, PSV_CARD_STAT, 
                         PSV_USE_YN,    PSV_USE_YN;

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

END PKG_MEPA1030;

/
