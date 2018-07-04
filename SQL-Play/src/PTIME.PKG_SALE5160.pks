CREATE OR REPLACE PACKAGE      PKG_SALE5160 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE5160
    --  Description      : 환전현황 조회 
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
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회기간(시작)
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회기간(종료)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );

END PKG_SALE5160;

/

CREATE OR REPLACE PACKAGE BODY      PKG_SALE5160 AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_GFR_DATE    IN  VARCHAR2 ,                -- 조회기간(시작)
        PSV_GTO_DATE    IN  VARCHAR2 ,                -- 조회기간(종료)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN      환전현황 조회
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  RL.PRT_DT                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.PRT_TM                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.POS_NO                       ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SU.USER_NM      AS CASHIER_NM   ]'
        ||CHR(13)||CHR(10)||Q'[      ,  RL.CDO_RESN                     ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  REPRINT_LOG     RL  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  S_STORE         S   ]'
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
        ||CHR(13)||CHR(10)||Q'[  WHERE  RL.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BRAND_CD = S.BRAND_CD    ]' 
        ||CHR(13)||CHR(10)||Q'[    AND  RL.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.COMP_CD  = SU.COMP_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.BRAND_CD = SU.BRAND_CD(+)]' 
        ||CHR(13)||CHR(10)||Q'[    AND  RL.STOR_CD  = SU.STOR_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.CASHIER  = SU.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.PRT_DT   BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE   ]'
        ||CHR(13)||CHR(10)||Q'[    AND  RL.DRAW_DIV = '1'           ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY RL.PRT_DT, RL.PRT_TM     ]';
              
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_LANG_CD, PSV_COMP_CD, PSV_GFR_DATE, PSV_GTO_DATE;

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
    
END PKG_SALE5160;

/
