--------------------------------------------------------
--  DDL for Procedure PRMT_COUPON_PUBLISH_BULK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PRMT_COUPON_PUBLISH_BULK" (
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
        P_BRAND_CD        IN   VARCHAR2,
        P_CUST_GP_ID      IN   VARCHAR2,
        N_PUBLISH_COUNT   IN   VARCHAR2, 
        N_NOTES           IN   VARCHAR2,
        P_USER_ID         IN   VARCHAR2,   
        O_PRMT_ID         OUT  VARCHAR2,
        O_PRMT_USE_DIV    OUT  VARCHAR2,
        O_PUBLISH_ID      OUT  VARCHAR2,
        O_MY_USER_ID      OUT  VARCHAR2,
        O_RTN_CD          OUT  VARCHAR2
) AS   
        v_result_cd       VARCHAR2(7) := '1'; --성공
        v_publish_id      VARCHAR2(10); -- 쿠폰발행번호
        v_cust_gp_id      VARCHAR2(500); -- 쿠폰발행번호
        
        v_random_cd       VARCHAR2(20); -- 임시쿠폰난수(연번제외)
        v_temp_coupon_cd  VARCHAR2(20); -- 임시쿠폰번호(연번제외)
        v_coupon_cd       VARCHAR2(20); -- 쿠폰번호
        
        v_coupon_dt_type  VARCHAR2(1); -- 쿠폰날짜 타입
        v_coupon_expire   VARCHAR2(4); -- 발행일로부터 쿠폰사용기간
        v_prmt_dt_start   VARCHAR2(8); -- 프로모션시작일자
        v_prmt_dt_end     VARCHAR2(8); -- 프로모션종료일자
        v_coupon_start_dt VARCHAR2(8); -- 쿠폰유효기간시작일자
        v_coupon_end_dt   VARCHAR2(8); -- 쿠폰유효기간종료일자
        v_coupon_img_type VARCHAR2(20); -- 쿠폰이미지타입
        v_item_cd         VARCHAR2(20); -- 상품코드
        v_item_count      NUMBER;
        v_sale_prc        VARCHAR2(11); -- 상품가격
        v_coupon_seq      VARCHAR2(11); -- 쿠폰 시퀀스
        v_coupon_his_seq  VARCHAR2(11); -- 쿠폰 히스토리시퀀스
        v_prmt_use_div    VARCHAR2(10); -- 프로모션 적용구분
        
        CURSOR_COUPON_COUNT NUMBER;
        CURSOR_CUST_ID    VARCHAR2(30);
        CURSOR_CARD_ID    VARCHAR2(100);
        
        NOT_USABLE_PRMT_DT EXCEPTION;
        
BEGIN

        v_cust_gp_id := P_CUST_GP_ID;
        
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
            IF P_PUBLISH_TYPE IN ('C6501','C6502') THEN
            
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
             
           
               MERGE INTO PROMOTION_COUPON A
               USING (
                            SELECT  /*+ INDEX(D C_CARD_INDEX1) */  
                                    '0'                                   AS COUPON_CD
                                   ,v_publish_id                          AS PUBLISH_ID
                                   , B.CUST_ID                            AS CUST_ID
                                   ,(
                                        SELECT ENCRYPT(CARD_ID) 
                                        FROM   C_CARD
                                        WHERE  CUST_ID = CURSOR_CUST_ID
                                        AND    USE_YN = 'Y'
                                        AND    REP_CARD_YN = 'Y'
                                    )                                     AS CARD_ID
                                   ,NULL                                  AS TG_STOR_CD
                                   ,NULL                                  AS STOR_CD
                                   ,NULL                                  AS POS_NO
                                   ,NULL                                  AS BILL_NO
                                   ,NULL                                  AS POS_SEQ
                                   ,'P0303'                               AS COUPON_STATE
                                   ,(
                                        SELECT CASE WHEN COUPON_IMG_TYPE IS NOT NULL THEN COUPON_IMG_TYPE || '_' || (SELECT LVL_CD FROM C_CUST WHERE CUST_ID = CURSOR_CUST_ID)
                                                    ELSE NULL
                                               END
                                        FROM   PROMOTION 
                                        WHERE  PRMT_ID = P_PRMT_ID
                                   )                                      AS COUPON_IMG
                                   ,v_coupon_start_dt                     AS START_DT
                                   ,v_coupon_end_dt                       AS END_DT
                                   ,NULL                                  AS USE_DT
                                   ,NULL                                  AS DESTROY_DT
                                   ,P_USER_ID                             AS INST_USER
                                   ,SYSDATE                               AS INST_DT
                                   ,P_USER_ID                             AS UPD_USER
                                   ,SYSDATE                               AS UPD_DT
                            FROM   MARKETING_GP_CUST A
                            JOIN   C_CUST B
                            ON     A.CUST_ID = B.CUST_ID
                            LEFT OUTER JOIN C_CUST_LVL C
                            ON     B.COMP_CD = C.COMP_CD 
                            AND    B.LVL_CD = C.LVL_CD
                            JOIN   C_CARD D
                            ON     B.CUST_ID = D.CUST_ID
                            WHERE  A.CUST_GP_ID IN (
                                    SELECT REGEXP_SUBSTR(v_cust_gp_id,'[^,]+', 1, LEVEL) FROM DUAL
                                    CONNECT BY REGEXP_SUBSTR(v_cust_gp_id, '[^,]+', 1, LEVEL) IS NOT NULL 
                            )
                            AND   B.USE_YN      = D.USE_YN
                            AND   D.USE_YN      = 'Y'
                            AND   D.CARD_STAT   = '10'
                            AND   D.REP_CARD_YN = 'Y'
                            AND   ( DECRYPT(D.CARD_ID) LIKE '2012%' OR DECRYPT(D.CARD_ID) LIKE '1998%' )   
                            AND   (TRIM(P_BRAND_CD) IS NULL OR B.BRAND_CD = P_BRAND_CD)
               ) B
               ON ( A.COUPON_CD = B.COUPON_CD)
               WHEN NOT MATCHED THEN
                INSERT
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
                )VALUES(
                        '3' || SUBSTR(TO_CHAR(SYSDATE,'YYMMDDHH24MM'), 2, 10) ||  LPAD(TO_CHAR(COUPON_SEQ.NEXTVAL), 8, '0')|| LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*10)), 2,'0')
                       ,B.PUBLISH_ID
                       ,COUPON_SEQ.NEXTVAL
                       ,B.CUST_ID
                       ,B.CARD_ID
                       ,B.TG_STOR_CD
                       ,B.STOR_CD
                       ,B.POS_NO
                       ,B.BILL_NO
                       ,B.POS_SEQ
                       ,B.COUPON_STATE
                       ,B.COUPON_IMG
                       ,B.START_DT
                       ,B.END_DT
                       ,B.USE_DT
                       ,B.DESTROY_DT
                       ,B.INST_USER
                       ,B.INST_DT
                       ,B.UPD_USER
                       ,B.UPD_DT
                )
                ;
                             
               
               /*
               MERGE INTO PROMOTION_COUPON A
               USING (
                            SELECT 
                                   '0'                                   AS COUPON_CD
                                 , A.CUST_ID                             AS CUST_ID
                                 , D.CARD_ID                             AS CARD_ID
                                 , B.LVL_CD
                            FROM   C_CUST B, C_CARD D , MARKETING_GP_CUST A 
                            WHERE  1 = 1
                            AND    A.CUST_GP_ID IN (
                                   SELECT REGEXP_SUBSTR(v_cust_gp_id,'[^,]+', 1, LEVEL) FROM DUAL
                                   CONNECT BY REGEXP_SUBSTR(v_cust_gp_id, '[^,]+', 1, LEVEL) IS NOT NULL 
                            )
                            AND    A.CUST_ID      = D.CUST_ID
                            AND    A.CUST_ID      = B.CUST_ID
                            AND    B.COMP_CD      = D.COMP_CD
                            AND    B.BRAND_CD     = D.BRAND_CD
                            AND    D.COMP_CD      = '016' 
                            AND    D.BRAND_CD     = '100'   
                            AND    D.USE_YN       = 'Y'        
                            AND    D.CARD_STAT    = '10'
                            AND    D.REP_CARD_YN  = 'Y'
                            AND    (DECRYPT(D.CARD_ID) LIKE '2012%' OR DECRYPT(D.CARD_ID) LIKE '1998%')
               ) B
               ON ( A.COUPON_CD = B.COUPON_CD)
               WHEN NOT MATCHED THEN
                INSERT
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
                )VALUES(    -- 3 (1)+ 8년04월12일 12시34분 (9)+ seq(8) + random(2) = 20
                        '3' || SUBSTR(TO_CHAR(SYSDATE,'YYMMDDHH24MM'), 2, 10) ||  LPAD(TO_CHAR(COUPON_SEQ.NEXTVAL), 8, '0')|| LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1,10)*10)), 2,'0')
                       ,B.PUBLISH_ID
                       , COUPON_SEQ.NEXTVAL
                       ,B.CUST_ID
                       ,B.CARD_ID
                       ,B.TG_STOR_CD
                       ,B.STOR_CD
                       ,B.POS_NO
                       ,B.BILL_NO
                       ,B.POS_SEQ
                       ,B.COUPON_STATE
                       ,B.COUPON_IMG
                       ,B.START_DT
                       ,B.END_DT
                       ,B.USE_DT
                       ,B.DESTROY_DT
                       ,B.INST_USER
                       ,B.INST_DT
                       ,B.UPD_USER
                       ,B.UPD_DT
                )
                ;
               */
               
                       
                -- 쿠폰 발행 기록 히스토리 적용
                MERGE INTO PROMOTION_COUPON_HIS A1
                USING (
                    SELECT   A.COUPON_CD               AS COUPON_CD
                            ,0                         AS COUPON_HIS_SEQ
                            ,A.PUBLISH_ID              AS PUBLISH_ID
                            ,A.COUPON_STATE            AS COUPON_STATE
                            ,A.START_DT                AS START_DT
                            ,A.END_DT                  AS END_DT
                            ,NULL                      AS USE_DT
                            ,NULL                      AS DESTROY_DT
                            ,NULL                      AS GROUP_ID_HIS
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN A.CUST_ID
                                   ELSE NULL
                             END
                            )                          AS CUST_ID
                            ,NULL                      AS TO_CUST_ID
                            ,NULL                      AS FROM_CUST_ID
                            ,(CASE WHEN A.CUST_ID IS NOT NULL THEN (SELECT MOBILE FROM C_CUST WHERE CUST_ID = A.CUST_ID)
                                   ELSE NULL
                              END
                            )                          AS MOBILE
                            ,NULL                      AS RECEPTION_MOBILE
                            ,NULL                      AS POS_NO
                            ,NULL                      AS BILL_NO
                            ,NULL                      AS POS_SEQ
                            ,NULL                      AS POS_SALE_DT
                            ,NULL                      AS STOR_CD
                            ,NULL                      AS PUB_STOR_CD
                            ,NULL                      AS ITEM_CD
                            ,A.COUPON_IMG              AS COUPON_IMG 
                            ,P_USER_ID                 AS INST_USER  
                            ,SYSDATE                   AS INST_DT
                     FROM   PROMOTION_COUPON A
                     WHERE  A.PUBLISH_ID = v_publish_id
                ) B
                ON (A1.COUPON_HIS_SEQ = B.COUPON_HIS_SEQ)
                WHEN NOT MATCHED THEN 
                INSERT 
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
                )VALUES(
                         B.COUPON_CD
                        ,COUPON_HIS_SEQ.NEXTVAL
                        ,B.PUBLISH_ID
                        ,B.COUPON_STATE
                        ,B.START_DT
                        ,B.END_DT
                        ,B.USE_DT
                        ,B.DESTROY_DT
                        ,B.GROUP_ID_HIS
                        ,B.CUST_ID
                        ,B.TO_CUST_ID
                        ,B.FROM_CUST_ID
                        ,B.MOBILE
                        ,B.RECEPTION_MOBILE
                        ,B.POS_NO
                        ,B.BILL_NO
                        ,B.POS_SEQ
                        ,B.POS_SALE_DT
                        ,B.STOR_CD
                        ,B.PUB_STOR_CD
                        ,B.ITEM_CD
                        ,B.COUPON_IMG
                        ,B.INST_USER
                        ,B.INST_DT
                );
            
            O_PUBLISH_ID := v_publish_id;
        -- 재발행의 경우
        ELSE
            O_PUBLISH_ID := N_PUBLISH_ID;
        END IF;
        
        O_MY_USER_ID   := P_USER_ID;
        O_PRMT_ID      := P_PRMT_ID;
        O_PRMT_USE_DIV := v_prmt_use_div;
        O_RTN_CD       := v_result_cd;
    ELSE
    
        O_MY_USER_ID   := P_USER_ID;
        O_PRMT_ID      := P_PRMT_ID;
        O_PRMT_USE_DIV := v_prmt_use_div;
        O_RTN_CD       := '2';
    END IF;
    
    
  
EXCEPTION

    WHEN NOT_USABLE_PRMT_DT THEN
         O_RTN_CD  := '513'; --프로모션 기간이 지났습니다.
         dbms_output.put_line(SQLERRM);
         ROLLBACK;
         RETURN ;
    WHEN OTHERS THEN
         O_RTN_CD  := '2'; --실패
         dbms_output.put_line(SQLERRM);
         ROLLBACK;
         RETURN ;
        
END PRMT_COUPON_PUBLISH_BULK;

/
