--------------------------------------------------------
--  DDL for Procedure PROMOTION_SMS_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SMS_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 SMS 상세보기
-- Test			:	exec PROMOTION_SMS_VIEW '002', 'Y'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     SMS_SENDER_ID  AS SMS_SENDER_ID
                 , A.STOR_CD AS STOR_CD
                 , A.SMS_TITLE AS SMS_TITLE
                 , A.SMS_CONTENTS AS SMS_CONTENTS
                 , A.CUST_IMAGE_YN  AS CUST_IMAGE_YN
                 , A.TERM_X  AS TERM_X
                 , A.TERM_Y  AS TERM_Y                 
                 , A.TERM_WIDTH  AS TERM_WIDTH 
                 , A.TERM_HEIGHT  AS TERM_HEIGHT
                 , A.BARCODE_X  AS BARCODE_X
                 , A.BARCODE_Y  AS BARCODE_Y
                 , A.BARCODE_WIDTH  AS BARCODE_WIDTH
                 , A.BARCODE_HEIGHT  AS BARCODE_HEIGHT                 
                 , A.INST_USER  AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD')  AS INST_DT
                 , A.UPD_USER  AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD')  AS UPD_DT
                 , CASE WHEN B.FILE_ID IS NULL
                        THEN  ''
                        ELSE  B.FOLDER|| B.FILE_ID || '.' || B.FILE_EXT
                    END AS IMG_URL
                 , B.FILE_ID
        FROM       PROMOTION_SMS A
        LEFT      OUTER JOIN SY_CONTENT_FILE B
        ON        TABLE_NAME = 'PROMOTION_SMS'
        AND       A.PRMT_ID = B.REF_ID
        WHERE     A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                    A.PRMT_ID DESC;
END PROMOTION_SMS_VIEW;

/
