--------------------------------------------------------
--  DDL for Procedure HOLLYSCON_CANCEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HOLLYSCON_CANCEL" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	할리스콘 구매 취소
-- Test			:	exec HOLLYSCON_CANCEL '002', '', '', '' 
-- ==========================================================================================
        P_COUPON_CD            IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과) 
        v_coupon_his_seq NUMBER; -- 쿠폰히스토리시퀀스
        v_hollys_con_his_seq VARCHAR2(11); -- 할리스콘쿠폰히스토리시퀀스

BEGIN

        -- 쿠폰 취소가능 조회 
        SELECT
               CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                    WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                    WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                    WHEN TO_DATE(START_DT,'YYYYMMDD') < ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60) THEN '509' -- 쿠폰 최초 사용가능일로부터 5년이 넘었습니다.
                    ELSE '1'
               END
               INTO v_result_cd
        FROM   PROMOTION_COUPON A
        WHERE  A.COUPON_CD = P_COUPON_CD; 

        IF v_result_cd = '1' THEN

            -- 쿠폰 취소
            UPDATE PROMOTION_COUPON
            SET    COUPON_STATE = 'P0304'
                   ,DESTROY_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
                   ,UPD_USER   = P_USER_ID
                   ,UPD_DT     = SYSDATE
            WHERE  COUPON_CD   = P_COUPON_CD;

            SELECT TO_CHAR(HOLLYS_CON_HIS_SEQ.NEXTVAL)
            INTO v_hollys_con_his_seq
            FROM DUAL;

            -- HOLLYS_CON 테이블 기록
            INSERT INTO HOLLYS_CON_HIS
            (       
                    CARD_ID
                    ,CUST_ID
                    ,CUST_NM
                    ,MOBILE
                    ,TO_CUST_ID
                    ,TO_CUST_NM
                    ,RECEPTION_MOBILE
                    ,ITEM_CD
                    ,COUPON_CD
                    ,COUPON_NM
                    ,COUPON_PRICE
                    ,PT_PAYMENT
                    ,CREDIT_PAYMENT
                    ,MOBILE_PAYMENT
                    ,ETC_PAYMENT
                    ,START_DT
                    ,END_DT
                    ,BUY_DT
                    ,USE_DT
                    ,DESTROY_DT
                    ,STOR_CD
                    ,COUPON_STATE
                    ,EXTENSION_COUNT
                    ,SEND_COUNT
                    ,QTY
                    ,PAYMENT_REQ
                    ,HOLLYS_CON_HIS_SEQ
                    ,INST_USER
                    ,INST_DT
           )
           SELECT   A.* 
           FROM (
                   SELECT	A.CARD_ID
                            ,A.CUST_ID
                            ,A.CUST_NM
                            ,A.MOBILE
                            ,A.TO_CUST_ID
                            ,A.TO_CUST_NM
                            ,A.RECEPTION_MOBILE
                            ,A.ITEM_CD
                            ,A.COUPON_CD
                            ,A.COUPON_NM
                            ,A.COUPON_PRICE
                            ,A.PT_PAYMENT
                            ,A.CREDIT_PAYMENT
                            ,A.MOBILE_PAYMENT
                            ,A.ETC_PAYMENT
                            ,A.START_DT
                            ,A.END_DT
                            ,A.BUY_DT
                            ,A.USE_DT
                            ,TO_CHAR(SYSDATE, 'YYYYMMDD')
                            ,A.STOR_CD
                            ,'P0304'
                            ,A.EXTENSION_COUNT
                            ,A.SEND_COUNT
                            ,A.QTY
                            ,A.PAYMENT_REQ
                            ,v_hollys_con_his_seq
                            ,P_USER_ID
                            ,SYSDATE
                    FROM   HOLLYS_CON_HIS A
                    WHERE  A.COUPON_CD   = P_COUPON_CD
                    ORDER BY A.HOLLYS_CON_HIS_SEQ,A.INST_DT DESC
            )A 
            WHERE ROWNUM = 1;

            SELECT COUPON_HIS_SEQ.NEXTVAL
            INTO v_coupon_his_seq
            FROM DUAL;

            -- 쿠폰 취소 기록 히스토리 적용
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
                   SELECT	P_COUPON_CD
                           ,v_coupon_his_seq
                           ,A.PUBLISH_ID
                           ,'P0304'
                           ,A.START_DT
                           ,A.END_DT
                           ,A.USE_DT
                           ,TO_CHAR(SYSDATE, 'YYYYMMDD')
                           ,NULL
                           ,A.CUST_ID
                           ,A.TO_CUST_ID
                           ,A.FROM_CUST_ID
                           ,A.MOBILE
                           ,A.RECEPTION_MOBILE
                           ,A.POS_NO
                           ,A.BILL_NO
                           ,A.POS_SEQ
                           ,A.POS_SALE_DT
                           ,A.STOR_CD
                           ,A.PUB_STOR_CD 
                           ,A.ITEM_CD
                           ,A.COUPON_IMG
                           ,P_USER_ID
                           ,SYSDATE
                    FROM	PROMOTION_COUPON_HIS A
                    WHERE	A.COUPON_CD = P_COUPON_CD
                    ORDER BY A.COUPON_HIS_SEQ,A.INST_DT DESC
            )A 
            WHERE ROWNUM = 1;

        END IF;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END HOLLYSCON_CANCEL;

/
