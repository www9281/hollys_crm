CREATE OR REPLACE PACKAGE       PKG_ATTD4300 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ATTD4300
    --  Description      : 매장 방문 이동 현황
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
        PSV_TEXT        IN  VARCHAR2 ,                -- 
        PSV_VISIT_DIV   IN  VARCHAR2 ,                -- 방문구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    );
END PKG_ATTD4300;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ATTD4300 AS

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
        PSV_TEXT        IN  VARCHAR2 ,                -- 
        PSV_VISIT_DIV   IN  VARCHAR2 ,                -- 방문구분
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    매장 방문 이동 현황조회
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-01-19         1. CREATED THIS PROCEDURE.
        
        NOTES:
        OBJECT NAME :   SP_MAIN
        SYSDATE     :  
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;
        
        ls_sql_main := ''
        
    
        ||CHR(13)||CHR(10)||Q'[ SELECT STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   MNG_CARD_ID    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   VISIT_MEMO    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   READ_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   VISIT_DIV    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DECODE( READ_DIV, 'A' , 'MSR' , '@', '수기입력' )  AS READ_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   TO_CHAR(TO_DATE(VISIT_FROM_TM, 'YYYYMMDDHH24MI') , 'YYYY-MM-DD HH24:MI') AS VISIT_FROM_TM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   TO_CHAR(TO_DATE(VISIT_TO_TM,   'YYYYMMDDHH24MI') , 'YYYY-MM-DD HH24:MI') AS VISIT_TO_TM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DECODE ( FLOOR(VISIT_TM/60) , 0 , '' , FLOOR(VISIT_TM/60) || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'TIME') ) ||  LPAD(FLOOR (MOD(VISIT_TM, 60) ), 2, 0) || FC_GET_WORDPACK(:PSV_COMP_CD, :PSV_LANG_CD, 'MINUTES') AS VISIT_TIME    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (    ]'
        ||CHR(13)||CHR(10)||Q'[     SELECT A1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A2.STOR_NM     ]'
        ||CHR(13)||CHR(10)||Q'[       ,    NVL(A3.USER_ID , A4.USER_ID) AS USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    NVL(A3.USER_NM , A4.USER_NM) AS USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.MNG_CARD_ID    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.VISIT_FROM_TM  ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.VISIT_TO_TM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.VISIT_MEMO     ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.READ_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[       ,    ROUND( (TO_DATE(A1.VISIT_TO_TM, 'YYYYMMDDHH24MISS') - TO_DATE(A1.VISIT_FROM_TM, 'YYYYMMDDHH24MISS')) *24*60 )  AS VISIT_TM    ]'
        ||CHR(13)||CHR(10)||Q'[       ,    A1.VISIT_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[     FROM   STORE_VISIT   A1    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   S_STORE       A2    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   HQ_USER       A3    ]'
        ||CHR(13)||CHR(10)||Q'[        ,   STORE_USER    A4    ]'
        ||CHR(13)||CHR(10)||Q'[     WHERE  A1.COMP_CD  = A2.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.BRAND_CD = A2.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.STOR_CD  = A2.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.COMP_CD       = A3.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.VISIT_USER_ID = A3.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.COMP_CD       = A4.COMP_CD(+)     ]'
        ||CHR(13)||CHR(10)||Q'[     AND    A1.VISIT_USER_ID = A4.USER_ID(+) ]'
        ||CHR(13)||CHR(10)||Q'[     AND    (    A1.VISIT_FROM_TM BETWEEN :PSV_GFR_DATE || '0000' AND :PSV_GTO_DATE || '2359'    ]'
        ||CHR(13)||CHR(10)||Q'[              OR A1.VISIT_TO_TM   BETWEEN :PSV_GFR_DATE || '0000' AND :PSV_GTO_DATE || '2359'    ]'
        ||CHR(13)||CHR(10)||Q'[            )    ]'
        ||CHR(13)||CHR(10)||Q'[     AND    (:PSV_VISIT_DIV IS NULL OR A1.VISIT_DIV = :PSV_VISIT_DIV) ]'
        ||CHR(13)||CHR(10)||Q'[ )    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE   ( USER_ID = :PSV_TEXT  OR USER_NM LIKE '%' || :PSV_TEXT  || '%'  ) ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY USER_ID, VISIT_FROM_TM    ]'
        ;
        
               
        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);
        
        OPEN PR_RESULT FOR

            ls_sql USING PSV_COMP_CD , PSV_LANG_CD
                       , PSV_COMP_CD , PSV_LANG_CD
                       , PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_VISIT_DIV, PSV_VISIT_DIV
                       , PSV_TEXT    , PSV_TEXT
                       ;
                           

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
    
END PKG_ATTD4300;

/
