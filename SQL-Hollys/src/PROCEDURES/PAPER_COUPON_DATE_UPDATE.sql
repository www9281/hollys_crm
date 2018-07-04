--------------------------------------------------------
--  DDL for Procedure PAPER_COUPON_DATE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PAPER_COUPON_DATE_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	지류이벤트 쿠폰 유효기간 변경
-- Test			:	exec PAPER_COUPON_DATE_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_COUPON_CD            IN    VARCHAR2,
        P_START_DT             IN    VARCHAR2,
        P_END_DT               IN    VARCHAR2, 
        P_USER_ID              IN    VARCHAR2,
        O_PUBLISH_ID           OUT   VARCHAR2,
        O_PUBLISH_TYPE         OUT   VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)
        v_coupon_his_seq NUMBER; -- 쿠폰히스토리시퀀스

BEGIN   
        -- 쿠폰기간 확인
        SELECT
                CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다. 
                     WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                     --WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                     ELSE '1'
                END
                INTO v_result_cd
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID
        WHERE   A.COUPON_CD = P_COUPON_CD; 
        
        -- PUBLISH_ID,TYPE 구함
        SELECT  A.PUBLISH_ID
                ,B.PUBLISH_TYPE
                INTO O_PUBLISH_ID
                ,O_PUBLISH_TYPE
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID
        WHERE   A.COUPON_CD = P_COUPON_CD;

        IF v_result_cd = '1' THEN
            -- 쿠폰 기간연장
            UPDATE PROMOTION_COUPON
            SET    START_DT = P_START_DT
                   ,END_DT = P_END_DT 
                   ,UPD_USER = P_USER_ID
                   ,UPD_DT = SYSDATE
            WHERE  COUPON_CD = P_COUPON_CD
            AND    USE_DT IS NULL 
            AND    DESTROY_DT IS NULL
            AND    COUPON_STATE = 'P0303';
            dbms_output.put_line('1111111111111111');

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
                   SELECT	COUPON_CD
                           ,v_coupon_his_seq
                           ,PUBLISH_ID
                           ,'P0308'
                           ,P_START_DT
                           ,P_END_DT
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
                           ,STOR_CD
                           ,POS_SALE_DT
                           ,PUB_STOR_CD
                           ,ITEM_CD
                           ,COUPON_IMG
                           ,P_USER_ID
                           ,SYSDATE
                    FROM	PROMOTION_COUPON_HIS 
                    WHERE	COUPON_CD = P_COUPON_CD
                    ORDER BY COUPON_HIS_SEQ,INST_DT DESC
            )A 
            WHERE ROWNUM = 1;

        END IF;

        O_RTN_CD := v_result_cd;
        dbms_output.put_line(SQLERRM);
EXCEPTION

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END PAPER_COUPON_DATE_UPDATE;

/
