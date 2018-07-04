CREATE OR REPLACE PACKAGE       PKG_SALE4160 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4160
    --  Description      : 객단가 시간대 매출
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    );
   
    PROCEDURE SP_SUB
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    );
   
END PKG_SALE4160;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4160 AS
    PROCEDURE SP_MAIN /* 객단가 시간대 매출 */
    (
        PSV_COMP_CD     IN  VARCHAR2 ,  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN  OUT PKG_CURSOR.REF_CUR  , -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE4160L0 시간대 매출
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-02-01         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE4160L0
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

        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------
        ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT S.SEC_DIV AS SEC_DIV,           ]' /*매출시간*/
            ||CHR(13)||CHR(10)||Q'[        SUM(SALE_AMT) AS SALE_AMT,      ]' /*HIDDEN-총매출액*/
            ||CHR(13)||CHR(10)||Q'[        SUM(DC_AMT + ENR_AMT) AS DC_AMT,]' /*HIDDEN-할인액*/
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_AMT) AS GRD_AMT,        ]' /*시제매출*/
            ||CHR(13)||CHR(10)||Q'[        SUM(DECODE(:PSV_FILTER, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)) AS CUST_CNT, ]' /*영수건수 -> 객수*/
            ||CHR(13)||CHR(10)||Q'[        ROUND(SUM(GRD_AMT) / decode(SUM(DECODE(:PSV_FILTER, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)),0,1,SUM(DECODE(:PSV_FILTER, 'C', S.ETC_M_CNT + S.ETC_F_CNT, S.BILL_CNT - S.RTN_BILL_CNT)))) AS CUST_AMT, ]' /*영수단가 -> 객단가 */
            ||CHR(13)||CHR(10)||Q'[        ROUND(SUM(GRD_AMT) / decode(SUM(SUM(GRD_AMT)) OVER ( PARTITION BY S.COMP_CD ), 0, 1,SUM(SUM(GRD_AMT)) OVER ( PARTITION BY S.COMP_CD )) * 100 , 2) AS GRD_RATIO, ]'/*구성비*/
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_I_AMT) AS GRD_I_AMT, ]'/*HIDDEN-테이크인 매출액*/
            ||CHR(13)||CHR(10)||Q'[        SUM(GRD_O_AMT) AS GRD_O_AMT, ]'/*HIDDEN*-테이크아웃 매출액*/
            ||CHR(13)||CHR(10)||Q'[        SUM(ETC_M_CNT) AS ETC_M_CNT, ]'/*HIDDEN*-남자 동반고객수*/
            ||CHR(13)||CHR(10)||Q'[        SUM(ETC_F_CNT) AS ETC_F_CNT, ]'/*HIDDEN*-여자 동반고객수*/
            ||CHR(13)||CHR(10)||Q'[        SUM(TABLE_CNT) AS TABLE_CNT  ]'/*HIDDEN*-테이블수*/
            ||CHR(13)||CHR(10)||Q'[   FROM SALE_JTO  S, ]'
            ||CHR(13)||CHR(10)||Q'[        S_STORE   B  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE S.COMP_CD  = B.COMP_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.BRAND_CD = B.BRAND_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.STOR_CD  = B.STOR_CD     ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.COMP_CD  = :PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT >= :PSV_GFR_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT <= :PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_FG   = :PSV_SEC_FG   ]'
            ||CHR(13)||CHR(10)||Q'[  GROUP BY S.COMP_CD, S.SEC_DIV    ]'
            ||CHR(13)||CHR(10)||Q'[  ORDER BY S.SEC_DIV ASC           ]' ;

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;
        
        OPEN PR_RESULT FOR
           ls_sql USING PSV_FILTER, PSV_FILTER, PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG;

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
    
    PROCEDURE SP_SUB /*시간대 매출 - 상세 상품 매출*/
    (
        PSV_COMP_CD     IN  VARCHAR2 ,  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,  -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,  -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,  -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,  -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,  -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,  -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,  -- Search 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,  -- Search 종료일자
        PSV_SEC_FG      IN  VARCHAR2 ,  -- 시간구분
        PR_RESULT       IN     OUT PKG_CURSOR.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SP_SALE4160L1 시간대 매출 - 상세 상품 매출
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2010-02-01         1. CREATED THIS PROCEDURE.

       NOTES:

          OBJECT NAME:     SP_SALE4160L1
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
    --    ls_sql_cm_00770 := PKG_REPORT.F_REF_COMMON(PSV_LANG_CD , '00770') ;
        -------------------------------------------------------------------------------

        ls_sql_main := ''
            ||CHR(13)||CHR(10)||Q'[ SELECT /*+ ORDERED USE_INDEX (S, IDX02_PT_SALE_JTM) */ ]'
            ||CHR(13)||CHR(10)||Q'[        I.S_CLASS_NM, I.S_SORT_ORDER,                   ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(S.SALE_QTY) AS SALE_QTY,                    ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(S.SALE_AMT) AS SALE_AMT,                    ]' /*HIDDEN*/
            ||CHR(13)||CHR(10)||Q'[        SUM(S.DC_AMT + S.ENR_AMT) AS DC_AMT,            ]' /*HIDDEN*/
            ||CHR(13)||CHR(10)||Q'[        SUM(S.GRD_AMT)  AS GRD_AMT,                     ]'
            ||CHR(13)||CHR(10)||Q'[        SUM(S.GRD_I_AMT) AS GRD_I_AMT,                  ]' /*HIDDEN*/
            ||CHR(13)||CHR(10)||Q'[        SUM(S.GRD_O_AMT) AS GRD_O_AMT                   ]' /*HIDDEN*/
            ||CHR(13)||CHR(10)||Q'[   FROM S_STORE   B, ]'
            ||CHR(13)||CHR(10)||Q'[        SALE_JTM  S, ]'
            ||CHR(13)||CHR(10)||Q'[        S_ITEM    I  ]'
            ||CHR(13)||CHR(10)||Q'[  WHERE S.COMP_CD  = B.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.BRAND_CD = B.BRAND_CD   ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.STOR_CD  = B.STOR_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.COMP_CD  = I.COMP_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.ITEM_CD  = I.ITEM_CD    ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.COMP_CD  =:PSV_COMP_CD  ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_DIV  =:PSV_FILTER   ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT >=:PSV_GFR_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SALE_DT <=:PSV_GTO_DATE ]'
            ||CHR(13)||CHR(10)||Q'[    AND S.SEC_FG   =:PSV_SEC_FG   ]'
            ||CHR(13)||CHR(10)||Q'[ GROUP BY  I.S_CLASS_NM, I.S_SORT_ORDER ]'
            ||CHR(13)||CHR(10)||Q'[ ORDER BY  I.S_SORT_ORDER  ]';

        ls_sql := ls_sql || ls_sql_main ;
        dbms_output.put_line(ls_sql) ;

        OPEN PR_RESULT FOR
           ls_sql USING PSV_COMP_CD, PSV_FILTER, PSV_GFR_DATE, PSV_GTO_DATE, PSV_SEC_FG;


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
END PKG_SALE4160;

/
