--------------------------------------------------------
--  DDL for Procedure SP_SALE1140L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE1140L0" /* 결제수단별 상세(Sales) 매출현황 */
(   
  PSV_COMP_CD     IN  VARCHAR2 ,                -- Company Code
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_PAY_DIV     IN  VARCHAR2 ,                -- 결제수단
  PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드 
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message 
)    
IS       
/******************************************************************************
   NAME:       SP_SALE1140L0   결제수단별 상세(Sales) 매출현황
   PURPOSE:    

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-03-13         1. CREATED THIS PROCEDURE.

   NOTES: 

      OBJECT NAME:     SP_SALE1140L0
      SYSDATE:          
      USERNAME:        
      TABLE NAME:       
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_date2    VARCHAR2(1000) ;
    ls_ymd_date     VARCHAR2(1000) ;
    ls_ymd_date2    VARCHAR2(1000) ;
    ls_sql_store    VARCHAR2(20000) ;   -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000) ;   -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ; 

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER, PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

    ls_sql := ' WITH  '
           ||  ls_sql_store; -- S_STORE

    -- 조회기간 처리--------------------------------------------------------------- 
    ls_sql_date := ' SS.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SS.SALE_DT ' || ls_ex_date1 ;
    END IF;            

    ls_sql_main :=      Q'[  SELECT  BRAND_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_CD  ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_NM  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  CNT ]'
    ||chr(13)||chr(10)||Q'[       ,  AMT ]'
    ||chr(13)||chr(10)||Q'[    FROM  ( ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 현금 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  '10'                AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_10_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''                  AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''                  AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.PAY_DIV <> '40' THEN SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT) ELSE -1*(SS.CHANGE_AMT + SS.REMAIN_AMT) END) AS AMT]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST SS                  ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  IN ('10', '30', '40') ]'
    ||chr(13)||chr(10)||Q'[                AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV  IS NULL OR SS.PAY_DIV  = :PSV_PAY_DIV)  ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD              ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  COMP_CD             ]'                  -- 카드 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  BRAND_CD            ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(BRAND_NM)   AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  STOR_CD             ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(STOR_NM)    AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DIV         AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DIV_NM) AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DTL_CD      AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DTL_NM) AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CNT)        AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(AMT)        AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  (   ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  SS.COMP_CD          ]'                  -- 카드 결제수단 매출
    ||chr(13)||chr(10)||Q'[                              ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.BRAND_NM          ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.STOR_NM           ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.PAY_DIV          ]'
    ||chr(13)||chr(10)||Q'[                              ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_20_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN NVL(SF.STOR_DT_CD, '06') = '05' THEN '99'  ]'
    ||chr(13)||chr(10)||Q'[                                      ELSE SS.APPR_MAEIP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                 END AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN NVL(SF.STOR_DT_CD, '06') = '05' THEN ''  ]'
    ||chr(13)||chr(10)||Q'[                                      ELSE C.CARD_NM ]'
    ||chr(13)||chr(10)||Q'[                                 END AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END  AS CNT  ]'
    ||chr(13)||chr(10)||Q'[                              ,  SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT)    AS AMT  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  SALE_ST     SS  ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_STORE     S   ]'
    ||chr(13)||chr(10)||Q'[                              ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.CARD_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  NVL(L.LANG_NM, C.CARD_NM)   AS CARD_NM  ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  CARD        C   ]'
    ||chr(13)||chr(10)||Q'[                                          ,  LANG_TABLE  L   ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  LPAD(C.VAN_CD,2,' ')  || LPAD(C.CARD_CD,10,' ') = L.PK_COL(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.TABLE_NM(+) = 'CARD' ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.COL_NM(+) = 'CARD_NM' ]'
    ||chr(13)||chr(10)||Q'[                                        AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                                 )           C  ]'
    ||chr(13)||chr(10)||Q'[                              ,  STORE_FLAG  SF ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = C.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.APPR_MAEIP_CD = C.CARD_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = SF.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.BRAND_CD = SF.BRAND_CD(+)]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.STOR_CD  = SF.STOR_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SS.PAY_DIV  = '20' ]'
    ||chr(13)||chr(10)||Q'[                            AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                            AND  (:PSV_PAY_DIV  IS NULL OR SS.PAY_DIV  = :PSV_PAY_DIV ) ]'
    ||chr(13)||chr(10)||Q'[                            AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SF.STOR_FG(+) = '01']'
    ||chr(13)||chr(10)||Q'[                            AND  SF.USE_YN(+)  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )   ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY COMP_CD, BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD  ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 상품권 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_40_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.APPR_MAEIP_CD    AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(G.GIFT_NM)      AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SS.PAY_AMT)     AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  G.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  G.GIFT_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.LANG_NM, G.GIFT_NM)   AS GIFT_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  GIFT_CODE_MST   G ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_TABLE  L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  G.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  LPAD(G.GIFT_CD, 2, ' ') = L.PK_COL(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  G.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  G.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.TABLE_NM(+) = 'GIFT_CODE_MST' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.COL_NM(+) = 'GIFT_NM' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           G  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = G.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.APPR_MAEIP_CD = G.GIFT_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = '40' ]'
    ||chr(13)||chr(10)||Q'[                AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV  IS NULL OR SS.PAY_DIV  = :PSV_PAY_DIV ) ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV, SS.APPR_MAEIP_CD ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 식권 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'PAY_50_AMT')   AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.APPR_MAEIP_CD    AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(C.CODE_NM)      AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)         AS CNT          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT))           AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  COMMON      C   ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_COMMON L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP = L.CODE_TP(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_CD = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP   = '01155' ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           C  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = C.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.APPR_MAEIP_CD = C.CODE_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = '50' ]'
    ||chr(13)||chr(10)||Q'[                AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV  IS NULL OR SS.PAY_DIV  = :PSV_PAY_DIV ) ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV, SS.APPR_MAEIP_CD ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SS.COMP_CD          ]'                  -- 현금, 카드, 상품권, 식권을 제외한 결제수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SS.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  SS.PAY_DIV          AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(C.CODE_NM)  AS PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''              AS PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[                  ,  ''              AS PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN SS.SALE_DIV = '1' THEN 1 ELSE -1 END)     AS CNT  ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(CASE WHEN PAY_DIV IN ('70', '82') THEN SS.PAY_AMT ]'
    ||chr(13)||chr(10)||Q'[                              ELSE SS.PAY_AMT - (SS.CHANGE_AMT + SS.REMAIN_AMT) ]'
    ||chr(13)||chr(10)||Q'[                         END)        AS AMT  ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_ST     SS ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE     S  ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  COMMON      C   ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_COMMON L   ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  C.COMP_CD = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP = L.CODE_TP(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_CD = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.COMP_CD = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.CODE_TP   = '00490' ]'
    ||chr(13)||chr(10)||Q'[                            AND  C.USE_YN  = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.LANGUAGE_TP(+) = :PSV_LANG_CD ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.USE_YN(+) = 'Y' ]'
    ||chr(13)||chr(10)||Q'[                     )           C  ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SS.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = C.COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  = C.CODE_CD ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  SS.PAY_DIV  NOT IN ('10', '20', '30', '40', '50') ]'
    ||chr(13)||chr(10)||Q'[                AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_PAY_DIV  IS NULL OR SS.PAY_DIV  = :PSV_PAY_DIV ) ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_GIFT_DIV IS NULL OR SS.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY SS.COMP_CD, SS.BRAND_CD, SS.STOR_CD, SS.PAY_DIV ]'
    ||chr(13)||chr(10)||Q'[          ) ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD]';

    ls_sql := ls_sql || ls_sql_main ;  
    dbms_output.put_line(ls_sql) ;
    OPEN PR_RESULT FOR
       ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_PAY_DIV, PSV_PAY_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_PAY_DIV, PSV_PAY_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_PAY_DIV, PSV_PAY_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_PAY_DIV, PSV_PAY_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_PAY_DIV, PSV_PAY_DIV, PSV_GIFT_DIV, PSV_GIFT_DIV;


    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

EXCEPTION
    WHEN ERR_HANDLER THEN 
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
       dbms_output.put_line( PR_RTN_MSG ) ;       
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( PR_RTN_MSG ) ;
END ;

/
