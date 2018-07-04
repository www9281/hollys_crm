--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_BUY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_BUY" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	모바일전자상품권 구매
-- Test			:	exec API_GIFTCARD_BUY '002', '', '', '' 
-- ==========================================================================================
        P_COMP_CD              IN    VARCHAR2,
        P_BRAND_CD             IN    VARCHAR2,
        P_CUST_ID              IN    VARCHAR2,
        P_GIFTCARD_ID          IN    VARCHAR2,
        P_PIN_NO               IN    VARCHAR2,
        P_CUST_NM              IN    VARCHAR2, 
        P_MOBILE               IN    VARCHAR2,
        P_AMOUNT               IN    VARCHAR2,
        N_CREDIT_PAYMENT       IN    VARCHAR2,
        N_MOBILE_PAYMENT       IN    VARCHAR2,
        N_USE_PT               IN    VARCHAR2,
        P_TO_CUST_NM           IN    VARCHAR2,
        P_RECEPTION_MOBILE     IN    VARCHAR2,
        N_SEND_MSG             IN    VARCHAR2, 
        P_SEND_IMG             IN    VARCHAR2,
        P_IS_RECHARGE          IN    VARCHAR2,
        P_PAYMENT_REQ          IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        O_IS_RECHARGE          OUT   VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        
        v_result_cd        VARCHAR2(7) := '1'; -- 성공(전체결과)
        v_card_cnt         VARCHAR2(1); -- 모바일카드 확인
        v_cust_card_id     VARCHAR2(100);
        v_giftcard_his_seq NUMBER;        
        
        EXIST_GIFTCARD EXCEPTION;
        NOT_PRICE_EQUAL EXCEPTION;

BEGIN   
        BEGIN
        
            SELECT CARD_ID 
            INTO   v_cust_card_id
            FROM   C_CARD
            WHERE  CUST_ID = P_CUST_ID
            AND    USE_YN = 'Y'
            AND    REP_CARD_YN = 'Y';
            
            --신규일경우
            IF P_IS_RECHARGE = '0' THEN
                -- 모바일카드 중복확인
                SELECT   COUNT(*)
                         INTO v_card_cnt
                FROM     C_CARD
                WHERE    CARD_ID = ENCRYPT(P_GIFTCARD_ID)
                AND      P_PIN_NO = P_PIN_NO; 
                
                IF v_card_cnt > 0 THEN
                  RAISE EXIST_GIFTCARD;
                END IF;
                
                -- 결제금액 확인
                IF TO_NUMBER(P_AMOUNT) <> (TO_NUMBER(N_CREDIT_PAYMENT) + TO_NUMBER(N_MOBILE_PAYMENT) + TO_NUMBER(N_USE_PT)) THEN
                    RAISE NOT_PRICE_EQUAL;
                END IF;
                
                -- 카드 등록(C_CARD)
                INSERT INTO C_CARD
                (       COMP_CD
                        ,CARD_ID
                        ,PIN_NO
                        ,CUST_ID
                        ,CARD_STAT
                        ,ISSUE_DIV
                        ,ISSUE_DT
                        --,SAV_CASH
                        ,BRAND_CD 
                        ,REP_CARD_YN
                        ,USE_YN
                        ,INST_DT
                        ,INST_USER
                        ,UPD_DT
                        ,UPD_USER
                        ,CARD_TYPE
                        ,CARD_IMG_NM
               ) VALUES (   
                        P_COMP_CD
                        ,ENCRYPT(P_GIFTCARD_ID)
                        ,P_PIN_NO
                        ,NULL 
                        ,'10'
                        ,P_IS_RECHARGE
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')
                        --,P_AMOUNT
                        ,P_BRAND_CD
                        ,'N'
                        ,'Y'
                        ,SYSDATE
                        ,P_USER_ID
                        ,SYSDATE
                        ,P_USER_ID
                        ,'0'
                        ,P_SEND_IMG
                );
                
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
               ) VALUES (   
                        GIFTCARD_HIS_SEQ.NEXTVAL
                        ,ENCRYPT(P_GIFTCARD_ID)
                        ,P_PIN_NO
                        ,v_cust_card_id
                        ,P_CUST_ID
                        ,ENCRYPT(P_CUST_NM)
                        ,ENCRYPT(P_MOBILE)
                        ,P_AMOUNT
                        ,N_CREDIT_PAYMENT
                        ,N_MOBILE_PAYMENT
                        ,N_USE_PT
                        ,NULL
                        ,ENCRYPT(P_TO_CUST_NM)
                        ,ENCRYPT(P_RECEPTION_MOBILE)
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')
                        ,'G0102'
                        ,NULL
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')
                        ,'1'  --SEND_COUNT -> SMS 모듈 적용후 확인
                        ,P_IS_RECHARGE
                        ,N_SEND_MSG
                        ,P_SEND_IMG
                        ,P_PAYMENT_REQ
                        ,P_USER_ID
                        ,SYSDATE
               );
            
            -- 재충전일경우    
            ELSE
            
                SELECT GIFTCARD_HIS_SEQ.NEXTVAL
                INTO v_giftcard_his_seq
                FROM DUAL;
                
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
               ) VALUES (
                        v_giftcard_his_seq
                        ,ENCRYPT(P_GIFTCARD_ID)
                        ,P_PIN_NO
                        ,v_cust_card_id
                        ,P_CUST_ID
                        ,ENCRYPT(P_CUST_NM)
                        ,ENCRYPT(P_MOBILE)
                        ,P_AMOUNT
                        ,N_CREDIT_PAYMENT
                        ,N_MOBILE_PAYMENT
                        ,N_USE_PT
                        ,NULL
                        ,ENCRYPT(P_TO_CUST_NM)
                        ,ENCRYPT(P_RECEPTION_MOBILE)
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')
                        ,'G0102'
                        ,NULL
                        ,TO_CHAR(SYSDATE,'YYYYMMDD')
                        ,(  
                            SELECT   A.*
                            FROM     (
                                        SELECT   SEND_COUNT
                                        FROM     GIFTCARD_HIS 
                                        WHERE    GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID)
                                        AND      PIN_NO = P_PIN_NO
                                        AND      CUST_ID = P_CUST_ID
                                        ORDER BY GIFTCARD_HIS_SEQ DESC
                            ) A
                            WHERE ROWNUM = 1
                        )
                        ,P_IS_RECHARGE
                        ,N_SEND_MSG
                        ,P_SEND_IMG
                        ,P_PAYMENT_REQ
                        ,P_USER_ID
                        ,SYSDATE
               );
            END IF;
            
            --사용포인트가 있을 경우만
            IF N_USE_PT > 0 THEN
                
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
                   ,'301'
                   ,'포인트 사용'
                   ,NVL(N_USE_PT, 0)
                   ,P_BRAND_CD
                   ,NULL
                   ,TO_CHAR(ADD_MONTHS(SYSDATE-1, 12), 'YYYYMMDD')
                   ,NULL
                   ,NULL
                   ,SYSDATE
                   ,P_USER_ID
                );
                 
                -- 포인트사용이력에 사용포인트 정보 추가
                C_CUST_POINT_USE_HIS_PROC(P_CUST_ID, '301', N_USE_PT);
                
           END IF;
        
        END; 

        O_IS_RECHARGE := P_IS_RECHARGE;
        O_RTN_CD := v_result_cd;
        dbms_output.put_line(SQLERRM);

EXCEPTION

    WHEN NOT_PRICE_EQUAL THEN
        O_RTN_CD  := '508'; --결제금액이 상이합니다.
        dbms_output.put_line(SQLERRM);

    WHEN EXIST_GIFTCARD THEN
        O_RTN_CD  := '130'; -- 이미 등록된 카드입니다.
        dbms_output.put_line(SQLERRM);

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END API_GIFTCARD_BUY;

/
