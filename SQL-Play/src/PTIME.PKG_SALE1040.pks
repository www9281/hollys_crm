CREATE OR REPLACE PACKAGE      PKG_SALE1040 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE1040
   --  Description      : 점포별 영업현황
   -- Ref. Table        :
   ---------------------------------------------------------------------------------------------------

    
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB03
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
    );
    
    
    PROCEDURE SP_TAB04
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
    PROCEDURE SP_TAB05
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
    
END PKG_SALE1040;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1040 AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB01     점포별 영업현황(점포별)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-19         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB01
            SYSDATE     :   2014-08-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BRAND_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.CUST_CNT  ]'                                              -- 객수
        ||CHR(13)||CHR(10)||Q'[      ,  A.CUST_AMT  ]'                                              -- 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN A.SEAT = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND(A.CUST_CNT / A.SEAT, 2) ]'
        ||CHR(13)||CHR(10)||Q'[         END                                     AS ROTATION     ]'  -- 회전율
        ||CHR(13)||CHR(10)||Q'[      ,  A.SEAT      ]'                                              -- 좌석수
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_CNT  ]'                                              -- 영수건수
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_AMT  ]'                                              -- 총매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.DC_AMT    ]'                                              -- 할인
        ||CHR(13)||CHR(10)||Q'[      ,  A.GRD_AMT   ]'                                              -- 실매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.VAT_AMT   ]'                                              -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  A.NET_AMT   ]'                                              -- 순매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.RTN_AMT   ]'                                              -- 취소매출
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_10_AMT + B.PAY_30_AMT, 0)     AS PAY_10_AMT   ]'  -- 현금
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_20_AMT, 0)                    AS PAY_20_AMT   ]'  -- 카드
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_40_AMT, 0)                    AS PAY_40_AMT   ]'  -- 상품권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_50_AMT, 0)                    AS PAY_50_AMT   ]'  -- 식권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_60_AMT, 0)                    AS PAY_60_AMT   ]'  -- 포인트
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_69_AMT, 0)                    AS PAY_69_AMT   ]'  -- 회원권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_6A_AMT, 0)                    AS PAY_6A_AMT   ]'  -- 신세계포인트
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_70_AMT, 0)                    AS PAY_70_AMT   ]'  -- 기프티콘
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7A_AMT, 0)                    AS PAY_7A_AMT   ]'  -- 모바일쿠폰
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7B_AMT, 0)                    AS PAY_7B_AMT   ]'  -- 쿠팡
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7C_AMT, 0)                    AS PAY_7C_AMT   ]'  -- 티몬
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7D_AMT, 0)                    AS PAY_7D_AMT   ]'  -- 네이버페이
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_82_AMT, 0)                    AS PAY_82_AMT   ]'  -- 카카오톡
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_90_AMT, 0)                    AS PAY_90_AMT   ]'  -- 쿠폰
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_91_AMT, 0)                    AS PAY_91_AMT   ]'  -- 위메프
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_92_AMT, 0)                    AS PAY_92_AMT   ]'  -- 외상대
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_93_AMT, 0)                    AS PAY_93_AMT   ]'  -- 미수금
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_A0_AMT, 0)                    AS PAY_A0_AMT   ]'  -- 외상
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)                     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)                      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT) = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE ROUND(SUM(SJ.GRD_AMT - SJ.VAT_AMT) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))    ]'
        ||CHR(13)||CHR(10)||Q'[                     END                                 AS CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(NVL(S.SEAT, 0))                 AS SEAT         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)                    AS BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                    AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)         AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                     AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                     AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)        AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.RTN_AMT)                     AS RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, SJ.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         )   A       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.BRAND_NM)                     AS BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(S.STOR_NM)                      AS STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '10', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_10_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '20', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_20_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '30', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_30_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '40', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_40_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '50', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_50_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '60', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_60_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '69', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_69_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '6A', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_6A_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '70', SJ.PAY_AMT                                  )),0) AS PAY_70_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7A', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7A_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7B', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7B_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7C', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7C_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7D', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7D_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '82', SJ.PAY_AMT                                  )),0) AS PAY_82_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '90', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_90_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '91', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_91_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '92', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_92_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '93', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_93_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, 'A0', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_A0_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, SJ.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         )   B       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = B.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD  = B.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD   = B.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.COMP_CD, A.BRAND_CD, A.STOR_CD ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_TAB02     점포별 영업현황(일자별)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-19         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB02
            SYSDATE     :   2014-08-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(A.SALE_DT, 'YYYYMMDD'), 'YYYY-MM-DD') || ' (' || FC_GET_WEEK(:PSV_COMP_CD, A.SALE_DT, :PSV_LANG_CD) || ')'  AS SALE_DT_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.CUST_CNT  ]'                                              -- 객수
        ||CHR(13)||CHR(10)||Q'[      ,  A.CUST_AMT  ]'                                              -- 객단가
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN A.SEAT = 0 THEN 0     ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE ROUND(A.CUST_CNT / A.SEAT, 2) ]'
        ||CHR(13)||CHR(10)||Q'[         END                                     AS ROTATION     ]'  -- 회전율
        ||CHR(13)||CHR(10)||Q'[      ,  A.SEAT      ]'                                              -- 좌석수
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_CNT  ]'                                              -- 영수건수
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_AMT  ]'                                              -- 총매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.DC_AMT    ]'                                              -- 할인
        ||CHR(13)||CHR(10)||Q'[      ,  A.GRD_AMT   ]'                                              -- 실매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.VAT_AMT   ]'                                              -- 부가세
        ||CHR(13)||CHR(10)||Q'[      ,  A.NET_AMT   ]'                                              -- 순매출
        ||CHR(13)||CHR(10)||Q'[      ,  A.RTN_AMT   ]'                                              -- 취소매출
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_10_AMT + B.PAY_30_AMT, 0)     AS PAY_10_AMT   ]'  -- 현금
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_20_AMT, 0)                    AS PAY_20_AMT   ]'  -- 카드
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_40_AMT, 0)                    AS PAY_40_AMT   ]'  -- 상품권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_50_AMT, 0)                    AS PAY_50_AMT   ]'  -- 식권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_60_AMT, 0)                    AS PAY_60_AMT   ]'  -- 포인트
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_69_AMT, 0)                    AS PAY_69_AMT   ]'  -- 회원권
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_6A_AMT, 0)                    AS PAY_6A_AMT   ]'  -- 신세계포인트
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_70_AMT, 0)                    AS PAY_70_AMT   ]'  -- 기프티콘
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7A_AMT, 0)                    AS PAY_7A_AMT   ]'  -- 모바일쿠폰
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7B_AMT, 0)                    AS PAY_7B_AMT   ]'  -- 쿠팡
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7C_AMT, 0)                    AS PAY_7C_AMT   ]'  -- 티몬
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_7D_AMT, 0)                    AS PAY_7D_AMT   ]'  -- 네이버페이
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_82_AMT, 0)                    AS PAY_82_AMT   ]'  -- 카카오톡
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_90_AMT, 0)                    AS PAY_90_AMT   ]'  -- 쿠폰
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_91_AMT, 0)                    AS PAY_91_AMT   ]'  -- 위메프
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_92_AMT, 0)                    AS PAY_92_AMT   ]'  -- 외상대
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_93_AMT, 0)                    AS PAY_93_AMT   ]'  -- 미수금
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(B.PAY_A0_AMT, 0)                    AS PAY_A0_AMT   ]'  -- 외상
        ||CHR(13)||CHR(10)||Q'[   FROM  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT)    AS CUST_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT) = 0 THEN 0   ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE ROUND(SUM(SJ.GRD_AMT - SJ.VAT_AMT) / SUM(SJ.ETC_M_CNT + SJ.ETC_F_CNT))    ]'
        ||CHR(13)||CHR(10)||Q'[                     END                                 AS CUST_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(NVL(S.SEAT, 0))                 AS SEAT         ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.BILL_CNT)                    AS BILL_CNT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.SALE_AMT)                    AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)         AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT)                     AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.VAT_AMT)                     AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)        AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(SJ.RTN_AMT)                     AS RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   A       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SJ.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SJ.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '10', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_10_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '20', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_20_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '30', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_30_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '40', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_40_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '50', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_50_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '60', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_60_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '69', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_69_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '6A', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_6A_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '70', SJ.PAY_AMT                                  )),0) AS PAY_70_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7A', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7A_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7B', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7B_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7C', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7C_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '7D', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_7D_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '82', SJ.PAY_AMT                                  )),0) AS PAY_82_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '90', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_90_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '91', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_91_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '92', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_92_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, '93', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_93_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(SUM(DECODE(SJ.PAY_DIV, 'A0', SJ.PAY_AMT - (SJ.CHANGE_AMT + SJ.REMAIN_AMT))),0) AS PAY_A0_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_JDP    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY SJ.COMP_CD, SJ.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[         )   B       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD   = B.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DT   = B.SALE_DT(+)  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.COMP_CD, A.SALE_DT ]'
        ;
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
    PROCEDURE SP_TAB03
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
        NAME:       SP_TAB03     점포별 영업현황(상품별)
        PURPOSE:
    
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2014-08-19         1. CREATED THIS PROCEDURE.
    
        NOTES:
            OBJECT NAME :   SP_TAB03
            SYSDATE     :   2014-08-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  MAX(I.L_CLASS_NM)               AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)               AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)               AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.ITEM_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)                  AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_QTY)                AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.SALE_AMT)                AS SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)     AS DC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT)                 AS GRD_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.GRD_AMT - SJ.VAT_AMT)    AS NET_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.VAT_AMT)                 AS VAT_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDM    SJ  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD, SJ.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(L_SORT_ORDER), I.L_CLASS_CD, MAX(M_SORT_ORDER), I.M_CLASS_CD, MAX(S_SORT_ORDER), I.S_CLASS_CD, SJ.ITEM_CD]'
        ;
        
        ls_sql := ls_sql_with || ls_sql_main;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
    PROCEDURE SP_TAB04
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB04     점포별 영업현황(매장별 시간대)
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB04
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            TIME_DIV        VARCHAR2(2)
        ,   TIME_DIV_NM     VARCHAR2(20)
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
    ls_sql_main         VARCHAR2(30000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_time         VARCHAR2(1000) ;
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
    
    ls_sql_cm_01530 VARCHAR2(1000) ;    -- 공통코드SQL
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER
                          , ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2);
    
        ls_sql_with := ' WITH  '
                    ||  ls_sql_store -- S_STORE
                    --||  ', '
                    --||  ls_sql_item  -- S_ITEM
                    ;
               
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_01530 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01530') ;
        -------------------------------------------------------------------------------
        
        -- 조회시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  C.CODE_CD       AS TIME_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS TIME_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_01530 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    ]' || ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY C.CODE_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY C.CODE_CD    ]';
    
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
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]';
        
        V_HD2 := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'BRAND_CD')     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_CD')      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'STOR_NM')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).TIME_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*4);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_CNT')     || Q'[' AS CT]' || TO_CHAR(i*4 - 3);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*4 - 2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_CNT')     || Q'[' AS CT]' || TO_CHAR(i*4 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'CUST_AMT')     || Q'[' AS CT]' || TO_CHAR(i*4);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || CHR(13) || CHR(10) || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.BRAND_NM)     AS BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)      AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD           AS TIME_DIV ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(SH.SALE_DIV, '1', 1, -1))    AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', (SH.GRD_I_AMT + SH.GRD_O_AMT), 'T', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT)))   AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SH.CUST_M_CNT + SH.CUST_F_CNT)      AS CUST_CNT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(SUM(SH.CUST_M_CNT + SH.CUST_F_CNT), 0, 0, SUM(DECODE(:PSV_FILTER, 'G', (SH.GRD_I_AMT + SH.GRD_O_AMT), 'T', SH.SALE_AMT, (SH.GRD_I_AMT + SH.GRD_O_AMT) - (SH.VAT_I_AMT + SH.VAT_O_AMT))) / SUM(SH.CUST_M_CNT + SH.CUST_F_CNT))    AS CUST_AMT ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_01530 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SH.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    ]' || ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SH.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD       ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(BILL_CNT)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_CNT)   AS VCOL3 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(CUST_AMT)   AS VCOL4 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (TIME_DIV) IN    ]'
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
                     , PSV_COMP_CD, PSV_LANG_CD;
                     
        OPEN PR_RESULT FOR
            V_SQL USING PSV_FILTER, PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
    PROCEDURE SP_TAB05
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
        PSV_FR_TM       IN  VARCHAR2 ,                -- 조회시작시간
        PSV_TO_TM       IN  VARCHAR2 ,                -- 조회종료시간
        PR_HEADER       IN  OUT PKG_REPORT.REF_CUR ,  -- 헤더문자열
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_TAB05     점포별 영업현황(상품별 시간대)
       PURPOSE:
    
       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.
    
       NOTES:
    
          OBJECT NAME:     SP_TAB05
          SYSDATE:         2016-01-20
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
    TYPE  rec_ct_hd IS RECORD
    (
            TIME_DIV        VARCHAR2(2)
        ,   TIME_DIV_NM     VARCHAR2(20)
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
    ls_sql_main         VARCHAR2(30000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_time         VARCHAR2(1000) ;
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
    
    ls_sql_cm_01530 VARCHAR2(1000) ;    -- 공통코드SQL
    
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
        ls_sql_cm_01530 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '01530') ;
        -------------------------------------------------------------------------------
        
        -- 조회시간 처리
        IF PSV_FR_TM IS NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) <= '''||PSV_TO_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) >= '''||PSV_FR_TM||'''';
        ELSIF PSV_FR_TM IS NOT NULL AND PSV_TO_TM IS NOT NULL THEN
            ls_sql_time :=  '   AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN '''||PSV_FR_TM||''' AND '''||PSV_TO_TM||'''';
        END IF;
        
        /* 가로축 데이타 FETCH */
        ls_sql_tab_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  C.CODE_CD       AS TIME_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(C.CODE_NM)  AS TIME_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_01530 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    ]' || ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY C.CODE_CD    ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY C.CODE_CD    ]';
    
        ls_sql := ls_sql_with || ls_sql_tab_main ;
        dbms_output.put_line(ls_sql) ;
    
        EXECUTE IMMEDIATE ls_sql BULK COLLECT INTO qry_hd USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
    
        IF SQL%ROWCOUNT = 0  THEN
            ls_err_cd  := '4000100' ;
            ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd) ;
            RAISE ERR_HANDLER ;
        END IF ;
    
        V_HD1 := ''
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
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]';
        
        V_HD2 := ''
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
        ||CHR(13)||CHR(10)||Q'[      ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'ITEM_NM')      ]';
    
        FOR i IN qry_hd.FIRST..qry_hd.LAST
        LOOP
            BEGIN
                IF i > 1 THEN
                    V_CROSSTAB := V_CROSSTAB || CHR(13)||CHR(10)||Q'[, ]';
                END IF;
                
                V_CROSSTAB := V_CROSSTAB  || Q'[']'  || qry_hd(i).TIME_DIV || Q'[']';
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD1 := V_HD1 || CHR(13) || CHR(10) || Q'[      ,  ']' || qry_hd(i).TIME_DIV_NM  || Q'[' AS CT]' || TO_CHAR(i*2);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'QTY')          || Q'[' AS CT]' || TO_CHAR(i*2 - 1);
                V_HD2 := V_HD2 || CHR(13) || CHR(10) || Q'[      ,  ']' || FC_GET_WORDPACK(PSV_COMP_CD, PSV_LANG_CD, 'BILL_GRD_AMT') || Q'[' AS CT]' || TO_CHAR(i*2);
            END;
        END LOOP;
    
        V_HD1 :=  V_HD1 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD2 :=  V_HD2 || CHR(13) || CHR(10) || Q'[ FROM DUAL ]';
        V_HD   := V_HD1 || CHR(13) || CHR(10) || Q'[ UNION ALL ]' || CHR(13) || CHR(10) || V_HD2;
        
        /* MAIN SQL */
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  I.L_CLASS_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.L_SORT_ORDER) AS L_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.M_SORT_ORDER) AS M_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD                        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.S_SORT_ORDER) AS S_SORT_ORDER ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.ITEM_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(I.ITEM_NM)      AS ITEM_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD           AS TIME_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SD.SALE_QTY)    AS SALE_QTY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'G', (SD.GRD_AMT), 'T', SD.SALE_AMT, (SD.GRD_AMT) - (SD.VAT_AMT)))  AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_DT     SD  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_01530 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SD.COMP_CD  = S.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.BRAND_CD = S.BRAND_CD]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.STOR_CD  = S.STOR_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = C.COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SUBSTR(SD.SALE_TM, 0, 4) BETWEEN C.VAL_C1 AND C.VAL_C2  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    ]' || ls_sql_time
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY I.L_CLASS_CD ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.M_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.S_CLASS_CD    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.ITEM_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CODE_CD       ]';
    
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
        ||CHR(13)||CHR(10)||Q'[       SUM(SALE_QTY)   AS VCOL1 ]'
        ||CHR(13)||CHR(10)||Q'[     , SUM(GRD_AMT)    AS VCOL2 ]'
        ||CHR(13)||CHR(10)||Q'[     FOR (TIME_DIV) IN    ]'
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
            V_SQL USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;
     
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
    
END PKG_SALE1040;

/
