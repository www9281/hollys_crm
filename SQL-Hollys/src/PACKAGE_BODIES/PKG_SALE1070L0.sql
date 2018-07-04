--------------------------------------------------------
--  DDL for Package Body PKG_SALE1070L0
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_SALE1070L0" AS
    PROCEDURE SP_SALE1070   /* 식권매출현황 */
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_COUPON_CD   IN  VARCHAR2 ,                -- 식권코드
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE1070       식권매출현황
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-10-22         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE1070
          SYSDATE:         2014-10-22
          USERNAME:
          TABLE NAME:
    ******************************************************************************/

    ls_sql          VARCHAR2(30000) ;
    ls_sql_with     VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(10000) ;
    ls_sql_date     VARCHAR2(1000) ;
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

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );



    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' SS.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SS.SALE_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    ls_sql_with := ' WITH  '
           ||  ls_sql_store -- S_STORE
--           ||  ', '
--           ||  ls_sql_item  -- S_ITEM
           ;

    /* MAIN SQL */
    ls_sql_main :=  
      chr(13)||chr(10)||q'[SELECT  SS.APPR_MAEIP_CD    AS COUPON_CD ]' /* 식권코드 */
    ||chr(13)||chr(10)||q'[     ,  MAX(C.CODE_NM)      AS COUPON_NM ]' /* 식권명 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '1', ALLOT_LMT, 0)) AS S_CNT     ]' /* 정상건수 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '1', PAY_AMT, 0))   AS S_AMT     ]' /* 정상금액 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '2', ALLOT_LMT, 0)) AS R_CNT     ]' /* 반품건수 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '2', PAY_AMT, 0))   AS R_AMT     ]' /* 반품금액 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '1', ALLOT_LMT, 0)) - SUM(DECODE(SS.SALE_DIV, '2', ALLOT_LMT, 0))   AS T_CNT ]' /* 합계건수 */
    ||chr(13)||chr(10)||q'[     ,  SUM(DECODE(SS.SALE_DIV, '1', PAY_AMT, 0)) + SUM(DECODE(SS.SALE_DIV, '2', PAY_AMT, 0))       AS T_AMT ]' /* 합계금액 */
    ||chr(13)||chr(10)||q'[  FROM  SALE_ST  SS  ]'
    ||chr(13)||chr(10)||q'[     ,  S_STORE  S   ]'
    ||chr(13)||chr(10)||q'[     ,  (            ]'
    ||chr(13)||chr(10)||q'[             SELECT  C.COMP_CD   ]'
    ||chr(13)||chr(10)||q'[                  ,  C.CODE_CD   ]'
    ||chr(13)||chr(10)||q'[                  ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  ]'
    ||chr(13)||chr(10)||q'[               FROM  COMMON  C   ]'
    ||chr(13)||chr(10)||q'[                  ,  (           ]'
    ||chr(13)||chr(10)||q'[                         SELECT  COMP_CD ]'
    ||chr(13)||chr(10)||q'[                              ,  CODE_CD ]'
    ||chr(13)||chr(10)||q'[                              ,  CODE_NM ]'
    ||chr(13)||chr(10)||q'[                           FROM  LANG_COMMON ]'
    ||chr(13)||chr(10)||q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||q'[                            AND  CODE_TP     = '01155'       ]'
    ||chr(13)||chr(10)||q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||q'[                            AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||q'[                     )       L   ]'
    ||chr(13)||chr(10)||q'[              WHERE  C.COMP_CD   = L.COMP_CD(+)  ]'
    ||chr(13)||chr(10)||q'[                AND  C.CODE_CD   = L.CODE_CD(+)  ]'
    ||chr(13)||chr(10)||q'[                AND  C.COMP_CD   = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||q'[                AND  C.CODE_TP   = '01155'       ]'
    ||chr(13)||chr(10)||q'[         )       C   ]'
    ||chr(13)||chr(10)||q'[     WHERE  SS.COMP_CD  = S.COMP_CD      ]'
    ||chr(13)||chr(10)||q'[       AND  SS.BRAND_CD = S.BRAND_CD     ]'
    ||chr(13)||chr(10)||q'[       AND  SS.STOR_CD  = S.STOR_CD      ]'
    ||chr(13)||chr(10)||q'[       AND  SS.COMP_CD  = C.COMP_CD      ]'
    ||chr(13)||chr(10)||q'[       AND  SS.APPR_MAEIP_CD = C.CODE_CD ]'
    ||chr(13)||chr(10)||q'[       AND  SS.COMP_CD  = :PSV_COMP_CD   ]'
    ||chr(13)||chr(10)||q'[       AND  ]' || ls_sql_date
    ||chr(13)||chr(10)||q'[       AND  SS.PAY_DIV  = '50'           ]'
    ||chr(13)||chr(10)||q'[       AND  (:PSV_COUPON_CD IS NULL OR SS.APPR_MAEIP_CD = :PSV_COUPON_CD)    ]'
    ||chr(13)||chr(10)||q'[     GROUP  BY SS.APPR_MAEIP_CD          ]'
    ||chr(13)||chr(10)||q'[     ORDER  BY MAX(C.CODE_NM)            ]'
    ;

    ls_sql := ls_sql_with || ls_sql_main ;

    dbms_output.put_line( ls_sql ) ;


    OPEN PR_RESULT FOR
      ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_COMP_CD, PSV_COUPON_CD, PSV_COUPON_CD;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg ;

EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
    WHEN OTHERS THEN
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
END ;

END PKG_SALE1070L0;

/
