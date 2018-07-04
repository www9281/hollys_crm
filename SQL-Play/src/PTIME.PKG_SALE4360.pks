CREATE OR REPLACE PACKAGE       PKG_SALE4360 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE4360
    --  Description      : 신용카드 승인조회
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
        PSV_APRV_TP     IN  VARCHAR2 ,                -- 공통코드 00506 -> 승인기준 : 1.영업일, 2.승인일
        PSV_CARD_CD     IN  VARCHAR2 ,                -- 카드사 코드
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PSV_USE_YN      IN  VARCHAR2 ,                -- 사용여부
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_SALE4360;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE4360 AS

   ---------------------------------------------------------------------------------------------------
   --  Package Name     : PKG_SALE4360
   --  Description      : 신용카드 승인조회
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
        PSV_APRV_TP     IN  VARCHAR2 ,                -- 공통코드 00506 -> 승인기준 : 1.영업일, 2.승인일
        PSV_CARD_CD     IN  VARCHAR2 ,                -- 카드사 코드
        PSV_GIFT_DIV    IN  VARCHAR2 ,                -- 판매종류
        PSV_USE_YN      IN  VARCHAR2 ,                -- 사용여부
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN     신용카드 승인조회
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
    
    ls_sql_cm_00435 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00945 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00505 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
    ls_sql_cm_00440 VARCHAR2(1000) ;    -- 공통코드 참조 Table SQL( Role)
     
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        ;
        
        -- 공통코드 참조 Table 생성 ---------------------------------------------------
        ls_sql_cm_00435 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00435') ;
        ls_sql_cm_00945 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00945') ;
        ls_sql_cm_00505 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00505') ;
        ls_sql_cm_00440 := PKG_REPORT.F_REF_COMMON(PSV_COMP_CD, PSV_LANG_CD, '00440') ;
        -------------------------------------------------------------------------------
        
        ls_sql_main := ''
        ||CHR(13)||CHR(10)||Q'[ SELECT  A.BRAND_CD                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.SALE_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.STOR_CD                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S.STOR_NM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_DT                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_TM                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.POS_NO                    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.BILL_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL1.CODE_NM AS SALE_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL2.CODE_NM AS RSV_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL3.CODE_NM AS APPR_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CL4.CODE_NM AS GIFT_DIV_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  NVL(L.LANG_NM, C.CARD_NM)                   AS CARD_NM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.CARD_NO                   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.APPR_AMT * DECODE(A.SALE_DIV, '1', 1, -1) AS APPR_AMT ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(A.ALLOT_LMT, '0', '', A.ALLOT_LMT)   AS ALLOT_AMT]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.CARD_LMT                  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  DECODE(A.APPR_DIV, '@', CL3.CODE_NM, A.APPR_NO) AS APPR_NO  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  A.USE_YN                    ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  CARD_LOG A, S_STORE S, CARD C,  ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00435 || Q'[ CL1, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00945 || Q'[ CL2, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00505 || Q'[ CL3, ]'
        ||CHR(13)||CHR(10)||            ls_sql_cm_00440 || Q'[ CL4, ]'
        ||CHR(13)||CHR(10)||Q'[         (       ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  PK_COL      ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  LANG_NM     ]'
        ||CHR(13)||CHR(10)||q'[               FROM  LANG_TABLE  ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  COMP_CD     = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  TABLE_NM    = 'CARD'        ]'
        ||CHR(13)||CHR(10)||Q'[                AND  COL_NM      = 'CARD_NM'     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  LANGUAGE_TP = :PSV_LANG_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  USE_YN      = 'Y'           ]'
        ||CHR(13)||CHR(10)||Q'[         )   L   ]'
        ||CHR(13)||CHR(10)||Q'[  WHERE  A.COMP_CD  = S.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.BRAND_CD = S.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.STOR_CD  = S.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = C.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.MAEIP_CD = C.CARD_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.SALE_DIV = CL1.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.RSV_DIV  = CL2.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.APPR_DIV = CL3.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.GIFT_DIV = CL4.CODE_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  L.PK_COL(+)= LPAD(C.BRAND_CD, 4, ' ')||LPAD(C.CARD_DIV, 1, ' ')||LPAD(C.CARD_CD, 10, ' ') ]'
        ||CHR(13)||CHR(10)||Q'[    AND  A.COMP_CD  = :PSV_COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_CARD_CD  IS NULL OR C.CARD_CD  = :PSV_CARD_CD)  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_GIFT_DIV IS NULL OR A.GIFT_DIV = :PSV_GIFT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  (:PSV_USE_YN   IS NULL OR A.USE_YN   = :PSV_USE_YN) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  DECODE(:PSV_APRV_TP, '1', A.SALE_DT, A.APPR_DT) BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY A.STOR_CD, A.SALE_DT ASC, A.POS_NO ASC, A.BILL_NO ASC   ]';
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_CARD_CD, PSV_CARD_CD, 
                         PSV_GIFT_DIV, PSV_GIFT_DIV, PSV_USE_YN, PSV_USE_YN, PSV_APRV_TP, PSV_GFR_DATE, PSV_GTO_DATE;

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
    
END PKG_SALE4360;

/
