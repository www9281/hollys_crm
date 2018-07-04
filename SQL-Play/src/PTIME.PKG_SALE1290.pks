CREATE OR REPLACE PACKAGE       PKG_SALE1290 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1230
   --  Description      : 회원권 판매내역
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
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 회원권종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE1290;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1290 AS

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
        PSV_DSTN_COMP   IN  VARCHAR2 ,                -- 회원권종류
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  S1.DSTN_COMP            AS DSTN_COMP    ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  S2.STOR_NM              AS DSTN_COMP_NM ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  S1.BRAND_CD             AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[      ,  S1.BRAND_NM             AS BRAND_NM     ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_TP_NM           AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_CD              AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_NM              AS STOR_NM      ]'  -- 점포코드명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.OFFER_TM  )      AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.OFFER_CNT )      AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.OFFER_MCNT)      AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.OFFER_AMT )      AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.CONV_TM  )       AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.CONV_CNT )       AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.CONV_MCNT)       AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.CONV_AMT )       AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.USE_TM   )       AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.USE_CNT  )       AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.USE_MCNT )       AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.USE_AMT  )       AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.EXP_TM   )       AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.EXP_CNT  )       AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.EXP_MCNT )       AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.EXP_AMT  )       AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.REF_TM   )       AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.REF_CNT  )       AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.REF_MCNT )       AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.REF_AMT  )       AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.DISUSE_TM  )     AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.DISUSE_CNT )     AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.DISUSE_MCNT)     AS DISUSE_MCNT  ]'  -- 폐기교구횟수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(V1.DISUSE_AMT )     AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[ FROM   (                                        ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD              AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD             AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)      AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD              AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_TM   ELSE MS.OFFER_TM   - MS.USE_TM   END) AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_CNT  ELSE MS.OFFER_CNT  - MS.USE_CNT  END) AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_MCNT ELSE MS.OFFER_MCNT - MS.USE_MCNT END) AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(CASE WHEN HS.SALE_DIV = '1' THEN MS.OFFER_AMT  ELSE HS.GRD_AMT                  END) AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_MCNT  ]'  -- 폐기횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.SALE_USE_DIV ='1'                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.SALE_DIV     ='1'                ]'
        --||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD              AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD             AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)      AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD              AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_TM   - HS.USE_TM  ) AS CONV_TM  ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_CNT  - HS.USE_CNT ) AS CONV_CNT ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_MCNT - HS.USE_MCNT) AS CONV_MCNT]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_AMT  - HS.USE_AMT ) AS CONV_AMT ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_MCNT  ]'  -- 폐기횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE      MS          ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE_HIS  HS          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = HS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.PROGRAM_ID= HS.PROGRAM_ID        ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_NO    = HS.MBS_NO            ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_NO   = HS.CERT_NO           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.SALE_USE_DIV ='2'                ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.SALE_DIV     ='3'                ]'
        --||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_FDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     HS.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY                ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL               ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD              AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD             AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)      AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD              AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.USE_TM  )        AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.USE_CNT )        AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.USE_MCNT)        AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.USE_AMT )        AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_MCNT  ]'  -- 폐기횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                       AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1          ]'
        ||CHR(13)||CHR(10)||Q'[            ,    CS_MEMBERSHIP_SALE_HIS  MS          ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD         ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.SALE_USE_DIV = '2'               ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.SALE_DIV    <> '3'               ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.APPR_DT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE      ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY               ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL              ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD                      AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD                     AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)              AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD                      AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_TM  - MS.USE_TM  ) AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_CNT - MS.USE_CNT ) AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_MCNT- MS.USE_MCNT) AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_AMT - MS.USE_AMT ) AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_MCNT  ]'  -- 폐기교구횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE      MS      ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_STAT  = '90'             ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.CERT_TDT BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY            ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD                      AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD                     AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)              AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD                      AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_TM       ]' -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_CNT      ]' -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_MCNT     ]' -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_AMT      ]' -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_TM  - MS.USE_TM  ) AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_CNT - MS.USE_CNT ) AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_MCNT- MS.USE_MCNT) AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(-1*MS.REFUND_AMT)           AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_MCNT  ]'  -- 폐기교구횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE      MS      ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_STAT  = '92'          ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.REFUND_DT BETWEEN :PSV_GFR_DATE||'000000' AND :PSV_GTO_DATE||'999999']'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)                ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY            ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         UNION ALL           ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT  S1.COMP_CD                      AS COMP_CD      ]'  -- 회사코드
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD                     AS BRAND_CD     ]'  -- 영업조직
        ||CHR(13)||CHR(10)||Q'[              ,  MAX(S1.STOR_TP_NM)              AS STOR_TP_NM   ]'  -- 직가맹
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD                      AS STOR_CD      ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_TM     ]'  -- 제공시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_CNT    ]'  -- 제공횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_MCNT   ]'  -- 제공횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS OFFER_AMT    ]'  -- 제공금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_TM      ]'  -- 전환시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_CNT     ]'  -- 전환횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_MCNT    ]'  -- 전환횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS CONV_AMT     ]'  -- 전환금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_TM       ]'  -- 사용시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_CNT      ]'  -- 사용횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_MCNT     ]'  -- 사용횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS USE_AMT      ]'  -- 사용금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_TM       ]'  -- 유효기간만료시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_CNT      ]'  -- 유효기간만료횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_MCNT     ]'  -- 유효기간만료횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS EXP_AMT      ]'  -- 유효기간만료금액
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_TM       ]'  -- 환불시간
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_CNT      ]'  -- 환불횟수
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_MCNT     ]'  -- 환불횟수[교구]
        ||CHR(13)||CHR(10)||Q'[              ,  0                               AS REF_AMT      ]'  -- 환불금액
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_TM  - MS.USE_TM  ) AS DISUSE_TM    ]'  -- 폐기시간
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_CNT - MS.USE_CNT ) AS DISUSE_CNT   ]'  -- 폐기횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_MCNT- MS.USE_MCNT) AS DISUSE_MCNT  ]'  -- 폐기교구횟수
        ||CHR(13)||CHR(10)||Q'[              ,  SUM(MS.OFFER_AMT - MS.USE_AMT ) AS DISUSE_AMT   ]'  -- 폐기금액
        ||CHR(13)||CHR(10)||Q'[         FROM    S_STORE                 S1      ]'
        ||CHR(13)||CHR(10)||Q'[              ,  CS_MEMBERSHIP_SALE      MS      ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE   S1.COMP_CD   = MS.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.BRAND_CD  = MS.SALE_BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[         AND     S1.STOR_CD   = MS.SALE_STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.COMP_CD   = :PSV_COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.MBS_STAT  = '99'          ]'
        ||CHR(13)||CHR(10)||Q'[         AND     MS.DISUSE_DT BETWEEN :PSV_GFR_DATE||'000000' AND :PSV_GTO_DATE||'999999']'
        ||CHR(13)||CHR(10)||Q'[         AND    (:PSV_DSTN_COMP IS NULL OR S1.DSTN_COMP = :PSV_DSTN_COMP)                ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY            ]'
        ||CHR(13)||CHR(10)||Q'[                 S1.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[              ,  S1.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[        )            V1      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S1      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  STORE       S2      ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   S1.COMP_CD  = V1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S1.BRAND_CD = V1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S1.STOR_CD  = V1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S1.COMP_CD  = S2.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ AND     S1.DSTN_COMP= S2.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY                   ]'
        ||CHR(13)||CHR(10)||Q'[         S1.DSTN_COMP        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S2.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.BRAND_NM         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_TP_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_CD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_NM          ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER  BY                   ]'
        ||CHR(13)||CHR(10)||Q'[         S1.DSTN_COMP        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.BRAND_CD         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S1.STOR_CD          ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP;
     
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
    
END PKG_SALE1290;

/
