--------------------------------------------------------
--  DDL for Package Body PKG_SALE1090L0
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1090L0" AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1090L0
   --  Description      : 시간대별 매출분석(30분단위)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    PROCEDURE SP_STORE_TIME /* 점포별 시간대 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2,               -- 회사코드
        PSV_USER        IN  VARCHAR2,               -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2,               -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2,               -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2,               -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2,               -- Search Parameter
        PSV_FILTER      IN  VARCHAR2,               -- Search Filter
        PSV_FR_TM       IN  VARCHAR2 ,              -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,              -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR, -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2,               -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_STORE_TIME        점포별 시간대
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-08-25         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_STORE_TIME
          SYSDATE:         2014-08-25
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        TIME_DIV     VARCHAR2(2),
        TIME_DIV_NM  VARCHAR2(20)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB              VARCHAR2(30000);
    V_SQL                   VARCHAR2(30000);
    V_HD                    VARCHAR2(30000);
    V_HD1                   VARCHAR2(20000);
    V_HD2                   VARCHAR2(20000);
    ls_sql                  VARCHAR2(30000);
    ls_sql_with             VARCHAR2(30000);
    ls_sql_main             VARCHAR2(10000);
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_time             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main    VARCHAR2(20000) ;   -- CORSSTAB TITLE
    ERR_HANDLER             EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        dbms_output.enable( 10000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := ' SH.SALE_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND SH.SALE_DT ' || ls_ex_date1 ;
        END IF;

        -- 조쇠시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;

        V_HD  := '  SELECT     '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BRAND_CD')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BRAND_NM')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_TP')    ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_TP')    ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_CD')    ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'STOR_NM')    ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TIME_TAB')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT')||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')   ||''''
        ||chr(13)||chr(10)||', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT1')  ||''''
        ||chr(13)||chr(10)||' FROM DUAL ' ;


        /* MAIN SQL */
        ls_sql_main :=
          chr(13)||chr(10)||'SELECT  SH.BRAND_CD                        '
        ||chr(13)||chr(10)||'     ,  MAX(S.BRAND_NM)    AS BRAND_NM     '
        ||chr(13)||chr(10)||'     ,  S.STOR_TP                          '
        ||chr(13)||chr(10)||'     ,  MAX(S.STOR_TP_NM)  AS STOR_TP_NM   '
        ||chr(13)||chr(10)||'     ,  SH.STOR_CD                         '
        ||chr(13)||chr(10)||'     ,  MAX(S.STOR_NM)     AS STOR_NM      '
        ||chr(13)||chr(10)||'     ,  C.CODE_CD          AS TIME_DIV     '
        ||chr(13)||chr(10)||'     ,  MAX(C.CODE_NM)     AS TIME_DIV_NM  '
        ||chr(13)||chr(10)||'     ,  SUM(DECODE(SH.SALE_DIV, ''1'', 1, -1))   AS BILL_CNT     '
        ||chr(13)||chr(10)||'     ,  SUM(DECODE(''' || PSV_FILTER || ''', ''G'', (SH.GRD_I_AMT + SH.GRD_O_AMT), ''T'', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT)))  AS GRD_AMT  '
        ||chr(13)||chr(10)||'     ,  SUM(SH.CUST_M_CNT + SH.CUST_F_CNT)   AS CUST_CNT '
        ||chr(13)||chr(10)||'     ,  DECODE(SUM(SH.CUST_M_CNT + SH.CUST_F_CNT), 0, 0, SUM(DECODE(''' || PSV_FILTER || ''', ''G'', (SH.GRD_I_AMT + SH.GRD_O_AMT), ''T'', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT))) / SUM(SH.CUST_M_CNT + SH.CUST_F_CNT))   AS CUST_AMT '
        ||chr(13)||chr(10)||'  FROM  SALE_HD    SH  '
        ||chr(13)||chr(10)||'     ,  S_STORE    S   '
        ||chr(13)||chr(10)||'     ,  (                                      '
        ||chr(13)||chr(10)||'           SELECT  COMP_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_NM                     '
        ||chr(13)||chr(10)||'                ,  VAL_C1                      '
        ||chr(13)||chr(10)||'                ,  VAL_C2                      '
        ||chr(13)||chr(10)||'             FROM  COMMON                      '
        ||chr(13)||chr(10)||'            WHERE  COMP_CD = ' || PSV_COMP_CD
        ||chr(13)||chr(10)||'              AND  CODE_TP = ''01530''         '
        ||chr(13)||chr(10)||'              AND  USE_YN  = ''Y''             '
        ||chr(13)||chr(10)||'        )      C       '
        ||chr(13)||chr(10)||' WHERE  SH.COMP_CD  = S.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SH.BRAND_CD = S.BRAND_CD   '
        ||chr(13)||chr(10)||'   AND  SH.STOR_CD  = S.STOR_CD    '
        ||chr(13)||chr(10)||'   AND  SH.COMP_CD  = C.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2'
        ||chr(13)||chr(10)||'   AND  SH.COMP_CD  = ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)||'   AND  ' ||  ls_sql_date
        ||chr(13)||chr(10)||ls_sql_time
        ||chr(13)||chr(10)||' GROUP  BY SH.BRAND_CD '
        ||chr(13)||chr(10)||'     ,  S.STOR_TP      '
        ||chr(13)||chr(10)||'     ,  SH.STOR_CD     '
        ||chr(13)||chr(10)||'     ,  C.CODE_CD      '
        ||chr(13)||chr(10)||' ORDER  BY SH.BRAND_CD '
        ||chr(13)||chr(10)||'     ,  S.STOR_TP      '
        ||chr(13)||chr(10)||'     ,  SH.STOR_CD     '
        ||chr(13)||chr(10)||'     ,  C.CODE_CD      ';

        V_SQL := ls_sql_with || ls_sql_main;

        dbms_output.put_line( V_HD) ;
        dbms_output.put_line( V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD;
        OPEN PR_RESULT FOR
            V_SQL;

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
    END;

    PROCEDURE SP_ITEM_TIME  /* 상품별 시간대 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2,               -- 회사코드
        PSV_USER        IN  VARCHAR2,               -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2,               -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2,               -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2,               -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2,               -- Search Parameter
        PSV_FILTER      IN  VARCHAR2,               -- Search Filter
        PSV_FR_TM       IN  VARCHAR2 ,              -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,              -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR, -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2,               -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_ITEM_TIME        상품별 시간대
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-08-25         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_ITEM_TIME
          SYSDATE:         2014-08-25
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    ( 
        TIME_DIV     VARCHAR2(2),
        TIME_DIV_NM  VARCHAR2(20)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB              VARCHAR2(30000);
    V_SQL                   VARCHAR2(30000);
    V_HD                    VARCHAR2(30000);
    V_HD1                   VARCHAR2(20000);
    V_HD2                   VARCHAR2(20000);
    ls_sql                  VARCHAR2(30000);
    ls_sql_with             VARCHAR2(30000);
    ls_sql_main             VARCHAR2(10000);
    ls_sql_date             VARCHAR2(1000) ;
    ls_sql_time             VARCHAR2(1000) ;
    ls_sql_store            VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item             VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1                VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2                VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1             VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2             VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main    VARCHAR2(20000) ;   -- CORSSTAB TITLE
    ERR_HANDLER             EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        dbms_output.enable( 10000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        -- 조회기간 처리---------------------------------------------------------------
        ls_sql_date := ' SD.SALE_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND SD.SALE_DT ' || ls_ex_date1 ;
        END IF;

        -- 조쇠시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main :=
          chr(13)||chr(10)||'SELECT  C.CODE_CD       AS TIME_DIV            '
        ||chr(13)||chr(10)||'     ,  MAX(C.CODE_NM)  AS TIME_DIV_NM         '
        ||chr(13)||chr(10)||'  FROM  SALE_DT SD                             '
        ||chr(13)||chr(10)||'     ,  S_STORE S                              '
        ||chr(13)||chr(10)||'     ,  S_ITEM  I                              '
        ||chr(13)||chr(10)||'     ,  (                                      '
        ||chr(13)||chr(10)||'           SELECT  COMP_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_NM                     '
        ||chr(13)||chr(10)||'                ,  VAL_C1                      '
        ||chr(13)||chr(10)||'                ,  VAL_C2                      '
        ||chr(13)||chr(10)||'             FROM  COMMON                      '
        ||chr(13)||chr(10)||'            WHERE  COMP_CD = ' || PSV_COMP_CD
        ||chr(13)||chr(10)||'              AND  CODE_TP = ''01530''         '
        ||chr(13)||chr(10)||'              AND  USE_YN  = ''Y''             '
        ||chr(13)||chr(10)||'        )      C                   '
        ||chr(13)||chr(10)||' WHERE  SD.COMP_CD  = S.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SD.BRAND_CD = S.BRAND_CD   '
        ||chr(13)||chr(10)||'   AND  SD.STOR_CD  = S.STOR_CD    '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = I.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SD.ITEM_CD  = I.ITEM_CD    '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = C.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2'
        ||chr(13)||chr(10)||'   AND  (SD.T_SEQ    = ''0'' OR SD.SUB_ITEM_DIV = ''2'')  '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = ' || PSV_COMP_CD
        ||chr(13)||chr(10)||'   AND  ' ||  ls_sql_date
        ||chr(13)||chr(10)||ls_sql_time 
        ||chr(13)||chr(10)||' GROUP  BY C.CODE_CD               '
        ||chr(13)||chr(10)||' ORDER  BY C.CODE_CD               ';

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        dbms_output.put_line(ls_sql) ;

        --   DELETE FROM REPORT_QUERY WHERE PGM_ID = PSV_PGM_ID;
        --   INSERT INTO REPORT_QUERY( COMP_CD, PGM_ID, SEQ, QUERY_TEXT ) VALUES ( PSV_COMP_CD, PSV_PGM_ID, 1, ls_sql );
        --   COMMIT;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := '  SELECT       '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_CD')
        ||chr(13)||chr(10)||''', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_NM')
        ||chr(13)||chr(10)||''', ';
        V_HD2 := '  SELECT       '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_CD')
        ||chr(13)||chr(10)||''', '''||FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'ITEM_NM')
        ||chr(13)||chr(10)||''', ';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ' ;
                   V_HD2 := V_HD2 || ' , ' ;
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).TIME_DIV  || '''';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).TIME_DIV_NM  || ''' CT' || TO_CHAR(i*2 - 2) || ',' ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).TIME_DIV_NM  || ''' CT' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')         || ''' CT' || TO_CHAR(i*2 - 1 ) || ',' ;
                V_HD2 := V_HD2 || ' ''' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT')|| ''' CT' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM DUAL ' ;
        V_HD2 :=  V_HD2 || ' FROM DUAL ' ;
        V_HD   := V_HD1 || ' UNION ALL ' || V_HD2 ;


        /* MAIN SQL */
        ls_sql_main :=
          chr(13)||chr(10)||'SELECT  /*+ ORDERED */                     '
        ||chr(13)||chr(10)||'        SD.ITEM_CD     '
        ||chr(13)||chr(10)||'     ,  MAX(I.ITEM_NM)     AS ITEM_NM      '
        ||chr(13)||chr(10)||'     ,  C.CODE_CD          AS TIME_DIV     '
        ||chr(13)||chr(10)||'     ,  SUM(SD.SALE_QTY)   AS SALE_QTY     '
        ||chr(13)||chr(10)||'     ,  SUM(DECODE(''' || PSV_FILTER || ''', ''G'', SD.GRD_AMT, ''T'', SD.SALE_AMT, SD.GRD_AMT - SD.VAT_AMT))  AS GRD_AMT  '
        ||chr(13)||chr(10)||'  FROM  SALE_DT    SD  '
        ||chr(13)||chr(10)||'     ,  S_STORE    S   '
        ||chr(13)||chr(10)||'     ,  S_ITEM     I   '
        ||chr(13)||chr(10)||'     ,  (                                      '
        ||chr(13)||chr(10)||'           SELECT  COMP_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_CD                     '
        ||chr(13)||chr(10)||'                ,  CODE_NM                     '
        ||chr(13)||chr(10)||'                ,  VAL_C1                      '
        ||chr(13)||chr(10)||'                ,  VAL_C2                      '
        ||chr(13)||chr(10)||'             FROM  COMMON                      '
        ||chr(13)||chr(10)||'            WHERE  COMP_CD = ' || PSV_COMP_CD
        ||chr(13)||chr(10)||'              AND  CODE_TP = ''01530''         '
        ||chr(13)||chr(10)||'              AND  USE_YN  = ''Y''             '
        ||chr(13)||chr(10)||'        )      C       '
        ||chr(13)||chr(10)||' WHERE  SD.COMP_CD  = S.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SD.BRAND_CD = S.BRAND_CD   '
        ||chr(13)||chr(10)||'   AND  SD.STOR_CD  = S.STOR_CD    '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = I.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SD.ITEM_CD  = I.ITEM_CD    '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = C.COMP_CD    '
        ||chr(13)||chr(10)||'   AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2'
        ||chr(13)||chr(10)||'   AND  (SD.T_SEQ    = ''0'' OR SD.SUB_ITEM_DIV = ''2'')  '
        ||chr(13)||chr(10)||'   AND  SD.COMP_CD  = ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)||'   AND  ' ||  ls_sql_date
        ||chr(13)||chr(10)||ls_sql_time
        ||chr(13)||chr(10)||' GROUP  BY SD.ITEM_CD     '
        ||chr(13)||chr(10)||'     ,  C.CODE_CD      ';

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL :=   
          chr(13)||chr(10)||'SELECT  *  '
        ||chr(13)||chr(10)||'  FROM  (  '
        ||chr(13)||chr(10)||ls_sql
        ||chr(13)||chr(10)||'        ) S'
        ||chr(13)||chr(10)||' PIVOT     '
        ||chr(13)||chr(10)||' (         '
        ||chr(13)||chr(10)||'        SUM(SALE_QTY)   VCOL1 '
        ||chr(13)||chr(10)||'    ,   SUM(GRD_AMT)    VCOL2 '
        ||chr(13)||chr(10)||'    FOR ( TIME_DIV ) IN   '
        ||chr(13)||chr(10)||'    ( '
        ||chr(13)||chr(10)||V_CROSSTAB
        ||chr(13)||chr(10)||'    )  '
        ||chr(13)||chr(10)||' )     '
        ||chr(13)||chr(10)||' ORDER  BY 1, 2';

        dbms_output.put_line( V_HD) ;
        dbms_output.put_line( V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD;
        OPEN PR_RESULT FOR
            V_SQL;

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
    END;

END PKG_SALE1090L0;

/
