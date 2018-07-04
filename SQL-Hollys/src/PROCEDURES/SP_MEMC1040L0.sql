--------------------------------------------------------
--  DDL for Procedure SP_MEMC1040L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEMC1040L0" /* 쿠폰 판매 상위 상품 조회*/
(
  PSV_COMP_CD      IN  VARCHAR2 ,                -- 회사코드
  PSV_USER            IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID         IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD       IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA             IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER           IN  VARCHAR2 ,                -- Search Filter
  PSV_COUPON_CD   IN  VARCHAR2 ,                --  대상쿠폰
  PSV_SORT_ORDER IN  VARCHAR2 ,                -- 정렬기준
  PSV_FROM_RANK   IN  VARCHAR2 ,                -- 순위시작
  PSV_TO_RANK       IN  VARCHAR2 ,                -- 순위종료
  PR_RESULT           IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD           OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG         OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEMC1040L0      쿠폰 판매 상위 상품 조회
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-01-23         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEMC1040L0
      SYSDATE:         2015-01-23
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_date2    VARCHAR2(1000) ;    

    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_sql_order VARCHAR2(1000) ;   -- 정렬순서
    ls_sql_rank VARCHAR2(1000) ;   -- 상품순서
        
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

BEGIN

--    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
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
      ls_sql_date  := ' hd.SALE_DT ' || ls_date1;
      ls_sql_date2 := ' hd.SALE_DT ' || ls_date2;      
      
    --IF ls_ex_date1 IS NOT NULL THEN
    --   ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
    --END IF;
    ------------------------------------------------------------------------------

     IF PSV_SORT_ORDER = '01' THEN
         ls_sql_order :=  ' ORDER BY x1.SALE_QTY  DESC ';
     ELSIF PSV_SORT_ORDER = '02'  THEN
         ls_sql_order :=  ' ORDER BY x1.SALE_AMT  DESC ';
     END IF;
        
     IF PSV_FROM_RANK IS NOT NULL THEN
         ls_sql_rank :=  '  AND x1.RNUM BETWEEN  ''' || PSV_FROM_RANK || ''' AND ''' || PSV_TO_RANK || '''  ';
     END IF;
        
    ls_sql_main :=         ' SELECT ROWNUM as S_RANK '
    ||chr(13)||chr(10)||'            , x.*    '
    ||chr(13)||chr(10)||'   FROM ( ' 
    ||chr(13)||chr(10)||'   SELECT x1.ITEM_CD as S_ITEM_CD      '
    ||chr(13)||chr(10)||'             , x1.ITEM_NM as S_ITEM_NM     '
    ||chr(13)||chr(10)||'             , x1.SALE_QTY as S_SALE_QTY    '
    ||chr(13)||chr(10)||'             , x1.SALE_AMT as S_SALE_AMT    '
    ||chr(13)||chr(10)||'             , x2.ITEM_CD as T_ITEM_CD         '
    ||chr(13)||chr(10)||'             , x2.ITEM_NM  as T_ITEM_NM       '
    ||chr(13)||chr(10)||'             , x2.SALE_QTY as T_SALE_QTY     '
    ||chr(13)||chr(10)||'             , x2.SALE_AMT as T_SALE_AMT    '
    ||chr(13)||chr(10)||'    FROM        '
    ||chr(13)||chr(10)||'    (                '
    ||chr(13)||chr(10)||'               SELECT sou.ITEM_CD          '
    ||chr(13)||chr(10)||'                         , itm.ITEM_NM         '
    ||chr(13)||chr(10)||'                         , sou.SALE_QTY         '
    ||chr(13)||chr(10)||'                         , sou.SALE_AMT         '
    ||chr(13)||chr(10)||'                         , ROW_NUMBER() OVER('||CASE WHEN PSV_SORT_ORDER = '01' THEN ' ORDER BY sou.SALE_QTY  DESC ' ELSE ' ORDER BY sou.SALE_AMT  DESC ' END||')  AS RNUM  '
    ||chr(13)||chr(10)||'               FROM  '
    ||chr(13)||chr(10)||'               (         '
    ||chr(13)||chr(10)||'                          SELECT  /*+ index(dt pk_sale_dt) */ '
    ||chr(13)||chr(10)||'                                  dt.ITEM_CD     '
    ||chr(13)||chr(10)||'                                , SUM(dt.SALE_QTY) as SALE_QTY  '
    ||chr(13)||chr(10)||'                                , SUM(dt.SALE_AMT) as SALE_AMT '
    ||chr(13)||chr(10)||'                           FROM   SALE_HD hd '
    ||chr(13)||chr(10)||'                                , SALE_DT dt '
    ||chr(13)||chr(10)||'                                , S_STORE STO                        '       
    ||chr(13)||chr(10)||'                          WHERE   HD.BRAND_CD    = STO.BRAND_CD            '
    ||chr(13)||chr(10)||'                            AND   HD.STOR_CD     = STO.STOR_CD              '               
    ||chr(13)||chr(10)||'                            AND  ' ||  ls_sql_date
    ||chr(13)||chr(10)||'                            AND ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''')'
    ||chr(13)||chr(10)||'                            AND   hd.SALE_DT  = dt.SALE_DT '
    ||chr(13)||chr(10)||'                            AND   hd.BRAND_CD = dt.BRAND_CD '
    ||chr(13)||chr(10)||'                            AND   hd.STOR_CD  = dt.STOR_CD '
    ||chr(13)||chr(10)||'                            AND   hd.POS_NO   = dt.POS_NO '
    ||chr(13)||chr(10)||'                            AND   hd.BILL_NO  = dt.BILL_NO  '
    ||chr(13)||chr(10)||'                            AND   dt.DC_DIV   = (SELECT DC_DIV FROM C_COUPON_MST WHERE COMP_CD = '''|| PSV_COMP_CD ||''' AND COUPON_CD = '''||PSV_COUPON_CD||''')'
    ||chr(13)||chr(10)||'                            AND (dt.T_SEQ= 0 OR dt.SUB_TOUCH_DIV = ''2'')'                                                   
    ||chr(13)||chr(10)||'                             GROUP BY dt.ITEM_CD '
    ||chr(13)||chr(10)||'                 ) sou, S_ITEM itm                         '
    ||chr(13)||chr(10)||'    WHERE sou.ITEM_CD = itm.ITEM_CD  '    
    ||chr(13)||chr(10)||'    ) x1, '
    ||chr(13)||chr(10)||'    (       '
    ||chr(13)||chr(10)||'               SELECT tar.ITEM_CD          '
    ||chr(13)||chr(10)||'                         , itm.ITEM_NM          '
    ||chr(13)||chr(10)||'                         , tar.SALE_QTY         '
    ||chr(13)||chr(10)||'                         , tar.SALE_AMT         '
    ||chr(13)||chr(10)||'                         , ROW_NUMBER() OVER('||CASE WHEN PSV_SORT_ORDER = '01' THEN ' ORDER BY tar.SALE_QTY  DESC ' ELSE ' ORDER BY tar.SALE_AMT  DESC ' END||')  AS RNUM  '
    ||chr(13)||chr(10)||'               FROM  '
    ||chr(13)||chr(10)||'               (         '
    ||chr(13)||chr(10)||'                          SELECT  /*+ index(dt pk_sale_dt) */ '
    ||chr(13)||chr(10)||'                                  dt.ITEM_CD     '
    ||chr(13)||chr(10)||'                                , SUM(dt.SALE_QTY) as SALE_QTY  '
    ||chr(13)||chr(10)||'                                , SUM(dt.SALE_AMT) as SALE_AMT '
    ||chr(13)||chr(10)||'                           FROM   SALE_HD hd '
    ||chr(13)||chr(10)||'                                , SALE_DT dt '
    ||chr(13)||chr(10)||'                                , S_STORE   STO                        '       
    ||chr(13)||chr(10)||'                          WHERE   HD.BRAND_CD    = STO.BRAND_CD            '
    ||chr(13)||chr(10)||'                            AND   HD.STOR_CD     = STO.STOR_CD              '          
    ||chr(13)||chr(10)||'                            AND  ' ||  ls_sql_date2
    ||chr(13)||chr(10)||'                            AND ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''')'
    ||chr(13)||chr(10)||'                            AND   hd.SALE_DT    = dt.SALE_DT '
    ||chr(13)||chr(10)||'                            AND   hd.BRAND_CD   = dt.BRAND_CD '
    ||chr(13)||chr(10)||'                            AND   hd.STOR_CD    = dt.STOR_CD '
    ||chr(13)||chr(10)||'                            AND   hd.POS_NO      = dt.POS_NO '
    ||chr(13)||chr(10)||'                            AND   hd.BILL_NO    = dt.BILL_NO  '
    ||chr(13)||chr(10)||'                            AND   dt.DC_DIV   = (SELECT DC_DIV FROM C_COUPON_MST WHERE COMP_CD = '''|| PSV_COMP_CD ||''' AND COUPON_CD = '''||PSV_COUPON_CD||''')'
    ||chr(13)||chr(10)||'                            AND  (dt.T_SEQ= 0 OR dt.SUB_TOUCH_DIV = ''2'')'
    ||chr(13)||chr(10)||'                             GROUP BY dt.ITEM_CD '
    ||chr(13)||chr(10)||'                 ) tar , S_ITEM itm                        '
    ||chr(13)||chr(10)||'    WHERE tar.ITEM_CD = itm.ITEM_CD '    
    ||chr(13)||chr(10)||'    ) x2 '
    ||chr(13)||chr(10)||' WHERE x1.RNUM = x2.RNUM(+) '    
    ||chr(13)||chr(10)|| ls_sql_rank
    ||chr(13)||chr(10)|| ls_sql_order
    ||chr(13)||chr(10)||'  ) x ';   
    dbms_output.put_line('ls_err_cd:'||ls_err_cd) ;
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
