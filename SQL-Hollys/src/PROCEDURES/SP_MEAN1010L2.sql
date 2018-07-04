--------------------------------------------------------
--  DDL for Procedure SP_MEAN1010L2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1010L2" /* 회원통계정보-전체회원현황(회원) */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
  PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
  PSV_CUST_GRADE  IN  VARCHAR2 ,                -- 회원등급
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEAN1010L2     회원통계정보-전체회원현황(회원)
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-07-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1010L1
      SYSDATE:         2015-07-01
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

BEGIN

--    dbms_output.enable( 1000000 ) ;

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
    --ls_sql_date := ' DL.APPR_DT ' || ls_date1;
    --IF ls_ex_date1 IS NOT NULL THEN
    --   ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
    --END IF;
    ------------------------------------------------------------------------------

    ls_sql_main :=                  '   SELECT  TOT.COMP_CD                '
                ||chr(13)||chr(10)||'         , TOT.STOR_CD                '      
                ||chr(13)||chr(10)||'         , STO.STOR_NM                '
                ||chr(13)||chr(10)||'         , TOT.SALE_YM                '                       
                ||chr(13)||chr(10)||'         , TOT.CUST_ID               '    
                ||chr(13)||chr(10)||'         , decrypt(CUST.CUST_NM) as CUST_NM           '                                
                ||chr(13)||chr(10)||'         , TOT.ITEM_CD    '
                ||chr(13)||chr(10)||'         , ITM.ITEM_NM   '
                ||chr(13)||chr(10)||'         , TOT.CST_SALE_QTY  '
                ||chr(13)||chr(10)||'         , TOT.CST_SALE_AMT            '
                ||chr(13)||chr(10)||'         , TOT.CST_DC_AMT            '
                ||chr(13)||chr(10)||'         , TOT.CST_GRD_AMT            '
                ||chr(13)||chr(10)||'   FROM    S_STORE STO                '
                ||chr(13)||chr(10)||'         ,     S_ITEM ITM                              '
                ||chr(13)||chr(10)||'         ,     C_CUST  CUST                               '                                            
                ||chr(13)||chr(10)||'         ,(                                                   '
                ||chr(13)||chr(10)||'           SELECT  MMS.COMP_CD                                '
                ||chr(13)||chr(10)||'                 , MMS.BRAND_CD                               '
                ||chr(13)||chr(10)||'                 , MMS.STOR_CD                                '
                ||chr(13)||chr(10)||'                 , MMS.SALE_YM                                '                     
                ||chr(13)||chr(10)||'                 , MMS.CUST_ID '
                ||chr(13)||chr(10)||'                 , MMS.ITEM_CD '                
                ||chr(13)||chr(10)||'                 , SUM(MMS.SALE_QTY)           AS CST_SALE_QTY'
                ||chr(13)||chr(10)||'                 , SUM(MMS.SALE_AMT)           AS CST_SALE_AMT'          
                ||chr(13)||chr(10)||'                 , SUM(MMS.DC_AMT)              AS CST_DC_AMT'                                              
                ||chr(13)||chr(10)||'                 , SUM(MMS.GRD_AMT)            AS CST_GRD_AMT '
                ||chr(13)||chr(10)||'           FROM   (                                           '
                ||chr(13)||chr(10)||'                   SELECT  MS.COMP_CD                        '
                ||chr(13)||chr(10)||'                         , MS.BRAND_CD                       '
                ||chr(13)||chr(10)||'                         , MS.STOR_CD                        '
                ||chr(13)||chr(10)||'                         , MS.SALE_YM                        '
                ||chr(13)||chr(10)||'                         , MS.CUST_ID                        '
                ||chr(13)||chr(10)||'                         , MS.ITEM_CD                        '                                
                ||chr(13)||chr(10)||'                         , MS.SALE_QTY                       '
                ||chr(13)||chr(10)||'                         , MS.SALE_AMT                       '      
                ||chr(13)||chr(10)||'                         , MS.DC_AMT + MS.ENR_AMT as DC_AMT  '                                                
                ||chr(13)||chr(10)||'                         , MS.GRD_AMT                        '
                ||chr(13)||chr(10)||'                   FROM    C_CUST_MMS MS                     '
                ||chr(13)||chr(10)||'                         , S_STORE    ST                     '
                ||chr(13)||chr(10)||'                   WHERE   ST.BRAND_CD = MS.BRAND_CD '        
                ||chr(13)||chr(10)||'                   AND     ST.STOR_CD  = MS.STOR_CD  ' 
                ||chr(13)||chr(10)||'                   AND     MS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MS.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     MS.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   AND     MS.CUST_LVL = NVL('''||PSV_CUST_GRADE||''', MS.CUST_LVL)'
                --||chr(13)||chr(10)||'                   AND    ('''|| PSV_FILTER ||''' IS NULL OR ST.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                  ) MMS                                       '
                ||chr(13)||chr(10)||'           GROUP BY                                           '
                ||chr(13)||chr(10)||'                   MMS.COMP_CD                                '
                ||chr(13)||chr(10)||'                 , MMS.BRAND_CD                               '
                ||chr(13)||chr(10)||'                 , MMS.STOR_CD                                '
                ||chr(13)||chr(10)||'                 , MMS.SALE_YM                                '        
                ||chr(13)||chr(10)||'                 , MMS.CUST_ID                                '                                
                ||chr(13)||chr(10)||'                 , MMS.ITEM_CD                                '          
                ||chr(13)||chr(10)||'          ) TOT                                               '
                ||chr(13)||chr(10)||'   WHERE   TOT.COMP_CD  = STO.COMP_CD                         '
                ||chr(13)||chr(10)||'   AND     TOT.BRAND_CD = STO.BRAND_CD                        '
                ||chr(13)||chr(10)||'   AND     TOT.STOR_CD  = STO.STOR_CD                         '
                ||chr(13)||chr(10)||'   AND     TOT.COMP_CD  = CUST.COMP_CD                        '
                ||chr(13)||chr(10)||'   AND     TOT.CUST_ID  = CUST.CUST_ID                        '
                ||chr(13)||chr(10)||'   AND     TOT.COMP_CD  = ITM.COMP_CD                         '
                ||chr(13)||chr(10)||'   AND     TOT.ITEM_CD  = ITM.ITEM_CD                         '
                ||chr(13)||chr(10)||'   ORDER BY TOT.COMP_CD, TOT.STOR_CD, TOT.SALE_YM,  TOT.CUST_ID, TOT.ITEM_CD        '
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
