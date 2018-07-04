--------------------------------------------------------
--  DDL for Package Body PKG_SALE1430
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1430" AS

    PROCEDURE SP_TAB01
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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_MAIN       매출관리 > 프로모션분석  > POSA 기프트카드 집계현황(층전)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-14         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2017-12-14
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

    V_CROSSTAB       VARCHAR2(30000);
    V_SQL            VARCHAR2(30000);
    V_HD             VARCHAR2(30000);
    V_HD1            VARCHAR2(20000);
    V_HD2            VARCHAR2(20000);
    V_HD3            VARCHAR2(20000);
    V_CNT            PLS_INTEGER;
    ls_sql           VARCHAR2(30000);
    ls_sql_with      VARCHAR2(30000);
    ls_sql_main      VARCHAR2(30000);
    ls_sql_date      VARCHAR2(1000);
    ls_sql_store     VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item      VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1         VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2         VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1      VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2      VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main  VARCHAR2(30000);    -- CORSSTAB TITLE
    ERR_HANDLER      EXCEPTION;
    ls_err_cd        VARCHAR2(7) := '0';
    ls_err_msg       VARCHAR2(500);

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                    ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT ML.SALE_DT, SUBSTR(ML.SALE_DT,1,4) || '-' || SUBSTR(ML.SALE_DT,5,2) || '-' || SUBSTR(ML.SALE_DT,7,2) || '(' || FC_GET_WEEK(ML.COMP_CD, ML.SALE_DT, ']' || PSV_LANG_CD || q'[' ) || ')'  SALE_DT_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG    ML             ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.MOBILE_DIV IN ('93', '94')]'
        ||CHR(13)||CHR(10)||Q'[    AND  GIFT_DIV <> '0'              ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.RSV_DIV IN ('8','9')      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.SALE_DT ]'
        ;

        ls_sql :=  ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ;

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NORMAL_SAV')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NORMAL_SAV')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'YUN_SAV')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'YUN_SAV')       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NORMAL_RCV_AMT')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'NORMAL_RCV_AMT')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'RFND_RCV_AMT')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'RFND_RCV_AMT')  ]'
        ;

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 7);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 6);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*8);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL_SAV')     || Q'[' AS CT]' || TO_CHAR(i*8 - 7);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL_SAV')     || Q'[' AS CT]' || TO_CHAR(i*8 - 6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'YUN_SAV')        || Q'[' AS CT]' || TO_CHAR(i*8 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'YUN_SAV')        || Q'[' AS CT]' || TO_CHAR(i*8 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL_RCV_AMT') || Q'[' AS CT]' || TO_CHAR(i*8 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'NORMAL_RCV_AMT') || Q'[' AS CT]' || TO_CHAR(i*8 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RFND_RCV_AMT')   || Q'[' AS CT]' || TO_CHAR(i*8 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'RFND_RCV_AMT')   || Q'[' AS CT]' || TO_CHAR(i*8);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 7);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 6);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 5);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 4);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')            || Q'[' AS CT]' || TO_CHAR(i*8 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')            || Q'[' AS CT]' || TO_CHAR(i*8);

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        dbms_output.put_line(V_HD) ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[     SELECT                   ]'
        ||CHR(13)||CHR(10)||Q'[              S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[           ,  ML.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           ,  ML.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT1)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT1 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT1)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT1 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT2)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT2 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT2)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT2 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT3)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT3 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT3)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT3 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT4)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT4 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT4)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT4 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT1) AS APPR_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT1) AS APPR_AMT1  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT2) AS APPR_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT2) AS APPR_AMT2  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT3) AS APPR_CNT3  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT3) AS APPR_AMT3  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT4) AS APPR_CNT4  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT4) AS APPR_AMT4  ]'
        ||CHR(13)||CHR(10)||Q'[     FROM(                                 ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT                           ]'
        ||CHR(13)||CHR(10)||Q'[                  ML.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.SALE_DT               ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY = 1 THEN COUNT(APPR_AMT) ELSE 0   ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT1                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY > 1 THEN COUNT(APPR_AMT) ELSE 0   ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT2                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '8' AND SALE_DIV = '2' THEN COUNT(APPR_AMT )  ELSE 0                  ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT3                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '2' THEN COUNT(APPR_AMT ) ELSE 0                   ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT4                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY = 1 THEN SUM(APPR_AMT) ELSE 0     ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT1                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY > 1 THEN SUM(APPR_AMT) ELSE 0     ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT2                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '8' AND SALE_DIV = '2' THEN SUM( APPR_AMT ) * -1  ELSE 0              ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT3                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN RSV_DIV = '9' AND SALE_DIV = '2' THEN SUM(APPR_AMT ) * -1 ELSE 0                ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT4                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                                                      ]'
        ||CHR(13)||CHR(10)||Q'[                     WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY = 1 THEN 'AMT1'                    ]'
        ||CHR(13)||CHR(10)||Q'[                     WHEN RSV_DIV = '9' AND SALE_DIV = '1' AND ML.M_QTY > 1 THEN 'AMT2'                    ]'
        ||CHR(13)||CHR(10)||Q'[                     WHEN RSV_DIV = '8' AND SALE_DIV = '2' THEN 'AMT3'                                     ]'
        ||CHR(13)||CHR(10)||Q'[                     WHEN RSV_DIV = '9' AND SALE_DIV = '2' THEN 'AMT4'                                     ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_NAME                                                                          ]'
        ||CHR(13)||CHR(10)||Q'[          FROM   MOBILE_LOG ML                                                                             ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   ML.COMP_CD  = :PSV_COMP_CD                                   ]'
        ||CHR(13)||CHR(10)||Q'[           AND   ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE          ]'
        ||CHR(13)||CHR(10)||Q'[           AND   (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[           AND   ML.MOBILE_DIV IN(93, 94)                                     ]'
        ||CHR(13)||CHR(10)||Q'[           AND   GIFT_DIV <> '0'                                              ]'
        ||CHR(13)||CHR(10)||Q'[           AND   ML.RSV_DIV IN ('8','9')                                      ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY ML.COMP_CD, ML.BRAND_CD, ML.STOR_CD, ML.SALE_DT, RSV_DIV, SALE_DIV, MOBILE_DIV, M_QTY                ]'
        ||CHR(13)||CHR(10)||Q'[     ) ML, S_STORE S                                                          ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE  ML.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND    ML.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND    ML.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP  BY S.BRAND_NM, S.STOR_TP_NM,  S.TEAM_NM,  S.SV_USER_ID, ML.STOR_CD,  S.STOR_NM, ML.SALE_DT, ML.APPR_NAME  ]'
        ||CHR(13)||CHR(10)||Q'[     ORDER  BY S.STOR_NM, ML.SALE_DT, ML.APPR_NAME  ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''        
        ||CHR(13)||CHR(10)||Q'[ SELECT '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(APPR_CNT1)   AS VCNT1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT1)   AS VCOL1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_CNT2)   AS VCNT2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT2)   AS VCOL2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_CNT3)   AS VCNT3  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT3)   AS VCOL3  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_CNT4)   AS VCNT4  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT4)   AS VCOL4  ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN            ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y  ORDER BY STOR_NM DESC         ]'
        ;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     ;

        OPEN PR_RESULT FOR
            V_SQL USING
                          PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV 
                          ;

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

    PROCEDURE SP_TAB02
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
        PSV_MOBILE_DIV  IN  VARCHAR2 ,                -- 모바일명
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )   IS
    /******************************************************************************
        NAME:       SP_SUB        매출관리 > 프로모션분석  > POSA 기프트카드 집계현황(사용)
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2017-12-14         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2017-12-14
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

    V_CROSSTAB       VARCHAR2(30000);
    V_SQL            VARCHAR2(30000);
    V_HD             VARCHAR2(30000);
    V_HD1            VARCHAR2(20000);
    V_HD2            VARCHAR2(20000);
    V_HD3            VARCHAR2(20000);
    V_CNT            PLS_INTEGER;
    ls_sql           VARCHAR2(30000);
    ls_sql_with      VARCHAR2(30000);
    ls_sql_main      VARCHAR2(30000);
    ls_sql_date      VARCHAR2(1000);
    ls_sql_store     VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item      VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1         VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2         VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1      VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2      VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main  VARCHAR2(30000);    -- CORSSTAB TITLE
    ERR_HANDLER      EXCEPTION;
    ls_err_cd        VARCHAR2(7) := '0';
    ls_err_msg       VARCHAR2(500);

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                    ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    ;

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT ML.SALE_DT, SUBSTR(ML.SALE_DT,1,4) || '-' || SUBSTR(ML.SALE_DT,5,2) || '-' || SUBSTR(ML.SALE_DT,7,2) || '(' || FC_GET_WEEK(ML.COMP_CD, ML.SALE_DT, ']' || PSV_LANG_CD || q'[' ) || ')'  SALE_DT_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  MOBILE_LOG    ML             ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  ML.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ML.MOBILE_DIV IN ('75', '93', '94')]'
        ||CHR(13)||CHR(10)||Q'[    AND  GIFT_DIV = '0'               ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY ML.SALE_DT ]'
        ;

        ls_sql :=  ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV ;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ;

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USE_YN')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'USE_YN')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CANCEL')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CANCEL')  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TOTAL')   ]'
        ;

        V_HD3 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  'NO'   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_TP') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_TEAM' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SC_USER' )]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CNT')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'AMT')     ]'
        ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).SALE_DT || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[ , ']' || qry_hd(i).SALE_DT_NM  || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'USE_YN')        || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'USE_YN')        || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CANCEL')        || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CANCEL')        || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL')         || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'TOTAL')         || Q'[' AS CT]' || TO_CHAR(i*6);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')           || Q'[' AS CT]' || TO_CHAR(i*6 - 5);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')           || Q'[' AS CT]' || TO_CHAR(i*6 - 4);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')           || Q'[' AS CT]' || TO_CHAR(i*6 - 3);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')           || Q'[' AS CT]' || TO_CHAR(i*6 - 2);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CNT')           || Q'[' AS CT]' || TO_CHAR(i*6 - 1);
                V_HD3 := V_HD3 || CHR(13) || CHR(10) || Q'[ , ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'AMT')           || Q'[' AS CT]' || TO_CHAR(i*6);

            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD3 :=  V_HD3 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD2 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || V_HD3;

        dbms_output.put_line(V_HD) ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[     SELECT                   ]'
        ||CHR(13)||CHR(10)||Q'[              S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.STOR_TP_NM    ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.TEAM_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.SV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[           ,  ML.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[           ,  ML.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT1)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT1 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT1)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT1 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT2)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT2 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT2)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT2 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_CNT3)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS CNT3 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(SUM(APPR_AMT1 + APPR_AMT2)) OVER(PARTITION BY S.BRAND_NM , ML.STOR_CD ) AS AMT3 ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT1) AS APPR_CNT1  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT1) AS APPR_AMT1  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT2) AS APPR_CNT2  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT2) AS APPR_AMT2  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_CNT3) AS APPR_CNT3  ]'
        ||CHR(13)||CHR(10)||Q'[           ,  SUM(APPR_AMT1 + APPR_AMT2) AS APPR_AMT3  ]'
        ||CHR(13)||CHR(10)||Q'[     FROM(                                 ]'
        ||CHR(13)||CHR(10)||Q'[          SELECT                           ]'
        ||CHR(13)||CHR(10)||Q'[                  ML.COMP_CD               ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.STOR_CD               ]'
        ||CHR(13)||CHR(10)||Q'[               ,  ML.SALE_DT               ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                   ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN SALE_DIV = '1' THEN COUNT(APPR_AMT) ELSE 0   ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT1                                       ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                   ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN SALE_DIV = '2' THEN COUNT(APPR_AMT) ELSE 0   ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_CNT2                                       ]'
        ||CHR(13)||CHR(10)||Q'[               , COUNT(APPR_AMT)  AS APPR_CNT3                          ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                   ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN SALE_DIV = '1' THEN SUM(APPR_AMT) ELSE 0     ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT1                                       ]'
        ||CHR(13)||CHR(10)||Q'[               , CASE                                                   ]'
        ||CHR(13)||CHR(10)||Q'[                      WHEN SALE_DIV = '2' THEN SUM(APPR_AMT) * -1 ELSE 0       ]'
        ||CHR(13)||CHR(10)||Q'[                 END AS APPR_AMT2                                       ]'
        ||CHR(13)||CHR(10)||Q'[          FROM   MOBILE_LOG ML                                          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   ML.COMP_CD  = :PSV_COMP_CD                             ]'
        ||CHR(13)||CHR(10)||Q'[           AND   ML.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[           AND   (:PSV_MOBILE_DIV IS NULL OR ML.MOBILE_DIV = :PSV_MOBILE_DIV)  ]'
        ||CHR(13)||CHR(10)||Q'[           AND   ML.MOBILE_DIV IN('75', '93', '94')                     ]'
        ||CHR(13)||CHR(10)||Q'[           AND   GIFT_DIV = '0'                                         ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY ML.COMP_CD, ML.BRAND_CD, ML.STOR_CD, ML.SALE_DT,  SALE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[     ) ML, S_STORE S                                                           ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE  ML.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     AND    ML.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND    ML.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[     GROUP  BY S.BRAND_NM, S.STOR_TP_NM,  S.TEAM_NM,  S.SV_USER_ID, ML.STOR_CD,  S.STOR_NM, ML.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[     ORDER  BY S.STOR_NM, ML.SALE_DT    ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;

        /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
        V_SQL := ''        
        ||CHR(13)||CHR(10)||Q'[ SELECT '' AS NO, Y.*   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)|| ls_sql
        ||CHR(13)||CHR(10)||Q'[         ) S ]'
        ||CHR(13)||CHR(10)||Q'[ PIVOT       ]'
        ||CHR(13)||CHR(10)||Q'[ (           ]'
        ||CHR(13)||CHR(10)||Q'[       SUM(APPR_CNT1)   AS VCNT1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT1)   AS VCOL1  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_CNT2)   AS VCNT2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT2)   AS VCOL2  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_CNT3)   AS VCNT3  ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(APPR_AMT3)   AS VCOL3  ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (SALE_DT) IN             ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )Y  ORDER BY STOR_NM DESC         ]'
        ;

        dbms_output.put_line(V_SQL) ;

        OPEN PR_HEADER FOR
            V_HD USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     , PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD
                     ;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_MOBILE_DIV, PSV_MOBILE_DIV 
                        ;

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


END PKG_SALE1430;

/
