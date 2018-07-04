CREATE OR REPLACE PACKAGE      PKG_SALE4280 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4280
    --  Description      : 지역별 판매분석
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YEAR        IN  VARCHAR2 ,                -- 조회 기준년월
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    );
END PKG_SALE4280;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4280 AS
    PROCEDURE SP_MAIN /* 딜리버리 월별 판매추이 */
    (
        PSV_COMP_CD     IN  VARCHAR2 ,              -- 회사코드
        PSV_USER        IN  VARCHAR2 ,              -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,              -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,              -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,              -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,              -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,              -- Search Filter
        PSV_YEAR        IN  VARCHAR2 ,              -- 조회 기준년월
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR, -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,              -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_MAIN    딜리버리 월별 판매 추이
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2014-02-11         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_MAIN
          SYSDATE:         2014-02-13
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(30000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_date2    VARCHAR2(1000) ;

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
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
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

        ls_sql_main := ''
        ||CHR(13)||CHR(10)|| Q'[SELECT  SJ.BRAND_CD                 ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  MAX(S.BRAND_NM) AS BRAND_NM ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SJ.STOR_CD                  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  MAX(S.STOR_NM)  AS STOR_NM  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '01', SJ.SALE_QTY, 0))                                                                                       AS  QTY_01  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '01', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_01  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '02', SJ.SALE_QTY, 0))                                                                                       AS  QTY_02  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '02', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_02  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '03', SJ.SALE_QTY, 0))                                                                                       AS  QTY_03  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '03', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_03  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '04', SJ.SALE_QTY, 0))                                                                                       AS  QTY_04  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '04', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_04  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '05', SJ.SALE_QTY, 0))                                                                                       AS  QTY_05  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '05', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_05  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '06', SJ.SALE_QTY, 0))                                                                                       AS  QTY_06  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '06', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_06  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '07', SJ.SALE_QTY, 0))                                                                                       AS  QTY_07  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '07', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_07  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '08', SJ.SALE_QTY, 0))                                                                                       AS  QTY_08  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '08', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_08  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '09', SJ.SALE_QTY, 0))                                                                                       AS  QTY_09  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '09', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_09  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '10', SJ.SALE_QTY, 0))                                                                                       AS  QTY_10  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '10', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_10  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '11', SJ.SALE_QTY, 0))                                                                                       AS  QTY_11  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '11', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_11  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '12', SJ.SALE_QTY, 0))                                                                                       AS  QTY_12  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(SUBSTR(SJ.SALE_YM, 5, 2), '12', DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT), 0))  AS  AMT_12  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(SJ.SALE_QTY)                                                                            AS  QTY_TOT ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'T', SJ.SALE_AMT, SJ.GRD_AMT - SJ.VAT_AMT))        AS  AMT_TOT ]'
        ||CHR(13)||CHR(10)|| Q'[  FROM  SALE_JMO    SJ                  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)|| Q'[ WHERE  SJ.COMP_CD  = S.COMP_CD         ]'
        ||CHR(13)||CHR(10)|| Q'[   AND  SJ.BRAND_CD = S.BRAND_CD        ]'
        ||CHR(13)||CHR(10)|| Q'[   AND  SJ.STOR_CD  = S.STOR_CD         ]'
        ||CHR(13)||CHR(10)|| Q'[   AND  SJ.COMP_CD  = :PSV_COMP_CD      ]'
        ||CHR(13)||CHR(10)|| Q'[   AND  SJ.SALE_YM  LIKE :PSV_YEAR||'%' ]'
        ||CHR(13)||CHR(10)|| Q'[   AND  SJ.SALE_TYPE= '2'               ]'
        ||CHR(13)||CHR(10)|| Q'[ GROUP  BY SJ.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SJ.STOR_CD                      ]'
        ||CHR(13)||CHR(10)|| Q'[ ORDER  BY SJ.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)|| Q'[     ,  SJ.STOR_CD                      ]'
        ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;
        
        --delete from report_query where pgm_id = PSV_PGM_ID ;
        --insert into REPORT_QUERY ( comp_cd, pgm_id, seq, query_text ) values( PSV_COMP_CD, PSV_PGM_ID, 1, ls_sql );
        
        OPEN PR_RESULT FOR
           ls_sql USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER,
                        PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER,
                        PSV_COMP_CD, PSV_YEAR;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg ;
           dbms_output.put_line( PR_RTN_MSG ) ;
           EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999' ;
            PR_RTN_MSG := SQLERRM ;
            dbms_output.put_line( PR_RTN_MSG ) ;
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
END PKG_SALE4280;

/
