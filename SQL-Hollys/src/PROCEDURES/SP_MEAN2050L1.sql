--------------------------------------------------------
--  DDL for Procedure SP_MEAN2050L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEAN2050L1" /* 회원 VS 비회원 분석(점포) */
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
   NAME:       SP_MEAN2050L1  회원 VS 비회원 분석
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-07-03         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_MEAN2050L1
      SYSDATE:         2015-07-03
      USERNAME:
      TABLE NAME:
******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
       ( 
        SALE_YM     VARCHAR2(10),
        SALE_YM_NM  VARCHAR2(100)
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
/*
    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ;

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

    ls_sql_with := ' WITH  '
           ||  ls_sql_store; -- S_STORE
    /*       
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
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

    dbms_output.put_line(ls_sql) ;

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
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        WHEN OTHERS THEN
            ls_err_cd := '4999999' ;
            ls_err_msg := SQLERRM ;
            RAISE ERR_HANDLER ;
    END;

    V_HD1 := ' SELECT '        
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_CD')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'BRAND_NM')||''', '   
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'STOR_CD') ||''', '
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'STOR_NM') ||''', '                  
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
          || '        '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD,'DIVISION')||''', '
          ;
    V_HD2 := V_HD1;

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
               V_HD1 := V_HD1 || ' , ' ;
               V_HD2 := V_HD2 || ' , ' ;
            END IF;
            V_CROSSTAB := V_CROSSTAB|| '''' || qry_hd(i).SALE_YM || '''';
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 3) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 2) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4 - 1) || ',' ;
            V_HD1 := V_HD1 || ''''   || qry_hd(i).SALE_YM_NM  || ''' CT' || TO_CHAR(i*4)  ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'MEMBER'   )|| ''' CT' || TO_CHAR(i*4 - 3 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )|| ''' CT' || TO_CHAR(i*4 - 2 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NONMEMBER')|| ''' CT' || TO_CHAR(i*4 - 1 ) || ',' ;
            V_HD2 := V_HD2 || ''''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO'     )||'''  CT' || TO_CHAR(i*4)   ;
        END;
    END LOOP;

    V_HD1 := V_HD1 || ' FROM DUAL ' ;
    V_HD2 := V_HD2 || ' FROM DUAL ' ;
    V_HD  := V_HD1 || ' UNION ALL ' || V_HD2 ;


    /* MAIN SQL */
    ls_sql_main :=                  '   SELECT  JDS.SALE_YM          AS SALE_YM     '
                ||chr(13)||chr(10)||'         , JDS.BRAND_CD     '   
                ||chr(13)||chr(10)||'         , JDS.BRAND_NM     '                   
                ||chr(13)||chr(10)||'         , JDS.STOR_CD      '          
                ||chr(13)||chr(10)||'         , JDS.STOR_NM      '                                  
                ||chr(13)||chr(10)||'         , JDS.COL_ID           AS COL_ID      '   
                ||chr(13)||chr(10)||'         , GET_COMMON_CODE_NM('''||PSV_COMP_CD||''', ''12180'', JDS.COL_ID, '''||PSV_LANG_CD||''') AS COL_ID_NM   '
                ||chr(13)||chr(10)||'         , NVL(MAS.COL_VAL, 0)  AS CST_SALE_VAL '
                ||chr(13)||chr(10)||'         , CASE WHEN  JDS.COL_ID NOT IN(''2'', ''3'') THEN  CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(MAS.COL_VAL, 0) / TOT.COL_VAL * 100,2)  END  END CST_RATE  '
                ||chr(13)||chr(10)||'         , CASE WHEN  JDS.COL_ID = ''2'' AND TOT.COL_VAL = 0 THEN NULL ELSE JDS.COL_VAL END          AS NCST_SALE_VAL'
                ||chr(13)||chr(10)||'         , CASE WHEN  JDS.COL_ID NOT IN(''2'', ''3'') THEN  CASE WHEN TOT.COL_VAL = 0 THEN 0 ELSE ROUND(NVL(JDS.COL_VAL, 0) / TOT.COL_VAL * 100,2) END END NCST_RATE '
                ||chr(13)||chr(10)||'   FROM   (                    '
                ||chr(13)||chr(10)||'           SELECT  *           '
                ||chr(13)||chr(10)||'           FROM   (            '
                ||chr(13)||chr(10)||'                   SELECT  JDS.SALE_YM                                         '
                ||chr(13)||chr(10)||'                         , JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)  AS BILL_CNT    '
                ||chr(13)||chr(10)||'                         , NVL(MSS.CST_CNT, 0)                  AS CST_CNT     '
                ||chr(13)||chr(10)||'                         , CASE WHEN (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)) = 0 THEN 0 '
                ||chr(13)||chr(10)||'                                ELSE ROUND((JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0)) / (JDS.BILL_CNT - NVL(MAS.BILL_CNT, 0)), 0) END AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                         , JDS.SALE_QTY - NVL(MAS.SALE_QTY, 0)  AS SALE_QTY    '
                ||chr(13)||chr(10)||'                         , JDS.SALE_AMT - NVL(MAS.SALE_AMT, 0)  AS SALE_AMT    '
                ||chr(13)||chr(10)||'                         , JDS.DC_AMT   - NVL(MAS.DC_AMT  , 0)  AS DC_AMT      '
                ||chr(13)||chr(10)||'                         , JDS.GRD_AMT  - NVL(MAS.GRD_AMT , 0)  AS GRD_AMT     '
                ||chr(13)||chr(10)||'                         , JDS.BRAND_CD    '
                ||chr(13)||chr(10)||'                         , JDS.BRAND_NM    '                                
                ||chr(13)||chr(10)||'                         , JDS.STOR_CD     '          
                ||chr(13)||chr(10)||'                         , JDS.STOR_NM     '                                                                
                ||chr(13)||chr(10)||'                   FROM   (                                                    '
                ||chr(13)||chr(10)||'                           SELECT  SUBSTR(JDS.SALE_DT, 1, 6)   AS SALE_YM      '
                ||chr(13)||chr(10)||'                                 , SUM(JDS.BILL_CNT)           AS BILL_CNT     '
                ||chr(13)||chr(10)||'                                 , 0                           AS CST_CNT      '
                ||chr(13)||chr(10)||'                                 , 0                           AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                                 , SUM(JDS.SALE_QTY)           AS SALE_QTY     '
                ||chr(13)||chr(10)||'                                 , SUM(JDS.SALE_AMT)           AS SALE_AMT     '
                ||chr(13)||chr(10)||'                                 , SUM(JDS.DC_AMT+JDS.ENR_AMT) AS DC_AMT       '
                ||chr(13)||chr(10)||'                                 , SUM(JDS.GRD_AMT)            AS GRD_AMT      '
                ||chr(13)||chr(10)||'                                 , JDS.BRAND_CD                              '
                ||chr(13)||chr(10)||'                                 , STO.BRAND_NM                              '                
                ||chr(13)||chr(10)||'                                 , JDS.STOR_CD                              '       
                ||chr(13)||chr(10)||'                                 , STO.STOR_NM                              '                                                            
                ||chr(13)||chr(10)||'                           FROM    SALE_JDS   JDS                              '
                ||chr(13)||chr(10)||'                                 , S_STORE    STO                              '
                ||chr(13)||chr(10)||'                           WHERE   STO.COMP_CD  = JDS.COMP_CD                  '
                ||chr(13)||chr(10)||'                           AND     STO.BRAND_CD = JDS.BRAND_CD                 '
                ||chr(13)||chr(10)||'                           AND     STO.STOR_CD  = JDS.STOR_CD                  '
                ||chr(13)||chr(10)||'                           AND     JDS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                           AND     JDS.SALE_DT >= '''||PSV_STR_YM||'''||''01'' '
                ||chr(13)||chr(10)||'                           AND     JDS.SALE_DT <= '''||PSV_END_YM||'''||''31'' '
                --||chr(13)||chr(10)||'                           AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                           GROUP BY                                            '
                ||chr(13)||chr(10)||'                                    SUBSTR(SALE_DT, 1, 6)                      '
                ||chr(13)||chr(10)||'                                  , JDS.BRAND_CD                     '
                ||chr(13)||chr(10)||'                                  , STO.BRAND_NM                     '                                
                ||chr(13)||chr(10)||'                                  , JDS.STOR_CD                      '
                ||chr(13)||chr(10)||'                                  , STO.STOR_NM                      '                                      
                ||chr(13)||chr(10)||'                          ) JDS                                                '        
                ||chr(13)||chr(10)||'                         ,(                                                    '
                ||chr(13)||chr(10)||'                           SELECT  MAS.SALE_YM                                 '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.BILL_CNT)           AS BILL_CNT     '
                ||chr(13)||chr(10)||'                                 , 0                           AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.SALE_QTY)           AS SALE_QTY     '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.SALE_AMT)           AS SALE_AMT     '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.DC_AMT+MAS.ENR_AMT) AS DC_AMT       '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.GRD_AMT)            AS GRD_AMT      '
                ||chr(13)||chr(10)||'                                 , MAS.BRAND_CD                                '
                ||chr(13)||chr(10)||'                                 , MAS.STOR_CD                                 '                       
                ||chr(13)||chr(10)||'                           FROM    C_CUST_MAS MAS                              '
                ||chr(13)||chr(10)||'                                 , S_STORE    STO                              '
                ||chr(13)||chr(10)||'                           WHERE   STO.COMP_CD  = MAS.COMP_CD                  '
                ||chr(13)||chr(10)||'                           AND     STO.BRAND_CD = MAS.BRAND_CD                 '
                ||chr(13)||chr(10)||'                           AND     STO.STOR_CD  = MAS.STOR_CD                  '
                ||chr(13)||chr(10)||'                           AND     MAS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                           AND     MAS.SALE_YM >= '''||PSV_STR_YM||'''         '
                ||chr(13)||chr(10)||'                           AND     MAS.SALE_YM <= '''||PSV_END_YM||'''         '
                --||chr(13)||chr(10)||'                           AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                           GROUP BY                                            '
                ||chr(13)||chr(10)||'                                   SALE_YM                                     '
                ||chr(13)||chr(10)||'                                 , MAS.BRAND_CD                                '
                ||chr(13)||chr(10)||'                                 , MAS.STOR_CD                                 '
                ||chr(13)||chr(10)||'                          ) MAS                                                '
                ||chr(13)||chr(10)||'                         ,(                                                    ' 
                ||chr(13)||chr(10)||'                           SELECT  SALE_YM                                     '
                ||chr(13)||chr(10)||'                                 , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CNT '
                ||chr(13)||chr(10)||'                                 , BRAND_CD                                    '
                ||chr(13)||chr(10)||'                                 , STOR_CD                                     '
                ||chr(13)||chr(10)||'                           FROM   (                                            '
                ||chr(13)||chr(10)||'                                   SELECT  MSS.SALE_YM                         '
                ||chr(13)||chr(10)||'                                         , MSS.BRAND_CD                            '
                ||chr(13)||chr(10)||'                                         , MSS.STOR_CD                             '
                ||chr(13)||chr(10)||'                                         , MSS.CUST_ID                         '
                ||chr(13)||chr(10)||'                                         , ROW_NUMBER() OVER(PARTITION BY MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM '      
                ||chr(13)||chr(10)||'                                   FROM    C_CUST_MSS MSS                      '
                ||chr(13)||chr(10)||'                                         , S_STORE    STO                      '
                ||chr(13)||chr(10)||'                                   WHERE   STO.COMP_CD  = MSS.COMP_CD                  '
                ||chr(13)||chr(10)||'                                   AND     STO.BRAND_CD = MSS.BRAND_CD                 '
                ||chr(13)||chr(10)||'                                   AND     STO.STOR_CD  = MSS.STOR_CD                  '
                ||chr(13)||chr(10)||'                                   AND     MSS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                                   AND     MSS.SALE_YM >= '''||PSV_STR_YM||''' '
                ||chr(13)||chr(10)||'                                   AND     MSS.SALE_YM <= '''||PSV_END_YM||''' '
                --||chr(13)||chr(10)||'                                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                                  )                                            '         
                ||chr(13)||chr(10)||'                           GROUP BY                                            '
                ||chr(13)||chr(10)||'                                   SALE_YM                                     '
                ||chr(13)||chr(10)||'                                 , BRAND_CD                                    '
                ||chr(13)||chr(10)||'                                 , STOR_CD                                     '
                ||chr(13)||chr(10)||'                          ) MSS                                                '
                ||chr(13)||chr(10)||'                   WHERE    JDS.SALE_YM  = MAS.SALE_YM(+)                      '
                ||chr(13)||chr(10)||'                   AND      JDS.BRAND_CD = MAS.BRAND_CD(+)                     '
                ||chr(13)||chr(10)||'                   AND      JDS.STOR_CD  = MAS.STOR_CD(+)                      '
                ||chr(13)||chr(10)||'                   AND      JDS.BRAND_CD = MSS.BRAND_CD(+)                     '
                ||chr(13)||chr(10)||'                   AND      JDS.SALE_YM  = MSS.SALE_YM(+)                      '
                ||chr(13)||chr(10)||'                   AND      JDS.STOR_CD  = MSS.STOR_CD(+)                      '
                ||chr(13)||chr(10)||'                  ) JDS        '  
                ||chr(13)||chr(10)||'                   UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7))  '
                ||chr(13)||chr(10)||'          ) JDS                '     
                ||chr(13)||chr(10)||'         ,(                    '
                ||chr(13)||chr(10)||'           SELECT  *           '
                ||chr(13)||chr(10)||'           FROM   (            '
                ||chr(13)||chr(10)||'                   SELECT  SALE_YM                                             '                                 
                ||chr(13)||chr(10)||'                         , SUM(BILL_CNT    )            AS BILL_CNT            '
                ||chr(13)||chr(10)||'                         , SUM(CST_CNT     )            AS CST_CNT             '
                ||chr(13)||chr(10)||'                         , SUM(BILL_CST_AMT)            AS BILL_CST_AMT        '
                ||chr(13)||chr(10)||'                         , SUM(SALE_QTY    )            AS SALE_QTY            '
                ||chr(13)||chr(10)||'                         , SUM(SALE_AMT    )            AS SALE_AMT            '
                ||chr(13)||chr(10)||'                         , SUM(DC_AMT      )            AS DC_AMT              '
                ||chr(13)||chr(10)||'                         , SUM(GRD_AMT     )            AS GRD_AMT             '
                ||chr(13)||chr(10)||'                         , BRAND_CD        '         
                ||chr(13)||chr(10)||'                         , STOR_CD         '                          
                ||chr(13)||chr(10)||'                   FROM   (                                                    '
                ||chr(13)||chr(10)||'                           SELECT  MAS.SALE_YM                                 '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.BILL_CNT)               AS BILL_CNT '
                ||chr(13)||chr(10)||'                                 , 0                               AS CST_CNT  ' 
                ||chr(13)||chr(10)||'                                 , CASE WHEN SUM(MAS.BILL_CNT) = 0 THEN 0 ELSE ROUND(SUM(MAS.GRD_AMT) / SUM(MAS.BILL_CNT), 0) END AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.SALE_QTY)               AS SALE_QTY '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.SALE_AMT)               AS SALE_AMT '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.DC_AMT + MAS.ENR_AMT)   AS DC_AMT   '
                ||chr(13)||chr(10)||'                                 , SUM(MAS.GRD_AMT)                AS GRD_AMT  '
                ||chr(13)||chr(10)||'                                 , MAS.BRAND_CD                                '         
                ||chr(13)||chr(10)||'                                 , MAS.STOR_CD                                 '
                ||chr(13)||chr(10)||'                           FROM    C_CUST_MAS MAS                              '
                ||chr(13)||chr(10)||'                                 , S_STORE    STO                              '
                ||chr(13)||chr(10)||'                           WHERE   STO.COMP_CD  = MAS.COMP_CD                  '
                ||chr(13)||chr(10)||'                           AND     STO.BRAND_CD = MAS.BRAND_CD                 '
                ||chr(13)||chr(10)||'                           AND     STO.STOR_CD  = MAS.STOR_CD                  '
                ||chr(13)||chr(10)||'                           AND     MAS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                           AND     MAS.SALE_YM >= '''||PSV_STR_YM||'''         '
                ||chr(13)||chr(10)||'                           AND     MAS.SALE_YM <= '''||PSV_END_YM||'''         '
                --||chr(13)||chr(10)||'                           AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                           GROUP BY                                            '
                ||chr(13)||chr(10)||'                                   MAS.SALE_YM                                 '
                ||chr(13)||chr(10)||'                                 , MAS.BRAND_CD                                '         
                ||chr(13)||chr(10)||'                                 , MAS.STOR_CD                                 '
                ||chr(13)||chr(10)||'                           UNION ALL                                           '
                ||chr(13)||chr(10)||'                           SELECT  SALE_YM                                     '
                ||chr(13)||chr(10)||'                                 , 0                               AS BILL_CNT '  
                ||chr(13)||chr(10)||'                                 , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) AS CST_CNT   '
                ||chr(13)||chr(10)||'                                 , 0                               AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                                 , 0                               AS SALE_QTY '
                ||chr(13)||chr(10)||'                                 , 0                               AS SALE_AMT '
                ||chr(13)||chr(10)||'                                 , 0                               AS DC_AMT   '
                ||chr(13)||chr(10)||'                                 , 0                               AS GRD_AMT  '
                ||chr(13)||chr(10)||'                                 , BRAND_CD                                    '         
                ||chr(13)||chr(10)||'                                 , STOR_CD                                     '
                ||chr(13)||chr(10)||'                           FROM   (                                            '
                ||chr(13)||chr(10)||'                                   SELECT  MSS.SALE_YM                         '
                ||chr(13)||chr(10)||'                                         , MSS.CUST_ID                         '
                ||chr(13)||chr(10)||'                                         , ROW_NUMBER() OVER(PARTITION BY MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM '
                ||chr(13)||chr(10)||'                                         , MSS.BRAND_CD       '         
                ||chr(13)||chr(10)||'                                         , MSS.STOR_CD      '                          
                ||chr(13)||chr(10)||'                                   FROM    C_CUST_MSS MSS                      '
                ||chr(13)||chr(10)||'                                         , S_STORE    STO                      '        
                ||chr(13)||chr(10)||'                                   WHERE   STO.COMP_CD  = MSS.COMP_CD                  '
                ||chr(13)||chr(10)||'                                   AND     STO.BRAND_CD = MSS.BRAND_CD                 '
                ||chr(13)||chr(10)||'                                   AND     STO.STOR_CD  = MSS.STOR_CD                  '
                ||chr(13)||chr(10)||'                                   AND     MSS.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                                   AND     MSS.SALE_YM >= '''||PSV_STR_YM||''' '
                ||chr(13)||chr(10)||'                                   AND     MSS.SALE_YM <= '''||PSV_END_YM||''' '
                --||chr(13)||chr(10)||'                                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                                  )                                            '
                ||chr(13)||chr(10)||'                           GROUP BY                                            '
                ||chr(13)||chr(10)||'                                   SALE_YM                                     '
                ||chr(13)||chr(10)||'                                 , BRAND_CD                                '         
                ||chr(13)||chr(10)||'                                 , STOR_CD                                 '
                ||chr(13)||chr(10)||'                  )                                                            '
                ||chr(13)||chr(10)||'                   GROUP BY                                                    '
                ||chr(13)||chr(10)||'                           SALE_YM                                                    '
                ||chr(13)||chr(10)||'                         , BRAND_CD                                '         
                ||chr(13)||chr(10)||'                         , STOR_CD                                 '
                ||chr(13)||chr(10)||'              ) MAS                                                '
                ||chr(13)||chr(10)||'           UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7))  '
                ||chr(13)||chr(10)||'          ) MAS                            '
                ||chr(13)||chr(10)||'         ,(                    '
                ||chr(13)||chr(10)||'           SELECT  *           '
                ||chr(13)||chr(10)||'           FROM   (            '
                ||chr(13)||chr(10)||'                   SELECT  SUBSTR(TOT.SALE_DT, 1, 6)       AS SALE_YM      '
                ||chr(13)||chr(10)||'                         , SUM(TOT.BILL_CNT)               AS BILL_CNT     '
                ||chr(13)||chr(10)||'                         , 0                               AS CST_CNT     '
                ||chr(13)||chr(10)||'                         , CASE WHEN SUM(TOT.BILL_CNT) = 0 THEN 0 ELSE ROUND(SUM(TOT.GRD_AMT) / SUM(TOT.BILL_CNT), 0) END AS BILL_CST_AMT '
                ||chr(13)||chr(10)||'                         , SUM(TOT.SALE_QTY)               AS SALE_QTY     '
                ||chr(13)||chr(10)||'                         , SUM(TOT.SALE_AMT)               AS SALE_AMT     '
                ||chr(13)||chr(10)||'                         , SUM(TOT.DC_AMT + TOT.ENR_AMT)   AS DC_AMT       '
                ||chr(13)||chr(10)||'                         , SUM(TOT.GRD_AMT)                AS GRD_AMT      '
                ||chr(13)||chr(10)||'                         , TOT.BRAND_CD '                
                ||chr(13)||chr(10)||'                         , TOT.STOR_CD      '                
                ||chr(13)||chr(10)||'                   FROM    SALE_JDS   TOT                                  '
                ||chr(13)||chr(10)||'                         , S_STORE    STO                                  '
                ||chr(13)||chr(10)||'                   WHERE   STO.COMP_CD  = TOT.COMP_CD                  '
                ||chr(13)||chr(10)||'                   AND     STO.BRAND_CD = TOT.BRAND_CD                 '
                ||chr(13)||chr(10)||'                   AND     STO.STOR_CD  = TOT.STOR_CD                  '
                ||chr(13)||chr(10)||'                   AND     TOT.COMP_CD  = '''||PSV_COMP_CD||''''
                ||chr(13)||chr(10)||'                   AND     TOT.SALE_DT >= '''||PSV_STR_YM||'''||''01'' '
                ||chr(13)||chr(10)||'                   AND     TOT.SALE_DT <= '''||PSV_END_YM||'''||''31'' '
                --||chr(13)||chr(10)||'                   AND    ('''|| PSV_FILTER ||''' IS NULL OR STO.STOR_GRP1 = '''|| PSV_FILTER ||''') '
                ||chr(13)||chr(10)||'                   GROUP BY                                                '
                ||chr(13)||chr(10)||'                           SUBSTR(TOT.SALE_DT, 1, 6)                       '
                ||chr(13)||chr(10)||'                         , TOT.BRAND_CD                                    '       
                ||chr(13)||chr(10)||'                         , TOT.STOR_CD                                     '     
                ||chr(13)||chr(10)||'                  ) TOT                                                    '
                ||chr(13)||chr(10)||'           UNPIVOT INCLUDE NULLS (COL_VAL FOR COL_ID IN (BILL_CNT AS 1, CST_CNT AS 2, BILL_CST_AMT AS 3, SALE_QTY AS 4, SALE_AMT AS 5, DC_AMT AS 6, GRD_AMT AS 7))  '
                ||chr(13)||chr(10)||'          ) TOT                            '
                ||chr(13)||chr(10)||'   WHERE  JDS.SALE_YM  = TOT.SALE_YM       '
                ||chr(13)||chr(10)||'   AND    JDS.BRAND_CD = TOT.BRAND_CD      '      
                ||chr(13)||chr(10)||'   AND    JDS.STOR_CD  = TOT.STOR_CD       '                                
                ||chr(13)||chr(10)||'   AND    JDS.COL_ID   = TOT.COL_ID        '            
                ||chr(13)||chr(10)||'   AND    JDS.SALE_YM  = MAS.SALE_YM (+)   '
                ||chr(13)||chr(10)||'   AND    JDS.BRAND_CD = MAS.BRAND_CD(+)   '                
                ||chr(13)||chr(10)||'   AND    JDS.STOR_CD  = MAS.STOR_CD (+)   '                
                ||chr(13)||chr(10)||'   AND    JDS.COL_ID   = MAS.COL_ID  (+)   '
        ;

    V_CNT := qry_hd.LAST;

    ls_sql := ls_sql_with || ls_sql_main;

/* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=   ' SELECT *   '
            || ' FROM (     '
            || ls_sql
            || ' ) SCM      '
            || ' PIVOT      '
            || ' (          '
            || '    SUM(CST_SALE_VAL )  VCOL1 '
            || ' ,  SUM(CST_RATE     )  VCOL2 '
            || ' ,  SUM(NCST_SALE_VAL)  VCOL3 '
            || ' ,  MAX(NCST_RATE    )  VCOL4 '
            || ' FOR (SALE_YM ) IN   ( '
            || V_CROSSTAB
            || ' ) ) '
            || 'ORDER BY 1,2 ASC';

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
