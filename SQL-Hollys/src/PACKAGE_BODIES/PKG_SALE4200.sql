--------------------------------------------------------
--  DDL for Package Body PKG_SALE4200
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE4200" AS

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
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      일별 객수/객단가 현황
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
    TYPE  rec_ct_hd IS RECORD
    (
            SALE_DT     VARCHAR2(8)
        ,   SALE_DT_NM  VARCHAR2(20)
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;


        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  M.SALE_DT, SUBSTR(M.SALE_DT, 1, 4) || '-' || SUBSTR(M.SALE_DT, 5, 2) || '-' || SUBSTR(M.SALE_DT, 7, 2)  AS SALE_DT_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG  M   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  M.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.MOBILE_DIV = '62' ]'
        ||CHR(13)||CHR(10)||Q'[    AND  M.USE_YN = 'Y' ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY M.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY M.SALE_DT ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEQ')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC')           ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')        ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SEQ')          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_NM')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_QTY')        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOT_SALE_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DC_AMT')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_SALE_C')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'APPR_AMT')     ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'APPR_CNT')     || Q'[' AS CT]' || TO_CHAR(i*5 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'M_QTY')        || Q'[' AS CT]' || TO_CHAR(i*5 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOT_SALE_AMT') || Q'[' AS CT]' || TO_CHAR(i*5 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'DC_AMT')       || Q'[' AS CT]' || TO_CHAR(i*5 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'M_SALE_C')     || Q'[' AS CT]' || TO_CHAR(i*5 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'APPR_AMT')     || Q'[' AS CT]' || TO_CHAR(i*5);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  ROWNUM                  AS  SEQNO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM              AS  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_TP_NM            AS  STOR_TP_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.TEAM_NM               AS  SC_TEAM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.SV_USER_NM            AS  SC_USER     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_CD               AS  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM               AS  STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.SALE_DT              AS  SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.APPR_CNT) OVER() AS  TOT_APPR_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.M_QTY)    OVER() AS  TOT_M_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.SALE_AMT) OVER() AS  TOT_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.DC_AMT)   OVER() AS  TOT_DC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.M_SALE_C) OVER() AS  TOT_M_SALE_C]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V3.APPR_AMT) OVER() AS  TOT_APPR_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.APPR_CNT             AS  APPR_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.M_QTY                AS  M_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.SALE_AMT             AS  SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.DC_AMT               AS  DC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.M_SALE_C             AS  M_SALE_C    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V3.APPR_AMT             AS  APPR_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    S_STORE    S                            ]'
        ||CHR(13)||CHR(10)||Q'[      , (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V1.COMP_CD          AS  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.BRAND_CD         AS  BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.STOR_CD          AS  STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.SALE_DT          AS  SALE_DT     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.APPR_CNT)    AS  APPR_CNT    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.M_QTY   )    AS  M_QTY       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V2.SALE_AMT)    AS  SALE_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V2.DC_AMT  )    AS  DC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.M_SALE_C)    AS  M_SALE_C    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.APPR_AMT)    AS  APPR_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  M.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.DC_DIV                    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN M.SALE_DIV = '1' THEN 1           ELSE -1                END) AS APPR_CNT]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN M.SALE_DIV = '1' THEN M.M_QTY     ELSE M.M_QTY    * (-1) END) AS M_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN M.SALE_DIV = '1' THEN M.APPR_AMT  ELSE M.APPR_AMT * (-1) END) AS APPR_AMT]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN M.SALE_DIV = '1' THEN M.M_SALE_C  ELSE M.M_SALE_C * (-1) END) AS M_SALE_C]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  MOBILE_LOG  M               ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   M.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.MOBILE_DIV = '62'         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     M.USE_YN     = 'Y'          ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                            ]'
        ||CHR(13)||CHR(10)||Q'[                         M.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  M.DC_DIV                    ]'
        ||CHR(13)||CHR(10)||Q'[                ) V1                                 ]'
        ||CHR(13)||CHR(10)||Q'[              , (                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  D.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.DC_DIV                    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  MAX(D.SALE_AMT)           AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(D.DC_AMT + D.ENR_AMT) AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE     S               ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SALE_DC     D               ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   D.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                            ]'
        ||CHR(13)||CHR(10)||Q'[                         D.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.DC_DIV                    ]'
        ||CHR(13)||CHR(10)||Q'[                ) V2                                 ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   V1.COMP_CD  = V2.COMP_CD            ]'
        ||CHR(13)||CHR(10)||Q'[         AND     V1.SALE_DT  = V2.SALE_DT            ]'
        ||CHR(13)||CHR(10)||Q'[         AND     V1.BRAND_CD = V2.BRAND_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     V1.STOR_CD  = V2.STOR_CD            ]'
        ||CHR(13)||CHR(10)||Q'[         AND     V1.DC_DIV   = V2.DC_DIV             ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                 V1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V1.SALE_DT                          ]'
        ||CHR(13)||CHR(10)||Q'[            ) V3                                     ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   S.COMP_CD    = V3.COMP_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.BRAND_CD   = V3.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S.STOR_CD    = V3.STOR_CD                   ]'
        ;

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
        ||CHR(13)||CHR(10)||Q'[       SUM(APPR_CNT)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(M_QTY)      AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(SALE_AMT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(DC_AMT)     AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(M_SALE_C)   AS VCOL5 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT)   AS VCOL6 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CD, STOR_CD ]';

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
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                        PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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

END PKG_SALE4200;

/
