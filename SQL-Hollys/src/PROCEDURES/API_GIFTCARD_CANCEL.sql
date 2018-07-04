--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_CANCEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_CANCEL" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	모바일전자상품권 구매취소
-- Test			:	exec API_GIFTCARD_CANCEL '002', '', '', '' 
-- ==========================================================================================
        P_COMP_CD              IN    VARCHAR2,
        P_BRAND_CD             IN    VARCHAR2,
        N_CUST_ID              IN    VARCHAR2, 
        P_GIFTCARD_ID          IN    VARCHAR2,
        P_PIN_NO               IN    VARCHAR2,
        P_PAYMENT_REQ          IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd        VARCHAR2(7) := '1'; -- 성공(전체결과)
        v_result_send_cd   VARCHAR2(7) := '1'; -- 성공(전송)
        v_giftcard_his_seq NUMBER; -- 모바일전자상품권 히스토리 시퀀스
        v_cust_id          VARCHAR2(30);
        v_use_pt           NUMBER;
        v_cust_card_id     VARCHAR2(100);
        
BEGIN

        BEGIN
            -- 카드 취소(C_CARD)
            UPDATE C_CARD
            SET     UPD_DT    = SYSDATE
                   ,UPD_USER  = P_USER_ID            
            WHERE  CARD_ID = ENCRYPT(P_GIFTCARD_ID)
            AND    PIN_NO = P_PIN_NO            
            AND    COMP_CD = P_COMP_CD
            AND    REP_CARD_YN = 'N';
            --AND    BRAND_CD = P_BRAND_CD

            SELECT GIFTCARD_HIS_SEQ.NEXTVAL
            INTO v_giftcard_his_seq
            FROM DUAL;

            -- Giftcard 테이블 기록
            INSERT INTO GIFTCARD_HIS
            (       GIFTCARD_HIS_SEQ
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
           ) 
           SELECT   v_giftcard_his_seq
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
                    ,'G0103'
                    ,TO_CHAR(SYSDATE,'YYYYMMDD')
                    ,SEND_DT
                    ,SEND_COUNT
                    ,IS_RECHARGE
                    ,SEND_MSG
                    ,SEND_IMG
                    ,P_PAYMENT_REQ
                    ,P_USER_ID
                    ,SYSDATE
           FROM     GIFTCARD_HIS
           WHERE    PAYMENT_REQ = P_PAYMENT_REQ
           AND      GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID)
           AND      PIN_NO = P_PIN_NO
           AND      (TRIM(N_CUST_ID) IS NULL OR CUST_ID = N_CUST_ID);
           
           SELECT   USE_PT
                    ,CUST_ID
                    ,CARD_ID
           INTO     v_use_pt
                    ,v_cust_id
                    ,v_cust_card_id
           FROM     GIFTCARD_HIS
           WHERE    PAYMENT_REQ = P_PAYMENT_REQ
           AND      GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID)
           AND      PIN_NO = P_PIN_NO
           AND      (TRIM(N_CUST_ID) IS NULL OR CUST_ID = N_CUST_ID)
           AND      ROWNUM = 1
           ORDER BY GIFTCARD_HIS_SEQ DESC;
           
           --사용포인트가 있을 경우만
            IF v_use_pt > 0 THEN
                
                -- 포인트사용
                INSERT INTO C_CARD_SAV_HIS (
                   COMP_CD
                   ,CARD_ID
                   ,USE_DT
                   ,USE_SEQ
                   ,SAV_USE_FG
                   ,SAV_USE_DIV
                   ,REMARKS
                   ,USE_PT
                   ,BRAND_CD
                   ,STOR_CD
                   ,LOS_PT_DT
                   ,POS_NO
                   ,BILL_NO
                   ,INST_DT
                   ,INST_USER
               ) VALUES (
                   P_COMP_CD
                   ,v_cust_card_id
                   ,TO_CHAR(SYSDATE,'YYYYMMDD')
                   ,SQ_PCRM_SEQ.NEXTVAL
                   ,'4'
                   ,'302'
                   ,'포인트 취소'
                   ,NVL(v_use_pt, 0)
                   ,P_BRAND_CD
                   ,NULL
                   ,TO_CHAR(ADD_MONTHS(SYSDATE-1, 12), 'YYYYMMDD')
                   ,NULL
                   ,NULL
                   ,SYSDATE
                   ,P_USER_ID
                );
                 
                -- 포인트사용이력에 사용포인트 정보 추가
                C_CUST_POINT_USE_HIS_PROC(v_cust_id, '302', v_use_pt);
                
           END IF;

           EXCEPTION
               WHEN OTHERS THEN 
               ROLLBACK;
               v_result_cd := '702'; -- 모바일카드 등록도중 문제가 발생했습니다.
        END;

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패

END API_GIFTCARD_CANCEL;

/
