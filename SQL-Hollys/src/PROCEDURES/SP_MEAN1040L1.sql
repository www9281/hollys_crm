--------------------------------------------------------
--  DDL for Procedure SP_MEAN1040L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN1040L1" /* 회원관리지표-고객창출관점-기간 */
(
    PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
    PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
    PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
    PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
    PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
    PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
    PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
    PSV_STR_YM      IN  VARCHAR2 ,                -- 기준시작년월
    PSV_END_YM      IN  VARCHAR2 ,                -- 기준종료년월
    PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
    PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
    PR_RTN_CD       OUT VARCHAR2 ,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_MEAN1040L1  회원관리지표-고객창출관점-기간
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2010-02-01         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN1040L1
      SYSDATE:         2010-03-08
      USERNAME:
      TABLE NAME:
******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
        ( SALE_YM     VARCHAR2(8),
          SALE_YM_NM  VARCHAR2(12)
        );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1         VARCHAR2(20000);
    V_HD2         VARCHAR2(20000);
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

    ls_err_cd       VARCHAR2(20) := '0';
    ls_err_msg      VARCHAR2(1000) ;


    ERR_HANDLER     EXCEPTION;

BEGIN
    dbms_output.enable( 1000000 ) ;
    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;

/*
    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' A.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND A.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------
*/

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
          ' SELECT  TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM ||''', ''YYYYMM''), ROWNUM - 1), ''YYYYMM'' ) AS SALE_YM,   '
        ||'         TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM ||''', ''YYYYMM''), ROWNUM - 1), ''YYYY-MM'') AS SALE_YM_NM '
        ||' FROM    TAB '
        ||' WHERE   ROWNUM <= 1 + MONTHS_BETWEEN(TO_DATE('''||PSV_END_YM ||''', ''YYYYMM''), TO_DATE('''||PSV_STR_YM ||''', ''YYYYMM''))'
        ||' ORDER BY 1  ';

    ls_sql := ls_sql_crosstab_main ;

    --dbms_output.put_line(ls_sql) ;

    BEGIN
        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

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
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        WHEN OTHERS THEN
            ls_err_cd := '4999999' ;
            ls_err_msg := SQLERRM ;
            RAISE ERR_HANDLER ;
    END;

    V_HD1 := ' SELECT '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'AGE_GROUP')||''', '        
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'AGE_GROUP')||''', ';
    V_HD2 := V_HD1;

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
               V_HD1 := V_HD1 || ' , ' ;
               V_HD2 := V_HD2 || ' , ' ;
            END IF;
            V_CROSSTAB := V_CROSSTAB || qry_hd(i).SALE_YM;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*3 - 2) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*3 - 1) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*3)  ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMB_SALE_CUST_CNT')|| ''' CT' || TO_CHAR(i*3 - 2 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMB_NEW_CUST_CNT') || ''' CT' || TO_CHAR(i*3 - 1 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMB_NEW_SETT_RATE')|| ''' CT' || TO_CHAR(i*3)   ;
        END;
    END LOOP;

    V_HD1 := V_HD1 || ' FROM DUAL ' ;
    V_HD2 := V_HD2 || ' FROM DUAL ' ;
    V_HD  := V_HD1 || ' UNION ALL ' || V_HD2 ;


    /* MAIN SQL */
    ls_sql_main :=                  '   , W_CST AS                                               '
                ||chr(13)||chr(10)||'   (                                                           '
                ||chr(13)||chr(10)||'       SELECT  /*+ INDEX(C_CUST IDX05_C_CUST) */                   '
                ||chr(13)||chr(10)||'               COMP_CD                                         '
                ||chr(13)||chr(10)||'             , CUST_ID                                         '
                ||chr(13)||chr(10)||'             , GET_CHG_BIRTH_TO_AGE(COMP_CD, CUST_ID) AS CUST_AGE  '
                ||chr(13)||chr(10)||'             , TO_CHAR(ADD_MONTHS(TO_DATE(JOIN_DT, ''YYYYMMDD''), 1), ''YYYYMM'') AS SALE_YM '
                ||chr(13)||chr(10)||'       FROM    C_CUST                     '
                ||chr(13)||chr(10)||'       WHERE   COMP_CD  = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'       AND     JOIN_DT >= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_STR_YM||''', ''YYYYMM''), -1), ''YYYYMM'')||''01'' '
                ||chr(13)||chr(10)||'       AND     JOIN_DT <= TO_CHAR(ADD_MONTHS(TO_DATE('''||PSV_END_YM||''', ''YYYYMM''), -1), ''YYYYMM'')||''31'' '
                ||chr(13)||chr(10)||'       AND     SUBSTR(NVL(LEAVE_DT, ''99991231''), 1, 8)  >= '''||PSV_END_YM||'''||''01'''
                ||chr(13)||chr(10)||'       AND     CUST_STAT IN (''2'', ''9'')                                                                       '
                ||chr(13)||chr(10)||'       AND     JOIN_DT <= '''||PSV_END_YM||'''||''31'' '
                ||chr(13)||chr(10)||'   )                                                           '
                ||chr(13)||chr(10)||'   SELECT  V04.SALE_YM                                         '
                ||chr(13)||chr(10)||'         , V04.CODE_CD                                         '
                ||chr(13)||chr(10)||'         , V04.CODE_NM                                         '
                ||chr(13)||chr(10)||'         , NVL(V03.BUY_CUST_CNT, 0) AS BUY_CUST_CNT            '
                ||chr(13)||chr(10)||'         , V04.NEW_CUST_CNT                                    '
                ||chr(13)||chr(10)||'         , CASE WHEN V04.NEW_CUST_CNT = 0 THEN 0 ELSE NVL(V03.BUY_CUST_CNT, 0) / V04.NEW_CUST_CNT * 100 END AS SET_DWN_RATE'
                ||chr(13)||chr(10)||'   FROM   (                                                    '
                ||chr(13)||chr(10)||'           SELECT  V01.COMP_CD                                 '
                ||chr(13)||chr(10)||'                 , V01.SALE_YM                                 '
                ||chr(13)||chr(10)||'                 , COM.CODE_CD                                 '
                ||chr(13)||chr(10)||'                 , COM.CODE_NM                                 '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN V01.CUST_AGE BETWEEN COM.VAL_N1 AND COM.VAL_N2 THEN V01.BUY_CUST_CNT ELSE 0 END) BUY_CUST_CNT '
                ||chr(13)||chr(10)||'           FROM   (                                            '
                ||chr(13)||chr(10)||'                   SELECT  /*+ NO_MERGE */            '
                ||chr(13)||chr(10)||'                           MSS.COMP_CD                         '
                ||chr(13)||chr(10)||'                         , MSS.SALE_YM                         '
                ||chr(13)||chr(10)||'                         , MSS.CUST_AGE                        '
                ||chr(13)||chr(10)||'                         , SUM(CASE WHEN S_NUM = 1 THEN 1 ELSE 0 END) BUY_CUST_CNT'
                ||chr(13)||chr(10)||'                   FROM   (                                    '
                ||chr(13)||chr(10)||'                           SELECT  /*+ NO_MERGE */             '
                ||chr(13)||chr(10)||'                                   MSS.COMP_CD                 '
                ||chr(13)||chr(10)||'                                 , MSS.SALE_YM                 '
                ||chr(13)||chr(10)||'                                 , MSS.CUST_AGE                '
                ||chr(13)||chr(10)||'                                 , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.CUST_ID, MSS.SALE_YM ORDER BY MSS.CUST_AGE) S_NUM '
                ||chr(13)||chr(10)||'                           FROM    C_CUST_MSS  MSS             '
                ||chr(13)||chr(10)||'                                 , S_STORE     STO                    '
                ||chr(13)||chr(10)||'                                 , W_CST       CST             '
                ||chr(13)||chr(10)||'                           WHERE   STO.COMP_CD  = MSS.COMP_CD  '
                ||chr(13)||chr(10)||'                           AND     STO.BRAND_CD = MSS.BRAND_CD '        
                ||chr(13)||chr(10)||'                           AND     STO.STOR_CD  = MSS.STOR_CD  ' 
                ||chr(13)||chr(10)||'                           AND     CST.COMP_CD  = MSS.COMP_CD  '
                ||chr(13)||chr(10)||'                           AND     CST.SALE_YM  = MSS.SALE_YM  '
                ||chr(13)||chr(10)||'                           AND     CST.CUST_ID  = MSS.CUST_ID  '
                ||chr(13)||chr(10)||'                           AND     MSS.COMP_CD  = '''||PSV_COMP_CD   ||''''
                --||chr(13)||chr(10)||'                           AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') ' 
                ||chr(13)||chr(10)||'                          ) MSS                                '
                ||chr(13)||chr(10)||'                   GROUP BY MSS.COMP_CD, MSS.SALE_YM, MSS.CUST_AGE '
                ||chr(13)||chr(10)||'                  ) V01                                        '
                ||chr(13)||chr(10)||'                 ,(                                            '
                ||chr(13)||chr(10)||'                   SELECT  /*+ NO_MERGE */                     '
                ||chr(13)||chr(10)||'                           COMP_CD                             '
                ||chr(13)||chr(10)||'                         , CODE_CD                             '
                ||chr(13)||chr(10)||'                         , CODE_NM                             '
                ||chr(13)||chr(10)||'                         , SORT_SEQ                            '
                ||chr(13)||chr(10)||'                         , VAL_N1                              '
                ||chr(13)||chr(10)||'                         , VAL_N2                              '
                ||chr(13)||chr(10)||'                   FROM    COMMON                              '
                ||chr(13)||chr(10)||'                   WHERE   COMP_CD = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'                   AND     CODE_TP = ''01760''                 '
                ||chr(13)||chr(10)||'                   AND     USE_YN  = ''Y''                     '
                ||chr(13)||chr(10)||'                  ) COM                                        '
                ||chr(13)||chr(10)||'           WHERE   V01.COMP_CD = COM.COMP_CD                   '
                ||chr(13)||chr(10)||'           GROUP BY V01.COMP_CD, V01.SALE_YM, COM.CODE_CD, COM.CODE_NM '
                ||chr(13)||chr(10)||'          ) V03                                                '
                ||chr(13)||chr(10)||'        , (                                                    '
                ||chr(13)||chr(10)||'           SELECT  V02.COMP_CD                                 '
                ||chr(13)||chr(10)||'                 , V02.SALE_YM                                 '
                ||chr(13)||chr(10)||'                 , COM.CODE_CD                                 '
                ||chr(13)||chr(10)||'                 , COM.CODE_NM                                 '
                ||chr(13)||chr(10)||'                 , SUM(CASE WHEN V02.CUST_AGE BETWEEN COM.VAL_N1 AND COM.VAL_N2 THEN V02.NEW_CUST_CNT ELSE 0 END) NEW_CUST_CNT '
                ||chr(13)||chr(10)||'           FROM   (                                            '
                ||chr(13)||chr(10)||'                   SELECT  /*+ NO_MERGE */                     '
                ||chr(13)||chr(10)||'                           CST.COMP_CD                         '
                ||chr(13)||chr(10)||'                         , CST.SALE_YM                         '
                ||chr(13)||chr(10)||'                         , CST.CUST_AGE                        '
                ||chr(13)||chr(10)||'                         , COUNT(*) NEW_CUST_CNT               '
                ||chr(13)||chr(10)||'                   FROM    W_CST CST                           '
                ||chr(13)||chr(10)||'                   GROUP BY CST.COMP_CD, CST.SALE_YM, CST.CUST_AGE '
                ||chr(13)||chr(10)||'                  ) V02                                        '
                ||chr(13)||chr(10)||'                 ,(                                            '
                ||chr(13)||chr(10)||'                   SELECT  /*+ NO_MERGE */                     '
                ||chr(13)||chr(10)||'                           COMP_CD    '
                ||chr(13)||chr(10)||'                         , CODE_CD                             '
                ||chr(13)||chr(10)||'                         , CODE_NM                             '
                ||chr(13)||chr(10)||'                         , SORT_SEQ                            '
                ||chr(13)||chr(10)||'                         , VAL_N1                              '
                ||chr(13)||chr(10)||'                         , VAL_N2                              '
                ||chr(13)||chr(10)||'                   FROM    COMMON                              '
                ||chr(13)||chr(10)||'                   WHERE   COMP_CD = '''||PSV_COMP_CD   ||''''
                ||chr(13)||chr(10)||'                   AND     CODE_TP = ''01760''                 '
                ||chr(13)||chr(10)||'                   AND     USE_YN  = ''Y''                     '
                ||chr(13)||chr(10)||'                  ) COM                                        '
                ||chr(13)||chr(10)||'           WHERE   V02.COMP_CD = COM.COMP_CD                   '
                ||chr(13)||chr(10)||'           GROUP BY V02.COMP_CD, V02.SALE_YM, COM.CODE_CD, COM.CODE_NM '
                ||chr(13)||chr(10)||'          ) V04                                                '
                ||chr(13)||chr(10)||'   WHERE   V04.COMP_CD = V03.COMP_CD(+)                        '
                ||chr(13)||chr(10)||'   AND     V04.SALE_YM = V03.SALE_YM(+)                        '
                ||chr(13)||chr(10)||'   AND     V04.CODE_CD = V03.CODE_CD(+)                        '

        ;

    V_CNT := qry_hd.LAST;

    ls_sql := ls_sql_with || ls_sql_main;
    --dbms_output.put_line(ls_sql) ;
/* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=   ' SELECT * '
            || ' FROM ( '
            || ls_sql
            || ' ) SCM '
            || ' PIVOT '
            || ' ( SUM(BUY_CUST_CNT) VCOL1 '
            || ' , SUM(NEW_CUST_CNT) VCOL2 '
            || ' , MAX(SET_DWN_RATE) VCOL3 '
            || ' FOR (SALE_YM ) IN ( '
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
