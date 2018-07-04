CREATE OR REPLACE PACKAGE       PKG_SALE6210 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE6210
    --  Description      : ERP 전송 결과 조회
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
END PKG_SALE6210;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE6210 AS

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
        NAME:       SP_MAIN      ERP 전송 결과 조회
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  HD.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  HD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'Y' THEN HD.GRD_I_AMT + HD.GRD_O_AMT ELSE 0 END) AS GRD_AMT_Y ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'Y' THEN HD.GRD_I_AMT + HD.GRD_O_AMT - HD.VAT_I_AMT - HD.VAT_O_AMT ELSE 0 END) AS NET_AMT_Y ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'Y' THEN HD.VAT_I_AMT - HD.VAT_O_AMT ELSE 0 END) AS VAT_AMT_Y ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'N' THEN HD.GRD_I_AMT + HD.GRD_O_AMT ELSE 0 END) AS GRD_AMT_N ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'N' THEN HD.GRD_I_AMT + HD.GRD_O_AMT - HD.VAT_I_AMT - HD.VAT_O_AMT ELSE 0 END) AS NET_AMT_N ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN HD.SAP_IF_YN = 'N' THEN HD.VAT_I_AMT - HD.VAT_O_AMT ELSE 0 END) AS VAT_AMT_N ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SLIP_NO                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SEND_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(FC_GET_WORDPACK(HD.COMP_CD, :PSV_LANG_CD, DECODE(EI.RESULT, '0', 'ERP_SEND_N', 'ERP_SEND_Y'))) RESULT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(EI.RESULT_MSG) AS RESULT_MSG ]'
        ||CHR(13)||CHR(10)||Q'[ FROM    SALE_HD HD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE ST                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ERP_IF_RESULT EI            ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   HD.COMP_CD   = ST.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.BRNAD_CD  = ST.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.STOR_CD   = ST.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.COMP_CD   = EI.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.SALE_DT   = EI.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.STOR_CD   = EI.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND     HD.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE     ]'
        ||CHR(13)||CHR(10)||Q'[ GROUP  BY                           ]' 
        ||CHR(13)||CHR(10)||Q'[         HD.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  HD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SLIP_NO                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SEND_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY                          ]'
        ||CHR(13)||CHR(10)||Q'[         HD.SALE_DT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  HD.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  ST.STOR_NM                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SLIP_NO                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  EI.SEND_DT                  ]'
        ;
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_LANG_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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
    
END PKG_SALE6210;

/
