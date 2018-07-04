--------------------------------------------------------
--  DDL for Package Body PKG_ACNT1100
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ACNT1100" AS

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
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    전도금 월별 사용 현황
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''





        ||CHR(13)||CHR(10)||Q'[ SELECT C1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.ETC_CD  || C1.RMK_SEQ ETC_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.RMK_NM     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   CASE WHEN ( C1.DISP_SEQ = '0' ) THEN C1.BEGIN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[             ELSE NULL  END  BEGIN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.IN_ETC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.OUT_ETC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   CASE WHEN ( C1.DISP_SEQ = '0' ) THEN C1.BEGIN_AMT + C1.IN_ETC_AMT - C1.OUT_ETC_AMT     ]'
        ||CHR(13)||CHR(10)||Q'[             ELSE NULL  END  END_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   C1.DISP_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (  ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT B1.*  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   NVL(B2.BEGIN_AMT  , 0) AS BEGIN_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[            ,   NVL(B3.IN_ETC_AMT , 0) AS IN_ETC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[            ,   NVL(B3.OUT_ETC_AMT, 0) AS OUT_ETC_AMT  ]'   
        ||CHR(13)||CHR(10)||Q'[            ,   0                    AS DISP_SEQ       ]'
        ||CHR(13)||CHR(10)||Q'[         FROM    (  ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT A1.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A2.BRAND_CD ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A2.BRAND_NM ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A2.STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A2.STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A1.ETC_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A1.RMK_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   A1.RMK_NM   ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM   ACC_RMK       A1  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   S_STORE       A2  ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE  A1.COMP_CD  = A2.COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    A1.STOR_TP  = A2.STOR_TP  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    A1.COMP_CD  = :PSV_COMP_CD]'
        ||CHR(13)||CHR(10)||Q'[                 AND    A1.ETC_CD   = '133'  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    A1.RMK_SEQ  = '01'   ]'
        ||CHR(13)||CHR(10)||Q'[                 ) B1   ]'
        ||CHR(13)||CHR(10)||Q'[             ,   STORE_ETC_YM  B2  ]' 
        ||CHR(13)||CHR(10)||Q'[             ,   (  ]'
        ||CHR(13)||CHR(10)||Q'[                 SELECT COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   BRAND_CD ]'     
        ||CHR(13)||CHR(10)||Q'[                    ,   STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   SUM(DECODE( ETC_DIV, '01' , ETC_AMT_HQ, 0)) AS IN_ETC_AMT   ]'
        ||CHR(13)||CHR(10)||Q'[                    ,   SUM(DECODE( ETC_DIV, '02' , ETC_AMT_HQ, 0)) AS OUT_ETC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[                 FROM   STORE_ETC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[                 WHERE  COMP_CD = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    PRC_DT  LIKE :PSV_GFR_DATE || '%'  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    ETC_CD  = '133'  ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    RMK_SEQ = '01'   ]'
        ||CHR(13)||CHR(10)||Q'[                 AND    CONFIRM_YN = 'Y' ]'
        ||CHR(13)||CHR(10)||Q'[                 GROUP BY COMP_CD, BRAND_CD, STOR_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                 ) B3  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE B1.COMP_CD     = B2.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B2.PRC_YM(+)   = :PSV_GFR_DATE  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.BRAND_CD    = B2.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.STOR_CD     = B2.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.ETC_CD      = B2.ETC_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B2.DATA_DIV(+) = '2'  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B2.USE_YN(+)   = 'Y'  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.COMP_CD     = B3.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.BRAND_CD    = B3.BRAND_CD(+) ]'
        ||CHR(13)||CHR(10)||Q'[         AND   B1.STOR_CD     = B3.STOR_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[         UNION  ]'
        ||CHR(13)||CHR(10)||Q'[         SELECT A1.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[            ,   A1.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   MAX(A2.BRAND_NM) AS BRAND_NM]'
        ||CHR(13)||CHR(10)||Q'[            ,   A1.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[            ,   MAX(A2.STOR_NM) AS STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   A1.ETC_CD  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   A1.RMK_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   MAX(A3.RMK_NM) AS RMK_NM  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   NULL                                        AS BEGIN_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   SUM(DECODE( ETC_DIV, '01' , ETC_AMT_HQ, 0)) AS IN_ETC_AMT  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   SUM(DECODE( ETC_DIV, '02' , ETC_AMT_HQ, 0)) AS OUT_ETC_AMT     ]' 
        ||CHR(13)||CHR(10)||Q'[            ,  (ROW_NUMBER() OVER(PARTITION BY  A1.COMP_CD, A1.BRAND_CD, A1.STOR_CD ORDER BY A1.ETC_CD, A1.RMK_SEQ)) AS DISP_SEQ  ]'
        ||CHR(13)||CHR(10)||Q'[         FROM   STORE_ETC_AMT  A1  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   S_STORE        A2  ]'
        ||CHR(13)||CHR(10)||Q'[            ,   ACC_RMK        A3  ]'
        ||CHR(13)||CHR(10)||Q'[         WHERE  A1.COMP_CD  = A2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.BRAND_CD = A2.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.STOR_CD  = A2.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A2.COMP_CD  = A3.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A2.STOR_TP  = A3.STOR_TP   ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.ETC_CD   = A3.ETC_CD    ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.RMK_SEQ  = A3.RMK_SEQ   ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.COMP_CD  = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.PRC_DT  LIKE :PSV_GFR_DATE || '%'  ]'
        ||CHR(13)||CHR(10)||Q'[         AND    A1.ETC_CD  <> '133'      ]'
        ||CHR(13)||CHR(10)||Q'[         AND    CONFIRM_YN = 'Y'  ]'
        ||CHR(13)||CHR(10)||Q'[         GROUP BY A1.COMP_CD, A1.BRAND_CD, A1.STOR_CD, A1.ETC_CD, A1.RMK_SEQ ]'
        ||CHR(13)||CHR(10)||Q'[ ) C1]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY C1.COMP_CD, C1.STOR_CD, C1.DISP_SEQ]'


        ;    

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR

            ls_sql USING PSV_COMP_CD  , PSV_COMP_CD
                        ,PSV_GFR_DATE , PSV_GFR_DATE
                        ,PSV_COMP_CD  , PSV_GFR_DATE  
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

END PKG_ACNT1100;

/
