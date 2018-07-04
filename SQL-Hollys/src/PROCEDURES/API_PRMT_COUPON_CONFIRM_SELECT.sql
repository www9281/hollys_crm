--------------------------------------------------------
--  DDL for Procedure API_PRMT_COUPON_CONFIRM_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_COUPON_CONFIRM_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰인증 조회
-- Test			:	exec API_PRMT_COUPON_CONFIRM_SELECT '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_COUPON_CD     IN   VARCHAR2,
        P_STOR_CD       IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,  
        O_RTN_CD        OUT  VARCHAR2,  
        O_PRMT_ID       OUT  VARCHAR2
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
        v_check_cd  VARCHAR2(7);
        v_prmt_id   VARCHAR2(5);
        
        v_count   NUMBER; 
        
        NOT_EXISTS_COUPON EXCEPTION;
BEGIN  

        SELECT  COUNT(*)
                INTO v_count
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B  
        ON      A.PUBLISH_ID = B.PUBLISH_ID 
        JOIN    PROMOTION C
        ON      C.COMP_CD = P_COMP_CD
        AND     C.BRAND_CD = P_BRAND_CD
        AND     C.PRMT_ID = B.PRMT_ID
        WHERE   A.COUPON_CD = P_COUPON_CD; 
        
        -- 쿠폰 존재 확인
        IF v_count < 1 THEN
            RAISE NOT_EXISTS_COUPON;
        END IF;

        SELECT
                CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                     WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                     WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                     WHEN A.TG_STOR_CD IS NOT NULL AND A.TG_STOR_CD <> P_STOR_CD THEN '516' -- 본 쿠폰은 발급받은 매장에서만 사용가능합니다. 쿠폰의 발행매장을 확인해주세요.
                     ELSE '1'
                END
                , B.PRMT_ID 
                INTO v_check_cd, v_prmt_id
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B  
        ON      A.PUBLISH_ID = B.PUBLISH_ID 
        JOIN    PROMOTION C
        ON      C.COMP_CD = P_COMP_CD
        AND     C.BRAND_CD = P_BRAND_CD
        AND     C.PRMT_ID = B.PRMT_ID
        WHERE   A.COUPON_CD = P_COUPON_CD; 
        
        IF v_check_cd <> '1' THEN
           v_result_cd := v_check_cd;
        END IF;
        
        IF v_result_cd = '1' THEN
           O_PRMT_ID := v_prmt_id;
        END IF;
        
        O_RTN_CD := v_result_cd;
        
EXCEPTION
    WHEN NOT_EXISTS_COUPON THEN
         O_RTN_CD  := '500'; --쿠폰정보가 없습니다.
         dbms_output.put_line(SQLERRM);
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
END API_PRMT_COUPON_CONFIRM_SELECT;

/
