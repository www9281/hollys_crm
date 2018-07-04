--------------------------------------------------------
--  DDL for Package Body PKG_STCK1060
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_STCK1060" AS

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
       NAME:       SP_MAIN     메뉴손실현황
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2017-11-08         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_MAIN
          SYSDATE:         2017-11-08
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            CODE_CD     VARCHAR2(2)
        ,   CODE_NM     VARCHAR2(100)
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
    ls_sql_cm_00460     VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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


        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00460 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00460') ;
        -------------------------------------------------------------------------------

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SD.FREE_DIV     AS CODE_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS CODE_NM      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDD    SD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_JDS    SJ                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ]' || ls_sql_cm_00460 || Q'[ C  ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = SJ.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT  = SJ.SALE_DT        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = SJ.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = SJ.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = C.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.FREE_DIV = C.CODE_CD         ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SD.FREE_DIV                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(C.SORT_SEQ), SD.FREE_DIV ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_SALE_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'GRD_SALE_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'RATO')         ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).CODE_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).CODE_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).CODE_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RATO') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  BRAND_NM        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_TP_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SV_USER_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GRD_AMT         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TOT_FREE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN GRD_AMT = 0 THEN 0 ELSE ROUND(TOT_FREE_AMT/GRD_AMT*100, 2) END    AS TOT_FREE_RT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FREE_DIV        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FREE_AMT        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN GRD_AMT = 0 THEN 0 ELSE ROUND(FREE_AMT/GRD_AMT*100, 2) END        AS FREE_RT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_TP_NM)   AS STOR_TP_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.SV_USER_NM)   AS SV_USER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.FREE_DIV                         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)     AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SUM(SD.SALE_AMT)) OVER (PARTITION BY SD.COMP_CD, SD.BRAND_CD, SD.STOR_CD)  AS TOT_FREE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_AMT)    AS FREE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDD    SD                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_JDS    SJ                  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I                   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00460 || Q'[ C  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD  = SJ.COMP_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT  = SJ.SALE_DT        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD = SJ.BRAND_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD  = SJ.STOR_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = I.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD  = I.ITEM_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = C.COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.FREE_DIV = C.CODE_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.COMP_CD, SD.BRAND_CD, SD.STOR_CD, SD.FREE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[         )       ]';

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
        ||CHR(13)||CHR(10)||Q'[       SUM(FREE_AMT)  AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , MAX(FREE_RT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (FREE_DIV) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY STOR_CD ]';

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
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD
                     , PSV_COMP_CD , PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_STCK1060;

/
