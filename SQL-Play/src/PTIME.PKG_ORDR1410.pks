CREATE OR REPLACE PACKAGE       PKG_ORDR1410 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ORDR1410
    --  Description      : 개별입고 등록 - 파일업로드  조회
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    
     PROCEDURE SEARCH
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_ORD_DT      IN  VARCHAR2 , 
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
     PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_ORD_DT      IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_ORD_SEQ     IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  -- 
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 
        PSV_ITEM_CD     IN  VARCHAR2 ,                  -- 
        PSV_ORD_QTY     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
     PROCEDURE SAVE_FIX
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_ORD_DT      IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_ORD_SEQ     IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );

    
END PKG_ORDR1410;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ORDR1410 AS

    
    PROCEDURE SEARCH
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_ORD_DT      IN  VARCHAR2 , 
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
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
    
    ls_sql              VARCHAR2(30000);
    ls_sql_with         VARCHAR2(30000);
    ls_sql_main         VARCHAR2(10000);
    ls_sql_date         VARCHAR2(1000);
    ls_sql_store        VARCHAR2(20000);    -- 점포 WITH  S_STORE
    ls_sql_item         VARCHAR2(20000);    -- 제품 WITH  S_ITEM
    ls_date1            VARCHAR2(2000);     -- 조회일자 (기준)
    ls_date2            VARCHAR2(2000);     -- 조회일자 (대비)
    ls_ex_date1         VARCHAR2(2000);     -- 조회일자 제외 (기준)
    ls_ex_date2         VARCHAR2(2000);     -- 조회일자 제외 (대비)
    ls_sql_tab_main     VARCHAR2(20000);    -- CORSSTAB TITLE
    ERR_HANDLER     EXCEPTION;
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    BEGIN
    
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
        
        /* MAIN SQL */
        ls_sql_main := ''
        
        ||CHR(13)||CHR(10)||Q'[ SELECT A1.COMP_CD       ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ORD_DT        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ORD_USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ORD_SEQ   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.SEQ_NO   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.ITEM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ORD_QTY   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_MSG   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   ORDER_FILE_UPLOAD  A1   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STORE              A2   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ITEM               A3   ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD = A2.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.STOR_CD = A2.STOR_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD = A3.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ITEM_CD = A3.ITEM_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD      = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ORD_DT       = :PSV_ORD_DT     ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ORD_USER_ID  = :PSV_USER       ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ORD_SEQ      = (               ]'
        ||CHR(13)||CHR(10)||Q'[                            SELECT MAX(ORD_SEQ)      ]'
        ||CHR(13)||CHR(10)||Q'[                            FROM   ORDER_FILE_UPLOAD ]'
        ||CHR(13)||CHR(10)||Q'[                            WHERE  COMP_CD     = A1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                            AND    ORD_DT      = A1.ORD_DT       ]'
        ||CHR(13)||CHR(10)||Q'[                            AND    ORD_USER_ID = A1.ORD_USER_ID  ]'
        ||CHR(13)||CHR(10)||Q'[                          )  ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY A1.SEQ_NO  ]'
        ;
        
        OPEN PR_RESULT FOR
            ls_sql_main USING PSV_COMP_CD, PSV_ORD_DT, PSV_USER;
                       
     
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
        PSV_ORD_DT      IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_ORD_SEQ     IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  -- 
        PSV_STOR_CD     IN  VARCHAR2 ,                  -- 
        PSV_ITEM_CD     IN  VARCHAR2 ,                  -- 
        PSV_ORD_QTY     IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    V_DATE_CHECK  VARCHAR2(1) ;
    
    v_stor_cd      ORDER_FILE_UPLOAD.STOR_CD%TYPE;
    v_item_cd      ORDER_FILE_UPLOAD.ITEM_CD%TYPE;
    v_ord_qty      ORDER_FILE_UPLOAD.ORD_QTY%TYPE;
    v_err_cd       ORDER_FILE_UPLOAD.ERR_CD%TYPE  := '10000' ;
    v_err_msg      ORDER_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      ORDER_FILE_UPLOAD.PRC_DIV%TYPE := 'N';
    v_user_id      ORDER_FILE_UPLOAD.ORD_USER_ID%TYPE;
    v_use_yn       ITEM_CHAIN.USE_YN%TYPE;
    v_ord_sale_div ITEM_CHAIN.ORD_SALE_DIV%TYPE;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
    
        BEGIN
        
            SELECT CASE WHEN TO_DATE(PSV_ORD_DT)  < TO_DATE(TO_CHAR( LAST_DAY(ADD_MONTHS (SYSDATE , -2)) +1 , 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                        WHEN TO_DATE(PSV_ORD_DT) > TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                        ELSE 'Y' END 
            INTO   V_DATE_CHECK              
            FROM   DUAL
            ;
            
        EXCEPTION WHEN OTHERS THEN
        
            ls_err_cd  := '-1';
            ls_err_msg := '주문일자가 잘못되었습니다. (주문일자:' || PSV_ORD_DT || ')';
            
            RAISE ERR_HANDLER;
            
        END;
       
        IF ( V_DATE_CHECK <> 'Y' ) THEN
        
            ls_err_cd  := '-1';
            ls_err_msg := '주문일자가 잘못되었습니다. (주문일자:' || PSV_ORD_DT || ')';
            
            RAISE ERR_HANDLER;
            
        END IF;
        
        BEGIN 
        
            SELECT USER_ID
            INTO   v_user_id
            FROM   HQ_USER
            WHERE  COMP_CD = PSV_COMP_CD
            AND    USER_ID = PSV_USER_ID
            AND    USE_YN  = 'Y'
            ;
        
        EXCEPTION WHEN OTHERS THEN
        
            ls_err_cd  := '-1';
            ls_err_msg := '주문자 정보가 잘못되었습니다.(주문자:' || PSV_USER_ID || ')';
            
            RAISE ERR_HANDLER;
        
        END;
        
        
        BEGIN
        
            SELECT NVL(MAX(PRC_DIV), 'N')
            INTO   v_prc_div
            FROM   ORDER_FILE_UPLOAD
            WHERE  COMP_CD     = PSV_COMP_CD
            AND    ORD_DT      = PSV_ORD_DT
            AND    ORD_USER_ID = PSV_USER_ID
            AND    ORD_SEQ     = PSV_ORD_SEQ
            AND    SEQ_NO      = PSV_SEQ_NO
            ;
            
        END; 
        
        IF ( v_prc_div <> 'Y') THEN
        
            v_prc_div := 'N';
            
            BEGIN
                    
                SELECT STOR_CD
                INTO   v_stor_cd
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = PSV_STOR_CD
                ;
                
            EXCEPTION WHEN OTHERS THEN
            
                v_stor_cd := 'ERROR';
                v_err_cd  := TO_NUMBER(v_err_cd) + 3;
                v_err_msg := '점포코드가 잘못되었습니다.';
                v_prc_div := 'E';
        
            END;
            
            BEGIN
            
                SELECT ITEM_CD
                INTO   v_item_cd
                FROM   ITEM
                WHERE  COMP_CD = PSV_COMP_CD
                AND    ITEM_CD = PSV_ITEM_CD
                ;
            EXCEPTION 
                WHEN OTHERS THEN
                    v_item_cd := 'ERROR';
                    v_err_cd  := TO_NUMBER(v_err_cd) + 5;
                    v_err_msg := v_err_msg || '상품코드가 잘못되었습니다.';
                    v_prc_div := 'E';
            
            END;
            
            IF ( PSV_ORD_QTY IS NULL OR PSV_ORD_QTY = '' OR PSV_ORD_QTY = '0' OR REGEXP_INSTR(PSV_ORD_QTY ,'[^0-9]') <> 0 ) THEN
            
                v_ord_qty := '0';
                v_err_cd  := TO_NUMBER(v_err_cd) + 7;
                v_err_msg := v_err_msg || '주문수량이 잘못되었습니다.';
                v_prc_div := 'E';
                
            ELSE 
                v_ord_qty := PSV_ORD_QTY;
                
            END IF;
            
            IF ( v_prc_div = 'N' ) THEN
            
                BEGIN
                        
                    SELECT USE_YN, ORD_SALE_DIV
                    INTO   v_use_yn, v_ord_sale_div   
                    FROM   ITEM_CHAIN
                    WHERE  COMP_CD  = PSV_COMP_CD
                    AND    (BRAND_CD , STOR_TP ) = ( SELECT BRAND_CD , STOR_TP
                                                     FROM   STORE
                                                     WHERE  COMP_CD = PSV_COMP_CD
                                                     AND    STOR_CD = PSV_STOR_CD
                                                   )
                    AND    ITEM_CD = v_item_cd                               
                    ;
                 
                EXCEPTION 
                    WHEN OTHERS THEN
                        v_err_cd  := TO_NUMBER(v_err_cd) + 11;
                        v_err_msg := v_err_msg || 'ITEM_CHAIN - 상품정보를 찾을수 없습니다.';
                        v_prc_div := 'E';
                        
                    
                END;
                
                IF( v_prc_div <> 'E' AND v_use_yn <> 'Y' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 13;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - 사용중지된 상품입니다.';
                    v_prc_div := 'E';
                
                END IF;
            
                IF( v_prc_div <> 'E' AND v_ord_sale_div <> '1' AND v_ord_sale_div <> '2' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 17;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - 주문용 상품이 아닙니다.';
                    v_prc_div := 'E';
                
                END IF;
            
            
            END IF;
        
            BEGIN
            
                MERGE INTO ORDER_FILE_UPLOAD   A1
                USING (
                         SELECT PSV_COMP_CD   AS COMP_CD
                            ,   PSV_ORD_DT    AS ORD_DT
                            ,   PSV_USER_ID   AS ORD_USER_ID
                            ,   PSV_ORD_SEQ   AS ORD_SEQ
                            ,   PSV_SEQ_NO    AS SEQ_NO
                            ,   v_stor_cd     AS STOR_CD
                            ,   v_item_cd     AS ITEM_CD
                            ,   v_ord_qty     AS ORD_QTY
                            ,   v_prc_div     AS PRC_DIV
                            ,   DECODE(v_prc_div, 'E', v_err_cd , '') AS ERR_CD
                            ,   DECODE(v_prc_div, 'E', v_err_msg, '') AS ERR_MSG
                            ,   SYSDATE       AS INST_DT  
                            ,   PSV_USER_ID   AS INST_USER
                            ,   SYSDATE       AS UPD_DT
                            ,   PSV_USER_ID   AS UPD_USER
                          FROM  DUAL
                )  A2
                ON (     A1.COMP_CD     = A2.COMP_CD
                     AND A1.ORD_DT      = A2.ORD_DT
                     AND A1.ORD_USER_ID = A2.ORD_USER_ID
                     AND A1.ORD_SEQ     = A2.ORD_SEQ
                     AND A1.SEQ_NO      = A2.SEQ_NO
                )  
                WHEN MATCHED THEN
                    UPDATE 
                    SET    A1.STOR_CD  = A2.STOR_CD
                       ,   A1.ITEM_CD  = A2.ITEM_CD
                       ,   A1.ORD_QTY  = A2.ORD_QTY
                       ,   A1.PRC_DIV  = A2.PRC_DIV
                       ,   A1.ERR_CD   = A2.ERR_CD
                       ,   A1.ERR_MSG  = A2.ERR_MSG
                       ,   A1.UPD_DT   = A2.UPD_DT
                       ,   A1.UPD_USER = A2.UPD_USER
                WHEN NOT MATCHED THEN
                    INSERT (
                           A1.COMP_CD
                       ,   A1.ORD_DT
                       ,   A1.ORD_USER_ID
                       ,   A1.ORD_SEQ
                       ,   A1.SEQ_NO
                       ,   A1.STOR_CD
                       ,   A1.ITEM_CD
                       ,   A1.ORD_QTY
                       ,   A1.PRC_DIV
                       ,   A1.ERR_CD
                       ,   A1.ERR_MSG
                       ,   A1.INST_DT  
                       ,   A1.INST_USER
                       ,   A1.UPD_DT
                       ,   A1.UPD_USER
                    ) VALUES (
                           A2.COMP_CD
                       ,   A2.ORD_DT
                       ,   A2.ORD_USER_ID
                       ,   A2.ORD_SEQ
                       ,   A2.SEQ_NO
                       ,   A2.STOR_CD
                       ,   A2.ITEM_CD
                       ,   A2.ORD_QTY
                       ,   A2.PRC_DIV
                       ,   A2.ERR_CD
                       ,   A2.ERR_MSG
                       ,   A2.INST_DT  
                       ,   A2.INST_USER
                       ,   A2.UPD_DT
                       ,   A2.UPD_USER
                    )
                    ;
            
            EXCEPTION         
                WHEN OTHERS THEN
                    
                    ls_err_cd  := '-1';
                    ls_err_msg := '저장시 에러' || v_err_msg || SQLERRM;
            
                    RAISE ERR_HANDLER;
                    
            END;
       
        
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
        PSV_ORD_DT      IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_ORD_SEQ     IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    V_DATE_CHECK  VARCHAR2(1) ;
    V_DUP_CHECK   VARCHAR2(1) := 'N';
    V_IS_HIS      VARCHAR2(1) := 'Y';
    
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
    
    
    ERR_HANDLER        EXCEPTION;
    ERR_UPDATE_HANDLER EXCEPTION;
    SKIP_HANDLER       EXCEPTION;
    
    BEGIN
    
        BEGIN
        
            SELECT PRC_DIV, ERR_CD, STOR_CD, ITEM_CD, ORD_QTY
            INTO   v_prc_div, v_err_cd, v_stor_cd, v_item_cd, v_ord_qty
            FROM   ORDER_FILE_UPLOAD
            WHERE  COMP_CD     = PSV_COMP_CD
            AND    ORD_DT      = PSV_ORD_DT
            AND    ORD_USER_ID = PSV_USER_ID
            AND    ORD_SEQ     = PSV_ORD_SEQ    
            AND    SEQ_NO      = PSV_SEQ_NO
            ;
            
        EXCEPTION 
            WHEN OTHERS THEN
                ls_err_cd  := '-1';
                ls_err_msg := '데이터를 찾을수 없습니다.  ';
            
                RAISE SKIP_HANDLER;
            
        
        END;
        
        v_ord_no := PSV_ORD_DT || v_stor_cd || '1' || '02';
        
        /*
        IF( v_prc_div <> 'N' OR v_prc_div IS NULL ) THEN
        
            v_err_cd  := '10019';
            v_err_msg := '확정된 데이터이거나 잘못된 데이터입니다.';
            
            RAISE SKIP_HANDLER;
        
        END IF;
        */
        
        IF ( v_prc_div = 'N' ) THEN
    
            BEGIN
            
                SELECT CASE WHEN TO_DATE(PSV_ORD_DT)  < TO_DATE(TO_CHAR( LAST_DAY(ADD_MONTHS (SYSDATE , -2)) +1 , 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                            WHEN TO_DATE(PSV_ORD_DT) > TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                            ELSE 'Y' END 
                INTO   V_DATE_CHECK              
                FROM   DUAL
                ;
                
            EXCEPTION WHEN OTHERS THEN
            
                v_err_cd   := '10023';
                v_err_msg  := '주문일자가 잘못되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END;
           
            IF ( V_DATE_CHECK <> 'Y' ) THEN
            
                v_err_cd  := '10023';
                v_err_msg := '주문일자가 잘못되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END IF;
            
            BEGIN
            
                SELECT BRAND_CD, STOR_TP
                INTO   v_brand_cd, v_stor_tp
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = v_stor_cd
                ;
                
            END;
            
            BEGIN
                
                -- ITEM_CHAIN_HIS 데이터 존재 여부 
                SELECT DECODE( COUNT(*) , 0 , 'N', 'Y')
                INTO   V_IS_HIS
                FROM   ITEM_CHAIN_HIS
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    BRAND_CD = v_brand_cd
                AND    STOR_TP  = v_stor_tp
                AND    ITEM_CD  = v_item_cd
                AND    PSV_ORD_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231') 
                ;
            
            END;
            
            IF( V_IS_HIS = 'N' ) THEN
            
                v_err_cd  := '10019';
                v_err_msg := 'ITEM_CHAIN_HIS - 정보가 없습니다.';
            
                RAISE ERR_UPDATE_HANDLER;
            
            END IF;
            
            BEGIN
            
                -- 중복여부
                SELECT DECODE( COUNT(*) , 0 , 'N', 'Y')
                INTO   V_DUP_CHECK    
                FROM   ORDER_DTV
                WHERE  COMP_CD = PSV_COMP_CD
                AND    ORD_NO  = v_ord_no
                AND    ITEM_CD = v_item_cd
                ;
            
            END;
            
            IF( V_DUP_CHECK = 'Y' ) THEN
                 
                v_err_cd  := '10029';
                v_err_msg := 'ORDER_DTV 상품이 중복되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END IF; 
            
            
            
            BEGIN
            
                SELECT NVL(MAX(TO_NUMBER(ORD_SEQ)),0) + 1
                INTO   v_ord_seq
                FROM   ORDER_DTV
                WHERE  COMP_CD     = PSV_COMP_CD
                AND    ORD_NO      = v_ord_no
                ;
            END;
            
            
            BEGIN

                MERGE INTO ORDER_HDV  A1
                USING (
                        SELECT PSV_COMP_CD                            AS COMP_CD
                           ,   v_ord_no                               AS ORD_NO
                           ,   PSV_ORD_DT                             AS ORD_DT
                           ,   '1'                                    AS ORD_DIV
                           ,   BRAND_CD                             
                           ,   STOR_CD
                           ,   '1'                                    AS ORD_FG
                           ,   SYSDATE                                AS INST_DT
                           ,   PSV_USER_ID                            AS INST_USER
                           ,   SYSDATE                                AS UPD_DT
                           ,   PSV_USER_ID                            AS UPD_USER
                        FROM   STORE
                        WHERE  COMP_CD = PSV_COMP_CD   
                        AND    STOR_CD = v_stor_cd   
                ) A2
                ON (
                         A1.COMP_CD = A2.COMP_CD
                     AND A1.ORD_NO  = A2.ORD_NO
                )
                WHEN MATCHED THEN
                    UPDATE
                    SET    A1.UPD_DT   = A2.UPD_DT
                       ,   A1.UPD_USER = A2.UPD_USER
                WHEN NOT MATCHED THEN
                    INSERT (
                           A1.COMP_CD
                        ,  A1.ORD_NO
                        ,  A1.ORD_DT
                        ,  A1.ORD_DIV
                        ,  A1.BRAND_CD
                        ,  A1.STOR_CD
                        ,  A1.ORD_FG
                        ,  A1.INST_DT
                        ,  A1.INST_USER
                        ,  A1.UPD_DT
                        ,  A1.UPD_USER
                    ) VALUES (
                           A2.COMP_CD
                        ,  A2.ORD_NO
                        ,  A2.ORD_DT
                        ,  A2.ORD_DIV
                        ,  A2.BRAND_CD
                        ,  A2.STOR_CD
                        ,  A2.ORD_FG
                        ,  A2.INST_DT
                        ,  A2.INST_USER
                        ,  A2.UPD_DT
                        ,  A2.UPD_USER
                    )
                    ; 
                        
            EXCEPTION 
                WHEN OTHERS THEN        
                    v_err_cd  := '10031';
                    v_err_msg := 'ORDER_HDV 저장 오류' || SQLERRM;
                
                    RAISE ERR_UPDATE_HANDLER;
            
            END;
            
            
            BEGIN
            
                INSERT INTO ORDER_DTV (
                        COMP_CD
                    ,   ORD_NO
                    ,   ORD_SEQ
                    ,   ORD_DT
                    ,   BRAND_CD
                    ,   STOR_CD
                    ,   ORD_FG
                    ,   ITEM_CD
                    ,   ORD_UNIT
                    ,   ORD_UNIT_QTY
                    ,   ORD_COST
                    ,   ORD_QTY
                    ,   ORD_AMT
                    ,   ORD_VAT
                    ,   DLV_DT
                    ,   VENDOR_CD
                    ,   REMARKS
                    ,   STK_DT
                    ,   ORD_CQTY
                    ,   ORD_CAMT
                    ,   ORD_CVAT
                    ,   ORD_REMARKS
                    ,   DLV_CDT
                    ,   DLV_QTY
                    ,   DLV_AMT
                    ,   DLV_VAT
                    ,   DLV_REMARKS
                    ,   MSF_IF_YN
                    ,   MSF_IF_DT
                    ,   SAP_IF_YN
                    ,   SAP_IF_DT
                    ,   INST_DT
                    ,   INST_USER
                    ,   UPD_DT
                    ,   UPD_USER
                    ,   ORD_DIV
                )
                SELECT  A1.COMP_CD
                    ,   v_ord_no
                    ,   v_ord_seq
                    ,   PSV_ORD_DT
                    ,   v_brand_cd
                    ,   v_stor_cd
                    ,   '1'
                    ,   A1.ITEM_CD
                    ,   A1.ORD_UNIT
                    ,   A1.ORD_UNIT_QTY
                    ,   NVL(A2.COST, NVL(A1.COST, 0))
                    ,   v_ord_qty
                    ,   v_ord_qty * NVL(A2.COST, NVL(A1.COST, 0))
                    ,   DECODE( A1.COST_VAT_YN, 'Y' , NVL(A2.COST, NVL(A1.COST, 0)) * NVL(A1.COST_VAT_RATE, 0) , 0) 
                    ,   TO_CHAR( TO_DATE(PSV_ORD_DT) + NVL(LEAD_TIME,0), 'YYYYMMDD')
                    ,   A1.VENDOR_CD
                    ,   ''
                    ,   PSV_ORD_DT
                    ,   v_ord_qty
                    ,   v_ord_qty * NVL(A2.COST, NVL(A1.COST, 0))
                    ,   DECODE( A1.COST_VAT_YN, 'Y' , NVL(A2.COST, NVL(A1.COST, 0)) * NVL(A1.COST_VAT_RATE, 0) , 0) 
                    ,   '파일업로드'
                    ,   null
                    ,   0
                    ,   0
                    ,   0
                    ,   null
                    ,   'N'
                    ,   null
                    ,   'N'
                    ,   null
                    ,   SYSDATE
                    ,   PSV_USER_ID
                    ,   SYSDATE
                    ,   PSV_USER_ID
                    ,   '1'
                FROM   ITEM_CHAIN A1
                    ,  (
                            SELECT ITEM_CD,MAX(COST) KEEP ( DENSE_RANK FIRST ORDER BY START_DT DESC)  AS COST
                            FROM   ITEM_CHAIN_HIS
                            WHERE  COMP_CD  = PSV_COMP_CD
                            AND    BRAND_CD = v_brand_cd
                            AND    STOR_TP  = v_stor_tp
                            AND    ITEM_CD  = v_item_cd
                            AND    PSV_ORD_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
                            GROUP BY ITEM_CD 
                    
                       ) A2
                WHERE  A1.ITEM_CD  = A2.ITEM_CD(+)
                AND    A1.COMP_CD  = PSV_COMP_CD
                AND    A1.BRAND_CD = v_brand_cd
                AND    A1.STOR_TP  = v_stor_tp
                AND    A1.ITEM_CD  = v_item_cd
                ;
            
            EXCEPTION 
                WHEN OTHERS THEN        
                    v_err_cd  := '10037';
                    v_err_msg := 'ORDER_DTV 저장 오류' || SQLERRM;
                
                    RAISE ERR_UPDATE_HANDLER;    
                
            END;
            
            BEGIN
            
                UPDATE ORDER_FILE_UPLOAD
                SET    PRC_DIV = 'Y'
                WHERE  COMP_CD     = PSV_COMP_CD 
                AND    ORD_DT      = PSV_ORD_DT
                AND    ORD_USER_ID = PSV_USER_ID
                AND    ORD_SEQ     = PSV_ORD_SEQ
                AND    SEQ_NO      = PSV_SEQ_NO
                ;    
                
            END;

        END IF;
                
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
            
                UPDATE ORDER_FILE_UPLOAD
                SET    PRC_DIV = 'E'
                   ,   ERR_CD  = v_err_cd 
                   ,   ERR_MSG = v_err_msg
                WHERE  COMP_CD     = PSV_COMP_CD 
                AND    ORD_DT      = PSV_ORD_DT
                AND    ORD_USER_ID = PSV_USER_ID
                AND    ORD_SEQ     = PSV_ORD_SEQ
                AND    SEQ_NO      = PSV_SEQ_NO
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
            
    
END PKG_ORDR1410;

/
