CREATE OR REPLACE PACKAGE      PKG_SALE4040 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4040
    --  Description      : 포인트 승인조회 
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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE4040;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4040 AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     포인트 승인조회
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
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;

        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  PL.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.APPR_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.PAY_TP       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.BILL_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.CUST_ID      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.CARD_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.SALE_DIV     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  TO_CHAR(TO_DATE(PL.APPR_TM, 'HH24MISS'), 'HH24:MI:SS')  AS APPR_TM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  HD.SALE_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.APPR_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.SALE_DT      ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  POINT_LOG  PL   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE    S    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SALE_HD    HD   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  PL.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.COMP_CD  = HD.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.BRAND_CD = HD.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.STOR_CD  = HD.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.SALE_DT  = HD.SALE_DT    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.POS_NO   = HD.POS_NO     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.BILL_NO  = HD.BILL_NO    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.APPR_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[    AND  PL.PAY_TP IN ( '1', '2' )   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY PL.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.APPR_DT DESC             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.PAY_TP                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.POS_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  PL.BILL_NO DESC             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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
    
END PKG_SALE4040;

/
