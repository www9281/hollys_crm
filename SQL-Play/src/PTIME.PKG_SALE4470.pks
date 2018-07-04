CREATE OR REPLACE PACKAGE       PKG_SALE4470 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4470
   --  Description      : 판매 로스현황
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                  -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE4470;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4470 AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                  -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     판매 로스현황
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
            FREE_DIV        VARCHAR2(2)
        ,   FREE_DIV_NM     VARCHAR2(60)
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
    ls_sql_common       VARCHAR2(1000) ;    -- 공통코드SQL
    ERR_HANDLER         EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
        
        ------------------------------------------------------------------------------
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_common := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00460') ;
        -------------------------------------------------------------------------------
   
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.FREE_DIV                             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS FREE_DIV_NM          ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD    SJ                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_common || Q'[ C              ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.FREE_DIV = C.CODE_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.FREE_DIV                          ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(C.SORT_SEQ), SJ.FREE_DIV         ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_PRC')     ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_PRC')     ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).FREE_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).FREE_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).FREE_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SJ.ITEM_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.SALE_PRC)     AS SALE_PRC ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.FREE_DIV                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)    AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)    AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD   SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_common || Q'[ C      ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = C.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.FREE_DIV = C.CODE_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.ITEM_CD, SJ.FREE_DIV      ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)  AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (FREE_DIV) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ITEM_CD ]';
        
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
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;
     
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
    
END PKG_SALE4470;

/
