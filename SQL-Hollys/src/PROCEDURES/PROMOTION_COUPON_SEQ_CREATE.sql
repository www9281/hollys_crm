--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_SEQ_CREATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_SEQ_CREATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰 시퀀스 생성 
-- Test			:	exec PROMOTION_COUPON_SEQ_CREATE '016', '102', '13'
-- ==========================================================================================
        O_RTN_CD            OUT  VARCHAR2,
        O_COUPON_SEQ        OUT  VARCHAR2
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
BEGIN  

        SELECT COUPON_SEQ.NEXTVAL
        INTO O_COUPON_SEQ
        FROM DUAL;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패

END PROMOTION_COUPON_SEQ_CREATE;

/
