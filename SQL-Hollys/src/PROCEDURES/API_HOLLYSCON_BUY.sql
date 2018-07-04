--------------------------------------------------------
--  DDL for Procedure API_HOLLYSCON_BUY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_HOLLYSCON_BUY" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	할리스콘 구매
-- Test			:	exec API_HOLLYSCON_BUY '002', '', '', '' 
-- ==========================================================================================
        P_COMP_CD              IN    VARCHAR2,
        P_BRAND_CD             IN    VARCHAR2, 
        P_CUST_ID              IN    VARCHAR2, 
        P_CUST_NM              IN    VARCHAR2,
        P_MOBILE               IN    VARCHAR2,
        P_TO_CUST_NM           IN    VARCHAR2,
        P_RECEPTION_MOBILE     IN    VARCHAR2, 
        N_PT_PAYMENT           IN    VARCHAR2,  
        N_CREDIT_PAYMENT       IN    VARCHAR2, N_MOBILE_PAYMENT       IN    VARCHAR2, 
        N_ETC_PAYMENT          IN    VARCHAR2,  
        P_PRMT_ITEM_CD         IN    VARCHAR2, 
        P_PAYMENT_REQ          IN    VARCHAR2, 
        P_USER_ID              IN    VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2,
        O_START_DT             OUT   VARCHAR2, 
        O_END_DT               OUT   VARCHAR2,
        O_COUPON_CD            OUT   VARCHAR2,
        O_PUBLISH_ID           OUT   VARCHAR2
) AS 
        v_result_cd VARCHAR2(7) := '1';
        
        v_prmt_id VARCHAR2(5); -- 프로모션코드
        v_item_cd VARCHAR2(20); -- 상품코드
        v_publish_id VARCHAR2(10); -- 쿠폰발행번호
        v_random_cd VARCHAR2(20); -- 임시쿠폰난수(연번제외)
        v_temp_coupon_cd VARCHAR2(20); -- 임시쿠폰번호(연번제외)
        v_coupon_cd VARCHAR2(20); -- 쿠폰번호
        v_coupon_dt_type VARCHAR2(1); -- 쿠폰날짜 타입
        v_coupon_expire VARCHAR2(4); -- 발행일로부터 쿠폰사용기간
        v_prmt_dt_start VARCHAR2(8); -- 프로모션시작일자
        v_prmt_dt_end VARCHAR2(8); -- 프로모션종료일자
        v_coupon_start_dt VARCHAR2(8); -- 쿠폰유효기간시작일자
        v_coupon_end_dt VARCHAR2(8); -- 쿠폰유효기간종료일자
        v_sale_prc VARCHAR2(11); -- 상품가격
        v_cust_card_id VARCHAR2(100);
        
        NOT_PRICE_EQUAL EXCEPTION;
        NOT_USABLE_PRMT_DT EXCEPTION;
        
BEGIN
        -- 프모모션 아이디 및 아이템 아이디 분할
        SELECT REGEXP_SUBSTR(P_PRMT_ITEM_CD, '[^_]+', 1, 1), 
               REGEXP_SUBSTR(P_PRMT_ITEM_CD, '[^_]+', 1, 2)
        INTO   v_prmt_id, v_item_cd
        FROM  DUAL;
        
        
        -- 상품가격 확인
        SELECT SALE_PRC
               INTO v_sale_prc
        FROM   ITEM
        WHERE  ITEM_CD = v_item_cd
        AND    COMP_CD = P_COMP_CD;
        --AND    BRAND_CD = P_BRAND_CD;
        
        -- 쿠폰 결제금액 확인
        IF TO_NUMBER(v_sale_prc) <> (TO_NUMBER(N_PT_PAYMENT) + TO_NUMBER(N_CREDIT_PAYMENT) + TO_NUMBER(N_MOBILE_PAYMENT) + TO_NUMBER(N_ETC_PAYMENT)) THEN
            RAISE NOT_PRICE_EQUAL;
        END IF;
        
        SELECT CARD_ID 
        INTO   v_cust_card_id
        FROM   C_CARD
        WHERE  CUST_ID = P_CUST_ID
        AND    USE_YN = 'Y'
        AND    REP_CARD_YN = 'Y';
        
        -- 난수쿠폰번호 생성(임시- prefix('1') + 난수3자리 + 연도2자리 = 6자리)
        v_random_cd := '1' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100)) || TO_CHAR(SYSDATE,'YY');
        
        -- 쿠폰번호 중복 조회
        SELECT MAX(A.COUPON_CD)
               INTO v_temp_coupon_cd
        FROM   PROMOTION_COUPON A
        JOIN   PROMOTION_COUPON_PUBLISH B
        ON     B.PRMT_ID = v_prmt_id
        WHERE  A.COUPON_CD LIKE v_random_cd || '%';
        
        v_temp_coupon_cd := SUBSTR(v_temp_coupon_cd, 1, 6);
        
        -- 신규발행번호
        SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
               INTO v_publish_id
        FROM   PROMOTION_COUPON_PUBLISH;
        
        v_publish_id := LPAD(v_publish_id, 6, '0');
        
        -- 생성한 난수가 이미 있을 경우 
        IF v_temp_coupon_cd IS NOT NULL THEN
           v_coupon_cd := TO_NUMBER(v_temp_coupon_cd) || v_publish_id;
        ELSE -- 없을경우
            v_coupon_cd := v_random_cd || v_publish_id;
        END IF;
        
        BEGIN
        
            SELECT COUPON_DT_TYPE
                  ,COUPON_EXPIRE
                  ,PRMT_DT_START
                  ,PRMT_DT_END
           INTO   v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end
           FROM   PROMOTION
           WHERE  PRMT_ID = v_prmt_id;
           
           IF v_coupon_dt_type = '1' THEN
                IF v_prmt_dt_start <= TO_CHAR(SYSDATE,'YYYYMMDD') AND v_prmt_dt_end >= TO_CHAR(SYSDATE,'YYYYMMDD') THEN
                    v_coupon_start_dt := TO_CHAR(SYSDATE,'YYYYMMDD');
                    v_coupon_end_dt := TO_CHAR(SYSDATE + TO_NUMBER(v_coupon_expire),'YYYYMMDD');
                ELSE    
                    RAISE NOT_USABLE_PRMT_DT;
                END IF;
           ELSE
                v_coupon_start_dt := v_prmt_dt_start;
                v_coupon_end_dt := v_prmt_dt_end;
           END IF;
            
            -- 쿠폰 발행정보 생성
            INSERT INTO PROMOTION_COUPON_PUBLISH
            (       
                    PUBLISH_ID
                    ,PRMT_ID
                    ,PUBLISH_TYPE
                    ,OWN_YN
                    ,PUBLISH_COUNT
                    ,NOTES
                    ,INST_USER
                    ,INST_DT
                    ,UPD_USER
                    ,UPD_DT
           ) VALUES (
                    v_publish_id
                    ,v_prmt_id
                    ,'C6503'
                    ,(
                        CASE WHEN P_MOBILE = P_RECEPTION_MOBILE THEN 'Y'
                             ELSE 'N'
                        END
                    )
                    ,(
                        CASE WHEN P_MOBILE = P_RECEPTION_MOBILE THEN 0
                             ELSE 1
                        END
                    )
                    ,'할리스콘'                    
                    ,P_USER_ID
                    ,SYSDATE
                    ,P_USER_ID
                    ,SYSDATE
           );
           
           -- 쿠폰 발행
           INSERT INTO PROMOTION_COUPON
            (       
                    COUPON_CD
                    ,PUBLISH_ID
                    ,COUPON_SEQ
                    ,CUST_ID
                    ,CARD_ID
                    ,TG_STOR_CD
                    ,STOR_CD
                    ,POS_NO
                    ,BILL_NO
                    ,POS_SEQ
                    ,POS_SALE_DT 
                    ,COUPON_STATE
                    ,COUPON_IMG
                    ,START_DT
                    ,END_DT
                    ,USE_DT
                    ,DESTROY_DT
                    ,INST_USER
                    ,INST_DT
                    ,UPD_USER
                    ,UPD_DT
           ) VALUES (
                    v_coupon_cd
                    ,v_publish_id
                    ,COUPON_SEQ.NEXTVAL
                    ,(
                        CASE WHEN P_MOBILE = P_RECEPTION_MOBILE THEN P_CUST_ID
                             ELSE NULL
                        END
                    )
                    ,v_cust_card_id
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,NULL
                    ,'P0303'
                    ,P_PRMT_ITEM_CD
                    ,v_coupon_start_dt
                    ,v_coupon_end_dt
                    ,NULL
                    ,NULL
                    ,P_USER_ID
                    ,SYSDATE
                    ,P_USER_ID
                    ,SYSDATE
           );
        
           
           -- 쿠폰 발행 기록 히스토리 적용
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
           SELECT	v_coupon_cd  
                   ,COUPON_HIS_SEQ.NEXTVAL
                   ,v_publish_id
                   ,(
                        CASE WHEN P_MOBILE <> P_RECEPTION_MOBILE THEN 'P0305'
                             ELSE 'P0303'
                        END
                    )
                   ,A.START_DT
                   ,A.END_DT
                   ,NULL
                   ,NULL
                   ,NULL
                   ,P_CUST_ID
                   ,(
                        CASE WHEN P_MOBILE <> P_RECEPTION_MOBILE THEN P_CUST_ID
                             ELSE NULL
                        END
                    )
                   ,NULL
                   ,ENCRYPT(P_MOBILE)
                   ,ENCRYPT(P_RECEPTION_MOBILE)
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,NULL
                   ,v_item_cd
                   ,P_PRMT_ITEM_CD
                   ,P_USER_ID
                   ,SYSDATE
            FROM	PROMOTION_COUPON A
            JOIN    PROMOTION_COUPON_PUBLISH B
            ON      A.PUBLISH_ID = B.PUBLISH_ID
            AND     B.PRMT_ID = v_prmt_id
            WHERE	A.COUPON_CD = v_coupon_cd;
            
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
           ) VALUES (   
                    v_cust_card_id
                    ,P_CUST_ID
                    ,ENCRYPT(P_CUST_NM)
                    ,ENCRYPT(P_MOBILE)
                    ,(CASE WHEN P_MOBILE = P_RECEPTION_MOBILE THEN P_CUST_ID
                           ELSE NULL
                      END) 
                    ,ENCRYPT(P_TO_CUST_NM)
                    ,ENCRYPT(P_RECEPTION_MOBILE)
                    ,v_item_cd
                    ,v_coupon_cd
                    ,(
                        SELECT PRMT_NM
                        FROM   PROMOTION
                        WHERE  PRMT_ID = v_prmt_id
                     )
                    ,(TO_NUMBER(N_PT_PAYMENT) + TO_NUMBER(N_CREDIT_PAYMENT) + TO_NUMBER(N_MOBILE_PAYMENT) + TO_NUMBER(N_ETC_PAYMENT))
                    ,N_PT_PAYMENT
                    ,N_CREDIT_PAYMENT
                    ,N_MOBILE_PAYMENT
                    ,N_ETC_PAYMENT
                    ,v_coupon_start_dt
                    ,v_coupon_end_dt
                    ,TO_CHAR(SYSDATE,'YYYYMMDD')
                    ,NULL
                    ,NULL
                    ,NULL 
                    ,(CASE WHEN P_RECEPTION_MOBILE = P_MOBILE THEN 'P0303'
                           ELSE 'P0305'
                      END)
                    ,NULL
                    ,1
                    ,'1'
                    ,P_PAYMENT_REQ
                    ,HOLLYS_CON_HIS_SEQ.NEXTVAL
                    ,P_USER_ID
                    ,SYSDATE
           );
           
         
       
       --사용포인트가 있을 경우만
       IF N_PT_PAYMENT > 0 THEN
            
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
              ,NVL(N_PT_PAYMENT, 0)
              ,P_BRAND_CD
              ,NULL
              ,TO_CHAR(ADD_MONTHS(SYSDATE-1, 12), 'YYYYMMDD')
              ,NULL
              ,NULL
              ,SYSDATE
              ,P_USER_ID
           );
             
           -- 포인트사용이력에 사용포인트 정보 추가
           C_CUST_POINT_USE_HIS_PROC(P_CUST_ID, '301', N_PT_PAYMENT);
            
       END IF;
       
       O_RTN_CD := v_result_cd;
       O_START_DT := v_coupon_start_dt;
       O_END_DT := v_coupon_end_dt;
       O_COUPON_CD := v_coupon_cd;
       O_PUBLISH_ID := v_publish_id;
       dbms_output.put_line(SQLERRM);
       
          
           EXCEPTION
                WHEN OTHERS THEN 
                O_RTN_CD := '504';
                dbms_output.put_line(SQLERRM);
                ROLLBACK;
   END;
     
       
EXCEPTION

    WHEN NOT_PRICE_EQUAL THEN
            O_RTN_CD  := '508'; --쿠폰 결제금액이 상이합니다.
            dbms_output.put_line(SQLERRM);
            
    WHEN NOT_USABLE_PRMT_DT THEN
            O_RTN_CD  := '513'; --프로모션 기간이 지났습니다.
            dbms_output.put_line(SQLERRM);
            
    WHEN OTHERS THEN
            O_RTN_CD  := '2'; --실패
            dbms_output.put_line(SQLERRM);
            
        
END API_HOLLYSCON_BUY;

/
