--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_DESTROY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_DESTROY" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-11-16
-- Description    :    쿠폰 폐기
-- Test            :    exec PROMOTION_COUPON_DESTROY '002', '', '', '' 
-- ==========================================================================================
        P_CUST_ID              IN    VARCHAR2,
        P_COUPON_CD            IN    VARCHAR2,
        P_PUBLISH_ID           IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_PUBLISH_ID           OUT   VARCHAR2,
        O_PUBLISH_TYPE         OUT   VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)

        v_exist_coupon VARCHAR2(20); -- 성공(전체결과)
        v_coupon_his_seq VARCHAR2(11); -- 쿠폰히스토리시퀀스  

        NOT_EXIST_COUPON EXCEPTION;

BEGIN
        -- 쿠폰 존재 확인
        SELECT  A.COUPON_CD
                INTO v_exist_coupon
        FROM    PROMOTION_COUPON A
        WHERE   A.COUPON_CD = P_COUPON_CD
        AND     CUST_ID = P_CUST_ID;
 
        IF v_exist_coupon IS NULL THEN
          RAISE NOT_EXIST_COUPON;
        END IF;

        -- 쿠폰기간 확인
        SELECT
                CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                     WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                     WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                     WHEN (B.PUBLISH_TYPE = 'C6503' AND TO_DATE(START_DT,'YYYYMMDD') < ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60)) THEN '509' -- 쿠폰 최초 사용가능일로부터 5년이 넘었습니다.
                     ELSE '1'
                END,
                B.PUBLISH_TYPE
                INTO v_result_cd, O_PUBLISH_TYPE
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID
        WHERE   A.COUPON_CD = P_COUPON_CD
        AND     CUST_ID = P_CUST_ID
        AND     B.PUBLISH_ID = P_PUBLISH_ID; 

        IF v_result_cd = '1' THEN
            -- 쿠폰 폐기
            UPDATE PROMOTION_COUPON
            SET    DESTROY_DT = TO_CHAR(SYSDATE+93,'YYYYMMDD')
                   ,COUPON_STATE = 'P0309'
                   ,UPD_USER = P_USER_ID
                   ,UPD_DT = SYSDATE
            WHERE  COUPON_CD = P_COUPON_CD
            AND    CUST_ID = P_CUST_ID
            AND    PUBLISH_ID = P_PUBLISH_ID
            AND    USE_DT IS NULL
            AND    DESTROY_DT IS NULL;

            -- 쿠폰 연장 기록 히스토리 적용
           SELECT COUPON_HIS_SEQ.NEXTVAL
           INTO v_coupon_his_seq
           FROM DUAL;

           INSERT INTO PROMOTION_COUPON_HIS
           (       
                   COUPON_CD
                   ,COUPON_HIS_SEQ
                   ,PUBLISH_ID
                   ,COUPON_STATE
                   ,START_DT
                   ,END_DT
                   ,USE_DT
                   ,DESTROY_DT
                   ,GROUP_ID_HIS
                   ,CUST_ID
                   ,TO_CUST_ID
                   ,FROM_CUST_ID
                   ,MOBILE
                   ,RECEPTION_MOBILE
                   ,POS_NO
                   ,BILL_NO
                   ,POS_SEQ
                   ,POS_SALE_DT
                   ,STOR_CD
                   ,PUB_STOR_CD
                   ,ITEM_CD
                   ,COUPON_IMG
                   ,INST_USER
                   ,INST_DT
           ) 
           SELECT   A.* 
           FROM (
                   SELECT    COUPON_CD
                           ,v_coupon_his_seq
                           ,PUBLISH_ID
                           ,'P0309'
                           ,START_DT
                           ,END_DT
                           ,USE_DT
                           ,DESTROY_DT
                           ,GROUP_ID_HIS
                           ,CUST_ID
                           ,TO_CUST_ID
                           ,FROM_CUST_ID
                           ,MOBILE
                           ,RECEPTION_MOBILE
                           ,POS_NO
                           ,BILL_NO
                           ,POS_SEQ
                           ,POS_SALE_DT
                           ,STOR_CD
                           ,PUB_STOR_CD
                           ,ITEM_CD
                           ,COUPON_IMG
                           ,P_USER_ID
                           ,SYSDATE
                    FROM    PROMOTION_COUPON_HIS 
                    WHERE    COUPON_CD = P_COUPON_CD 
                    AND     CUST_ID = P_CUST_ID
                    AND     PUBLISH_ID = P_PUBLISH_ID
                    ORDER BY INST_DT DESC
             )A 
            WHERE ROWNUM = 1;

        END IF;

        O_PUBLISH_ID := P_PUBLISH_ID;
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN NOT_EXIST_COUPON THEN
        O_RTN_CD  := '500'; -- 쿠폰정보가 없습니다.
        dbms_output.put_line(SQLERRM);

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END PROMOTION_COUPON_DESTROY;

/
