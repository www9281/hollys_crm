--------------------------------------------------------
--  DDL for Procedure API_WEB_COUPON_GIFT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_WEB_COUPON_GIFT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰 선물하기 및 등록하기
-- Test			:	exec API_WEB_COUPON_GIFT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_COUPON_CD     IN   VARCHAR2,
        P_FROM_CUST_ID  IN   VARCHAR2,
        P_TO_CARD_ID    IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2, 
        O_RTN_CD        OUT   VARCHAR2
) AS 

        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)
        v_coupon_his_seq NUMBER; -- 쿠폰히스토리시퀀스 
        v_chk_cust VARCHAR2(100); -- 받는 고객확인
        v_cust_id VARCHAR2(20); -- 받는 고객아이디
        NOT_EXIST_CUST EXCEPTION;
 
BEGIN  
        -- 받는 고객 존재 확인
        SELECT CUST_ID
               INTO v_chk_cust
        FROM   C_CARD
        WHERE  CARD_ID = ENCRYPT(P_TO_CARD_ID)
        AND    REP_CARD_YN = 'Y'
        AND    USE_YN = 'Y';

        IF v_chk_cust IS NULL THEN
          RAISE NOT_EXIST_CUST;
        END IF;
        
        -- 받는 고객아이디 저장
        SELECT CUST_ID
               INTO v_cust_id
        FROM   C_CARD
        WHERE  CARD_ID = ENCRYPT(P_TO_CARD_ID)
        AND    REP_CARD_YN = 'Y'
        AND    USE_YN = 'Y';

        -- 쿠폰기간 확인
        SELECT
                CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                     WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 폐기된 쿠폰입니다.
                     WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                     WHEN B.PUBLISH_TYPE = 'C6503' THEN '512' -- 할리스콘은 선물하기 대상상품이 아닙니다.
                     ELSE '1'
                END
                INTO v_result_cd
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID
        WHERE   A.COUPON_CD = P_COUPON_CD 
        AND     A.CUST_ID = P_FROM_CUST_ID; 

        -- 사용가능한 쿠폰일 경우만
        IF v_result_cd = '1' THEN

             -- 쿠폰 명의 이관
            UPDATE  PROMOTION_COUPON B
            SET     B.CUST_ID = v_cust_id
                    ,B.UPD_DT = SYSDATE
                    ,B.UPD_USER = P_USER_ID
            WHERE   B.COUPON_CD = P_COUPON_CD
            AND     B.CUST_ID = P_FROM_CUST_ID;

            -- 쿠폰 히스토리 기록
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
           SELECT   C.* 
           FROM (
                   SELECT	COUPON_CD
                           ,v_coupon_his_seq
                           ,PUBLISH_ID
                           ,'P0305'
                           ,START_DT
                           ,END_DT
                           ,USE_DT
                           ,DESTROY_DT
                           ,GROUP_ID_HIS
                           ,CUST_ID
                           ,(
                                SELECT  CUST_ID
                                FROM    C_CARD
                                WHERE   CARD_ID = ENCRYPT(P_TO_CARD_ID)
                                AND     REP_CARD_YN = 'Y'
                                AND     USE_YN = 'Y'
                           )
                           ,P_FROM_CUST_ID
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
                    FROM	PROMOTION_COUPON_HIS 
                    WHERE	COUPON_CD = P_COUPON_CD
                    AND     CUST_ID = P_FROM_CUST_ID
                    ORDER BY INST_DT DESC
             )C 
            WHERE ROWNUM = 1;

        END IF;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN NOT_EXIST_CUST THEN
        O_RTN_CD  := '171'; -- 해당 고객을 찾을 수 없습니다.
        dbms_output.put_line(SQLERRM);

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END API_WEB_COUPON_GIFT;

/
