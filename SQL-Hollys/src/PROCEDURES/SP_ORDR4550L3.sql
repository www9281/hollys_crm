--------------------------------------------------------
--  DDL for Procedure SP_ORDR4550L3
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ORDR4550L3" /*주문 현황 - 대분류별*/
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_ORD_FG      IN  VARCHAR2 ,                -- 주문구분
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_ORDR4550L3
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

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;


    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' S.SHIP_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND S.SHIP_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00395 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00395') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=
            ' SELECT S.BRAND_CD,' /*영업조직-HIDDEN*/
        ||  '        B.BRAND_NM,' /*영업조직명*/
        ||  '        S.STOR_CD,'  /*점포코드-HIDDEN*/
        ||  '        B.STOR_NM,'  /*점포명*/
        ||  '        S.ORD_FG,'  /*구분코드-HIDDEN*/
        ||  '        CL.CODE_NM AS ORD_FG_NM,' /*구분*/
        ||  '        I.L_CLASS_CD,' /*대분류*/
        ||  '        I.L_CLASS_NM,' /*대분류명*/
        ||  '        SUM(SUM(S.ORD_QTY))  OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_QTY_TTL,'/*요청수량*/
        ||  '        SUM(SUM(S.ORD_AMT+S.ORD_VAT))  OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_AMT_TTL,'/*요청금액*/
        ||  '        SUM(SUM(S.ORD_VAT))  OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_VAT_TTL,'/*요청VAT*/
        ||  '        SUM(SUM(S.ORD_CQTY)) OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_CQTY_TTL,'/*확정수량*/
        ||  '        SUM(SUM(S.ORD_CAMT+S.ORD_CVAT)) OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_CAMT_TTL,'/*확정금액*/
        ||  '        SUM(SUM(S.ORD_CVAT)) OVER (PARTITION BY S.BRAND_CD, B.BRAND_NM,  S.STOR_CD, B.STOR_NM, S.ORD_FG, CL.CODE_NM, I.L_CLASS_CD, I.L_CLASS_NM )   AS ORD_CVAT_TTL,'/*확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_QTY,0)) AS ORD_QTY_1,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_1,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_VAT,0)) AS ORD_VAT_1,]'/*1차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_CQTY,0)) AS ORD_CQTY_1,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_1,]'/*1차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'1',S.ORD_CVAT,0)) AS ORD_CVAT_1, ]'/*1차 확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_QTY,0)) AS ORD_QTY_2,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_2,]'/*2차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_VAT,0)) AS ORD_VAT_2,]'/*2차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_CQTY,0)) AS ORD_CQTY_2,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_2,]'/*2차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'2',S.ORD_CVAT,0)) AS ORD_CVAT_2, ]'/*2차 확정VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_QTY,0)) AS ORD_QTY_3,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_AMT+S.ORD_VAT,0)) AS ORD_AMT_3,]'/*3차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_VAT,0)) AS ORD_VAT_3,]'/*3차 요청VAT*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_CQTY,0)) AS ORD_QTY_3,]'/*1차 요청금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_CAMT+S.ORD_CVAT,0)) AS ORD_CAMT_3,]'/*3차 확정금액*/
        ||  q'[      SUM(DECODE(S.ORD_SEQ,'3',S.ORD_CVAT,0)) AS ORD_CVAT_3 ]'/*3차 확정VAT*/
        ||  ' FROM ORDER_HD  H,'
        ||  '      ORDER_DT  S,'
        ||  '      S_STORE B,'
        ||  '      S_ITEM I,'
        ||         ls_sql_cm_00395 || ' CL '
        ||  '   WHERE H.COMP_CD  = S.COMP_CD '
        ||  '     AND H.SHIP_DT  = S.SHIP_DT  '
        ||  '     AND H.BRAND_CD = S.BRAND_CD '
        ||  '     AND H.STOR_CD  = S.STOR_CD '
        ||  '     AND H.ORD_GRP  = S.ORD_GRP '
        ||  '     AND H.ORD_SEQ  = S.ORD_SEQ '
        ||  '     AND H.ORD_FG   = S.ORD_FG '
        ||  '     AND S.COMP_CD  = B.COMP_CD '
        ||  '     AND S.BRAND_CD = B.BRAND_CD '
        ||  '     AND S.STOR_CD  = B.STOR_CD '
        ||  '     AND S.COMP_CD  = I.COMP_CD '
        ||  '     AND S.ITEM_CD  = I.ITEM_CD '
        ||  '     AND S.COMP_CD  = CL.COMP_CD(+) '
        ||  '     AND S.ORD_FG   = CL.CODE_CD(+) '
        ||  '     AND H.COMP_CD  = ''' || PSV_COMP_CD || ''''
        ||  '     AND ' ||  ls_sql_date
        ||  '     AND (''' || PSV_ORD_FG || ''' IS NULL OR S.ORD_FG = ''' ||  PSV_ORD_FG || ''') '
        ||  '     AND S.ORD_QTY <> 0 '
        ||  'GROUP BY S.BRAND_CD, ' /*영업조직-HIDDEN*/
        ||  '        B.BRAND_NM, ' /*영업조직명*/
        ||  '        S.STOR_CD, '  /*점포코드-HIDDEN*/
        ||  '        B.STOR_NM, '  /*점포명*/
        ||  '        S.ORD_FG, '  /*구분코드-HIDDEN*/
        ||  '        CL.CODE_NM, '
        ||  '        I.L_CLASS_CD, ' /*대분류*/
        ||  '        I.L_CLASS_NM ' /*대분류명*/
        ||  'ORDER BY 1,2,3,4,5,6,7,8 ASC' /*영업조직-HIDDEN*/  ;

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
