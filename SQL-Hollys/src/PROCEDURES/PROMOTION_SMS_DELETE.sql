--------------------------------------------------------
--  DDL for Procedure PROMOTION_SMS_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SMS_DELETE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 SMS 정보삭제
-- Test			:	exec PROMOTION_SMS_DELETE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2
) AS 
BEGIN   

       DELETE PROMOTION_SMS
       WHERE  PRMT_ID = P_PRMT_ID;

END PROMOTION_SMS_DELETE;

/
