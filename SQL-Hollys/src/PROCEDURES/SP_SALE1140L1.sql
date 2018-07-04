--------------------------------------------------------
--  DDL for Procedure SP_SALE1140L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE1140L1" /* 결제수단별 상세(Non Sales) 매출현황 */
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
   NAME:       SP_SALE1140L1   결제수단별 상세(Non Sales) 매출현황
   PURPOSE:    

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-03-13         1. CREATED THIS PROCEDURE.

   NOTES: 

      OBJECT NAME:     SP_SALE1140L1
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
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
    ;

    -- 조회기간 처리--------------------------------------------------------------- 
    ls_sql_date := ' SD.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SD.SALE_DT ' || ls_ex_date1 ;
    END IF;            

    ls_sql_main :=      Q'[  SELECT  BRAND_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  BRAND_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_CD  ]'
    ||chr(13)||chr(10)||Q'[       ,  STOR_NM  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DIV_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[       ,  PAY_DTL_NM ]'
    ||chr(13)||chr(10)||Q'[       ,  QTY ]'
    ||chr(13)||chr(10)||Q'[       ,  AMT ]'
    ||chr(13)||chr(10)||Q'[    FROM  ( ]'
    ||chr(13)||chr(10)||Q'[             SELECT  SD.COMP_CD          ]'                  -- 할인수단 매출
    ||chr(13)||chr(10)||Q'[                  ,  SD.BRAND_CD         ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  SD.STOR_CD          ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  '10'                AS PAY_DIV      ]'
    ||chr(13)||chr(10)||Q'[                  ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'DC')           AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  TO_CHAR(SD.DC_DIV)  AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(D.DC_NM)        AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SD.SALE_QTY)    AS QTY          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(SD.DC_AMT + SD.ENR_AMT)      AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  SALE_JDD  SD                ]'
    ||chr(13)||chr(10)||Q'[                  ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[                  ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  D.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                              ,  D.BRAND_CD      ]'
    ||chr(13)||chr(10)||Q'[                              ,  D.DC_DIV        ]'
    ||chr(13)||chr(10)||Q'[                              ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM]'
    ||chr(13)||chr(10)||Q'[                           FROM  DC      D       ]'
    ||chr(13)||chr(10)||Q'[                              ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                                          ,  PK_COL      ]'
    ||chr(13)||chr(10)||Q'[                                          ,  LANG_NM     ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  LANG_TABLE  ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                        AND  TABLE_NM    = 'DC'          ]'
    ||chr(13)||chr(10)||Q'[                                        AND  COL_NM      = 'DC_NM'       ]'
    ||chr(13)||chr(10)||Q'[                                        AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||Q'[                                        AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||Q'[                                 )       L       ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  L.COMP_CD(+) = D.COMP_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  L.PK_COL(+)  = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ') ]'
    ||chr(13)||chr(10)||Q'[                            AND  D.COMP_CD    = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                     )           D               ]'
    ||chr(13)||chr(10)||Q'[              WHERE  SD.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.COMP_CD  = D.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.BRAND_CD = D.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.DC_DIV   = D.DC_DIV      ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SD.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[                AND  SD.FREE_DIV = '0'           ]'
    ||chr(13)||chr(10)||Q'[                AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[              GROUP  BY SD.COMP_CD, SD.BRAND_CD, SD.STOR_CD, SD.DC_DIV   ]'
    ||chr(13)||chr(10)||Q'[             UNION ALL   ]'
    ||chr(13)||chr(10)||Q'[             SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                  ,  BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(BRAND_NM)       AS BRAND_NM     ]'
    ||chr(13)||chr(10)||Q'[                  ,  STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(STOR_NM)        AS STOR_NM      ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DIV     ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DIV_NM)     AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  PAY_DTL_CD  ]'
    ||chr(13)||chr(10)||Q'[                  ,  MAX(PAY_DTL_NM)     AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(QTY)            AS QTY          ]'
    ||chr(13)||chr(10)||Q'[                  ,  SUM(AMT)            AS AMT          ]'
    ||chr(13)||chr(10)||Q'[               FROM  (           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  SD.COMP_CD      ]'                  -- 서비스 매출
    ||chr(13)||chr(10)||Q'[                              ,  SD.BRAND_CD     ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.BRAND_NM      ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.STOR_CD      ]'
    ||chr(13)||chr(10)||Q'[                              ,  S.STOR_NM       ]'
    ||chr(13)||chr(10)||Q'[                              ,  '20'            AS PAY_DIV  ]'
    ||chr(13)||chr(10)||Q'[                              ,  FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'SERVICE')  AS PAY_DIV_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.FREE_DIV     AS PAY_DTL_CD   ]'
    ||chr(13)||chr(10)||Q'[                              ,  C.CODE_NM       AS PAY_DTL_NM   ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.SALE_QTY     AS QTY  ]'
    ||chr(13)||chr(10)||Q'[                              ,  SD.SALE_AMT     AS AMT  ]'
    ||chr(13)||chr(10)||Q'[                           FROM  SALE_JDD  SD                ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_STORE   S                 ]'
    ||chr(13)||chr(10)||Q'[                              ,  S_ITEM    I                 ]'
    ||chr(13)||chr(10)||Q'[                              ,  (                           ]'
    ||chr(13)||chr(10)||Q'[                                     SELECT  C.COMP_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.CODE_CD       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  NVL(L.CODE_NM, C.CODE_NM) AS CODE_NM    ]'
    ||chr(13)||chr(10)||Q'[                                          ,  C.VAL_C1        ]'
    ||chr(13)||chr(10)||Q'[                                       FROM  COMMON  C       ]'
    ||chr(13)||chr(10)||Q'[                                          ,  (               ]'
    ||chr(13)||chr(10)||Q'[                                                 SELECT  COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                                                      ,  CODE_CD     ]'
    ||chr(13)||chr(10)||Q'[                                                      ,  CODE_NM     ]'
    ||chr(13)||chr(10)||Q'[                                                   FROM  LANG_COMMON ]'
    ||chr(13)||chr(10)||Q'[                                                  WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  CODE_TP     = '00460'       ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||Q'[                                                    AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||Q'[                                             )       L       ]'
    ||chr(13)||chr(10)||Q'[                                      WHERE  C.COMP_CD   = L.COMP_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.CODE_CD   = L.CODE_CD(+) ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.COMP_CD   = :PSV_COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                                        AND  C.CODE_TP   = '00460'      ]'
    ||chr(13)||chr(10)||Q'[                                 )           C               ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  SD.COMP_CD  = S.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.BRAND_CD = S.BRAND_CD    ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.STOR_CD  = S.STOR_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = I.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.ITEM_CD  = I.ITEM_CD     ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = C.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.FREE_DIV = C.CODE_CD(+)  ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.COMP_CD  = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND (:PSV_GIFT_DIV IS NULL OR SD.GIFT_DIV = :PSV_GIFT_DIV) ]'
    ||chr(13)||chr(10)||Q'[                            AND  SD.FREE_DIV NOT IN ('0', '1', '9', '10') ]'
    ||chr(13)||chr(10)||Q'[                            AND ]' || ls_sql_date
    ||chr(13)||chr(10)||Q'[                     )          ]'
    ||chr(13)||chr(10)||Q'[              GROUP  BY COMP_CD, BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD ]'
    ||chr(13)||chr(10)||Q'[          ) ]'
    ||chr(13)||chr(10)||Q'[   ORDER  BY BRAND_CD, STOR_CD, PAY_DIV, PAY_DTL_CD]';

    ls_sql := ls_sql || ls_sql_main ;  
    dbms_output.put_line(ls_sql) ;
    OPEN PR_RESULT FOR
       ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_GIFT_DIV, PSV_GIFT_DIV,
                    PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_GIFT_DIV, PSV_GIFT_DIV;


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
