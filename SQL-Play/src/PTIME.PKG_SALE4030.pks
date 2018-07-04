CREATE OR REPLACE PACKAGE       PKG_SALE4030 AS
    PROCEDURE SP_TAB01 /*일별 시간대별 매출*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- Search 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,                -- FROM 시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- TO 시간
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB02 /*일별 시간대별 매출*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- Search 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,                -- FROM 시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- TO 시간
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_SALE4030;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4030 AS
    PROCEDURE SP_TAB01 /*일별 시간대별 매출 - 매출금액*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- Search 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,                -- FROM 시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- TO 시간
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE4030 일별 시간대별 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-01-24         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_SALE4030
          SYSDATE:         2010-03-08
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    
    
  

    TYPE  rec_ct_hd IS RECORD
        ( SEC_DIV     VARCHAR2(2),
          SEC_DIV_NM  VARCHAR2(12)
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
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    lsTitle1        VARCHAR2(20);

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );



        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------


        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
               ;
    /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT DISTINCT TO_NUMBER(S.SEC_DIV), TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM SALE_JTO  S, ]'
            ||CHR(13)||CHR(10)||Q'[        S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT >= :PSV_GFR_DATE]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT <= :PSV_GTO_DATE]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = :PSV_SEC_FG  ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_DIV  BETWEEN TO_CHAR(TO_NUMBER(NVL(:PSV_FR_TM, '0')), 'FM09') AND TO_CHAR(TO_NUMBER(NVL(:PSV_TO_TM, '23')), 'FM09') ]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        --dbms_output.put_line(ls_sql) ;
        --dbms_output.put_line('---------------------') ;

        BEGIN
            EXECUTE IMMEDIATE  
                ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG, PSV_FR_TM, PSV_TO_TM;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
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


          SELECT  FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'SALE_DT') INTO lsTitle1  from DUAL ;

              V_HD1 := ' SELECT ''' || lsTitle1 || ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') ||  ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''' , '  ;
              V_HD2 := ' SELECT ''' || lsTitle1 || ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL') ||  ''' AS TOT, ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL') || ''' AS TOT1 '  ;

     

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   --V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || qry_hd(i).SEC_DIV   ;
                --V_HD1 := V_HD1 || ' V04  CT' || TO_CHAR(i)  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SEC_DIV_NM  ||  ''' CT' || TO_CHAR(i ) ;
                V_HD2 := V_HD2 || ','''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_NET_SALES_AMT')  ||  ''' CT' || TO_CHAR(i) ;
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD , PSV_LANG_CD)  ||  V_HD2 || ' UNION ALL ' || V_HD1 ;

        /* MAIN SQL */
        ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT SUBSTR(S.SALE_DT,1,4) || '-' || SUBSTR(S.SALE_DT,5,2) || '-' || SUBSTR(S.SALE_DT,7,2) || '(' || FC_GET_WEEK(:PSV_COMP_CD, S.SALE_DT, :PSV_LANG_CD) || ')'  AS SALE_DT, ]'
            ||CHR(13)||CHR(10)||Q'[        SUM (SUM (S.SALE_QTY)) OVER (PARTITION BY S.SALE_DT) AS SALE_QTY_TTL, ]' /* 합계  수량*/
            ||CHR(13)||CHR(10)||Q'[        SUM(SUM(DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT))) OVER (PARTITION BY S.SALE_DT ) AS GRD_AMT_TTL, ]' /*합계 금액*/
            ||CHR(13)||CHR(10)||Q'[        TO_NUMBER(S.SEC_DIV) AS SEC_DIV, ]'    
            ||CHR(13)||CHR(10)||Q'[        SUM(DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT)) AS GRD_AMT ]' /*시간대별 매출액*/
            ||CHR(13)||CHR(10)||Q'[   FROM SALE_JTO  S,]'
            ||CHR(13)||CHR(10)||Q'[        S_STORE   B ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT >= :PSV_GFR_DATE]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT <= :PSV_GTO_DATE]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_FG   = :PSV_SEC_FG  ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_DIV  BETWEEN TO_CHAR(TO_NUMBER(NVL(:PSV_FR_TM, '0')), 'FM09') AND TO_CHAR(TO_NUMBER(NVL(:PSV_TO_TM, '23')), 'FM09') ]'
            ||CHR(13)||CHR(10)||Q'[ GROUP BY S.SALE_DT, TO_NUMBER(S.SEC_DIV) ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        --delete from report_query where pgm_id = PSV_PGM_ID ;
         --insert into REPORT_QUERY ( comp_cd, pgm_id, seq, query_text ) values( PSV_COMP_CD, PSV_PGM_ID, 1, ls_sql );
         --COMMIT;
    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   ' SELECT * '
                ||CHR(13)||CHR(10)||Q'[   FROM (   ]'
                ||CHR(13)||CHR(10)|| ls_sql
                ||CHR(13)||CHR(10)||Q'[   ) S_SALE ]'
                ||CHR(13)||CHR(10)||Q'[   PIVOT    ]'
                ||CHR(13)||CHR(10)||Q'[ (SUM(GRD_AMT) VCOL1 ]';
            
            V_SQL := V_SQL    
                ||CHR(13)||CHR(10)||Q'[ FOR (SEC_DIV ) IN ( ]'
                ||CHR(13)||CHR(10)|| V_CROSSTAB
                ||CHR(13)||CHR(10)||Q'[ ) )                 ]'
                ||CHR(13)||CHR(10)||Q'[ ORDER BY SALE_DT    ]'
              ;

           --dbms_output.put_line( V_SQL) ;
           --dbms_output.put_line('---------------------');
           --dbms_output.put_line( V_HD) ;
           --dbms_output.put_line('---------------------');
           --dbms_output.put_line( V_CROSSTAB) ; 

        OPEN PR_HEADER FOR
          V_HD;
        OPEN PR_RESULT FOR
          V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_FILTER, PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                      PSV_SEC_FG, PSV_FR_TM, PSV_TO_TM;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;
    
    PROCEDURE SP_TAB02 /*일별 시간대별 매출 - 매출수량*/
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- Search 종료일자
        PSV_FR_TM       IN  VARCHAR2 ,                -- FROM 시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- TO 시간
        PSV_SEC_FG      IN  VARCHAR2 ,                -- 시간구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE4030 일별 시간대별 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-01-24         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_SALE4030
          SYSDATE:         2010-03-08
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    
    
  

    TYPE  rec_ct_hd IS RECORD
        ( SEC_DIV     VARCHAR2(2),
          SEC_DIV_NM  VARCHAR2(12)
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
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(20000) ; -- CORSSTAB TITLE
    lsTitle1        VARCHAR2(20);

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
    --           ||  ', '
    --           ||  ls_sql_item  -- S_ITEM
               ;
               
        /* 가로축 데이타 FETCH */
       ls_sql_crosstab_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT DISTINCT TO_NUMBER(S.SEC_DIV), TO_NUMBER(S.SEC_DIV) || FC_GET_WORDPACK(:PSV_COMP_CD,:PSV_LANG_CD, 'HOURS')  AS SEC_DIV_NM ]'
            ||CHR(13)||CHR(10)||Q'[   FROM SALE_JTO  S, ]'
            ||CHR(13)||CHR(10)||Q'[        S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[   WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT >= :PSV_GFR_DATE]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SALE_DT <= :PSV_GTO_DATE]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_FG   = :PSV_SEC_FG  ]'
            ||CHR(13)||CHR(10)||Q'[     AND S.SEC_DIV  BETWEEN TO_CHAR(TO_NUMBER(NVL(:PSV_FR_TM, '0')), 'FM09') AND TO_CHAR(TO_NUMBER(NVL(:PSV_TO_TM, '23')), 'FM09') ]'
            ||CHR(13)||CHR(10)||Q'[     ORDER BY TO_NUMBER(S.SEC_DIV) ]';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        --dbms_output.put_line(ls_sql) ;
        --dbms_output.put_line('---------------------') ;

        BEGIN
            EXECUTE IMMEDIATE  
                ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG, PSV_FR_TM, PSV_TO_TM;

             IF qry_hd.COUNT = 0 OR qry_hd.COUNT IS NULL  THEN
                ls_err_cd  := '4000100' ;
                ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
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


          SELECT  FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'SALE_DT') INTO lsTitle1  from DUAL ;

              V_HD1 := ' SELECT ''' || lsTitle1 || ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY') ||  ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || ''' , '  ;
              V_HD2 := ' SELECT ''' || lsTitle1 || ''' , ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL') ||  ''' AS TOT, ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL') || ''' AS TOT1 '  ;

     

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   --V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || qry_hd(i).SEC_DIV   ;
                --V_HD1 := V_HD1 || ' V04  CT' || TO_CHAR(i)  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).SEC_DIV_NM  ||  ''' CT' || TO_CHAR(i ) ;
                V_HD2 := V_HD2 || ','''   || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALES_QTY')  ||  ''' CT' || TO_CHAR(i) ;
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := PKG_REPORT.f_olap_hd(PSV_COMP_CD , PSV_LANG_CD)  ||  V_HD2 || ' UNION ALL ' || V_HD1 ;

        /* MAIN SQL */
        ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT SUBSTR(S.SALE_DT,1,4) || '-' || SUBSTR(S.SALE_DT,5,2) || '-' || SUBSTR(S.SALE_DT,7,2) || '(' || FC_GET_WEEK(:PSV_COMP_CD, S.SALE_DT, :PSV_LANG_CD) || ')'  AS SALE_DT, ]'
            ||CHR(13)||CHR(10)||Q'[        SUM (SUM (S.SALE_QTY)) OVER (PARTITION BY S.SALE_DT) AS SALE_QTY_TTL, ]' /* 합계  수량*/
            ||CHR(13)||CHR(10)||Q'[        SUM(SUM(DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT))) OVER (PARTITION BY S.SALE_DT ) AS GRD_AMT_TTL, ]' /*합계 금액*/
            ||CHR(13)||CHR(10)||Q'[        TO_NUMBER(S.SEC_DIV) AS SEC_DIV, ]'    
            ||CHR(13)||CHR(10)||Q'[        SUM(S.SALE_QTY)      AS SALE_QTY ]'
            ||CHR(13)||CHR(10)||Q'[   FROM SALE_JTO  S,]'
            ||CHR(13)||CHR(10)||Q'[        S_STORE   B ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.COMP_CD  = :PSV_COMP_CD ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT >= :PSV_GFR_DATE]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT <= :PSV_GTO_DATE]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_FG   = :PSV_SEC_FG  ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_DIV  BETWEEN TO_CHAR(TO_NUMBER(NVL(:PSV_FR_TM, '0')), 'FM09') AND TO_CHAR(TO_NUMBER(NVL(:PSV_TO_TM, '23')), 'FM09') ]'
            ||CHR(13)||CHR(10)||Q'[ GROUP BY S.SALE_DT, TO_NUMBER(S.SEC_DIV) ]';

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        --delete from report_query where pgm_id = PSV_PGM_ID ;
         --insert into REPORT_QUERY ( comp_cd, pgm_id, seq, query_text ) values( PSV_COMP_CD, PSV_PGM_ID, 1, ls_sql );
         --COMMIT;
    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   ' SELECT * '
                ||CHR(13)||CHR(10)||Q'[   FROM (             ]'
                ||CHR(13)||CHR(10)|| ls_sql
                ||CHR(13)||CHR(10)||Q'[   ) S_SALE           ]'
                ||CHR(13)||CHR(10)||Q'[   PIVOT              ]'
                ||CHR(13)||CHR(10)||Q'[ (SUM(SALE_QTY) VCOL1 ]';
            
            V_SQL := V_SQL    
                ||CHR(13)||CHR(10)||Q'[ FOR (SEC_DIV ) IN (  ]'
                ||CHR(13)||CHR(10)|| V_CROSSTAB
                ||CHR(13)||CHR(10)||Q'[ ) )                  ]'
                ||CHR(13)||CHR(10)||Q'[ ORDER BY SALE_DT     ]'
              ;

           --dbms_output.put_line( V_SQL) ;
           --dbms_output.put_line('---------------------');
           --dbms_output.put_line( V_HD) ;
           --dbms_output.put_line('---------------------');
           --dbms_output.put_line( V_CROSSTAB) ; 


        OPEN PR_HEADER FOR
          V_HD;
        OPEN PR_RESULT FOR
          V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, 
                      PSV_SEC_FG, PSV_FR_TM, PSV_TO_TM;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;
END PKG_SALE4030;

/
