CREATE OR REPLACE PACKAGE       PKG_ACNT1020 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ACNT1010
    --  Description      : 본사 전도금 출금 
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    
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
    );
    
     PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,                  --
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,        
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_BANK_NM     IN  VARCHAR2 ,
        PSV_ACC_NO      IN  VARCHAR2 ,                  -- 
        PSV_ACC_NM      IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 ,
        PSV_HQ_USER_ID  IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
     PROCEDURE SAVE_DELETE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
                    
    
END PKG_ACNT1020;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ACNT1020 AS

    
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

        PKG_REPORT_REP.RPT_PARA(PSV_COMP_CD,  PSV_USER,    PSV_PGM_ID, PSV_LANG_CD, PSV_ORG_CLASS, PSV_PARA, PSV_FILTER,
                        ls_sql_store, ls_sql_item, ls_date1,   ls_ex_date1, ls_date2, ls_ex_date2 );


        ls_sql := ' WITH  '
               ||  ls_sql_store -- S_STORE
        --       ||  ', '
        --       ||  ls_sql_item  -- S_ITEM
        ;
        
        /* MAIN SQL */
        ls_sql_main := ''
        
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DT        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BRAND_CD      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.BRAND_NM      ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.POS_NO        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_DIV       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.SEQ           ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.BANK_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ACC_NO        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ACC_NM        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ETC_AMT       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.HQ_USER_ID    AS USER_ID ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.USER_NM       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.CONFIRM_YN    ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   STORE_ETC_AMT  A1    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   S_STORE        A2    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   HQ_USER        A3    ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD    = A2.COMP_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.BRAND_CD   = A2.BRAND_CD  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD    = A2.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = A3.COMP_CD(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.HQ_USER_ID = A3.USER_ID(+)]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD    = :PSV_COMP_CD ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.PRC_DT     = :PSV_PRC_DT  ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ETC_DIV    = '01'         ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.DEL_YN     = 'N'          ]'
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
        PSV_BRAND_CD    IN  VARCHAR2 ,
        PSV_STOR_CD     IN  VARCHAR2 ,                  --
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,        
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_BANK_NM     IN  VARCHAR2 ,
        PSV_ACC_NO      IN  VARCHAR2 ,                  -- 
        PSV_ACC_NM      IN  VARCHAR2 ,
        PSV_ETC_AMT     IN  VARCHAR2 ,
        PSV_HQ_USER_ID  IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    V_DATE_CHECK  VARCHAR2(1) ;
    
    v_brand_cd     STORE_ETC_AMT.BRAND_CD%TYPE; 
    v_seq          STORE_ETC_AMT.SEQ%TYPE;
    v_confirm_yn   STORE_ETC_AMT.CONFIRM_YN%TYPE;   
    
    v_etc_amt      STORE_ETC_FILE_UPLOAD.ETC_AMT%TYPE;
    
    v_err_cd       STORE_ETC_FILE_UPLOAD.ERR_CD%TYPE  := '10000' ;
    v_err_msg      STORE_ETC_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      STORE_ETC_FILE_UPLOAD.PRC_DIV%TYPE := 'N';
    v_user_id      STORE_ETC_FILE_UPLOAD.HQ_USER_ID%TYPE;
    
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
    
        IF ( PSV_BRAND_CD IS NULL OR PSV_BRAND_CD = '' ) THEN
        
            BEGIN
            
                SELECT BRAND_CD
                INTO   v_brand_cd
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = PSV_STOR_CD
                ;
            
            EXCEPTION 
                WHEN OTHERS THEN
                    ls_err_cd    := '-1';
                    ls_err_msg   := '잘못된 점포코드입니다. 점포코드 (' || PSV_STOR_CD || ')';
                    
                    RAISE ERR_HANDLER;
            
            END;
            
        ELSE
            v_brand_cd := PSV_BRAND_CD; 
        
        END IF;
        
    
        IF ( PSV_SEQ IS NULL OR PSV_SEQ = '' ) THEN
        
            BEGIN
            
                SELECT NVL(MAX(SEQ) , 0) + 1
                INTO   v_seq
                FROM   STORE_ETC_AMT
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    PRC_DT   = PSV_PRC_DT
                AND    BRAND_CD = v_brand_cd
                AND    STOR_CD  = PSV_STOR_CD
                AND    POS_NO   = PSV_POS_NO
                AND    ETC_DIV  = PSV_ETC_DIV
                ;
            
            EXCEPTION 
                WHEN OTHERS THEN
                    ls_err_cd    := '-1';
                    ls_err_msg   := SQLERRM;
                    
                    RAISE ERR_HANDLER;
            
            END;
            
        ELSE 
            v_seq := PSV_SEQ;
            
        END IF;
        
        
        BEGIN
        
            SELECT NVL(MAX(CONFIRM_YN), 'N')
            INTO   v_confirm_yn
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = v_brand_cd
            AND    STOR_CD  = PSV_STOR_CD
            AND    POS_NO   = PSV_POS_NO
            AND    ETC_DIV  = PSV_ETC_DIV
            AND    SEQ      = v_seq
            ;
        
        EXCEPTION
            WHEN OTHERS THEN     
                ls_err_cd    := '-1';
                ls_err_msg   := SQLERRM;
                        
                RAISE ERR_HANDLER;
        
        END;
        
        IF( v_confirm_yn = 'N') THEN
        
            BEGIN
            
                MERGE INTO STORE_ETC_AMT  A1
                USING  (
                        SELECT PSV_COMP_CD   AS COMP_CD
                           ,   PSV_PRC_DT    AS PRC_DT
                           ,   v_brand_cd    AS BRAND_CD
                           ,   PSV_STOR_CD   AS STOR_CD
                           ,   PSV_POS_NO    AS POS_NO
                           ,   PSV_ETC_DIV   AS ETC_DIV
                           ,   v_seq         AS SEQ
                           ,   '133'         AS ETC_CD
                           ,   PSV_ETC_AMT   AS ETC_AMT
                           ,   PSV_ETC_AMT   AS ETC_AMT_HQ
                           ,   0             AS CARD_AMT
                           ,   NULL          AS CUST_ID
                           ,   NULL          AS USER_ID 
                           ,   '10'          AS ETC_TP
                           ,   TO_CHAR( SYSDATE, 'HH24MISS') AS ETC_TM
                           ,   '01'          AS RMK_SEQ
                           ,   '전도금'      AS ETC_DESC
                           ,   NULL          AS PURCHASE_CD
                           ,   '02'          AS STOR_PAY_DIV
                           ,   NULL          AS APPR_NO
                           ,   NULL          AS APPR_DT 
                           ,   NULL          AS APPR_TM
                           ,   PSV_HQ_USER_ID AS HQ_USER_ID
                           ,   PSV_BANK_NM   AS BANK_NM
                           ,   PSV_ACC_NO    AS ACC_NO
                           ,   PSV_ACC_NM    AS ACC_NM
                           ,   'N'           AS CONFIRM_YN
                           ,   NULL          AS CONFIRM_DT
                           ,   'N'           AS DEL_YN
                           ,   SYSDATE       AS INST_DT
                           ,   PSV_USER_ID   AS INST_USER
                           ,   SYSDATE       AS UPD_DT
                           ,   PSV_USER_ID   AS UPD_USER
                           ,   '0'           AS INPUT_TP 
                           ,   NULL          AS SEQ_EXCEL
                        FROM  DUAL    
                ) A2
                ON (     A1.COMP_CD  = A2.COMP_CD
                     AND A1.PRC_DT   = A2.PRC_DT
                     AND A1.BRAND_CD = A2.BRAND_CD
                     AND A1.STOR_CD  = A2.STOR_CD
                     AND A1.POS_NO   = A2.POS_NO
                     AND A1.ETC_DIV  = A2.ETC_DIV
                     AND A1.SEQ      = A2.SEQ
                )
                WHEN NOT MATCHED THEN
                    INSERT (
                              A1.COMP_CD
                            , A1.PRC_DT
                            , A1.BRAND_CD
                            , A1.STOR_CD
                            , A1.POS_NO
                            , A1.ETC_DIV
                            , A1.SEQ
                            , A1.ETC_CD
                            , A1.ETC_AMT
                            , A1.ETC_AMT_HQ
                            , A1.CARD_AMT
                            , A1.CUST_ID
                            , A1.USER_ID
                            , A1.ETC_TP
                            , A1.ETC_TM
                            , A1.RMK_SEQ
                            , A1.EVID_DOC
                            , A1.ETC_DESC
                            , A1.PURCHASE_CD
                            , A1.STOR_PAY_DIV
                            , A1.APPR_NO
                            , A1.APPR_DT
                            , A1.APPR_TM
                            , A1.HQ_USER_ID
                            , A1.BANK_NM
                            , A1.ACC_NO
                            , A1.ACC_NM
                            , A1.CONFIRM_YN
                            , A1.CONFIRM_DT
                            , A1.DEL_YN
                            , A1.INST_DT
                            , A1.INST_USER
                            , A1.UPD_DT
                            , A1.UPD_USER
                            , A1.INPUT_TP
                            , A1.SEQ_EXCEL
                    ) VALUES (
                              A2.COMP_CD
                            , A2.PRC_DT
                            , A2.BRAND_CD
                            , A2.STOR_CD
                            , A2.POS_NO
                            , A2.ETC_DIV
                            , A2.SEQ
                            , A2.ETC_CD
                            , A2.ETC_AMT
                            , A2.ETC_AMT_HQ
                            , A2.CARD_AMT
                            , A2.CUST_ID
                            , A2.USER_ID
                            , A2.ETC_TP
                            , A2.ETC_TM
                            , A2.RMK_SEQ
                            , '00'
                            , A2.ETC_DESC
                            , A2.PURCHASE_CD
                            , A2.STOR_PAY_DIV
                            , A2.APPR_NO
                            , A2.APPR_DT
                            , A2.APPR_TM
                            , A2.HQ_USER_ID
                            , A2.BANK_NM
                            , A2.ACC_NO
                            , A2.ACC_NM
                            , A2.CONFIRM_YN
                            , A2.CONFIRM_DT
                            , A2.DEL_YN
                            , A2.INST_DT
                            , A2.INST_USER
                            , A2.UPD_DT
                            , A2.UPD_USER
                            , A2.INPUT_TP
                            , A2.SEQ_EXCEL
                    )
                WHEN MATCHED THEN
                    UPDATE 
                    SET   A1.BANK_NM    = A2.BANK_NM
                       ,  A1.ACC_NO     = A2.ACC_NO
                       ,  A1.ACC_NM     = A2.ACC_NM
                       ,  A1.ETC_AMT    = A2.ETC_AMT
                       ,  A1.ETC_AMT_HQ = A2.ETC_AMT_HQ
                       ,  A1.HQ_USER_ID = A2.HQ_USER_ID
                       ,  A1.UPD_DT     = A2.UPD_DT
                       ,  A1.UPD_USER   = A2.UPD_USER
                 ;      
            EXCEPTION
                WHEN OTHERS THEN     
                    ls_err_cd    := '-1';
                    ls_err_msg   := SQLERRM;
                            
                    RAISE ERR_HANDLER;     
            
            END;
            
        ELSE     
        
            ls_err_cd    := '-1';
            ls_err_msg   := '이미 확정된 데이터가 있습니다. 조회후 다시 저장하십시오.';
                            
            RAISE ERR_HANDLER;     
        
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
    
    PROCEDURE SAVE_DELETE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_PRC_DT      IN  VARCHAR2 , 
        PSV_BRAND_CD    IN  VARCHAR2 ,                  -- 
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 
        PSV_POS_NO      IN  VARCHAR2 ,
        PSV_ETC_DIV     IN  VARCHAR2 ,
        PSV_SEQ         IN  VARCHAR2 ,                  --
        PSV_USER_ID     IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    v_confirm_yn   STORE_ETC_AMT.CONFIRM_YN%TYPE; 
   
    ERR_HANDLER        EXCEPTION;
    ERR_UPDATE_HANDLER EXCEPTION;
    SKIP_HANDLER       EXCEPTION;
    
    BEGIN
    
        BEGIN
        
            SELECT NVL(CONFIRM_YN, 'N')
            INTO   v_confirm_yn
            FROM   STORE_ETC_AMT
            WHERE  COMP_CD  = PSV_COMP_CD
            AND    PRC_DT   = PSV_PRC_DT
            AND    BRAND_CD = PSV_BRAND_CD
            AND    STOR_CD  = PSV_STOR_CD
            AND    POS_NO   = PSV_POS_NO
            AND    ETC_DIV  = PSV_ETC_DIV
            AND    SEQ      = PSV_SEQ
            ;
        
        EXCEPTION 
            WHEN OTHERS THEN
                ls_err_cd  := '-1';
                ls_err_msg := '데이터를 찾을수 없습니다.'; 
            
                RAISE ERR_HANDLER;
        END;
        
        IF ( v_confirm_yn <> 'Y' ) THEN
        
            BEGIN
            
                UPDATE STORE_ETC_AMT
                SET    DEL_YN   = 'Y'
                   ,   UPD_DT   = SYSDATE
                   ,   UPD_USER = PSV_USER_ID
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    PRC_DT   = PSV_PRC_DT
                AND    BRAND_CD = PSV_BRAND_CD
                AND    STOR_CD  = PSV_STOR_CD
                AND    POS_NO   = PSV_POS_NO
                AND    ETC_DIV  = PSV_ETC_DIV
                AND    SEQ      = PSV_SEQ
                ;
            
            END;
            
        ELSE 
            
            ls_err_cd  := '-1';
            ls_err_msg := '이미 확정된 데이터가 있습니다. 조회후 사용하십시오'; 
            
            RAISE ERR_HANDLER;
        
        END IF;
        
        
        PR_RTN_CD  := ls_err_cd;
        PR_RTN_MSG := ls_err_msg;
        
    
    EXCEPTION
        WHEN SKIP_HANDLER THEN
            PR_RTN_CD  := ls_err_cd;
            PR_RTN_MSG := ls_err_msg;
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
            
    
END PKG_ACNT1020;

/
