--------------------------------------------------------
--  DDL for Procedure API_HOLLYS_CON_DATE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_HOLLYS_CON_DATE_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	할리스콘 유효기간 연장
-- Test			:	exec API_HOLLYS_CON_DATE_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_CUST_ID              IN    VARCHAR2,
        P_COUPON_CD            IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2, 
        O_RTN_CD               OUT   VARCHAR2
) AS 
         
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)

        v_exist_coupon VARCHAR2(20); -- 성공(전체결과)
        v_coupon_his_seq NUMBER; -- 쿠폰히스토리시퀀스
        v_hollys_con_his_seq VARCHAR2(11); -- 할리스콘히스토리시퀀스

        NOT_EXIST_COUPON EXCEPTION;

BEGIN
        -- 쿠폰 존재 확인
        SELECT  A.COUPON_CD
                INTO v_exist_coupon
        FROM    PROMOTION_COUPON A
        WHERE   A.COUPON_CD = P_COUPON_CD
        AND     A.CUST_ID = P_CUST_ID;

        IF v_exist_coupon IS NULL THEN
            RAISE NOT_EXIST_COUPON;
        END IF;
        
        -- 쿠폰기간 확인
        SELECT
                CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다. 
                     WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                     WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                     WHEN TO_DATE(START_DT,'YYYYMMDD') < ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60) THEN '509' -- 쿠폰 최초 사용가능일로부터 5년이 넘었습니다.
                     WHEN B.PUBLISH_TYPE <> 'C6503' THEN '511' -- 쿠폰기간연장은 할리스콘만 가능합니다.
                     ELSE '1'
                END
                INTO v_result_cd
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID
        WHERE   A.COUPON_CD = P_COUPON_CD
        AND     A.CUST_ID = P_CUST_ID; 
        
        IF v_result_cd = '1' THEN
            -- 쿠폰 기간연장
            UPDATE PROMOTION_COUPON
            SET    END_DT = TO_CHAR(TO_DATE(END_DT)+93,'YYYYMMDD') 
                   ,UPD_USER = P_USER_ID
                   ,UPD_DT = SYSDATE
            WHERE  COUPON_CD = P_COUPON_CD
            AND    CUST_ID = P_CUST_ID
            --AND    USE_DT IS NULL 
            --AND    DESTROY_DT IS NULL
            AND    NVL(USE_DT, 'ISNULL') = 'ISNULL'
            AND    NVL(DESTROY_DT, 'ISNULL') = 'ISNULL'
            AND    COUPON_STATE = 'P0303'
            AND    TO_DATE(START_DT,'YYYYMMDD') > ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60);

            -- 쿠폰 재전송

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
                           ,START_DT
                           ,TO_CHAR(TO_DATE(END_DT)+93,'YYYYMMDD')
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
                    AND     CUST_ID = P_CUST_ID
                    ORDER BY COUPON_HIS_SEQ,INST_DT DESC
            )A 
            WHERE ROWNUM = 1;
            
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
                   SELECT	CARD_ID
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
                            ,TO_CHAR(TO_DATE(END_DT)+93,'YYYYMMDD')
                            ,BUY_DT
                            ,USE_DT 
                            ,DESTROY_DT
                            ,STOR_CD
                            ,'P0308'
                            ,CASE WHEN EXTENSION_COUNT IS NOT NULL THEN TO_NUMBER(EXTENSION_COUNT) + 1
                                  ELSE 1
                             END
                            ,SEND_COUNT
                            ,QTY
                            ,PAYMENT_REQ
                            ,v_hollys_con_his_seq
                            ,P_USER_ID
                            ,SYSDATE
                    FROM	HOLLYS_CON_HIS
                    WHERE	COUPON_CD = P_COUPON_CD
                    ORDER BY HOLLYS_CON_HIS_SEQ,INST_DT DESC
            )A 
            WHERE ROWNUM = 1;
            
        END IF;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN NOT_EXIST_COUPON THEN
        O_RTN_CD  := '500'; -- 쿠폰정보가 없습니다.
        dbms_output.put_line(SQLERRM);

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END API_HOLLYS_CON_DATE_UPDATE;

/
