--------------------------------------------------------
--  DDL for Procedure SP_MEAN2010L0_2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN2010L0_2" /* 연령대/상품분류별 구매분석 */
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
  PSV_CUST_AGE    IN  VARCHAR2 ,                -- 연령대
  PSV_CUST_LVL    IN  VARCHAR2 ,                -- 회원등급
  PSV_CUST_SEX    IN  VARCHAR2 ,                -- 성별
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEAN2010L0      연령대/상품분류별 구매분석
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN2010L0
      SYSDATE:         2014-07-11
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

    ls_sql_main :=                  '   SELECT  V02.COMP_CD         '
                ||chr(13)||chr(10)||'         , V02.BRAND_CD         '                
                ||chr(13)||chr(10)||'         , V02.BRAND_NM         '                 
                ||chr(13)||chr(10)||'         , V02.AGE_GRP         '
                ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM('''||PSV_COMP_CD||''', ''01760'', V02.AGE_GRP, '''||PSV_LANG_CD||''') AS AGE_GRP_NM'                
                ||chr(13)||chr(10)||'         , V02.L_CLASS_CD      '
                ||chr(13)||chr(10)||'         , ITM.L_CLASS_NM      '
                ||chr(13)||chr(10)||'         , V02.M_CLASS_CD      '
                ||chr(13)||chr(10)||'         , ITM.M_CLASS_NM      '
                ||chr(13)||chr(10)||'         , V02.S_CLASS_CD      '
                ||chr(13)||chr(10)||'         , ITM.S_CLASS_NM      '
                ||chr(13)||chr(10)||'         , V02.CLS_SUM_QTY     '
                ||chr(13)||chr(10)||'         , V02.CLS_SUM_GRD     '
                ||chr(13)||chr(10)||'         , CASE WHEN V02.AGE_SUM_GRD = 0 THEN 0 ELSE V02.CLS_SUM_GRD / V02.AGE_SUM_GRD  * 100 END AS GRD_RATE'
                ||chr(13)||chr(10)||'         , V02.ITEM_CD         '
                ||chr(13)||chr(10)||'         , ''[''||V02.ITEM_CD||''] ''||ITM.ITEM_NM TOP_ITEM_CD'            
                ||chr(13)||chr(10)||'   FROM    S_ITEM ITM          '
                ||chr(13)||chr(10)||'         ,(                       '
                ||chr(13)||chr(10)||'           SELECT  V01.COMP_CD    '
                ||chr(13)||chr(10)||'                 , V01.BRAND_CD    '
                ||chr(13)||chr(10)||'                 , V01.BRAND_NM    '                                
                ||chr(13)||chr(10)||'                 , V01.AGE_GRP    '
                ||chr(13)||chr(10)||'                 , V01.L_CLASS_CD '
                ||chr(13)||chr(10)||'                 , V01.M_CLASS_CD '
                ||chr(13)||chr(10)||'                 , V01.S_CLASS_CD '
                ||chr(13)||chr(10)||'                 , V01.ITEM_CD    '
                ||chr(13)||chr(10)||'                 , SUM(V01.SALE_QTY) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD) CLS_SUM_QTY  '
                ||chr(13)||chr(10)||'                 , SUM(V01.GRD_AMT ) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD) CLS_SUM_GRD  '
                ||chr(13)||chr(10)||'                 , SUM(V01.GRD_AMT ) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP ) AGE_SUM_GRD  '
                ||chr(13)||chr(10)||'                 , ROW_NUMBER()        OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD,  V01.AGE_GRP, V01.L_CLASS_CD, V01.M_CLASS_CD, V01.S_CLASS_CD ORDER BY GRD_AMT DESC) R_NUM  '
                ||chr(13)||chr(10)||'           FROM   (               '
                ||chr(13)||chr(10)||'                   SELECT  MMS.COMP_CD                            '
                ||chr(13)||chr(10)||'                         , STO.BRAND_CD                         '
                ||chr(13)||chr(10)||'                         , STO.BRAND_NM                        '                                
                ||chr(13)||chr(10)||'                         , GET_AGE_GROUP('''||PSV_COMP_CD||''', MMS.CUST_AGE) AS AGE_GRP '
                ||chr(13)||chr(10)||'                         , ITM.L_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , ITM.M_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , ITM.S_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , MMS.ITEM_CD                            '
                ||chr(13)||chr(10)||'                         , SUM(MMS.SALE_QTY) AS SALE_QTY          '
                ||chr(13)||chr(10)||'                         , SUM(MMS.GRD_AMT ) AS GRD_AMT           '
                ||chr(13)||chr(10)||'                   FROM    C_CUST_MMS  MMS                        '
                ||chr(13)||chr(10)||'                         , ITEM        ITM                        '
                ||chr(13)||chr(10)||'                         , S_STORE     STO                        '
                ||chr(13)||chr(10)||'                   WHERE   MMS.COMP_CD  = STO.COMP_CD             '
                ||chr(13)||chr(10)||'                   AND     MMS.BRAND_CD = STO.BRAND_CD            '
                ||chr(13)||chr(10)||'                   AND     MMS.STOR_CD  = STO.STOR_CD             '
                ||chr(13)||chr(10)||'                   AND     MMS.COMP_CD  = ITM.COMP_CD             '
                ||chr(13)||chr(10)||'                   AND     MMS.ITEM_CD  = ITM.ITEM_CD             '
                ||chr(13)||chr(10)||'                   AND     MMS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MMS.SALE_YM >= '''||PSV_STR_YM||'''    '
                ||chr(13)||chr(10)||'                   AND     MMS.SALE_YM <= '''||PSV_END_YM||'''    '                
                ||chr(13)||chr(10)||'                   AND     MMS.CUST_SEX = NVL('''||PSV_CUST_SEX||''', MMS.CUST_SEX) '
                ||chr(13)||chr(10)||'                   AND     MMS.CUST_LVL = NVL('''||PSV_CUST_LVL||''', MMS.CUST_LVL) '
                --||chr(13)||chr(10)||'                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                   GROUP BY                                       '
                ||chr(13)||chr(10)||'                           MMS.COMP_CD                            '
                ||chr(13)||chr(10)||'                         , STO.BRAND_CD                          '
                ||chr(13)||chr(10)||'                         , STO.BRAND_NM                         '                                
                ||chr(13)||chr(10)||'                         , GET_AGE_GROUP('''||PSV_COMP_CD||''', MMS.CUST_AGE) '
                ||chr(13)||chr(10)||'                         , ITM.L_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , ITM.M_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , ITM.S_CLASS_CD                         '
                ||chr(13)||chr(10)||'                         , MMS.ITEM_CD                            '
                ||chr(13)||chr(10)||'                  ) V01                       '
                ||chr(13)||chr(10)||'           WHERE  V01.AGE_GRP = NVL('''||PSV_CUST_AGE||''', V01.AGE_GRP)'
                ||chr(13)||chr(10)||'          ) V02                               '
                ||chr(13)||chr(10)||'   WHERE   ITM.COMP_CD = V02.COMP_CD          '
                ||chr(13)||chr(10)||'   AND     ITM.ITEM_CD = V02.ITEM_CD          '
                ||chr(13)||chr(10)||'   AND     V02.R_NUM = 1                      '
                ||chr(13)||chr(10)||'   ORDER BY   V02.COMP_CD, V02.AGE_GRP, V02.S_CLASS_CD            '
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
