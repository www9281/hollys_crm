--------------------------------------------------------
--  DDL for Procedure SP_MEPA1010L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEPA1010L1" /* 회원 포인트 적립현황(연령대) */
(
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_GFR_DATE    IN  VARCHAR2 ,                -- 시작일자
    PSV_GTO_DATE    IN  VARCHAR2 ,                -- 종료일자
    PSV_CUST_LVL    IN  VARCHAR2 ,                -- 고객등급
    PSV_CUST_SEX    IN  VARCHAR2 ,                -- 고객성별
    PSV_CUST_AGE    IN  VARCHAR2 ,                -- 고객연령대
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
) 
IS
/******************************************************************************
   NAME:       SP_MEPA1010L1  회원 포인트 적립현황(연령대) 
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEPA1010L1
      SYSDATE:         2010-03-08
      USERNAME:
      TABLE NAME:
******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
        ( SALE_DAY     VARCHAR2(8),
          SALE_DAY_NM  VARCHAR2(12)
        );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1          VARCHAR2(20000);
    V_HD2          VARCHAR2(20000);
    V_CNT          PLS_INTEGER;

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(20000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_01415 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    ls_sql_pos      VARCHAR2(2000);     -- POS_NO
    
    ls_str_dt       VARCHAR2(20) := NULL;
    ls_end_dt       VARCHAR2(20) := NULL;
    
    ls_err_cd       VARCHAR2(20) := '0';
    ls_err_msg      VARCHAR2(1000) ;

    ERR_HANDLER     EXCEPTION;

BEGIN
    dbms_output.enable( 1000000 ) ;
    PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;
    
    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' CSH.USE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND CSH.USE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    -- 공통코드 참조 Table 생성 ---------------------------------------------------
    --   ls_sql_cm_01415 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '01415') ;
    -------------------------------------------------------------------------------

/*
    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;
*/

/* 가로축 데이타 FETCH */
   ls_sql_crosstab_main :=
          ' SELECT  CODE_CD,  '
        ||'         CODE_NM'
        ||' FROM    COMMON                                                                                 '
        ||' WHERE   CODE_TP = ''01760'''
        ||' AND     USE_YN  = ''Y'''
        ||' ORDER BY CODE_CD';
 
    ls_sql := ls_sql_crosstab_main ;

    dbms_output.put_line(ls_sql) ;

    BEGIN
        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

         IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    EXCEPTION
        WHEN ERR_HANDLER THEN
            RAISE ERR_HANDLER ;
        WHEN NO_DATA_FOUND THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        WHEN OTHERS THEN
            ls_err_cd := '4999999' ;
            ls_err_msg := SQLERRM ;
            RAISE ERR_HANDLER ;
    END;

    V_HD1 := ' SELECT  '        
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'BRAND_CD')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'BRAND_NM')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'STOR_CD' )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'STOR_NM' )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'TOTAL'   )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'TOTAL'   )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'TOTAL'   )||''', ';
          
    V_HD2 := ' SELECT  '        
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'BRAND_CD')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'BRAND_NM')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'STOR_CD' )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'STOR_NM' )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'VISIT_CUST_CNT')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'TOT_SAV_PT'    )||''', '
          || '        '''||FC_GET_WORDPACK(PSV_LANG_CD,'AVG_SAV_PT'    )||''', ';

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ', ';
               V_HD1 := V_HD1 || ' , ' ;
               V_HD2 := V_HD2 || ' , ' ;
            END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).SALE_DAY ||'''';
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DAY_NM || ''' CT' || TO_CHAR(i*3 - 2) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DAY_NM || ''' CT' || TO_CHAR(i*3 - 1) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_DAY_NM || ''' CT' || TO_CHAR(i*3)  ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_LANG_CD, 'VISIT_CUST_CNT')|| ''' CT' || TO_CHAR(i*3 - 2 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_LANG_CD, 'TOT_SAV_PT'    )|| ''' CT' || TO_CHAR(i*3 - 1 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_LANG_CD, 'AVG_SAV_PT'    )||'''  CT' || TO_CHAR(i*3)   ;
        END;
    END LOOP;

    V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
    V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
    V_HD   := PKG_REPORT.f_olap_hd(PSV_LANG_CD)  ||  V_HD1 || ' UNION ALL ' || V_HD2 ;


    /* MAIN SQL */
    ls_sql_main :=                   '   SELECT  V03.BRAND_CD                                        '
                ||chr(13)||chr(10)|| '         , V03.BRAND_NM                                        '
                ||chr(13)||chr(10)|| '         , V03.STOR_CD                                         '
                ||chr(13)||chr(10)|| '         , V03.STOR_NM                                         '
                ||chr(13)||chr(10)|| '         , V03.AGE_GROUP                                       '
                ||chr(13)||chr(10)|| '         , SUM(V03.DAY_CUST_CNT) OVER() AS TOT_CUST_CNT        '
                ||chr(13)||chr(10)|| '         , SUM(V03.DAY_SAV_PT  ) OVER() AS TOT_SAV_PT          '
                ||chr(13)||chr(10)|| '         , CASE WHEN SUM(V03.DAY_CUST_CNT) OVER() = 0 THEN 0   '
                ||chr(13)||chr(10)|| '                ELSE SUM(V03.DAY_SAV_PT  ) OVER() / SUM(V03.DAY_CUST_CNT) OVER()'
                ||chr(13)||chr(10)|| '           END  AS TOT_AVG_SAV_PT                              '
                ||chr(13)||chr(10)|| '         , V03.DAY_CUST_CNT                                    '
                ||chr(13)||chr(10)|| '         , V03.DAY_SAV_PT                                      '
                ||chr(13)||chr(10)|| '         , CASE WHEN V03.DAY_CUST_CNT = 0 THEN 0               '
                ||chr(13)||chr(10)|| '                ELSE V03.DAY_SAV_PT / V03.DAY_CUST_CNT         '
                ||chr(13)||chr(10)|| '           END  AS DAY_AVG_SAV_PT                              '
                ||chr(13)||chr(10)|| '   FROM   (                                                    '
                ||chr(13)||chr(10)|| '           SELECT  STO.BRAND_CD                                '
                ||chr(13)||chr(10)|| '                 , STO.BRAND_NM                                '
                ||chr(13)||chr(10)|| '                 , CSH.STOR_CD                                 '
                ||chr(13)||chr(10)|| '                 , STO.STOR_NM                                 '
                ||chr(13)||chr(10)|| '                 , V02.AGE_GROUP                                  '
                ||chr(13)||chr(10)|| '                 , COUNT(DISTINCT CSH.CARD_ID) AS DAY_CUST_CNT '
                ||chr(13)||chr(10)|| '                 , SUM(CSH.SAV_PT)             AS DAY_SAV_PT   '
                ||chr(13)||chr(10)|| '           FROM    S_STORE         STO                         '
                ||chr(13)||chr(10)|| '                 , C_CARD_SAV_HIS  CSH                         '
                ||chr(13)||chr(10)|| '                 , C_CARD          CRD                         '
                ||chr(13)||chr(10)|| '                 ,(                                            '
                ||chr(13)||chr(10)|| '                   SELECT  V01.COMP_CD                         '
                ||chr(13)||chr(10)|| '                         , V01.CUST_ID                         '
                ||chr(13)||chr(10)|| '                         , GET_AGE_GROUP(V01.CUST_AGE) AGE_GROUP       '
                ||chr(13)||chr(10)|| '                   FROM   (                                            '
                ||chr(13)||chr(10)|| '                           SELECT  CST.COMP_CD                         '
                ||chr(13)||chr(10)|| '                                 , CST.CUST_ID                         '
                ||chr(13)||chr(10)|| '                                 , CASE WHEN REGEXP_INSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(CST.BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, ''^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])'') = 1 '
                ||chr(13)||chr(10)|| '                                        THEN  TRUNC((TO_NUMBER(SUBSTR('''||PSV_GTO_DATE||''', 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN CST.LUNAR_DIV = ''L'' THEN UF_LUN2SOL(BIRTH_DT, ''0'') ELSE CST.BIRTH_DT END, 1, 6))) / 100 + 1)                   '
                ||chr(13)||chr(10)|| '                                   ELSE 999 END AS CUST_AGE            '
                ||chr(13)||chr(10)|| '                           FROM    C_CUST     CST                      '
                ||chr(13)||chr(10)|| '                           WHERE   CST.COMP_CD = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)|| '                           AND     CST.LVL_CD  = NVL('''||PSV_CUST_LVL||''', CST.LVL_CD )'
                ||chr(13)||chr(10)|| '                           AND     CST.SEX_DIV = NVL('''||PSV_CUST_SEX||''', CST.SEX_DIV)'
                ||chr(13)||chr(10)|| '                          ) V01                                        '
                ||chr(13)||chr(10)|| '                      ) V02                                            '
                ||chr(13)||chr(10)|| '           WHERE   CSH.BRAND_CD   = STO.BRAND_CD                       '
                ||chr(13)||chr(10)|| '           AND     CSH.STOR_CD    = STO.STOR_CD                        '
                ||chr(13)||chr(10)|| '           AND     CSH.COMP_CD    = CRD.COMP_CD                        '
                ||chr(13)||chr(10)|| '           AND     CSH.CARD_ID    = CRD.CARD_ID                        '
                ||chr(13)||chr(10)|| '           AND     CRD.COMP_CD    = V02.COMP_CD                        '
                ||chr(13)||chr(10)|| '           AND     CRD.CUST_ID    = V02.CUST_ID                        '
                ||chr(13)||chr(10)|| '           AND     V02.AGE_GROUP  = NVL('''||PSV_CUST_AGE||''', V02.AGE_GROUP)'
                ||chr(13)||chr(10)||q'[          AND     CSH.SAV_USE_FG IN('3', '4')                ]'
                ||chr(13)||chr(10)|| '           AND     '||ls_sql_date
                ||chr(13)||chr(10)|| '           GROUP BY                                            '
                ||chr(13)||chr(10)|| '                   STO.BRAND_CD                                '
                ||chr(13)||chr(10)|| '                 , STO.BRAND_NM                                '
                ||chr(13)||chr(10)|| '                 , CSH.STOR_CD                                 '
                ||chr(13)||chr(10)|| '                 , STO.STOR_NM                                 '
                ||chr(13)||chr(10)|| '                 , V02.AGE_GROUP                               '
                ||chr(13)||chr(10)|| '         ) V03                                                 '
        ;

    V_CNT := qry_hd.LAST;

    ls_sql := ls_sql_with || ls_sql_main;

/* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || ls_sql
            || ' ) SCM '
            || ' PIVOT '
            || ' ( SUM(DAY_CUST_CNT  ) VCOL1 '
            || ' , SUM(DAY_SAV_PT    ) VCOL2 '
            || ' , AVG(DAY_AVG_SAV_PT) VCOL3 '
            || ' FOR (AGE_GROUP) IN ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2,3 ASC';

    dbms_output.put_line( V_HD) ;

    dbms_output.put_line( V_SQL) ;

    OPEN PR_HEADER FOR      V_HD;
    OPEN PR_RESULT FOR      V_SQL;


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
