--------------------------------------------------------
--  DDL for Package Body PKG_ACNT1000
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ACNT1000" AS

    PROCEDURE SP_MAIN
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                -- LOGIN USER
        PSV_PGM_ID      IN  VARCHAR2 ,                -- Progrm ID
        PSV_LANG_CD     IN  VARCHAR2 ,                -- Language Code
        PSV_ORG_CLASS   IN  VARCHAR2 ,                -- 품목 대/중/소 분류 그룹
        PSV_PARA        IN  VARCHAR2 ,                -- Search Parameter
        PSV_FILTER      IN  VARCHAR2 ,                -- Search Filter
        PSV_YYYYMM      IN  VARCHAR2 ,                -- 조회 시작일자
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

        PKG_REPORT.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;

        ls_sql_main := ''


        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[   ,   :PSV_YYYYMM   AS PRC_YM    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    A1.BRAND_CD   ]'
        ||CHR(13)||CHR(10)||Q'[   ,    A1.BRAND_NM   ]'
        ||CHR(13)||CHR(10)||Q'[   ,    A1.STOR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    A1.STOR_NM    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    A2.ETC_AMT    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   S_STORE        A1    ]'
        ||CHR(13)||CHR(10)||Q'[   ,    STORE_ETC_YM   A2    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD     = A2.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD    = A2.BRAND_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD     = A2.STOR_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD     = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.PRC_YM(+)   = :PSV_YYYYMM     ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.DATA_DIV(+) = '1'    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A2.USE_YN(+)   = 'Y'    ]'
        ;



        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR

            ls_sql USING PSV_YYYYMM , PSV_COMP_CD
                       , PSV_YYYYMM 
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

    PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_PRC_YM      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 , 
        PSV_STOR_CD     IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 , 
        PSV_USER        IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    V_DATE_CHECK  VARCHAR2(1) ;

    v_data_div     STORE_ETC_YM.DATA_DIV%TYPE := '1';
    v_etc_cd       STORE_ETC_YM.ETC_CD%TYPE   := '133';
    v_begin_amt    STORE_ETC_YM.BEGIN_AMT%TYPE;

    v_in_etc_amt   STORE_ETC_AMT.ETC_AMT_HQ%TYPE;
    v_out_etc_amt  STORE_ETC_AMT.ETC_AMT_HQ%TYPE;

    ERR_HANDLER     EXCEPTION;

    BEGIN

        BEGIN

            SELECT CASE WHEN TO_DATE(PSV_PRC_YM , 'YYYYMM') < TO_DATE( TO_CHAR(SYSDATE, 'YYYYMM'), 'YYYYMM') THEN 'N'
                        ELSE 'Y'   END 
            INTO   V_DATE_CHECK            
            FROM   DUAL 
            ;

        EXCEPTION 
            WHEN OTHERS THEN
                ls_err_cd  := '-1';
                ls_err_msg := '잘못된 조회년월입니다';

                RAISE ERR_HANDLER;

        END;

        IF V_DATE_CHECK = 'N' THEN

            ls_err_cd  := '-1';
            ls_err_msg := '과거 데이터는 저장할수 없습니다.';

            RAISE ERR_HANDLER;

        END IF;

        -- 이전월 기말 전도금
        BEGIN 

            SELECT NVL(MAX(END_AMT), 0) 
            INTO   v_begin_amt
            FROM   STORE_ETC_YM
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_YM   = TO_CHAR(ADD_MONTHS(TO_DATE( PSV_PRC_YM , 'YYYYMM'), -1), 'YYYYMM')
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    DATA_DIV = v_data_div
            ; 

        END;

        -- 이전월 입금 계정금액
        BEGIN

            SELECT NVL(SUM(ETC_AMT_HQ), 0)
            INTO   v_in_etc_amt
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD    = PSV_COMP_CD
            AND    PRC_DT     LIKE TO_CHAR(ADD_MONTHS(TO_DATE( PSV_PRC_YM , 'YYYYMM'), -1), 'YYYYMM') || '%'
            AND    BRAND_CD   = PSV_BRAND_CD
            AND    STOR_CD    = PSV_STOR_CD
            AND    ETC_DIV    = '01'
            AND    CONFIRM_YN = 'Y'
            ;

        END;

        -- 이전월 출금 계정 금액
        BEGIN

            SELECT NVL(SUM(ETC_AMT_HQ), 0)
            INTO   v_out_etc_amt
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD    = PSV_COMP_CD
            AND    PRC_DT     LIKE TO_CHAR(ADD_MONTHS(TO_DATE( PSV_PRC_YM , 'YYYYMM'), -1), 'YYYYMM') || '%'
            AND    BRAND_CD   = PSV_BRAND_CD
            AND    STOR_CD    = PSV_STOR_CD
            AND    ETC_DIV    = '02'
            AND    CONFIRM_YN = 'Y'
            ;

        END;

        BEGIN

            MERGE INTO STORE_ETC_YM   A1
            USING (
                     SELECT PSV_COMP_CD   AS COMP_CD
                        ,   PSV_PRC_YM    AS PRC_YM
                        ,   PSV_BRAND_CD  AS BRAND_CD
                        ,   PSV_STOR_CD   AS STOR_CD
                        ,   v_data_div    AS DATA_DIV 
                        ,   v_etc_cd      AS ETC_CD                        
                        ,   PSV_ETC_AMT   AS ETC_AMT
                        ,   v_begin_amt   AS BEGIN_AMT
                        ,   v_begin_amt + v_in_etc_amt - v_out_etc_amt   AS END_AMT
                        ,   'Y'           AS USE_YN
                        ,   PSV_USER      AS INST_USER
                        ,   SYSDATE       AS INST_DT
                     FROM   DUAL               
            ) A2 
            ON (     A1.COMP_CD  = A2.COMP_CD
                 AND A1.PRC_YM   = A2.PRC_YM
                 AND A1.BRAND_CD = A2.BRAND_CD
                 AND A1.STOR_CD  = A2.STOR_CD
                 AND A1.DATA_DIV = A2.DATA_DIV
            )
            WHEN NOT MATCHED THEN
                INSERT (
                      A1.COMP_CD
                    , A1.PRC_YM
                    , A1.BRAND_CD
                    , A1.STOR_CD
                    , A1.DATA_DIV
                    , A1.ETC_CD
                    , A1.ETC_AMT
                    , A1.BEGIN_AMT
                    , A1.END_AMT
                    , A1.ETC_DESC
                    , A1.USE_YN
                    , A1.INST_DT
                    , A1.INST_USER
                    , A1.UPD_DT
                    , A1.UPD_USER
                ) VALUES (
                      A2.COMP_CD
                    , A2.PRC_YM
                    , A2.BRAND_CD
                    , A2.STOR_CD
                    , A2.DATA_DIV
                    , A2.ETC_CD
                    , A2.ETC_AMT
                    , A2.BEGIN_AMT
                    , A2.END_AMT
                    , NULL
                    , A2.USE_YN
                    , A2.INST_DT
                    , A2.INST_USER
                    , A2.INST_DT
                    , A2.INST_USER  
                )
            WHEN MATCHED THEN
                UPDATE
                SET   A1.ETC_CD     = A2.ETC_CD
                    , A1.ETC_AMT    = A2.ETC_AMT
                    , A1.BEGIN_AMT  = A2.BEGIN_AMT
                    , A1.END_AMT    = A2.END_AMT
                    , A1.USE_YN     = A2.USE_YN
                    , A1.UPD_DT     = A2.INST_DT
                    , A1.UPD_USER   = A2.INST_USER
             ;            


        END;

        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

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

END PKG_ACNT1000;

/
