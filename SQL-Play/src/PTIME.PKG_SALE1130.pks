CREATE OR REPLACE PACKAGE      PKG_SALE1130 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_SALE1130
    --  Description      : 판매주문 소요시간 현황
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

END PKG_SALE1130;

/

CREATE OR REPLACE PACKAGE BODY       PKG_SALE1130 AS

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
        NAME:       SP_MAIN         판매주문 소요시간 현황
        PURPOSE:
        
        REVISIONS:
        VER        DATE        AUTHOR           DESCRIPTION
        ---------  ----------  ---------------  ------------------------------------
        1.0        2016-02-29         1. CREATED THIS PROCEDURE.
        
        NOTES:
            OBJECT NAME :   SP_MAIN
            SYSDATE     :   2016-02-29
            USERNAME    :
            TABLE NAME  :
    ******************************************************************************/
    ls_sql          VARCHAR2(30000);
    ls_sql_with     VARCHAR2(30000);
    ls_sql_main     VARCHAR2(30000);
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
        ||CHR(13)||CHR(10)||Q'[ SELECT  MAX(TM_NM)          AS TM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[      ,  CASE WHEN MAX(BILL_CNT) <> 0 THEN FN_GET_FROMAT_MMSS(TO_CHAR(ROUND(MAX(TERM_SEC) / MAX(BILL_CNT)))) ]'
        ||CHR(13)||CHR(10)||Q'[              ELSE '00:00'              ]'
        ||CHR(13)||CHR(10)||Q'[         END                 AS AVG_TM  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(BILL_CNT)       AS BILL_CNT]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '1'  THEN 1 ELSE 0 END)   AS TERM_MIN_01  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '2'  THEN 1 ELSE 0 END)   AS TERM_MIN_02  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '3'  THEN 1 ELSE 0 END)   AS TERM_MIN_03  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '4'  THEN 1 ELSE 0 END)   AS TERM_MIN_04  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '5'  THEN 1 ELSE 0 END)   AS TERM_MIN_05  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '6'  THEN 1 ELSE 0 END)   AS TERM_MIN_06  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '7'  THEN 1 ELSE 0 END)   AS TERM_MIN_07  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '8'  THEN 1 ELSE 0 END)   AS TERM_MIN_08  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '9'  THEN 1 ELSE 0 END)   AS TERM_MIN_09  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '10' THEN 1 ELSE 0 END)   AS TERM_MIN_10  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '11' THEN 1 ELSE 0 END)   AS TERM_MIN_11  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '12' THEN 1 ELSE 0 END)   AS TERM_MIN_12  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '13' THEN 1 ELSE 0 END)   AS TERM_MIN_13  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '14' THEN 1 ELSE 0 END)   AS TERM_MIN_14  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '15' THEN 1 ELSE 0 END)   AS TERM_MIN_15  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '16' THEN 1 ELSE 0 END)   AS TERM_MIN_16  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '17' THEN 1 ELSE 0 END)   AS TERM_MIN_17  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '18' THEN 1 ELSE 0 END)   AS TERM_MIN_18  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '19' THEN 1 ELSE 0 END)   AS TERM_MIN_19  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '20' THEN 1 ELSE 0 END)   AS TERM_MIN_20  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '21' THEN 1 ELSE 0 END)   AS TERM_MIN_21  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '22' THEN 1 ELSE 0 END)   AS TERM_MIN_22  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '23' THEN 1 ELSE 0 END)   AS TERM_MIN_23  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '24' THEN 1 ELSE 0 END)   AS TERM_MIN_24  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '25' THEN 1 ELSE 0 END)   AS TERM_MIN_25  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  SUM(CASE WHEN TERM_MIN = '26' THEN 1 ELSE 0 END)   AS TERM_MIN_26  ]'
        ||CHR(13)||CHR(10)||Q'[      ,  MAX(TERM_SEC)                                    AS TOT_TERM_SEC   ]'
        ||CHR(13)||CHR(10)||Q'[   FROM  (  ]'
        ||CHR(13)||CHR(10)||Q'[             SELECT  SUBSTR(SH.SORD_TM, 1, 2)                                            AS TM_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUBSTR(SH.SORD_TM, 1, 2)||':00~'||SUBSTR(SH.SORD_TM, 1, 2)||':59'   AS TM_NM    ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  CASE WHEN TRUNC((TO_DATE(SHK.EORD_TM, 'HH24MISS') - TO_DATE(SH.SORD_TM, 'HH24MISS')) * 24 * 60) > 25 THEN 26    ]'
        ||CHR(13)||CHR(10)||Q'[                          ELSE TRUNC((TO_DATE(SHK.EORD_TM, 'HH24MISS') - TO_DATE(SH.SORD_TM, 'HH24MISS')) * 24 * 60)                 ]'
        ||CHR(13)||CHR(10)||Q'[                     END                                                                 AS TERM_MIN ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SUM((TO_DATE(SHK.EORD_TM, 'HH24MISS') - TO_DATE(SH.SORD_TM, 'HH24MISS')) * 24 * 60 * 60)  OVER (PARTITION BY SH.COMP_CD, SH.SALE_DT, SH.BRAND_CD, SH.STOR_CD, SUBSTR(SH.SORD_TM, 1, 2)) AS TERM_SEC ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  COUNT(*) OVER (PARTITION BY SH.COMP_CD, SH.BRAND_CD, SH.STOR_CD, SUBSTR(SH.SORD_TM, 1, 2))  AS BILL_CNT ]'
        ||CHR(13)||CHR(10)||Q'[               FROM  SALE_HD     SH  ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  S_STORE     S   ]'
        ||CHR(13)||CHR(10)||Q'[                  ,  SALE_HD_KD  SHK ]'
        ||CHR(13)||CHR(10)||Q'[              WHERE  SH.COMP_CD  = S.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD = S.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD  = S.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD  = SHK.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT  = SHK.SALE_DT   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BRAND_CD = SHK.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.STOR_CD  = SHK.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.POS_NO   = SHK.POS_NO    ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.BILL_NO  = SHK.BILL_NO   ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.COMP_CD  = :PSV_COMP_CD  ]'
        ||CHR(13)||CHR(10)||Q'[                AND  SH.SALE_DT  BETWEEN :PSV_GFR_DATE AND :PSV_GTO_DATE ]'
        ||CHR(13)||CHR(10)||Q'[         )   A       ]'
        ||CHR(13)||CHR(10)||Q'[  GROUP  BY TM_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[  ORDER  BY TM_DIV   ]';
              
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
    
END PKG_SALE1130;

/
