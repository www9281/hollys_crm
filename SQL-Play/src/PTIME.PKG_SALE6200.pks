CREATE OR REPLACE PACKAGE       PKG_SALE6200 AS
/*
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2012-07-24                   1. CREATED THIS PROCEDURE.
   1.1        2012-07-25                   1. UPDATE THIS PROCEDURE.

   NOTES: PKG_SALE6200 매출관리> 재경관련> 점포별 기간별 / 일별 입출금 현황
*/
    -- Procedure Name : 점포별 기간별 입출금 현황
    PROCEDURE SP_SALE6200L0
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

    -- Procedure Name : 점포별 일별 입출금 현황
    PROCEDURE SP_SALE6200L1
    (
    	PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

    -- Procedure Name : 지출내역서
    PROCEDURE SP_SALE6200L2
    (
    	PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE6200;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE6200 AS
/*
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2012-07-24                   1. CREATED THIS PROCEDURE.
   1.1        2012-07-25                   1. UPDATE THIS PROCEDURE.

   NOTES: PKG_SALE6200 매출관리> 재경관련> 점포별 기간별 / 일별 입출금 현황
*/
    -- Procedure Name : 점포별 기간별 입출금 현황
    PROCEDURE SP_SALE6200L0
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    ) IS

    ls_sql          VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_date2    VARCHAR2(1000);
    ls_sql_cm_00770 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role )
    ls_sql_store    VARCHAR2(30000);   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);    -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);    -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);    -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);    -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    lsLine varchar2(3) := '000';

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
        dbms_output.enable( 1000000 );

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        -- 조회기간 처리-----------------------------------------------------------
        ls_sql_date := ' A.PRC_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND A.PRC_DT ' || ls_ex_date1;
        END IF;
        ---------------------------------------------------------------------------

        ls_sql_main := ''
        ||chr(13)||chr(10)|| q'[ SELECT A.BRAND_CD AS BRAND_CD,]'
        ||chr(13)||chr(10)|| q'[        S.BRAND_NM AS BRAND_NM,]'
        ||chr(13)||chr(10)|| q'[        A.STOR_CD  AS STOR_CD,]'
        ||chr(13)||chr(10)|| q'[        S.STOR_NM  AS STOR_NM,]'
        ||chr(13)||chr(10)|| q'[        A.ETC_CD   AS ETC_CD,]'
        ||chr(13)||chr(10)|| q'[        NVL(LT.LANG_NM,B.ETC_NM)   AS ETC_NM,]'
        ||chr(13)||chr(10)|| q'[        SUM(DECODE(A.ETC_DIV, '01', A.ETC_AMT))   AS IN_AMT,]'
        ||chr(13)||chr(10)|| q'[        SUM(DECODE(A.ETC_DIV, '02', A.ETC_AMT))   AS OUT_AMT]'
        ||chr(13)||chr(10)|| q'[   FROM STORE_ETC_AMT A,]'
        ||chr(13)||chr(10)|| q'[        S_STORE S,]'
        ||chr(13)||chr(10)|| q'[        ACC_MST B,]'
        ||chr(13)||chr(10)|| q'[        (                     ]'
        ||chr(13)||chr(10)|| q'[          SELECT  PK_COL, LANG_NM ]'
        ||chr(13)||chr(10)|| q'[            FROM  LANG_TABLE]'
        ||chr(13)||chr(10)||  '            WHERE  COMP_CD  = '''||PSV_COMP_CD||''''
        ||chr(13)||chr(10)|| q'[             AND  TABLE_NM = 'ACC_MST']'
        ||chr(13)||chr(10)|| q'[             AND  COL_NM   = 'ETC_NM' ]'
        ||chr(13)||chr(10)||  '              AND  LANGUAGE_TP = '''||PSV_LANG_CD||''''
        ||chr(13)||chr(10)|| q'[        )    LT                 ]' 
        ||chr(13)||chr(10)|| q'[  WHERE A.COMP_CD  = S.COMP_CD ]'
        ||chr(13)||chr(10)|| q'[    AND A.BRAND_CD = S.BRAND_CD]'
        ||chr(13)||chr(10)|| q'[    AND A.STOR_CD  = S.STOR_CD ]'
        ||chr(13)||chr(10)|| q'[    AND A.COMP_CD  = B.COMP_CD ]'
        ||chr(13)||chr(10)|| q'[    AND A.ETC_CD   = B.ETC_CD  ]'
        ||chr(13)||chr(10)|| q'[    AND B.COMP_CD  = S.COMP_CD ]'
        ||chr(13)||chr(10)|| q'[    AND B.STOR_TP  = S.STOR_TP ]'
        ||chr(13)||chr(10)|| q'[    AND LPAD(B.ETC_CD,3,' ')||LPAD(B.STOR_TP,2,' ') = LT.PK_COL(+) ]'
        ||chr(13)||chr(10)||  '     AND A.COMP_CD = '''|| PSV_COMP_CD ||''''
        ||chr(13)||chr(10)||  '     AND B.COMP_CD = '''|| PSV_COMP_CD ||''''
        ||chr(13)||chr(10)|| q'[    AND ]'|| ls_sql_date
        ||chr(13)||chr(10)|| q'[  GROUP BY A.BRAND_CD, S.BRAND_NM, A.STOR_CD, S.STOR_NM, A.ETC_CD, NVL(LT.LANG_NM,B.ETC_NM)]'
        ||chr(13)||chr(10)|| q'[  ORDER BY A.BRAND_CD, A.STOR_CD, A.ETC_CD]'
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        OPEN PR_RESULT
            FOR ls_sql;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXCEPTION
            WHEN ERR_HANDLER THEN
                PR_RTN_CD  := ls_err_cd;
                PR_RTN_MSG := ls_err_msg ;
               dbms_output.put_line( PR_RTN_MSG ) ;
            WHEN OTHERS THEN
                dbms_output.put_line('line [' || lsLine || '] ' || SQLERRM(SQLCODE) );
                PR_RTN_CD  := '4999999' ;
                PR_RTN_MSG := SQLERRM ;
                dbms_output.put_line( PR_RTN_MSG ) ;
    END;

    -- Procedure Name : 점포별 일별 입출금 현황
      PROCEDURE SP_SALE6200L1
      (
            PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
          PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
          PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
          PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
          PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
          PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
          PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
          PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
          PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
          PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
      ) IS

      ls_sql          VARCHAR2(30000);
      ls_sql_main     VARCHAR2(30000);
      ls_sql_date     VARCHAR2(1000);
      ls_sql_date2    VARCHAR2(1000);
      ls_sql_cm_00770 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role )
      ls_sql_store    VARCHAR2(30000);   -- 점포 WITH  S_STORE
      ls_sql_item     VARCHAR2(20000);   -- 제품 WITH  S_ITEM
      ls_date1        VARCHAR2(2000);    -- 조회일자 (기준)
      ls_date2        VARCHAR2(2000);    -- 조회일자 (대비)
      ls_ex_date1     VARCHAR2(2000);    -- 조회일자 제외 (기준)
      ls_ex_date2     VARCHAR2(2000);    -- 조회일자 제외 (대비)

      ERR_HANDLER     EXCEPTION;

      lsLine varchar2(3) := '000';

      ls_err_cd     VARCHAR2(7) := '0' ;
      ls_err_msg    VARCHAR2(500) ;

      BEGIN
          dbms_output.enable( 1000000 );

          PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                              ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

          ls_sql := ' WITH  '
                 ||  ls_sql_store -- S_STORE
                 ;

          -- 조회기간 처리-----------------------------------------------------------
          ls_sql_date := ' A.PRC_DT ' || ls_date1;
          IF ls_ex_date1 IS NOT NULL THEN
              ls_sql_date := ls_sql_date || ' AND A.PRC_DT ' || ls_ex_date1;
          END IF;
          ---------------------------------------------------------------------------

          ls_sql_main := ''
          ||chr(13)||chr(10)|| q'[ SELECT A.BRAND_CD AS BRAND_CD,]'
          ||chr(13)||chr(10)|| q'[        S.BRAND_NM AS BRAND_NM,]'
          ||chr(13)||chr(10)|| q'[        A.STOR_CD  AS STOR_CD,]'
          ||chr(13)||chr(10)|| q'[        S.STOR_NM  AS STOR_NM,]'
          ||chr(13)||chr(10)|| q'[        A.ETC_CD   AS ETC_CD,]'
          ||chr(13)||chr(10)|| q'[        NVL(LT.LANG_NM,B.ETC_NM)   AS ETC_NM,]'
          ||chr(13)||chr(10)|| q'[        A.PRC_DT   AS PRC_DT,]'
          ||chr(13)||chr(10)|| q'[        SUM(DECODE(A.ETC_DIV, '01', A.ETC_AMT))   AS IN_AMT,]'
          ||chr(13)||chr(10)|| q'[        SUM(DECODE(A.ETC_DIV, '02', A.ETC_AMT))   AS OUT_AMT,]'
          ||chr(13)||chr(10)|| q'[        A.ETC_DESC   AS ETC_DESC]'
          ||chr(13)||chr(10)|| q'[   FROM STORE_ETC_AMT A,]'
          ||chr(13)||chr(10)|| q'[        S_STORE S,]'
          ||chr(13)||chr(10)|| q'[        ACC_MST B,]'
          ||chr(13)||chr(10)|| q'[        (                     ]'
          ||chr(13)||chr(10)|| q'[          SELECT  PK_COL, LANG_NM ]'
          ||chr(13)||chr(10)|| q'[            FROM  LANG_TABLE]'
          ||chr(13)||chr(10)||  '            WHERE  COMP_CD  = '''||PSV_COMP_CD||''''
          ||chr(13)||chr(10)|| q'[             AND  TABLE_NM = 'ACC_MST']'
          ||chr(13)||chr(10)|| q'[             AND  COL_NM   = 'ETC_NM' ]'
          ||chr(13)||chr(10)||  '              AND  LANGUAGE_TP = '''||PSV_LANG_CD||''''
          ||chr(13)||chr(10)|| q'[        )    LT                 ]' 
          ||chr(13)||chr(10)|| q'[  WHERE A.COMP_CD  = S.COMP_CD   ]'
          ||chr(13)||chr(10)|| q'[    AND A.BRAND_CD = S.BRAND_CD  ]'
          ||chr(13)||chr(10)|| q'[    AND A.STOR_CD  = S.STOR_CD   ]'
          ||chr(13)||chr(10)|| q'[    AND A.COMP_CD  = B.COMP_CD   ]'
          ||chr(13)||chr(10)|| q'[    AND A.ETC_CD   = B.ETC_CD    ]'
          ||chr(13)||chr(10)|| q'[    AND B.COMP_CD  = S.COMP_CD   ]'
          ||chr(13)||chr(10)|| q'[    AND B.STOR_TP  = S.STOR_TP   ]'
          ||chr(13)||chr(10)|| q'[    AND LPAD(B.ETC_CD,3,' ')||LPAD(B.STOR_TP,2,' ') = LT.PK_COL(+) ]'
          ||chr(13)||chr(10)||  '     AND A.COMP_CD = '''|| PSV_COMP_CD ||''''
          ||chr(13)||chr(10)||  '     AND B.COMP_CD = '''|| PSV_COMP_CD ||''''
          ||chr(13)||chr(10)|| q'[    AND ]'|| ls_sql_date
          ||chr(13)||chr(10)|| q'[  GROUP BY A.BRAND_CD, S.BRAND_NM, A.STOR_CD, S.STOR_NM, A.ETC_CD, NVL(LT.LANG_NM,B.ETC_NM), A.PRC_DT, A.ETC_DESC]'
          ||chr(13)||chr(10)|| q'[  ORDER BY A.BRAND_CD, A.STOR_CD, A.PRC_DT, A.ETC_CD]'
          ;

          ls_sql := ls_sql || ls_sql_main;
          dbms_output.put_line(ls_sql);
          OPEN PR_RESULT
              FOR ls_sql;

          PR_RTN_CD  := ls_err_cd;
          PR_RTN_MSG := ls_err_msg ;

          EXCEPTION
              WHEN ERR_HANDLER THEN
                  PR_RTN_CD  := ls_err_cd;
                  PR_RTN_MSG := ls_err_msg ;
                 dbms_output.put_line( PR_RTN_MSG ) ;
              WHEN OTHERS THEN
                  dbms_output.put_line('line [' || lsLine || '] ' || SQLERRM(SQLCODE) );
                  PR_RTN_CD  := '4999999' ;
                  PR_RTN_MSG := SQLERRM ;
                  dbms_output.put_line( PR_RTN_MSG ) ;
      END;

-- Procedure Name : 지출내역서
    PROCEDURE SP_SALE6200L2
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    ) IS

    ls_sql          VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_date2    VARCHAR2(1000);
    ls_sql_cm_00770 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role )
    ls_sql_store    VARCHAR2(30000);   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);    -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);    -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);    -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);    -- 조회일자 제외 (대비)

    ERR_HANDLER     EXCEPTION;

    lsLine varchar2(3) := '000';

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN
        dbms_output.enable( 1000000 );

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                            ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ;

        -- 조회기간 처리-----------------------------------------------------------
        ls_sql_date := ' A.PRC_DT ' || ls_date1;
        IF ls_ex_date1 IS NOT NULL THEN
            ls_sql_date := ls_sql_date || ' AND A.PRC_DT ' || ls_ex_date1;
        END IF;
        ---------------------------------------------------------------------------

        ls_sql_main := ''
        ||chr(13)||chr(10)|| q'[ SELECT A.BRAND_CD,]'
        ||chr(13)||chr(10)|| q'[        S.BRAND_NM,]'
        ||chr(13)||chr(10)|| q'[        A.STOR_CD,]'
        ||chr(13)||chr(10)|| q'[        S.STOR_NM,]'
        ||chr(13)||chr(10)|| q'[        SUM(DECODE(A.ETC_DIV, '02', A.ETC_AMT)) AS OUT_AMT,]'
        ||chr(13)||chr(10)|| q'[        '' RECEIPT_YN,]'
        ||chr(13)||chr(10)|| q'[        '' SLIP_NO]'
        ||chr(13)||chr(10)|| q'[   FROM STORE_ETC_AMT A,]'
        ||chr(13)||chr(10)|| q'[        S_STORE S]'
        ||chr(13)||chr(10)|| q'[  WHERE A.COMP_CD  = S.COMP_CD   ]'
        ||chr(13)||chr(10)|| q'[    AND A.BRAND_CD = S.BRAND_CD  ]'
        ||chr(13)||chr(10)|| q'[    AND A.STOR_CD  = S.STOR_CD   ]'
        ||chr(13)||chr(10)|| q'[    AND A.COMP_CD  = ]'|| PSV_COMP_CD
        ||chr(13)||chr(10)|| q'[    AND ]'|| ls_sql_date
        ||chr(13)||chr(10)|| q'[  GROUP BY A.BRAND_CD, S.BRAND_NM, A.STOR_CD, S.STOR_NM]'
        ||chr(13)||chr(10)|| q'[  ORDER BY A.BRAND_CD, A.STOR_CD]'
        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        OPEN PR_RESULT
            FOR ls_sql;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXCEPTION
            WHEN ERR_HANDLER THEN
                PR_RTN_CD  := ls_err_cd;
                PR_RTN_MSG := ls_err_msg ;
               dbms_output.put_line( PR_RTN_MSG ) ;
            WHEN OTHERS THEN
                dbms_output.put_line('line [' || lsLine || '] ' || SQLERRM(SQLCODE) );
                PR_RTN_CD  := '4999999' ;
                PR_RTN_MSG := SQLERRM ;
                dbms_output.put_line( PR_RTN_MSG ) ;
    END;


END PKG_SALE6200;

/
