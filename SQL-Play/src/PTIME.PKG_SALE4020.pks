CREATE OR REPLACE PACKAGE       PKG_SALE4020 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4020
    --  Description      : 상품별 - 시간대 매출 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD  IN  VARCHAR2 ,  -- 대분류
        PSV_M_CLASS_CD  IN  VARCHAR2 ,  -- 중분류
        PSV_S_CLASS_CD  IN  VARCHAR2 ,  -- 소분류
        PSV_PARA        IN  VARCHAR2 ,  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR  , -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    );
END PKG_SALE4020;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4020 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,  -- 품목 대/중/소 분류 그룹
        PSV_L_CLASS_CD  IN  VARCHAR2 ,  -- 대분류
        PSV_M_CLASS_CD  IN  VARCHAR2 ,  -- 중분류
        PSV_S_CLASS_CD  IN  VARCHAR2 ,  -- 소분류
        PSV_PARA        IN  VARCHAR2 ,  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR  , -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE4020 상품별 시간대 매출
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-02-01         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE4020
          SYSDATE:         2010-03-08
          USERNAME:
          TABLE NAME:
    ******************************************************************************/
        ls_sql          VARCHAR2(30000) ;
        ls_sql_main     VARCHAR2(10000) ;
        ls_sql_date     VARCHAR2(1000) ;
        ls_sql_cm_00770 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
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
        dbms_output.enable( 1000000 ) ;

        PKG_REPORT.RPT_PARA(PSV_COMP_CD, PSV_USER ,PSV_PGM_ID ,PSV_LANG_CD ,PSV_ORG_CLASS ,PSV_PARA ,PSV_FILTER ,
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

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD , PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT I.L_CLASS_CD,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.L_CLASS_NM,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.L_SORT_ORDER,]'
            ||CHR(13)||CHR(10)||Q'[        I.M_CLASS_CD,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.M_CLASS_NM,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.M_SORT_ORDER,]'
            ||CHR(13)||CHR(10)||Q'[        I.S_CLASS_CD,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.S_CLASS_NM,  ]'
            ||CHR(13)||CHR(10)||Q'[        I.S_SORT_ORDER,]'
            ||CHR(13)||CHR(10)||Q'[        I.ITEM_CD,     ]'
            ||CHR(13)||CHR(10)||Q'[        I.ITEM_NM,     ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_00 ) AS SALE_QTY_00 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_00  ) AS GRD_AMT_00  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_06 ) AS SALE_QTY_06 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_06  ) AS GRD_AMT_06  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_09 ) AS SALE_QTY_09 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_09  ) AS GRD_AMT_09  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_12 ) AS SALE_QTY_12 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_12  ) AS GRD_AMT_12  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_15 ) AS SALE_QTY_15 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_15  ) AS GRD_AMT_15  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_18 ) AS SALE_QTY_18 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_18  ) AS GRD_AMT_18  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_21 ) AS SALE_QTY_21 , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_21  ) AS GRD_AMT_21  , ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_QTY_TOT) AS SALE_QTY_TOT, ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT_TOT ) AS GRD_AMT_TOT   ]'
            ||CHR(13)||CHR(10)||Q'[  FROM (SELECT S.COMP_CD   AS COMP_CD,     ]'
            ||CHR(13)||CHR(10)||Q'[               S.BRAND_CD  AS BRAND_CD,    ]'
            ||CHR(13)||CHR(10)||Q'[               B.BRAND_NM  AS BRAND_NM,    ]'
            ||CHR(13)||CHR(10)||Q'[               S.STOR_CD   AS STOR_CD ,    ]'
            ||CHR(13)||CHR(10)||Q'[               B.STOR_NM   AS STOR_NM ,    ]'
            ||CHR(13)||CHR(10)||Q'[               S.ITEM_CD   AS ITEM_CD ,    ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 05 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_00, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 05 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_00, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 06 AND 08 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_06, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 06 AND 08 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_06, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 09 AND 11 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_09, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 09 AND 11 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_09, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 12 AND 14 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_12, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 12 AND 14 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_12, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 15 AND 17 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_15, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 15 AND 17 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_15, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 18 AND 20 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_18, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 18 AND 20 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_18, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 21 AND 24 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_21, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 21 AND 24 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_21, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 24 THEN S.SALE_QTY ELSE 0 END ) AS SALE_QTY_TOT, ]'
            ||CHR(13)||CHR(10)||Q'[               SUM(CASE WHEN S.SEC_DIV BETWEEN 00 AND 24 THEN DECODE(:PSV_FILTER, 'G', S.GRD_AMT, 'T', S.SALE_AMT, S.GRD_AMT - S.VAT_AMT) ELSE 0 END ) AS GRD_AMT_TOT ]'
            ||CHR(13)||CHR(10)||Q'[          FROM SALE_JTM  S, ]'
            ||CHR(13)||CHR(10)||Q'[               S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[         WHERE S.COMP_CD  = B.COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[           AND S.BRAND_CD = B.BRAND_CD ]'
            ||CHR(13)||CHR(10)||Q'[           AND S.STOR_CD  = B.STOR_CD  ]'
            ||CHR(13)||CHR(10)||Q'[           AND S.SALE_DT >= :PSV_GFR_DATE ]'
            ||CHR(13)||CHR(10)||Q'[           AND S.SALE_DT <= :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[           AND S.SEC_FG   = :PSV_SEC_FG   ]'
            ||CHR(13)||CHR(10)||Q'[         GROUP BY S.COMP_CD,  ]'  
            ||CHR(13)||CHR(10)||Q'[                  S.BRAND_CD, ]'
            ||CHR(13)||CHR(10)||Q'[                  B.BRAND_NM, ]'
            ||CHR(13)||CHR(10)||Q'[                  S.STOR_CD , ]'
            ||CHR(13)||CHR(10)||Q'[                  B.STOR_NM , ]'
            ||CHR(13)||CHR(10)||Q'[                  S.ITEM_CD   ]'
            ||CHR(13)||CHR(10)||Q'[       )      S,              ]'
            ||CHR(13)||CHR(10)||Q'[       S_ITEM I               ]'
            ||CHR(13)||CHR(10)||Q'[ WHERE S.COMP_CD = I.COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[   AND S.ITEM_CD = I.ITEM_CD  ]'
            ||CHR(13)||CHR(10)||Q'[   AND S.COMP_CD =:PSV_COMP_CD]' 
            ||CHR(13)||CHR(10)||Q'[ GROUP BY I.L_CLASS_CD,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.L_CLASS_NM,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.L_SORT_ORDER,     ]'
            ||CHR(13)||CHR(10)||Q'[          I.M_CLASS_CD,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.M_CLASS_NM,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.M_SORT_ORDER,     ]'
            ||CHR(13)||CHR(10)||Q'[          I.S_CLASS_CD,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.S_CLASS_NM,       ]'
            ||CHR(13)||CHR(10)||Q'[          I.S_SORT_ORDER,     ]'
            ||CHR(13)||CHR(10)||Q'[          I.ITEM_CD,          ]'
            ||CHR(13)||CHR(10)||Q'[          I.ITEM_NM           ]'
            ||CHR(13)||CHR(10)||Q'[ ORDER BY I.L_SORT_ORDER, I.M_SORT_ORDER, I.S_SORT_ORDER, I.ITEM_NM ASC ]';

     --   dbms_output.put_line(ls_sql_main) ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;


        OPEN PR_RESULT FOR
           ls_sql USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_FILTER, 
                        PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG, PSV_COMP_CD;

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
    END ;
END PKG_SALE4020;

/
