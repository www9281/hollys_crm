CREATE OR REPLACE PACKAGE       PKG_SALE4440 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4440
    --  Description      : 중분류 매출현황(전-누계)
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_SALE4440;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4440 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_CODE_DIV    IN  VARCHAR2 ,                -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    중분류 매출현황
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  M_CLASS_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DC_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NET_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  VAT_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(ROUND(DECODE(TOT_GRD_AMT, 0, 0, (GRD_AMT / TOT_GRD_AMT) * 100), 2), '900.00')||'%'  AS PERCENT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(DECODE(TOT_GRD_AMT, 0, 0, (GRD_AMT / TOT_GRD_AMT) * 100), 2)                          AS PERCENT2 ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M_CLASS_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  M_SORT_ORDER]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ITEM_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(GRD_AMT) OVER() AS TOT_GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  DC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  GRD_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NET_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  VAT_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[             FROM   (            ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) AS M_CLASS_CD]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) AS M_CLASS_NM]'
        ||CHR(13)||CHR(10)||Q'[                          ,  MAX(DECODE(:PSV_CODE_DIV, '01', I.M_SORT_ORDER, I.REP_M_SORT_ORDER)) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD) AS ITEM_CD]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM) AS ITEM_NM]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.SALE_QTY)                AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.SALE_AMT)                AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||q'[                       FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                          ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||q'[                          ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[                      WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                        AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                     GROUP  BY              ]'
        ||CHR(13)||CHR(10)||Q'[                             DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_CD, I.REP_M_CLASS_CD) ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.M_CLASS_NM, I.REP_M_CLASS_NM) ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_CD, I.REP_ITEM_CD)       ]'
        ||CHR(13)||CHR(10)||Q'[                          ,  DECODE(:PSV_CODE_DIV, '01', I.ITEM_NM, I.REP_ITEM_NM)       ]'
        ||CHR(13)||CHR(10)||Q'[                    )        ]'
        ||CHR(13)||CHR(10)||Q'[         )       S   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY M_SORT_ORDER, M_CLASS_CD, ITEM_CD  ]';
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_CODE_DIV, PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_CODE_DIV, PSV_CODE_DIV
                       , PSV_CODE_DIV, PSV_CODE_DIV;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
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
    
END PKG_SALE4440;

/
