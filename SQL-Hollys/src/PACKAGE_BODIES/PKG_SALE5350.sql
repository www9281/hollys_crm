--------------------------------------------------------
--  DDL for Package Body PKG_SALE5350
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE5350" AS
/******************************************************************************
   NAME:       PKG_SALE5350
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        2012-01-18             1. Created this package body.
******************************************************************************/

   -----------------------------------------------------------------------------
   -- Procedure Name   : SP_TAB01
   -- Description      : 기간별신용카드매출현황
   -- Ref. Table       :
   -----------------------------------------------------------------------------
    PROCEDURE SP_TAB01
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회기간(시작)
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회기간(종료)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS

    TYPE  rec_ct_hd IS RECORD
    ( CARD_CD  VARCHAR2(30),
      CARD_NM  VARCHAR2(80)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1          VARCHAR2(30000);
    V_HD2          VARCHAR2(30000);
    V_CNT          PLS_INTEGER;

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(30000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(30000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    lsLine varchar2(3) := '000';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        dbms_output.enable( 1000000 ) ;


        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := 'WITH'
        ||  ls_sql_store -- S_STORE
        ;

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main := ''
        || chr(13)||chr(10) || q'[  SELECT CARD_CD, CARD_NM                                            ]'
        || chr(13)||chr(10) || q'[    FROM (                                                           ]'
        || chr(13)||chr(10) || q'[          SELECT /*+ LEADING(B, S, C) USE_HASH(C) */ S.BRAND_CD      ]'
        || chr(13)||chr(10) || q'[               , S.STOR_CD                                           ]'
        || chr(13)||chr(10) || q'[               , C.CARD_CD                                           ]'
        || chr(13)||chr(10) || q'[               , C.CARD_NM                                           ]'
        || chr(13)||chr(10) || q'[               , S.PAY_AMT                                           ]'
        || chr(13)||chr(10) || q'[               , S.PAY_CNT                                           ]'
        || chr(13)||chr(10) || q'[               , S.PAY_AMT * C.CARD_FEE AS CHARGE_AMT                ]'
        || chr(13)||chr(10) || q'[            FROM (                                                   ]'
        || chr(13)||chr(10) || q'[                  SELECT S.COMP_CD                                   ]'
        || chr(13)||chr(10) || q'[                       , S.BRAND_CD                                  ]'
        || chr(13)||chr(10) || q'[                       , S.STOR_CD                                   ]'
        || chr(13)||chr(10) || q'[                       , S.CARD_CD                                   ]'
        || chr(13)||chr(10) || q'[                       , SUM(S.APPR_AMT + S.R_PAY_AMT) AS PAY_AMT    ]'
        || chr(13)||chr(10) || q'[                       , SUM(S.GC_QTY   - S.R_GC_QTY ) AS PAY_CNT    ]'
        || chr(13)||chr(10) || q'[                    FROM SALE_JDC S                                  ]'
        || chr(13)||chr(10) || q'[                    WHERE S.COMP_CD = :PSV_COMP_CD                   ]'
        || chr(13)||chr(10) || q'[                     AND S.SALE_DT  >= :PSV_GFR_DATE                 ]'
        || chr(13)||chr(10) || q'[                     AND S.SALE_DT  <= :PSV_GTO_DATE                 ]'
        || chr(13)||chr(10) || q'[                     AND  (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV) ]'
        || chr(13)||chr(10) || q'[                   GROUP BY S.COMP_CD, S.BRAND_CD, S.STOR_CD, S.CARD_CD         ]'
        || chr(13)||chr(10) || q'[                 ) S                                                 ]'
        || chr(13)||chr(10) || q'[               , S_STORE B                                           ]'
        || chr(13)||chr(10) || q'[               , (                                                   ]'
        || chr(13)||chr(10) || q'[                      SELECT  C.COMP_CD                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.BRAND_CD                             ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_DIV                             ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_CD                              ]'
        || chr(13)||chr(10) || q'[                           ,  NVL(L.LANG_NM, C.CARD_NM) AS CARD_NM   ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_FEE                             ]'
        || chr(13)||chr(10) || q'[                        FROM  CARD    C                              ]'
        || chr(13)||chr(10) || q'[                           ,  (                                      ]'
        || chr(13)||chr(10) || q'[                                  SELECT  COMP_CD                    ]'
        || chr(13)||chr(10) || q'[                                       ,  PK_COL                     ]'
        || chr(13)||chr(10) || q'[                                       ,  LANG_NM                    ]'
        || chr(13)||chr(10) || q'[                                    FROM  LANG_TABLE                 ]'
        || chr(13)||chr(10) || q'[                                   WHERE  COMP_CD     = :PSV_COMP_CD ]'
        || chr(13)||chr(10) || q'[                                     AND  TABLE_NM    = 'CARD'       ]'
        || chr(13)||chr(10) || q'[                                     AND  COL_NM      = 'CARD_NM'    ]'
        || chr(13)||chr(10) || q'[                                     AND  LANGUAGE_TP = :PSV_LANG_CD ]'
        || chr(13)||chr(10) || q'[                                     AND  USE_YN      = 'Y'          ]'
        || chr(13)||chr(10) || q'[                              )       L                              ]'
        || chr(13)||chr(10) || q'[                       WHERE  L.COMP_CD(+) = C.COMP_CD               ]'
        || chr(13)||chr(10) || q'[                         AND  L.PK_COL(+)  = LPAD(C.BRAND_CD, 4, ' ')||LPAD(C.CARD_DIV, 1, ' ')||LPAD(C.CARD_CD, 10, ' ')]'
        || chr(13)||chr(10) || q'[                         AND  C.COMP_CD    = :PSV_COMP_CD            ]'
        || chr(13)||chr(10) || q'[                 ) C                                                 ]'
        || chr(13)||chr(10) || q'[           WHERE S.COMP_CD  = B.COMP_CD                              ]'
        || chr(13)||chr(10) || q'[             AND S.BRAND_CD = B.BRAND_CD                             ]'
        || chr(13)||chr(10) || q'[             AND S.STOR_CD = B.STOR_CD                               ]'
        || chr(13)||chr(10) || q'[             AND S.COMP_CD = C.COMP_CD(+)                            ]'
        || chr(13)||chr(10) || q'[             AND S.CARD_CD = C.CARD_CD(+)                            ]'
        || chr(13)||chr(10) || q'[             AND C.CARD_DIV(+) = '1'                                 ]'
        || chr(13)||chr(10) || q'[        )                                                            ]'
        || chr(13)||chr(10) || q'[    GROUP BY CARD_CD, CARD_NM                                        ]'
        || chr(13)||chr(10) || q'[    ORDER BY CARD_CD                                                 ]'
        ;

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        dbms_output.put_line(ls_sql) ;
        --dbms_output.put_line(ls_sql_crosstab_main) ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD, PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ' SELECT BRAND, BRAND_NM, STOR_CD, STOR_NM, PAYMENTS, PAY_CNT, CHARGE_AMT, ';
        V_HD2 := V_HD1 ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ';
                   V_HD2 := V_HD2 || ' , ';
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).CARD_CD || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*3 - 2) || ',';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*3 - 1) || ',';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*3);
                V_HD2 := V_HD2 || ' V01  CT' || TO_CHAR(i*3 - 2 ) || ',';
                V_HD2 := V_HD2 || ' V02  CT' || TO_CHAR(i*3 - 1 ) || ',';
                V_HD2 := V_HD2 || ' V03  CT' || TO_CHAR(i*3);
            END;
        END LOOP;


        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := ' WITH S_HD AS ( '
        || chr(13)||chr(10) || ' SELECT FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''BRAND_CD'') AS BRAND                  '   -- 영업조직
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''BRAND_NM'') AS BRAND_NM               '   -- 영업조직
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''STOR_CD'') AS STOR_CD                 '   -- 점포
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''STOR_NM'') AS STOR_NM                 '   -- 점포명
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAYMENTS'') AS PAYMENTS               '   -- 결제금액
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAY_CNT'') AS PAY_CNT                 '   -- 결제건수
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''CHARGE_AMT'') AS CHARGE_AMT           '   -- 수수료
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAYMENTS'') AS V01                    '   -- 결제금액
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAY_CNT'')  AS V02                    '   -- 결제건수
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''CHARGE_AMT'') AS V03                  '   -- 수수료
        || chr(13)||chr(10) || '   FROM DUAL                                                                            '
        || chr(13)||chr(10) || ' )                                                                                      '
        ||  V_HD1 || ' UNION ALL ' || V_HD2
        ;

        /* MAIN SQL */
        ls_sql_main := ''
        || chr(13)||chr(10) || q'[ SELECT /*+ LEADING(B, S, C) USE_HASH(C) */ S.BRAND_CD                                               ]'
        || chr(13)||chr(10) || q'[      , B.BRAND_NM                                                                                   ]'
        || chr(13)||chr(10) || q'[      , S.STOR_CD                                                                                    ]'
        || chr(13)||chr(10) || q'[      , B.STOR_NM                                                                                    ]'
        || chr(13)||chr(10) || q'[      , C.CARD_CD                                                                                    ]'
        || chr(13)||chr(10) || q'[      , SUM(S.PAY_AMT) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD) T_PAY_AMT                            ]'
        || chr(13)||chr(10) || q'[      , SUM(S.PAY_CNT) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD) T_PAY_CNT                            ]'
        || chr(13)||chr(10) || q'[      , SUM(S.PAY_AMT * NVL(C.CARD_FEE, 0)) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD) T_CHARGE_AMT    ]'
        || chr(13)||chr(10) || q'[      , S.PAY_AMT                                                                                    ]'
        || chr(13)||chr(10) || q'[      , S.PAY_CNT                                                                                    ]'
        || chr(13)||chr(10) || q'[      , S.PAY_AMT * NVL(C.CARD_FEE, 0) AS CHARGE_AMT                                                 ]'
        || chr(13)||chr(10) || q'[   FROM (                                                             ]'
        || chr(13)||chr(10) || q'[         SELECT S.COMP_CD                                             ]'
        || chr(13)||chr(10) || q'[              , S.BRAND_CD                                            ]'
        || chr(13)||chr(10) || q'[              , S.STOR_CD                                             ]'
        || chr(13)||chr(10) || q'[              , S.CARD_CD                                             ]'
        || chr(13)||chr(10) || q'[              , SUM(S.APPR_AMT + S.R_PAY_AMT) AS PAY_AMT              ]'
        || chr(13)||chr(10) || q'[              , SUM(S.GC_QTY   - S.R_GC_QTY ) AS PAY_CNT              ]'
        || chr(13)||chr(10) || q'[           FROM SALE_JDC S                                            ]'
        || chr(13)||chr(10) || q'[          WHERE S.COMP_CD  = :PSV_COMP_CD                             ]'
        || chr(13)||chr(10) || q'[            AND S.SALE_DT >= :PSV_GFR_DATE                            ]'
        || chr(13)||chr(10) || q'[            AND S.SALE_DT <= :PSV_GTO_DATE                            ]'
        || chr(13)||chr(10) || q'[            AND  (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV)]'
        || chr(13)||chr(10) || q'[          GROUP BY S.COMP_CD, S.BRAND_CD, S.STOR_CD, S.CARD_CD        ]'
        || chr(13)||chr(10) || q'[        ) S                                                           ]'
        || chr(13)||chr(10) || q'[      , S_STORE B                                                     ]'
        || chr(13)||chr(10) || q'[               , (                                                    ]'
        || chr(13)||chr(10) || q'[                      SELECT  C.COMP_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  C.BRAND_CD                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_DIV                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  NVL(L.LANG_NM, C.CARD_NM) AS CARD_NM    ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_FEE                              ]'
        || chr(13)||chr(10) || q'[                        FROM  CARD    C                               ]'
        || chr(13)||chr(10) || q'[                           ,  (                                       ]'
        || chr(13)||chr(10) || q'[                                  SELECT  COMP_CD                     ]'
        || chr(13)||chr(10) || q'[                                       ,  PK_COL                      ]'
        || chr(13)||chr(10) || q'[                                       ,  LANG_NM                     ]'
        || chr(13)||chr(10) || q'[                                    FROM  LANG_TABLE                  ]'
        || chr(13)||chr(10) || q'[                                   WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  TABLE_NM    = 'CARD'        ]'
        || chr(13)||chr(10) || q'[                                     AND  COL_NM      = 'CARD_NM'     ]'
        || chr(13)||chr(10) || q'[                                     AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  USE_YN      = 'Y'           ]'
        || chr(13)||chr(10) || q'[                              )       L                               ]'
        || chr(13)||chr(10) || q'[                       WHERE  L.COMP_CD(+) = C.COMP_CD                ]'
        || chr(13)||chr(10) || q'[                         AND  L.PK_COL(+)  = LPAD(C.BRAND_CD, 4, ' ')||LPAD(C.CARD_DIV, 1, ' ')||LPAD(C.CARD_CD, 10, ' ')]'
        || chr(13)||chr(10) || q'[                         AND  C.COMP_CD    = :PSV_COMP_CD             ]'
        || chr(13)||chr(10) || q'[                 ) C                                                  ]'
        || chr(13)||chr(10) || q'[  WHERE S.COMP_CD  = B.COMP_CD                                        ]'
        || chr(13)||chr(10) || q'[    AND S.BRAND_CD = B.BRAND_CD                                       ]'
        || chr(13)||chr(10) || q'[    AND S.STOR_CD = B.STOR_CD                                         ]'
        || chr(13)||chr(10) || q'[    AND S.COMP_CD = C.COMP_CD(+)                                      ]'
        || chr(13)||chr(10) || q'[    AND S.CARD_CD = C.CARD_CD(+)                                      ]'
        || chr(13)||chr(10) || q'[    AND S.COMP_CD = :PSV_COMP_CD                                      ]'
        || chr(13)||chr(10) || q'[    AND C.CARD_DIV(+) = '1'                                           ]'
        || chr(13)||chr(10) || q'[  GROUP BY S.BRAND_CD, B.BRAND_NM, S.STOR_CD, B.STOR_NM, C.CARD_CD, S.PAY_AMT, C.CARD_FEE, S.PAY_CNT ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line( ls_sql) ;

        V_SQL :=             ' SELECT * '
        || chr(13)||chr(10) || ' FROM ( '
        || chr(13)||chr(10) ||         ls_sql
        || chr(13)||chr(10) || ' ) S_STOR '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' ( '
        || chr(13)||chr(10) || '  MAX(PAY_AMT)    VCOL1, '
        || chr(13)||chr(10) || '  MAX(PAY_CNT)    VCOL2, '
        || chr(13)||chr(10) || '  MAX(CHARGE_AMT) VCOL3  '
        || chr(13)||chr(10) || '  FOR (CARD_CD) IN ( '
        || chr(13)||chr(10) ||     V_CROSSTAB
        || chr(13)||chr(10) || '                   ) '
        || chr(13)||chr(10) || ' ) '
        || chr(13)||chr(10) || 'ORDER BY BRAND_CD, STOR_CD'
        ;

        dbms_output.put_line( V_SQL) ;
        dbms_output.put_line( V_HD) ;

        OPEN PR_HEADER FOR V_HD;
        OPEN PR_RESULT FOR V_SQL 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            dbms_output.put_line('line [' || lsLine || '] ' || SQLERRM(SQLCODE) );
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;

---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_TAB02
--  Description      : 일별신용카드매출현황
-- Ref. Table        :
---------------------------------------------------------------------------------------------------
    PROCEDURE SP_TAB02
    (
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회기간(시작)
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회기간(종료)
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR,   -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS

    TYPE  rec_ct_hd IS RECORD
    ( CARD_CD  VARCHAR2(30),
      CARD_NM  VARCHAR2(80)
    );
    TYPE tb_ct_hd IS TABLE OF rec_ct_hd
        INDEX BY PLS_INTEGER;

    qry_hd     tb_ct_hd  ;

    V_CROSSTAB     VARCHAR2(30000);
    V_SQL          VARCHAR2(30000);
    V_HD           VARCHAR2(30000);
    V_HD1          VARCHAR2(30000);
    V_HD2          VARCHAR2(30000);
    V_CNT          PLS_INTEGER;

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(30000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_crosstab_main VARCHAR2(30000) ; -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    lsLine varchar2(3) := '000';

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        dbms_output.enable( 1000000 ) ;


        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := 'WITH'
        ||  ls_sql_store -- S_STORE
        ;

        /* 가로축 데이타 FETCH */
        ls_sql_crosstab_main := ''
        || chr(13)||chr(10) || q'[  SELECT CARD_CD, CARD_NM                                             ]'
        || chr(13)||chr(10) || q'[    FROM (                                                            ]'
        || chr(13)||chr(10) || q'[          SELECT /*+ LEADING(B, S, C) USE_HASH(C) */ S.BRAND_CD       ]'
        || chr(13)||chr(10) || q'[               , S.STOR_CD                                            ]'
        || chr(13)||chr(10) || q'[               , C.CARD_CD                                            ]'
        || chr(13)||chr(10) || q'[               , C.CARD_NM                                            ]'
        || chr(13)||chr(10) || q'[               , S.PAY_AMT                                            ]'
        || chr(13)||chr(10) || q'[               , S.PAY_CNT                                            ]'
        || chr(13)||chr(10) || q'[               , S.PAY_AMT * C.CARD_FEE AS CHARGE_AMT                 ]'
        || chr(13)||chr(10) || q'[            FROM (                                                    ]'
        || chr(13)||chr(10) || q'[                  SELECT S.COMP_CD                                    ]'
        || chr(13)||chr(10) || q'[                       , S.BRAND_CD                                   ]'
        || chr(13)||chr(10) || q'[                       , S.STOR_CD                                    ]'
        || chr(13)||chr(10) || q'[                       , S.CARD_CD                                    ]'
        || chr(13)||chr(10) || q'[                       , SUM(S.APPR_AMT + S.R_PAY_AMT) AS PAY_AMT     ]'
        || chr(13)||chr(10) || q'[                       , SUM(S.GC_QTY   - S.R_GC_QTY ) AS PAY_CNT     ]'
        || chr(13)||chr(10) || q'[                    FROM SALE_JDC S                                   ]'
        || chr(13)||chr(10) || q'[                   WHERE S.COMP_CD = :PSV_COMP_CD                     ]'
        || chr(13)||chr(10) || q'[                     AND S.SALE_DT >= :PSV_GFR_DATE                   ]'
        || chr(13)||chr(10) || q'[                     AND S.SALE_DT <= :PSV_GTO_DATE                   ]'
        || chr(13)||chr(10) || q'[                     AND (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV)]'
        || chr(13)||chr(10) || q'[                   GROUP BY S.COMP_CD, S.BRAND_CD, S.STOR_CD, S.CARD_CD ]'
        || chr(13)||chr(10) || q'[                 ) S                                                  ]'
        || chr(13)||chr(10) || q'[               , S_STORE B                                            ]'
        || chr(13)||chr(10) || q'[               , (                                                    ]'
        || chr(13)||chr(10) || q'[                      SELECT  C.COMP_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  C.BRAND_CD                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_DIV                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  NVL(L.LANG_NM, C.CARD_NM) AS CARD_NM    ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_FEE                              ]'
        || chr(13)||chr(10) || q'[                        FROM  CARD    C                               ]'
        || chr(13)||chr(10) || q'[                           ,  (                                       ]'
        || chr(13)||chr(10) || q'[                                  SELECT  COMP_CD                     ]'
        || chr(13)||chr(10) || q'[                                       ,  PK_COL                      ]'
        || chr(13)||chr(10) || q'[                                       ,  LANG_NM                     ]'
        || chr(13)||chr(10) || q'[                                    FROM  LANG_TABLE                  ]'
        || chr(13)||chr(10) || q'[                                   WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  TABLE_NM    = 'CARD'        ]'
        || chr(13)||chr(10) || q'[                                     AND  COL_NM      = 'CARD_NM'     ]'
        || chr(13)||chr(10) || q'[                                     AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  USE_YN      = 'Y'           ]'
        || chr(13)||chr(10) || q'[                              )       L                               ]'
        || chr(13)||chr(10) || q'[                       WHERE  L.COMP_CD(+) = C.COMP_CD                ]'
        || chr(13)||chr(10) || q'[                         AND  L.PK_COL(+)  = LPAD(C.BRAND_CD, 4, ' ')||LPAD(C.CARD_DIV, 1, ' ')||LPAD(C.CARD_CD, 10, ' ')]'
        || chr(13)||chr(10) || q'[                         AND  C.COMP_CD    = :PSV_COMP_CD             ]'
        || chr(13)||chr(10) || q'[                 ) C                                                  ]'
        || chr(13)||chr(10) || q'[           WHERE S.COMP_CD    = B.COMP_CD                             ]'
        || chr(13)||chr(10) || q'[               AND S.BRAND_CD = B.BRAND_CD                            ]'
        || chr(13)||chr(10) || q'[             AND S.STOR_CD    = B.STOR_CD                             ]'
        || chr(13)||chr(10) || q'[               AND S.COMP_CD  = C.COMP_CD(+)                          ]'
        || chr(13)||chr(10) || q'[             AND S.CARD_CD    = C.CARD_CD(+)                          ]'
        || chr(13)||chr(10) || q'[             AND S.COMP_CD    =  :PSV_COMP_CD                         ]'
        || chr(13)||chr(10) || q'[             AND C.CARD_DIV(+) = '1'                                  ]'
        || chr(13)||chr(10) || q'[        )                                                             ]'
        || chr(13)||chr(10) || q'[    GROUP BY CARD_CD, CARD_NM                                         ]'
        || chr(13)||chr(10) || q'[    ORDER BY CARD_CD                                                  ]'
        ;

        ls_sql := ls_sql_with || ls_sql_crosstab_main ;
        dbms_output.put_line(ls_sql_crosstab_main) ;

        EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV,
                  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD;

        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG(PSV_COMP_CD , PSV_LANG_CD , ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;

        V_HD1 := ' SELECT BRAND, BRAND_NM, STOR_CD, STOR_NM, SALE_DT, PAYMENTS, PAY_CNT, CHARGE_AMT, RCV_PAY_AMT, ';
        V_HD2 := V_HD1 ;

        FOR i IN qry_hd.FIRST..qry_hd.LAST LOOP
            BEGIN
                IF i > 1 THEN
                   V_CROSSTAB := V_CROSSTAB || ' , ';
                   V_HD1 := V_HD1 || ' , ';
                   V_HD2 := V_HD2 || ' , ';
                END IF;
                V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).CARD_CD || ''''  ;
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*4 - 3) || ',';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*4 - 2) || ',';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*4 - 1) || ',';
                V_HD1 := V_HD1 || ''''   || qry_hd(i).CARD_NM  || ''' CT' || TO_CHAR(i*4);
                V_HD2 := V_HD2 || ' V01  CT' || TO_CHAR(i*4 - 3 ) || ',';
                V_HD2 := V_HD2 || ' V02  CT' || TO_CHAR(i*4 - 2 ) || ',';
                V_HD2 := V_HD2 || ' V03  CT' || TO_CHAR(i*4 - 1 ) || ',';
                V_HD2 := V_HD2 || ' V04  CT' || TO_CHAR(i*4);
            END;
        END LOOP;

        V_HD1 :=  V_HD1 || ' FROM S_HD ' ;
        V_HD2 :=  V_HD2 || ' FROM S_HD ' ;
        V_HD   := ' WITH S_HD AS ( '
        || chr(13)||chr(10) || ' SELECT FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''BRAND_CD'')    AS BRAND       '   -- 영업조직
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''BRAND_NM'')    AS BRAND_NM    '   -- 영업조직
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''STOR_CD'')     AS STOR_CD     '   -- 점포
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''STOR_NM'')     AS STOR_NM     '   -- 점포명
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''SALE_DT'')     AS SALE_DT     '   -- 판매일자
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAYMENTS'')    AS PAYMENTS    '   -- 결제금액
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAY_CNT'')     AS PAY_CNT     '   -- 결제건수
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''CHARGE_AMT'')  AS CHARGE_AMT  '   -- 수수료
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''RCV_PAY_AMT'') AS RCV_PAY_AMT '   -- 입금액
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAYMENTS'')    AS V01         '   -- 결제금액
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''PAY_CNT'')     AS V02         '   -- 결제건수
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''CHARGE_AMT'')  AS V03         '   -- 수수료
        || chr(13)||chr(10) || '      , FC_GET_WORDPACK(''' || PSV_COMP_CD || ''' , '''||PSV_LANG_CD||''' , ''RCV_PAY_AMT'') AS V04         '   -- 입금액
        || chr(13)||chr(10) || '   FROM DUAL                                                                            '
        || chr(13)||chr(10) || ' )                                                                                      '
        ||  V_HD1 || ' UNION ALL ' || V_HD2
        ;

        /* MAIN SQL */
        ls_sql_main := ''
        || chr(13)||chr(10) || q'[  SELECT /*+ LEADING(B, S, C) USE_HASH(C) */ S.BRAND_CD                                  ]'
        || chr(13)||chr(10) || q'[       , B.BRAND_NM                                                                      ]'
        || chr(13)||chr(10) || q'[       , S.STOR_CD                                                                       ]'
        || chr(13)||chr(10) || q'[       , B.STOR_NM                                                                       ]'
        || chr(13)||chr(10) || q'[       , S.SALE_DT                                                                       ]'
        || chr(13)||chr(10) || q'[       , C.CARD_CD                                                                       ]'
        || chr(13)||chr(10) || q'[       , SUM(S.PAY_AMT) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD, S.SALE_DT) T_PAY_AMT    ]'
        || chr(13)||chr(10) || q'[       , SUM(S.PAY_CNT) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD, S.SALE_DT) T_PAY_CNT    ]'
        || chr(13)||chr(10) || q'[       , SUM(S.PAY_AMT * NVL(C.CARD_FEE, 0)) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD, S.SALE_DT) T_CHARGE_AMT   ]'
        || chr(13)||chr(10) || q'[       , SUM(S.PAY_AMT) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD, S.SALE_DT) - SUM(S.PAY_AMT * NVL(C.CARD_FEE, 0)) OVER(PARTITION BY S.BRAND_CD, S.STOR_CD, S.SALE_DT) T_RCV_PAY_AMT ]'
        || chr(13)||chr(10) || q'[       , S.PAY_AMT                                                                       ]'
        || chr(13)||chr(10) || q'[       , S.PAY_CNT                                                                       ]'
        || chr(13)||chr(10) || q'[       , S.PAY_AMT * NVL(C.CARD_FEE, 0)               AS CHARGE_AMT                      ]'
        || chr(13)||chr(10) || q'[       , S.PAY_AMT - S.PAY_AMT * NVL(C.CARD_FEE, 0)   AS RCV_PAY_AMT                     ]'
        || chr(13)||chr(10) || q'[   FROM (                                                             ]'
        || chr(13)||chr(10) || q'[         SELECT S.COMP_CD                                             ]'
        || chr(13)||chr(10) || q'[                , S.BRAND_CD                                          ]'
        || chr(13)||chr(10) || q'[              , S.STOR_CD                                             ]'
        || chr(13)||chr(10) || q'[              , S.CARD_CD                                             ]'
        || chr(13)||chr(10) || q'[              , S.SALE_DT                                             ]'
        || chr(13)||chr(10) || q'[              , SUM(S.APPR_AMT + S.R_PAY_AMT) AS PAY_AMT              ]'
        || chr(13)||chr(10) || q'[              , SUM(S.GC_QTY   - S.R_GC_QTY ) AS PAY_CNT              ]'
        || chr(13)||chr(10) || q'[           FROM SALE_JDC S                                            ]'
        || chr(13)||chr(10) || q'[          WHERE S.COMP_CD =  :PSV_COMP_CD                             ]'
        || chr(13)||chr(10) || q'[            AND S.SALE_DT >= :PSV_GFR_DATE                            ]'
        || chr(13)||chr(10) || q'[            AND S.SALE_DT <= :PSV_GTO_DATE                            ]'
        || chr(13)||chr(10) || q'[            AND (:PSV_GIFT_DIV IS NULL OR S.GIFT_DIV = :PSV_GIFT_DIV) ]'
        || chr(13)||chr(10) || q'[          GROUP BY S.COMP_CD, S.BRAND_CD, S.STOR_CD, S.CARD_CD, S.SALE_DT ]'
        || chr(13)||chr(10) || q'[        ) S                                                           ]'
        || chr(13)||chr(10) || q'[       , S_STORE B                                                    ]'
        || chr(13)||chr(10) || q'[               , (                                                    ]'
        || chr(13)||chr(10) || q'[                      SELECT  C.COMP_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  C.BRAND_CD                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_DIV                              ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_CD                               ]'
        || chr(13)||chr(10) || q'[                           ,  NVL(L.LANG_NM, C.CARD_NM) AS CARD_NM    ]'
        || chr(13)||chr(10) || q'[                           ,  C.CARD_FEE                              ]'
        || chr(13)||chr(10) || q'[                        FROM  CARD    C                               ]'
        || chr(13)||chr(10) || q'[                           ,  (                                       ]'
        || chr(13)||chr(10) || q'[                                  SELECT  COMP_CD                     ]'
        || chr(13)||chr(10) || q'[                                       ,  PK_COL                      ]'
        || chr(13)||chr(10) || q'[                                       ,  LANG_NM                     ]'
        || chr(13)||chr(10) || q'[                                    FROM  LANG_TABLE                  ]'
        || chr(13)||chr(10) || q'[                                   WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  TABLE_NM    = 'CARD'        ]'
        || chr(13)||chr(10) || q'[                                     AND  COL_NM      = 'CARD_NM'     ]'
        || chr(13)||chr(10) || q'[                                     AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        || chr(13)||chr(10) || q'[                                     AND  USE_YN      = 'Y'           ]'
        || chr(13)||chr(10) || q'[                              )       L                               ]'
        || chr(13)||chr(10) || q'[                       WHERE  L.COMP_CD(+) = C.COMP_CD                ]'
        || chr(13)||chr(10) || q'[                         AND  L.PK_COL(+)  = LPAD(C.BRAND_CD, 4, ' ')||LPAD(C.CARD_DIV, 1, ' ')||LPAD(C.CARD_CD, 10, ' ')]'
        || chr(13)||chr(10) || q'[                         AND  C.COMP_CD    = :PSV_COMP_CD             ]'
        || chr(13)||chr(10) || q'[                 ) C                                                  ]'
        || chr(13)||chr(10) || q'[  WHERE S.COMP_CD  = B.COMP_CD                                        ]'
        || chr(13)||chr(10) || q'[    AND S.BRAND_CD = B.BRAND_CD                                       ]'
        || chr(13)||chr(10) || q'[    AND S.STOR_CD = B.STOR_CD                                         ]'
        || chr(13)||chr(10) || q'[    AND S.COMP_CD = C.COMP_CD(+)                                      ]'
        || chr(13)||chr(10) || q'[    AND S.CARD_CD = C.CARD_CD(+)                                      ]'
        || chr(13)||chr(10) || q'[    AND S.COMP_CD = :PSV_COMP_CD                                      ]'
        || chr(13)||chr(10) || q'[    AND C.CARD_DIV(+) = '1'                                           ]'
        || chr(13)||chr(10) || q'[  GROUP BY S.BRAND_CD, B.BRAND_NM, S.STOR_CD, B.STOR_NM, S.SALE_DT, C.CARD_CD, S.PAY_AMT, C.CARD_FEE, S.PAY_CNT ]'
        ;

        V_CNT := qry_hd.LAST;

        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line( ls_sql) ;

        V_SQL :=             ' SELECT * '
        || chr(13)||chr(10) || ' FROM ( '
        || chr(13)||chr(10) ||         ls_sql
        || chr(13)||chr(10) || ' ) S_STOR '
        || chr(13)||chr(10) || ' PIVOT '
        || chr(13)||chr(10) || ' ( '
        || chr(13)||chr(10) || '  MAX(PAY_AMT)     VCOL1, '
        || chr(13)||chr(10) || '  MAX(PAY_CNT)     VCOL2, '
        || chr(13)||chr(10) || '  MAX(CHARGE_AMT)  VCOL3, '
        || chr(13)||chr(10) || '  MAX(RCV_PAY_AMT) VCOL4  '
        || chr(13)||chr(10) || '  FOR (CARD_CD) IN ( '
        || chr(13)||chr(10) ||     V_CROSSTAB
        || chr(13)||chr(10) || '                   ) '
        || chr(13)||chr(10) || ' ) '
        || chr(13)||chr(10) || 'ORDER BY BRAND_CD, STOR_CD, SALE_DT'
        ;

        dbms_output.put_line( V_SQL) ;
        dbms_output.put_line( V_HD) ;

        OPEN PR_HEADER FOR V_HD;
        OPEN PR_RESULT FOR V_SQL 
            USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, 
                  PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            dbms_output.put_line('line [' || lsLine || '] ' || SQLERRM(SQLCODE) );
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END ;

END PKG_SALE5350;

/
