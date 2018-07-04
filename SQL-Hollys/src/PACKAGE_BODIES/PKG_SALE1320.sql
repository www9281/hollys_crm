--------------------------------------------------------
--  DDL for Package Body PKG_SALE1320
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1320" AS

    PROCEDURE SP_TAB01  /* 점포별 매출 */
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
        PSV_STOR_TP     IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV  IN  VARCHAR2 ,                  -- 임대구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB01     점포별 매출
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
            M_CLASS_CD  VARCHAR2(5)
        ,   M_CLASS_NM  VARCHAR2(50)
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
    ls_sql_tab_main2    VARCHAR2(20000);    -- CORSSTAB TITLE
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT I.M_CLASS_CD, I.M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  D.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = I.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.ITEM_CD  = I.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  I.L_CLASS_CD= '01'      ]'
        ||CHR(13)||CHR(10)||Q'[    AND (                        ]'
        ||CHR(13)||CHR(10)||Q'[         D.GIFT_DIV = '1'        ]'                                                                                     -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[         OR                      ]'
        ||CHR(13)||CHR(10)||Q'[        (D.GIFT_DIV = '0' AND (D.T_SEQ = '0' OR D.SUB_ITEM_DIV IN ('2', '3')) AND D.PROGRAM_ID IS NULL)]'               -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[         OR                      ]'
        ||CHR(13)||CHR(10)||Q'[        (D.PROGRAM_ID IS NOT NULL AND (D.CERT_NO IS NULL OR (D.CERT_NO IS NOT NULL AND D.GRD_AMT - D.USE_AMT <> 0))) ]' -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[        )                        ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY I.M_CLASS_CD ]';

         /* 가로축 데이타 FETCH */
        ls_sql_tab_main2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT I.M_CLASS_CD, I.M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  D.COMP_CD  = S.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.BRAND_CD = S.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.STOR_CD  = S.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = I.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.ITEM_CD  = I.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND (                        ]'
        ||CHR(13)||CHR(10)||Q'[         D.GIFT_DIV = '1'        ]'                                                                                     -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[         OR                      ]'
        ||CHR(13)||CHR(10)||Q'[        (D.GIFT_DIV = '0' AND (D.T_SEQ = '0' OR D.SUB_ITEM_DIV IN ('2', '3')) AND D.PROGRAM_ID IS NULL)]'               -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[         OR                      ]'
        ||CHR(13)||CHR(10)||Q'[        (D.PROGRAM_ID IS NOT NULL AND (D.CERT_NO IS NULL OR (D.CERT_NO IS NOT NULL AND D.GRD_AMT - D.USE_AMT <> 0))) ]' -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[        )                        ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ROWNUM     = 1 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY I.M_CLASS_CD ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_sql := ls_sql_with || ls_sql_tab_main2;

            EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
        END IF;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_CODE')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_GOAL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACHI_RATE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CHILD_CNT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PARENT_CNT')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_HAP')  ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SV_CODE')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_GOAL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACHI_RATE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CHILD_CNT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PARENT_CNT')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_HAP')  ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).M_CLASS_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).M_CLASS_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).M_CLASS_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || CHR(13) || CHR(10) || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V01.BRAND_CLASS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(V01.COMP_CD, '01845', V01.BRAND_CLASS, :PSV_LANG_CD) AS BRAND_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.TR_SALE_AMT - NVL(V04.M_SALE_AMT, 0) AS TR_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V03.GOAL_MON  , 0) AS GOAL_MON  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(V03.GOAL_MON, 0) = 0 THEN 0 ELSE ROUND(V01.TR_SALE_AMT / NVL(V03.GOAL_MON, 0) * 100, 2) END AS GOAL_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V02.CHILD_CNT , 0) AS CHILD_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V02.PARENT_CNT, 0) AS PARENT_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.TS_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.SALE_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.S_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V99.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.BRAND_CLASS ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.SV_USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.SALE_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.S_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V99.S_SALE_AMT) OVER(PARTITION BY V99.COMP_CD, V99.STOR_CD) AS TS_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V99.R_SALE_AMT) OVER(PARTITION BY V99.COMP_CD, V99.STOR_CD) AS TR_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN I.L_CLASS_CD = '01' THEN D.SALE_QTY ELSE 0 END) AS SALE_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'G' THEN D.GRD_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'T' THEN D.SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'N' THEN D.GRD_AMT - D.VAT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                  ELSE 0 END) AS S_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN :PSV_FILTER = 'G' THEN D.GRD_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN :PSV_FILTER = 'T' THEN D.SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN :PSV_FILTER = 'N' THEN D.GRD_AMT - D.VAT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                  ELSE 0 END) AS R_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   D.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (                ]'
        ||CHR(13)||CHR(10)||Q'[                         D.GIFT_DIV = '1']'                                                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR              ]'
        ||CHR(13)||CHR(10)||Q'[                        (D.GIFT_DIV = '0' AND (D.T_SEQ = '0' OR D.SUB_ITEM_DIV IN ('2', '3')) AND D.PROGRAM_ID IS NULL)]'                -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR              ]'
        ||CHR(13)||CHR(10)||Q'[                        (D.PROGRAM_ID IS NOT NULL AND (D.CERT_NO IS NULL OR (D.CERT_NO IS NOT NULL AND D.GRD_AMT - D.USE_AMT <> 0))) ]'  -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                        )                ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                         D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  D.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.SV_USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                ) V99                    ]'
        ||CHR(13)||CHR(10)||Q'[        ) V01                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CE.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CE.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CE.ENTRY_DIV = '2' THEN 1 ELSE 0 END) AS CHILD_CNT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CE.ENTRY_DIV = '2' THEN 0 ELSE 1 END) AS PARENT_CNT]'
        ||CHR(13)||CHR(10)||Q'[          FROM   CS_ENTRY_DT CE  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CE.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.ENTRY_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                 CE.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CE.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[        ) V02                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  SG.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SG.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SG.GOAL_MON     ]'
        ||CHR(13)||CHR(10)||Q'[          FROM   SALE_GOAL_DAY SG]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE       S ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   SG.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.GOAL_YM  = SUBSTR(:PSV_GTO_DATE, 1, 6)]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[        ) V03                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  H.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN :PSV_FILTER = 'G' THEN H.ROUNDING           ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN :PSV_FILTER = 'T' THEN H.ROUNDING           ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN :PSV_FILTER = 'N' THEN ROUND(H.ROUNDING/1.1)]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE 0 END) AS M_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_HD H   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   H.COMP_CD   = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.BRAND_CD  = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.STOR_CD   = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.SALE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.ROUNDING  <> 0            ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY           ]'
        ||CHR(13)||CHR(10)||Q'[                 H.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  H.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         ) V04                               ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   V01.COMP_CD = V02.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.STOR_CD = V02.STOR_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.COMP_CD = V03.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.STOR_CD = V03.STOR_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.COMP_CD = V04.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.STOR_CD = V04.STOR_CD(+)        ]'
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
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY  )   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(S_SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (M_CLASS_CD) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CLASS, STOR_CD ]';

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
            V_SQL USING PSV_LANG_CD, PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_COMP_CD, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;

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

    PROCEDURE SP_TAB02  /* 상품별 매출 */
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
        PSV_STOR_TP     IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV  IN  VARCHAR2 ,                  -- 임대구분
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(헤더)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB02     상품별 매출
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
            M_CLASS_CD  VARCHAR2(5)
        ,   M_CLASS_NM  VARCHAR2(50)
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
    ls_sql_tab_main2    VARCHAR2(20000);    -- CORSSTAB TITLE
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT I.M_CLASS_CD, I.M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  D.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  I.L_CLASS_CD= '01'      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY I.M_CLASS_CD ]';

        /* 가로축 데이타 FETCH */
        ls_sql_tab_main2:= ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DISTINCT I.M_CLASS_CD, I.M_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  D.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  ROWNUM     = 1 ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY I.M_CLASS_CD ]';

        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;

        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        IF SQL%ROWCOUNT = 0  THEN
            ls_sql := ls_sql_with || ls_sql_tab_main2;

            EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd 
                USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
        END IF;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_GOAL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACHI_RATE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CHILD_CNT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PARENT_CNT')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_HAP')  ]';

        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_FG')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BILL_GRD_AMT') ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SALE_GOAL')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ACHI_RATE')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'CHILD_CNT')    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PARENT_CNT')   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'M_CLASS_HAP')  ]';

        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;

                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).M_CLASS_CD || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).M_CLASS_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).M_CLASS_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || CHR(13) || CHR(10) || V_HD2;

        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  V01.BRAND_CLASS ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(V01.COMP_CD, '01845', V01.BRAND_CLASS, :PSV_LANG_CD) AS BRAND_CLASS_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.TR_SALE_AMT - NVL(V04.M_SALE_AMT, 0) AS TR_SALE_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V03.GOAL_MON  , 0) AS GOAL_MON  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN NVL(V03.GOAL_MON, 0) = 0 THEN 0 ELSE ROUND(V01.TR_SALE_AMT / NVL(V03.GOAL_MON, 0) * 100, 2) END AS GOAL_RATE ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V02.CHILD_CNT , 0) AS CHILD_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(V02.PARENT_CNT, 0) AS PARENT_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.TS_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.SALE_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V01.S_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  V99.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.BRAND_CLASS ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.M_CLASS_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.SALE_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  V99.S_SALE_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V99.S_SALE_AMT) OVER(PARTITION BY V99.COMP_CD, V99.BRAND_CLASS) AS TS_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V99.R_SALE_AMT) OVER(PARTITION BY V99.COMP_CD, V99.BRAND_CLASS) AS TR_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   (                ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN I.L_CLASS_CD = '01' THEN D.SALE_QTY ELSE 0 END) AS SALE_QTY          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'G' THEN D.GRD_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'T' THEN D.SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN I.L_CLASS_CD = '01' AND :PSV_FILTER = 'N' THEN D.GRD_AMT - D.VAT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                  ELSE 0 END) AS S_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN :PSV_FILTER = 'G' THEN D.GRD_AMT             ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN :PSV_FILTER = 'T' THEN D.SALE_AMT            ]'
        ||CHR(13)||CHR(10)||Q'[                                  WHEN :PSV_FILTER = 'N' THEN D.GRD_AMT - D.VAT_AMT]'
        ||CHR(13)||CHR(10)||Q'[                                  ELSE 0 END) AS R_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM    SALE_DT     D   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   D.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     D.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (                ]'
        ||CHR(13)||CHR(10)||Q'[                         D.GIFT_DIV = '1']'                                                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR              ]'
        ||CHR(13)||CHR(10)||Q'[                        (D.GIFT_DIV = '0' AND (D.T_SEQ = '0' OR D.SUB_ITEM_DIV IN ('2', '3')) AND D.PROGRAM_ID IS NULL)]'                -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR              ]'
        ||CHR(13)||CHR(10)||Q'[                        (D.PROGRAM_ID IS NOT NULL AND (D.CERT_NO IS NULL OR (D.CERT_NO IS NOT NULL AND D.GRD_AMT - D.USE_AMT <> 0))) ]'  -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                        )                ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                         D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                ) V99                    ]'
        ||CHR(13)||CHR(10)||Q'[        ) V01                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  CE.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CE.ENTRY_DIV = '2' THEN 1 ELSE 0 END) AS CHILD_CNT ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN CE.ENTRY_DIV = '2' THEN 0 ELSE 1 END) AS PARENT_CNT]'
        ||CHR(13)||CHR(10)||Q'[          FROM   CS_ENTRY_DT CE  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   CE.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.ENTRY_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND     CE.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                 CE.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[        ) V02                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  SG.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(SG.GOAL_MON) AS GOAL_MON]'
        ||CHR(13)||CHR(10)||Q'[          FROM   SALE_GOAL_DAY SG]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE       S ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   SG.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     SG.GOAL_YM  = SUBSTR(:PSV_GTO_DATE, 1, 6)]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND     EXISTS (                    ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  1           ]'
        ||CHR(13)||CHR(10)||Q'[                         FROM    SALE_JDM JD ]'
        ||CHR(13)||CHR(10)||Q'[                               , S_ITEM   I  ]'
        ||CHR(13)||CHR(10)||Q'[                         WHERE   JD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     JD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     JD.COMP_CD  = SG.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     JD.BRAND_CD = SG.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     JD.STOR_CD  = SG.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     JD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                         AND     I.L_CLASS_CD= '01'          ]'
        ||CHR(13)||CHR(10)||Q'[                        )        ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                 SG.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[        ) V03                    ]'
        ||CHR(13)||CHR(10)||Q'[      , (                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  H.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN :PSV_FILTER = 'G' THEN H.ROUNDING           ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN :PSV_FILTER = 'T' THEN H.ROUNDING           ]'
        ||CHR(13)||CHR(10)||Q'[                          WHEN :PSV_FILTER = 'N' THEN ROUND(H.ROUNDING/1.1)]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE 0 END) AS M_SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    SALE_HD H       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE S       ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   H.COMP_CD   = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.BRAND_CD  = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.STOR_CD   = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.COMP_CD   = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.SALE_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV ) ]'
        ||CHR(13)||CHR(10)||Q'[         AND     H.ROUNDING  <> 0            ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP   BY              ]'
        ||CHR(13)||CHR(10)||Q'[                 H.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S.BRAND_CLASS   ]'
        ||CHR(13)||CHR(10)||Q'[         ) V04                               ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   V01.COMP_CD     = V02.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.BRAND_CLASS = V02.BRAND_CLASS(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.COMP_CD     = V03.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.BRAND_CLASS = V03.BRAND_CLASS(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.COMP_CD     = V04.COMP_CD(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     V01.BRAND_CLASS = V04.BRAND_CLASS(+)]'
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
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY  )   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(S_SALE_AMT)   AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (M_CLASS_CD) IN    ]'
        ||CHR(13)||CHR(10)||Q'[     (       ]'
        ||CHR(13)||CHR(10)|| V_CROSSTAB
        ||CHR(13)||CHR(10)||Q'[     )       ]'
        ||CHR(13)||CHR(10)||Q'[ )           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY BRAND_CLASS ]';

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
                     , PSV_COMP_CD, PSV_LANG_CD;

        OPEN PR_RESULT FOR
            V_SQL USING PSV_LANG_CD, PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_COMP_CD, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV
                      , PSV_FILTER, PSV_FILTER, PSV_FILTER
                      , PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE
                      , PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;

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

END PKG_SALE1320;

/
