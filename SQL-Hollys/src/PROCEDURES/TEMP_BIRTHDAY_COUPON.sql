--------------------------------------------------------
--  DDL for Procedure TEMP_BIRTHDAY_COUPON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."TEMP_BIRTHDAY_COUPON" 
IS    
    v_prmt_id VARCHAR2(5) := '6'; -- 프로모션 아이디
    v_publish_id VARCHAR2(10); -- 쿠폰발행번호
    v_random_cd VARCHAR2(20); -- 임시쿠폰난수(연번제외)
    v_coupon_start_dt VARCHAR2(8) := '20180319'; -- 쿠폰유효기간시작일자 
    v_coupon_end_dt VARCHAR2(8) := '20180418'; -- 쿠폰유효기간종료일자
    CURSOR_COUPON_COUNT NUMBER;
    CURSOR_CUST_ID  VARCHAR2(30);
    CURSOR_CARD_ID  VARCHAR2(100);

BEGIN
    -- ==========================================================================================
    -- Author        :   권혁민
    -- Create date   :   2018-01-23
    -- Description   :   생일 쿠폰 발행
    --               :   [생일쿠폰 관련]
    --               :   1. 생일 10일전 발행
    --               :   2. 유효기간 발행일 포함 30일
    --               :   3. 회원이 생일 수정 시 생일 쿠폰이 발행된 상태이면 생일 쿠폰 발행이 안되어야 함
    -- ==========================================================================================

    -- 신규발행번호
    SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
           INTO v_publish_id
    FROM   PROMOTION_COUPON_PUBLISH;

    v_publish_id := LPAD(v_publish_id, 6, '0');
    
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
            ,'C6501'
            ,'Y' 
            ,NULL
            ,'생일쿠폰'       
            ,'CRM'
            ,SYSDATE
            ,'CRM'
            ,SYSDATE
   );
    
    DECLARE CURSOR  CURSOR_CUST IS
    SELECT	A.CUST_ID
           ,(
                SELECT ENCRYPT(CARD_ID) 
                FROM   C_CARD
                WHERE  CUST_ID = A.CUST_ID
                AND    USE_YN = 'Y'
                AND    REP_CARD_YN = 'Y'
            )
   FROM   C_CUST A
    WHERE  A.BIRTH_DT <> '99999999'
    AND    LENGTH(A.BIRTH_DT) > 7
    AND    (TO_CHAR(TO_DATE(IS_DATE(
                CASE  WHEN  A.LUNAR_DIV = 'L'
                      THEN  GET_LUNAR_TRANS(TO_CHAR(SYSDATE,'YYYY')||SUBSTR(A.BIRTH_DT,5,8))
                      ELSE  A.BIRTH_DT
                END
          )-10),'MMDD') > TO_CHAR(TO_DATE('20180228','YYYYMMDD'),'MMDD')
    AND   TO_CHAR(TO_DATE(IS_DATE(
                CASE  WHEN  A.LUNAR_DIV = 'L'
                      THEN  GET_LUNAR_TRANS(TO_CHAR(SYSDATE,'YYYY')||SUBSTR(A.BIRTH_DT,5,8))
                      ELSE  A.BIRTH_DT
                END
          )-10),'MMDD') < TO_CHAR(TO_DATE('20180324','YYYYMMDD'),'MMDD'))
    AND    A.LVL_CD = '103'
    AND    NOT EXISTS(
                    SELECT *
                    FROM   PROMOTION_COUPON B
                    JOIN   PROMOTION_COUPON_PUBLISH C
                    ON     B.PUBLISH_ID = C.PUBLISH_ID
                    WHERE  A.CUST_ID = B.CUST_ID
                    AND    C.PRMT_ID = '6'
                    AND    TO_CHAR(B.INST_DT,'YYYY') = TO_CHAR(SYSDATE,'YYYY')
    );
   
   BEGIN    
            OPEN    CURSOR_CUST;
            LOOP
                    FETCH   CURSOR_CUST
                    INTO    CURSOR_CUST_ID,
                            CURSOR_CARD_ID;
                    EXIT    WHEN  CURSOR_CUST%NOTFOUND;
                    
                    v_random_cd := '';
                    
                    LOOP
                        -- 난수쿠폰번호 생성(Prefix(3)+랜덤번호(4자리)+년도(2자리)+월(2자리)+일(2자리)+랜덤번호(3자리)+발행번호(6자리))
                        v_random_cd := '3' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SYSDATE,'MM') || TO_CHAR(SYSDATE,'DD') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100)) || v_publish_id;
                        
                        -- 쿠폰번호 중복 조회 
                        SELECT  COUNT(*)
                        INTO    CURSOR_COUPON_COUNT
                        FROM    PROMOTION_COUPON
                        WHERE   COUPON_CD = v_random_cd;
                        EXIT    WHEN    CURSOR_COUPON_COUNT = 0;
                        
                    END LOOP;
                    
                    INSERT INTO PROMOTION_COUPON
                   (       COUPON_CD                           
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
                            v_random_cd
                           ,v_publish_id
                           ,COUPON_SEQ.NEXTVAL
                           ,CURSOR_CUST_ID
                           ,CURSOR_CARD_ID
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL
                           ,'P0303'
                           ,'P0406_103'
                           ,v_coupon_start_dt
                           ,v_coupon_end_dt
                           ,NULL
                           ,NULL
                           ,'CRM'
                           ,SYSDATE
                           ,'CRM'
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
                    )  VALUES (
                            v_random_cd                           
                            ,COUPON_HIS_SEQ.NEXTVAL
                            ,v_publish_id
                            ,'P0303'
                            ,v_coupon_start_dt
                            ,v_coupon_end_dt
                            ,NULL
                            ,NULL
                            ,NULL
                            ,CURSOR_CUST_ID
                            ,NULL
                            ,NULL
                            ,(
                                SELECT ENCRYPT(MOBILE) 
                                FROM   C_CUST 
                                WHERE  CUST_ID = CURSOR_CUST_ID
                            )
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,NULL
                            ,'P0406_103'
                            ,'CRM'
                            ,SYSDATE
                    );
                    
            END LOOP;
   
   END;
END TEMP_BIRTHDAY_COUPON;

/
