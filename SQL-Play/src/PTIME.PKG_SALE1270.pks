CREATE OR REPLACE PACKAGE       PKG_SALE1270 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1270
   --  Description      : 유통사별 매출정산
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_BRAND_CD        IN  VARCHAR2 ,                  -- 영업조직
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    );
    
END PKG_SALE1270;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1270 AS

    PROCEDURE SP_TAB01
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     유통사별 매출정산(유통사)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2016-06-03
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                     ]'      -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)             AS DSTN_COMP_NM ]'      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_QTY, 0))        AS SALE_QTY     ]'      -- 판매수량
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_AMT, 0) - NVL(SH.SALE_AMT, 0))  AS SALE_AMT     ]'      -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.DC_AMT  , 0) - NVL(SH.DC_AMT  , 0))  AS DC_AMT       ]'      -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.GRD_AMT , 0) - NVL(SH.GRD_AMT , 0))  AS GRD_AMT      ]'      -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.VAT_AMT , 0) - NVL(SH.VAT_AMT , 0))  AS VAT_AMT      ]'      -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.NET_AMT , 0) - NVL(SH.NET_AMT , 0))  AS NET_AMT      ]'      -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_CNT, 0) + NVL(SS.PAY_30_CNT, 0))  AS PAY_10_CNT   ]'  -- 현금+수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_AMT, 0) + NVL(SS.PAY_30_AMT, 0))  AS PAY_10_AMT   ]'  -- 현금+수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_CNT, 0))  AS PAY_20_CNT   ]'  -- 카드 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_AMT, 0))  AS PAY_20_AMT   ]'  -- 카드 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_CNT, 0))  AS PAY_30_CNT   ]'  -- 수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_AMT, 0))  AS PAY_30_AMT   ]'  -- 수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_CNT, 0))  AS PAY_40_CNT   ]'  -- 상품권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_AMT, 0))  AS PAY_40_AMT   ]'  -- 상품권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_CNT, 0))  AS PAY_50_CNT   ]'  -- 식권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_AMT, 0))  AS PAY_50_AMT   ]'  -- 식권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_CNT, 0))  AS PAY_60_CNT   ]'  -- 포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_AMT, 0))  AS PAY_60_AMT   ]'  -- 포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_CNT, 0))  AS PAY_67_CNT   ]'  -- 멤버십 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_AMT, 0))  AS PAY_67_AMT   ]'  -- 멤버십 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_CNT, 0))  AS PAY_68_CNT   ]'  -- 멤버십포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_AMT, 0))  AS PAY_68_AMT   ]'  -- 멤버십포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_CNT, 0))  AS PAY_6A_CNT   ]'  -- 신세계포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_AMT, 0))  AS PAY_6A_AMT   ]'  -- 신세계포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_CNT, 0))  AS PAY_70_CNT   ]'  -- 기프티콘 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_AMT, 0))  AS PAY_70_AMT   ]'  -- 기프티콘 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_CNT, 0))  AS PAY_7A_CNT   ]'  -- 모바일쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_AMT, 0))  AS PAY_7A_AMT   ]'  -- 모바일쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_CNT, 0))  AS PAY_7B_CNT   ]'  -- 쿠팡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_AMT, 0))  AS PAY_7B_AMT   ]'  -- 쿠팡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_CNT, 0))  AS PAY_7C_CNT   ]'  -- 티몬 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_AMT, 0))  AS PAY_7C_AMT   ]'  -- 티몬 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_CNT, 0))  AS PAY_7D_CNT   ]'  -- 네이버페이 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_AMT, 0))  AS PAY_7D_AMT   ]'  -- 네이버페이 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_CNT, 0))  AS PAY_82_CNT   ]'  -- 카카오톡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_AMT, 0))  AS PAY_82_AMT   ]'  -- 카카오톡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_CNT, 0))  AS PAY_84_CNT   ]'  -- 복지몰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_AMT, 0))  AS PAY_84_AMT   ]'  -- 복지몰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_CNT, 0))  AS PAY_83_CNT   ]'  -- 멤버십 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_AMT, 0))  AS PAY_83_AMT   ]'  -- 멤버십 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_CNT, 0))  AS PAY_90_CNT   ]'  -- 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_AMT, 0))  AS PAY_90_AMT   ]'  -- 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_CNT, 0))  AS PAY_91_CNT   ]'  -- 위메프 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_AMT, 0))  AS PAY_91_AMT   ]'  -- 위메프 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_CNT, 0))  AS PAY_92_CNT   ]'  -- 외상대 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_AMT, 0))  AS PAY_92_AMT   ]'  -- 외상대 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_CNT, 0))  AS PAY_93_CNT   ]'  -- 미수금 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_AMT, 0))  AS PAY_93_AMT   ]'  -- 미수금 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_CNT, 0))  AS PAY_A0_CNT   ]'  -- 외상 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_AMT, 0))  AS PAY_A0_AMT   ]'  -- 외상 금액
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY)            AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.SALE_AMT ELSE SD.GRD_AMT - SD.USE_AMT END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.DC_AMT + SD.ENR_AMT ELSE 0 END)            AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.GRD_AMT  ELSE SD.GRD_AMT - SD.USE_AMT END) AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.VAT_AMT  ELSE (SD.GRD_AMT - SD.USE_AMT) - ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.NET_AMT  ELSE ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END)                             AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SD.GIFT_DIV = '1'           ]'                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.GIFT_DIV = '0' AND (T_SEQ = '0' OR SD.SUB_ITEM_DIV IN ('2', '3')) AND PROGRAM_ID IS NULL)   ]'  -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.PROGRAM_ID IS NOT NULL AND (SD.CERT_NO IS NULL OR (SD.CERT_NO IS NOT NULL AND SD.GRD_AMT - SD.USE_AMT <> 0))) ]'              -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                     )   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_AMT <> 0                ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.COMP_CD, SD.SALE_DT, SD.BRAND_CD, SD.STOR_CD, SD.POS_NO, SD.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_10_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_10_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_20_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_30_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_30_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_40_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_50_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_60_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_60_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_67_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_67_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_68_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_6A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_6A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_70_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  ))   ,0) AS PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7B_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7B_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7C_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7C_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7D_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7D_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_82_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  ))   ,0) AS PAY_82_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_84_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  ))   ,0) AS PAY_84_AMT ]'        
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_83_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_90_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_90_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_91_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_91_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_92_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_92_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_93_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_A0_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_A0_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.PAY_DIV      <> '69' ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                       AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING - ROUND(SH.ROUNDING/1.1)    AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ROUND(SH.ROUNDING/1.1)                  AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.ROUNDING     <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD      = SS.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SS.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SS.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SS.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SS.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SS.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = SH.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SH.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SH.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SH.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SH.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SH.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP  ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV,
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV,
                         PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
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
    
    PROCEDURE SP_TAB02
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     유통사별 매출정산(영업조직)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2016-06-03
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                 ]'      -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)         AS DSTN_COMP_NM ]'      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.BRAND_CD                                 ]'      -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)             AS BRAND_NM     ]'      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_QTY, 0))    AS SALE_QTY     ]'      -- 판매수량
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_AMT, 0) - NVL(SH.SALE_AMT, 0))  AS SALE_AMT     ]'      -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.DC_AMT  , 0) - NVL(SH.DC_AMT, 0))    AS DC_AMT       ]'      -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.GRD_AMT , 0) - NVL(SH.GRD_AMT, 0))   AS GRD_AMT      ]'      -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.VAT_AMT , 0) - NVL(SH.VAT_AMT, 0))   AS VAT_AMT      ]'      -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.NET_AMT , 0) - NVL(SH.NET_AMT, 0))   AS NET_AMT      ]'      -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_CNT, 0) + NVL(SS.PAY_30_CNT, 0))  AS PAY_10_CNT   ]'  -- 현금+수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_AMT, 0) + NVL(SS.PAY_30_AMT, 0))  AS PAY_10_AMT   ]'  -- 현금+수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_CNT, 0))  AS PAY_20_CNT   ]'  -- 카드 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_AMT, 0))  AS PAY_20_AMT   ]'  -- 카드 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_CNT, 0))  AS PAY_30_CNT   ]'  -- 수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_AMT, 0))  AS PAY_30_AMT   ]'  -- 수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_CNT, 0))  AS PAY_40_CNT   ]'  -- 상품권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_AMT, 0))  AS PAY_40_AMT   ]'  -- 상품권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_CNT, 0))  AS PAY_50_CNT   ]'  -- 식권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_AMT, 0))  AS PAY_50_AMT   ]'  -- 식권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_CNT, 0))  AS PAY_60_CNT   ]'  -- 포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_AMT, 0))  AS PAY_60_AMT   ]'  -- 포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_CNT, 0))  AS PAY_67_CNT   ]'  -- 멤버십 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_AMT, 0))  AS PAY_67_AMT   ]'  -- 멤버십 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_CNT, 0))  AS PAY_68_CNT   ]'  -- 멤버십포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_AMT, 0))  AS PAY_68_AMT   ]'  -- 멤버십포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_CNT, 0))  AS PAY_6A_CNT   ]'  -- 신세계포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_AMT, 0))  AS PAY_6A_AMT   ]'  -- 신세계포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_CNT, 0))  AS PAY_70_CNT   ]'  -- 기프티콘 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_AMT, 0))  AS PAY_70_AMT   ]'  -- 기프티콘 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_CNT, 0))  AS PAY_7A_CNT   ]'  -- 모바일쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_AMT, 0))  AS PAY_7A_AMT   ]'  -- 모바일쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_CNT, 0))  AS PAY_7B_CNT   ]'  -- 쿠팡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_AMT, 0))  AS PAY_7B_AMT   ]'  -- 쿠팡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_CNT, 0))  AS PAY_7C_CNT   ]'  -- 티몬 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_AMT, 0))  AS PAY_7C_AMT   ]'  -- 티몬 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_CNT, 0))  AS PAY_7D_CNT   ]'  -- 네이버페이 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_AMT, 0))  AS PAY_7D_AMT   ]'  -- 네이버페이 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_CNT, 0))  AS PAY_82_CNT   ]'  -- 카카오톡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_AMT, 0))  AS PAY_82_AMT   ]'  -- 카카오톡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_CNT, 0))  AS PAY_84_CNT   ]'  -- 복지몰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_AMT, 0))  AS PAY_84_AMT   ]'  -- 복지몰 금액        
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_CNT, 0))  AS PAY_83_CNT   ]'  -- 멤버십 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_AMT, 0))  AS PAY_83_AMT   ]'  -- 멤버십 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_CNT, 0))  AS PAY_90_CNT   ]'  -- 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_AMT, 0))  AS PAY_90_AMT   ]'  -- 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_CNT, 0))  AS PAY_91_CNT   ]'  -- 위메프 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_AMT, 0))  AS PAY_91_AMT   ]'  -- 위메프 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_CNT, 0))  AS PAY_92_CNT   ]'  -- 외상대 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_AMT, 0))  AS PAY_92_AMT   ]'  -- 외상대 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_CNT, 0))  AS PAY_93_CNT   ]'  -- 미수금 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_AMT, 0))  AS PAY_93_AMT   ]'  -- 미수금 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_CNT, 0))  AS PAY_A0_CNT   ]'  -- 외상 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_AMT, 0))  AS PAY_A0_AMT   ]'  -- 외상 금액
        ||CHR(13)||CHR(10)||Q'[   FROM  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY)            AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.SALE_AMT ELSE SD.GRD_AMT - SD.USE_AMT END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.DC_AMT + SD.ENR_AMT ELSE 0 END)            AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.GRD_AMT  ELSE SD.GRD_AMT - SD.USE_AMT END) AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.VAT_AMT  ELSE (SD.GRD_AMT - SD.USE_AMT) - ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.NET_AMT  ELSE ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END)                             AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SD.GIFT_DIV = '1'           ]'                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.GIFT_DIV = '0' AND (T_SEQ = '0' OR SD.SUB_ITEM_DIV IN ('2', '3')) AND PROGRAM_ID IS NULL)   ]'  -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.PROGRAM_ID IS NOT NULL AND (SD.CERT_NO IS NULL OR (SD.CERT_NO IS NOT NULL AND SD.GRD_AMT - SD.USE_AMT <> 0))) ]'              -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                     )   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_AMT <> 0                ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.COMP_CD, SD.SALE_DT, SD.BRAND_CD, SD.STOR_CD, SD.POS_NO, SD.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_10_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_10_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_20_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_30_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_30_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_40_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_50_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_60_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_60_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_67_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_67_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_68_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_6A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_6A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_70_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  ))   ,0) AS PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7B_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7B_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7C_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7C_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7D_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7D_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_82_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  ))   ,0) AS PAY_82_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_84_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  ))   ,0) AS PAY_84_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_83_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_90_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_90_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_91_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_91_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_92_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_92_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_93_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_A0_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_A0_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.PAY_DIV      <> '69' ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                       AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING - ROUND(SH.ROUNDING/1.1)    AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ROUND(SH.ROUNDING/1.1)                  AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.ROUNDING     <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD      = SS.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SS.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SS.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SS.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SS.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SS.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = SH.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SH.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SH.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SH.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SH.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SH.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, SD.BRAND_CD ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
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
    
    PROCEDURE SP_TAB03
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB03     유통사별 매출정산(점포)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2016-06-03
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                 ]'      -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)         AS DSTN_COMP_NM ]'      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.BRAND_CD                                 ]'      -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)             AS BRAND_NM     ]'      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD                                  ]'      -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)              AS STOR_NM      ]'      -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_QTY, 0))    AS SALE_QTY     ]'      -- 판매수량
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.SALE_AMT, 0) - NVL(SH.SALE_AMT, 0))  AS SALE_AMT     ]'      -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.DC_AMT  , 0) - NVL(SH.DC_AMT, 0))    AS DC_AMT       ]'      -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.GRD_AMT , 0) - NVL(SH.GRD_AMT, 0))   AS GRD_AMT      ]'      -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.VAT_AMT , 0) - NVL(SH.VAT_AMT, 0))   AS VAT_AMT      ]'      -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SD.NET_AMT , 0) - NVL(SH.NET_AMT, 0))   AS NET_AMT      ]'      -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_CNT, 0) + NVL(SS.PAY_30_CNT, 0))  AS PAY_10_CNT   ]'  -- 현금+수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_AMT, 0) + NVL(SS.PAY_30_AMT, 0))  AS PAY_10_AMT   ]'  -- 현금+수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_CNT, 0))  AS PAY_20_CNT   ]'  -- 카드 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_AMT, 0))  AS PAY_20_AMT   ]'  -- 카드 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_CNT, 0))  AS PAY_30_CNT   ]'  -- 수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_AMT, 0))  AS PAY_30_AMT   ]'  -- 수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_CNT, 0))  AS PAY_40_CNT   ]'  -- 상품권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_AMT, 0))  AS PAY_40_AMT   ]'  -- 상품권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_CNT, 0))  AS PAY_50_CNT   ]'  -- 식권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_AMT, 0))  AS PAY_50_AMT   ]'  -- 식권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_CNT, 0))  AS PAY_60_CNT   ]'  -- 포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_AMT, 0))  AS PAY_60_AMT   ]'  -- 포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_CNT, 0))  AS PAY_67_CNT   ]'  -- 멤버십 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_AMT, 0))  AS PAY_67_AMT   ]'  -- 멤버십 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_CNT, 0))  AS PAY_68_CNT   ]'  -- 멤버십포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_AMT, 0))  AS PAY_68_AMT   ]'  -- 멤버십포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_CNT, 0))  AS PAY_6A_CNT   ]'  -- 신세계포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_AMT, 0))  AS PAY_6A_AMT   ]'  -- 신세계포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_CNT, 0))  AS PAY_70_CNT   ]'  -- 기프티콘 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_AMT, 0))  AS PAY_70_AMT   ]'  -- 기프티콘 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_CNT, 0))  AS PAY_7A_CNT   ]'  -- 모바일쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_AMT, 0))  AS PAY_7A_AMT   ]'  -- 모바일쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_CNT, 0))  AS PAY_7B_CNT   ]'  -- 쿠팡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_AMT, 0))  AS PAY_7B_AMT   ]'  -- 쿠팡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_CNT, 0))  AS PAY_7C_CNT   ]'  -- 티몬 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_AMT, 0))  AS PAY_7C_AMT   ]'  -- 티몬 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_CNT, 0))  AS PAY_7D_CNT   ]'  -- 네이버페이 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_AMT, 0))  AS PAY_7D_AMT   ]'  -- 네이버페이 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_CNT, 0))  AS PAY_82_CNT   ]'  -- 카카오톡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_AMT, 0))  AS PAY_82_AMT   ]'  -- 카카오톡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_CNT, 0))  AS PAY_84_CNT   ]'  -- 복지몰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_AMT, 0))  AS PAY_84_AMT   ]'  -- 복지몰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_CNT, 0))  AS PAY_83_CNT   ]'  -- 멤버십 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_AMT, 0))  AS PAY_83_AMT   ]'  -- 멤버십 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_CNT, 0))  AS PAY_90_CNT   ]'  -- 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_AMT, 0))  AS PAY_90_AMT   ]'  -- 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_CNT, 0))  AS PAY_91_CNT   ]'  -- 위메프 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_AMT, 0))  AS PAY_91_AMT   ]'  -- 위메프 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_CNT, 0))  AS PAY_92_CNT   ]'  -- 외상대 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_AMT, 0))  AS PAY_92_AMT   ]'  -- 외상대 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_CNT, 0))  AS PAY_93_CNT   ]'  -- 미수금 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_AMT, 0))  AS PAY_93_AMT   ]'  -- 미수금 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_CNT, 0))  AS PAY_A0_CNT   ]'  -- 외상 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_AMT, 0))  AS PAY_A0_AMT   ]'  -- 외상 금액
        ||CHR(13)||CHR(10)||Q'[   FROM  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY)            AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.SALE_AMT ELSE SD.GRD_AMT - SD.USE_AMT END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.DC_AMT + SD.ENR_AMT ELSE 0 END)            AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.GRD_AMT  ELSE SD.GRD_AMT - SD.USE_AMT END) AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.VAT_AMT  ELSE (SD.GRD_AMT - SD.USE_AMT) - ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.NET_AMT  ELSE ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END)                             AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SD.GIFT_DIV = '1'           ]'                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.GIFT_DIV = '0' AND (T_SEQ = '0' OR SD.SUB_ITEM_DIV IN ('2', '3')) AND PROGRAM_ID IS NULL)   ]'  -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.PROGRAM_ID IS NOT NULL AND (SD.CERT_NO IS NULL OR (SD.CERT_NO IS NOT NULL AND SD.GRD_AMT - SD.USE_AMT <> 0))) ]'              -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                     )   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_AMT <> 0                ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.COMP_CD, SD.SALE_DT, SD.BRAND_CD, SD.STOR_CD, SD.POS_NO, SD.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_10_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_10_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_20_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_30_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_30_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_40_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_50_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_60_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_60_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_67_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_67_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_68_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_6A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_6A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_70_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  ))   ,0) AS PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7B_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7B_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7C_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7C_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7D_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7D_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_82_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  ))   ,0) AS PAY_82_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_84_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  ))   ,0) AS PAY_84_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_83_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_90_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_90_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_91_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_91_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_92_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_92_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_93_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_A0_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_A0_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.PAY_DIV      <> '69' ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                       AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING - ROUND(SH.ROUNDING/1.1)    AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ROUND(SH.ROUNDING/1.1)                  AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.ROUNDING     <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD      = SS.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SS.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SS.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SS.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SS.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SS.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = SH.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SH.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SH.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SH.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SH.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SH.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, SD.BRAND_CD, SD.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, SD.BRAND_CD, SD.STOR_CD ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
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
    
    PROCEDURE SP_TAB04
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB04     유통사별 매출정산(일자)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB04
            SYSDATE     :   2016-06-03
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  S.DSTN_COMP                                 ]'      -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.DSTN_COMP_NM)         AS DSTN_COMP_NM ]'      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.BRAND_CD                                 ]'      -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)             AS BRAND_NM     ]'      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.STOR_CD                                  ]'      -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)              AS STOR_NM      ]'      -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SALE_DT                                  ]'      -- 판매일자
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WEEK(:PSV_COMP_CD, SD.SALE_DT, :PSV_LANG_CD)   AS SALE_DY  ]'      -- 요일
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.SALE_QTY)                AS SALE_QTY     ]'      -- 판매수량
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.SALE_AMT - NVL(SH.SALE_AMT, 0))  AS SALE_AMT     ]'      -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.DC_AMT   - NVL(SH.DC_AMT, 0))    AS DC_AMT       ]'      -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.GRD_AMT  - NVL(SH.GRD_AMT, 0))   AS GRD_AMT      ]'      -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.VAT_AMT  - NVL(SH.VAT_AMT, 0))   AS VAT_AMT      ]'      -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.NET_AMT  - NVL(SH.NET_AMT, 0))   AS NET_AMT      ]'      -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_CNT, 0) + NVL(SS.PAY_30_CNT, 0))  AS PAY_10_CNT   ]'  -- 현금+수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_10_AMT, 0) + NVL(SS.PAY_30_AMT, 0))  AS PAY_10_AMT   ]'  -- 현금+수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_CNT, 0))  AS PAY_20_CNT   ]'  -- 카드 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_20_AMT, 0))  AS PAY_20_AMT   ]'  -- 카드 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_CNT, 0))  AS PAY_30_CNT   ]'  -- 수표 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_30_AMT, 0))  AS PAY_30_AMT   ]'  -- 수표 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_CNT, 0))  AS PAY_40_CNT   ]'  -- 상품권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_40_AMT, 0))  AS PAY_40_AMT   ]'  -- 상품권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_CNT, 0))  AS PAY_50_CNT   ]'  -- 식권 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_50_AMT, 0))  AS PAY_50_AMT   ]'  -- 식권 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_CNT, 0))  AS PAY_60_CNT   ]'  -- 포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_60_AMT, 0))  AS PAY_60_AMT   ]'  -- 포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_CNT, 0))  AS PAY_67_CNT   ]'  -- 멤버십 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_67_AMT, 0))  AS PAY_67_AMT   ]'  -- 멤버십 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_CNT, 0))  AS PAY_68_CNT   ]'  -- 멤버십포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_68_AMT, 0))  AS PAY_68_AMT   ]'  -- 멤버십포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_CNT, 0))  AS PAY_6A_CNT   ]'  -- 신세계포인트 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_6A_AMT, 0))  AS PAY_6A_AMT   ]'  -- 신세계포인트 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_CNT, 0))  AS PAY_70_CNT   ]'  -- 기프티콘 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_70_AMT, 0))  AS PAY_70_AMT   ]'  -- 기프티콘 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_CNT, 0))  AS PAY_7A_CNT   ]'  -- 모바일쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7A_AMT, 0))  AS PAY_7A_AMT   ]'  -- 모바일쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_CNT, 0))  AS PAY_7B_CNT   ]'  -- 쿠팡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7B_AMT, 0))  AS PAY_7B_AMT   ]'  -- 쿠팡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_CNT, 0))  AS PAY_7C_CNT   ]'  -- 티몬 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7C_AMT, 0))  AS PAY_7C_AMT   ]'  -- 티몬 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_CNT, 0))  AS PAY_7D_CNT   ]'  -- 네이버페이 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_7D_AMT, 0))  AS PAY_7D_AMT   ]'  -- 네이버페이 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_CNT, 0))  AS PAY_82_CNT   ]'  -- 카카오톡 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_82_AMT, 0))  AS PAY_82_AMT   ]'  -- 카카오톡 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_CNT, 0))  AS PAY_84_CNT   ]'  -- 복지몰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_84_AMT, 0))  AS PAY_84_AMT   ]'  -- 복지몰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_CNT, 0))  AS PAY_83_CNT   ]'  -- 멤버십 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_83_AMT, 0))  AS PAY_83_AMT   ]'  -- 멤버십 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_CNT, 0))  AS PAY_90_CNT   ]'  -- 쿠폰 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_90_AMT, 0))  AS PAY_90_AMT   ]'  -- 쿠폰 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_CNT, 0))  AS PAY_91_CNT   ]'  -- 위메프 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_91_AMT, 0))  AS PAY_91_AMT   ]'  -- 위메프 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_CNT, 0))  AS PAY_92_CNT   ]'  -- 외상대 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_92_AMT, 0))  AS PAY_92_AMT   ]'  -- 외상대 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_CNT, 0))  AS PAY_93_CNT   ]'  -- 미수금 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_93_AMT, 0))  AS PAY_93_AMT   ]'  -- 미수금 금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_CNT, 0))  AS PAY_A0_CNT   ]'  -- 외상 건수
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NVL(SS.PAY_A0_AMT, 0))  AS PAY_A0_AMT   ]'  -- 외상 금액
        ||CHR(13)||CHR(10)||Q'[   FROM  (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SD.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SD.SALE_QTY)            AS SALE_QTY ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.SALE_AMT ELSE SD.GRD_AMT - SD.USE_AMT END) AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.DC_AMT + SD.ENR_AMT ELSE 0 END)            AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.GRD_AMT  ELSE SD.GRD_AMT - SD.USE_AMT END) AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.VAT_AMT  ELSE (SD.GRD_AMT - SD.USE_AMT) - ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END) AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(CASE WHEN SD.CERT_NO IS NULL THEN SD.NET_AMT  ELSE ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END)                             AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM  I   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SD.GIFT_DIV = '1'           ]'                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.GIFT_DIV = '0' AND (T_SEQ = '0' OR SD.SUB_ITEM_DIV IN ('2', '3')) AND PROGRAM_ID IS NULL)   ]'  -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.PROGRAM_ID IS NOT NULL AND (SD.CERT_NO IS NULL OR (SD.CERT_NO IS NOT NULL AND SD.GRD_AMT - SD.USE_AMT <> 0))) ]'              -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                     )   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_AMT <> 0                ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SD.COMP_CD, SD.SALE_DT, SD.BRAND_CD, SD.STOR_CD, SD.POS_NO, SD.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SD          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SS.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SS.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_10_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '10', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_10_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_20_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '20', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_20_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_30_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '30', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_30_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_40_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '40', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_40_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_50_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '50', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_50_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_60_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '60', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_60_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_67_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '67', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_67_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_68_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '68', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_68_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_6A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '6A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_6A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_70_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '70', SS.PAY_AMT                                  ))   ,0) AS PAY_70_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7A_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7A', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7A_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7B_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7B', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7B_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7C_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7C', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7C_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_7D_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '7D', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_7D_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_82_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '82', SS.PAY_AMT                                  ))   ,0) AS PAY_82_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_84_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '84', SS.PAY_AMT                                  ))   ,0) AS PAY_84_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_83_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '83', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_83_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_90_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '90', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_90_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_91_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '91', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_91_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_92_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '92', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_92_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_93_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, '93', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_93_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)) ,0) AS PAY_A0_CNT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SS.PAY_DIV, 'A0', SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)))   ,0) AS PAY_A0_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_ST SS  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SS.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SS.PAY_DIV      <> '69' ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SS.COMP_CD, SS.SALE_DT, SS.BRAND_CD, SS.STOR_CD, SS.POS_NO, SS.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[         )   SS          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SH.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.POS_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BILL_NO  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0                                       AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING                             AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.ROUNDING - ROUND(SH.ROUNDING/1.1)    AS VAT_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ROUND(SH.ROUNDING/1.1)                  AS NET_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.ROUNDING     <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[         )   SH          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD      = SS.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SS.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SS.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SS.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SS.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SS.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = SH.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT      = SH.SALE_DT(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = SH.BRAND_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = SH.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.POS_NO       = SH.POS_NO(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BILL_NO      = SH.BILL_NO(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY S.DSTN_COMP, SD.BRAND_CD, SD.STOR_CD, SD.SALE_DT ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY S.DSTN_COMP, SD.BRAND_CD, SD.STOR_CD, SD.SALE_DT ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV, 
                         PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
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
    
    PROCEDURE SP_TAB05
    ( 
        PSV_COMP_CD         IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER            IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_PGM_ID          IN  VARCHAR2 ,                  -- Progrm ID
        PSV_LANG_CD         IN  VARCHAR2 ,                  -- Language Code
        PSV_ORG_CLASS       IN  VARCHAR2 ,                  -- 품목 대/중/소 분류 그룹
        PSV_PARA            IN  VARCHAR2 ,                  -- Search Parameter
        PSV_FILTER          IN  VARCHAR2 ,                  -- Search Filter
        PSV_GFR_DATE        IN  VARCHAR2 ,                  -- 조회 시작일자
        PSV_GTO_DATE        IN  VARCHAR2 ,                  -- 조회 종료일자
        PSV_BRAND_CD        IN  VARCHAR2 ,                  -- 영업조직
        PSV_DSTN_COMP       IN  VARCHAR2 ,                  -- 유통사
        PSV_STOR_TP         IN  VARCHAR2 ,                  -- 직가맹구분
        PSV_RENTAL_DIV      IN  VARCHAR2 ,                  -- 임대구분
        PR_RESULT           IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set
        PR_RTN_CD           OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG          OUT VARCHAR2                    -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB05     유통사별 매출정산(상세정보)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-06-01         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB05
            SYSDATE     :   2016-06-03
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
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  DSTN_COMP                           ]'  -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DSTN_COMP_NM)   AS DSTN_COMP_NM ]'  -- 유통사명
        ||CHR(13)||CHR(10)||Q'[      ,  BRAND_CD                            ]'  -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BRAND_NM)       AS BRAND_NM     ]'  -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[      ,  STOR_CD                             ]'  -- 점포코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(STOR_NM)        AS STOR_NM      ]'  -- 점포명
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT                             ]'  -- 판매일자
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SALE_DY)        AS SALE_DY      ]'  -- 요일
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_TM                             ]'  -- 판매시간
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(SALE_DIV_NM)    AS SALE_DIV_NM  ]'  -- 판매구분
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(L_CLASS_CD)     AS L_CLASS_CD   ]'  -- 대분류코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(L_CLASS_NM)     AS L_CLASS_NM   ]'  -- 대분류명
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(M_CLASS_CD)     AS M_CLASS_CD   ]'  -- 중분류코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(M_CLASS_NM)     AS M_CLASS_NM   ]'  -- 중분류명
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S_CLASS_CD)     AS S_CLASS_CD   ]'  -- 소분류코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S_CLASS_NM)     AS S_CLASS_NM   ]'  -- 소분류명
        ||CHR(13)||CHR(10)||Q'[      ,  ITEM_CD                             ]'  -- 상품코드
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(ITEM_NM)        AS ITEM_NM      ]'  -- 상품명
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_QTY)       AS SALE_QTY     ]'  -- 판매수량
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SALE_AMT)       AS SALE_AMT     ]'  -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DC_AMT)         AS DC_AMT       ]'  -- 할인금액
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(DC_NM)          AS DC_NM        ]'  -- 할인종류
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(GRD_AMT)        AS GRD_AMT      ]'  -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(VAT_AMT)        AS VAT_AMT      ]'  -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(NET_AMT)        AS NET_AMT      ]'  -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'  
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.DSTN_COMP ]'                                                          -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DSTN_COMP_NM  ]'                                                      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.BRAND_CD ]'                                                          -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM  ]'                                                          -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.STOR_CD  ]'                                                          -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM   ]'                                                          -- 점포명
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_DT  ]'                                                          -- 판매일자
        ||CHR(13)||CHR(10)||Q'[                  ,  FC_GET_WEEK(:PSV_COMP_CD, SH.SALE_DT, :PSV_LANG_CD) AS SALE_DY  ]'      -- 요일
        ||CHR(13)||CHR(10)||Q'[                  ,  SH.SALE_TM  ]'                                                          -- 판매시간
        ||CHR(13)||CHR(10)||Q'[                  ,  0   AS SEQ  ]'                                                          -- 순번
        ||CHR(13)||CHR(10)||Q'[                  ,  '0' AS SALE_DIV ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'UNPAID_AMT') AS SALE_DIV_NM ]'  -- 판매구분
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS L_CLASS_CD   ]'                                                  -- 대분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS L_CLASS_NM   ]'                                                  -- 대분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS M_CLASS_CD   ]'                                                  -- 중분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS M_CLASS_NM   ]'                                                  -- 중분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS S_CLASS_CD   ]'                                                  -- 소분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS S_CLASS_NM   ]'                                                  -- 소분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS ITEM_CD      ]'                                                  -- 상품코드
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS ITEM_NM      ]'                                                  -- 상품명
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS FREE_DIV     ]'                                                  -- 무료구분
        ||CHR(13)||CHR(10)||Q'[                  ,  0   AS SALE_QTY    ]'                                                  -- 판매수량
        ||CHR(13)||CHR(10)||Q'[                  ,  -1 * SH.ROUNDING    AS SALE_AMT ]'                                      -- 총판매금액
        ||CHR(13)||CHR(10)||Q'[                  ,  0                   AS DC_AMT   ]'                                      -- 할인금액
        ||CHR(13)||CHR(10)||Q'[                  ,  0                   AS DC_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ''  AS DC_NM        ]'                                                  -- 할인종류
        ||CHR(13)||CHR(10)||Q'[                  ,  -1 * SH.ROUNDING    AS GRD_AMT  ]'                                      -- 순매출액(세포함)
        ||CHR(13)||CHR(10)||Q'[                  ,  -1 * (SH.ROUNDING - ROUND(SH.ROUNDING/1.1)) AS VAT_AMT  ]'              -- 부가세
        ||CHR(13)||CHR(10)||Q'[                  ,  -1 * ROUND(SH.ROUNDING/1.1) AS NET_AMT  ]'                              -- 순매출액(세제외)
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.ROUNDING     <> 0    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP   IS NULL OR S.DSTN_COMP       = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  S.DSTN_COMP     ]'      -- 유통사코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.DSTN_COMP_NM  ]'      -- 유통사명
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.BRAND_CD     ]'      -- 영업조직코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.BRAND_NM      ]'      -- 영업조직명
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.STOR_CD      ]'      -- 점포코드
        ||CHR(13)||CHR(10)||Q'[                  ,  S.STOR_NM       ]'      -- 점포명
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DT      ]'      -- 판매일자
        ||CHR(13)||CHR(10)||Q'[                  ,  FC_GET_WEEK(:PSV_COMP_CD, SD.SALE_DT, :PSV_LANG_CD) AS SALE_DY  ]'                      -- 요일
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_TM      ]'      -- 판매시간
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SEQ          ]'      -- 순번
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  GET_COMMON_CODE_NM(:PSV_COMP_CD, '01935', SD.SALE_DIV, :PSV_LANG_CD) AS SALE_DIV_NM]'   -- 판매구분
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_CD    ]'      -- 대분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  I.L_CLASS_NM    ]'      -- 대분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_CD    ]'      -- 중분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  I.M_CLASS_NM    ]'      -- 중분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_CD    ]'      -- 소분류코드
        ||CHR(13)||CHR(10)||Q'[                  ,  I.S_CLASS_NM    ]'      -- 소분류명
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.ITEM_CD      ]'      -- 상품코드
        ||CHR(13)||CHR(10)||Q'[                  ,  I.ITEM_NM       ]'      -- 상품명
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.FREE_DIV     ]'      -- 무료구분
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.SALE_QTY     ]'      -- 판매수량
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.CERT_NO IS NULL THEN SD.SALE_AMT ELSE SD.GRD_AMT - SD.USE_AMT END AS SALE_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.CERT_NO IS NULL THEN SD.DC_AMT + SD.ENR_AMT ELSE 0 END            AS DC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SD.DC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  D.DC_NM         ]'      -- 할인종류
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.CERT_NO IS NULL THEN SD.GRD_AMT  ELSE SD.GRD_AMT - SD.USE_AMT END AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.CERT_NO IS NULL THEN SD.VAT_AMT  ELSE (SD.GRD_AMT - SD.USE_AMT) - ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END AS VAT_AMT ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SD.CERT_NO IS NULL THEN SD.NET_AMT  ELSE ROUND((SD.GRD_AMT - SD.USE_AMT)/1.1) END                             AS NET_AMT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_DT     SD  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  (       ]'
        ||CHR(13)||CHR(10)||Q'[                         SELECT  D.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  D.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  D.DC_DIV        ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM]'
        ||CHR(13)||CHR(10)||Q'[                           FROM  DC      D       ]'
        ||CHR(13)||CHR(10)||Q'[                              ,  (               ]'
        ||CHR(13)||CHR(10)||Q'[                                     SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                                          ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                                       FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[                                      WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  TABLE_NM    = 'DC'          ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  COL_NM      = 'DC_NM'       ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                                        AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[                                 )       L       ]'
        ||CHR(13)||CHR(10)||Q'[                             WHERE  L.COMP_CD(+) = D.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  L.PK_COL(+)  = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  D.COMP_CD    = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[                               AND  D.BRAND_CD IN ('0000', :PSV_BRAND_CD)   ]'
        ||CHR(13)||CHR(10)||Q'[                     )   D               ]'  
        ||CHR(13)||CHR(10)||Q'[              WHERE  SD.COMP_CD      = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.BRAND_CD     = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.STOR_CD      = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.ITEM_CD      = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = D.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.DC_DIV       = D.DC_DIV(+)   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.COMP_CD      = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_DT      BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (   ]'
        ||CHR(13)||CHR(10)||Q'[                         SD.GIFT_DIV = '1'           ]'                                                              -- 회원권/상품권상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.GIFT_DIV = '0' AND (T_SEQ = '0' OR SD.SUB_ITEM_DIV IN ('2', '3')) AND PROGRAM_ID IS NULL)   ]'  -- 일반상품 판매
        ||CHR(13)||CHR(10)||Q'[                         OR                          ]'
        ||CHR(13)||CHR(10)||Q'[                         (SD.PROGRAM_ID IS NOT NULL AND (SD.CERT_NO IS NULL OR (SD.CERT_NO IS NOT NULL AND SD.GRD_AMT - SD.USE_AMT <> 0))) ]'              -- 서비스상품(개인/단체 입장료,보호자동반, 추가요금 등)  판매
        ||CHR(13)||CHR(10)||Q'[                     )               ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_DSTN_COMP  IS NULL OR S.DSTN_COMP  = :PSV_DSTN_COMP  )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_STOR_TP    IS NULL OR S.STOR_TP    = :PSV_STOR_TP    )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  (:PSV_RENTAL_DIV IS NULL OR S.RENTAL_DIV = :PSV_RENTAL_DIV )  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SD.SALE_AMT <> 0                ]'
        ||CHR(13)||CHR(10)||Q'[         )   A   ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY A.DSTN_COMP, A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SALE_TM, A.SALE_DIV, A.ITEM_CD, A.DC_DIV ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.DSTN_COMP, A.BRAND_CD, A.STOR_CD, A.SALE_DT, A.SALE_TM, A.SALE_DIV, A.ITEM_CD, A.DC_DIV ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        --dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV,
                         PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_BRAND_CD, 
                         PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_DSTN_COMP, PSV_DSTN_COMP, PSV_STOR_TP, PSV_STOR_TP, PSV_RENTAL_DIV, PSV_RENTAL_DIV;
     
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
    
END PKG_SALE1270;

/
