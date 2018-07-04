--------------------------------------------------------
--  DDL for Procedure API_PRMT_FRQ_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_FRQ_SAVE" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-10-31
-- Description    :    프리퀀시 적립/취소 
-- Test            :    exec API_PRMT_FRQ_SAVE '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD           IN   VARCHAR2,
        P_BRAND_CD          IN   VARCHAR2,
        P_USER_ID           IN   VARCHAR2, 
        P_PRMT_ID           IN   VARCHAR2,
        P_STOR_CD           IN   VARCHAR2,
        P_ITEM_CD           IN   VARCHAR2,
        P_ITEM_DIV          IN   VARCHAR2, 
        P_CUST_ID           IN   VARCHAR2,
        P_QTY               IN   VARCHAR2,
        P_FRQ_DIV           IN   VARCHAR2,
        N_CRE_FRQ_SEQ       IN   VARCHAR2,
        N_FRQ_SEQ           IN   VARCHAR2,
        P_POS_NO            IN   VARCHAR2,  
        P_BILL_NO           IN   VARCHAR2,
        P_POS_SEQ           IN   VARCHAR2,
        P_POS_SALE_DT       IN   VARCHAR2, 
        O_RTN_CD            OUT  VARCHAR2,
        O_FRQ_SEQ           OUT  VARCHAR2  
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
        v_frq_his_seq VARCHAR2(11); -- 프리퀀시 히스토리 시퀀스
        v_org_qty VARCHAR2(4); -- 원본 적립 개수
        v_req_qty VARCHAR2(4); -- 필수잔수적립 개수
        v_nor_qty VARCHAR2(4); -- 일반잔수적립 개수
        v_req_standard VARCHAR2(4); -- 필수잔수적립 기준
        v_nor_standard VARCHAR2(4); -- 일반잔수적립 기준
        L_TYPE NUMBER;
        L_COUNT NUMBER;
        v_coupon_cnt NUMBER;
        
        v_sub_prmt_id VARCHAR2(5); -- 서브프로모션 아이디
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
        v_prmt_nm       VARCHAR2(255); -- 
        
        NOT_USABLE_PRMT_DT EXCEPTION;
        
        v_count NUMBER; -- 프로모션 유무확인
        NOT_EXISTS_PROMOTION EXCEPTION; -- 프로모션 정보가 없습니다.
BEGIN  

        SELECT COUNT(*)
               INTO v_count
        FROM   PROMOTION
        WHERE  PRMT_ID = P_PRMT_ID;
        
        IF v_count < 1 THEN
            RAISE NOT_EXISTS_PROMOTION; -- 프로모션 정보가 없습니다.
        END IF;
            
        IF P_FRQ_DIV = '101' THEN -- 적립일때
            
            --FOR I IN 1..TO_NUMBER(P_QTY)
               -- LOOP
                    SELECT FRQ_HIS_SEQ.NEXTVAL
                    INTO v_frq_his_seq
                    FROM DUAL;
                
                    INSERT INTO PROMOTION_FREQUENCY
                    (       FRQ_SEQ
                            ,FRQ_HIS_SEQ
                            ,PRMT_ID
                            ,STOR_CD
                            ,ITEM_CD
                            ,ITEM_DIV
                            ,QTY
                            ,CUST_ID
                            ,PUBLISH_YN
                            ,LOCK_YN
                            ,FRQ_DIV
                            ,POS_NO
                            ,BILL_NO
                            ,POS_SEQ
                            ,POS_SALE_DT
                            ,NOTES
                            ,INST_USER
                            ,INST_DT
                    ) VALUES (   
                            N_CRE_FRQ_SEQ
                            ,v_frq_his_seq
                            ,P_PRMT_ID
                            ,P_STOR_CD
                            ,P_ITEM_CD
                            ,P_ITEM_DIV
                            ,'1'
                            ,P_CUST_ID
                            ,'N'
                            ,'N' 
                            ,P_FRQ_DIV
                            ,P_POS_NO
                            ,P_BILL_NO
                            ,P_POS_SEQ
                            ,P_POS_SALE_DT
                            ,NULL
                            ,P_USER_ID
                            ,SYSDATE
                    );
           -- END LOOP;
            
            O_FRQ_SEQ := N_CRE_FRQ_SEQ;

        ELSE  --취소일경우
        
            SELECT SUM(QTY)
                   INTO v_org_qty
            FROM   PROMOTION_FREQUENCY
            WHERE  FRQ_SEQ     = N_FRQ_SEQ
            AND    FRQ_DIV     = '101'
            AND    PRMT_ID     = P_PRMT_ID         
            AND    STOR_CD     = P_STOR_CD 
            AND    ITEM_CD     = P_ITEM_CD     
            AND    ITEM_DIV    = P_ITEM_DIV  
            AND    CUST_ID     = P_CUST_ID  
            AND    POS_NO      = P_POS_NO     
            AND    BILL_NO     = P_BILL_NO     
            AND    POS_SEQ     = P_POS_SEQ       
            AND    POS_SALE_DT = P_POS_SALE_DT;
            
           -- FOR I IN 1..TO_NUMBER(v_org_qty)
            --LOOP
            
                SELECT FRQ_HIS_SEQ.NEXTVAL
                INTO v_frq_his_seq
                FROM DUAL;
                
                INSERT INTO PROMOTION_FREQUENCY
                (       FRQ_SEQ
                        ,FRQ_HIS_SEQ
                        ,PRMT_ID
                        ,STOR_CD
                        ,ITEM_CD
                        ,ITEM_DIV
                        ,QTY
                        ,CUST_ID
                        ,PUBLISH_YN
                        ,LOCK_YN
                        ,FRQ_DIV
                        ,POS_NO
                        ,BILL_NO
                        ,POS_SEQ
                        ,POS_SALE_DT
                        ,NOTES
                        ,INST_USER
                        ,INST_DT
                ) VALUES (   
                        N_FRQ_SEQ
                        ,v_frq_his_seq
                        ,P_PRMT_ID
                        ,P_STOR_CD
                        ,P_ITEM_CD
                        ,P_ITEM_DIV
                        ,'1'
                        ,P_CUST_ID
                        ,'N'
                        ,'N'
                        ,P_FRQ_DIV
                        ,P_POS_NO
                        ,P_BILL_NO
                        ,P_POS_SEQ
                        ,P_POS_SALE_DT
                        ,NULL
                        ,P_USER_ID
                        ,SYSDATE
                );
                
            --END LOOP;
            
            --일자 : 20180629
            --작업자 : 손영재 대리
            --내용 : 발행된 쿠폰을 취소 하는 부분 추가
             
            
            SELECT  COUNT(COUPON_CD) , MAX(COUPON_CD) INTO v_coupon_cnt, v_coupon_cd
            FROM PROMOTION_COUPON A , PROMOTION_COUPON_PUBLISH  B, PROMOTION C
            WHERE A.PUBLISH_ID = B.PUBLISH_ID
            AND B.PRMT_ID = C.PRMT_ID
            AND A.CUST_ID = P_CUST_ID
            AND C.PRMT_TYPE = 'C6017'
            AND B.PRMT_ID = P_PRMT_ID
            AND B.PUBLISH_TYPE = 'C6501'
            AND A.COUPON_STATE = 'P0303';
            
            IF v_coupon_cnt > 0 THEN  --미사용 프리퀸시 쿠폰이 존재하는지 체크
            
                -- 현재 필수, 일반 잔수 적립 조회
                v_req_qty := '0'; 
                v_nor_qty := '0';
                v_coupon_cnt := '0';
                v_coupon_cd := '';
                
                SELECT  COUNT(COUPON_CD) INTO v_coupon_cnt
                FROM PROMOTION_COUPON A , PROMOTION_COUPON_PUBLISH  B, PROMOTION C
                WHERE A.PUBLISH_ID = B.PUBLISH_ID
                AND B.PRMT_ID = C.PRMT_ID
                AND A.CUST_ID = P_CUST_ID
                AND C.PRMT_TYPE = 'C6017'
                AND B.PRMT_ID = P_PRMT_ID
                AND B.PUBLISH_TYPE = 'C6501';

                
                SELECT  COUNT(*)
                        ,MAX(C.CONDITION_QTY_REQ)
                        ,MAX(C.CONDITION_QTY_NOR)
                        INTO 
                        L_COUNT
                       ,v_req_standard
                       ,v_nor_standard    
                FROM    PROMOTION_FREQUENCY A
                JOIN    PROMOTION_TARGET_MN B
                ON      A.PRMT_ID   = B.PRMT_ID
                AND     A.ITEM_DIV  = B.ITEM_DIV
                AND     A.ITEM_CD   = B.ITEM_CD
                JOIN    PROMOTION C
                ON      A.PRMT_ID = C.PRMT_ID 
                WHERE   A.CUST_ID = P_CUST_ID
                --AND     A.PUBLISH_YN = 'Y'
                AND     A.PRMT_ID  =P_PRMT_ID
                AND     C.PRMT_TYPE = 'C6017';
                
                IF      L_COUNT > 0 THEN
                
                        SELECT  SUM(
                                  CASE  WHEN A.ITEM_DIV = 'C6401' AND A.FRQ_DIV = '101' THEN A.QTY
                                        WHEN A.ITEM_DIV = 'C6401' AND A.FRQ_DIV != '101' THEN -A.QTY
                                        ELSE 0
                                  END
                                ) AS REQ_QTY,
                                SUM(
                                  CASE  WHEN A.ITEM_DIV = 'C6402' AND A.FRQ_DIV = '101' THEN A.QTY
                                        WHEN A.ITEM_DIV = 'C6402' AND A.FRQ_DIV != '101' THEN -A.QTY
                                        ELSE 0
                                  END
                                ) AS NOR_QTY
                        INTO    v_req_qty,
                                v_nor_qty
                        FROM    PROMOTION_FREQUENCY A
                        JOIN    PROMOTION_TARGET_MN B
                        ON      A.PRMT_ID   = B.PRMT_ID
                        AND     A.ITEM_DIV  = B.ITEM_DIV
                        AND     A.ITEM_CD   = B.ITEM_CD
                        JOIN    PROMOTION C
                        ON      A.PRMT_ID = C.PRMT_ID 
                        WHERE   A.CUST_ID = P_CUST_ID
                        --AND     A.PUBLISH_YN = 'Y'  --발행에 적용된 건들
                        AND     A.PRMT_ID = P_PRMT_ID
                        AND     C.PRMT_TYPE = 'C6017';
                        
                END     IF;
                --기준 점수 * 쿠폰 수량  > SUM()  THEN 쿠폰반품 
                
                IF (v_req_standard * v_coupon_cnt)  > v_req_qty   OR  (v_nor_standard * v_coupon_cnt)  > v_nor_qty THEN
                    
                    -- 쿠폰만 디스트로이 가장 최근의 쿠폰을 작업
                    UPDATE PROMOTION_COUPON
                    SET DESTROY_DT = TO_CHAR(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD')) - 1, 'YYYYMMDD')
                    ,COUPON_STATE = 'P0304'
                    ,UPD_USER   = P_USER_ID
                    ,UPD_DT     = SYSDATE
                    WHERE COUPON_CD = v_coupon_cd
                    AND CUST_ID = P_CUST_ID
                    ;
                    
                    UPDATE PROMOTION_FREQUENCY
                    SET PUBLISH_YN = 'N'
                    WHERE     CUST_ID = P_CUST_ID
                    AND       NOTES = v_coupon_cd
                    ;
                
                END IF;               
                                  
            END IF;
            
            
        END IF;
        
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN NOT_EXISTS_PROMOTION THEN 
        O_RTN_CD := '521'; -- 프로모션 정보가 없습니다.
        dbms_output.put_line(SQLERRM); 

    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
        
END API_PRMT_FRQ_SAVE;

/
