--------------------------------------------------------
--  DDL for Procedure SP_SALE5130
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE5130" -- 매출관리>신규메뉴>상품권 판매현황
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
/*
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2011-09-07                   1. CREATED THIS PROCEDURE.

   NOTES: SP_SALE5130L0
*/
  TYPE rec_hd IS RECORD
      ( GIFT_CD   VARCHAR2(20),
        GIFT_NM   VARCHAR2(60)
      );
  TYPE tb_hd IS TABLE OF rec_hd INDEX BY PLS_INTEGER;
  qry_hd          tb_hd;

  V_CROSSTAB      VARCHAR2(30000);
  V_SQL           VARCHAR2(30000);
  V_HD            VARCHAR2(30000);
  V_HD1           VARCHAR2(20000);
  V_HD2           VARCHAR2(20000);
  V_CNT           PLS_INTEGER;

  ls_sql          VARCHAR2(30000);
  ls_sql_with     VARCHAR2(30000);
  ls_sql_main     VARCHAR2(30000);
  ls_sql_date     VARCHAR2(1000);
  ls_sql_store    VARCHAR2(20000);      -- 점포 WITH  S_STORE
  ls_sql_item     VARCHAR2(20000);      -- 제품 WITH  S_ITEM
  ls_date1        VARCHAR2(2000);       -- 조회일자 (기준)
  ls_date2        VARCHAR2(2000);       -- 조회일자 (대비)
  ls_ex_date1     VARCHAR2(2000);       -- 조회일자 제외 (기준)
  ls_ex_date2     VARCHAR2(2000);       -- 조회일자 제외 (대비)
  ls_sql_crosstab_main VARCHAR2(30000); -- CORSSTAB TITLE

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
     CHR(13) || CHR(10) || q'[  SELECT A.ITEM_CD AS GIFT_CD,]'
  || CHR(13) || CHR(10) || q'[        A.ITEM_CD || '(' || NVL(C.CODE_NM, ' ') || ')' GIFT_NM    ]'
  || CHR(13) || CHR(10) ||  '    FROM SALE_JDG A,                                                '
  || CHR(13) || CHR(10) ||  '         S_STORE  X,                                                '
  || CHR(13) || CHR(10) ||  '         (SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM       '
  || CHR(13) || CHR(10) ||  '            FROM COMMON C, LANG_COMMON L                            '
  || CHR(13) || CHR(10) ||  '           WHERE C.COMP_CD = L.COMP_CD(+)							 '
  || CHR(13) || CHR(10) ||  '             AND C.CODE_TP = L.CODE_TP(+)                           '
  || CHR(13) || CHR(10) ||  '             AND C.CODE_CD = L.CODE_CD(+)                           '
  || CHR(13) || CHR(10) ||  '             AND C.COMP_CD = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) || q'[            AND C.CODE_TP = '01110'                               ]'
  || CHR(13) || CHR(10) ||  '             AND L.LANGUAGE_TP(+) = ''' || PSV_LANG_CD || ''''
  || CHR(13) || CHR(10) ||  '         )        C                                                 '
  || CHR(13) || CHR(10) ||  '   WHERE A.COMP_CD  = X.COMP_CD									 '
  || CHR(13) || CHR(10) ||  '     AND A.BRAND_CD = X.BRAND_CD                                    '
  || CHR(13) || CHR(10) ||  '     AND A.STOR_CD  = X.STOR_CD                                     '
  || CHR(13) || CHR(10) ||  '     AND A.COMP_CD  = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) ||  '     AND ' || ls_sql_date
  || CHR(13) || CHR(10) ||  '     AND C.CODE_CD (+)  = A.ITEM_CD                                 '
  || CHR(13) || CHR(10) ||  '   GROUP BY A.ITEM_CD, C.CODE_NM                                    '
  || CHR(13) || CHR(10) ||  '   ORDER BY A.ITEM_CD DESC                                           ';

  ls_sql := ls_sql_with || ls_sql_crosstab_main;
  dbms_output.put_line('-----------ls_sql-----------');
  dbms_output.put_line(ls_sql);

  EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd;

  IF SQL%ROWCOUNT = 0 THEN
     ls_err_cd  := '4000100';
     ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD, ls_err_cd);
     RAISE ERR_HANDLER;
  END IF;

  V_HD1 := ' SELECT BRAND, BRAND_NM, STOR_CD, STOR_NM, TOTAL, TOTAL, ';
  V_HD2 := ' SELECT BRAND, BRAND_NM, STOR_CD, STOR_NM, CNT, AMT, ';

  FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
    BEGIN
      IF i > 1 THEN
         V_CROSSTAB := V_CROSSTAB || ' , ';
         V_HD1 := V_HD1 || ' , ';
         V_HD2 := V_HD2 || ' , ';
      END IF;
      V_CROSSTAB := V_CROSSTAB || ''''   || qry_hd(i).GIFT_CD || ''''  ;
      V_HD1 := V_HD1 || ''''   || qry_hd(i).GIFT_NM || ''' CT' || TO_CHAR(i*2 - 1) || ',';
      V_HD1 := V_HD1 || ''''   || qry_hd(i).GIFT_NM || ''' CT' || TO_CHAR(i*2);
      V_HD2 := V_HD2 || ' CNT  CT' || TO_CHAR(i*2 - 1 ) || ',';
      V_HD2 := V_HD2 || ' AMT  CT' || TO_CHAR(i*2);
    END;
  END LOOP;

    V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
    V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
    V_HD   := ' WITH S_HD AS ( '
    || chr(13)||chr(10) || ' SELECT FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''BRAND_CD'') AS BRAND                  '   -- 영업조직
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''BRAND_CD'') AS BRAND_NM               '   -- 영업조직
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''STOR_CD'') AS STOR_CD                 '   -- 점포
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''STOR_NM'') AS STOR_NM                 '   -- 점포명
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''SALE_QTY'') AS CNT                    '   -- 매출수량
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''SALE_AMT'') AS AMT                    '   -- 매출금액
    || chr(13)||chr(10) || '      , FC_GET_HEADER('''||PSV_COMP_CD||''' , '''||PSV_LANG_CD||''' , ''TOTAL'') AS TOTAL                     '   -- 합계
    || chr(13)||chr(10) || '   FROM DUAL                                                                          '
    || chr(13)||chr(10) || ' )                                                                                    '
    ||  V_HD1 || ' UNION ALL ' || V_HD2
        ;
  dbms_output.put_line('-----------V_HD-----------');
  dbms_output.put_line(V_HD);

  ls_sql_main :=
     CHR(13) || CHR(10) ||  '  SELECT X.BRAND_CD,                                                '
  || CHR(13) || CHR(10) ||  '         X.BRAND_NM,                                                '
  || CHR(13) || CHR(10) ||  '         X.STOR_CD,                                                 '
  || CHR(13) || CHR(10) ||  '         X.STOR_NM,                                                 '
  || CHR(13) || CHR(10) || q'[        A.ITEM_CD,                                                ]'
  || CHR(13) || CHR(10) ||  '         SUM(SUM(A.SALE_QTY)) OVER(PARTITION BY X.BRAND_CD, X.BRAND_NM, A.STOR_CD, X.STOR_NM) AS TOT_QTY,'
  || CHR(13) || CHR(10) ||  '         SUM(SUM(A.GRD_AMT)) OVER(PARTITION BY X.BRAND_CD, X.BRAND_NM, A.STOR_CD, X.STOR_NM) AS TOT_AMT,'
  || CHR(13) || CHR(10) ||  '         SUM(A.SALE_QTY) PAY_QTY,                                   '
  || CHR(13) || CHR(10) ||  '         SUM(A.GRD_AMT)  PAY_AMT                                    '
  || CHR(13) || CHR(10) ||  '   FROM (SELECT COMP_CD, BRAND_CD, SALE_DT, STOR_CD, ITEM_CD, SALE_QTY, '
  || CHR(13) || CHR(10) || q'[               DECODE(NVL(VAL_C1, 'G'), 'G', GRD_AMT, 'N', GRD_AMT + VAT_AMT, 'T', SALE_AMT) GRD_AMT ]'
  || CHR(13) || CHR(10) ||  '           FROM SALE_JDG A, '
  || CHR(13) || CHR(10) ||  '                (SELECT VAL_C1 '
  || CHR(13) || CHR(10) ||  '                   FROM COMMON '
  || CHR(13) || CHR(10) ||  '                  WHERE COMP_CD = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) || q'[                   AND CODE_TP = '01435' ]'
  || CHR(13) || CHR(10) || q'[                   AND CODE_CD = '200'   ]'
  || CHR(13) || CHR(10) ||  '                ) Z '
  || CHR(13) || CHR(10) ||  '          WHERE ' || ls_sql_date
  || CHR(13) || CHR(10) ||  '        )        A,'
  || CHR(13) || CHR(10) ||  '        S_STORE  X,                                                 '
  || CHR(13) || CHR(10) ||  '         (SELECT C.CODE_CD, NVL(L.CODE_NM, C.CODE_NM) CODE_NM       '
  || CHR(13) || CHR(10) ||  '            FROM COMMON C, LANG_COMMON L                            '
  || CHR(13) || CHR(10) ||  '           WHERE C.COMP_CD = L.COMP_CD(+)							 '
  || CHR(13) || CHR(10) ||  '             AND C.CODE_TP = L.CODE_TP(+)                           '
  || CHR(13) || CHR(10) ||  '             AND C.CODE_CD = L.CODE_CD(+)                           '
  || CHR(13) || CHR(10) ||  '             AND C.COMP_CD = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) || q'[            AND C.CODE_TP = '01110'                               ]'
  || CHR(13) || CHR(10) ||  '             AND L.LANGUAGE_TP(+) = ''' || PSV_LANG_CD || ''''
  || CHR(13) || CHR(10) ||  '         )        C                                                 '
  || CHR(13) || CHR(10) ||  '   WHERE A.COMP_CD  = X.COMP_CD									 '
  || CHR(13) || CHR(10) ||  '     AND A.BRAND_CD = X.BRAND_CD                                    '
  || CHR(13) || CHR(10) ||  '     AND A.STOR_CD  = X.STOR_CD                                     '
  || CHR(13) || CHR(10) ||  '     AND A.COMP_CD = ''' || PSV_COMP_CD || ''''
  || CHR(13) || CHR(10) ||  '     AND C.CODE_CD (+)  = A.ITEM_CD                                 '
  || CHR(13) || CHR(10) ||  '   GROUP BY X.BRAND_CD, X.BRAND_NM, A.STOR_CD, X.STOR_CD, X.STOR_NM, A.ITEM_CD ';

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
  || ' (SUM(PAY_QTY) VCOL1 , '
  || '  SUM(PAY_AMT) VCOL2   '
  || ' FOR ( ITEM_CD ) IN ( '
  || V_CROSSTAB
  || ' ) ) '
  || ' ORDER BY BRAND_CD, STOR_CD';

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
