--------------------------------------------------------
--  DDL for Procedure SP_SALE1030L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE1030L0" /* 인증번호 로그 조회 */
(
  PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
  PSV_USE_STAT    IN  VARCHAR2 ,                -- 사용상태
  PSV_DC_TXT      IN  VARCHAR2 ,                -- 할인코드/명
  PSV_CERT_NO     IN  VARCHAR2 ,                -- 인증번호
  PR_RESULT       IN OUT PKG_CURSOR.REF_CUR ,   -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_SALE1030      인증번호 로그 조회
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2014-07-11         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE1030
      SYSDATE:         2014-07-11
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql          VARCHAR2(30000) ;
    ls_sql_main     VARCHAR2(30000) ;
    ls_sql_date     VARCHAR2(1000) ;
    ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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

--    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
           ||  ls_sql_store -- S_STORE
           ||  ', '
           ||  ls_sql_item  -- S_ITEM
           ;

/*
  S_STORE AS
  (
 SELECT S.BRAND_CD , B.BRAND_NM, S.STOR_CD, S.STOR_NM, S.USE_YN ,
        S.STOR_TP, CM1.CODE_NM STOR_TP_NM , S.SIDO_CD, CM2.CODE_NM SIDO_CD_NM,
        S.REGION_CD, R.REGION_NM , S.TRAD_AREA, CM3.CODE_NM TRAD_AREA_NM, '
        S.DEPT_CD, CM4.CODE_NM DEPT_CD_NM, S.TEAM_CD, CM5.CODE_NM TEAM_CD_NM,
        S.SV_USER_ID , U.USER_NM
  )
*/

/*
  S_ITEM AS
  (
   SELECT I.BRAND_CD, I.ITEM_CD, I.SALE_PRC,
          I.ITEM_NM , I.L_CLASS_CD, I.M_CLASS_CD, I.S_CLASS_CD,
         IC1.L_CLASS_NM , IC2.M_CLASS_NM , IC3.S_CLASS_NM
  )
*/

    -- 조회기간 처리---------------------------------------------------------------
    ls_sql_date := ' DL.APPR_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND DL.APPR_DT ' || ls_ex_date1 ;
    END IF;
    ------------------------------------------------------------------------------

    ls_sql_main :=
                            Q'[ SELECT  DL.DC_DIV                                           ]'
        ||chr(13)||chr(10)||Q'[      ,  D.DC_NM                                             ]'
        ||chr(13)||chr(10)||Q'[      ,  D.DC_FG                                             ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.CERT_NO                                          ]'
        ||chr(13)||chr(10)||Q'[      ,  TO_CHAR(TO_DATE(DL.APPR_DT, 'YYYYMMDD'), 'YYYY-MM-DD')  AS APPR_DT  ]'
        ||chr(13)||chr(10)||Q'[      ,  TO_CHAR(TO_DATE(DL.APPR_TM, 'HH24MISS'), 'HH24:MI:SS')  AS APPR_TM  ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.USE_STAT                                         ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.STOR_CD                                          ]'
        ||chr(13)||chr(10)||Q'[      ,  S.STOR_NM                                           ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.POS_NO                                           ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.BILL_NO                                          ]'
        ||chr(13)||chr(10)||Q'[      ,  SD.ITEM_CD                                          ]'
        ||chr(13)||chr(10)||Q'[      ,  I.ITEM_NM                                           ]'
        ||chr(13)||chr(10)||Q'[      ,  SD.SALE_PRC                                         ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.MSG1                                             ]'
        ||chr(13)||chr(10)||Q'[   FROM  DC_CERT_LOG DL                                      ]'
        ||chr(13)||chr(10)||Q'[      ,  (                                                   ]'
        ||chr(13)||chr(10)||Q'[             SELECT  D.BRAND_CD                              ]'
        ||chr(13)||chr(10)||Q'[                  ,  D.DC_DIV                                ]'
        ||chr(13)||chr(10)||Q'[                  ,  NVL(L.LANG_NM, D.DC_NM)   AS DC_NM      ]'
        ||chr(13)||chr(10)||Q'[                  ,  D.DC_FG                                 ]'
        ||chr(13)||chr(10)||Q'[               FROM  DC  D                                   ]'
        ||chr(13)||chr(10)||Q'[                  ,  (                                       ]'
        ||chr(13)||chr(10)||Q'[                         SELECT  PK_COL                      ]'
        ||chr(13)||chr(10)||Q'[                              ,  LANG_NM                     ]'
        ||chr(13)||chr(10)||Q'[                           FROM  LANG_TABLE                  ]'
        ||chr(13)||chr(10)||Q'[                          WHERE  TABLE_NM    = 'DC'          ]'
        ||chr(13)||chr(10)||Q'[                            AND  COL_NM      = 'DC_NM'       ]'
        ||chr(13)||chr(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||chr(13)||chr(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
        ||chr(13)||chr(10)||Q'[                     )   L                                   ]'
        ||chr(13)||chr(10)||Q'[              WHERE  L.PK_COL(+) = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ')  ]'
        ||chr(13)||chr(10)||Q'[         )           D                                       ]'
        ||chr(13)||chr(10)||Q'[      ,  SALE_DT     SD                                      ]'
        ||chr(13)||chr(10)||Q'[      ,  S_STORE     S                                       ]'
        ||chr(13)||chr(10)||Q'[      ,  S_ITEM      I                                       ]'
        ||chr(13)||chr(10)||Q'[  WHERE  DL.BRAND_CD = D.BRAND_CD                            ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.DC_DIV   = D.DC_DIV                              ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.SALE_DT  = SD.SALE_DT(+)                         ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.BRAND_CD = SD.BRAND_CD(+)                        ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.STOR_CD  = SD.STOR_CD(+)                         ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.POS_NO   = SD.POS_NO(+)                          ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.BILL_NO  = SD.BILL_NO(+)                         ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.SEQ      = SD.SEQ(+)                             ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.BRAND_CD = S.BRAND_CD                            ]'
        ||chr(13)||chr(10)||Q'[    AND  DL.STOR_CD  = S.STOR_CD                             ]'
        ||chr(13)||chr(10)||Q'[    AND  SD.BRAND_CD = I.BRAND_CD(+)                         ]'
        ||chr(13)||chr(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD(+)                          ]'
        ||chr(13)||chr(10)||Q'[    AND  (:PSV_USE_STAT IS NULL OR DL.USE_STAT = :PSV_USE_STAT)  ]'
        ||chr(13)||chr(10)||Q'[    AND  (:PSV_DC_TXT IS NULL OR (D.DC_DIV LIKE '%'||:PSV_DC_TXT||'%' OR D.DC_NM LIKE '%'||:PSV_DC_TXT||'%'))  ]'
        ||chr(13)||chr(10)||Q'[    AND  (:PSV_CERT_NO IS NULL OR DL.CERT_NO = :PSV_CERT_NO) ]'
        ||chr(13)||chr(10)||Q'[    AND  ]' ||  ls_sql_date          
        ||chr(13)||chr(10)||Q'[  ORDER  BY DL.APPR_DT DESC                                  ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.APPR_TM                                          ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.DC_DIV                                           ]'
        ||chr(13)||chr(10)||Q'[      ,  DL.CERT_NO                                          ]'
        ;

 --   dbms_output.put_line(ls_sql_main) ;

    ls_sql := ls_sql || ls_sql_main ;
    dbms_output.put_line(ls_sql) ;

    OPEN PR_RESULT FOR
       ls_sql USING PSV_LANG_CD, PSV_USE_STAT, PSV_USE_STAT, PSV_DC_TXT, PSV_DC_TXT, PSV_DC_TXT, PSV_CERT_NO, PSV_CERT_NO;

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
