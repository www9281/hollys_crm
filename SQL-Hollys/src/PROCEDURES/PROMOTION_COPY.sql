--------------------------------------------------------
--  DDL for Procedure PROMOTION_COPY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COPY" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 복사
-- Test			:	PROMOTION_COPY '00001', 'TEST'
-- ==========================================================================================
        P_PRMT_ID    IN    VARCHAR2,
        P_USER_ID    IN    VARCHAR2,
        O_PRMT_ID    OUT   VARCHAR2,
        O_PUSH_NO    OUT   VARCHAR2
) AS 
BEGIN

		SELECT SQ_PRMT_ID.NEXTVAL  
        INTO O_PRMT_ID
        FROM DUAL;

        --프로모션 정보저장
		INSERT	INTO	PROMOTION (
				 PRMT_ID
                ,SUB_PRMT_ID  
                ,COMP_CD
                ,BRAND_CD
                ,PRMT_CLASS
                ,PRMT_TYPE
                ,PRMT_NM
                ,PRMT_DT_START
                ,PRMT_DT_END
                ,PRMT_USE_DIV
                ,PRMT_COUPON_YN
                ,PRMT_TIME_HH_START
                ,PRMT_TIME_MM_START
                ,PRMT_TIME_HH_END
                ,PRMT_TIME_MM_END
                ,PRMT_WEEK_1
                ,PRMT_WEEK_2
                ,PRMT_WEEK_3
                ,PRMT_WEEK_4
                ,PRMT_WEEK_5
                ,PRMT_WEEK_6 
                ,PRMT_WEEK_7
                ,COUPON_DT_TYPE
                ,COUPON_EXPIRE
                ,COUPON_IMG_TYPE
                ,MODIFY_DIV_1
                ,REWARD_TERM 
                ,LVL_CD_1
                ,LVL_CD_2
                ,LVL_CD_3
                ,LVL_CD_4
                ,PRINT_TARGET
                ,MODIFY_DIV_2
                ,CONDITION_QTY_REQ 
                ,CONDITION_QTY_NOR
                ,CONDITION_AMT
                ,GIVE_QTY
                ,SALE_RATE
                ,SALE_AMT
                ,GIVE_REWARD
                ,COUPON_NOTICE
                ,COUPON_NOTICE_PRINT
                ,REMARKS
                ,REMARKS_PRINT
                ,AGREE_YN
                ,AGREE_ID
                ,AGREE_DT
                ,STOR_LIMIT
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PRMT_ID
                ,SUB_PRMT_ID
                ,COMP_CD
                ,BRAND_CD
                ,PRMT_CLASS
                ,PRMT_TYPE
                ,PRMT_NM
                ,PRMT_DT_START
                ,PRMT_DT_END
                ,PRMT_USE_DIV
                ,PRMT_COUPON_YN
                ,PRMT_TIME_HH_START
                ,PRMT_TIME_MM_START
                ,PRMT_TIME_HH_END
                ,PRMT_TIME_MM_END
                ,PRMT_WEEK_1
                ,PRMT_WEEK_2
                ,PRMT_WEEK_3
                ,PRMT_WEEK_4
                ,PRMT_WEEK_5
                ,PRMT_WEEK_6
                ,PRMT_WEEK_7
                ,COUPON_DT_TYPE
                ,COUPON_EXPIRE
                ,COUPON_IMG_TYPE
                ,MODIFY_DIV_1
                ,REWARD_TERM
                ,LVL_CD_1
                ,LVL_CD_2
                ,LVL_CD_3
                ,LVL_CD_4
                ,PRINT_TARGET
                ,MODIFY_DIV_2
                ,CONDITION_QTY_REQ
                ,CONDITION_QTY_NOR
                ,CONDITION_AMT
                ,GIVE_QTY
                ,SALE_RATE
                ,SALE_AMT
                ,GIVE_REWARD
                ,COUPON_NOTICE
                ,COUPON_NOTICE_PRINT
                ,REMARKS
                ,REMARKS_PRINT
                ,AGREE_YN
                ,AGREE_ID
                ,AGREE_DT
                ,STOR_LIMIT
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 대상메뉴군저장
		INSERT	INTO	PROMOTION_TARGET_MN_GP	(
                PRMT_ID
                ,D_CLASS_CD
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
                ,L_CLASS_CD
                ,M_CLASS_CD
                ,S_CLASS_CD
                ,QTY
                ,ITEM_DIV
		)
		SELECT	O_PRMT_ID
                ,D_CLASS_CD
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,L_CLASS_CD
                ,M_CLASS_CD
                ,S_CLASS_CD
                ,QTY
                ,ITEM_DIV
		FROM	PROMOTION_TARGET_MN_GP
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 대상메뉴저장
		INSERT	INTO	PROMOTION_TARGET_MN	(
				PRMT_ID
                ,ITEM_DIV
                ,ITEM_CD
                ,QTY
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
                ,USE_YN
		)
		SELECT	O_PRMT_ID
                ,ITEM_DIV
                ,ITEM_CD
                ,QTY
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,USE_YN
		FROM	PROMOTION_TARGET_MN
		WHERE	PRMT_ID = P_PRMT_ID;
        
        --프로모션 대상메뉴군저장
		INSERT	INTO	PROMOTION_BNFIT_MN_GP	(
				PRMT_ID
                ,D_CLASS_CD
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
                ,QTY
                ,SALE_PRC
                ,SALE_RATE
                ,BNFIT_DIV
                ,GIVE_REWARD
                ,L_CLASS_CD
                ,M_CLASS_CD
                ,S_CLASS_CD
		)
		SELECT	O_PRMT_ID
                ,D_CLASS_CD
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,QTY
                ,SALE_PRC
                ,SALE_RATE
                ,BNFIT_DIV
                ,GIVE_REWARD
                ,L_CLASS_CD
                ,M_CLASS_CD
                ,S_CLASS_CD
		FROM	PROMOTION_BNFIT_MN_GP
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 혜택메뉴저장
		INSERT	INTO	PROMOTION_BNFIT_MN	(
				PRMT_ID
                ,ITEM_CD
                ,QTY
                ,SALE_PRC
                ,SALE_RATE
                ,BNFIT_DIV
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
                ,GIVE_REWARD
                ,DC_AMT_H
                ,USE_YN
		)
		SELECT	O_PRMT_ID
                ,ITEM_CD
                ,QTY
                ,SALE_PRC
                ,SALE_RATE
                ,BNFIT_DIV
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,GIVE_REWARD
                ,DC_AMT_H
                ,USE_YN
		FROM	PROMOTION_BNFIT_MN
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 대상매장그룹저장
		INSERT	INTO PROMOTION_CAN_STOR_GP (
				PRMT_ID
                ,STOR_GP_ID
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PRMT_ID
                ,STOR_GP_ID
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION_CAN_STOR_GP
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 대상매장저장
		INSERT	INTO	PROMOTION_CAN_STOR	(
				PRMT_ID
                ,STOR_CD
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PRMT_ID
                ,STOR_CD
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION_CAN_STOR
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 적용매장군저장
		INSERT	INTO PROMOTION_STOR_GP	(
				PRMT_ID
                ,STOR_GP_ID
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PRMT_ID
                ,STOR_GP_ID
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION_STOR_GP
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 적용매장저장
		INSERT	INTO PROMOTION_STOR	(
				PRMT_ID
                ,STOR_CD
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PRMT_ID
                ,STOR_CD
                ,USE_YN
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION_STOR
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 영수증정보저장
		INSERT	INTO PROMOTION_PRINT	(
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
		)
		SELECT	O_PRMT_ID
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
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
                ,PRINT_TYPE_2
                ,PRINT_TYPE_3
                ,MENU_COUNT
                ,PRINT_URL
		FROM	PROMOTION_PRINT
		WHERE	PRMT_ID = P_PRMT_ID;

        --프로모션 SMS정보저장
		INSERT	INTO PROMOTION_SMS	(
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
		)
		SELECT	O_PRMT_ID
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
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM	PROMOTION_SMS
		WHERE	PRMT_ID = P_PRMT_ID;
        
        SELECT SQ_PUSH_NO.NEXTVAL
        INTO O_PUSH_NO
        FROM DUAL;
        
        --프로모션 PUSH정보저장
		INSERT	INTO PROMOTION_PUSH	(
				PUSH_NO
                ,PRMT_ID
                ,PUSH_TYPE
                ,PUSH_YN
                ,PUSH_TITLE
                ,PUSH_CONTENTS
                ,PUSH_LINK
                ,IMG_URL
                ,BOOK_DT
                ,BOOK_HOUR
                ,BOOK_MINUTE
                ,PUSH_SEND_DIV
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
		)
		SELECT	O_PUSH_NO
                ,O_PRMT_ID
                ,A.PUSH_TYPE
                ,A.PUSH_YN
                ,A.PUSH_TITLE
                ,A.PUSH_CONTENTS
                ,A.PUSH_LINK
                ,A.IMG_URL
                ,A.BOOK_DT
                ,A.BOOK_HOUR
                ,A.BOOK_MINUTE
                ,A.PUSH_SEND_DIV
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
		FROM    PROMOTION_PUSH A
        LEFT    OUTER JOIN SY_CONTENT_FILE B
        ON      TABLE_NAME = 'PROMOTION_PUSH'
        AND     A.PRMT_ID = B.REF_ID
		WHERE	A.PRMT_ID = P_PRMT_ID;

		COMMIT;
        
END PROMOTION_COPY;

/
