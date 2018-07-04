--------------------------------------------------------
--  DDL for Procedure SP_SALE4330L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE4330L0" -- 딜리버리 메뉴별 판매추이(전)
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR ,  -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
) IS
/******************************************************************************
   NAME:       SP_SALE4330L0    딜리버리 메뉴별 판매 추이
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-02-14                   1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE4330L0
      SYSDATE:         2014-02-14
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_date2    VARCHAR2(1000) ;

    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000) ;    -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000) ;    -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000) ;    -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000) ;    -- 조회일자 제외 (대비)

    ls_from_date1   VARCHAR2(12);       -- 조회일자
    ls_from_date2   VARCHAR2(12);       -- 조회일자
    ls_date_1       VARCHAR2(12);
    ls_date_7       VARCHAR2(12);
    ls_date_364     VARCHAR2(12);

    ls_err_cd       VARCHAR2(7) := '0' ;
    ls_err_msg      VARCHAR2(500) ;

    ERR_HANDLER   EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );

    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' SJ.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND SJ.SALE_DT ' || ls_ex_date1 ;
    END IF;

    ls_sql_main := ''
        || CHR(13) || CHR(10) || Q'[SELECT  SJ.BRAND_CD                         ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(S.BRAND_NM)     AS BRAND_NM     ]'
        || CHR(13) || CHR(10) || Q'[     ,  SJ.STOR_CD                          ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(S.STOR_NM)      AS STOR_NM      ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(I.L_CLASS_NM)   AS L_CLASS_NM   ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(I.M_CLASS_NM)   AS M_CLASS_NM   ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(I.S_CLASS_NM)   AS S_CLASS_NM   ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.ITEM_CD                           ]'
        || CHR(13) || CHR(10) || Q'[     ,  MAX(I.ITEM_NM)      AS ITEM_NM      ]'
        || CHR(13) || CHR(10) ||  '      ,  SUM(SJ.SALE_QTY)                                                                     AS  SALE_QTY  '
        || CHR(13) || CHR(10) ||  '      ,  SUM(DECODE(''' || PSV_FILTER || ''', ''G'', SJ.SALE_AMT, SJ.SALE_AMT - SJ.VAT_AMT))  AS  SALE_AMT  '
        || CHR(13) || CHR(10) ||  '      ,  SUM(SJ.DC_AMT + SJ.ENR_AMT)                                                          AS  DC_AMT    '
        || CHR(13) || CHR(10) ||  '      ,  SUM(DECODE(''' || PSV_FILTER || ''', ''G'', SJ.GRD_AMT , SJ.GRD_AMT  - SJ.VAT_AMT))  AS  GRD_AMT   '
        || CHR(13) || CHR(10) || Q'[  FROM  SALE_JDM    SJ              ]'
        || CHR(13) || CHR(10) || Q'[     ,  S_STORE     S               ]'
        || CHR(13) || CHR(10) || Q'[     ,  S_ITEM      I               ]'
        || CHR(13) || CHR(10) || Q'[ WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        || CHR(13) || CHR(10) || Q'[   AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        || CHR(13) || CHR(10) || Q'[   AND  SJ.STOR_CD  = S.STOR_CD     ]'
        || CHR(13) || CHR(10) || Q'[   AND  SJ.COMP_CD  = I.COMP_CD     ]'
        || CHR(13) || CHR(10) || Q'[   AND  SJ.ITEM_CD  = I.ITEM_CD     ]'
        || CHR(13) || CHR(10) ||  '    AND  SJ.COMP_CD  = ''' || PSV_COMP_CD || ''''
        || CHR(13) || CHR(10) || Q'[   AND  SJ.SALE_TYPE= '2'           ]'
        || CHR(13) || CHR(10) || Q'[   AND ]' || ls_sql_date
        || CHR(13) || CHR(10) || Q'[ GROUP  BY SJ.BRAND_CD              ]'
        || CHR(13) || CHR(10) || Q'[     ,  SJ.STOR_CD                  ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.L_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.M_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.S_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.ITEM_CD                   ]'
        || CHR(13) || CHR(10) || Q'[ ORDER  BY SJ.BRAND_CD              ]'
        || CHR(13) || CHR(10) || Q'[     ,  SJ.STOR_CD                  ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.L_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.M_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.S_CLASS_CD                ]'
        || CHR(13) || CHR(10) || Q'[     ,  I.ITEM_CD                   ]'
     ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR ls_sql;

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
