--------------------------------------------------------
--  DDL for Procedure SP_MEAN1040L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1040L0" /* 회원관리지표-고객창출관점-기간 */
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
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEAN1040L0      회원관리지표-고객창출관점-기간
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1040L0
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
           ||  ls_sql_store; -- S_STORE
    /*       
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;
    */       

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

    ls_sql_main :=                  '   , W_CST AS                                                   '
                ||chr(13)||chr(10)||'   (                                                               '
                ||chr(13)||chr(10)||'       SELECT  /*+ INDEX(C_CUST IDX05_C_CUST) */                   '
                ||chr(13)||chr(10)||'               COMP_CD                                             '
                ||chr(13)||chr(10)||'             , CUST_ID                                             '
                ||chr(13)||chr(10)||'             , GET_CHG_BIRTH_TO_AGE(COMP_CD, CUST_ID) AS CUST_AGE  '
                ||chr(13)||chr(10)||'             , TO_CHAR(ADD_MONTHS(TO_DATE(JOIN_DT, ''YYYYMMDD''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'       FROM    C_CUST                     '
                ||chr(13)||chr(10)||'       WHERE   COMP_CD  = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'       AND     JOIN_DT >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'')||''01'' '
                ||chr(13)||chr(10)||'       AND     JOIN_DT <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'')||''31'' '
                ||chr(13)||chr(10)||'       AND     SUBSTR(NVL(LEAVE_DT, ''99991231''), 1, 8)  >= '''||PSV_END_YM||'''||''01'''
                ||chr(13)||chr(10)||'       AND     CUST_STAT IN (''2'', ''9'')                                                                       '
                ||chr(13)||chr(10)||'       AND     JOIN_DT <= '''||PSV_END_YM||'''||''31'' '
                ||chr(13)||chr(10)||'   )                                   '
                ||chr(13)||chr(10)||'   SELECT  V02.COMP_CD        '
                ||chr(13)||chr(10)||'         , V02.SALE_YM        '
                ||chr(13)||chr(10)||'         , NVL(V01.BUY_CUST_CNT, 0) AS BUY_CUST_CNT '
                ||chr(13)||chr(10)||'         , V02.NEW_CUST_CNT   '
                ||chr(13)||chr(10)||'         , CASE WHEN V02.NEW_CUST_CNT = 0 THEN 0 ELSE NVL(V01.BUY_CUST_CNT, 0) / V02.NEW_CUST_CNT * 100 END AS SET_DWN_RATE'
                ||chr(13)||chr(10)||'   FROM   (                                '
                ||chr(13)||chr(10)||'           SELECT  MSS.COMP_CD                                '
                ||chr(13)||chr(10)||'                 , MSS.SALE_YM                                '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN S_NUM = 1 THEN 1 ELSE 0 END) BUY_CUST_CNT'
                ||chr(13)||chr(10)||'           FROM   (                                           '
                ||chr(13)||chr(10)||'                   SELECT  MSS.COMP_CD                        '
                ||chr(13)||chr(10)||'                         , MSS.SALE_YM                        '
                ||chr(13)||chr(10)||'                         , MSS.CUST_AGE                       '
                ||chr(13)||chr(10)||'                         , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.CUST_ID, MSS.SALE_YM ORDER BY MSS.CUST_AGE) S_NUM '
                ||chr(13)||chr(10)||'                   FROM    C_CUST_MSS  MSS                    '
                ||chr(13)||chr(10)||'                         , S_STORE     STO                    '
                ||chr(13)||chr(10)||'                         , W_CST       CST                    '
                ||chr(13)||chr(10)||'                   WHERE   STO.COMP_CD  = MSS.COMP_CD         '
                ||chr(13)||chr(10)||'                   AND     STO.BRAND_CD = MSS.BRAND_CD        '        
                ||chr(13)||chr(10)||'                   AND     STO.STOR_CD  = MSS.STOR_CD         ' 
                ||chr(13)||chr(10)||'                   AND     CST.COMP_CD  = MSS.COMP_CD         '
                ||chr(13)||chr(10)||'                   AND     CST.SALE_YM  = MSS.SALE_YM         '
                ||chr(13)||chr(10)||'                   AND     CST.CUST_ID  = MSS.CUST_ID         '
                ||chr(13)||chr(10)||'                   AND     MSS.COMP_CD  = '''||PSV_COMP_CD   ||''''
                --||chr(13)||chr(10)||'                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') ' 
                ||chr(13)||chr(10)||'                   AND     EXISTS (                            '
                ||chr(13)||chr(10)||'                                   SELECT  1                   '
                ||chr(13)||chr(10)||'                                   FROM    COMMON COM                  ' 
                ||chr(13)||chr(10)||'                                   WHERE   MSS.CUST_AGE BETWEEN COM.VAL_N1 AND COM.VAL_N2 '
                ||chr(13)||chr(10)||'                                   AND     COM.COMP_CD = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'                                   AND     COM.CODE_TP = ''01760''     '
                ||chr(13)||chr(10)||'                                   AND     COM.USE_YN  = ''Y''         '
                ||chr(13)||chr(10)||'                                   AND     COM.CODE_CD = NVL('''||PSV_CUST_AGE||''', CODE_CD) '
                ||chr(13)||chr(10)||'                                  )                            '
                ||chr(13)||chr(10)||'                  ) MSS                                        '
                ||chr(13)||chr(10)||'           GROUP BY MSS.COMP_CD, MSS.SALE_YM                   '
                ||chr(13)||chr(10)||'          ) V01                                                '
                ||chr(13)||chr(10)||'        , (                                                    '
                ||chr(13)||chr(10)||'           SELECT  CST.COMP_CD                                 '
                ||chr(13)||chr(10)||'                 , CST.SALE_YM                                 '
                ||chr(13)||chr(10)||'                 , COUNT(*) NEW_CUST_CNT                       '
                ||chr(13)||chr(10)||'           FROM    W_CST CST                                   '
                ||chr(13)||chr(10)||'           WHERE   EXISTS (                            '
                ||chr(13)||chr(10)||'                           SELECT  1                   '
                ||chr(13)||chr(10)||'                           FROM    COMMON COM                  ' 
                ||chr(13)||chr(10)||'                           WHERE   CST.CUST_AGE BETWEEN COM.VAL_N1 AND COM.VAL_N2 '
                ||chr(13)||chr(10)||'                           AND     COM.COMP_CD = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'                           AND     COM.CODE_TP = ''01760''     '
                ||chr(13)||chr(10)||'                           AND     COM.USE_YN  = ''Y''         '
                ||chr(13)||chr(10)||'                           AND     COM.CODE_CD = NVL('''||PSV_CUST_AGE||''', CODE_CD) '
                ||chr(13)||chr(10)||'                          )                                    '
                ||chr(13)||chr(10)||'           GROUP BY CST.COMP_CD, CST.SALE_YM                   '
                ||chr(13)||chr(10)||'          ) V02                                                '
                ||chr(13)||chr(10)||'   WHERE   V02.COMP_CD = V01.COMP_CD(+)                        '
                ||chr(13)||chr(10)||'   AND     V02.SALE_YM = V01.SALE_YM(+)                        '
                ||chr(13)||chr(10)||'   ORDER BY                   '
                ||chr(13)||chr(10)||'           V02.COMP_CD        '
                ||chr(13)||chr(10)||'         , V02.SALE_YM        '
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
