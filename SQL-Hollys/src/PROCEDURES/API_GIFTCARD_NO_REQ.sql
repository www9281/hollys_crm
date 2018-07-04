--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_NO_REQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_NO_REQ" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	모바일전자상품권 사용가능 번호조회
-- Test			:	exec API_GIFTCARD_NO_REQ '002', '', '', '' 
-- ==========================================================================================
        P_CUST_ID              IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_GIFTCARD_ID          OUT   VARCHAR2,
        O_PIN_NO               OUT   VARCHAR2,
        O_CUST_ID              OUT   VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        v_result_cd VARCHAR2(7) := '1';
        v_giftcard_id VARCHAR2(100); -- 모바일전자상품권 아이디
        v_pin_no VARCHAR2(10); -- 모바일전자상품권 핀번호
        v_giftcard_his_seq NUMBER; -- 모바일전자상품권 히스토리 시퀀스
        v_usable_cnt VARCHAR2(100); -- 모바일전자상품권 잔여카운트

        NOT_EXIST_USE_CARD EXCEPTION;
BEGIN

        -- 모바일전자상품권 잔여 여부 확인
        SELECT COUNT(*) 
               INTO v_usable_cnt
        FROM   GIFTCARD 
        WHERE  CARD_STAT = 'G0101';
        
        IF v_usable_cnt <= 0 THEN
          RAISE NOT_EXIST_USE_CARD;
        END IF;

        BEGIN
            -- 잔여카드 카드번호구하기(최소번호카드)
            SELECT A.CARD_ID
                  ,B.PIN_NO
                  INTO v_giftcard_id, v_pin_no
            FROM  (
                    SELECT MIN(CARD_ID) AS CARD_ID
                    FROM   GIFTCARD 
                    WHERE  CARD_STAT = 'G0101'
                  ) A
            JOIN GIFTCARD B
            ON   A.CARD_ID = B.CARD_ID;

            -- 카드 사용처리
            UPDATE GIFTCARD
            SET    CARD_STAT = 'G0102'
            WHERE  CARD_ID = v_giftcard_id
            AND    PIN_NO = v_pin_no;

           SELECT GIFTCARD_HIS_SEQ.NEXTVAL
           INTO v_giftcard_his_seq
           FROM DUAL;

           -- 모바일전자상품권 기록 히스토리 적용
           INSERT INTO GIFTCARD_HIS
           (       
                  GIFTCARD_HIS_SEQ
                 ,GIFTCARD_ID
                 ,PIN_NO
                 ,CARD_ID
                 ,CUST_ID
                 ,CUST_NM
                 ,MOBILE
                 ,AMOUNT
                 ,CREDIT_PAYMENT
                 ,MOBILE_PAYMENT
                 ,USE_PT
                 ,TO_CUST_ID
                 ,TO_CUST_NM
                 ,RECEPTION_MOBILE
                 ,BUY_DT
                 ,CARD_STAT
                 ,CANCEL_DT
                 ,SEND_DT
                 ,SEND_COUNT
                 ,IS_RECHARGE
                 ,SEND_MSG
                 ,SEND_IMG
                 ,PAYMENT_REQ
                 ,INST_USER
                 ,INST_DT
            ) VALUES (   
                 v_giftcard_his_seq
                 ,ENCRYPT(v_giftcard_id)
                 ,v_pin_no
                 ,(
                    SELECT CARD_ID 
                    FROM   C_CARD
                    WHERE  CUST_ID = P_CUST_ID
                    AND    USE_YN = 'Y'
                    AND    REP_CARD_YN = 'Y'
                 )
                 ,P_CUST_ID
                 ,(
                    SELECT CUST_NM
                    FROM   C_CUST
                    WHERE  CUST_ID = P_CUST_ID
                    AND    USE_YN = 'Y'
                 )
                 ,(
                    SELECT MOBILE 
                    FROM   C_CUST
                    WHERE  CUST_ID = P_CUST_ID
                    AND    USE_YN = 'Y'
                 )
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,'G0102'
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,NULL
                 ,P_USER_ID
                 ,SYSDATE
            );
            
           EXCEPTION
               WHEN OTHERS THEN 
               ROLLBACK;
               v_result_cd := '702'; -- 모바일카드 등록도중 문제가 발생했습니다. 
        END;    

        O_RTN_CD := v_result_cd;
        O_GIFTCARD_ID := v_giftcard_id;
        O_PIN_NO := v_pin_no;
        O_CUST_ID := P_CUST_ID;
        
EXCEPTION
    WHEN NOT_EXIST_USE_CARD THEN
        O_RTN_CD  := '701'; -- 상품권 잔여카드가 모두 소진되었습니다.
        dbms_output.put_line(SQLERRM);

END API_GIFTCARD_NO_REQ;

/
