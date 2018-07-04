--------------------------------------------------------
--  DDL for Procedure PROMOTION_PRINT_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_PRINT_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 영수증정보 등록/수정
-- Test			:	exec PROMOTION_PRINT_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2,
        P_RECEIPT_TYPE    IN   VARCHAR2,
        N_EFFECTIVE_TIME  IN   VARCHAR2,
        N_BILL_COUNT      IN   VARCHAR2,
        P_PAY_METHOD      IN   VARCHAR2,
        P_PRINT_RECEIPT   IN   VARCHAR2,
        P_PRINT_METHOD    IN   CHAR,
        N_STOR_PUBL_QTY   IN   VARCHAR2,
        P_REUSE_YN        IN   CHAR,
        N_PRINT_TYPE_1    IN   CHAR, 
        N_PREFACE         IN   VARCHAR2,
        N_MAIN_TEXT       IN   VARCHAR2,
        N_FOOTER          IN   VARCHAR2,
        N_PRINT_TYPE_2    IN   CHAR,
        N_PRINT_TYPE_3    IN   CHAR,
        N_MENU_COUNT      IN   VARCHAR2,
        N_PRINT_URL       IN   VARCHAR2,
        P_USER_ID         IN   VARCHAR2,
        O_PRMT_ID         OUT  VARCHAR2
) AS 
BEGIN  
        MERGE INTO PROMOTION_PRINT
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
           )
        WHEN MATCHED THEN

        UPDATE    
           SET   RECEIPT_TYPE   = P_RECEIPT_TYPE
                ,EFFECTIVE_TIME = N_EFFECTIVE_TIME
                ,BILL_COUNT     = N_BILL_COUNT
                ,PAY_METHOD     = P_PAY_METHOD
                ,PRINT_RECEIPT  = P_PRINT_RECEIPT
                ,PRINT_METHOD   = DECODE(P_PRINT_METHOD, '1', '1', '0')
                ,STOR_PUBL_QTY  = N_STOR_PUBL_QTY
                ,REUSE_YN       = DECODE(P_REUSE_YN, 'Y', 'Y', 'N')
                ,PRINT_TYPE_1   = DECODE(N_PRINT_TYPE_1, 'Y', 'Y', 'N')
                ,PREFACE        = N_PREFACE
                ,MAIN_TEXT      = N_MAIN_TEXT
                ,FOOTER         = N_FOOTER
                ,UPD_USER       = P_USER_ID
                ,UPD_DT         = SYSDATE
                ,PRINT_TYPE_2   = DECODE(N_PRINT_TYPE_2, 'Y', 'Y', 'N')
                ,PRINT_TYPE_3   = DECODE(N_PRINT_TYPE_3, 'Y', 'Y', 'N')
                ,MENU_COUNT     = N_MENU_COUNT
                ,PRINT_URL      = N_PRINT_URL
        WHERE    PRMT_ID        = P_PRMT_ID

        WHEN NOT MATCHED THEN

        INSERT 
        (      
                PRMT_ID
                ,RECEIPT_TYPE
                ,EFFECTIVE_TIME
                ,BILL_COUNT
                ,PAY_METHOD
                ,PRINT_RECEIPT
                ,PRINT_METHOD
                ,STOR_PUBL_QTY
                ,REUSE_YN
                ,PRINT_TYPE_1
                ,PREFACE
                ,MAIN_TEXT
                ,FOOTER
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
                ,PRINT_TYPE_2
                ,PRINT_TYPE_3
                ,MENU_COUNT  
                ,PRINT_URL
       ) VALUES (   
                 P_PRMT_ID
                ,P_RECEIPT_TYPE
                ,N_EFFECTIVE_TIME
                ,N_BILL_COUNT
                ,P_PAY_METHOD
                ,P_PRINT_RECEIPT
                ,DECODE(P_PRINT_METHOD, '1', '1', '0')
                ,N_STOR_PUBL_QTY
                ,DECODE(P_REUSE_YN, 'Y', 'Y', 'N')
                ,DECODE(N_PRINT_TYPE_1, 'Y', 'Y', 'N')
                ,N_PREFACE
                ,N_MAIN_TEXT
                ,N_FOOTER
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,DECODE(N_PRINT_TYPE_2, 'Y', 'Y', 'N')
                ,DECODE(N_PRINT_TYPE_3, 'Y', 'Y', 'N')
                ,N_MENU_COUNT
                ,N_PRINT_URL
       );
       
       O_PRMT_ID := P_PRMT_ID;
END PROMOTION_PRINT_SAVE;

/
