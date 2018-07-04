--------------------------------------------------------
--  DDL for Procedure SP_MAST5000
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MAST5000" -- 재고손익>상품권관리>상품권 승인조회
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 분류유형
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_GIFT_CD     IN  VARCHAR2 ,                -- 상품권종류
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
) IS

    ls_sql          VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd       VARCHAR2(7) := '0';
    ls_err_msg      VARCHAR2(500);

    ERR_HANDLER     EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 );

    PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2);

    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;

    dbms_output.put_line(ls_sql);

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SALE_DT ' || ls_ex_date1;
    END IF;
    -------------------------------------------------------------------------------

    ls_sql_main :=
                             q'[SELECT L.BRAND_CD,]'
    || CHR(13) || CHR(10) || q'[       L.STOR_CD,]'
    || CHR(13) || CHR(10) || q'[       S.STOR_NM,]'
    || CHR(13) || CHR(10) || q'[       SUBSTR (SALE_DT, 1, 4) || '-' || SUBSTR (SALE_DT, 5, 2) || '-' || SUBSTR (SALE_DT, 7, 2) SALE_DT,]'
    || CHR(13) || CHR(10) || q'[       SUM(CASE SALE_DIV WHEN '1' THEN 1 WHEN '2' THEN -1 ELSE 0 END) SALE_QTY,]'
    || CHR(13) || CHR(10) || q'[       SUM(APPR_AMT) SALE_AMT,]'
    || CHR(13) || CHR(10) || q'[       GIFT_NM]'
    || CHR(13) || CHR(10) || q'[  FROM GIFT_LOG L,]'
    || CHR(13) || CHR(10) || q'[       S_STORE S]'
    || CHR(13) || CHR(10) || '   WHERE GIFT_GB LIKE ''%' || PSV_GIFT_CD || '%'''
    || CHR(13) || CHR(10) || '     AND '                 || ls_sql_date
    || CHR(13) || CHR(10) || '     AND L.COMP_CD = '''     || PSV_COMP_CD || ''''
    || CHR(13) || CHR(10) || q'[ GROUP BY L.BRAND_CD, L.STOR_CD, S.stor_NM, SALE_DT, GIFT_NM]'
    ;

    ls_sql := ls_sql || ls_sql_main;
    dbms_output.put_line(ls_sql);

    OPEN PR_RESULT FOR ls_sql;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg;

EXCEPTION
  WHEN ERR_HANDLER THEN
       PR_RTN_CD  := ls_err_cd;
       PR_RTN_MSG := ls_err_msg;
       dbms_output.put_line( PR_RTN_MSG );
  WHEN OTHERS THEN
       PR_RTN_CD  := '4999999';
       PR_RTN_MSG := SQLERRM;
       dbms_output.put_line( PR_RTN_MSG );
END ;

/
