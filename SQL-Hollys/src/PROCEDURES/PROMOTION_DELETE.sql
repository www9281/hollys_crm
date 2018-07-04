--------------------------------------------------------
--  DDL for Procedure PROMOTION_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_DELETE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 삭제
-- Test			:	PROMOTION_DELETE '00001', 'TEST'
-- ==========================================================================================
        P_PRMT_ID  IN    VARCHAR2
) AS 
BEGIN
 
        --프로모션 정보삭제
		DELETE 
        FROM	PROMOTION 
        WHERE	PRMT_ID = P_PRMT_ID;  
        
        --프로모션 대상메뉴삭제
		DELETE
		FROM	PROMOTION_TARGET_MN  
		WHERE	PRMT_ID = P_PRMT_ID;  

        --프로모션 대상메뉴군삭제
		DELETE 
		FROM	PROMOTION_TARGET_MN_GP
		WHERE	PRMT_ID = P_PRMT_ID; 
        
        --프로모션 혜택메뉴삭제 
		DELETE
		FROM	PROMOTION_BNFIT_MN
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 대상메뉴군삭제
		DELETE
		FROM	PROMOTION_BNFIT_MN_GP
		WHERE	PRMT_ID = P_PRMT_ID;
        
        --프로모션 대상매장삭제
		DELETE
		FROM	PROMOTION_CAN_STOR
		WHERE	PRMT_ID = P_PRMT_ID; 

        --프로모션 대상매장그룹삭제
		DELETE
		FROM	PROMOTION_CAN_STOR_GP
		WHERE	PRMT_ID = P_PRMT_ID;
        
        --프로모션 적용매장삭제
		DELETE
		FROM	PROMOTION_STOR
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 적용매장군삭제
		DELETE
		FROM	PROMOTION_STOR_GP 
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 영수증정보삭제
		DELETE
		FROM	PROMOTION_PRINT
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 SMS정보삭제
		DELETE
		FROM	PROMOTION_SMS
		WHERE	PRMT_ID = P_PRMT_ID; 

        --프로모션 PUSH정보삭제
		DELETE
		FROM	PROMOTION_PUSH
		WHERE	PRMT_ID = P_PRMT_ID;

		COMMIT;

END PROMOTION_DELETE;

/
