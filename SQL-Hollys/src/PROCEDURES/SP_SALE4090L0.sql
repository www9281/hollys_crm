--------------------------------------------------------
--  DDL for Procedure SP_SALE4090L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SALE4090L0" /* 모바일 승인조회(헤더) */
(
  PSV_USER                    IN  VARCHAR2 ,                -- LOGIN USER
  PSV_PGM_ID                  IN  VARCHAR2 ,                -- Progrm ID
  PSV_LANG_CD                 IN  VARCHAR2 ,                -- Language Code
  PSV_ORG_CLASS               IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
  PSV_PARA                    IN  VARCHAR2 ,                -- Search Parameter
  PSV_FILTER                  IN  VARCHAR2 ,                -- Search Filter
  PSV_MOBILE_DIV              IN  VARCHAR2 ,                -- 기프티콘(쇼) 검색
  PR_RESULT                   IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD                   OUT VARCHAR2 ,  -- 처리코드
  PR_RTN_MSG                  OUT VARCHAR2    -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_SALE4090L0 모바일 승인조회(헤더)
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2013-08-28         1. CREATED THIS PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_SALE4090L0
      SYSDATE:         2013-08-28
      USERNAME:
      TABLE NAME:
******************************************************************************/
    ls_sql             VARCHAR2(30000);
    ls_sql_main        VARCHAR2(10000);
    ls_sql_date        VARCHAR2(1000);
    ls_sql_cm_00770    VARCHAR2(1000);     -- 공통코드 참조 Table SQL( Role)
    ls_sql_store       VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item        VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1           VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2           VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1        VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2        VARCHAR2(2000);     -- 조회일자 제외 (대비)

    ls_err_cd          VARCHAR2(7) := '0';
    ls_err_msg         VARCHAR2(500);

    ERR_HANDLER        EXCEPTION;

BEGIN

    dbms_output.enable( 1000000 ) ;

    PKG_REPORT.RPT_PARA(PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
                        ls_sql_store , ls_sql_item , ls_date1, ls_ex_date1, ls_date2, ls_ex_date2 );


    ls_sql := ' WITH  '
             ||  ls_sql_store -- S_STORE
--           ||  ', '
--           ||  ls_sql_item  -- S_ITEM
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
    ls_sql_date := 'ML.SALE_DT ' || ls_date1;
    IF ls_ex_date1 IS NOT NULL THEN
       ls_sql_date := ls_sql_date || ' AND ML.SALE_DT ' || ls_ex_date1 ;
    END IF;

    ls_sql_main :=
            '  SELECT A.*, ROWNUM      AS SEQ      '
    ||      '    FROM (                            '
    ||      '           SELECT /*+ LEADING(ML) NO_MERGE */ '
    ||      '                  ML.BRAND_CD         '
    ||      '                , S.BRAND_NM          '        
    ||      '                , ML.STOR_CD          '
    ||      '                , S.STOR_NM           '
    ||      '                , ML.SALE_DT          '
    ||      '                , ML.POS_NO           '
    ||      '                , ML.BILL_NO          '
    ||      '                , ML.MOBILE_DIV       '
    ||      '                , CASE WHEN P.CARD_NO IS NULL THEN 2 '
    ||      '                       ELSE 1         '
    ||      '                  END AS PAY_DC_DIV   '
    ||      '                , CASE WHEN P.CARD_NO IS NULL THEN FC_GET_WORDPACK('''||PSV_LANG_CD||''', ''DC'')'
    ||      '                       ELSE                        FC_GET_WORDPACK('''||PSV_LANG_CD||''', ''PAY'')'
    ||      '                  END AS PAY_DC_DIV_NM'
    ||      '                , ML.SALE_DIV         '
    ||      '                , ML.MOBILE_NM        '
    ||      '                , ML.MOBILE_NO        '
    ||      q'[              , ML.APPR_AMT * DECODE(ML.SALE_DIV, '1', 1, -1 ) AS APPR_AMT]'
    ||      '                , ML.APPR_NO          '
    ||      '                , ML.APPR_DT          '
    ||      q'[              , TO_CHAR(TO_DATE(CONCAT(ML.APPR_DT, ML.APPR_TM), 'YYYYMMDDHH24MISS'), 'YYYY-MM-DD HH24:MI:SS') AS APPR_TM]'
    ||      q'[              , (ML.TOT_AMT - ML.APPR_AMT) * DECODE(ML.SALE_DIV, '1', 1, -1) AS BALANCE_AMT]'
    ||      q'[              , ML.TOT_AMT * DECODE(ML.SALE_DIV, '1', 1, -1 ) AS TOT_AMT]'
    ||      '             FROM MOBILE_LOG ML        '
    ||      '                , S_STORE S            '
    ||      '                ,(                     '
    ||      '                  SELECT CODE_CD       '
    ||      '                       , CODE_NM       '
    ||      '                  FROM   COMMON        '
    ||      '                  WHERE  CODE_TP   = ''00490'''
    ||      '                  AND    VAL_C1    = ''M'''
    ||      '                  AND    USE_YN    = ''Y'''
    ||      '                 ) C                   '
    ||      '                , SALE_ST P            '
    ||      '            WHERE ML.BRAND_CD    = S.BRAND_CD    '
    ||      '              AND ML.STOR_CD     = S.STOR_CD     '
    ||      '              AND ML.MOBILE_DIV  = C.CODE_CD     '
    ||      '              AND ML.SALE_DT     = P.SALE_DT(+)  '
    ||      '              AND ML.BRAND_CD    = P.BRAND_CD(+) '
    ||      '              AND ML.STOR_CD     = P.STOR_CD(+)  '
    ||      '              AND ML.POS_NO      = P.POS_NO(+)   '
    ||      '              AND ML.BILL_NO     = P.BILL_NO(+)  '
    ||      '              AND ML.MOBILE_DIV  = P.PAY_DIV(+)  '
    ||      '              AND ML.MOBILE_NO   = P.CARD_NO(+)  '
    ||      q'[            AND ML.USE_YN      = 'Y']'
    ||      '              AND ' || ls_sql_date;

      -- 기프티콘 검색 조건 처리-----------------------------------------------------
    IF PSV_MOBILE_DIV IS NOT NULL THEN
          ls_sql_main := ls_sql_main || ' AND ML.MOBILE_DIV = '''||PSV_MOBILE_DIV||'''';
    END IF;

        ls_sql_main := ls_sql_main || ' ORDER BY ML.BRAND_CD, ML.STOR_CD, ML.SALE_DT, ML.POS_NO, ML.BILL_NO '
                                   || ' ) A ';
 --   dbms_output.put_line(ls_sql_main) ;
 
    ls_sql := ls_sql || ls_sql_main ;
--  DELETE FROM REPORT_QUERY WHERE PGM_ID = PSV_PGM_ID AND SEQ = 1;
--  INSERT INTO REPORT_QUERY VALUES (PSV_PGM_ID, 1, ls_sql);
    dbms_output.put_line(ls_sql) ;
    OPEN PR_RESULT FOR
       ls_sql;

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
