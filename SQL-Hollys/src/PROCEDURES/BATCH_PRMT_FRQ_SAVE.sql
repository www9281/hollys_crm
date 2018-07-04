--------------------------------------------------------
--  DDL for Procedure BATCH_PRMT_FRQ_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_PRMT_FRQ_SAVE" 
IS
        v_result_cd VARCHAR2(7) := '1';    --성공 
        v_frq_his_seq VARCHAR2(11);        -- 프리퀀시 히스토리 시퀀스
        v_org_qty VARCHAR2(4);             -- 원본 적립 개수
        v_req_qty VARCHAR2(4);             -- 필수잔수적립 개수
        v_nor_qty VARCHAR2(4);             -- 일반잔수적립 개수
        v_req_standard VARCHAR2(4);        -- 필수잔수적립 기준
        v_nor_standard VARCHAR2(4);        -- 일반잔수적립 기준
        L_TYPE NUMBER;
        L_COUNT NUMBER;
        
        v_sub_prmt_id VARCHAR2(5);         -- 서브프로모션 아이디
        v_publish_id VARCHAR2(10);         -- 쿠폰발행번호
        v_random_cd VARCHAR2(20);          -- 임시쿠폰난수(연번제외)
        v_temp_coupon_cd VARCHAR2(20);     -- 임시쿠폰번호(연번제외)
        v_coupon_cd VARCHAR2(20);          -- 쿠폰번호
        v_coupon_dt_type VARCHAR2(1);      -- 쿠폰날짜 타입
        v_coupon_expire VARCHAR2(4);       -- 발행일로부터 쿠폰사용기간
        v_prmt_dt_start VARCHAR2(8);       -- 프로모션시작일자
        v_prmt_dt_end VARCHAR2(8);         -- 프로모션종료일자
        v_coupon_start_dt VARCHAR2(8);     -- 쿠폰유효기간시작일자
        v_coupon_end_dt VARCHAR2(8);       -- 쿠폰유효기간종료일자
        v_prmt_nm       VARCHAR2(255);     -- 쿠폰명
        
        NOT_USABLE_PRMT_DT EXCEPTION;
        
        v_count NUMBER; -- 프로모션 유무확인
        NOT_EXISTS_PROMOTION EXCEPTION; -- 프로모션 정보가 없습니다.
BEGIN  

    FOR CUR IN (
        SELECT 
               A.CUST_ID
             , C.PRMT_ID 
        FROM   PROMOTION_FREQUENCY A, PROMOTION C
        WHERE  A.PUBLISH_YN = 'N'
          AND  C.PRMT_TYPE = 'C6017'
          AND  C.USE_YN = 'Y'
          AND  TO_CHAR(SYSDATE,'YYYYMMDD') BETWEEN C.PRMT_DT_START AND C.PRMT_DT_END
          ------AND ROWNUM <= 1
        GROUP  BY  A.CUST_ID  , C.PRMT_ID       
    )
    LOOP

        -- 현재 필수, 일반 잔수 적립 조회
        v_req_qty := '0'; 
        v_nor_qty := '0';
        
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
        WHERE   A.CUST_ID = CUR.CUST_ID
        AND     A.PUBLISH_YN = 'N'
        AND     A.PRMT_ID  =CUR.PRMT_ID
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
                WHERE   A.CUST_ID = CUR.CUST_ID
                AND     A.PUBLISH_YN = 'N'
                AND     A.PRMT_ID = CUR.PRMT_ID
                AND     C.PRMT_TYPE = 'C6017';
                
        END     IF;
   
        
        SELECT  CASE  
                    WHEN  (TO_NUMBER(v_req_qty) >= TO_NUMBER(v_req_standard)) AND (TO_NUMBER(v_nor_qty) >= TO_NUMBER(v_nor_standard))  THEN  1  
                    ELSE  
                          CASE  
                                WHEN  (TO_NUMBER(v_req_qty) >= TO_NUMBER(v_req_standard) + TO_NUMBER(v_nor_standard))   AND   TO_NUMBER(v_nor_qty) = 0            THEN  2  
                                WHEN  (TO_NUMBER(v_req_qty) >= TO_NUMBER(v_req_standard)) AND  (TO_NUMBER(v_req_qty) + (TO_NUMBER(v_nor_qty) ) >= (TO_NUMBER(v_req_standard) + TO_NUMBER(v_nor_standard)))                  THEN  3      
                                ELSE                                                                                                         0
                          END
                END
        INTO    L_TYPE
        FROM    DUAL;
            
        IF  L_TYPE > 0    THEN                                        -- 기준 충족 시
            
            -- 쿠폰 발행
            -- 신규발행번호
            SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
                   INTO v_publish_id
            FROM   PROMOTION_COUPON_PUBLISH;
                
            SELECT SUB_PRMT_ID
                   INTO v_sub_prmt_id
            FROM   PROMOTION
            WHERE  PRMT_ID = CUR.PRMT_ID;
                
            v_publish_id := LPAD(v_publish_id, 6, '0');
                
            SELECT COUPON_DT_TYPE
                  ,COUPON_EXPIRE
                  ,PRMT_DT_START
                  ,PRMT_DT_END
                  ,PRMT_NM
            INTO   v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end, v_prmt_nm
            FROM   PROMOTION
            WHERE  PRMT_ID = v_sub_prmt_id;
               
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
                
            -- 난수쿠폰번호 생성(Prefix(3)+랜덤번호(4자리)+년도(2자리)+월(2자리)+일(2자리)+랜덤번호(3자리)+발행번호(6자리))
            v_random_cd := '3' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SYSDATE,'MM') || TO_CHAR(SYSDATE,'DD') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));
               
            -- 쿠폰번호 중복 조회
            SELECT MAX(A.COUPON_CD)
                   INTO v_temp_coupon_cd
            FROM   PROMOTION_COUPON A
            JOIN   PROMOTION_COUPON_PUBLISH B
            ON     A.PUBLISH_ID = B.PUBLISH_ID
            WHERE  B.PRMT_ID = v_sub_prmt_id
            AND    A.COUPON_CD LIKE '%' || v_random_cd || '%';
                
            v_temp_coupon_cd := SUBSTR(v_temp_coupon_cd, 1, 14);
                
            -- 생성한 난수가 이미 있을 경우 
            IF v_temp_coupon_cd IS NOT NULL THEN
               v_coupon_cd := TO_NUMBER(v_temp_coupon_cd) || v_publish_id;
            ELSE -- 없을경우
                v_coupon_cd := v_random_cd || v_publish_id;
            END IF;
                
            BEGIN
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
                        ,v_sub_prmt_id
                        ,'C6501'
                        ,'Y' 
                        ,NULL
                        ,v_prmt_nm            
                        ,'CRM'
                        ,SYSDATE
                        ,'CRM'
                        ,SYSDATE
               );
                
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
                       v_coupon_cd
                       ,v_publish_id
                       ,COUPON_SEQ.NEXTVAL
                       ,CUR.CUST_ID
                       ,(
                            SELECT ENCRYPT(CARD_ID) 
                            FROM   C_CARD
                            WHERE  CUST_ID = CUR.CUST_ID
                            AND    USE_YN = 'Y'
                            AND    REP_CARD_YN = 'Y'
                        )
                       ,NULL
                       ,NULL
                       ,NULL
                       ,NULL
                       ,NULL
                       ,NULL
                       ,'P0303'
                       ,'P0401'
                       ,v_coupon_start_dt
                       ,v_coupon_end_dt
                       ,NULL
                       ,NULL
                       ,'CRM'
                       ,SYSDATE
                       ,'CRM'
                       ,SYSDATE
               );
                   
               EXCEPTION
                    WHEN OTHERS THEN
                    ROLLBACK;
                    EXIT;
                    dbms_output.put_line(SQLERRM);
                   
           END;
               
           BEGIN
        
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
                SELECT    A.COUPON_CD  
                        ,COUPON_HIS_SEQ.NEXTVAL
                        ,A.PUBLISH_ID
                        ,A.COUPON_STATE
                        ,A.START_DT
                        ,A.END_DT
                        ,A.USE_DT
                        ,A.DESTROY_DT
                        ,NULL
                        ,A.CUST_ID
                        ,NULL
                        ,NULL
                        ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                               ELSE NULL
                          END
                        )
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,NULL
                        ,A.COUPON_IMG
                        ,'CRM'
                        ,SYSDATE
                 FROM    PROMOTION_COUPON A
                 JOIN   PROMOTION_COUPON_PUBLISH B
                 ON     A.PUBLISH_ID = B.PUBLISH_ID
                 WHERE    A.COUPON_CD = v_coupon_cd;
        
                 EXCEPTION
                    WHEN OTHERS THEN
                    ROLLBACK; 
                    EXIT;
                    dbms_output.put_line(SQLERRM); 
            END;
            
            -- 필수 수량 처리
            MERGE -- + USE_HASH(A B)
            INTO PROMOTION_FREQUENCY A
            USING
            (
                    SELECT  Z.FRQ_SEQ,
                            Z.FRQ_HIS_SEQ
                    FROM    (
                                    SELECT  X.FRQ_SEQ,
                                            X.FRQ_HIS_SEQ
                                    FROM    PROMOTION_FREQUENCY X
                                    JOIN    PROMOTION_TARGET_MN Y
                                    ON      X.PRMT_ID = Y.PRMT_ID
                                    AND     X.ITEM_CD = Y.ITEM_CD
                                    WHERE   X.PRMT_ID = CUR.PRMT_ID
                                    AND     X.CUST_ID = CUR.CUST_ID
                                    AND     X.PUBLISH_YN = 'N'
                                    AND     Y.ITEM_DIV = 'C6401'
                                    ORDER   BY
                                            X.FRQ_SEQ,
                                            X.FRQ_HIS_SEQ
                            ) Z
                     WHERE  ROWNUM <= CASE  WHEN  L_TYPE = 1
                                            THEN  TO_NUMBER(v_req_standard)                                  
                                            ELSE  CASE  WHEN  L_TYPE = 2  THEN  TO_NUMBER(v_req_standard) + TO_NUMBER(v_nor_standard) 
                                                        WHEN  L_TYPE = 3  THEN  TO_NUMBER(v_req_standard) + TO_NUMBER(v_nor_standard) - TO_NUMBER(v_nor_qty)  
                                                        ELSE  0
                                                  END
                                      END
            ) B
            ON     (A.FRQ_SEQ = B.FRQ_SEQ AND A.FRQ_HIS_SEQ = B.FRQ_HIS_SEQ)
            WHEN   MATCHED THEN
            UPDATE
            SET     A.PUBLISH_YN = 'Y'
                   ,A.NOTES = v_coupon_cd;
                
            IF  L_TYPE = 1  THEN
                -- 일반 수량 처리
                MERGE -- + USE_HASH(A B)
                INTO PROMOTION_FREQUENCY A
                USING
                (
                        SELECT  Z.FRQ_SEQ,
                                Z.FRQ_HIS_SEQ
                        FROM    (
                                        SELECT  X.FRQ_SEQ,
                                                X.FRQ_HIS_SEQ
                                        FROM    PROMOTION_FREQUENCY X
                                        JOIN    PROMOTION_TARGET_MN Y
                                        ON      X.PRMT_ID = Y.PRMT_ID
                                        AND     X.ITEM_CD = Y.ITEM_CD
                                        WHERE   X.PRMT_ID = CUR.PRMT_ID
                                        AND     X.CUST_ID = CUR.CUST_ID
                                        AND     X.PUBLISH_YN = 'N'
                                        AND     Y.ITEM_DIV = 'C6402'
                                        ORDER   BY
                                                X.FRQ_SEQ,
                                                X.FRQ_HIS_SEQ
                                ) Z
                         WHERE  ROWNUM <= TO_NUMBER(v_nor_standard)
                ) B
                ON      (A.FRQ_SEQ = B.FRQ_SEQ AND A.FRQ_HIS_SEQ = B.FRQ_HIS_SEQ)
                WHEN   MATCHED THEN
                UPDATE
                SET     A.PUBLISH_YN = 'Y'
                       ,A.NOTES = v_coupon_cd;
                
            ELSIF  L_TYPE = 3  THEN
                -- 일반 수량 처리
                MERGE -- + USE_HASH(A B)
                INTO PROMOTION_FREQUENCY A
                USING
                (
                        SELECT  Z.FRQ_SEQ,
                                Z.FRQ_HIS_SEQ
                        FROM    (
                                        SELECT  X.FRQ_SEQ,
                                                X.FRQ_HIS_SEQ
                                        FROM    PROMOTION_FREQUENCY X
                                        JOIN    PROMOTION_TARGET_MN Y
                                        ON      X.PRMT_ID = Y.PRMT_ID
                                        AND     X.ITEM_CD = Y.ITEM_CD
                                        WHERE   X.PRMT_ID = CUR.PRMT_ID
                                        AND     X.CUST_ID = CUR.CUST_ID
                                        AND     X.PUBLISH_YN = 'N'
                                        AND     Y.ITEM_DIV = 'C6402'
                                        ORDER   BY
                                                X.FRQ_SEQ,
                                                X.FRQ_HIS_SEQ
                                ) Z
                         WHERE  ROWNUM <= TO_NUMBER  (  v_nor_qty  )
                ) B
                ON      (A.FRQ_SEQ = B.FRQ_SEQ AND A.FRQ_HIS_SEQ = B.FRQ_HIS_SEQ)
                WHEN   MATCHED THEN
                UPDATE
                SET     A.PUBLISH_YN = 'Y'
                       ,A.NOTES = v_coupon_cd;
            END IF; -- TYPE = 1
          
        END IF; -- 기준충족시
            
    COMMIT;  
        
    END LOOP;
    
    

EXCEPTION
    WHEN NOT_EXISTS_PROMOTION THEN
        ROLLBACK; 
        
        dbms_output.put_line(SQLERRM); 

    WHEN OTHERS THEN
        ROLLBACK; 
        
        dbms_output.put_line(SQLERRM);
        
END BATCH_PRMT_FRQ_SAVE;

/
