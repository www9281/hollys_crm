CREATE OR REPLACE PACKAGE       PKG_SALE4710 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4710
   --  Description      : 월별 TREND 매출현황(상품)
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01  /* 대분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB02  /* 중분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );

    PROCEDURE SP_TAB03  /* 소분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );


    PROCEDURE SP_TAB04  /* 상품 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE4710;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4710 AS

    PROCEDURE SP_TAB01  /* 대분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB01     대분류 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB01
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_YM     VARCHAR2(6)
        ,   SALE_YM_NM  VARCHAR2(20)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(20000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_YM, SUBSTR(SJ.SALE_YM,1, 4) || '-' || SUBSTR(SJ.SALE_YM, 5, 2)  AS SALE_YM_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_YM ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_YM || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_QTY')     || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DC_AMT')       || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'GRD_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VAT_AMT')      || Q'[' AS CT]' || TO_CHAR(i*6);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT + SJ.ENR_AMT)        AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY              ]'
        ||CHR(13)||CHR(10)||Q'[         DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]';
    
        V_CNT := qry_hd.LAST;
    
        ls_sql := ls_sql_with || ls_sql_main;
        
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DC_AMT)     AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(NET_AMT)    AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(VAT_AMT)    AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_YM) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY L_SORT_ORDER, L_CLASS_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM
                      , PSV_CODE_DIV,PSV_CODE_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
        
    PROCEDURE SP_TAB02  /* 중분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC) 
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB02     중분류 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB02
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_YM     VARCHAR2(6)
        ,   SALE_YM_NM  VARCHAR2(20)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(20000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_YM, SUBSTR(SJ.SALE_YM,1, 4) || '-' || SUBSTR(SJ.SALE_YM, 5, 2)  AS SALE_YM_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_YM ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_YM || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_QTY')     || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DC_AMT')       || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'GRD_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VAT_AMT')      || Q'[' AS CT]' || TO_CHAR(i*6);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT + SJ.ENR_AMT)        AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY              ]'
        ||CHR(13)||CHR(10)||Q'[         DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]';
    
        V_CNT := qry_hd.LAST;
    
        ls_sql := ls_sql_with || ls_sql_main;
        
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DC_AMT)     AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(NET_AMT)    AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(VAT_AMT)    AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_YM) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY L_SORT_ORDER, L_CLASS_CD, M_SORT_ORDER, M_CLASS_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
     
    PROCEDURE SP_TAB03  /* 소분류 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC)
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드) 
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB03     소분류 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB03
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_YM     VARCHAR2(6)
        ,   SALE_YM_NM  VARCHAR2(20)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(20000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_YM, SUBSTR(SJ.SALE_YM,1, 4) || '-' || SUBSTR(SJ.SALE_YM, 5, 2)  AS SALE_YM_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_YM ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_YM || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_QTY')     || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DC_AMT')       || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'GRD_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VAT_AMT')      || Q'[' AS CT]' || TO_CHAR(i*6);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT + SJ.ENR_AMT)        AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY              ]'
        ||CHR(13)||CHR(10)||Q'[         DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]';
    
        V_CNT := qry_hd.LAST;
    
        ls_sql := ls_sql_with || ls_sql_main;
        
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DC_AMT)     AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(NET_AMT)    AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(VAT_AMT)    AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_YM) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY L_SORT_ORDER, L_CLASS_CD, M_SORT_ORDER, M_CLASS_CD, S_SORT_ORDER, S_CLASS_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
     
     
    PROCEDURE SP_TAB04  /* 상품 매출 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_YM      IN  VARCHAR2 ,                  -- 조회 시작년월
        PSV_GTO_YM      IN  VARCHAR2 ,                  -- 조회 종료년월
        PSV_ORDER_BY    IN  VARCHAR2 ,                  -- 일자 정렬(ASC,DESC)
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드) 
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB04     상품 매출
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB04
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_YM     VARCHAR2(6)
        ,   SALE_YM_NM  VARCHAR2(20)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_HD1               VARCHAR2(20000);
    V_HD2               VARCHAR2(20000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(20000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.SALE_YM, SUBSTR(SJ.SALE_YM,1, 4) || '-' || SUBSTR(SJ.SALE_YM, 5, 2)  AS SALE_YM_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.SALE_YM ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.SALE_YM ]' || PSV_ORDER_BY;
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_NM')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_YM || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_YM_NM || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'SALE_QTY')     || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DC_AMT')       || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'GRD_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NET_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'VAT_AMT')      || Q'[' AS CT]' || TO_CHAR(i*6);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) AS L_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) AS L_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.L_SORT_ORDER, I.REP_L_SORT_ORDER)) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) AS S_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) AS S_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.S_SORT_ORDER, I.REP_S_SORT_ORDER)) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT + SJ.ENR_AMT)        AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JMM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_YM  BETWEEN :PSV_GFR_YM AND :PSV_GTO_YM ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY              ]'
        ||CHR(13)||CHR(10)||Q'[         DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_CD, I.REP_L_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.L_CLASS_NM, I.REP_L_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_CD, I.REP_S_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.S_CLASS_NM, I.REP_S_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_YM      ]';
    
        V_CNT := qry_hd.LAST;
    
        ls_sql := ls_sql_with || ls_sql_main;
        
        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  *   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DC_AMT)     AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(NET_AMT)    AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(VAT_AMT)    AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_YM) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY L_SORT_ORDER, L_CLASS_CD, M_SORT_ORDER, M_CLASS_CD, S_SORT_ORDER, S_CLASS_CD, ITEM_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_COMP_CD, PSV_GFR_YM, PSV_GTO_YM
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV;
     
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE4710;

/
