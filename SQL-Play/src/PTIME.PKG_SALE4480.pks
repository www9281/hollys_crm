CREATE OR REPLACE PACKAGE       PKG_SALE4480 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4480
    --  Description      : 카드단말기 승인현황 (한점포) 
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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                  -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE4480;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4480 AS

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
        PSV_GIFT_DIV    IN  VARCHAR2 ,                  -- 판매종류
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     카드단말기 승인현황 (한점포)
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
    
    ls_sql_cm_00440 VARCHAR2(1000) ;    -- 공통코드SQL
        
    ls_err_cd     VARCHAR2(7) := '0';
    ls_err_msg    VARCHAR2(500);
        
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );

        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  CL.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.APPR_DT      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.APPR_TM      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.POS_NO       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.BILL_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  D.CODE_NM       AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.CARD_NO      ]'
        ||CHR(13)||CHR(10)||Q'[      ,  C.CARD_NM       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.APPR_AMT * DECODE(SALE_DIV, '1', 1, -1)  AS APPR_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  CARD_LOG    CL  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CARD        C   ]'
        ||CHR(13)||CHR(10)||Q'[      ,]' || ls_sql_cm_00440 || Q'[ D]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  CL.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.COMP_CD  = C.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.MAEIP_CD = C.CARD_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.GIFT_DIV = D.CODE_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[    AND (:PSV_GIFT_DIV IS NULL OR CL.GIFT_DIV = :PSV_GIFT_DIV)]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.APPR_DIV = '@'           ]'
        ||CHR(13)||CHR(10)||Q'[    AND  CL.USE_YN   = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY CL.BRAND_CD              ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.STOR_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.APPR_DT DESC             ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL.APPR_TM DESC             ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE, PSV_GIFT_DIV, PSV_GIFT_DIV;

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
    
END PKG_SALE4480;

/
