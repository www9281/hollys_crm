--------------------------------------------------------
--  DDL for Procedure SP_STCK1000L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_STCK1000L0" /* 할인쿠폰 수불현황 */
(
  PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
  PSV_BRAND_CD    IN  VARCHAR2 ,                -- 영업조직
  PSV_DC_DIV      IN  VARCHAR2 ,                -- 할인코드
  PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
  PR_HEADER       IN  OUT PKG_REPORT.REF_CUR  , -- Result Set
  PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
  PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
  PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
)
IS
/******************************************************************************
   NAME:       SP_STCK1000L0  할인쿠폰 수불현황
   PURPOSE:

   REVISIONS:
   VER        DATE        AUTHOR           DESCRIPTION
   ---------  ----------  ---------------  ------------------------------------
   1.0        2015-01-09  최세원           CREATED PROCEDURE.

   NOTES:

      OBJECT NAME:     SP_STCK1000L0
      SYSDATE:         2015-01-09
      USERNAME:
      TABLE NAME:      DC_CERT
******************************************************************************/

ls_sql          VARCHAR2(30000);
ls_sql_main     VARCHAR2(30000);
ls_sql_crosstab_main VARCHAR2(20000);   -- CORSSTAB TITLE

ERR_HANDLER     EXCEPTION;

ls_err_cd     VARCHAR2(7) := '0';
ls_err_msg    VARCHAR2(500);

lsLine varchar2(3) := '000';

TYPE  rec_ct_hd IS RECORD
( CODE_CD  VARCHAR2(10),
  CODE_NM  VARCHAR2(60)
);

TYPE tb_ct_hd IS TABLE OF rec_ct_hd
    INDEX BY PLS_INTEGER;
qry_hd         tb_ct_hd;

V_CROSSTAB     VARCHAR2(30000);
V_SQL          VARCHAR2(30000);
V_HD           VARCHAR2(30000);
V_CNT          PLS_INTEGER;

BEGIN

    dbms_output.enable( 1000000 );

    ls_sql_crosstab_main := 'SELECT  C.CODE_CD                               '
        ||chr(13)||chr(10)||'     ,  NVL(L.CODE_NM, C.CODE_NM)   AS CODE_NM  '
        ||chr(13)||chr(10)||'  FROM  COMMON  C   '
        ||chr(13)||chr(10)||'     ,  (           '
        ||chr(13)||chr(10)||'            SELECT  COMP_CD                 '
        ||chr(13)||chr(10)||'                 ,  CODE_TP                 '
        ||chr(13)||chr(10)||'                 ,  CODE_CD                 '
        ||chr(13)||chr(10)||'                 ,  CODE_NM                 '
        ||chr(13)||chr(10)||'              FROM  LANG_COMMON              '
        ||chr(13)||chr(10)||'             WHERE  COMP_CD     = ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)||'               AND  CODE_TP     = ''01615'''
        ||chr(13)||chr(10)||'               AND  LANGUAGE_TP = ''' || PSV_LANG_CD || ''''
        ||chr(13)||chr(10)||'               AND  USE_YN      = ''Y'''
        ||chr(13)||chr(10)||'        )       L   '
        ||chr(13)||chr(10)||' WHERE  C.COMP_CD = L.COMP_CD(+)    '
        ||chr(13)||chr(10)||'   AND  C.CODE_CD = L.CODE_CD(+)    '
        ||chr(13)||chr(10)||'   AND  C.COMP_CD = ''' || PSV_COMP_CD || ''''
        ||chr(13)||chr(10)||'   AND  C.CODE_TP = ''01615'''
        ||chr(13)||chr(10)||'   AND  C.USE_YN  = ''Y'''
        ||chr(13)||chr(10)||' ORDER  BY C.SORT_SEQ, C.CODE_CD '
    ;

    ls_sql := ls_sql_crosstab_main ;

    dbms_output.put_line(ls_sql) ;

    EXECUTE IMMEDIATE  ls_sql BULK COLLECT INTO qry_hd ;

    IF SQL%ROWCOUNT = 0  THEN
       ls_err_cd  := '4000100';
       ls_err_msg := PKG_COMMON_FC.F_RTN_MSG( PSV_COMP_CD, PSV_LANG_CD, ls_err_cd );
       RAISE ERR_HANDLER ;
    END IF ;

    V_HD := ' SELECT ''' || FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'DC_CD') || ''','
         || '        ''' || FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'DC_NM') || ''','
         || '        ''' || FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'START_DT') || ''','
         || '        ''' || FC_GET_WORDPACK(PSV_COMP_CD , PSV_LANG_CD, 'TOTAL') || ''',';

    FOR i IN qry_hd.FIRST..qry_hd.LAST
    LOOP
        BEGIN
            IF i > 1 THEN
               V_CROSSTAB := V_CROSSTAB || ' , ';
               V_HD := V_HD || ' , ';
            END IF;
            V_CROSSTAB := V_CROSSTAB || '''' || qry_hd(i).CODE_CD || '''';
            V_HD       := V_HD       || '''' || qry_hd(i).CODE_NM || ''' CT  ';
        END;
    END LOOP;

    V_HD := V_HD || ' FROM DUAL ' ;

    ls_sql_main := ''
    ||chr(13)||chr(10)||Q'[ SELECT  D.DC_DIV                ]'
    ||chr(13)||chr(10)||Q'[      ,  MAX(D.DC_NM)        AS DC_NM    ]'
    ||chr(13)||chr(10)||Q'[      ,  DC.CERT_FDT             ]'
    ||chr(13)||chr(10)||Q'[      ,  SUM(COUNT(*)) OVER (PARTITION BY D.COMP_CD, D.BRAND_CD, D.DC_DIV, DC.CERT_FDT)   AS TOTAL    ]'
    ||chr(13)||chr(10)||Q'[      ,  DC.USE_STAT ]'
    ||chr(13)||chr(10)||Q'[      ,  COUNT(*)    AS CNT  ]'
    ||chr(13)||chr(10)||Q'[   FROM  (           ]'
    ||chr(13)||chr(10)||Q'[             SELECT  D.COMP_CD   ]'
    ||chr(13)||chr(10)||Q'[                  ,  D.BRAND_CD  ]'
    ||chr(13)||chr(10)||Q'[                  ,  D.DC_DIV    ]'
    ||chr(13)||chr(10)||Q'[                  ,  NVL(L.LANG_NM, D.DC_NM) AS DC_NM    ]'
    ||chr(13)||chr(10)||Q'[               FROM  DC      D   ]'
    ||chr(13)||chr(10)||Q'[                  ,  (           ]'
    ||chr(13)||chr(10)||Q'[                         SELECT  COMP_CD ]'
    ||chr(13)||chr(10)||Q'[                              ,  PK_COL  ]'
    ||chr(13)||chr(10)||Q'[                              ,  LANG_NM ]'
    ||chr(13)||chr(10)||Q'[                           FROM  LANG_TABLE ]'
    ||chr(13)||chr(10)||Q'[                          WHERE  COMP_CD     = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND  TABLE_NM    = 'DC'          ]'
    ||chr(13)||chr(10)||Q'[                            AND  COL_NM      = 'DC_NM'       ]'
    ||chr(13)||chr(10)||Q'[                            AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
    ||chr(13)||chr(10)||Q'[                            AND  USE_YN      = 'Y'           ]'
    ||chr(13)||chr(10)||Q'[                     )       L   ]'
    ||chr(13)||chr(10)||Q'[              WHERE  L.COMP_CD(+)= D.COMP_CD     ]'
    ||chr(13)||chr(10)||Q'[                AND  L.PK_COL(+) = LPAD(D.BRAND_CD, 4, ' ')||LPAD(D.DC_DIV, 5, ' ') ]'
    ||chr(13)||chr(10)||Q'[                AND  D.COMP_CD   = :PSV_COMP_CD  ]'
    ||chr(13)||chr(10)||Q'[                AND  D.DC_CLASS  = '2'           ]'
    ||chr(13)||chr(10)||Q'[                AND  D.DML_FLAG <> 'D'           ]'
    ||chr(13)||chr(10)||Q'[                AND  (:PSV_DC_DIV IS NULL OR D.DC_DIV = :PSV_DC_DIV) ]'
    ||chr(13)||chr(10)||Q'[         )       D   ]'
    ||chr(13)||chr(10)||Q'[      ,  DC_CERT DC  ]'
    ||chr(13)||chr(10)||Q'[  WHERE  D.COMP_CD   = DC.COMP_CD    ]'
    ||chr(13)||chr(10)||Q'[    AND  D.BRAND_CD  = DC.BRAND_CD   ]'
    ||chr(13)||chr(10)||Q'[    AND  D.DC_DIV    = DC.DC_DIV     ]'
    ||chr(13)||chr(10)||Q'[  GROUP  BY D.COMP_CD, D.BRAND_CD, D.DC_DIV, DC.CERT_FDT, DC.USE_STAT ]'
    ;

    V_CNT := qry_hd.LAST;

    ls_sql := ls_sql_main;

    /* PIVOT 구현 - FROM 절과 PIVOT 컬럼 정의*/
    V_SQL :=             ' SELECT *                     '
    ||chr(13)||chr(10)|| ' FROM (                       '
    ||chr(13)||chr(10)||         ls_sql
    ||chr(13)||chr(10)|| '      ) DC                    '
    ||chr(13)||chr(10)|| ' PIVOT                        '
    ||chr(13)||chr(10)|| ' (                            '
    ||chr(13)||chr(10)|| '  MAX(CNT)  VCOL1             '
    ||chr(13)||chr(10)|| '  FOR (USE_STAT) IN (         '
    ||chr(13)||chr(10)||                      V_CROSSTAB
    ||chr(13)||chr(10)|| '                   )          '
    ||chr(13)||chr(10)|| ' )                            '
    ||chr(13)||chr(10)|| ' ORDER BY 1                  '
    ;

    dbms_output.put_line( V_SQL) ;
    dbms_output.put_line( V_HD) ;

    OPEN PR_HEADER FOR V_HD;
    OPEN PR_RESULT FOR V_SQL USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_DC_DIV, PSV_DC_DIV;

    PR_RTN_CD  := ls_err_cd;
    PR_RTN_MSG := ls_err_msg;

EXCEPTION
    WHEN ERR_HANDLER THEN
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
       dbms_output.put_line( PR_RTN_MSG );
    WHEN OTHERS THEN
        dbms_output.put_line( 'line [' || lsLine || '] ' || sqlerrm(sqlcode) );
        PR_RTN_CD  := '4999999';
        PR_RTN_MSG := SQLERRM;
        dbms_output.put_line( PR_RTN_MSG );

END ;

/
