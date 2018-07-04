--------------------------------------------------------
--  DDL for Procedure PRMT_COUPON_PUBLISH2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PRMT_COUPON_PUBLISH2" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-11-16
-- Description    :    쿠폰 발행
-- Test            :    exec PRMT_COUPON_PUBLISH '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2,
        N_PUBLISH_ID      IN   VARCHAR2,
        P_PUBLISH_TYPE    IN   VARCHAR2,
        P_OWN_YN          IN   VARCHAR2,
        N_ARR_CUST_LIST   IN   VARCHAR2, 
        N_PUBLISH_COUNT   IN   VARCHAR2, 
        N_NOTES           IN   VARCHAR2,
        P_USER_ID         IN   VARCHAR2,   
        O_PRMT_ID         OUT  VARCHAR2,
        O_PRMT_USE_DIV    OUT  VARCHAR2,
        O_PUBLISH_ID      OUT  VARCHAR2,
        O_MY_USER_ID      OUT  VARCHAR2,
        O_RTN_CD          OUT  VARCHAR2
) AS   
        v_result_cd VARCHAR2(7) := '1'; --성공 
        
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
        v_coupon_img_type VARCHAR2(20); -- 쿠폰이미지타입
        v_item_cd VARCHAR2(20); -- 상품코드
        v_item_count NUMBER;
        v_sale_prc VARCHAR2(11); -- 상품가격
        
        v_coupon_seq VARCHAR2(11); -- 쿠폰 시퀀스
        v_coupon_his_seq VARCHAR2(11); -- 쿠폰 히스토리시퀀스
        v_prmt_use_div VARCHAR2(10); -- 프로모션 적용구분
        
        CURSOR_COUPON_COUNT NUMBER;
        CURSOR_CUST_ID  VARCHAR2(30);
        CURSOR_CARD_ID  VARCHAR2(100);
        
        NOT_USABLE_PRMT_DT EXCEPTION;
        NOT_MATCH_ITEM_HOLLYS_CON EXCEPTION;
        
BEGIN
        
        SELECT COUPON_DT_TYPE
              ,COUPON_EXPIRE
              ,PRMT_DT_START
              ,PRMT_DT_END
              ,PRMT_USE_DIV
              ,COUPON_IMG_TYPE
        INTO   v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end, v_prmt_use_div, v_coupon_img_type
        FROM   PROMOTION
        WHERE  PRMT_ID = P_PRMT_ID;
         
        -- 신규발행의 경우
        IF N_PUBLISH_ID IS NULL THEN
        
            -- 신규발행번호
            SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
                   INTO v_publish_id
            FROM   PROMOTION_COUPON_PUBLISH;
            
            v_publish_id := LPAD(v_publish_id, 6, '0');         
           
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
            
            -- 멤버십쿠폰
            IF P_PUBLISH_TYPE = 'C6501' THEN
            
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
                        ,P_PRMT_ID
                        ,P_PUBLISH_TYPE
                        ,P_OWN_YN
                        ,N_PUBLISH_COUNT
                        ,N_NOTES                    
                        ,P_USER_ID
                        ,SYSDATE
                        ,P_USER_ID
                        ,SYSDATE
               );
            
                 -- 고객아이디 분할                
                 DECLARE CURSOR  CURSOR_CUST IS 
                                 (SELECT REGEXP_SUBSTR(N_ARR_CUST_LIST,'[^;]+', 1, LEVEL) AS CUST_ID
                                 FROM DUAL
                                 CONNECT BY REGEXP_SUBSTR (N_ARR_CUST_LIST,'[^;]+', 1, LEVEL) IS NOT NULL);
                                 
                 BEGIN    
                         OPEN    CURSOR_CUST;
                         
                         LOOP
                                 FETCH   CURSOR_CUST
                                 INTO    CURSOR_CUST_ID;  
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
                                       ,(
                                            SELECT ENCRYPT(CARD_ID) 
                                            FROM   C_CARD
                                            WHERE  CUST_ID = CURSOR_CUST_ID
                                            AND    USE_YN = 'Y'
                                            AND    REP_CARD_YN = 'Y'
                                        )
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,'P0303'
                                       ,(
                                            SELECT CASE WHEN COUPON_IMG_TYPE IS NOT NULL THEN COUPON_IMG_TYPE || '_' || (SELECT LVL_CD FROM C_CUST WHERE CUST_ID = CURSOR_CUST_ID)
                                                        ELSE NULL
                                                   END
                                            FROM   PROMOTION 
                                            WHERE  PRMT_ID = P_PRMT_ID
                                       )
                                       ,v_coupon_start_dt
                                       ,v_coupon_end_dt
                                       ,NULL
                                       ,NULL
                                       ,P_USER_ID
                                       ,SYSDATE
                                       ,P_USER_ID
                                       ,SYSDATE
                               );
                               
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
                                        SELECT    A.COUPON_CD  
                                                ,v_coupon_his_seq
                                                ,A.PUBLISH_ID
                                                ,A.COUPON_STATE
                                                ,A.START_DT
                                                ,A.END_DT
                                                ,NULL
                                                ,NULL
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
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,A.COUPON_IMG
                                                ,P_USER_ID
                                                ,SYSDATE
                                         FROM    PROMOTION_COUPON A
                                         JOIN   PROMOTION_COUPON_PUBLISH B
                                         ON     A.PUBLISH_ID = B.PUBLISH_ID
                                         WHERE    A.COUPON_CD = v_random_cd;
                        
                                         EXCEPTION
                                            WHEN OTHERS THEN 
                                            O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                                            dbms_output.put_line(SQLERRM); 
                                            ROLLBACK;
                                    END;
                               
                           END LOOP;
                 END;
                
                
            -- 프로모션쿠폰
            ELSIF P_PUBLISH_TYPE = 'C6502' THEN
               
               -- 프로모션쿠폰(기명)
               IF P_OWN_YN = 'Y' THEN
               
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
                            ,P_PRMT_ID
                            ,P_PUBLISH_TYPE
                            ,P_OWN_YN
                            ,N_PUBLISH_COUNT
                            ,N_NOTES                    
                            ,P_USER_ID
                            ,SYSDATE
                            ,P_USER_ID
                            ,SYSDATE
                   );
                   
                   -- 고객아이디 분할                
                   DECLARE CURSOR  CURSOR_CUST IS 
                                   (SELECT REGEXP_SUBSTR(N_ARR_CUST_LIST,'[^;]+', 1, LEVEL) AS CUST_ID
                                   FROM DUAL
                                   CONNECT BY REGEXP_SUBSTR (N_ARR_CUST_LIST,'[^;]+', 1, LEVEL) IS NOT NULL);
                                 
                   BEGIN    
                             OPEN    CURSOR_CUST;
                             LOOP
                                     FETCH   CURSOR_CUST
                                     INTO    CURSOR_CUST_ID;  
                                     EXIT    WHEN  CURSOR_CUST%NOTFOUND;
                
                                v_random_cd := '';
                                
                                LOOP
                                    -- 난수쿠폰번호 생성(Prefix(5)+랜덤번호(4자리)+년도(2자리)+랜덤번호(3자리)+발행번호(6자리))
                                    v_random_cd := '5' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100)) || v_publish_id;
                                    
                                    
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
                                       ,(
                                            SELECT ENCRYPT(CARD_ID) 
                                            FROM   C_CARD
                                            WHERE  CUST_ID = CURSOR_CUST_ID
                                            AND    USE_YN = 'Y'
                                            AND    REP_CARD_YN = 'Y'
                                        )
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,NULL
                                       ,'P0303'
                                       ,(
                                            SELECT CASE WHEN COUPON_IMG_TYPE IS NOT NULL THEN COUPON_IMG_TYPE || '_' || (SELECT LVL_CD FROM C_CUST WHERE CUST_ID = CURSOR_CUST_ID)
                                                        ELSE NULL
                                                   END
                                            FROM   PROMOTION 
                                            WHERE  PRMT_ID = P_PRMT_ID
                                       )
                                       ,v_coupon_start_dt
                                       ,v_coupon_end_dt
                                       ,NULL
                                       ,NULL
                                       ,P_USER_ID
                                       ,SYSDATE
                                       ,P_USER_ID
                                       ,SYSDATE
                               );
                               
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
                                        SELECT    A.COUPON_CD  
                                                ,v_coupon_his_seq
                                                ,A.PUBLISH_ID
                                                ,A.COUPON_STATE
                                                ,A.START_DT
                                                ,A.END_DT
                                                ,NULL
                                                ,NULL
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
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,NULL
                                                ,A.COUPON_IMG
                                                ,P_USER_ID
                                                ,SYSDATE
                                         FROM    PROMOTION_COUPON A
                                         JOIN   PROMOTION_COUPON_PUBLISH B
                                         ON     A.PUBLISH_ID = B.PUBLISH_ID
                                         WHERE    A.COUPON_CD = v_random_cd;
                        
                                         EXCEPTION
                                            WHEN OTHERS THEN 
                                            O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                                            ROLLBACK;
                                            dbms_output.put_line(SQLERRM); 
                                    END;
                                             
                                END LOOP;
                   
                   END;
                   
               -- 프로모션쿠폰(무기명)
               ELSE                
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
                           ,P_PRMT_ID
                           ,P_PUBLISH_TYPE
                           ,P_OWN_YN
                           ,N_PUBLISH_COUNT
                           ,N_NOTES                    
                           ,P_USER_ID
                           ,SYSDATE
                           ,P_USER_ID
                           ,SYSDATE
                   ); 
               
                   -- 고객아이디 분할
                   FOR PUBLISH_COUNT IN 1..TO_NUMBER(N_PUBLISH_COUNT)
                   LOOP
                   
                        v_random_cd := '';
                                
                        LOOP
                            -- 난수쿠폰번호 생성(Prefix(5)+랜덤번호(4자리)+년도(2자리)+랜덤번호(3자리)+발행번호(6자리))
                            v_random_cd := '5' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100)) || v_publish_id;
                                                    
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
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,NULL
                                ,'P0303'
                                ,NULL
                                ,v_coupon_start_dt
                                ,v_coupon_end_dt
                                ,NULL
                                ,NULL
                                ,P_USER_ID
                                ,SYSDATE
                                ,P_USER_ID
                                ,SYSDATE
                        );
                      
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
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,A.COUPON_IMG
                                    ,P_USER_ID
                                    ,SYSDATE
                             FROM    PROMOTION_COUPON A
                             JOIN   PROMOTION_COUPON_PUBLISH B
                             ON     A.PUBLISH_ID = B.PUBLISH_ID
                             WHERE    A.COUPON_CD = v_random_cd;
            
                             EXCEPTION
                                WHEN OTHERS THEN 
                                O_RTN_CD := '506'; -- 쿠폰정보기록 도중 문제가 생겼습니다.
                                ROLLBACK;
                                dbms_output.put_line(SQLERRM); 
                        END;
                       
                   END LOOP;
                   
               END IF;        
                 
            END IF;
            O_PUBLISH_ID := v_publish_id;
        -- 재발행의 경우
        ELSE
            O_PUBLISH_ID := N_PUBLISH_ID;
        END IF;         
         
        O_MY_USER_ID := P_USER_ID;
        O_PRMT_ID := P_PRMT_ID;
        O_PRMT_USE_DIV := v_prmt_use_div;
        O_RTN_CD := v_result_cd;
        dbms_output.put_line(SQLERRM);
       
EXCEPTION

    WHEN NOT_USABLE_PRMT_DT THEN
         O_RTN_CD  := '513'; --프로모션 기간이 지났습니다.
         dbms_output.put_line(SQLERRM);
         ROLLBACK;
    WHEN OTHERS THEN
         O_RTN_CD  := '2'; --실패
         dbms_output.put_line(SQLERRM);
         ROLLBACK;
        
END PRMT_COUPON_PUBLISH2;

/
