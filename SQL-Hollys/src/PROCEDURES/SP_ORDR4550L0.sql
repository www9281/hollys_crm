--------------------------------------------------------
--  DDL for Procedure SP_ORDR4550L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ORDR4550L0" /*주문 현황 - 점포별*/
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_ORDR4550L0
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_ORDR4550L0
      SYSDATE:         2010-03-08
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00395 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd     VARCHAR2(7) ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ;
    ls_err_cd := '0' ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER ,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2,      ls_ex_date2 );

    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
--           ||  ', '
--           ||  ls_sql_item  -- S_ITEM
           ;


    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' H.SHIP_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND H.SHIP_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
--    ls_sql_cm_00395 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00395') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=
            ' SELECT S.COMP_CD, '
        ||  '        S.BRAND_CD,' /*영업조직-HIDDEN*/
        ||  '        B.BRAND_NM,' /*영업조직명*/
        ||  '        S.STOR_CD,'  /*점포코드-HIDDEN*/
        ||  '        B.STOR_NM,'  /*점포명*/
        ||  '        SUM(SUM(S.ORD_AMT + S.ORD_VAT))  OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM )   AS ORD_AMT_TTL,'/*요청금액*/
        ||  '        SUM(SUM(S.ORD_VAT))  OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM )   AS ORD_VAT_TTL,'/*요청VAT*/
        ||  '        SUM(SUM(S.ORD_CAMT + S.ORD_CVAT)) OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM )   AS ORD_CAMT_TTL,'/*확정금액*/
        ||  '        SUM(SUM(S.ORD_CVAT)) OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM )   AS ORD_CVAT_TTL,'/*확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_1,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_VAT,0)) AS ORD_VAT_1,]'/*1차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_1,]'/*1차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_CVAT,0)) AS ORD_CVAT_1, ]'/*1차 확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_2,]'/*2차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_VAT,0)) AS ORD_VAT_2,]'/*2차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_2,]'/*2차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_CVAT,0)) AS ORD_CVAT_2, ]'/*2차 확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_3,]'/*3차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_VAT,0)) AS ORD_VAT_3,]'/*3차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_3,]'/*3차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_CVAT,0)) AS ORD_CVAT_3 ]'/*3차 확정VAT*/
        ||  ' FROM (    '
        ||  '           SELECT  H.COMP_CD   '
        ||  '                ,  H.BRAND_CD  '
        ||  '                ,  H.STOR_CD   '
        ||  '                ,  H.ORD_SEQ   '
        ||  '                ,  SUM(D.ORD_AMT)  AS ORD_AMT  '
        ||  '                ,  SUM(D.ORD_VAT)  AS ORD_VAT  '
        ||  '                ,  SUM(D.ORD_CAMT) AS ORD_CAMT '
        ||  '                ,  SUM(D.ORD_CVAT) AS ORD_CVAT '
        ||  '             FROM  ORDER_HD    H   '
        ||  '                ,  ORDER_DT    D   '
        ||  '            WHERE  H.SHIP_DT  = D.SHIP_DT   '
        ||  '              AND  H.COMP_CD  = D.COMP_CD   '
        ||  '              AND  H.BRAND_CD = D.BRAND_CD  '
        ||  '              AND  H.STOR_CD  = D.STOR_CD   '
        ||  '              AND  H.ORD_GRP  = D.ORD_GRP   '
        ||  '              AND  H.ORD_SEQ  = D.ORD_SEQ   '
        ||  '              AND  H.ORD_FG   = D.ORD_FG    '
        ||  '              AND  H.COMP_CD  = ''' || PSV_COMP_CD || ''''
        ||  '              AND ' ||  ls_sql_date
        ||  '              AND  D.ORD_QTY <> 0           '
        ||  '            GROUP BY H.COMP_CD, H.BRAND_CD, H.STOR_CD, H.ORD_SEQ           '
        ||  '      )  S,'
        ||  '      S_STORE B'
        ||  '   WHERE S.COMP_CD  = B.COMP_CD  '
        ||  '     AND S.BRAND_CD = B.BRAND_CD '
        ||  '     AND S.STOR_CD  = B.STOR_CD  '
        ||  'GROUP BY S.COMP_CD, '
        ||  '         S.BRAND_CD,' /*영업조직-HIDDEN*/
        ||  '         B.BRAND_NM,' /*영업조직명*/
        ||  '         S.STOR_CD,'  /*점포코드-HIDDEN*/
        ||  '         B.STOR_NM '  /*점포명*/
        ||  'ORDER BY 1,2,3,4, 5 ASC' /*영업조직-HIDDEN*/  ;

 --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;
    OPEN PR_RESULT FOR
       ls_sql;


    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
       dbms_output.put_line( PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
