--------------------------------------------------------
--  DDL for Procedure API_PRMT_COUPON_APPROVE_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_COUPON_APPROVE_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰 승인/취소 
-- Test			:	exec API_PRMT_COUPON_APPROVE_SAVE '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_COUPON_CD     IN   VARCHAR2,
        N_CUST_ID       IN   VARCHAR2,
        P_STOR_CD       IN   VARCHAR2,
        P_USE_DIV       IN   VARCHAR2,
        P_POS_NO        IN   VARCHAR2, 
        P_BILL_NO       IN   VARCHAR2,
        P_POS_SEQ       IN   VARCHAR2, 
        P_ITEM_CD       IN   VARCHAR2,
        P_POS_SALE_DT   IN   VARCHAR2, 
        P_USER_ID       IN   VARCHAR2, 
        O_RTN_CD        OUT  VARCHAR2,
        O_PRMT_ID       OUT  VARCHAR2  
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
        v_check_cd  VARCHAR2(7);
        v_prmt_id   VARCHAR2(5);
        v_coupon_his_seq NUMBER; -- 쿠폰 히스토리시퀀스
        NOT_FOUND_COUPON  EXCEPTION;
        v_check_cnt  NUMBER;
        
        v_publish_type  VARCHAR2(10);  -- 발행타입구분
        v_hollys_con_his_seq VARCHAR2(11); -- 할리스콘쿠폰히스토리시퀀스
        
BEGIN  
        
        -- 해당쿠폰의 정보를 조회
        SELECT COUNT(1)
        INTO  v_check_cnt
        FROM  PROMOTION_COUPON A, PROMOTION_COUPON_PUBLISH B 
        WHERE A.PUBLISH_ID = B.PUBLISH_ID
        AND   A.COUPON_CD = P_COUPON_CD 
        AND   EXISTS (SELECT 1 FROM PROMOTION WHERE PRMT_ID = B.PRMT_ID AND COMP_CD = P_COMP_CD AND BRAND_CD = P_BRAND_CD);
        
        -- 조회된 쿠폰이 없으면 오류 RETURN
        IF v_check_cnt < 1 THEN
          RAISE NOT_FOUND_COUPON;
        END IF;
        
        SELECT B.PUBLISH_TYPE
        INTO  v_publish_type
        FROM  PROMOTION_COUPON A, PROMOTION_COUPON_PUBLISH B 
        WHERE A.PUBLISH_ID = B.PUBLISH_ID
        AND   A.COUPON_CD = P_COUPON_CD;

        IF P_USE_DIV = '101' THEN -- 사용일때

           SELECT
                    CASE WHEN A.USE_DT IS NOT NULL THEN '501' -- 이미 사용된 쿠폰입니다.
                         WHEN A.DESTROY_DT IS NOT NULL THEN '502' -- 사용 종료된 쿠폰입니다.
                         WHEN A.START_DT > TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD') THEN '503' -- 쿠폰 사용기간이 아닙니다.
                         WHEN A.TG_STOR_CD IS NOT NULL AND A.TG_STOR_CD <> P_STOR_CD THEN '516' -- 본 쿠폰은 발급받은 매장에서만 사용가능합니다. 쿠폰의 발행매장을 확인해주세요.
                         ELSE '1'
                    END
                    , B.PRMT_ID 
                    INTO v_check_cd, v_prmt_id
            FROM    PROMOTION_COUPON A 
            JOIN    PROMOTION_COUPON_PUBLISH B
            ON      A.PUBLISH_ID = B.PUBLISH_ID 
            JOIN    PROMOTION C 
            ON      C.COMP_CD = P_COMP_CD
            AND     C.BRAND_CD = P_BRAND_CD
            AND     C.PRMT_ID = B.PRMT_ID
            WHERE   A.COUPON_CD = P_COUPON_CD; 

            IF v_check_cd <> '1' THEN
               v_result_cd := v_check_cd;
            END IF;

            O_RTN_CD := v_result_cd;

            IF O_RTN_CD = '1' THEN
            
               BEGIN
                    UPDATE  PROMOTION_COUPON  
                    SET  STOR_CD       = P_STOR_CD
                         ,POS_NO        = P_POS_NO
                         ,BILL_NO       = P_BILL_NO
                         ,POS_SEQ       = P_POS_SEQ
                         ,POS_SALE_DT   = P_POS_SALE_DT
                         ,COUPON_STATE  = 'P0301'
                         ,USE_DT        = TO_CHAR(SYSDATE, 'YYYYMMDD')
                         ,UPD_USER      = P_USER_ID
                         ,UPD_DT        = SYSDATE
                     WHERE   COUPON_CD = P_COUPON_CD;

                     O_PRMT_ID := v_prmt_id;
                     
                     EXCEPTION
                        WHEN OTHERS THEN 
                        O_RTN_CD := '517'; -- 쿠폰 승인처리중 문제가 발생하였습니다.
                        dbms_output.put_line(SQLERRM);
               END;
               
               BEGIN
                    -- 쿠폰히스토리 기록
                    SELECT COUPON_HIS_SEQ.NEXTVAL
                    INTO v_coupon_his_seq
                    FROM DUAL;
                   
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
                    SELECT	P_COUPON_CD  
                            ,v_coupon_his_seq
                            ,A.PUBLISH_ID
                            ,'P0301'
                            ,A.START_DT 
                            ,A.END_DT
                            ,A.USE_DT
                            ,A.DESTROY_DT
                            ,NULL
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,NULL
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,A.POS_NO
                            ,A.BILL_NO
                            ,A.POS_SEQ
                            ,A.POS_SALE_DT
                            ,A.STOR_CD
                            ,NULL
                            ,P_ITEM_CD
                            ,NULL
                            ,P_USER_ID
                            ,SYSDATE
                     FROM    PROMOTION_COUPON A 
                     JOIN    PROMOTION_COUPON_PUBLISH B
                     ON      A.PUBLISH_ID = B.PUBLISH_ID 
                     JOIN    PROMOTION C
                     ON      C.COMP_CD = P_COMP_CD
                     AND     C.BRAND_CD = P_BRAND_CD
                     AND     C.PRMT_ID = B.PRMT_ID
                     WHERE   A.COUPON_CD = P_COUPON_CD;
                     
                     --쿠폰이 할리스콘일 경우
                     IF v_publish_type = 'C6503' THEN 
                     
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
                                SELECT	 CARD_ID
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
                                        ,TO_CHAR(SYSDATE, 'YYYYMMDD')
                                        ,DESTROY_DT
                                        ,P_STOR_CD
                                        ,'P0301'
                                        ,EXTENSION_COUNT
                                        ,SEND_COUNT
                                        ,QTY
                                        ,PAYMENT_REQ
                                        ,v_hollys_con_his_seq
                                        ,P_USER_ID
                                        ,SYSDATE
                                FROM   HOLLYS_CON_HIS
                                WHERE  COUPON_CD   = P_COUPON_CD
                         )A 
                         WHERE ROWNUM = 1;
                     END IF;
                    
                     EXCEPTION
                        WHEN OTHERS THEN 
                        O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                        dbms_output.put_line(SQLERRM); 
                END;
               
            END IF;

        ELSE        -- 취소일때
        
            BEGIN
                -- 쿠폰승인 취소처리 (사용일자 : USE_DT 수정)
                UPDATE   PROMOTION_COUPON 
                    SET  STOR_CD        = NULL
                         ,POS_NO        = NULL
                         ,BILL_NO       = NULL
                         ,POS_SEQ       = NULL
                         ,POS_SALE_DT   = NULL
                         ,COUPON_STATE  = 'P0303'
                         ,USE_DT        = NULL
                         ,UPD_USER      = P_USER_ID
                         ,UPD_DT        = SYSDATE
                 WHERE   COUPON_CD  = P_COUPON_CD;
    
                O_RTN_CD := '1';
                
                EXCEPTION
                     WHEN OTHERS THEN 
                     O_RTN_CD := '518'; -- 쿠폰 승인취소 처리중 문제가 발행하였습니다.
                     dbms_output.put_line(SQLERRM);
            END;
            
            BEGIN
                    -- 쿠폰히스토리 기록
                    SELECT COUPON_HIS_SEQ.NEXTVAL
                    INTO v_coupon_his_seq
                    FROM DUAL;
                   
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
                    SELECT	P_COUPON_CD  
                            ,v_coupon_his_seq
                            ,A.PUBLISH_ID
                            ,'P0302'
                            ,A.START_DT 
                            ,A.END_DT
                            ,A.USE_DT
                            ,A.DESTROY_DT
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,NULL
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                                  ELSE NULL
                             END
                            )
                            ,NULL
                            ,A.POS_NO
                            ,A.BILL_NO
                            ,A.POS_SEQ
                            ,A.POS_SALE_DT
                            ,A.STOR_CD
                            ,NULL
                            ,P_ITEM_CD
                            ,NULL
                            ,P_USER_ID
                            ,SYSDATE
                     FROM    PROMOTION_COUPON A 
                     JOIN    PROMOTION_COUPON_PUBLISH B
                     ON      A.PUBLISH_ID = B.PUBLISH_ID 
                     JOIN    PROMOTION C
                     ON      C.COMP_CD = P_COMP_CD
                     AND     C.BRAND_CD = P_BRAND_CD
                     AND     C.PRMT_ID = B.PRMT_ID
                     WHERE   A.COUPON_CD = P_COUPON_CD; 
                     
                     --쿠폰이 할리스콘일 경우
                     IF v_publish_type = 'C6503' THEN 
                     
                         SELECT HOLLYS_CON_HIS_SEQ.NEXTVAL
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
                                SELECT	 CARD_ID
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
                                        ,NULL
                                        ,DESTROY_DT
                                        ,NULL AS STOR_CD
                                        ,'P0307'
                                        ,EXTENSION_COUNT
                                        ,SEND_COUNT 
                                        ,QTY
                                        ,PAYMENT_REQ
                                        ,v_hollys_con_his_seq
                                        ,P_USER_ID
                                        ,SYSDATE
                                FROM   HOLLYS_CON_HIS
                                WHERE  COUPON_CD   = P_COUPON_CD
                         )A 
                         WHERE ROWNUM = 1;
                     END IF;
                    
                     EXCEPTION
                        WHEN OTHERS THEN 
                        O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                        dbms_output.put_line(SQLERRM); 
            END;
            
        END IF;



EXCEPTION
    WHEN NOT_FOUND_COUPON THEN
        O_RTN_CD  := '500'; -- 쿠폰정보가 없습니다
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패

END API_PRMT_COUPON_APPROVE_SAVE;

/
