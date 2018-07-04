--------------------------------------------------------
--  DDL for Package Body PKG_ATTD4220
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ATTD4220" AS

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
        PSV_CODE_DIV    IN  VARCHAR2 ,                  -- 코드구분(상품코드, 대표코드)
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
        NAME:       SP_MAIN    상품 매출순위
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
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''


        ||CHR(13)||CHR(10)||Q'[ SELECT ATTD_DT    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      USER_NM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      CONFIRM_START_DTM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      CONFIRM_CLOSE_DTM    ]' 
        ||CHR(13)||CHR(10)||Q'[ ,      WORK_TIME  ]'
        ||CHR(13)||CHR(10)||Q'[ ,      (FLOOR (WORK_TIME)) ||'시간'||' ' || LPAD(FLOOR (MOD( (WORK_TIME *60), 60) ), 2, 0) ||'분' AS WORK_HHMM    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      HOUR_PAY   ]'
        ||CHR(13)||CHR(10)||Q'[ ,      DAY_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[ ,      WEEK_PAY   ]'
        ||CHR(13)||CHR(10)||Q'[ ,      WORK_DIV_NM   ]'
        ||CHR(13)||CHR(10)||Q'[ ,      DAY_PAY + WEEK_PAY AS TOTAL_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   (    ]'
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.ATTD_DT     ]' 
        ||CHR(13)||CHR(10)||Q'[    ,   A1.USER_ID     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.USER_NM     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   NVL(A4.BASIC_PAY, 0) AS HOUR_PAY ]'
        ||CHR(13)||CHR(10)||Q'[    ,   SUBSTR(A1.CONFIRM_START_DTM, 9, 2) || ':' || SUBSTR(A1.CONFIRM_START_DTM, 11, 2)  AS CONFIRM_START_DTM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   SUBSTR(A1.CONFIRM_CLOSE_DTM, 9, 2) || ':' || SUBSTR(A1.CONFIRM_CLOSE_DTM, 11, 2)  AS CONFIRM_CLOSE_DTM    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ROUND( (TO_DATE(A1.CONFIRM_CLOSE_DTM, 'YYYYMMDDHH24MISS') - TO_DATE(A1.CONFIRM_START_DTM, 'YYYYMMDDHH24MISS')) *24 , 2) AS WORK_TIME    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   NVL(A4.BASIC_PAY, 0) * ROUND( (TO_DATE(A1.CONFIRM_CLOSE_DTM, 'YYYYMMDDHH24MISS') - TO_DATE(A1.CONFIRM_START_DTM, 'YYYYMMDDHH24MISS')) *24 ) AS DAY_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ROUND(DECODE( NVL(A1.WEEK_DIV, 'N') , 'Y', NVL(A4.BASIC_PAY, 0) , 0) * A4.DAY_HOURS) AS WEEK_PAY    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   DENSE_RANK() over(PARTITION BY A4.COMP_CD, A4.BRAND_CD, A4.STOR_CD, A4.USER_ID ORDER BY ATTD_PAY_DT DESC)  ATTD_PAY_RANK    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A5.CODE_NM  AS WORK_DIV_NM    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   ATTENDANCE     A1    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    S_STORE        A2    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE_USER     A3    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE_PAY_MST  A4    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    COMMON         A5    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A3.BRAND_CD          ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A3.STOR_CD           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A3.USER_ID           ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A3.EMP_DIV    = '5'                  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A4.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A4.BRAND_CD(+)       ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A4.STOR_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.USER_ID    = A4.USER_ID(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ATTD_DT   >= A4.ATTD_PAY_DT(+)    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A4.ATTD_PAY_DIV(+) = '1'             ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A5.COMP_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.WORK_DIV   = A5.CODE_CD(+)        ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A5.CODE_TP(+) = '02000'              ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ATTD_DT    BETWEEN :PSV_GFR_DATE AND  :PSV_GTO_DATE    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    ( A1.WORK_DIV = NVL(:PSV_CODE_DIV, A1.WORK_DIV )  OR (:PSV_CODE_DIV IS NULL AND A1.WORK_DIV IS NULL ))  ]'
        ||CHR(13)||CHR(10)||Q'[ --AND    A1.CONFIRM_YN = 'Y'    ]'
        ||CHR(13)||CHR(10)||Q'[ )    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE ATTD_PAY_RANK = '1'    ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY ATTD_DT, USER_ID, CONFIRM_START_DTM  ]'
        ;




        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line('==>' || PSV_CODE_DIV);
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR

            ls_sql USING PSV_GFR_DATE, PSV_GTO_DATE
                       , PSV_CODE_DIV, PSV_CODE_DIV;


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

END PKG_ATTD4220;

/
