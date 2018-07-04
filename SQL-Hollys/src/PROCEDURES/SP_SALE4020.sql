--------------------------------------------------------
--  DDL for Procedure SP_SALE4020
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE4020" /*상품별 시간대 매출*/
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_L_CLASS_CD  IN  VARCHAR2 ,                -- 대분류
  PSV_M_CLASS_CD  IN  VARCHAR2 ,                -- 중분류
  PSV_S_CLASS_CD  IN  VARCHAR2 ,                -- 소분류
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_SALE4020 상품별 시간대 매출
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE4020
      SYSDATE:         2010-03-08
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
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
    ls_sql_date := ' S.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND S.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------

    ls_sql_main :=
            ' SELECT I.L_CLASS_CD,'
        ||  '        I.L_CLASS_NM,'
        ||  '        I.L_SORT_ORDER,'
        ||  '        I.M_CLASS_CD,'
        ||  '        I.M_CLASS_NM,'
        ||  '        I.M_SORT_ORDER,'
        ||  '        I.S_CLASS_CD,'
        ||  '        I.S_CLASS_NM,'
        ||  '        I.S_SORT_ORDER,'
        ||  '        I.ITEM_CD,'
        ||  '        I.ITEM_NM,'
        ||  '        SUM(SALE_QTY_00 ) AS SALE_QTY_00 ,'
        ||  '        SUM(GRD_AMT_00  ) AS GRD_AMT_00  ,'
        ||  '        SUM(SALE_QTY_06 ) AS SALE_QTY_06 ,'
        ||  '        SUM(GRD_AMT_06  ) AS GRD_AMT_06  ,'
        ||  '        SUM(SALE_QTY_09 ) AS SALE_QTY_09 ,'
        ||  '        SUM(GRD_AMT_09  ) AS GRD_AMT_09  ,'
        ||  '        SUM(SALE_QTY_12 ) AS SALE_QTY_12 ,'
        ||  '        SUM(GRD_AMT_12  ) AS GRD_AMT_12  ,'
        ||  '        SUM(SALE_QTY_15 ) AS SALE_QTY_15 ,'
        ||  '        SUM(GRD_AMT_15  ) AS GRD_AMT_15  ,'
        ||  '        SUM(SALE_QTY_18 ) AS SALE_QTY_18 ,'
        ||  '        SUM(GRD_AMT_18  ) AS GRD_AMT_18  ,'
        ||  '        SUM(SALE_QTY_21 ) AS SALE_QTY_21 ,'
        ||  '        SUM(GRD_AMT_21  ) AS GRD_AMT_21  ,'
        ||  '        SUM(SALE_QTY_TOT) AS SALE_QTY_TOT,'
        ||  '        SUM(GRD_AMT_TOT ) AS GRD_AMT_TOT  '
        ||  '  FROM (SELECT S.COMP_CD   AS COMP_CD, '
        ||  '               S.BRAND_CD  AS BRAND_CD,'
        ||  '               B.BRAND_NM  AS BRAND_NM,'
        ||  '               S.STOR_CD   AS STOR_CD ,'
        ||  '               B.STOR_NM   AS STOR_NM ,'
        ||  '               S.ITEM_CD   AS ITEM_CD ,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 05 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_00,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 05 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_00,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 06 AND 08 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_06,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 06 AND 08 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_06,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 09 AND 11 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_09,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 09 AND 11 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_09,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 12 AND 14 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_12,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 12 AND 14 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_12,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 15 AND 17 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_15,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 15 AND 17 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_15,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 18 AND 20 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_18,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 18 AND 20 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_18,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 21 AND 24 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_21,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 21 AND 24 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_21,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 24 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_TOT,'
        ||  '               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 24 THEN DECODE(''' || PSV_FILTER || ''', ''G'', S.GRD_AMT, ''T'', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_TOT'
        ||  '          FROM SALE_JTM  S,'
        ||  '               S_STORE   B '
        ||  '         WHERE S.COMP_CD  = B.COMP_CD  '
        ||  '           AND S.BRAND_CD = B.BRAND_CD '
        ||  '           AND S.STOR_CD  = B.STOR_CD  '
        ||  '           AND ' ||  ls_sql_date
        ||  '         GROUP BY S.COMP_CD, '  
        ||  '                  S.BRAND_CD,'
        ||  '                  B.BRAND_NM,'
        ||  '                  S.STOR_CD ,'
        ||  '                  B.STOR_NM ,'
        ||  '                  S.ITEM_CD  '
        ||  '       )      S,             '
        ||  '       S_ITEM I              '
        ||  ' WHERE S.COMP_CD = I.COMP_CD '
        ||  '   AND S.ITEM_CD = I.ITEM_CD '
        ||  '   AND S.COMP_CD = ''' || PSV_COMP_CD || '''' 
        ||  ' GROUP BY I.L_CLASS_CD,'
        ||  '          I.L_CLASS_NM,'
        ||  '          I.L_SORT_ORDER,'
        ||  '          I.M_CLASS_CD,'
        ||  '          I.M_CLASS_NM,'
        ||  '          I.M_SORT_ORDER,'
        ||  '          I.S_CLASS_CD,'
        ||  '          I.S_CLASS_NM,'
        ||  '          I.S_SORT_ORDER,'
        ||  '          I.ITEM_CD,'
        ||  '          I.ITEM_NM'
        ||  ' ORDER BY I.L_SORT_ORDER, I.M_SORT_ORDER, I.S_SORT_ORDER, I.ITEM_NM ASC ';

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
