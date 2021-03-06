--------------------------------------------------------
--  DDL for Procedure SP_MEAN1010L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1010L0" /* 회원통계정보-전체회원현황(전체) */
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
   NAME:       SP_MEAN1010L0      회원통계정보-전체회원현황(전체)
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1010L0
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

    ls_sql_main :=                  '   SELECT  /*+ NO_MERGE LEADING(CST) */ '
                ||chr(13)||chr(10)||'           CST.STD_YM                 '
                ||chr(13)||chr(10)||'         , CST.TOT_CUST_CNT           '
                ||chr(13)||chr(10)||'         , CST.NEW_CUST_CNT           '
                ||chr(13)||chr(10)||'         , MSS.CST_CUST_CNT           '
                ||chr(13)||chr(10)||'         , CASE WHEN CST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CST.TOT_CUST_CNT * 100 END AS OPER_RATE     '
                ||chr(13)||chr(10)||'         , CASE WHEN MSS.CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT  / MSS.CST_BILL_CNT       END AS CST_BILL_AMT  '
                ||chr(13)||chr(10)||'         , CASE WHEN (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) = 0 THEN 0                                                '
                ||chr(13)||chr(10)||'                ELSE (JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT) / (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT)                     '
                ||chr(13)||chr(10)||'           END AS NCST_BILL_AMT       '
                ||chr(13)||chr(10)||'         , CASE WHEN (SUM(MSS.CST_BILL_CNT) OVER()) = 0 THEN 0 ELSE (SUM(MSS.CST_GRD_AMT) OVER()) / (SUM(MSS.CST_BILL_CNT) OVER()) END AS T_CST_BILL_AMT  '
                ||chr(13)||chr(10)||'         , CASE WHEN (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER()) = 0 THEN 0                                        '
                ||chr(13)||chr(10)||'                ELSE (SUM(JDS.TOT_GRD_AMT - MSS.CST_GRD_AMT)OVER()) / (SUM(JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) OVER())  '
                ||chr(13)||chr(10)||'           END AS T_NCST_BILL_AMT       '
                ||chr(13)||chr(10)||'         , MSS.CST_SALE_QTY           '
                ||chr(13)||chr(10)||'         , JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY AS NCST_SALE_QTY '
                ||chr(13)||chr(10)||'         , MSS.CST_GRD_AMT            '
                ||chr(13)||chr(10)||'         , JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT  AS NCST_GRD_AMT  '
                ||chr(13)||chr(10)||'   FROM   (                                                                                                               '    
                ||chr(13)||chr(10)||'           SELECT  /*+ NO_MERGE LEADING(CST) */                 '
                ||chr(13)||chr(10)||'                   V01.COMP_CD                                                                                            '
                ||chr(13)||chr(10)||'                 , V01.STD_YM                                                                                             '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN CST.JOIN_DT <=   V01.STD_YM||''31'' AND NVL(CST.LEAVE_DT, ''99991231'') >= V01.STD_YM||''31'' THEN 1 ELSE 0 END) TOT_CUST_CNT '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN CST.JOIN_DT LIKE V01.STD_YM||''%''  AND NVL(CST.LEAVE_DT, ''99991231'') >= V01.STD_YM||''31'' THEN 1 ELSE 0 END) NEW_CUST_CNT '
                ||chr(13)||chr(10)||'           FROM    C_CUST     CST                                                                                         '
                ||chr(13)||chr(10)||'                 ,(                                                                                                       '
                ||chr(13)||chr(10)||'                   SELECT  '''||PSV_COMP_CD||''' AS COMP_CD                                                               '
                ||chr(13)||chr(10)||'                        ,  TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), ROWNUM - 1), ''YYYYMM'') STD_YM  '
                ||chr(13)||chr(10)||'                   FROM    TAB                                                                                            '
                ||chr(13)||chr(10)||'                   WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''),                            '
                ||chr(13)||chr(10)||'                                                    TO_DATE('''||PSV_STR_YM||''', ''YYYYMM'')) + 1)                       '
                ||chr(13)||chr(10)||'                  ) V01                                                                                                   '
                ||chr(13)||chr(10)||'           WHERE   CST.COMP_CD = V01.COMP_CD                                                                              '
                ||chr(13)||chr(10)||'           AND     CST.COMP_CD = '''||PSV_COMP_CD   ||'''                                                                 '
                ||chr(13)||chr(10)||'           AND     CST.LVL_CD  = NVL('''||PSV_CUST_GRADE||''', CST.LVL_CD)                                                '
                ||chr(13)||chr(10)||'           AND     NVL(CST.LEAVE_DT, ''99991231'')  >= '''||PSV_STR_YM||'''||''01'''
                ||chr(13)||chr(10)||'           AND     CST.CUST_STAT IN (''2'', ''9'')                                                                        '
                ||chr(13)||chr(10)||'           GROUP BY                                           '
                ||chr(13)||chr(10)||'                   V01.COMP_CD                                '
                ||chr(13)||chr(10)||'                ,  V01.STD_YM                                 '
                ||chr(13)||chr(10)||'          ) CST                                               '
                ||chr(13)||chr(10)||'         ,(                                                   '
                ||chr(13)||chr(10)||'           SELECT  /*+ NO_MERGE LEADING(MSS) */               '
                ||chr(13)||chr(10)||'                   MSS.COMP_CD                                '
                ||chr(13)||chr(10)||'                 , MSS.SALE_YM                                '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT'
                ||chr(13)||chr(10)||'                 , SUM(MSS.BILL_CNT)           AS CST_BILL_CNT'
                ||chr(13)||chr(10)||'                 , SUM(MSS.SALE_QTY)           AS CST_SALE_QTY'
                ||chr(13)||chr(10)||'                 , SUM(MSS.GRD_AMT)            AS CST_GRD_AMT '
                ||chr(13)||chr(10)||'           FROM   (                                           '
                ||chr(13)||chr(10)||'                   SELECT  /*+ NO_MERGE */       '
                ||chr(13)||chr(10)||'                           MSS.COMP_CD                        '
                ||chr(13)||chr(10)||'                         , MSS.SALE_YM                        '
                ||chr(13)||chr(10)||'                         , MSS.CUST_ID                        '
                ||chr(13)||chr(10)||'                         , MSS.BILL_CNT                       '
                ||chr(13)||chr(10)||'                         , MSS.SALE_QTY                       '
                ||chr(13)||chr(10)||'                         , MSS.GRD_AMT                        '
                ||chr(13)||chr(10)||'                         , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM '
                ||chr(13)||chr(10)||'                   FROM    C_CUST_MSS MSS                     '
                ||chr(13)||chr(10)||'                   WHERE   MSS.COMP_CD  = '''||PSV_COMP_CD  ||''''
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM >= '''||PSV_STR_YM   ||''''
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM <= '''||PSV_END_YM   ||''''
                ||chr(13)||chr(10)||'                   AND     MSS.CUST_LVL = NVL('''||PSV_CUST_GRADE||''', MSS.CUST_LVL)'
                ||chr(13)||chr(10)||'                   AND     EXISTS( SELECT  1                           '
                ||chr(13)||chr(10)||'                                   FROM    S_STORE STO                 '
                ||chr(13)||chr(10)||'                                   WHERE   STO.BRAND_CD = MSS.BRAND_CD '        
                ||chr(13)||chr(10)||'                                   AND     STO.STOR_CD  = MSS.STOR_CD) ' 
                ||chr(13)||chr(10)||'                  ) MSS                                       '
                ||chr(13)||chr(10)||'           GROUP BY                                           '
                ||chr(13)||chr(10)||'                   MSS.COMP_CD                                '
                ||chr(13)||chr(10)||'                 , MSS.SALE_YM                                '
                ||chr(13)||chr(10)||'          ) MSS                                               '
                ||chr(13)||chr(10)||'         ,(                                                   '
                ||chr(13)||chr(10)||'           SELECT  /*+ NO_MERGE LEADING(JDS) */               '
                ||chr(13)||chr(10)||'                   JDS.COMP_CD                 AS COMP_CD     '
                ||chr(13)||chr(10)||'               ,   SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM     '
                ||chr(13)||chr(10)||'               ,   SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT'
                ||chr(13)||chr(10)||'               ,   SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY'
                ||chr(13)||chr(10)||'               ,   SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT '
                ||chr(13)||chr(10)||'           FROM    SALE_JDS JDS                               '
                ||chr(13)||chr(10)||'                 , S_STORE  STO                               '
                ||chr(13)||chr(10)||'           WHERE   STO.COMP_CD  = JDS.COMP_CD                 '
                ||chr(13)||chr(10)||'           AND     STO.BRAND_CD = JDS.BRAND_CD                '
                ||chr(13)||chr(10)||'           AND     STO.STOR_CD  = JDS.STOR_CD                 '
                ||chr(13)||chr(10)||'           AND     JDS.COMP_CD  = '''||PSV_COMP_CD  ||''''
                ||chr(13)||chr(10)||'           AND     JDS.SALE_DT  >= '''||PSV_STR_YM||'''||''01'''
                ||chr(13)||chr(10)||'           AND     JDS.SALE_DT  <= '''||PSV_END_YM||'''||''31'''
                ||chr(13)||chr(10)||'           GROUP BY JDS.COMP_CD                               '
                ||chr(13)||chr(10)||'               ,    SUBSTR(JDS.SALE_DT, 1, 6 )                '
                ||chr(13)||chr(10)||'          ) JDS                                               '
                ||chr(13)||chr(10)||'   WHERE   CST.COMP_CD   = MSS.COMP_CD(+)                     '
                ||chr(13)||chr(10)||'   AND     CST.STD_YM    = MSS.SALE_YM(+)                     '
                ||chr(13)||chr(10)||'   AND     CST.COMP_CD   = JDS.COMP_CD                        '
                ||chr(13)||chr(10)||'   AND     CST.STD_YM    = JDS.SALE_YM                        '
                ||chr(13)||chr(10)||'   ORDER BY CST.STD_YM                                        '
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
