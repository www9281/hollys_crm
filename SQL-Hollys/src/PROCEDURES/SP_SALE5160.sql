--------------------------------------------------------
--  DDL for Procedure SP_SALE5160
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE5160" /*재발행영수증 현황*/
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_POS_NO      IN  VARCHAR2 ,                -- Search Parameter
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_SALE5160
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE5160
      SYSDATE:         2010-03-13
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(10000) ;   -- 제품 WITH  S_ITEM
    ls_sql_pos      VARCHAR2(2000);     -- POS_NO
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
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


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
    ls_sql_date := ' T1.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND T1.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 포스번호 ---------------------------------------------------------------

    ls_sql_pos := ' AND A.POS_NO ' || ls_date1;
    IF PSV_POS_NO IS NULL THEN
       ls_sql_pos := '' ;
    ELSE
       ls_sql_pos := ' AND A.POS_NO = ''' || PSV_POS_NO || '''' ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00435') ;
    -------------------------------------------------------------------------------

    ls_sql_main := q'[    SELECT   T1.PRT_DT AS "NO_SALE_DT"  ]' --환전일
                || q'[       ,     TO_CHAR(TO_DATE(T1.PRT_TM, 'HH24MISS'), 'HH24:MI:SS') AS "NO_SALE_TM"  ]' --환전시간
                || q'[       ,     T1.POS_NO                  ]' --포스
                || q'[       ,     T3.USER_NM AS "NO_SALE_NM" ]' --환전자
                || q'[       ,     T1.CDO_RESN AS "CDO_RESN"  ]' --환전사유
                || q'[    FROM     REPRINT_LOG T1 ]'
                ||  '        ,     S_STORE     T2  '
                || q'[       ,     STORE_USER  T3 ]'
                || q'[    WHERE    T1.COMP_CD      = T2.COMP_CD     ]'
                || q'[      AND    T1.BRAND_CD     = T2.BRAND_CD    ]'
                || q'[      AND    T1.STOR_CD      = T2.STOR_CD     ]'
                || q'[      AND    T1.COMP_CD      = T3.COMP_CD(+)  ]'
                || q'[      AND    T1.BRAND_CD     = T3.BRAND_CD(+) ]'
                || q'[      AND    T1.STOR_CD      = T3.STOR_CD(+)  ]'
                || q'[      AND    T1.CASHIER      = T3.USER_ID(+)  ]'
                ||  '       AND    T1.COMP_CD      = ''' || PSV_COMP_CD || ''''
                || q'[      AND    ]' || ls_sql_date
                || q'[      AND    T1.DRAW_DIV     = '1'            ]'
                || q'[ ORDER BY    NO_SALE_DT ASC ]'
                || q'[       ,     NO_SALE_TM ASC ]'     ;

    dbms_output.put_line(ls_sql) ;
    dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    OPEN PR_RESULT FOR
      ls_sql;

/*
        SELECT   T1.PRT_DT AS "NO_SALE_DT"  
           ,     T1.PRT_TM AS "NO_SALE_TM"  
           ,     T1.POS_NO                  
           ,     T3.USER_NM AS "NO_SALE_NM" 
           ,     T1.CDO_RESN AS "CDO_RESN"  
        FROM     REPRINT_LOG T1 
           ,     STORE_USER  T3 
        WHERE    T1.DRAW_DIV     = '1'
          AND    T1.BRAND_CD     = T3.BRAND_CD(+) 
          AND    T1.STOR_CD      = T3.STOR_CD(+)  
          AND    T1.CASHIER      = T3.USER_ID(+)  
     ORDER BY    NO_SALE_DT ASC 
           ,     NO_SALE_TM ASC      ;
           */

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
