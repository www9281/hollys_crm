CREATE OR REPLACE PACKAGE      PKG_ORDR1040 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_ORDR1040
   --  Description      : 매장간 이동 현황
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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_ORDR1040;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ORDR1040 AS

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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     매장간 이동 현황
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-03-07         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_MAIN
          SYSDATE:         2016-03-07
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            STOR_CD     VARCHAR2(10)
        ,   STOR_NM     VARCHAR2(60)
    );
    
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd INDEX BY PLS_INTEGER;
    
    qry_hd     tb_ct_hd;
    
    V_CROSSTAB          VARCHAR2(30000);
    V_SQL               VARCHAR2(30000);
    V_HD                VARCHAR2(30000);
    V_CNT               PLS_INTEGER;
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(30000);
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
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ||  ', '
                    ||  ls_sql_item  -- S_ITEM
                    ;
               
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  STOR_CD                                 ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)    AS STOR_NM              ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                                       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  MS.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.OUT_BRAND_CD             ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.OUT_STOR_CD  AS STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MOVE_STORE  MS              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  MS.COMP_CD      = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.ITEM_CD      = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.CONFIRM_DIV IN ('2', '3', '4')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_CONF_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL                           ]'   
        ||CHR(13)||CHR(10)||Q'[             SELECT  MS.COMP_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.IN_BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.IN_STOR_CD  AS STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MOVE_STORE  MS              ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I               ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  MS.COMP_CD      = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.IN_BRAND_CD  = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.IN_STOR_CD   = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.ITEM_CD      = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.CONFIRM_DIV IN ('3', '4')        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_CONF_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         )   B                                   ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY STOR_CD                              ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_CD                              ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'L_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'S_CLASS_CD')   ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STANDARD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOCK_UNIT')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).STOR_CD || Q'[']';
                V_HD := V_HD || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).STOR_NM  || Q'[' AS CT]' || TO_CHAR(i);
            END;
        END LOOP;
    
        V_HD :=  V_HD || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  MAX(L_CLASS_CD)     AS L_CLASS_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(L_CLASS_NM)     AS L_CLASS_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(L_SORT_ORDER)   AS L_SORT_ORDER         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(M_CLASS_CD)     AS M_CLASS_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(M_CLASS_NM)     AS M_CLASS_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(M_SORT_ORDER)   AS M_SORT_ORDER         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S_CLASS_CD)     AS S_CLASS_CD           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S_CLASS_NM)     AS S_CLASS_NM           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S_SORT_ORDER)   AS S_SORT_ORDER         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD                                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ITEM_NM)        AS ITEM_NM              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STANDARD)       AS STANDARD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOCK_UNIT_NM)  AS STOCK_UNIT_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(MV_QTY)) OVER (PARTITION BY COMP_CD, ITEM_CD)    AS TOT_QTY ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD                                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(MV_QTY)         AS MV_QTY               ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (                                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  MS.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.ITEM_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.ITEM_NM       AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.STANDARD      AS STANDARD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.STOCK_UNIT_NM AS STOCK_UNIT_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.OUT_STOR_CD  AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  -1 * (NVL(MS.MV_QTY, 0) * NVL(MS.MV_UNIT_QTY, 0))   AS MV_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  MOVE_STORE  MS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  MS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.CONFIRM_DIV IN ('2', '3', '4')   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_CONF_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL                               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  MS.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_CD                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_NM                    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_SORT_ORDER                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.ITEM_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.ITEM_NM       AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.STANDARD      AS STANDARD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  I.STOCK_UNIT_NM AS STOCK_UNIT_NM]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MS.IN_STOR_CD   AS STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN MS.CONFIRM_DIV IN ('3', '4') THEN NVL(MS.MV_CQTY, 0) * NVL(MS.MV_UNIT_QTY, 0) ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE 0                     ]'
        ||CHR(13)||CHR(10)||Q'[                     END             AS MV_QTY       ]'  
        ||CHR(13)||CHR(10)||Q'[               FROM  MOVE_STORE  MS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  MS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.IN_BRAND_CD  = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.IN_STOR_CD   = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.COMP_CD      = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.CONFIRM_DIV IN ('3', '4')        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  MS.OUT_CONF_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         )                                           ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD     ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(MV_QTY)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (STOR_CD) IN    ]'
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
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
END PKG_ORDR1040;

/
