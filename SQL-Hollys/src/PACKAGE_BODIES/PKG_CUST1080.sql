--------------------------------------------------------
--  DDL for Package Body PKG_CUST1080
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_CUST1080" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     회원권 판매내역
        PURPOSE:

        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-05-30         1. CREATED THIS PROCEDURE.

        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-05-30
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(32000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    BEGIN

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                            ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql_with := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
               ;

        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  V2.BRAND_CD             AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  V2.BRAND_NM             AS BRAND_NM         ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD              AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_NM              AS STOR_NM          ]'  -- 점포코드명
        ||CHR(13)||CHR(10)||Q'[      ,  V2.OFFER_AMT                                ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  V2.GIF_SAL_AMT                              ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  V2.USE_AMT                                  ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  V2.GIF_PAY_AMT                              ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  V2.ENT_AMT                                  ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CST_OFFER_AMT                            ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.OFFER_AMT     = 0 THEN 0 ELSE V2.CST_OFFER_AMT     / V2.OFFER_AMT   * 100 END AS CST_OFFER_AMT_RATE    ]'  -- 멤버십_제공금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CST_GIF_SAL_AMT                          ]'  -- 멤버십_상품권판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.GIF_SAL_AMT = 0 THEN 0 ELSE V2.CST_GIF_SAL_AMT    / V2.GIF_SAL_AMT  * 100 END AS CST_GIF_SAL_AMT_RATE  ]'  -- 멤버십_상품권판매금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CST_USE_AMT                              ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.USE_AMT       = 0 THEN 0 ELSE V2.CST_USE_AMT       / V2.USE_AMT     * 100 END AS CST_USE_AMT_RATE      ]'  -- 멤버십_사용금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CST_GIF_PAY_AMT                          ]'  -- 멤버십_상품권결제
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.GIF_PAY_AMT   = 0 THEN 0 ELSE V2.CST_GIF_PAY_AMT   / V2.GIF_PAY_AMT * 100 END AS CST_GIF_PAY_AMT_RATE  ]'  -- 멤버십_상품권결제 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.CST_ENT_AMT                              ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.ENT_AMT       = 0 THEN 0 ELSE V2.CST_ENT_AMT       / V2.ENT_AMT     * 100 END AS CST_ENT_AMT_RATE      ]'  -- 멤버십_입장금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NCST_OFFER_AMT                           ]'  -- 비멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.OFFER_AMT     = 0 THEN 0 ELSE V2.NCST_OFFER_AMT    / V2.OFFER_AMT   * 100 END AS NCST_OFFER_AMT_RATE   ]'  -- 비멤버십_제공금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NCST_GIF_SAL_AMT                        ]'  -- 비멤버십_상품권판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.GIF_SAL_AMT = 0 THEN 0 ELSE V2.NCST_GIF_SAL_AMT    / V2.GIF_SAL_AMT * 100 END AS NCST_GIF_SAL_AMT_RATE ]'  -- 비멤버십_상품권판매 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NCST_USE_AMT                             ]'  -- 비멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.USE_AMT       = 0 THEN 0 ELSE V2.NCST_USE_AMT      / V2.USE_AMT     * 100 END AS NCST_USE_AMT_RATE     ]'  -- 비멤버십_사용금액 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NCST_GIF_PAY_AMT                          ]' -- 비멤버십_상품권결제금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.GIF_PAY_AMT   = 0 THEN 0 ELSE V2.NCST_GIF_PAY_AMT  / V2.GIF_PAY_AMT * 100 END AS NCST_GIF_PAY_AMT_RATE ]'  -- 비멤버십_상품권결제 비율
        ||CHR(13)||CHR(10)||Q'[      ,  V2.NCST_ENT_AMT                             ]'  -- 비멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN V2.ENT_AMT       = 0 THEN 0 ELSE V2.NCST_ENT_AMT      / V2.ENT_AMT     * 100 END AS NCST_ENT_AMT_RATE     ]'  -- 비멤버십_입장금액 비율
        ||CHR(13)||CHR(10)||Q'[ FROM(                                                ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.BRAND_CD             AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_NM             AS BRAND_NM         ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD              AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_NM              AS STOR_NM          ]'  -- 점포코드명
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.OFFER_AMT     +                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CONV_AMT)        AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.GIF_SAL_AMT)     AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.USE_AMT)         AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.GIF_PAY_AMT)     AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.ENT_AMT       -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.USE_AMT      -                       ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.GIF_PAY_AMT)     AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.CST_OFFER_AMT +                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_CONV_AMT)    AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.CST_GIF_SAL_AMT) AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.CST_USE_AMT)     AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.CST_GIF_PAY_AMT) AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권결제금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.CST_ENT_AMT   -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_USE_AMT   -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_GIF_PAY_AMT) AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.OFFER_AMT     +                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CONV_AMT      -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_OFFER_AMT -                      ]' 
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_CONV_AMT)    AS NCST_OFFER_AMT   ]' -- 비멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.GIF_SAL_AMT       -                  ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_GIF_SAL_AMT) AS NCST_GIF_SAL_AMT ]' -- 비멤버십_상품권판매금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.USE_AMT       -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_USE_AMT )    AS NCST_USE_AMT     ]' -- 비멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.GIF_PAY_AMT       -                  ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_GIF_PAY_AMT) AS NCST_GIF_PAY_AMT ]' -- 비멤버십_상품권결제금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(V1.ENT_AMT       -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.USE_AMT       -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.GIF_PAY_AMT   -                      ]'
        ||CHR(13)||CHR(10)||Q'[                    (V1.CST_ENT_AMT   -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_USE_AMT   -                      ]'
        ||CHR(13)||CHR(10)||Q'[                     V1.CST_GIF_PAY_AMT)) AS NCST_ENT_AMT    ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[         FROM   (                                            ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_AMT ELSE HS.GRD_AMT END) AS OFFER_AMT]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_USE_DIV ='1'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(MS.OFFER_AMT  - HS.USE_AMT) AS CONV_AMT ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_USE_DIV ='2'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_DIV     ='3'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN ST.GIFT_DIV  = '2'                       THEN ST.PAY_AMT                                   ELSE 0 END) AS GIF_SAL_AMT ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN ST.GIFT_DIV != '2' AND ST.PAY_DIV = '40' THEN ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT) ELSE 0 END) AS GIF_PAY_AMT ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CC.MEMBER_NO IS NOT NULL AND ST.GIFT_DIV  = '2'                       THEN ST.PAY_AMT                                   ELSE 0 END) AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN CC.MEMBER_NO IS NOT NULL AND ST.GIFT_DIV != '2' AND ST.PAY_DIV = '40' THEN ST.PAY_AMT - (ST.CHANGE_AMT + ST.REMAIN_AMT) ELSE 0 END) AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SALE_ST                 ST          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  C_CUST                  CC          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = ST.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = ST.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = ST.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     ST.COMP_CD   = CC.COMP_CD  (+)      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     ST.CUST_ID   = CC.MEMBER_NO(+)      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     ST.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    (ST.GIFT_DIV  = '2' OR ST.PAY_DIV = '40') ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     ST.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(MS.USE_AMT) AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                    ,    CS_MEMBERSHIP_SALE_HIS  MS          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.SALE_USE_DIV = '2'               ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.SALE_DIV    != '3'               ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.APPR_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE      ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(SH.GRD_I_AMT + SH.GRD_O_AMT) AS ENT_AMT ]'  -- 매출금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE         S1                  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,    SALE_HD         SH                  ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = SH.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = SH.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = SH.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.GIFT_DIV  = '0'                  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_AMT  ELSE HS.GRD_AMT END) AS CST_OFFER_AMT]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  C_CUST                  CC          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = CC.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MEMBER_NO = CC.MEMBER_NO         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_USE_DIV ='1'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(MS.OFFER_AMT - HS.USE_AMT) AS CST_CONV_AMT ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  C_CUST                  CC          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = CC.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MEMBER_NO = CC.MEMBER_NO         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_USE_DIV ='2'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_DIV     ='3'                ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(MS.USE_AMT) AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_ENT_AMT      ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[                    ,    CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  C_CUST                  CC          ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = CC.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.MEMBER_NO = CC.MEMBER_NO         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_USE_DIV = '2'               ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.SALE_DIV    != '3'               ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY               ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 UNION ALL                                   ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT  S1.COMP_CD      AS COMP_CD          ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD     AS BRAND_CD         ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD      AS STOR_CD          ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS OFFER_AMT        ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CONV_AMT         ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_SAL_AMT      ]'  -- 상품권판매금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS GIF_PAY_AMT      ]'  -- 상품권결제금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS USE_AMT          ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS ENT_AMT          ]'  -- 입장금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_OFFER_AMT    ]'  -- 멤버십_제공금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_CONV_AMT     ]'  -- 멤버십_전환금액
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_SAL_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_GIF_PAY_AMT  ]'  -- 멤버십_상품권판매현황
        ||CHR(13)||CHR(10)||Q'[                      ,  0               AS CST_USE_AMT      ]'  -- 멤버십_사용금액
        ||CHR(13)||CHR(10)||Q'[                      ,  SUM(SH.GRD_I_AMT + SH.GRD_O_AMT) AS CST_ENT_AMT ]'  -- 멤버십_입장금액
        ||CHR(13)||CHR(10)||Q'[                 FROM    S_STORE         S1                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  SALE_HD         SH                  ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  C_CUST          CC                  ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE   S1.COMP_CD   = SH.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.BRAND_CD  = SH.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     S1.STOR_CD   = SH.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.COMP_CD   = CC.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.CUST_ID   = CC.MEMBER_NO         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.GIFT_DIV  = '0'                  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[                 AND     SH.SALE_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY                                    ]'
        ||CHR(13)||CHR(10)||Q'[                         S1.COMP_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[                      ,  S1.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[                )            V1  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S_STORE     S1  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD  = V1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD = V1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD  = V1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP  BY               ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[        )    V2                        ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                       ]'
        ||CHR(13)||CHR(10)||Q'[         V2.BRAND_CD             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  V2.STOR_CD              ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GFR_DATE, PSV_GTO_DATE,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            --dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;

END PKG_CUST1080;

/
