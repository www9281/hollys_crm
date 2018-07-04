--------------------------------------------------------
--  DDL for Procedure SP_ANAL1100L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ANAL1100L1" /*원가시뮬레이션(메뉴-실행원가)*/
(   
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드 
  PR_RTN_MSG      OUT VARCHAR2    -- 처리Message 
)    
IS       
/******************************************************************************
   NAME:       SP_ANAL1100L1 원가시뮬레이션(메뉴-실행원가)
   PURPOSE:    

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-01-10         1. CREATED THIS PROCEDURE.

   NOTES: 

      OBJECT NAME:     SP_ANAL1100L1
      SYSDATE:          
      USERNAME:        
      TABLE NAME:       
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_date2     VARCHAR2(1000) ;
    ls_ymd_date     VARCHAR2(1000) ;
    ls_ymd_date2     VARCHAR2(1000) ;
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

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


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
    ls_sql_date := ' ICS.CALC_YM ' || ls_date1;
    /****************************************************************************** 
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND S.SALE_DT ' || ls_ex_date1 ;
    END IF;            
    *******************************************************************************/


    -- 대비기간 처리(미사용)-------------------------------------------------------
    /****************************************************************************** 
    ls_sql_date2 := ' ICR.CALC_YM ' || ls_date2;
    IF ls_ex_date2 IS NOT NULL THEN
       ls_sql_date2 := ls_sql_date2 || ' AND S.SALE_DT ' || ls_ex_date2 ;
    END IF;
    *******************************************************************************/           
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
    -------------------------------------------------------------------------------
    ls_sql_main :=
                                '   SELECT  V1.BRAND_CD                         BRAND_CD,               '
        || chr(13)||chr(10) ||  '           V1.BRAND_NM                         BRAND_NM,               '
        || chr(13)||chr(10) ||  '           V1.STOR_CD                          STOR_CD,                '
        || chr(13)||chr(10) ||  '           V1.STOR_NM                          STOR_NM,                '
        || chr(13)||chr(10) ||  '           C1.L_CLASS_CD                       P_L_CLS_CD,             '
        || chr(13)||chr(10) ||  '           C1.L_CLASS_NM                       P_L_CLS_NM,             '
        || chr(13)||chr(10) ||  '           C1.M_CLASS_CD                       P_M_CLS_CD,             '
        || chr(13)||chr(10) ||  '           C1.M_CLASS_NM                       P_M_CLS_NM,             '
        || chr(13)||chr(10) ||  '           C1.S_CLASS_CD                       P_S_CLS_CD,             '
        || chr(13)||chr(10) ||  '           C1.S_CLASS_NM                       P_S_CLS_NM,             '
        || chr(13)||chr(10) ||  '           V1.P_ITEM_CD                        P_ITEM_CD,              '
        || chr(13)||chr(10) ||  '           C1.ITEM_NM                          P_ITEM_NM,              '
        || chr(13)||chr(10) ||  '           V1.P_ITEM_QTY                       P_ITEM_QTY,             '
        || chr(13)||chr(10) ||  '           V1.P_ITEM_AMT                       P_ITEM_AMT,             '
        || chr(13)||chr(10) ||  '           V1.P_ITME_COST                      P_ITEM_COST,            '
        || chr(13)||chr(10) ||  '           V1.NET_AMT                          P_NET_AMT,              '
        || chr(13)||chr(10) ||  '           V1.NET_AMT - V1.P_ITEM_AMT          P_ITEM_PRO,             '
        || chr(13)||chr(10) ||  '           CASE WHEN V1.NET_AMT = 0 THEN 0                             '
        || chr(13)||chr(10) ||  '                ELSE V1.P_ITEM_AMT / V1.NET_AMT * 100 END              '
        || chr(13)||chr(10) ||  '                                               P_PRO_PER               '
        || chr(13)||chr(10) ||  '   FROM    S_ITEM          C1,                                         ' -- 상품
        || chr(13)||chr(10) ||  '          (                                                            '
        || chr(13)||chr(10) ||  '           SELECT  STR.COMP_CD,                                        '
        || chr(13)||chr(10) ||  '                   STR.BRAND_CD,                                       '    
        || chr(13)||chr(10) ||  '                   STR.BRAND_NM,                                       '
        || chr(13)||chr(10) ||  '                   STR.STOR_CD,                                        '
        || chr(13)||chr(10) ||  '                   STR.STOR_NM,                                        '
        || chr(13)||chr(10) ||  '                   ICS.ITEM_CD         P_ITEM_CD,                      '
        || chr(13)||chr(10) ||  '                   ICS.RUN_QTY         P_ITEM_QTY,                     '
        || chr(13)||chr(10) ||  '                   ICS.RUN_AMT         P_ITEM_AMT,                     '
        || chr(13)||chr(10) ||  '                   ICS.RUN_COST        P_ITME_COST,                    '
        || chr(13)||chr(10) ||  '                   ICS.NET_AMT                                         '
        || chr(13)||chr(10) ||  '           FROM    ITEM_CHAIN_STD ICS,                                 '
        || chr(13)||chr(10) ||  '                   S_STORE        STR                                  '
        || chr(13)||chr(10) ||  '           WHERE   STR.COMP_CD  = ICS.COMP_CD                          '
        || chr(13)||chr(10) ||  '           AND     STR.BRAND_CD = ICS.BRAND_CD                         '
        || chr(13)||chr(10) ||  '           AND     STR.STOR_CD  = ICS.STOR_CD                          '
        || chr(13)||chr(10) ||  '           AND     STR.COMP_CD  = ''' || PSV_COMP_CD || ''''
        || chr(13)||chr(10) ||  '           AND ' ||  ls_sql_date
        || chr(13)||chr(10) ||  '          )V1                                                          '
        || chr(13)||chr(10) ||  '   WHERE   V1.COMP_CD    = C1.COMP_CD                                  '
      --|| chr(13)||chr(10) ||  '   AND     V1.BRAND_CD   = C1.BRAND_CD                                 '
        || chr(13)||chr(10) ||  '   AND     V1.P_ITEM_CD  = C1.ITEM_CD                                  '
        || chr(13)||chr(10) ||  '   ORDER BY                                                            '  
        || chr(13)||chr(10) ||  '           V1.COMP_CD,                                                 '
        || chr(13)||chr(10) ||  '           V1.BRAND_CD,                                                '
        || chr(13)||chr(10) ||  '           V1.STOR_CD,                                                 '
        || chr(13)||chr(10) ||  '           C1.L_CLASS_CD,                                              '
        || chr(13)||chr(10) ||  '           C1.M_CLASS_CD,                                              '
        || chr(13)||chr(10) ||  '           C1.S_CLASS_CD,                                              '
        || chr(13)||chr(10) ||  '           V1.P_ITEM_CD                                                '
        ;

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
