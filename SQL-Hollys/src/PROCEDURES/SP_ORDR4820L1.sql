--------------------------------------------------------
--  DDL for Procedure SP_ORDR4820L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ORDR4820L1" /* 주문확정현황_점포별 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_ITEM_GRP    IN  VARCHAR2 ,                -- 제품군
  PSV_ITEM_TP     IN  VARCHAR2 ,                -- 자재그룹
  PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
  PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2               ,  -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_ORDR4820L1  주문확정현황_점포별
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2011-07-21         1. CREATED THIS PROCEDURE.

   NOTES:

   OBJECT NAME:     SP_ORDR4820L1
   SYSDATE:         2011-07-21
   USERNAME:
   TABLE NAME:
******************************************************************************/

    TYPE rec_ct_hd IS RECORD
    (
         STOR_CD VARCHAR2(10)
      ,  STOR_NM VARCHAR2(60)
    );

    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd                  tb_ct_hd;

    V_CROSSTAB              VARCHAR2(30000);
    V_SQL1                  VARCHAR2(1000);
    V_SQL2                  VARCHAR2(1000);
    V_SQL3                  VARCHAR2(1000);
    V_HD                    VARCHAR2(30000);

    ls_sql                  VARCHAR2(30000) ;
    ls_sql_with             VARCHAR2(30000) ;
    ls_sql_main             VARCHAR2(10000) ;
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main    VARCHAR2(30000) ;   -- CORSSTAB TITLE

    ls_err_cd               VARCHAR2(7) := '0' ;
    ls_err_msg              VARCHAR2(500) ;

    ERR_HANDLER     EXCEPTION;

BEGIN
    dbms_output.enable( 9000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' H.SHIP_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND H.SHIP_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    /* 가로축 데이타 FETCH */
    ls_sql_crosstab_main :=
         '  SELECT   STOR_CD  '
    ||   '       ,   STOR_NM  '
    ||   '    FROM   (  '
    ||   '              SELECT   H.STOR_CD   '
    ||   '                   ,   S.STOR_NM   '
    ||   '                   ,   SUM(D.ORD_CQTY)  AS ORD_CQTY '
    ||   '                FROM   ORDER_HD H  '
    ||   '                   ,   ORDER_DT D  '
    ||   '                   ,   S_STORE  S  '
    ||   '               WHERE   H.COMP_CD  = D.COMP_CD  '
    ||   '                 AND   H.BRAND_CD = D.BRAND_CD '
    ||   '                 AND   H.SHIP_DT  = D.SHIP_DT  '
    ||   '                 AND   H.STOR_CD  = D.STOR_CD  '
    ||   '                 AND   H.ORD_SEQ  = D.ORD_SEQ  '
    ||   '                 AND   H.ORD_FG   = D.ORD_FG   '
    ||   '                 AND   H.COMP_CD  = S.COMP_CD  '
    ||   '                 AND   H.STOR_CD  = S.STOR_CD  '
    ||   '                 AND   H.COMP_CD  = ''' || PSV_COMP_CD || ''''
    ||   '                 AND   ' || ls_sql_date
    ||   '               GROUP BY H.STOR_CD, S.STOR_NM '
    ||   '           )  '
    ||   '   WHERE ROWNUM <= 500 '
    ||   '   ORDER BY ORD_CQTY DESC ';

    ls_sql_crosstab_main := ls_sql_with || ls_sql_crosstab_main;

    dbms_output.put_line(ls_sql_crosstab_main);

    BEGIN
        EXECUTE IMMEDIATE  ls_sql_crosstab_main BULK COLLECT INTO qry_hd ;

         IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            RAISE ERR_HANDLER ;
        WHEN NO_DATA_FOUND THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        WHEN OTHERS THEN
            ls_err_cd := '4999999' ;
            ls_err_msg := SQLERRM ;
            RAISE ERR_HANDLER ;
    END;

    V_HD := ' SELECT '  ;

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ', ';
               V_HD := V_HD || ', ' ;
            END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).STOR_CD || '''';
            V_HD := V_HD || '''( ' || qry_hd(i).STOR_CD || ' )' || ' ' || qry_hd(i).STOR_NM || '''';
        END;
    END LOOP;

    V_HD :=  V_HD || ' FROM DUAL WHERE ROWNUM = 1 ';

    dbms_output.put_line(V_HD);

    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;

    /* MAIN SQL */
    ls_sql_main :=
         '  SELECT   H.BRAND_CD  '
    ||   '       ,   D.ORD_FG    '
    ||   '       ,   I.ITEM_GRP  '
    ||   '       ,   I.ITEM_TP   '
    ||   '       ,   D.ITEM_CD   '
    ||   '       ,   I.ITEM_NM   '
    ||   '       ,   D.ORD_UNIT  '
    ||   '       ,   H.STOR_CD   '
    ||   '       ,   SUM(SUM(D.ORD_QTY))  OVER (PARTITION BY H.BRAND_CD, D.ORD_FG, D.ITEM_CD) AS REQ_ORD_QTY    '
    ||   '       ,   SUM(SUM(D.ORD_CQTY)) OVER (PARTITION BY H.BRAND_CD, D.ORD_FG, D.ITEM_CD) AS CFM_ORD_CQTY   '
    ||   '       ,   SUM(D.ORD_CQTY)   AS ORD_CQTY '
    ||   '    FROM   ORDER_HD H  '
    ||   '       ,   ORDER_DT D  '
    ||   '       ,   S_STORE  S  '
    ||   '       ,   S_ITEM   I  '
    ||   '   WHERE   H.COMP_CD  = D.COMP_CD  '
    ||   '     AND   H.BRAND_CD = D.BRAND_CD '
    ||   '     AND   H.SHIP_DT  = D.SHIP_DT  '
    ||   '     AND   H.STOR_CD  = D.STOR_CD  '
    ||   '     AND   H.ORD_GRP  = D.ORD_GRP  '
    ||   '     AND   H.ORD_SEQ  = D.ORD_SEQ  '
    ||   '     AND   H.ORD_FG   = D.ORD_FG   '
    ||   '     AND   D.COMP_CD  = S.COMP_CD  '
    ||   '     AND   D.BRAND_CD = S.BRAND_CD '
    ||   '     AND   D.STOR_CD  = S.STOR_CD  '
    ||   '     AND   D.COMP_CD  = I.COMP_CD  '
    ||   '     AND   D.ITEM_CD  = I.ITEM_CD  '
    ||   '     AND   H.COMP_CD  = :SCH_COMP_CD  '
    ||   '     AND   (:SCH_ITEM_GRP IS NULL OR I.ITEM_GRP = :SCH_ITEM_GRP) '
    ||   '     AND   (:SCH_ITEM_TP  IS NULL OR I.ITEM_TP  = :SCH_ITEM_TP ) '
    ||   '     AND   D.ORD_QTY  <> 0  '
    ||   '     AND   ' || ls_sql_date
    ||   '   GROUP BY H.BRAND_CD '
    ||   '       ,    D.ORD_FG   '
    ||   '       ,    I.ITEM_GRP '
    ||   '       ,    I.ITEM_TP  '
    ||   '       ,    D.ITEM_CD  '
    ||   '       ,    I.ITEM_NM  '
    ||   '       ,    D.ORD_UNIT '
    ||   '       ,    H.STOR_CD  ';

    --ls_sql := ls_sql_with || ls_sql_main;

    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL1 :=
         '  SELECT   *  '
    ||   '    FROM   (  ';
    --||   ls_sql
    V_SQL2 :=
         '           ) ORD '
    ||   '  PIVOT    '
    ||   '  (   '
    ||   '     SUM(ORD_CQTY) AS VCOL1 '
    ||   '     FOR (STOR_CD) IN '
    ||   '     (   ';
    V_SQL3 :=
    --||   V_CROSSTAB
         '     )   '
    ||   '  )   '
    ||   '   ORDER BY 1, 2, 3, 4 ASC';

    --dbms_output.put_line(V_HD) ;
    --dbms_output.put_line(ls_sql_with);
    --dbms_output.put_line(ls_sql_main);
    --dbms_output.put_line(V_CROSSTAB);
    dbms_output.put_line(V_SQL1||ls_sql_with||ls_sql_main||V_SQL2||V_CROSSTAB||V_SQL3) ;

    OPEN PR_HEADER FOR V_HD;
    OPEN PR_RESULT FOR V_SQL1||ls_sql_with||ls_sql_main||V_SQL2||V_CROSSTAB||V_SQL3 USING PSV_COMP_CD, PSV_ITEM_GRP, PSV_ITEM_GRP, PSV_ITEM_TP, PSV_ITEM_TP;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
END ;

/
