--------------------------------------------------------
--  DDL for Procedure SP_MEAN1050L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1050L0" /* 회원육성관점 */
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
   NAME:       SP_MEAN1010L1      회원통계정보-전체회원현황(점포)
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1010L1
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

    /*           
    ls_sql := ' WITH  '
           ||  ls_sql_store; -- S_STORE
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

    ls_sql_main :=                  '   WITH W_CUST AS          '
                ||chr(13)||chr(10)||'  (                        '
                ||chr(13)||chr(10)||'   SELECT  COMP_CD         '
                ||chr(13)||chr(10)||'         , SALE_YM         '
                ||chr(13)||chr(10)||'         , BRAND_CD        '
                ||chr(13)||chr(10)||'         , CUST_ID         '
                ||chr(13)||chr(10)||'         , CUST_LVL        '
                ||chr(13)||chr(10)||'   FROM    C_CUST_MLVL MVL '
                ||chr(13)||chr(10)||'   WHERE   COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'   AND     SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'   AND     SALE_YM <= '''||PSV_END_YM||''''
                ||chr(13)||chr(10)||'   AND     EXISTS (                        '
                ||chr(13)||chr(10)||'                   SELECT  1               '
                ||chr(13)||chr(10)||'                   FROM    C_CUST  CST                 '
                ||chr(13)||chr(10)||'                   WHERE   CST.COMP_CD = MVL.COMP_CD   '
                ||chr(13)||chr(10)||'                   AND     CST.CUST_ID = MVL.CUST_ID   '
                ||chr(13)||chr(10)||'                   AND     CST.COMP_CD = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     SUBSTR(NVL(CST.LEAVE_DT,''99991231''), 1, 8) >= '''||PSV_STR_YM||'''||''31'''
                ||chr(13)||chr(10)||'           )                               '
                ||chr(13)||chr(10)||'  )                                        '
                ||chr(13)||chr(10)||'   SELECT  W03.COMP_CD                     '
                ||chr(13)||chr(10)||'         , W03.SALE_YM                     '
                ||chr(13)||chr(10)||'         , W03.LVL_ST_CNT                  '
                ||chr(13)||chr(10)||'         , V04.LST_LVL_CNT                 '
                ||chr(13)||chr(10)||'         , CASE WHEN V04.LST_LVL_CNT = 0 THEN 0 ELSE ROUND(W03.LVL_ST_CNT / V04.LST_LVL_CNT * 100, 2) END AS LVL_ST_RATE '
                ||chr(13)||chr(10)||'         , W03.LVL_UP_CNT                  '
                ||chr(13)||chr(10)||'         , V04.LOW_LVL_CNT                 '
                ||chr(13)||chr(10)||'         , CASE WHEN V04.LOW_LVL_CNT = 0 THEN 0 ELSE ROUND(W03.LVL_UP_CNT / V04.LOW_LVL_CNT * 100, 2) END AS LVL_UP_RATE '
                ||chr(13)||chr(10)||'   FROM   (                                '
                ||chr(13)||chr(10)||'           SELECT  W01.COMP_CD             '
                ||chr(13)||chr(10)||'                 , W01.SALE_YM             '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN W01.LVL_RANK > W02.LVL_RANK AND W01.CUST_LVL = '''||PSV_CUST_GRADE||''' THEN 1 ELSE 0 END) AS LVL_UP_CNT '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN W01.LVL_RANK = W02.LVL_RANK AND W01.CUST_LVL = '''||PSV_CUST_GRADE||''' THEN 1 ELSE 0 END) AS LVL_ST_CNT '
                ||chr(13)||chr(10)||'           FROM   (                        '
                ||chr(13)||chr(10)||'                   SELECT  W01.COMP_CD     '
                ||chr(13)||chr(10)||'                         , W01.SALE_YM     '
                ||chr(13)||chr(10)||'                         , W01.BRAND_CD    '
                ||chr(13)||chr(10)||'                         , W01.CUST_ID     '
                ||chr(13)||chr(10)||'                         , W01.CUST_LVL    '
                ||chr(13)||chr(10)||'                         , LVL.LVL_RANK    '
                ||chr(13)||chr(10)||'                   FROM    W_CUST W01      '
                ||chr(13)||chr(10)||'                         , C_CUST_LVL LVL  '
                ||chr(13)||chr(10)||'                   WHERE   W01.COMP_CD  = LVL.COMP_CD '
                ||chr(13)||chr(10)||'                   AND     W01.CUST_LVL = LVL.LVL_CD  '
                ||chr(13)||chr(10)||'                   AND     W01.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     W01.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     W01.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   AND     LVL.USE_YN  = ''Y'''
                ||chr(13)||chr(10)||'                  ) W01                    '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  W02.COMP_CD     '
                ||chr(13)||chr(10)||'                         , TO_CHAR(ADD_MONTHS(TO_DATE(W02.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'                         , W02.BRAND_CD    '
                ||chr(13)||chr(10)||'                         , W02.CUST_ID     '
                ||chr(13)||chr(10)||'                         , W02.CUST_LVL    '
                ||chr(13)||chr(10)||'                         , LVL.LVL_RANK    '
                ||chr(13)||chr(10)||'                   FROM    W_CUST     W02  '
                ||chr(13)||chr(10)||'                         , C_CUST_LVL LVL  '
                ||chr(13)||chr(10)||'                   WHERE   W02.COMP_CD  = LVL.COMP_CD '
                ||chr(13)||chr(10)||'                   AND     W02.CUST_LVL = LVL.LVL_CD  '
                ||chr(13)||chr(10)||'                   AND     W02.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     W02.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     W02.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     LVL.USE_YN  = ''Y'''
                ||chr(13)||chr(10)||'                  ) W02                    '
                ||chr(13)||chr(10)||'           WHERE   W01.COMP_CD  = W02.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     W01.SALE_YM  = W02.SALE_YM(+)'
                ||chr(13)||chr(10)||'           AND     W01.CUST_ID  = W02.CUST_ID(+)'
                ||chr(13)||chr(10)||'           GROUP BY W01.COMP_CD, W01.SALE_YM   '
                ||chr(13)||chr(10)||'          ) W03                    '
                ||chr(13)||chr(10)||'         ,(                        '
                ||chr(13)||chr(10)||'           SELECT  V03.COMP_CD             '
                ||chr(13)||chr(10)||'                 , V03.SALE_YM             '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN V03.STD_LVL_RANK > V03.LVL_RANK THEN 1 ELSE 0 END) AS LOW_LVL_CNT '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN V03.STD_LVL_RANK = V03.LVL_RANK THEN 1 ELSE 0 END) AS LST_LVL_CNT '
                ||chr(13)||chr(10)||'           FROM   (                        '
                ||chr(13)||chr(10)||'                   SELECT  V01.COMP_CD     '
                ||chr(13)||chr(10)||'                         , TO_CHAR(ADD_MONTHS(TO_DATE(V01.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'                         , V01.BRAND_CD    '
                ||chr(13)||chr(10)||'                         , V01.CUST_ID     '
                ||chr(13)||chr(10)||'                         , V01.CUST_LVL    '
                ||chr(13)||chr(10)||'                         , LVL.LVL_RANK    '
                ||chr(13)||chr(10)||'                         , V02.STD_LVL_CD  '
                ||chr(13)||chr(10)||'                         , V02.STD_LVL_RANK'
                ||chr(13)||chr(10)||'                   FROM    W_CUST     V01  '
                ||chr(13)||chr(10)||'                         , C_CUST_LVL LVL  '
                ||chr(13)||chr(10)||'                         ,(                '
                ||chr(13)||chr(10)||'                           SELECT  COMP_CD     '
                ||chr(13)||chr(10)||'                                 , LVL_CD      AS STD_LVL_CD   '
                ||chr(13)||chr(10)||'                                 , LVL_RANK    AS STD_LVL_RANK '
                ||chr(13)||chr(10)||'                           FROM    C_CUST_LVL  '
                ||chr(13)||chr(10)||'                           WHERE   COMP_CD = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'                           AND     LVL_CD  = '''||PSV_CUST_GRADE||''''
                ||chr(13)||chr(10)||'                           AND     USE_YN  = ''Y'''
                ||chr(13)||chr(10)||'                          ) V02'
                ||chr(13)||chr(10)||'                   WHERE   V01.COMP_CD  = LVL.COMP_CD '
                ||chr(13)||chr(10)||'                   AND     V01.CUST_LVL = LVL.LVL_CD  '
                ||chr(13)||chr(10)||'                   AND     V01.COMP_CD  = V02.COMP_CD '
                ||chr(13)||chr(10)||'                   AND     V01.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     V01.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     V01.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                  ) V03                        '
                ||chr(13)||chr(10)||'           GROUP BY V03.COMP_CD, V03.SALE_YM   '
                ||chr(13)||chr(10)||'          ) V04                                '
                ||chr(13)||chr(10)||'   WHERE   W03.COMP_CD = V04.COMP_CD           '
                ||chr(13)||chr(10)||'   AND     W03.SALE_YM = V04.SALE_YM           '
                ||chr(13)||chr(10)||'   ORDER BY  W03.SALE_YM                       '
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
