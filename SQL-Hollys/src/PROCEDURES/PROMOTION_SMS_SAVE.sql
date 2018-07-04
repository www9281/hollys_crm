--------------------------------------------------------
--  DDL for Procedure PROMOTION_SMS_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SMS_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 SMS 등록/수정
-- Test			:	exec PROMOTION_SMS_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2,
        N_SMS_SENDER_ID   IN   VARCHAR2,
        N_STOR_CD         IN   VARCHAR2,
        N_SMS_TITLE       IN   VARCHAR2,
        N_SMS_CONTENTS    IN   VARCHAR2,
        N_CUST_IMAGE_YN   IN   VARCHAR2,
        N_TERM_X          IN   VARCHAR2,
        N_TERM_Y          IN   VARCHAR2,
        N_TERM_WIDTH      IN   VARCHAR2,
        N_TERM_HEIGHT     IN   VARCHAR2,
        N_BARCODE_X       IN   VARCHAR2,
        N_BARCODE_Y       IN   VARCHAR2,
        N_BARCODE_WIDTH   IN   VARCHAR2,
        N_BARCODE_HEIGHT  IN   VARCHAR2, 
        P_MY_USER_ID      IN   VARCHAR2
) IS
        IS_EXISTS         NUMBER;
BEGIN  

        SELECT  COUNT(*)
        INTO    IS_EXISTS
        FROM    PROMOTION_SMS
        WHERE   PRMT_ID         = P_PRMT_ID;
        
        IF      IS_EXISTS > 0   THEN

        UPDATE    PROMOTION_SMS
        SET   SMS_SENDER_ID   = N_SMS_SENDER_ID
             ,STOR_CD         = N_STOR_CD
             ,SMS_TITLE       = N_SMS_TITLE
             ,SMS_CONTENTS    = N_SMS_CONTENTS
             ,CUST_IMAGE_YN   = N_CUST_IMAGE_YN
             ,TERM_X          = N_TERM_X
             ,TERM_Y          = N_TERM_Y
             ,TERM_WIDTH      = N_TERM_WIDTH
             ,TERM_HEIGHT     = N_TERM_HEIGHT
             ,BARCODE_X       = N_BARCODE_X
             ,BARCODE_Y       = N_BARCODE_Y
             ,BARCODE_WIDTH   = N_BARCODE_WIDTH 
             ,BARCODE_HEIGHT  = N_BARCODE_HEIGHT
             ,UPD_USER        = P_MY_USER_ID
             ,UPD_DT          = SYSDATE
        WHERE PRMT_ID         = P_PRMT_ID;

        ELSE

        INSERT INTO PROMOTION_SMS
        (      
                PRMT_ID
                ,SMS_SENDER_ID
                ,STOR_CD
                ,SMS_TITLE
                ,SMS_CONTENTS
                ,CUST_IMAGE_YN
                ,TERM_X
                ,TERM_Y
                ,TERM_WIDTH
                ,TERM_HEIGHT
                ,BARCODE_X 
                ,BARCODE_Y
                ,BARCODE_WIDTH
                ,BARCODE_HEIGHT
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
       ) VALUES (    
                P_PRMT_ID
                ,N_SMS_SENDER_ID
                ,N_STOR_CD
                ,N_SMS_TITLE
                ,N_SMS_CONTENTS
                ,N_CUST_IMAGE_YN
                ,N_TERM_X
                ,N_TERM_Y
                ,N_TERM_WIDTH
                ,N_TERM_HEIGHT
                ,N_BARCODE_X
                ,N_BARCODE_Y
                ,N_BARCODE_WIDTH
                ,N_BARCODE_HEIGHT
                ,P_MY_USER_ID
                ,SYSDATE
                ,NULL
                ,NULL
       );
       
       END      IF;
       
END PROMOTION_SMS_SAVE;

/
