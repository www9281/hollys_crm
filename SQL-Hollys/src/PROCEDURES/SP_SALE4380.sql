--------------------------------------------------------
--  DDL for Procedure SP_SALE4380
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE4380" /*카드사별 집계 현황 - HD*/
(
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_APRV_TP     IN  VARCHAR2 ,                -- 공통코드 00506 -> 승인기준 : 1.영업일, 2.승인일
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_SALE4380
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE4380
      SYSDATE:         2010-03-13
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_01345 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(10000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd     VARCHAR2(7) ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN
    ls_err_cd := '0' ;

    PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
--           ||  ', '
--           ||  ls_sql_item  -- S_ITEM
           ;

/*
  S_STORE AS
  (
 SELECT S.BRAND_CD , B.BRAND_NM, S.STOR_CD, S.STOR_NM, S.USE_YN ,
        S.STOR_TP, CM1.CODE_NM STOR_TP_NM , S.SIDO_CD, CM2.CODE_NM SIDO_CD_NM,
        S.REGION_CD, R.REGION_NM , S.TRAD_AREA, CM3.CODE_NM TRAD_AREA_NM, '
        S.DEPT_CD, CM4.CODE_NM DEPT_CD_NM, S.TEAM_CD, CM5.CODE_NM TEAM_CD_NM,
        S.SV_USER_ID , U.USER_NM
  )
*/

/*
  S_ITEM AS
  (
   SELECT I.BRAND_CD, I.ITEM_CD, I.SALE_PRC,
          I.ITEM_NM , I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD,
         IC1.L_CLASS_NM , IC2.M_CLASS_NM , IC3.S_CLASS_NM
  )
*/

    -- 조회기간 처리---------------------------------------------------------------
    IF PSV_APRV_TP = '1' THEN
            ls_sql_date := ' A.SALE_DT ' || ls_date1;
            IF ls_ex_date1 IS NOT NULL THEN
               ls_sql_date := ls_sql_date || ' AND A.SALE_DT ' || ls_ex_date1 ;
            END IF;
    ELSE
            ls_sql_date := ' A.APPR_DT ' || ls_date1;
            IF ls_ex_date1 IS NOT NULL THEN
               ls_sql_date := ls_sql_date || ' AND A.APPR_DT ' || ls_ex_date1 ;
            END IF;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
 --   ls_sql_cm_01345 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '01345') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=  ' SELECT S.STOR_CD, ' /*점포코드*/
                ||  '        S.STOR_NM, ' /*점포명*/
                ||  '        A.MAEIP_CD AS CARD_CD, ' /*카드사코드*/
                ||  '        C.CARD_NM, ' /*카드사명*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',DECODE(A.ALLOT_LMT,'0',A.APPR_AMT,0),0)) AS O_ILSIBUL, ]' /*승인 일시불 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',DECODE(A.ALLOT_LMT,'0',0,A.APPR_AMT),0)) AS O_HALBU, ]' /*승인 할부 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',1,0)) AS O_CNT, ]' /*승인 건수*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'2',DECODE(A.ALLOT_LMT,'0',A.APPR_AMT,0),0)) AS X_ILSIBUL, ]'  /*취소 일시불 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'2',DECODE(A.ALLOT_LMT,'0',0,A.APPR_AMT),0)) AS X_HALBU, ]' /*취소 할부 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'2',1,0)) AS X_CNT, ]'  /*취소 건수*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',DECODE(A.ALLOT_LMT,'0',A.APPR_AMT,0),0)) - SUM(DECODE(A.SALE_DIV,'2',DECODE(A.ALLOT_LMT,'0',A.APPR_AMT,0),0)) AS T_ILSIBUL, ]' /*집계 일시불 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',DECODE(A.ALLOT_LMT,'0',0,A.APPR_AMT),0)) - SUM(DECODE(A.SALE_DIV,'2',DECODE(A.ALLOT_LMT,'0',0,A.APPR_AMT),0)) AS T_HALBU, ]' /*집계 할부 금액*/
                ||  q'[      SUM(DECODE(A.SALE_DIV,'1',1,0)) - SUM(DECODE(A.SALE_DIV,'2',1,0)) AS T_CNT ]' /*집계 건수*/
                ||  q'[ FROM CARD_LOG A, S_STORE S, ]'
                ||  q'[      ( SELECT * FROM CARD WHERE USE_YN = 'Y' )  C    ]'
                ||  ' WHERE A.BRAND_CD = S.BRAND_CD '
                ||  '   AND A.STOR_CD  = S.STOR_CD '
                ||  '   AND A.MAEIP_CD = C.CARD_CD(+) '
                ||  '   AND (''' || PSV_FILTER  || ''' IS NULL OR A.RSV_DIV =  ''' || PSV_FILTER   || ''') '
                ||  '   AND ' ||  ls_sql_date
                ||  q'[ AND A.USE_YN   = 'Y' ]'
                ||  ' GROUP BY S.STOR_CD, S.STOR_NM, A.MAEIP_CD,  C.CARD_NM ' 
                ||  ' ORDER BY S.STOR_CD, A.MAEIP_CD ' ;

    dbms_output.put_line(ls_sql) ;
    dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
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
