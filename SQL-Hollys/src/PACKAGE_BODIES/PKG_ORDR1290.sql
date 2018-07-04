--------------------------------------------------------
--  DDL for Package Body PKG_ORDR1290
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ORDR1290" AS

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
        PSV_ORD_FG      IN  VARCHAR2 ,                  -- 주문구분
        PSV_ITEM_TXT    IN  VARCHAR2 ,                  -- 상품코드/명
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN     청구집계현황(본사)
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
            ORD_DT      VARCHAR2(10)
        ,   ORD_DT_NM   VARCHAR2(60)
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  O.ORD_DT                                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(O.ORD_DT, 'YYYYMMDD'), 'MM-DD') AS ORD_DT_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_DTV   O                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I                           ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  O.COMP_CD   = S.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.BRAND_CD  = S.BRAND_CD                ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.STOR_CD   = S.STOR_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.COMP_CD   = I.COMP_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ITEM_CD   = I.ITEM_CD                 ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.COMP_CD   = :PSV_COMP_CD              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_FG    = :PSV_ORD_FG               ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_DIV   = '0'                       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_DT    BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (O.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY O.ORD_DT                             ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY O.ORD_DT                             ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_ORD_FG, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_CD')      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STANDARD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ORD_UNIT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRADE_STOR_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TRADE_STOR_NM')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).ORD_DT || Q'[']';
                V_HD := V_HD || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).ORD_DT_NM  || Q'[' AS CT]' || TO_CHAR(i);
            END;
        END LOOP;

        V_HD :=  V_HD || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  O.ITEM_CD                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.STANDARD)     AS STANDARD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ORD_UNIT_NM)  AS ORD_UNIT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(O.VENDOR_CD)    AS VENDOR_CD]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(V.VENDOR_NM)    AS VENDOR_NM]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SUM(O.ORD_QTY)) OVER (PARTITION BY O.ITEM_CD)   AS TOT_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  O.ORD_DT                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(O.ORD_QTY)      AS ORD_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  ORDER_DTV   O                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM     I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_CD                   AS VENDOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.STOR_NM, S.STOR_NM)   AS VENDOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE   S       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COMMON  C       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  LANG_STORE      ]'
        ||CHR(13)||CHR(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                     )       L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  S.COMP_CD   = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_TP   = C.CODE_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = L.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.BRAND_CD  = L.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.STOR_CD   = L.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  S.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  C.CODE_TP   = '00565'       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  INSTR('V', C.VAL_C1, 1) > 0 ]'
        ||CHR(13)||CHR(10)||Q'[         )       V                   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  O.COMP_CD   = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.BRAND_CD  = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.STOR_CD   = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.COMP_CD   = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ITEM_CD   = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.COMP_CD   = V.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.VENDOR_CD = V.VENDOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_FG    = :PSV_ORD_FG   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_DIV   = '0'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  O.ORD_DT    BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_ITEM_TXT IS NULL OR (O.ITEM_CD LIKE '%'||:PSV_ITEM_TXT||'%' OR I.ITEM_NM LIKE '%'||:PSV_ITEM_TXT||'%'))  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY O.ORD_DT, O.ITEM_CD      ]';

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
        ||CHR(13)||CHR(10)||Q'[       SUM(ORD_QTY)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (ORD_DT) IN    ]'
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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_ORD_FG, PSV_GFR_DATE, PSV_GTO_DATE, PSV_ITEM_TXT, PSV_ITEM_TXT, PSV_ITEM_TXT;

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

END PKG_ORDR1290;

/
