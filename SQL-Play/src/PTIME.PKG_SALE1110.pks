CREATE OR REPLACE PACKAGE       PKG_SALE1110 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1110
   --  Description      : 판매유형별 매출현황
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드) 
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE1110;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1110 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드) 
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     판매유형별 매출현황
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            CODE_CD     VARCHAR2(10)
        ,   CODE_NM     VARCHAR2(60)
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
    ls_sql_main         VARCHAR2(10000);
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  C.CODE_CD                               ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  COMMON      C                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                                       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CODE_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CODE_NM                     ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  LANG_COMMON                 ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  CODE_TP     = '01695'       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[           ) L                                   ]'
        ||CHR(13)||CHR(10)||Q'[    WHERE  C.COMP_CD   = L.COMP_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[      AND  C.CODE_CD   = L.CODE_CD(+)            ]'
        ||CHR(13)||CHR(10)||Q'[      AND  C.COMP_CD   = :PSV_COMP_CD            ]'
        ||CHR(13)||CHR(10)||Q'[      AND  C.CODE_TP   = '01695'                 ]'
        ||CHR(13)||CHR(10)||Q'[      AND  C.USE_YN    = 'Y'                     ]'
        ||CHR(13)||CHR(10)||Q'[    ORDER  BY C.SORT_SEQ, C.CODE_CD              ]';
    
        ls_sql := ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'QTY')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).CODE_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).CODE_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).CODE_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ITEM_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ITEM_NM)    AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(TOT_QTY)    AS TOT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(TOT_AMT)    AS TOT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_TYPE                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(QTY)        AS QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AMT)        AS AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY) OVER (PARTITION BY SD.COMP_CD, DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD)) AS TOT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', SD.GRD_AMT, 'N', SD.GRD_AMT - SD.VAT_AMT, SD.SALE_AMT)) OVER (PARTITION BY SD.COMP_CD, DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD)) AS TOT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.SALE_TYPE = '1' AND SD.TAKE_DIV = '0' THEN '01'    ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN SD.SALE_TYPE = '1' AND SD.TAKE_DIV = '1' THEN '02'    ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN SD.SALE_TYPE = '2' THEN '03'                          ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE NULL                                                  ]'
        ||CHR(13)||CHR(10)||Q'[                     END         AS SALE_TYPE    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_QTY AS QTY          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DECODE(:PSV_FILTER, 'G', SD.GRD_AMT, 'N', SD.GRD_AMT - SD.VAT_AMT, SD.SALE_AMT) AS AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT    SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_SET_DIV <> '1'      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         )                                       ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY ITEM_CD, SALE_TYPE                   ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(QTY)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(AMT)  AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_TYPE) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ITEM_CD ]';
        
        dbms_output.put_line(V_HD) ;
        dbms_output.put_line(V_SQL) ;
    
        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_CODE_DIV, PSV_CODE_DIV
                      , PSV_FILTER, PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
END PKG_SALE1110;

/
