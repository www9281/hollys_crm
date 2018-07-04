CREATE OR REPLACE PACKAGE       PKG_ORDR4450 AS

    ---------------------------------------------------------------------------------------------------
    --  Package Name     : PKG_ORDR4450
    --  Description      :점간이동 - 파일업로드  
    -- Ref. Table        :
    ---------------------------------------------------------------------------------------------------
    
    
     PROCEDURE SEARCH
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_MV_DT       IN  VARCHAR2 , 
        PR_RESULT       IN  OUT PKG_REPORT.REF_CUR ,    -- Result Set(데이터)
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
     PROCEDURE SAVE
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_MV_DT       IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_MV_SEQ      IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  --
        PSV_OUT_STOR_CD IN  VARCHAR2 ,                  --
        PSV_IN_STOR_CD  IN  VARCHAR2 ,                  -- 
        PSV_ITEM_CD     IN  VARCHAR2 ,                  -- 
        PSV_MV_QTY      IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );
    
     PROCEDURE SAVE_FIX
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_MV_DT       IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  --
        PSV_MV_SEQ      IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  --
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    );

    
END PKG_ORDR4450;

/

CREATE OR REPLACE PACKAGE BODY       PKG_ORDR4450 AS

    
    PROCEDURE SEARCH
    ( 
        PSV_COMP_CD     IN  VARCHAR2 ,                  -- 회사코드
        PSV_USER        IN  VARCHAR2 ,                  -- LOGIN USER
        PSV_MV_DT       IN  VARCHAR2 , 
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
        ||CHR(13)||CHR(10)||Q'[    ,   A1.MV_DT         ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.MV_USER_ID    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.MV_SEQ        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.SEQ_NO        ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.OUT_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A2.STOR_NM    AS OUT_STOR_NM ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.IN_STOR_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A3.STOR_NM    AS IN_STOR_NM  ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ITEM_CD   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A4.ITEM_NM   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.MV_QTY    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.PRC_DIV   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_CD    ]'
        ||CHR(13)||CHR(10)||Q'[    ,   A1.ERR_MSG   ]'
        ||CHR(13)||CHR(10)||Q'[ FROM   MOVE_FILE_UPLOAD   A1   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STORE              A2   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   STORE              A3   ]'
        ||CHR(13)||CHR(10)||Q'[    ,   ITEM               A4   ]'
        ||CHR(13)||CHR(10)||Q'[ WHERE  A1.COMP_CD     = A2.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.OUT_STOR_CD = A2.STOR_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD     = A3.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.IN_STOR_CD  = A3.STOR_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD = A4.COMP_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.ITEM_CD = A4.ITEM_CD(+)   ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.COMP_CD      = :PSV_COMP_CD    ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.MV_DT        = :PSV_MV_DT      ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.MV_USER_ID   = :PSV_USER       ]'
        ||CHR(13)||CHR(10)||Q'[ AND    A1.MV_SEQ       = (               ]'
        ||CHR(13)||CHR(10)||Q'[                            SELECT MAX(MV_SEQ)      ]'
        ||CHR(13)||CHR(10)||Q'[                            FROM   MOVE_FILE_UPLOAD ]'
        ||CHR(13)||CHR(10)||Q'[                            WHERE  COMP_CD     = A1.COMP_CD      ]'
        ||CHR(13)||CHR(10)||Q'[                            AND    MV_DT       = A1.MV_DT        ]'
        ||CHR(13)||CHR(10)||Q'[                            AND    MV_USER_ID  = A1.MV_USER_ID   ]'
        ||CHR(13)||CHR(10)||Q'[                          )  ]'
        ||CHR(13)||CHR(10)||Q'[ ORDER BY A1.SEQ_NO  ]'
        ;
        
        OPEN PR_RESULT FOR
            ls_sql_main USING PSV_COMP_CD, PSV_MV_DT, PSV_USER;
                       
     
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
        PSV_MV_DT       IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  -- 
        PSV_MV_SEQ      IN  VARCHAR2 ,                  -- 
        PSV_SEQ_NO      IN  VARCHAR2 ,                  --
        PSV_OUT_STOR_CD IN  VARCHAR2 ,                  --
        PSV_IN_STOR_CD  IN  VARCHAR2 ,                  -- 
        PSV_ITEM_CD     IN  VARCHAR2 ,                  -- 
        PSV_MV_QTY      IN  VARCHAR2 ,
        PR_RTN_CD       OUT VARCHAR2 ,                  -- 처리코드
        PR_RTN_MSG      OUT VARCHAR2                    -- 처리Message
    )
    IS
    
    ls_err_cd     VARCHAR2(7) := '0' ;
    ls_err_msg    VARCHAR2(500) ;
    
    V_DATE_CHECK  VARCHAR2(1) ;
    
    v_out_stor_cd  MOVE_FILE_UPLOAD.OUT_STOR_CD%TYPE;
    v_in_stor_cd   MOVE_FILE_UPLOAD.IN_STOR_CD%TYPE;
    v_item_cd      MOVE_FILE_UPLOAD.ITEM_CD%TYPE;
    v_mv_qty       MOVE_FILE_UPLOAD.MV_QTY%TYPE;
    v_err_cd       MOVE_FILE_UPLOAD.ERR_CD%TYPE  := '10000' ;
    v_err_msg      MOVE_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      MOVE_FILE_UPLOAD.PRC_DIV%TYPE := 'N';
    v_user_id      MOVE_FILE_UPLOAD.MV_USER_ID%TYPE;
    v_use_yn       ITEM_CHAIN.USE_YN%TYPE;
    v_ord_sale_div ITEM_CHAIN.ORD_SALE_DIV%TYPE;
    
    ERR_HANDLER     EXCEPTION;
    
    BEGIN
    
        BEGIN
        
            SELECT CASE WHEN TO_DATE(PSV_MV_DT)  < TO_DATE(TO_CHAR( LAST_DAY(ADD_MONTHS (SYSDATE , -2)) +1 , 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                        --WHEN TO_DATE(PSV_MV_DT) > TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') THEN 'N'
                        ELSE 'Y' END 
            INTO   V_DATE_CHECK              
            FROM   DUAL
            ;
            
        EXCEPTION WHEN OTHERS THEN
        
            ls_err_cd  := '-1';
            ls_err_msg := '이동일자가 잘못되었습니다. (이동일자:' || PSV_MV_DT || ')';
            
            RAISE ERR_HANDLER;
            
        END;
       
        IF ( V_DATE_CHECK <> 'Y' ) THEN
        
            ls_err_cd  := '-1';
            ls_err_msg := '이동일자가 잘못되었습니다. (이동일자:' || PSV_MV_DT || ')';
            
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
            ls_err_msg := '등록자 정보가 잘못되었습니다.(등록자:' || PSV_USER_ID || ')';
            
            RAISE ERR_HANDLER;
        
        END;
        
        
        BEGIN
        
            SELECT NVL(MAX(PRC_DIV), 'N')
            INTO   v_prc_div
            FROM   MOVE_FILE_UPLOAD
            WHERE  COMP_CD     = PSV_COMP_CD
            AND    MV_DT       = PSV_MV_DT
            AND    MV_USER_ID  = PSV_USER_ID
            AND    MV_SEQ      = PSV_MV_SEQ
            AND    SEQ_NO      = PSV_SEQ_NO
            ;
            
        END; 
        
        
        IF ( v_prc_div <> 'Y') THEN
        
            v_prc_div := 'N';
            
            BEGIN
                    
                SELECT STOR_CD
                INTO   v_out_stor_cd
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = PSV_OUT_STOR_CD
                ;
                
            EXCEPTION WHEN OTHERS THEN
            
                v_out_stor_cd := 'ERROR';
                v_err_cd  := TO_NUMBER(v_err_cd) + 3;
                v_err_msg := '출고점포코드가 잘못되었습니다.';
                v_prc_div := 'E';
        
            END;
            
            BEGIN
                    
                SELECT STOR_CD
                INTO   v_in_stor_cd
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = PSV_IN_STOR_CD
                ;
                
            EXCEPTION WHEN OTHERS THEN
            
                v_in_stor_cd := 'ERROR';
                v_err_cd  := TO_NUMBER(v_err_cd) + 5;
                v_err_msg := v_err_msg || '입고점포코드가 잘못되었습니다.';
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
                    v_err_cd  := TO_NUMBER(v_err_cd) + 7;
                    v_err_msg := v_err_msg || '상품코드가 잘못되었습니다.';
                    v_prc_div := 'E';
            
            END;
            
            IF ( PSV_MV_QTY IS NULL OR PSV_MV_QTY = '' OR PSV_MV_QTY = '0' OR REGEXP_INSTR(PSV_MV_QTY ,'[^0-9]') <> 0 ) THEN
            
                v_mv_qty  := '0';
                v_err_cd  := TO_NUMBER(v_err_cd) + 13;
                v_err_msg := v_err_msg || '이동수량이 잘못되었습니다.';
                v_prc_div := 'E';
                
            ELSE 
                v_mv_qty := PSV_MV_QTY;
                
            END IF;
            
            IF ( v_prc_div = 'N' AND v_out_stor_cd = v_in_stor_cd  ) THEN
            
                v_err_cd  := TO_NUMBER(v_err_cd) + 31;
                v_err_msg := v_err_msg || '출고점포와 입고점포가 같습니다.';
                v_prc_div := 'E';
                
            
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
                                                     AND    STOR_CD = PSV_OUT_STOR_CD
                                                   )
                    AND    ITEM_CD = v_item_cd                               
                    ;
                 
                EXCEPTION 
                    WHEN OTHERS THEN
                        v_err_cd  := TO_NUMBER(v_err_cd) + 37;
                        v_err_msg := v_err_msg || 'ITEM_CHAIN - (출고점포)상품정보를 찾을수 없습니다.';
                        v_prc_div := 'E';
                        
                    
                END;
                
                IF( v_prc_div <> 'E' AND v_use_yn <> 'Y' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 41;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - (출고점포)사용중지된 상품입니다.';
                    v_prc_div := 'E';
                
                END IF;
                
                /*
                IF( v_prc_div <> 'E' AND v_ord_sale_div <> '1' AND v_ord_sale_div <> '2' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 43;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - (출고점포)주문용 상품이 아닙니다.';
                    v_prc_div := 'E';
                
                END IF;
                */
            
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
                                                     AND    STOR_CD = PSV_IN_STOR_CD
                                                   )
                    AND    ITEM_CD = v_item_cd                               
                    ;
                 
                EXCEPTION 
                    WHEN OTHERS THEN
                        v_err_cd  := TO_NUMBER(v_err_cd) + 47;
                        v_err_msg := v_err_msg || 'ITEM_CHAIN - (입고점포)상품정보를 찾을수 없습니다.';
                        v_prc_div := 'E';
                        
                    
                END;
                
                IF( v_prc_div <> 'E' AND v_use_yn <> 'Y' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 53;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - (입고점포)사용중지된 상품입니다.';
                    v_prc_div := 'E';
                
                END IF;
                
                /*
                IF( v_prc_div <> 'E' AND v_ord_sale_div <> '1' AND v_ord_sale_div <> '2' ) THEN
                
                    v_err_cd  := TO_NUMBER(v_err_cd) + 59;
                    v_err_msg := v_err_msg || 'ITEM_CHAIN - (입고점포)주문용 상품이 아닙니다.';
                    v_prc_div := 'E';
                
                END IF;
                */
            
            END IF;
            
            BEGIN
            
                MERGE INTO MOVE_FILE_UPLOAD   A1
                USING (
                         SELECT PSV_COMP_CD   AS COMP_CD
                            ,   PSV_MV_DT     AS MV_DT
                            ,   PSV_USER_ID   AS MV_USER_ID
                            ,   PSV_MV_SEQ    AS MV_SEQ
                            ,   PSV_SEQ_NO    AS SEQ_NO
                            ,   v_out_stor_cd AS OUT_STOR_CD
                            ,   v_in_stor_cd  AS IN_STOR_CD
                            ,   v_item_cd     AS ITEM_CD
                            ,   v_mv_qty      AS MV_QTY
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
                     AND A1.MV_DT       = A2.MV_DT
                     AND A1.MV_USER_ID  = A2.MV_USER_ID
                     AND A1.MV_SEQ      = A2.MV_SEQ
                     AND A1.SEQ_NO      = A2.SEQ_NO
                )  
                WHEN MATCHED THEN
                    UPDATE 
                    SET    A1.OUT_STOR_CD  = A2.OUT_STOR_CD
                       ,   A1.IN_STOR_CD   = A2.IN_STOR_CD
                       ,   A1.ITEM_CD  = A2.ITEM_CD
                       ,   A1.MV_QTY   = A2.MV_QTY
                       ,   A1.PRC_DIV  = A2.PRC_DIV
                       ,   A1.ERR_CD   = A2.ERR_CD
                       ,   A1.ERR_MSG  = A2.ERR_MSG
                       ,   A1.UPD_DT   = A2.UPD_DT
                       ,   A1.UPD_USER = A2.UPD_USER
                WHEN NOT MATCHED THEN
                    INSERT (
                           A1.COMP_CD
                       ,   A1.MV_DT
                       ,   A1.MV_USER_ID
                       ,   A1.MV_SEQ
                       ,   A1.SEQ_NO
                       ,   A1.OUT_STOR_CD
                       ,   A1.IN_STOR_CD
                       ,   A1.ITEM_CD
                       ,   A1.MV_QTY
                       ,   A1.PRC_DIV
                       ,   A1.ERR_CD
                       ,   A1.ERR_MSG
                       ,   A1.INST_DT  
                       ,   A1.INST_USER
                       ,   A1.UPD_DT
                       ,   A1.UPD_USER
                    ) VALUES (
                           A2.COMP_CD
                       ,   A2.MV_DT
                       ,   A2.MV_USER_ID
                       ,   A2.MV_SEQ
                       ,   A2.SEQ_NO
                       ,   A2.OUT_STOR_CD
                       ,   A2.IN_STOR_CD
                       ,   A2.ITEM_CD
                       ,   A2.MV_QTY
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
        PSV_MV_DT       IN  VARCHAR2 , 
        PSV_USER_ID     IN  VARCHAR2 ,                  --
        PSV_MV_SEQ      IN  VARCHAR2 ,                  -- 
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
    
    v_out_stor_cd  MOVE_FILE_UPLOAD.OUT_STOR_CD%TYPE;
    v_in_stor_cd   MOVE_FILE_UPLOAD.IN_STOR_CD%TYPE;
    v_item_cd      MOVE_FILE_UPLOAD.ITEM_CD%TYPE;
    v_mv_qty       MOVE_FILE_UPLOAD.MV_QTY%TYPE;
    
    
    v_err_cd       MOVE_FILE_UPLOAD.ERR_CD%TYPE;
    v_err_msg      MOVE_FILE_UPLOAD.ERR_MSG%TYPE;
    v_prc_div      MOVE_FILE_UPLOAD.PRC_DIV%TYPE;
    v_user_id      MOVE_FILE_UPLOAD.MV_USER_ID%TYPE;
    v_use_yn       ITEM_CHAIN.USE_YN%TYPE;
    v_ord_sale_div ITEM_CHAIN.ORD_SALE_DIV%TYPE;
    
    v_out_brand_cd STORE.BRAND_CD%TYPE;
    v_in_brand_cd  STORE.BRAND_CD%TYPE;
    
    v_out_stor_tp  STORE.STOR_TP%TYPE;
    v_in_stor_tp   STORE.STOR_TP%TYPE;
     
    v_seq          MOVE_STORE.SEQ%TYPE;
    v_mv_unit      MOVE_STORE.MV_UNIT%TYPE;
    v_mv_unit_qty  MOVE_STORE.MV_UNIT_QTY%TYPE;
    
    v_out_cost     MOVE_STORE.OUT_COST%TYPE; 
    v_out_cost_amt MOVE_STORE.OUT_COST_AMT%TYPE;
    v_out_cost_vat MOVE_STORE.OUT_COST_VAT%TYPE;
    
    v_in_cost      MOVE_STORE.IN_COST%TYPE; 
    v_in_cost_amt  MOVE_STORE.IN_COST_AMT%TYPE; 
    v_in_cost_vat  MOVE_STORE.IN_COST_VAT%TYPE;
    
    
    ERR_HANDLER        EXCEPTION;
    ERR_UPDATE_HANDLER EXCEPTION;
    SKIP_HANDLER       EXCEPTION;
    
    BEGIN
    
        BEGIN
        
            SELECT PRC_DIV, ERR_CD, OUT_STOR_CD, IN_STOR_CD, ITEM_CD, MV_QTY
            INTO   v_prc_div, v_err_cd, v_out_stor_cd, v_in_stor_cd, v_item_cd, v_mv_qty
            FROM   MOVE_FILE_UPLOAD
            WHERE  COMP_CD     = PSV_COMP_CD
            AND    MV_DT       = PSV_MV_DT
            AND    MV_USER_ID  = PSV_USER_ID
            AND    MV_SEQ      = PSV_MV_SEQ    
            AND    SEQ_NO      = PSV_SEQ_NO
            ;
            
        EXCEPTION 
            WHEN OTHERS THEN
                ls_err_cd  := '-1';
                ls_err_msg := '데이터를 찾을수 없습니다.  ';
            
                RAISE SKIP_HANDLER;
            
        
        END;
        
        
        
        /*
        IF( v_prc_div <> 'N' OR v_prc_div IS NULL ) THEN
        
            v_err_cd  := '10019';
            v_err_msg := '확정된 데이터이거나 잘못된 데이터입니다.';
            
            RAISE SKIP_HANDLER;
        
        END IF;
        */
        
        IF ( v_prc_div = 'N' ) THEN
    
            BEGIN
            
                SELECT CASE WHEN PSV_MV_DT = TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 'Y'
                            ELSE 'N' END 
                INTO   V_DATE_CHECK              
                FROM   DUAL
                ;
                
            EXCEPTION WHEN OTHERS THEN
            
                v_err_cd   := '20001';
                v_err_msg  := '이동일자가 잘못되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END;
           
            IF ( V_DATE_CHECK <> 'Y' ) THEN
            
                v_err_cd  := '20001';
                v_err_msg := '이동일자가 잘못되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END IF;
            
            -- 브랜드,직가맹 
            BEGIN
            
                SELECT BRAND_CD, STOR_TP
                INTO   v_out_brand_cd, v_out_stor_tp
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = v_out_stor_cd
                ;
            
                SELECT BRAND_CD, STOR_TP
                INTO   v_in_brand_cd, v_in_stor_tp
                FROM   STORE
                WHERE  COMP_CD = PSV_COMP_CD
                AND    STOR_CD = v_in_stor_cd
                ;
                
            END;
            
       
            
            -- 주문단위, 주문단위 입수량
            BEGIN
            
                SELECT A1.ORD_UNIT, A1.ORD_UNIT_QTY, NVL(A2.COST, A1.COST) , v_mv_qty * NVL(A2.COST, A1.COST), DECODE( A1.COST_VAT_YN, 'Y' , v_mv_qty * NVL(A2.COST, NVL(A1.COST, 0)) * NVL(A1.COST_VAT_RATE, 0) , 0)   
                INTO   v_mv_unit, v_mv_unit_qty, v_out_cost, v_out_cost_amt, v_out_cost_vat
                FROM   ITEM_CHAIN A1
                   ,  (
                            SELECT ITEM_CD,MAX(COST) KEEP ( DENSE_RANK FIRST ORDER BY START_DT DESC)  AS COST
                            FROM   ITEM_CHAIN_HIS
                            WHERE  COMP_CD  = PSV_COMP_CD
                            AND    BRAND_CD = v_out_brand_cd
                            AND    STOR_TP  = v_out_stor_tp
                            AND    ITEM_CD  = v_item_cd
                            AND    PSV_MV_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
                            GROUP BY ITEM_CD 
                    
                       ) A2
                WHERE  A1.COMP_CD  = PSV_COMP_CD
                AND    A1.BRAND_CD = v_out_brand_cd
                AND    A1.STOR_TP  = v_out_stor_tp
                AND    A1.ITEM_CD  = v_item_cd
                AND    A1.ITEM_CD  = A2.ITEM_CD
                ;
                
                
                SELECT A1.ORD_UNIT, A1.ORD_UNIT_QTY, NVL(A2.COST, A1.COST) , v_mv_qty * NVL(A2.COST, A1.COST), DECODE( A1.COST_VAT_YN, 'Y' , v_mv_qty * NVL(A2.COST, NVL(A1.COST, 0)) * NVL(A1.COST_VAT_RATE, 0) , 0)   
                INTO   v_mv_unit, v_mv_unit_qty, v_in_cost, v_in_cost_amt, v_in_cost_vat
                FROM   ITEM_CHAIN A1
                   ,  (
                            SELECT ITEM_CD,MAX(COST) KEEP ( DENSE_RANK FIRST ORDER BY START_DT DESC)  AS COST
                            FROM   ITEM_CHAIN_HIS
                            WHERE  COMP_CD  = PSV_COMP_CD
                            AND    BRAND_CD = v_in_brand_cd
                            AND    STOR_TP  = v_in_stor_tp
                            AND    ITEM_CD  = v_item_cd
                            AND    PSV_MV_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
                            GROUP BY ITEM_CD 
                    
                       ) A2
                WHERE  A1.COMP_CD  = PSV_COMP_CD
                AND    A1.BRAND_CD = v_in_brand_cd
                AND    A1.STOR_TP  = v_in_stor_tp
                AND    A1.ITEM_CD  = v_item_cd
                AND    A1.ORD_UNIT = v_mv_unit
                AND    A1.ORD_UNIT_QTY = v_mv_unit_qty
                AND    A1.ITEM_CD  = A2.ITEM_CD
                ;
            
            EXCEPTION WHEN OTHERS THEN
            
                v_err_cd   := '20002';
                v_err_msg  := '주문단위 및 주문단위 입수량이 잘못되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;   
            
            
            END;
            
            
            BEGIN
                
                -- ITEM_CHAIN_HIS 데이터 존재 여부 
                SELECT DECODE( COUNT(*) , 0 , 'N', 'Y')
                INTO   V_IS_HIS
                FROM   ITEM_CHAIN_HIS
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    BRAND_CD = v_out_brand_cd
                AND    STOR_TP  = v_out_stor_tp
                AND    ITEM_CD  = v_item_cd
                AND    PSV_MV_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231') 
                ;
            
            END;
            
            IF( V_IS_HIS = 'N' ) THEN
            
                v_err_cd  := '20003';
                v_err_msg := 'ITEM_CHAIN_HIS - (출고점포) 정보가 없습니다.';
            
                RAISE ERR_UPDATE_HANDLER;
            
            END IF;
            
            
            BEGIN
                
                -- ITEM_CHAIN_HIS 데이터 존재 여부 
                SELECT DECODE( COUNT(*) , 0 , 'N', 'Y')
                INTO   V_IS_HIS
                FROM   ITEM_CHAIN_HIS
                WHERE  COMP_CD  = PSV_COMP_CD
                AND    BRAND_CD = v_in_brand_cd
                AND    STOR_TP  = v_in_stor_tp
                AND    ITEM_CD  = v_item_cd
                AND    PSV_MV_DT BETWEEN START_DT AND NVL(CLOSE_DT, '99991231') 
                ;
            
            END;
            
            IF( V_IS_HIS = 'N' ) THEN
            
                v_err_cd  := '20004';
                v_err_msg := 'ITEM_CHAIN_HIS - (입고점포) 정보가 없습니다.';
            
                RAISE ERR_UPDATE_HANDLER;
            
            END IF;
            
            -- 이동순번
            BEGIN
            
                SELECT NVL(MAX(SEQ), 'N')
                INTO   v_seq 
                FROM   MOVE_STORE
                WHERE  COMP_CD      = PSV_COMP_CD
                AND    MV_DT        = PSV_MV_DT
                AND    OUT_BRAND_CD = v_out_brand_cd
                AND    OUT_STOR_CD  = v_out_stor_cd
                AND    IN_BRAND_CD  = v_in_brand_cd
                AND    IN_STOR_CD   = v_in_stor_cd
                AND    CONFIRM_DIV  = '1'
                AND    INST_USER    = PSV_USER_ID
                ;
            
            END;
            
            IF( v_seq = 'N' ) THEN
            
                SELECT TO_NUMBER(NVL(MAX(SEQ), '0')) + 1
                INTO   v_seq 
                FROM   MOVE_STORE
                WHERE  COMP_CD      = PSV_COMP_CD
                AND    MV_DT        = PSV_MV_DT
                AND    OUT_BRAND_CD = v_out_brand_cd
                AND    OUT_STOR_CD  = v_out_stor_cd
                AND    IN_BRAND_CD  = v_in_brand_cd
                AND    IN_STOR_CD   = v_in_stor_cd
                ;
            
            END IF;
            
            
            -- 중복여부 체크
            BEGIN
            
                SELECT DECODE( COUNT(*) , 0 , 'N', 'Y')
                INTO   V_DUP_CHECK    
                FROM   MOVE_STORE
                WHERE  COMP_CD      = PSV_COMP_CD
                AND    MV_DT        = PSV_MV_DT
                AND    OUT_BRAND_CD = v_out_brand_cd
                AND    OUT_STOR_CD  = v_out_stor_cd
                AND    IN_BRAND_CD  = v_in_brand_cd
                AND    IN_STOR_CD   = v_in_stor_cd
                AND    SEQ          = v_seq
                AND    ITEM_CD      = v_item_cd
                ;
            
            END;
            
            IF( V_DUP_CHECK = 'Y' ) THEN
                 
                v_err_cd  := '20005';
                v_err_msg := 'MOVE_STORE 상품이 중복되었습니다.';
                
                RAISE ERR_UPDATE_HANDLER;
                
            END IF; 
            
            
            
            BEGIN
            
                INSERT INTO MOVE_STORE (
                      COMP_CD
                    , MV_DT
                    , OUT_BRAND_CD
                    , OUT_STOR_CD
                    , IN_BRAND_CD
                    , IN_STOR_CD
                    , SEQ
                    , ITEM_CD
                    , MV_UNIT
                    , MV_UNIT_QTY
                    , MV_QTY
                    , MV_CQTY
                    , OUT_COST
                    , OUT_COST_AMT
                    , OUT_COST_VAT
                    , IN_COST
                    , IN_COST_AMT
                    , IN_COST_VAT
                    , CONFIRM_DIV
                    , OUT_CONF_DT
                    , IN_CONF_DT
                    , HQ_CONF_DT
                    , TRANS_YN
                    , REMARKS
                    , INST_DT
                    , INST_USER
                    , UPD_DT
                    , UPD_USER
                ) VALUES (
                      PSV_COMP_CD
                    , PSV_MV_DT
                    , v_out_brand_cd
                    , v_out_stor_cd
                    , v_in_brand_cd
                    , v_in_stor_cd
                    , v_seq
                    , v_item_cd
                    , v_mv_unit
                    , v_mv_unit_qty
                    , v_mv_qty
                    , v_mv_qty
                    , v_out_cost
                    , v_out_cost_amt
                    , v_out_cost_vat
                    , v_in_cost
                    , v_in_cost_amt
                    , v_in_cost_vat
                    , '1'
                    , NULL
                    , NULL
                    , NULL
                    , 'N'
                    , 'EXECEL UPLOAD'
                    , SYSDATE
                    , PSV_USER_ID
                    , SYSDATE
                    , PSV_USER_ID
                )
                ;
                
                -- 출고확정
                UPDATE  MOVE_STORE
                   SET  CONFIRM_DIV  = '2'
                     ,  OUT_CONF_DT  = PSV_MV_DT
                 WHERE  COMP_CD     = PSV_COMP_CD
                   AND  MV_DT       = PSV_MV_DT
                   AND  OUT_BRAND_CD= v_out_brand_cd
                   AND  OUT_STOR_CD = v_out_stor_cd
                   AND  IN_BRAND_CD = v_in_brand_cd
                   AND  IN_STOR_CD  = v_in_stor_cd
                   AND  SEQ         = v_seq
                   AND  ITEM_CD     = v_item_cd;
                   
                
                -- 입고확정
                UPDATE  MOVE_STORE
                   SET  CONFIRM_DIV = '4'
                     ,  IN_CONF_DT  = PSV_MV_DT
                     ,  HQ_CONF_DT  = PSV_MV_DT
                 WHERE  COMP_CD     = PSV_COMP_CD
                   AND  MV_DT       = PSV_MV_DT
                   AND  OUT_BRAND_CD= v_out_brand_cd
                   AND  OUT_STOR_CD = v_out_stor_cd
                   AND  IN_BRAND_CD = v_in_brand_cd
                   AND  IN_STOR_CD  = v_in_stor_cd
                   AND  SEQ         = v_seq
                   AND  ITEM_CD     = v_item_cd;
                
            END;
           
            
            BEGIN
            
                UPDATE MOVE_FILE_UPLOAD
                SET    PRC_DIV = 'Y'
                WHERE  COMP_CD     = PSV_COMP_CD 
                AND    MV_DT       = PSV_MV_DT
                AND    MV_USER_ID  = PSV_USER_ID
                AND    MV_SEQ      = PSV_MV_SEQ
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
            
                UPDATE MOVE_FILE_UPLOAD
                SET    PRC_DIV = 'E'
                   ,   ERR_CD  = v_err_cd 
                   ,   ERR_MSG = v_err_msg
                WHERE  COMP_CD     = PSV_COMP_CD 
                AND    MV_DT       = PSV_MV_DT
                AND    MV_USER_ID  = PSV_USER_ID
                AND    MV_SEQ      = PSV_MV_SEQ
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
            
    
END PKG_ORDR4450;

/
