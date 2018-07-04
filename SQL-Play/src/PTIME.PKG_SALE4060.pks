CREATE OR REPLACE PACKAGE       PKG_SALE4060 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4060
    --  Description      : 요일별 매출(대비)
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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_SALE4060;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4060 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회 시작일자
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회 종료일자
        PSV_DFR_DATE    IN  VARCHAR2 ,                -- 대비 시작일자
        PSV_DTO_DATE    IN  VARCHAR2 ,                -- 대비 종료일자
        PSV_CUST_DIV    IN  VARCHAR2 ,                -- 고객구분
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      대비기간별 상품매출
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-19
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(10000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
    
    ls_sql_cm_00285 VARCHAR2(1000) ;    -- 공통코드SQL
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
    
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               --||  ', '
               --||  ls_sql_item  -- S_ITEM
        ;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00285 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00285') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  SALE_DY         AS WEEK_DAY     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AMT_G)      AS AMT_G        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(AMT_G)) OVER () * 100, 2) AMT_RATE_G  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT_G) AS CUST_CNT_G   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(CUST_CNT_G) = 0 THEN 0 ELSE SUM(AMT_G) / SUM(CUST_CNT_G) END ,2) AS CUST_AMT_G  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(AMT_D)      AS AMT_D        ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(RATIO_TO_REPORT(SUM(AMT_D)) OVER () * 100, 2) AMT_RATE_D  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CUST_CNT_D) AS CUST_CNT_D   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(CUST_CNT_D) = 0 THEN 0 ELSE SUM(AMT_D) / SUM(CUST_CNT_D) END ,2) AS CUST_AMT_D  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ROUND(CASE WHEN SUM(AMT_G) = 0 AND SUM(AMT_D) = 0 THEN 0    ]'
        ||CHR(13)||CHR(10)||Q'[                    WHEN SUM(AMT_D) = 0 THEN 100 ]'
        ||CHR(13)||CHR(10)||Q'[                    ELSE (SUM(AMT_G) - SUM(AMT_D)) / SUM(AMT_D) * 100    ]'
        ||CHR(13)||CHR(10)||Q'[               END, 2)    AS INCS_RATE   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (   ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) AS SALE_DY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'N', SJ.GRD_AMT - SJ.VAT_AMT, SJ.SALE_AMT))        AS AMT_G        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT))    AS CUST_CNT_G   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0   AS AMT_D        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0   AS CUST_CNT_D   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(C.SORT_SEQ)     AS SORT_SEQ     ]'
        ||CHR(13)||CHR(10)||q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00285 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') = C.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[             UNION ALL                           ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD) AS SALE_DY  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0       AS AMT_G        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  0       AS CUST_CNT_G   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_FILTER, 'G', SJ.GRD_AMT, 'N', SJ.GRD_AMT - SJ.VAT_AMT, SJ.SALE_AMT))        AS AMT_D        ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM(DECODE(:PSV_CUST_DIV, 'C', SJ.ETC_M_CNT + ETC_F_CNT, SJ.BILL_CNT - SJ.RTN_BILL_CNT))    AS CUST_CNT_D   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  MAX(C.SORT_SEQ)     AS SORT_SEQ     ]'
        ||CHR(13)||CHR(10)||q'[               FROM  SALE_JDS    SJ  ]'
        ||CHR(13)||CHR(10)||q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  ]' || ls_sql_cm_00285 || Q'[ C ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SJ.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = C.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TO_CHAR(TO_DATE(SJ.SALE_DT, 'YYYYMMDD'), 'D') = C.CODE_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SJ.SALE_DT  BETWEEN :PSV_DFR_DATE AND :PSV_DTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[                AND (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV)   ]'
        ||CHR(13)||CHR(10)||Q'[              GROUP  BY FC_GET_WEEK(:PSV_COMP_CD, SJ.SALE_DT, :PSV_LANG_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[         )               ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SALE_DY      ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY MAX(SORT_SEQ)]';
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_FILTER, PSV_CUST_DIV, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_COMP_CD, PSV_LANG_CD
                       , PSV_COMP_CD, PSV_LANG_CD, PSV_FILTER, PSV_CUST_DIV, PSV_COMP_CD, PSV_DFR_DATE, PSV_DTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_COMP_CD, PSV_LANG_CD;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

    EXCEPTION
        WHEN ERR_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
           
        WHEN OTHERS THEN
            PR_RTN_CD  := '4999999';
            PR_RTN_MSG := SQLERRM;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';
    END;
    
END PKG_SALE4060;

/
