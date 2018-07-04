--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_CUST_POP_PAGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_CUST_POP_PAGE" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-10-31
-- Description    :    마켓팅 목록 내 고객 조회
-- Test            :    exec MARKETING_GP_CUST_POP_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_CUST_GP_ID    IN   VARCHAR2,
        N_BRAND_CD      IN   VARCHAR2,
        P_ROWS          IN   VARCHAR2,
        P_PAGE          IN   VARCHAR2,
        O_CURSOR        OUT PKG_REPORT.REF_CUR
) IS
    
    ls_sql        VARCHAR2(32000) ;
    
    ERR_HANDLER   EXCEPTION;
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    TMP           SYS_REFCURSOR;
    
BEGIN   

    ls_sql := '' 
    ||CHR(13)||CHR(10)||Q'[ SELECT        ]'
    ||CHR(13)||CHR(10)||Q'[        NO            ]'
    ||CHR(13)||CHR(10)||Q'[      , PAGE          ]'
    ||CHR(13)||CHR(10)||Q'[      , PAGECNT       ]'
    ||CHR(13)||CHR(10)||Q'[      , TOTAL         ]'
    ||CHR(13)||CHR(10)||Q'[      , DECRYPT(Y.CUST_NM)    AS CUST_NM                                     ]'
    ||CHR(13)||CHR(10)||Q'[      , CUST_ID       ]'
    ||CHR(13)||CHR(10)||Q'[      , CUST_WEB_ID   ]'
    ||CHR(13)||CHR(10)||Q'[      , FN_GET_FORMAT_HP_NO(DECRYPT(Y.MOBILE))     AS MOBILE                 ]'
    ||CHR(13)||CHR(10)||Q'[      , CARD_ID       ]'
    ||CHR(13)||CHR(10)||Q'[      , BIRTH_DT      ]'
    ||CHR(13)||CHR(10)||Q'[      , GET_COMMON_CODE_NM('00315', Y.SEX_DIV, 'KOR') AS SEX_DIV             ]'
    ||CHR(13)||CHR(10)||Q'[     FROM(            ]'
    ||CHR(13)||CHR(10)||Q'[         SELECT       ]'
    ||CHR(13)||CHR(10)||Q'[                COUNT(*) OVER()  - ROWNUM + 1 AS NO                          ]'
    ||CHR(13)||CHR(10)||Q'[              , FLOOR((ROWNUM-1)/ TO_NUMBER(]' || P_ROWS || Q'[) +1)          AS PAGE     ]'
    ||CHR(13)||CHR(10)||Q'[              , FLOOR((COUNT(*) OVER()-1)/ TO_NUMBER(]' || P_ROWS || Q'[) +1) AS PAGECNT  ]'
    ||CHR(13)||CHR(10)||Q'[              , COUNT(*) OVER() AS TOTAL                                                  ]'
    ||CHR(13)||CHR(10)||Q'[              , CUST_NM       ]'
    ||CHR(13)||CHR(10)||Q'[              , CUST_ID       ]'
    ||CHR(13)||CHR(10)||Q'[              , CUST_WEB_ID   ]'
    ||CHR(13)||CHR(10)||Q'[              , MOBILE        ]'
    ||CHR(13)||CHR(10)||Q'[              , CARD_ID       ]'
    ||CHR(13)||CHR(10)||Q'[              , BIRTH_DT      ]'
    ||CHR(13)||CHR(10)||Q'[              , SEX_DIV       ]'
    ||CHR(13)||CHR(10)||Q'[         FROM                 ]'
    ||CHR(13)||CHR(10)||Q'[         (                    ]'
    ||CHR(13)||CHR(10)||Q'[             SELECT  /*+ INDEX(D C_CARD_INDEX1) */ ]'
    ||CHR(13)||CHR(10)||Q'[                     B.CUST_NM      ]'
    ||CHR(13)||CHR(10)||Q'[                   , B.CUST_ID      ]'
    ||CHR(13)||CHR(10)||Q'[                   , B.CUST_WEB_ID  ]'
    ||CHR(13)||CHR(10)||Q'[                   , B.MOBILE       ]'
    ||CHR(13)||CHR(10)||Q'[                   , D.CARD_ID      ]'
    ||CHR(13)||CHR(10)||Q'[                   , B.BIRTH_DT     ]'
    ||CHR(13)||CHR(10)||Q'[                   , B.SEX_DIV              ]'
    ||CHR(13)||CHR(10)||Q'[             FROM    MARKETING_GP_CUST A    ]'
    ||CHR(13)||CHR(10)||Q'[             JOIN    C_CUST B               ]'
    ||CHR(13)||CHR(10)||Q'[             ON      A.CUST_ID = B.CUST_ID  ]'
    ||CHR(13)||CHR(10)||Q'[             JOIN    C_CARD D               ]'
    ||CHR(13)||CHR(10)||Q'[             ON      B.CUST_ID = D.CUST_ID  ]'
    ||CHR(13)||CHR(10)||Q'[             WHERE   A.CUST_GP_ID IN (]' || P_CUST_GP_ID || Q'[)                                       ]'
    ||CHR(13)||CHR(10)||Q'[             AND     (TRIM(]' || N_BRAND_CD || Q'[) IS NULL OR B.BRAND_CD = ]' || N_BRAND_CD || Q'[)   ]'    
    ||CHR(13)||CHR(10)||Q'[             AND     B.USE_YN       = D.USE_YN   ]'
    ||CHR(13)||CHR(10)||Q'[             AND     B.USE_YN       = 'Y'        ]'
    ||CHR(13)||CHR(10)||Q'[             AND     D.CARD_STAT    = '10'       ]'
    ||CHR(13)||CHR(10)||Q'[             AND     D.REP_CARD_YN  = 'Y'        ]'
    ||CHR(13)||CHR(10)||Q'[             AND     B.COMP_CD      = D.COMP_CD  ]'
    ||CHR(13)||CHR(10)||Q'[             AND     B.COMP_CD      = '016'      ]'
    ||CHR(13)||CHR(10)||Q'[             AND     ( DECRYPT(D.CARD_ID) LIKE '2012%' OR DECRYPT(D.CARD_ID) LIKE '1998%' )            ]'
    ||CHR(13)||CHR(10)||Q'[             ORDER BY    B.CUST_ID           ]'
    ||CHR(13)||CHR(10)||Q'[         )X                                      ]'
    ||CHR(13)||CHR(10)||Q'[     )Y WHERE PAGE = TO_NUMBER(]' || P_PAGE || Q'[)]'
    ;
    
    dbms_output.put_line(ls_sql) ;
    
    OPEN O_CURSOR FOR
            ls_sql ;

    EXCEPTION
        WHEN ERR_HANDLER THEN
        RETURN;
           
        WHEN OTHERS THEN
        RETURN;
   
END MARKETING_GP_CUST_POP_PAGE;

/
