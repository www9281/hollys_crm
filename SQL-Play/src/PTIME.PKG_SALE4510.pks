CREATE OR REPLACE PACKAGE       PKG_SALE4510 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4510
    --  Description      : 판매 반품현황
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
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
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 판매일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE4510;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4510 AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     판매 반품현황(메인)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-01-18
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := 
          CHR(13)||CHR(10)||Q'[ SELECT  SJ.BRAND_CD                         ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.STOR_CD                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(S.STOR_NM)          AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SJ.SALE_DT                          ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(DECODE(:PSV_FILTER, 'T', SJ.SALE_AMT, 'G', SJ.GRD_AMT, SJ.GRD_AMT - SJ.VAT_AMT))    AS GRD_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.RTN_BILL_CNT)    AS RTN_CNT  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.RTN_QTY)         AS RTN_QTY  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(SJ.RTN_AMT)         AS RTN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_JDS    SJ                      ]' 
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                       ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SJ.COMP_CD  = S.COMP_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.BRAND_CD = S.BRAND_CD            ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.STOR_CD  = S.STOR_CD             ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.COMP_CD  = :PSV_COMP_CD          ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SJ.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SJ.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY SJ.COMP_CD, SJ.BRAND_CD, SJ.STOR_CD, SJ.SALE_DT  ]'         
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SJ.COMP_CD, SJ.BRAND_CD, SJ.STOR_CD, SJ.SALE_DT  ]';
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_FILTER, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
    PROCEDURE SP_SUB
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_SALE_DT     IN  VARCHAR2 ,                -- 판매일자
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_SUB     판매 반품현황(서브)
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-18         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_SUB
            SYSDATE     :   2016-01-18
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(20000);
    ls_sql_date     VARCHAR2(1000);
    ls_sql_store    VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item     VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1        VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2        VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1     VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2     VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ERR_HANDLER     EXCEPTION;
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);

    ls_sql_cm_00435 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00440 VARCHAR2(1000);    -- 공통코드 참조 Table SQL( Role)
        
    BEGIN
        
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER ,
                            ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );
       
        
        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
               ||  ', '
               ||  ls_sql_item  -- S_ITEM
               ;
      
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00435');
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD , '00440');
        -------------------------------------------------------------------------------
        
        ls_sql_main := '' 
        ||CHR(13)||CHR(10)||Q'[ SELECT  SH.COMP_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BRAND_CD                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.STOR_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.POS_NO                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.BILL_NO                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.CODE_NM       AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_DT                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.SALE_TM                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.CASHIER_ID                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SU.USER_NM      AS CASHIER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SH.RTN_MEMO                     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.ITEM_CD                      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  I.ITEM_NM                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  GET_COMMON_CODE_NM(:PSV_COP_CD, '01705', SD.RTN_DIV, :PSV_LANG_CD)  AS RTN_DIV  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SALE_QTY     AS RTN_QTY      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.GRD_AMT      AS RTN_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.SUB_TOUCH_DIV                ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SD.T_SEQ                        ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  SALE_HD     SH                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_DT     SD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_ITEM      I                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  (                               ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  U.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  U.USER_ID           ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  NVL(L.LANG_NM, U.USER_NM)   AS USER_NM  ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  STORE_USER  U       ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_TABLE  L       ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  L.COMP_CD(+)    = U.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.PK_COL(+)     = LPAD(U.BRAND_CD, 4, ' ')||LPAD(U.STOR_CD, 10, ' ')||LPAD(U.USER_ID, 15, ' ')  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  U.COMP_CD       = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.LANGUAGE_TP(+)= :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  L.USE_YN(+)     = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   SU                          ]' 
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00440 || Q'[ D    ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  SH.COMP_CD  = SD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  = SD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = SD.BRAND_CD   ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = SD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.POS_NO   = SD.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BILL_NO  = SD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = S.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.COMP_CD  = I.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SD.ITEM_CD  = I.ITEM_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.BRAND_CD = SU.BRAND_CD(+)]' 
        ||CHR(13)||CHR(10)||Q'[    AND  SH.STOR_CD  = SU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.CASHIER_ID = SU.USER_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.GIFT_DIV = D.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DT  = :PSV_SALE_DT  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR SH.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  SH.SALE_DIV = '2'           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY SH.POS_NO, SH.BILL_NO, SD.ITEM_CD  ]';
        
        dbms_output.put_line(ls_sql);
        dbms_output.put_line(ls_sql_main);
        
        ls_sql := ls_sql || ls_sql_main;
          
        OPEN PR_RESULT FOR
           ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_SALE_DT, PSV_GIFT_DIV, PSV_GIFT_DIV;
        
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
    
END PKG_SALE4510;

/
