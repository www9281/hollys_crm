--------------------------------------------------------
--  DDL for Package Body PKG_ACNT1010
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_ACNT1010" AS

    
    PROCEDURE SEARCH
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
        PSV_PRC_DT      IN  VARCHAR2 ,                --
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,  -- Result Set
        PR_RTN_CD       OUT VARCHAR2 ,                -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
    )
    IS
    /******************************************************************************
       NAME:       SEARCH     개별입고 등록 - 파일업로드  조회
       PURPOSE:

       REVISIONS:
       VER        DATE        AUTHOR           DESCRIPTION
       ---------  ----------  ---------------  ------------------------------------
       1.0        2016-01-20         1. CREATED THIS PROCEDURE.

       NOTES:

       OBJECT NAME:     SEARCH
       SYSDATE:         2017-08-08
       USERNAME:
       TABLE NAME:
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

        /* MAIN SQL */
        ls_sql_main := ''

        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DT       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.BRAND_NM     ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.SEQ          ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BANK_NM      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ACC_NO       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ACC_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.HQ_USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.USER_NM     AS HQ_USER_NM      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DIV      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_MSG      ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   STORE_ETC_FILE_UPLOAD  A1      ]'
        ||CHR(13)||CHR(10)||Q'[   ,    S_STORE                A2      ]'
        ||CHR(13)||CHR(10)||Q'[   ,    HQ_USER                A3      ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD(+)  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.HQ_USER_ID = A3.USER_ID(+)  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.SEQ = (      ]'
        ||CHR(13)||CHR(10)||Q'[                     SELECT  MAX(B1.SEQ)      ]'
        ||CHR(13)||CHR(10)||Q'[                     FROM    STORE_ETC_FILE_UPLOAD  B1    ]'
        ||CHR(13)||CHR(10)||Q'[                     WHERE   B1.COMP_CD  = A1.COMP_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     B1.PRC_DT   = A1.PRC_DT      ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     B1.BRAND_CD = A1.BRAND_CD    ]'
        ||CHR(13)||CHR(10)||Q'[                     AND     B1.STOR_CD  = A1.STOR_CD     ]'
        ||CHR(13)||CHR(10)||Q'[                 )      ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.PRC_DT  = :PSV_PRC_DT     ]'   

        ;

        ls_sql := ls_sql || ls_sql_main;
        dbms_output.put_line(ls_sql);

        OPEN PR_RESULT FOR
            ls_sql USING PSV_COMP_CD, PSV_PRC_DT;


        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg ;

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
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_STOR_CD     IN  VARCHAR2 ,                  --
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_BANK_NM     IN  VARCHAR2 ,                  --
        PSV_ACC_NO      IN  VARCHAR2 ,                  -- 
        PSV_ACC_NM      IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    V_DATE_CHECK  VARCHAR2(1) ;

    v_brand_cd     STORE_ETC_FILE_UPLOAD.BRAND_CD%TYPE; 
    v_stor_cd      STORE_ETC_FILE_UPLOAD.STOR_CD%TYPE;
    v_seq          STORE_ETC_FILE_UPLOAD.SEQ%TYPE;
    v_etc_amt      STORE_ETC_FILE_UPLOAD.ETC_AMT%TYPE;

    v_err_cd       STORE_ETC_FILE_UPLOAD.ERR_CD%TYPE  := '10000' ;
    v_err_msg      STORE_ETC_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      STORE_ETC_FILE_UPLOAD.PRC_DIV%TYPE := 'N';
    v_user_id      STORE_ETC_FILE_UPLOAD.HQ_USER_ID%TYPE;


    ERR_HANDLER     EXCEPTION;

    BEGIN

        BEGIN

            SELECT CASE WHEN TO_DATE(PSV_PRC_DT, 'YYYYMMDD') > TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                        ELSE 'Y' END 
            INTO   V_DATE_CHECK              
            FROM   DUAL
            ;

        EXCEPTION WHEN OTHERS THEN

            ls_err_cd  := '-1';
            ls_err_msg := '출금일자가 잘못되었습니다. (출금일자:' || PSV_PRC_DT || ')';

            RAISE ERR_HANDLER;

        END;

        IF ( V_DATE_CHECK <> 'Y' ) THEN

            ls_err_cd  := '-1';
            ls_err_msg := '출금일자가 잘못되었습니다. (출금일자:' || PSV_PRC_DT || ')';

            RAISE ERR_HANDLER;

        END IF;

        BEGIN

            SELECT  BRAND_CD, STOR_CD
            INTO    v_brand_cd, v_stor_cd
            FROM    STORE
            WHERE   COMP_CD = PSV_COMP_CD
            AND     STOR_CD = PSV_STOR_CD
            AND     USE_YN  = 'Y'
            ;

        EXCEPTION 
            WHEN OTHERS THEN
                v_stor_cd  := 'ERROR';


        END;


        IF ( v_stor_cd <> 'ERROR' ) THEN

            IF( PSV_SEQ IS NULL OR PSV_SEQ = '' ) THEN    

                SELECT NVL(MAX(SEQ), 0)+1
                INTO   v_seq
                FROM   STORE_ETC_FILE_UPLOAD
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    PRC_DT   = PSV_PRC_DT
                AND    BRAND_CD = v_brand_cd
                AND    STOR_CD  = v_stor_cd   
                ;

            ELSE

                v_seq := PSV_SEQ;

                BEGIN

                    SELECT PRC_DIV
                    INTO   v_prc_div
                    FROM   STORE_ETC_FILE_UPLOAD
                    WHERE  COMP_CD  = PSV_COMP_CD
                    AND    PRC_DT   = PSV_PRC_DT
                    AND    BRAND_CD = v_brand_cd
                    AND    STOR_CD  = v_stor_cd   
                    AND    SEQ      = PSV_SEQ;

                EXCEPTION 
                    WHEN OTHERS THEN

                    ls_err_cd  := '-1';
                    ls_err_msg := '데이터를 찾을수 없습니다.';

                    RAISE ERR_HANDLER;

                END;

            END IF;

            IF(  v_prc_div <> 'Y' ) THEN

                v_prc_div := 'N';

                IF (PSV_BANK_NM IS NULL OR PSV_BANK_NM = '' ) THEN

                    v_err_cd  := TO_NUMBER(v_err_cd) + 3;
                    v_err_msg := '은행명이 없습니다.';
                    v_prc_div := 'E';

                END IF;

                IF (PSV_ACC_NO IS NULL OR PSV_ACC_NO = '' ) THEN

                    v_err_cd  := TO_NUMBER(v_err_cd) + 5;
                    v_err_msg := v_err_msg || '계좌번호가 없습니다.';
                    v_prc_div := 'E';

                END IF;

                IF (PSV_ACC_NM IS NULL OR PSV_ACC_NM = '' ) THEN

                    v_err_cd  := TO_NUMBER(v_err_cd) + 7;
                    v_err_msg := v_err_msg || '예금주명이 없습니다.';
                    v_prc_div := 'E';

                END IF;

                IF ( PSV_ETC_AMT IS NULL OR PSV_ETC_AMT = '' OR PSV_ETC_AMT = '0' OR REGEXP_INSTR(PSV_ETC_AMT ,'[^0-9]') <> 0 ) THEN

                    v_etc_amt := '0';
                    v_err_cd  := TO_NUMBER(v_err_cd) + 11;
                    v_err_msg := v_err_msg || '출금액이 잘못되었습니다.';
                    v_prc_div := 'E';

                ELSE 
                    v_etc_amt := PSV_ETC_AMT;

                END IF;

                BEGIN

                    MERGE INTO STORE_ETC_FILE_UPLOAD  A1
                    USING (
                            SELECT PSV_COMP_CD   AS COMP_CD
                               ,   PSV_PRC_DT    AS PRC_DT
                               ,   v_brand_cd    AS BRAND_CD
                               ,   v_stor_cd     AS STOR_CD
                               ,   v_seq         AS SEQ
                               ,   PSV_BANK_NM   AS BANK_NM
                               ,   PSV_ACC_NO    AS ACC_NO
                               ,   PSV_ACC_NM    AS ACC_NM
                               ,   v_etc_amt     AS ETC_AMT
                               ,   PSV_USER_ID   AS HQ_USER_ID
                               ,   v_prc_div     AS PRC_DIV
                               ,   DECODE(v_prc_div, 'E' , v_err_cd,  '')     AS ERR_CD
                               ,   DECODE(v_prc_div, 'E' , v_err_msg, '')     AS ERR_MSG
                               ,   SYSDATE       AS INST_DT
                            FROM   DUAL
                    ) A2
                    ON (     A1.COMP_CD  = A2.COMP_CD
                         AND A1.PRC_DT   = A2.PRC_DT
                         AND A1.BRAND_CD = A2.BRAND_CD
                         AND A1.STOR_CD  = A2.STOR_CD
                         AND A1.SEQ      = A2.SEQ
                    )
                    WHEN NOT MATCHED THEN
                        INSERT (
                                A1.COMP_CD
                            ,   A1.PRC_DT
                            ,   A1.BRAND_CD
                            ,   A1.STOR_CD
                            ,   A1.SEQ
                            ,   A1.BANK_NM
                            ,   A1.ACC_NO
                            ,   A1.ACC_NM
                            ,   A1.ETC_AMT
                            ,   A1.HQ_USER_ID
                            ,   A1.PRC_DIV
                            ,   A1.ERR_CD
                            ,   A1.ERR_MSG
                            ,   A1.INST_DT
                            ,   A1.INST_USER
                            ,   A1.UPD_DT
                            ,   A1.UPD_USER
                        ) VALUES (
                                A2.COMP_CD
                            ,   A2.PRC_DT
                            ,   A2.BRAND_CD
                            ,   A2.STOR_CD
                            ,   A2.SEQ
                            ,   A2.BANK_NM
                            ,   A2.ACC_NO
                            ,   A2.ACC_NM
                            ,   A2.ETC_AMT
                            ,   A2.HQ_USER_ID
                            ,   A2.PRC_DIV
                            ,   A2.ERR_CD
                            ,   A2.ERR_MSG
                            ,   A2.INST_DT
                            ,   A2.HQ_USER_ID
                            ,   A2.INST_DT
                            ,   A2.HQ_USER_ID
                        )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     A1.BANK_NM    = A2.BANK_NM
                           ,    A1.ACC_NO     = A2.ACC_NO
                           ,    A1.ACC_NM     = A2.ACC_NM
                           ,    A1.ETC_AMT    = A2.ETC_AMT
                           ,    A1.HQ_USER_ID = A2.HQ_USER_ID        
                           ,    A1.PRC_DIV    = A2.PRC_DIV
                           ,    A1.ERR_CD     = A2.ERR_CD
                           ,    A1.ERR_MSG    = A2.ERR_MSG
                           ,    A1.UPD_DT     = A2.INST_DT
                           ,    A1.UPD_USER   = A2.HQ_USER_ID
                     ;

                EXCEPTION 
                    WHEN OTHERS THEN        
                        ls_err_cd  := '-1';
                        ls_err_msg := 'STORE_ETC_FILE_UPLOAD 저장 오류' || SQLERRM;

                        RAISE ERR_HANDLER;

                END;

            END IF;

        END IF;


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

    PROCEDURE SAVE_FIX
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS

    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;

    V_DATE_CHECK  VARCHAR2(1) ;
    V_DUP_CHECK   VARCHAR2(1) := 'N';
    V_IS_HIS      VARCHAR2(1) := 'Y';

    v_err_cd       STORE_ETC_FILE_UPLOAD.ERR_CD%TYPE;
    v_err_msg      STORE_ETC_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      STORE_ETC_FILE_UPLOAD.PRC_DIV%TYPE;
    v_seq          STORE_ETC_AMT.SEQ%TYPE;

    v_pos_no       STORE_ETC_AMT.POS_NO%TYPE  := 'HQ';
    v_etc_div      STORE_ETC_AMT.ETC_DIV%TYPE := '01'; -- 입출금구분[00820>01:입금계정, 02:출금계정]

    /*
    v_stor_cd      ORDER_FILE_UPLOAD.STOR_CD%TYPE;
    v_item_cd      ORDER_FILE_UPLOAD.ITEM_CD%TYPE;
    v_ord_qty      ORDER_FILE_UPLOAD.ORD_QTY%TYPE;
    v_err_cd       ORDER_FILE_UPLOAD.ERR_CD%TYPE;
    v_err_msg      ORDER_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      ORDER_FILE_UPLOAD.PRC_DIV%TYPE;
    v_user_id      ORDER_FILE_UPLOAD.ORD_USER_ID%TYPE;
    v_use_yn       ITEM_CHAIN.USE_YN%TYPE;
    v_ord_sale_div ITEM_CHAIN.ORD_SALE_DIV%TYPE;

    v_brand_cd     STORE.BRAND_CD%TYPE;
    v_stor_tp      STORE.STOR_TP%TYPE; 
    v_ord_no       ORDER_HDV.ORD_NO%TYPE;
    v_ord_seq      ORDER_DTV.ORD_SEQ%TYPE;
    */

    ERR_HANDLER        EXCEPTION;
    ERR_UPDATE_HANDLER EXCEPTION;
    SKIP_HANDLER       EXCEPTION;

    BEGIN

        BEGIN

            SELECT PRC_DIV
            INTO   v_prc_div
            FROM   STORE_ETC_FILE_UPLOAD
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    SEQ      = PSV_SEQ
            ;

        EXCEPTION 
            WHEN OTHERS THEN
                RAISE SKIP_HANDLER;
        END;

        IF ( v_prc_div = 'Y' OR v_prc_div = 'E' ) THEN

            RAISE SKIP_HANDLER;

        END IF;

        BEGIN 

            SELECT NVL(MAX(SEQ), 0) + 1
            INTO   v_seq
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    POS_NO   = v_pos_no
            AND    ETC_DIV  = v_etc_div
            ;


        END;

        BEGIN

            INSERT INTO STORE_ETC_AMT (
                  COMP_CD
                , PRC_DT
                , BRAND_CD
                , STOR_CD
                , POS_NO
                , ETC_DIV
                , SEQ
                , ETC_CD
                , ETC_AMT
                , ETC_AMT_HQ
                , CARD_AMT
                , CUST_ID
                , USER_ID
                , ETC_TP
                , ETC_TM
                , RMK_SEQ
                , EVID_DOC
                , ETC_DESC
                , PURCHASE_CD
                , STOR_PAY_DIV
                , APPR_NO
                , APPR_DT
                , APPR_TM
                , HQ_USER_ID
                , BANK_NM
                , ACC_NO
                , ACC_NM
                , CONFIRM_YN
                , CONFIRM_DT
                , DEL_YN
                , INST_DT
                , INST_USER
                , UPD_DT
                , UPD_USER
                , INPUT_TP
                , SEQ_EXCEL
            ) 
            SELECT   
                  COMP_CD
                , PRC_DT
                , BRAND_CD
                , STOR_CD
                , v_pos_no
                , v_etc_div
                , v_seq
                , '133'
                , ETC_AMT
                , ETC_AMT
                , 0
                , NULL
                , NULL
                , '10'
                , TO_CHAR( SYSDATE, 'HH24MISS')
                , '01'
                , '00'
                , '전도금'
                , NULL
                , '02'
                , NULL
                , NULL
                , NULL
                , HQ_USER_ID
                , BANK_NM
                , ACC_NO
                , ACC_NM
                , 'N'
                , NULL
                , 'N'
                , SYSDATE
                , PSV_USER_ID
                , SYSDATE
                , PSV_USER_ID
                , '1' 
                , SEQ
            FROM  STORE_ETC_FILE_UPLOAD
            WHERE COMP_CD  = PSV_COMP_CD
            AND   PRC_DT   = PSV_PRC_DT
            AND   BRAND_CD = PSV_BRAND_CD
            AND   STOR_CD  = PSV_STOR_CD
            AND   SEQ      = PSV_SEQ
            ;

        EXCEPTION 
            WHEN DUP_VAL_ON_INDEX THEN
                v_err_cd  := '10031';
                v_err_msg := 'STORE_ETC_AMT 중복 오류';                
                RAISE ERR_UPDATE_HANDLER;
            WHEN OTHERS THEN
                v_err_cd  := '10037';
                v_err_msg := 'STORE_ETC_AMT 저장 오류';
                RAISE ERR_UPDATE_HANDLER;

        END;


        BEGIN

            UPDATE STORE_ETC_FILE_UPLOAD
            SET    PRC_DIV  = 'Y'
               ,   UPD_DT   = SYSDATE
               ,   UPD_USER = PSV_USER_ID
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    SEQ      = PSV_SEQ
            ;

        END;



        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;

        COMMIT;

    EXCEPTION
        WHEN SKIP_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

        WHEN ERR_UPDATE_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;

            ROLLBACK;

            BEGIN

                UPDATE STORE_ETC_FILE_UPLOAD
                SET    PRC_DIV  = 'E'
                   ,   ERR_CD   = v_err_cd
                   ,   ERR_MSG  = v_err_msg
                   ,   UPD_DT   = SYSDATE
                   ,   UPD_USER = PSV_USER_ID
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    PRC_DT   = PSV_PRC_DT
                AND    BRAND_CD = PSV_BRAND_CD
                AND    STOR_CD  = PSV_STOR_CD
                AND    SEQ      = PSV_SEQ
                ;

            END;

            COMMIT;
            dbms_output.put_line( PR_RTN_MSG );
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';

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


END PKG_ACNT1010;

/
