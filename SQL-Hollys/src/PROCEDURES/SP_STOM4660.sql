--------------------------------------------------------
--  DDL for Procedure SP_STOM4660
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_STOM4660" 
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 분류유형
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
  PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
) IS

  TYPE rec_hd IS RECORD
      ( CROSS_CD   VARCHAR2(20),
        CROSS_NM   VARCHAR2(60)
      );
  TYPE tb_hd IS TABLE OF rec_hd INDEX BY PLS_INTEGER;
  qry_hd          tb_hd;

    V_CROSSTAB     LONG;
    V_SQL          LONG;
    V_HD           LONG;
    V_HD1          LONG;
    V_HD2          LONG;
    V_CNT          PLS_INTEGER;

    ls_sql          LONG;
    ls_sql_with     LONG;
    ls_sql_main     LONG;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(30000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main LONG;          -- CORSSTAB TITLE

  ls_err_cd       VARCHAR2(7) := '0';
  ls_err_msg      VARCHAR2(500);

  ERR_HANDLER     EXCEPTION;
BEGIN

  dbms_output.enable( 10000000 );

  PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                      ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

  -- 조회기간 처리---------------------------------------------------------------
  ls_sql_date := ' A.SALE_DT ' || ls_date1;
  IF ls_ex_date1 IS NOT NULL THEN
     ls_sql_date := ls_sql_date || ' AND A.SALE_DT ' || ls_ex_date1 ;
  END IF;
  -------------------------------------------------------------------------------

  ls_sql_with := ' WITH  '
  ||  ls_sql_store; -- S_STORE

  ls_sql_crosstab_main :=
                             q'[  SELECT '''' || S.BRAND_CD || S.STOR_CD || '''' CROSS_CD,]'
        ||chr(13)||chr(10)|| q'[       S.STOR_NM CROSS_NM]'
        ||chr(13)||chr(10)|| q'[  FROM SALE_JDS J,]'
        ||chr(13)||chr(10)|| q'[       (]'
        ||chr(13)||chr(10)|| q'[            SELECT  A.COMP_CD, ]'
        ||chr(13)||chr(10)|| q'[                    A.BRAND_CD,]'
        ||chr(13)||chr(10)|| q'[                    A.STOR_CD, ]'
        ||chr(13)||chr(10)|| q'[                    B.STOR_NM, ]'
        ||chr(13)||chr(10)|| q'[                    A.SALE_DT, ]'
        ||chr(13)||chr(10)|| q'[                     SUM(  CASE WHEN A.PAY_DIV IN ('10', '30') THEN A.PAY_AMT + (A.CHANGE_AMT * -1)  ELSE 0 END ) PAY_AMT]'
        ||chr(13)||chr(10)|| q'[              FROM  SALE_ST A, ]'
        ||chr(13)||chr(10)|| q'[                    S_STORE B  ]'
        ||chr(13)||chr(10)|| q'[             WHERE A.PAY_DIV IN ('10', '30')]'
        ||chr(13)||chr(10)|| q'[               AND ]' || ls_sql_date
        ||chr(13)||chr(10)|| q'[               AND A.COMP_CD  = B.COMP_CD   ]'
        ||chr(13)||chr(10)|| q'[               AND A.BRAND_CD = B.BRAND_CD  ]'
        ||chr(13)||chr(10)|| q'[               AND A.STOR_CD  = B.STOR_CD   ]'
        ||chr(13)||chr(10)||  '                AND A.COMP_CD  =  ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)|| q'[             GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, B.STOR_NM, A.SALE_DT]'
        ||chr(13)||chr(10)|| q'[        ) S]'
        ||chr(13)||chr(10)|| q'[ WHERE S.COMP_CD  = J.COMP_CD   ]'
        ||chr(13)||chr(10)|| q'[   AND S.BRAND_CD = J.BRAND_CD  ]'
        ||chr(13)||chr(10)|| q'[   AND S.STOR_CD = J.STOR_CD    ]'
        ||chr(13)||chr(10)|| q'[   AND S.SALE_DT = J.SALE_DT    ]'
        ||chr(13)||chr(10)||  '    AND S.COMP_CD  = ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)|| q'[ GROUP BY S.BRAND_CD, S.STOR_CD, S.STOR_NM]'
        ||chr(13)||chr(10)|| q'[ ORDER BY S.BRAND_CD, S.STOR_CD]';

  ls_sql := ls_sql_with || ls_sql_crosstab_main;
  dbms_output.put_line('-----------ls_sql-----------');
  dbms_output.put_line(ls_sql);


  EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd;

  IF SQL%ROWCOUNT = 0 THEN
     ls_err_cd  := '4000100';
     ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD, ls_err_cd);
     RAISE ERR_HANDLER;
  END IF;

  V_HD1 := ' SELECT SALE_DT, TOTAL, TOTAL, ';
  V_HD2 := ' SELECT SALE_DT, GRD_AMT, PAY_AMT, ';

  FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
    BEGIN
      IF i > 1 THEN
         V_CROSSTAB := V_CROSSTAB || ' , ';
         V_HD1 := V_HD1 || ' , ';
         V_HD2 := V_HD2 || ' , ';
      END IF;
      V_CROSSTAB := V_CROSSTAB || qry_hd(i).CROSS_CD;
      V_HD1 := V_HD1 || '''' || qry_hd(i).CROSS_NM || ''',';
      V_HD1 := V_HD1 || '''' || qry_hd(i).CROSS_NM || '''';
      V_HD2 := V_HD2 || ' GRD_AMT, PAY_AMT ';
    END;
  END LOOP;

    V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
    V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
    V_HD   := ' WITH S_HD AS ( '
    || chr(13)||chr(10) || ' SELECT FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''SALE_DT'')      AS SALE_DT  '   -- 판매일자
    || chr(13)||chr(10) || '      , FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''TOTAL'')        AS TOTAL    '   -- 합계
    || chr(13)||chr(10) || '      , FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''GRD_SALE_AMT'') AS GRD_AMT  '   -- 실매출액
    || chr(13)||chr(10) || '      , FC_GET_WORDPACK('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''RCV_PAY_AMT'')  AS PAY_AMT  '   -- 입금액
    || chr(13)||chr(10) || '   FROM DUAL                                                                          '
    || chr(13)||chr(10) || ' )                                                                                    '
    ||  V_HD1 || ' UNION ALL ' || V_HD2
        ;
  dbms_output.put_line('-----------V_HD-----------');
  dbms_output.put_line(V_HD);

  ls_sql_main :=
                           q'[SELECT S.BRAND_CD || S.STOR_CD CROSS_CD ,]'
  || CHR(13) || CHR(10) || q'[       SUBSTR (S.SALE_DT, 1, 4) || '-' || SUBSTR (S.SALE_DT, 5, 2) || '-' || SUBSTR (S.SALE_DT, 7, 2) SALE_DT,]'
  || CHR(13) || CHR(10) || q'[       SUM(J.GRD_AMT) OVER(PARTITION BY J.SALE_DT) TOT_GRD_AMT,]'
  || CHR(13) || CHR(10) || q'[       SUM(S.PAY_AMT) OVER(PARTITION BY S.SALE_DT) TOT_PAY_AMT,]'
  || CHR(13) || CHR(10) || q'[       J.GRD_AMT,]'
  || CHR(13) || CHR(10) || q'[       S.PAY_AMT]'
  || CHR(13) || CHR(10) || q'[  FROM SALE_JDS J,]'
  || CHR(13) || CHR(10) || q'[       (]'
  || CHR(13) || CHR(10) || q'[            SELECT  A.COMP_CD, ]'
  || CHR(13) || CHR(10) || q'[                    A.BRAND_CD,]'
  || CHR(13) || CHR(10) || q'[                    A.STOR_CD, ]'
  || CHR(13) || CHR(10) || q'[                    A.SALE_DT, ]'
  || CHR(13) || CHR(10) || q'[                    SUM(A.PAY_AMT) - MIN(C.CHANGE_AMT) PAY_AMT]'
  || CHR(13) || CHR(10) || q'[              FROM  SALE_ST A, ]'
  || CHR(13) || CHR(10) || q'[                    S_STORE B, ]'
  || CHR(13) || CHR(10) || q'[                    (SELECT COMP_CD, BRAND_CD, STOR_CD, SALE_DT, SUM(CHANGE_AMT + REMAIN_AMT) CHANGE_AMT  ]'
  || CHR(13) || CHR(10) || q'[                       FROM SALE_ST         ]'
  || CHR(13) || CHR(10) || q'[                      GROUP BY COMP_CD, BRAND_CD, STOR_CD, SALE_DT ) C     ]'
  || CHR(13) || CHR(10) || q'[             WHERE A.PAY_DIV IN ('10', '30')]'
  || CHR(13) || CHR(10) || q'[               AND ]' || ls_sql_date
  || CHR(13) || CHR(10) || q'[               AND A.COMP_CD  = B.COMP_CD   ]'
  || CHR(13) || CHR(10) || q'[               AND A.BRAND_CD = B.BRAND_CD  ]'
  || CHR(13) || CHR(10) || q'[               AND A.STOR_CD  = B.STOR_CD   ]'
  || CHR(13) || CHR(10) || q'[               AND A.COMP_CD  = C.COMP_CD   ]'
  || CHR(13) || CHR(10) || q'[               AND A.BRAND_CD = C.BRAND_CD  ]'
  || CHR(13) || CHR(10) || q'[               AND A.STOR_CD  = C.STOR_CD   ]'
  || CHR(13) || CHR(10) || q'[               AND A.SALE_DT  = C.SALE_DT   ]'
  || CHR(13) || CHR(10) ||  '                AND A.COMP_CD  = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) || q'[             GROUP BY A.COMP_CD, A.BRAND_CD, A.STOR_CD, A.SALE_DT ]'
  || CHR(13) || CHR(10) || q'[        ) S]'
  || CHR(13) || CHR(10) || q'[ WHERE S.COMP_CD  = J.COMP_CD  ]'
  || CHR(13) || CHR(10) || q'[   AND S.BRAND_CD = J.BRAND_CD ]'
  || CHR(13) || CHR(10) || q'[   AND S.STOR_CD  = J.STOR_CD  ]'
  || CHR(13) || CHR(10) || q'[   AND S.SALE_DT  = J.SALE_DT  ]'
  || CHR(13) || CHR(10) ||  '    AND S.COMP_CD  =  ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) || q'[ ORDER BY S.SALE_DT, S.BRAND_CD, S.STOR_CD ]';

  V_CNT  := qry_hd.LAST;

  ls_sql := ls_sql_with || ls_sql_main;

  dbms_output.put_line('-----------ls_sql-----------');
  dbms_output.put_line(ls_sql);


  V_SQL :=
     ' SELECT * '
  || '   FROM ( '
  || ls_sql
  || '        ) S_SALE '
  || ' PIVOT '
  || ' (SUM(GRD_AMT) VCOL1 , '
  || '  SUM(PAY_AMT) VCOL2   '
  || ' FOR ( CROSS_CD ) IN ( '
  || V_CROSSTAB
  || ' ) ) '
  || ' ORDER BY SALE_DT';

  dbms_output.put_line('-----------V_SQL-----------');
  dbms_output.put_line(V_SQL);

  OPEN PR_HEADER FOR V_HD;
  OPEN PR_RESULT FOR V_SQL;

  PR_RTN_CD  := ls_err_cd;
  PR_RTN_MSG := ls_err_msg ;
EXCEPTION
  WHEN ERR_HANDLER THEN
       PR_RTN_CD  := ls_err_cd;
       PR_RTN_MSG := ls_err_msg;
       dbms_output.put_line( PR_RTN_MSG );
  WHEN OTHERS THEN
       PR_RTN_CD  := '4999999';
       PR_RTN_MSG := SQLERRM;
       dbms_output.put_line( PR_RTN_MSG );
END;

/
