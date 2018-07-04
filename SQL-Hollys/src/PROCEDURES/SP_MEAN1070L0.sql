--------------------------------------------------------
--  DDL for Procedure SP_MEAN1070L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1070L0" /* 고객유지관점 */
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
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEAN1070L0      고객유지관점
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1070L0
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

    ls_sql_main :=                  '   , W_MSS AS                                   '
                ||chr(13)||chr(10)||'  (                                                '
                ||chr(13)||chr(10)||'   SELECT  /*+ NO_MERGE */                         '
                ||chr(13)||chr(10)||'           MSS.COMP_CD                             '
                ||chr(13)||chr(10)||'         , MSS.SALE_YM                             '
                ||chr(13)||chr(10)||'         , MSS.CUST_ID                             '
                ||chr(13)||chr(10)||'         , SUM(MSS.BILL_CNT) AS BILL_CNT           '
                ||chr(13)||chr(10)||'         , SUM(MSS.SALE_QTY) AS SALE_QTY           '
                ||chr(13)||chr(10)||'         , SUM(MSS.GRD_AMT ) AS GRD_AMT            '
                ||chr(13)||chr(10)||'   FROM    C_CUST_MSS MSS                          '
                ||chr(13)||chr(10)||'         , S_STORE    STO                          '
                ||chr(13)||chr(10)||'   WHERE   STO.COMP_CD  = MSS.COMP_CD         '
                ||chr(13)||chr(10)||'   AND     STO.BRAND_CD = MSS.BRAND_CD        '        
                ||chr(13)||chr(10)||'   AND     STO.STOR_CD  = MSS.STOR_CD         ' 
                ||chr(13)||chr(10)||'   AND     MSS.COMP_CD  = '''||PSV_COMP_CD  ||'''  '
                ||chr(13)||chr(10)||'   AND     MSS.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'   AND     MSS.SALE_YM <= '''||PSV_END_YM   ||'''  '
                --||chr(13)||chr(10)||'   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') ' 
                ||chr(13)||chr(10)||'   GROUP BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_ID  '
                ||chr(13)||chr(10)||'  )                                        '
                ||chr(13)||chr(10)||'   SELECT  V99.COMP_CD                     '
                ||chr(13)||chr(10)||'         , V99.SALE_YM                     '
                ||chr(13)||chr(10)||'         , NVL(V99.CUR_RE_SALE_CNT ,0) AS CUR_RE_SALE_CNT  '
                ||chr(13)||chr(10)||'         , NVL(V99.BEF_SALE_CNT    ,0) AS BEF_SALE_CNT     '
                ||chr(13)||chr(10)||'         , NVL(V99.RE_SALE_RATE    ,0) AS RE_SALE_RATE     '
                ||chr(13)||chr(10)||'         , NVL(V99.CUR_NON_SALE_CNT,0) AS CUR_NON_SALE_CNT '
                ||chr(13)||chr(10)||'         , NVL(V99.BEF_SALE_CNT    ,0) AS BEF_SALE_CNT     '
                ||chr(13)||chr(10)||'         , NVL(V99.BE_AWAY_RATE    ,0) AS BE_AWAY_RATE     '
                ||chr(13)||chr(10)||'         , NVL(V99.NEW_SALE_CNT    ,0) AS NEW_SALE_CNT     '
                ||chr(13)||chr(10)||'         , NVL(V99.BEF_NON_SALE_CNT,0) AS BEF_NON_SALE_CNT '
                ||chr(13)||chr(10)||'         , NVL(V99.IN_FULX_RATE    ,0) AS IN_FULX_RATE     '
                ||chr(13)||chr(10)||'         , W99.CST_SALE_RATE               '
                ||chr(13)||chr(10)||'         , W99.CST_BILL_CNT                '
                ||chr(13)||chr(10)||'         , W99.CST_SALE_CNT                '
                ||chr(13)||chr(10)||'         , W99.CST_BILL_AMT                '
                ||chr(13)||chr(10)||'   FROM   (                                '
                ||chr(13)||chr(10)||'           SELECT  V01.COMP_CD             '
                ||chr(13)||chr(10)||'                 , V01.SALE_YM             '
                ||chr(13)||chr(10)||'                 , V04.CUR_RE_SALE_CNT     '
                ||chr(13)||chr(10)||'                 , V02.BEF_SALE_CNT        '
                ||chr(13)||chr(10)||'                 , CASE WHEN V02.BEF_SALE_CNT = 0 THEN 0 ELSE ROUND(V04.CUR_RE_SALE_CNT / V02.BEF_SALE_CNT * 100, 2)    END RE_SALE_RATE    '
                ||chr(13)||chr(10)||'                 , V03.CUR_NON_SALE_CNT    '
                ||chr(13)||chr(10)||'                 , CASE WHEN V02.BEF_SALE_CNT = 0 THEN 0 ELSE ROUND(V03.CUR_NON_SALE_CNT / V02.BEF_SALE_CNT * 100, 2)   END BE_AWAY_RATE    '
                ||chr(13)||chr(10)||'                 , V05.NEW_SALE_CNT        '
                ||chr(13)||chr(10)||'                 , V06.BEF_NON_SALE_CNT        '
                ||chr(13)||chr(10)||'                 , CASE WHEN V06.BEF_NON_SALE_CNT = 0 THEN 0 ELSE ROUND(V05.NEW_SALE_CNT / V06.BEF_NON_SALE_CNT * 100, 2) END IN_FULX_RATE  '
                ||chr(13)||chr(10)||'           FROM   (                        '
                ||chr(13)||chr(10)||'                   SELECT  '''||PSV_COMP_CD||''' AS COMP_CD                                        '
                ||chr(13)||chr(10)||'                         , TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), ROWNUM - 1), ''YYYYMM'') SALE_YM  '
                ||chr(13)||chr(10)||'                   FROM    TAB     '
                ||chr(13)||chr(10)||'                   WHERE   ROWNUM <= (MONTHS_BETWEEN(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''),    '
                ||chr(13)||chr(10)||'                                                     TO_DATE('''||PSV_STR_YM||''', ''YYYYMM'')) + 1)        '
                ||chr(13)||chr(10)||'                   ) V01                   '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  MSS.COMP_CD     '
                ||chr(13)||chr(10)||'                         , TO_CHAR(ADD_MONTHS(TO_DATE(MSS.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'                         , COUNT(*) AS BEF_SALE_CNT '
                ||chr(13)||chr(10)||'                   FROM    W_MSS MSS       '
                ||chr(13)||chr(10)||'                   WHERE   MSS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   GROUP BY  MSS.COMP_CD   '
                ||chr(13)||chr(10)||'                           , TO_CHAR(ADD_MONTHS(TO_DATE(MSS.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                  ) V02                    '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  MSS.COMP_CD     '
                ||chr(13)||chr(10)||'                         , TO_CHAR(ADD_MONTHS(TO_DATE(MSS.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'                         , COUNT(*) AS CUR_NON_SALE_CNT '
                ||chr(13)||chr(10)||'                   FROM    W_MSS MSS       '
                ||chr(13)||chr(10)||'                   WHERE   MSS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     MSS.SALE_YM <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     NOT EXISTS(                         '
                ||chr(13)||chr(10)||'                                       SELECT  1               '
                ||chr(13)||chr(10)||'                                       FROM    W_MSS MS1       '
                ||chr(13)||chr(10)||'                                       WHERE   MS1.COMP_CD  = MSS.COMP_CD  '
                ||chr(13)||chr(10)||'                                       AND     MS1.SALE_YM  = TO_CHAR(ADD_MONTHS(TO_DATE(MSS.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                                       AND     MS1.CUST_ID  = MSS.CUST_ID  '
                ||chr(13)||chr(10)||'                                      )                        '
                ||chr(13)||chr(10)||'                   GROUP BY  MSS.COMP_CD   '
                ||chr(13)||chr(10)||'                           , TO_CHAR(ADD_MONTHS(TO_DATE(MSS.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                  ) V03                    '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  MS1.COMP_CD     '
                ||chr(13)||chr(10)||'                         , MS1.SALE_YM     '
                ||chr(13)||chr(10)||'                         , COUNT(*) AS CUR_RE_SALE_CNT         '
                ||chr(13)||chr(10)||'                   FROM    W_MSS MS1       '
                ||chr(13)||chr(10)||'                         , W_MSS MS2       '
                ||chr(13)||chr(10)||'                   WHERE   MS1.COMP_CD  = MS2.COMP_CD          '
                ||chr(13)||chr(10)||'                   AND     MS1.SALE_YM  = TO_CHAR(ADD_MONTHS(TO_DATE(MS2.SALE_YM, ''YYYYMM''), 1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                   AND     MS1.CUST_ID  = MS2.CUST_ID          '
                ||chr(13)||chr(10)||'                   AND     MS1.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MS1.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     MS1.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   GROUP BY  MS1.COMP_CD   '
                ||chr(13)||chr(10)||'                           , MS1.SALE_YM   '
                ||chr(13)||chr(10)||'                  ) V04                    '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  MS1.COMP_CD     '
                ||chr(13)||chr(10)||'                         , MS1.SALE_YM     '
                ||chr(13)||chr(10)||'                         , SUM(CASE WHEN CST.JOIN_DT < MS1.SALE_YM||''01'' THEN 1 ELSE 0 END) NEW_SALE_CNT '
                ||chr(13)||chr(10)||'                   FROM    W_MSS  MS1       '
                ||chr(13)||chr(10)||'                         , C_CUST CST       '
                ||chr(13)||chr(10)||'                   WHERE   MS1.COMP_CD = CST.COMP_CD           '
                ||chr(13)||chr(10)||'                   AND     MS1.CUST_ID = CST.CUST_ID           '
                ||chr(13)||chr(10)||'                   AND     MS1.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     MS1.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     MS1.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   AND     SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8) >= '''||PSV_STR_YM||'''||''01'''
                ||chr(13)||chr(10)||'                   AND     CST.CUST_STAT IN (''2'', ''9'')     '
                ||chr(13)||chr(10)||'                   AND     NOT EXISTS(                         '
                ||chr(13)||chr(10)||'                                       SELECT  1               '
                ||chr(13)||chr(10)||'                                       FROM    W_MSS MS2       '
                ||chr(13)||chr(10)||'                                       WHERE   MS2.COMP_CD  = MS1.COMP_CD  '
                ||chr(13)||chr(10)||'                                       AND     MS2.SALE_YM  = TO_CHAR(ADD_MONTHS(TO_DATE(MS1.SALE_YM, ''YYYYMM''), -1), ''YYYYMM'') '
                ||chr(13)||chr(10)||'                                       AND     MS2.CUST_ID  = MS1.CUST_ID  '
                ||chr(13)||chr(10)||'                                      )                        '
                ||chr(13)||chr(10)||'                   GROUP BY  MS1.COMP_CD   '
                ||chr(13)||chr(10)||'                           , MS1.SALE_YM   '
                ||chr(13)||chr(10)||'                  ) V05                    '
                ||chr(13)||chr(10)||'                , (                        '
                ||chr(13)||chr(10)||'                   SELECT  CST.COMP_CD     '
                ||chr(13)||chr(10)||'                         , TMP.SALE_YM     '
                ||chr(13)||chr(10)||'                         , SUM(CASE WHEN CST.JOIN_DT <=   TMP.COMP_YM||''31'' AND SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8) >= TMP.COMP_YM||''01'' THEN 1 ELSE 0 END) BEF_NON_SALE_CNT '
                ||chr(13)||chr(10)||'                   FROM    C_CUST CST      '
                ||chr(13)||chr(10)||'                         ,(                '
                ||chr(13)||chr(10)||'                           SELECT  '''||PSV_COMP_CD||''' AS COMP_CD                                        '
                ||chr(13)||chr(10)||'                                 , TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), ROWNUM - 1), ''YYYYMM'') SALE_YM  '
                ||chr(13)||chr(10)||'                                 , TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), ROWNUM - 2), ''YYYYMM'') COMP_YM  '
                ||chr(13)||chr(10)||'                           FROM    TAB     '
                ||chr(13)||chr(10)||'                           WHERE   ROWNUM <= (MONTHS_BETWEEN(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''),    '
                ||chr(13)||chr(10)||'                                                    TO_DATE('''||PSV_STR_YM||''', ''YYYYMM'')) + 1)        '
                ||chr(13)||chr(10)||'                          ) TMP            '
                ||chr(13)||chr(10)||'                   WHERE   CST.COMP_CD  = TMP.COMP_CD'    
                ||chr(13)||chr(10)||'                   AND     CST.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     TMP.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     TMP.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   AND     SUBSTR(NVL(CST.LEAVE_DT, ''99991231''), 1, 8) >= '''||PSV_STR_YM||'''||''01'''
                ||chr(13)||chr(10)||'                   AND     CST.CUST_STAT IN (''2'', ''9'')                                 '
                ||chr(13)||chr(10)||'                   AND     NOT EXISTS(                         '
                ||chr(13)||chr(10)||'                                       SELECT  1               '
                ||chr(13)||chr(10)||'                                       FROM    W_MSS MS1       '
                ||chr(13)||chr(10)||'                                       WHERE   MS1.COMP_CD  = CST.COMP_CD '
                ||chr(13)||chr(10)||'                                       AND     MS1.SALE_YM  = TMP.COMP_YM '
                ||chr(13)||chr(10)||'                                       AND     MS1.CUST_ID  = CST.CUST_ID '
                ||chr(13)||chr(10)||'                                      )                        '
                ||chr(13)||chr(10)||'                   GROUP BY  CST.COMP_CD   '
                ||chr(13)||chr(10)||'                           , TMP.SALE_YM   '
                ||chr(13)||chr(10)||'                  ) V06                   '
                ||chr(13)||chr(10)||'           WHERE   V01.COMP_CD  = V02.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     V01.SALE_YM  = V02.SALE_YM(+)'
                ||chr(13)||chr(10)||'           AND     V01.COMP_CD  = V03.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     V01.SALE_YM  = V03.SALE_YM(+)'
                ||chr(13)||chr(10)||'           AND     V01.COMP_CD  = V04.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     V01.SALE_YM  = V04.SALE_YM(+)'
                ||chr(13)||chr(10)||'           AND     V01.COMP_CD  = V05.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     V01.SALE_YM  = V05.SALE_YM(+)'
                ||chr(13)||chr(10)||'           AND     V01.COMP_CD  = V06.COMP_CD(+)'
                ||chr(13)||chr(10)||'           AND     V01.SALE_YM  = V06.SALE_YM(+)'
                ||chr(13)||chr(10)||'          ) V99                                '
                ||chr(13)||chr(10)||'         ,(                                    '
                ||chr(13)||chr(10)||'           SELECT  W02.COMP_CD                 '
                ||chr(13)||chr(10)||'                 , W02.SALE_YM                 '
                ||chr(13)||chr(10)||'                 , CASE WHEN W02.GRD_AMT = 0 THEN 0             ELSE ROUND(W01.CST_GRD_AMT / W02.GRD_AMT * 100, 2)      END AS CST_SALE_RATE '
                ||chr(13)||chr(10)||'                 , NVL(W01.CST_BILL_CNT, 0)                                                                                 AS CST_BILL_CNT  '
                ||chr(13)||chr(10)||'                 , NVL(W01.CST_SALE_CNT, 0)                                                                                 AS CST_SALE_CNT   '
                ||chr(13)||chr(10)||'                 , CASE WHEN NVL(W01.CST_GRD_AMT, 0) = 0 THEN 0 ELSE ROUND(NVL(W01.CST_GRD_AMT, 0) / NVL(W01.CST_BILL_CNT, 0)) END AS CST_BILL_AMT  '
                ||chr(13)||chr(10)||'           FROM   (                            '
                ||chr(13)||chr(10)||'                   SELECT  W01.COMP_CD         '
                ||chr(13)||chr(10)||'                         , W01.SALE_YM         '
                ||chr(13)||chr(10)||'                         , SUM(W01.GRD_AMT )           AS CST_GRD_AMT  '
                ||chr(13)||chr(10)||'                         , SUM(W01.BILL_CNT)           AS CST_BILL_CNT '
                ||chr(13)||chr(10)||'                         , COUNT(*)                    AS CST_SALE_CNT '
                ||chr(13)||chr(10)||'                   FROM    W_MSS       W01  '
                ||chr(13)||chr(10)||'                   WHERE   W01.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     W01.SALE_YM >= '''||PSV_STR_YM ||''''
                ||chr(13)||chr(10)||'                   AND     W01.SALE_YM <= '''||PSV_END_YM ||''''
                ||chr(13)||chr(10)||'                   GROUP BY W01.COMP_CD, W01.SALE_YM   '
                ||chr(13)||chr(10)||'                  ) W01                        '
                ||chr(13)||chr(10)||'               , (                             '
                ||chr(13)||chr(10)||'                   SELECT  '''||PSV_COMP_CD||''' AS COMP_CD    '
                ||chr(13)||chr(10)||'                         , SUBSTR(W02.SALE_DT, 1, 6) AS SALE_YM'
                ||chr(13)||chr(10)||'                         , SUM(W02.GRD_AMT )         AS GRD_AMT'
                ||chr(13)||chr(10)||'                   FROM    SALE_JDS W02                        '
                ||chr(13)||chr(10)||'                         , S_STORE  STO                               '
                ||chr(13)||chr(10)||'                   WHERE   STO.COMP_CD  = W02.COMP_CD                 '
                ||chr(13)||chr(10)||'                   AND     STO.BRAND_CD = W02.BRAND_CD                '
                ||chr(13)||chr(10)||'                   AND     STO.STOR_CD  = W02.STOR_CD                 '
                ||chr(13)||chr(10)||'                   AND     W02.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     W02.SALE_DT >= '''||PSV_STR_YM ||'''||''01'''
                ||chr(13)||chr(10)||'                   AND     W02.SALE_DT <= '''||PSV_END_YM ||'''||''31'''
                --||chr(13)||chr(10)||'                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                   GROUP BY SUBSTR(W02.SALE_DT, 1, 6)          '
                ||chr(13)||chr(10)||'                  ) W02                                        '
                ||chr(13)||chr(10)||'           WHERE   W02.COMP_CD = W01.COMP_CD(+)                '
                ||chr(13)||chr(10)||'           AND     W02.SALE_YM = W01.SALE_YM(+)                '
                ||chr(13)||chr(10)||'          ) W99                                '
                ||chr(13)||chr(10)||'   WHERE   V99.COMP_CD = W99.COMP_CD           '
                ||chr(13)||chr(10)||'   AND     V99.SALE_YM = W99.SALE_YM           '
                ||chr(13)||chr(10)||'   ORDER BY  V99.SALE_YM                       '
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
