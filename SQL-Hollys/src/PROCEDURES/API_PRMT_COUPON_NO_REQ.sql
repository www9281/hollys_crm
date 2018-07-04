--------------------------------------------------------
--  DDL for Procedure API_PRMT_COUPON_NO_REQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_PRMT_COUPON_NO_REQ" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:   쿠폰 번호 요청(발급)
-- Test			:	exec API_PRMT_COUPON_NO_REQ '016', '101', '163'
-- ==========================================================================================
        P_COMP_CD        IN   VARCHAR2,
        P_BRAND_CD       IN   VARCHAR2,
        P_PRMT_ID        IN   VARCHAR2,
        P_STOR_CD        IN   VARCHAR2,
        N_CUST_ID        IN   VARCHAR2,
        N_CRE_COUPON_SEQ IN   VARCHAR2, 
        N_COUPON_SEQ     IN   VARCHAR2,
        P_USE_DIV        IN   VARCHAR2,
        N_COUPON_CD      IN   VARCHAR2,
        P_GROUP_ID       IN   VARCHAR2, 
        P_USER_ID        IN   VARCHAR2, 
        O_COUPON_CD      OUT  VARCHAR2,
        O_COUPON_SEQ     OUT  VARCHAR2,
        O_START_DT       OUT  VARCHAR2,
        O_END_DT         OUT  VARCHAR2,
        O_GROUP_ID       OUT  VARCHAR2,
        O_PRMT_USE_DIV   OUT  VARCHAR2,
        O_PUBLISH_ID     OUT  VARCHAR2,
        O_PRMT_COUPON_YN OUT  VARCHAR2,
        O_RTN_CD         OUT  VARCHAR2
) AS 
        v_result_cd      VARCHAR2(7) := '1'; --성공
        v_sub_prmt_id VARCHAR2(5); -- 서브프로모션 아이디
        v_publish_id VARCHAR2(10); -- 쿠폰발행번호
        v_random_cd VARCHAR2(20); -- 임시쿠폰난수(연번제외)
        v_temp_coupon_cd VARCHAR2(20); -- 임시쿠폰번호(연번제외)
        v_coupon_cd VARCHAR2(20); -- 쿠폰번호
        v_prmt_class VARCHAR2(10); -- 프로모션 분류
        v_coupon_dt_type VARCHAR2(1); -- 쿠폰날짜 타입
        v_coupon_expire VARCHAR2(4); -- 발행일로부터 쿠폰사용기간
        v_prmt_dt_start VARCHAR2(8); -- 프로모션시작일자
        v_prmt_dt_end VARCHAR2(8); -- 프로모션종료일자
        v_coupon_start_dt VARCHAR2(8); -- 쿠폰유효기간시작일자
        v_coupon_end_dt VARCHAR2(8); -- 쿠폰유효기간종료일자
        v_prmt_use_div VARCHAR2(10); -- 프로모션 적용구분
        v_stor_limit VARCHAR2(1); -- 매장 제한
        v_print_target VARCHAR2(10); -- 출력대상
        v_prmt_coupon_yn VARCHAR2(1); -- 쿠폰프로모션 여부
        
        v_coupon_img_type VARCHAR2(20); -- 쿠폰이미지타입
        
        NOT_USABLE_PRMT_DT EXCEPTION;       -- 프로모션 기간이 지났습니다.
        NOT_MATCH_MEMBER_EVENT EXCEPTION;   -- 해당 프로모션은 멤버십 이벤트 이므로 CUST_ID가 필수입니다.
        NOT_COUPON_EVENT EXCEPTION;         -- 해당 이벤트 유형은 쿠폰요청이벤트가 아닙니다.
        NOT_MATCH_TARGET EXCEPTION;         -- 해당 이벤트는 출력대상이 일반인대상인데 고객 정보가 전달되었습니다.
        NOT_IN_CUST_ID EXCEPTION;           -- 해당 이벤트는 출력대상이 멤버십대상인데 고객 정보가 없습니다.
        NOT_MATCH_EVENT_DIV EXCEPTION;      -- 온라인이벤트는 적용구분이 온라인으로 설정되어있어야합니다.
        
BEGIN   
        IF P_USE_DIV = '101' THEN -- 발급일때
        
            -- 신규발행번호
            SELECT NVL(MAX(CAST(PUBLISH_ID AS NUMBER)),0) + 1 
                   INTO v_publish_id
            FROM   PROMOTION_COUPON_PUBLISH;
            
            v_publish_id := LPAD(v_publish_id, 6, '0');
            
            SELECT SUB_PRMT_ID
                   INTO v_sub_prmt_id
            FROM   PROMOTION
            WHERE  PRMT_ID = P_PRMT_ID;
            
            SELECT STOR_LIMIT
                  ,PRMT_CLASS
                  ,COUPON_DT_TYPE
                  ,COUPON_EXPIRE
                  ,PRMT_DT_START
                  ,PRMT_DT_END
                  ,PRMT_USE_DIV
                  ,PRINT_TARGET
                  ,PRMT_COUPON_YN
                  ,COUPON_IMG_TYPE
            INTO   v_stor_limit, v_prmt_class, v_coupon_dt_type, v_coupon_expire, v_prmt_dt_start, v_prmt_dt_end, v_prmt_use_div, v_print_target, v_prmt_coupon_yn, v_coupon_img_type
            FROM   PROMOTION
            WHERE  PRMT_ID = v_sub_prmt_id;
            
            O_PRMT_USE_DIV := v_prmt_use_div;
            
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
                                                
            -- 멤버십이벤트 || 멤버십혜택
            IF v_prmt_class = 'C5001' OR v_prmt_class = 'C5006' THEN
                
                IF N_CUST_ID IS NOT NULL THEN
                
                    -- 난수쿠폰번호 생성(Prefix(3)+랜덤번호(4자리)+년도(2자리)+월(2자리)+일(2자리)+랜덤번호(3자리)+발행번호(6자리))
                    v_random_cd := '3' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(SYSDATE,'MM') || TO_CHAR(SYSDATE,'DD') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));
                    
                    -- 쿠폰번호 중복 조회 
                    SELECT MAX(A.COUPON_CD)
                           INTO v_temp_coupon_cd
                    FROM   PROMOTION_COUPON A
                    JOIN   PROMOTION_COUPON_PUBLISH B
                    ON     A.PUBLISH_ID = B.PUBLISH_ID
                    WHERE  B.PRMT_ID = v_sub_prmt_id
                    AND    A.COUPON_CD LIKE v_random_cd || '%'
                    AND    B.OWN_YN = 'Y'
                    AND    B.PUBLISH_TYPE = 'C6501';
                    
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
                                ,NULL                    
                                ,P_USER_ID
                                ,SYSDATE
                                ,P_USER_ID
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
                               ,N_CRE_COUPON_SEQ
                               ,(CASE WHEN v_prmt_use_div = 'C6921' THEN NULL -- 오프라인적용일 경우
                                      ELSE N_CUST_ID
                                 END
                               )
                               ,(
                                    SELECT CARD_ID 
                                    FROM   C_CARD
                                    WHERE  CUST_ID = N_CUST_ID
                                    AND    USE_YN = 'Y'
                                    AND    REP_CARD_YN = 'Y'
                                )
                               ,(
                                    SELECT CASE WHEN v_stor_limit = '0' THEN NULL
                                                WHEN v_stor_limit = '1' THEN P_STOR_CD
                                                ELSE NULL
                                           END 
                                    FROM   PROMOTION
                                    WHERE  PRMT_ID = v_sub_prmt_id
                               )
                               ,NULL
                               ,NULL
                               ,NULL
                               ,NULL
                               ,NULL
                               ,'P0303'
                               ,(
                                    CASE WHEN v_coupon_img_type IS NOT NULL THEN (
                                                                                    CASE WHEN v_coupon_img_type = 'P0401' THEN 'P0401'
                                                                                         ELSE v_coupon_img_type || '_' || (SELECT LVL_CD FROM C_CUST WHERE CUST_ID = N_CUST_ID)
                                                                                    END
                                                                                 )
                                         ELSE 'P0401'
                                    END
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
                       
                       EXCEPTION
                            WHEN OTHERS THEN 
                            O_RTN_CD := '504'; -- 쿠폰발급 도중 문제가 생겼습니다.
                            dbms_output.put_line(SQLERRM);
                       
                   END;
                   
               ELSE --고객 아이디 없을때
                   RAISE NOT_MATCH_MEMBER_EVENT;
               END IF;
                   
            -- LSM 이벤트 || 영수증이벤트 || 기프트카드(충전/사용) || 온라인이벤트
            ELSIF v_prmt_class = 'C5002' OR v_prmt_class = 'C5003' OR v_prmt_class = 'C5005' OR v_prmt_class = 'C5007' THEN
             
               IF v_print_target = 'C6102' AND N_CUST_ID IS NOT NULL THEN -- 출력대상이 일반일 경우
                   RAISE NOT_MATCH_TARGET; -- 해당 이벤트는 출력대상이 일반인대상인데 고객 정보가 전달되었습니다.
               ELSIF v_print_target = 'C6103' AND N_CUST_ID IS NULL THEN -- 출력대상이 멤버십일 경우
                   RAISE NOT_IN_CUST_ID; -- 해당 이벤트는 출력대상이 멤버십대상인데 고객 정보가 없습니다.
               END IF;
            
               --프로모션 쿠폰생성
               -- 난수쿠폰번호 생성(Prefix(5)+랜덤번호(4자리)+년도(2자리)+랜덤번호(3자리))
               v_random_cd := '5' || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*1000)) || TO_CHAR(SYSDATE,'YY') || TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*100));
               
               -- 쿠폰번호 중복 조회 
               SELECT MAX(A.COUPON_CD)
                      INTO v_temp_coupon_cd
               FROM   PROMOTION_COUPON A
               JOIN   PROMOTION_COUPON_PUBLISH B
               ON     A.PUBLISH_ID = B.PUBLISH_ID
               WHERE  B.PRMT_ID = v_sub_prmt_id
               AND    A.COUPON_CD LIKE v_random_cd || '%';
               
               v_temp_coupon_cd := SUBSTR(v_temp_coupon_cd, 1, 10);
                
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
                            ,'C6502'
                            ,(CASE WHEN N_CUST_ID IS NOT NULL THEN 'Y'
                                  ELSE 'N'
                              END
                            )
                            ,(CASE WHEN N_CUST_ID IS NOT NULL THEN NULL
                                   ELSE '1'
                              END
                            )
                            ,NULL                    
                            ,P_USER_ID
                            ,SYSDATE
                            ,P_USER_ID
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
                           ,N_CRE_COUPON_SEQ
                           ,(CASE WHEN v_prmt_use_div = 'C6921' THEN NULL -- 오프라인적용,온라인(SMS)일 경우
                                  ELSE (CASE WHEN N_CUST_ID IS NOT NULL THEN N_CUST_ID
                                             ELSE NULL
                                        END)
                             END
                           )
                           ,(CASE WHEN N_CUST_ID IS NOT NULL THEN (SELECT CARD_ID FROM C_CARD WHERE CUST_ID = N_CUST_ID AND USE_YN = 'Y' AND REP_CARD_YN = 'Y')
                                  ELSE NULL
                             END
                           )
                           ,(
                                SELECT CASE WHEN v_stor_limit = '0' THEN NULL
                                            WHEN v_stor_limit = '1' THEN P_STOR_CD
                                            ELSE NULL
                                       END 
                                FROM   PROMOTION
                                WHERE  PRMT_ID = v_sub_prmt_id
                           )
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL
                           ,NULL
                           ,'P0303'
                           ,(CASE WHEN v_prmt_use_div = 'C6921' THEN NULL
                                  ELSE (
                                            CASE WHEN v_coupon_img_type IS NOT NULL THEN (
                                                                                            CASE WHEN N_CUST_ID IS NOT NULL THEN (
                                                                                                                                     CASE WHEN v_coupon_img_type = 'P0401' THEN 'P0401'
                                                                                                                                          ELSE v_coupon_img_type || '_' || (SELECT LVL_CD FROM C_CUST WHERE CUST_ID = N_CUST_ID)
                                                                                                                                     END
                                                                                                                                 )
                                                                                                 ELSE 'P0401'
                                                                                            END
                                                                                         )
                                                 ELSE 'P0401'
                                            END
                                       )
                             END
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
                   
                   EXCEPTION
                        WHEN OTHERS THEN 
                        O_RTN_CD := '504'; -- 쿠폰발급 도중 문제가 생겼습니다.
                        dbms_output.put_line(SQLERRM);                   
                END;
                
            ELSE
                RAISE NOT_COUPON_EVENT;
            END IF;
            
            O_COUPON_CD := v_coupon_cd;
            O_COUPON_SEQ := N_CRE_COUPON_SEQ;
            O_START_DT := v_coupon_start_dt;
            O_END_DT := v_coupon_end_dt;
            O_GROUP_ID := P_GROUP_ID;
            O_PUBLISH_ID := v_publish_id;
            O_PRMT_COUPON_YN := v_prmt_coupon_yn;
            O_RTN_CD := v_result_cd;
            
        ELSE -- 발급취소일때
            
            UPDATE PROMOTION_COUPON
            SET    DESTROY_DT    = TO_CHAR(SYSDATE,'YYYYMMDD')
                   ,COUPON_STATE = 'P0304' 
                   ,UPD_USER     = P_USER_ID
                   ,UPD_DT       = SYSDATE
            WHERE  COUPON_CD     = N_COUPON_CD
            AND    COUPON_SEQ    = N_COUPON_SEQ;
            
            O_COUPON_CD := N_COUPON_CD;
            O_COUPON_SEQ := N_COUPON_SEQ;
            O_START_DT := '';
            O_END_DT := '';
            O_GROUP_ID := '';
            O_PRMT_USE_DIV := '';
            O_PUBLISH_ID := v_publish_id;
            O_PRMT_COUPON_YN := '';
            O_RTN_CD := v_result_cd;
            dbms_output.put_line(SQLERRM);
        END IF;       

EXCEPTION
    
    WHEN NOT_MATCH_EVENT_DIV THEN
         O_RTN_CD  := '533'; -- 온라인이벤트는 적용구분이 온라인으로 설정되어있어야합니다.
         dbms_output.put_line(SQLERRM);
    WHEN NOT_MATCH_TARGET THEN
         O_RTN_CD  := '531'; -- 해당 이벤트는 출력대상이 일반인대상인데 고객 정보가 전달되었습니다.
         dbms_output.put_line(SQLERRM);
    WHEN NOT_IN_CUST_ID THEN
         O_RTN_CD  := '532'; -- 해당 이벤트는 출력대상이 멤버십대상인데 고객 정보가 없습니다.
         dbms_output.put_line(SQLERRM);
    WHEN NOT_COUPON_EVENT THEN
         O_RTN_CD  := '515'; -- 해당 이벤트 유형은 쿠폰요청이벤트가 아닙니다.
         dbms_output.put_line(SQLERRM);
    WHEN NOT_MATCH_MEMBER_EVENT THEN
         O_RTN_CD  := '514'; -- 해당 프로모션은 멤버십 이벤트 이므로 CUST_ID가 필수입니다.
         dbms_output.put_line(SQLERRM);
    WHEN NOT_USABLE_PRMT_DT THEN
         O_RTN_CD  := '513'; -- 프로모션 기간이 지났습니다.
         dbms_output.put_line(SQLERRM);
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        dbms_output.put_line(SQLERRM);
        
END API_PRMT_COUPON_NO_REQ;

/
