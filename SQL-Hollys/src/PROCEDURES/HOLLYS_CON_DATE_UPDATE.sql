--------------------------------------------------------
--  DDL for Procedure HOLLYS_CON_DATE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HOLLYS_CON_DATE_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	할리스콘 유효기간 연장(CRM)
-- Test			:	exec HOLLYS_CON_DATE_UPDATE '002', '', '', '' 
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
                     WHEN TO_DATE(A.START_DT,'YYYYMMDD') < ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60) THEN '509' -- 쿠폰 최초 사용가능일로부터 5년이 넘었습니다.
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
            AND    USE_DT IS NULL 
            AND    DESTROY_DT IS NULL
            AND    COUPON_STATE = 'P0303'
            AND    TO_DATE(START_DT,'YYYYMMDD') > ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')), -60);

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
                   SELECT	A.COUPON_CD
                           ,v_coupon_his_seq
                           ,A.PUBLISH_ID
                           ,'P0308'
                           ,A.START_DT
                           ,TO_CHAR(TO_DATE(A.END_DT)+93,'YYYYMMDD')
                           ,A.USE_DT
                           ,A.DESTROY_DT
                           ,A.GROUP_ID_HIS
                           ,A.CUST_ID
                           ,A.TO_CUST_ID
                           ,A.FROM_CUST_ID
                           ,A.MOBILE
                           ,A.RECEPTION_MOBILE
                           ,A.POS_NO
                           ,A.BILL_NO
                           ,A.POS_SEQ
                           ,A.STOR_CD
                           ,A.POS_SALE_DT
                           ,A.PUB_STOR_CD
                           ,A.ITEM_CD
                           ,A.COUPON_IMG
                           ,P_USER_ID
                           ,SYSDATE
                    FROM	PROMOTION_COUPON_HIS A
                    WHERE	A.COUPON_CD = P_COUPON_CD
                    AND     A.CUST_ID = P_CUST_ID
                    ORDER BY A.COUPON_HIS_SEQ,A.INST_DT DESC
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
                            ,TO_CHAR(TO_DATE(A.END_DT)+93,'YYYYMMDD')
                            ,A.BUY_DT
                            ,A.USE_DT 
                            ,A.DESTROY_DT
                            ,A.STOR_CD
                            ,'P0308'
                            ,CASE WHEN A.EXTENSION_COUNT IS NOT NULL THEN TO_NUMBER(A.EXTENSION_COUNT) + 1
                                  ELSE 1
                             END
                            ,A.SEND_COUNT
                            ,A.QTY
                            ,A.PAYMENT_REQ
                            ,v_hollys_con_his_seq
                            ,P_USER_ID
                            ,SYSDATE
                    FROM	HOLLYS_CON_HIS A
                    WHERE	A.COUPON_CD = P_COUPON_CD
                    ORDER BY A.HOLLYS_CON_HIS_SEQ DESC
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

END HOLLYS_CON_DATE_UPDATE;

/
