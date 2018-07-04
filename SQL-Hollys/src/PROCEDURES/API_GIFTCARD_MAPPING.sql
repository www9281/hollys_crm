--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_MAPPING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_MAPPING" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	모바일전자상품권 매핑
-- Test			:	exec API_GIFTCARD_MAPPING '002', '', '', '' 
-- ==========================================================================================
        P_COMP_CD              IN    VARCHAR2,
        P_BRAND_CD             IN    VARCHAR2,
        P_USER_ID              IN    VARCHAR2,
        P_GIFTCARD_ID          IN    VARCHAR2,
        P_PIN_NO               IN    VARCHAR2,
        P_CUST_ID              IN    VARCHAR2,
        P_CARD_STAT            IN    VARCHAR2,
        O_RTN_CD               OUT   VARCHAR2
) AS 
        v_result_cd VARCHAR2(7) := '1'; --성공
        v_card_cnt VARCHAR2(1); -- C_CARD에 카드가 등록되어있는지 확인
        v_card_CUST_ID VARCHAR2(30); -- C_CARD에 카드가 등록되어있는지 확인
        ERR_REMAPPING   EXCEPTION;
        
BEGIN
        SELECT   COUNT(*)
                 INTO v_card_cnt
        FROM     C_CARD
        WHERE    CARD_ID = ENCRYPT(P_GIFTCARD_ID)
        AND      P_PIN_NO = P_PIN_NO; 
        
        IF v_card_cnt < 1 THEN
            BEGIN
                -- 카드 등록(C_CARD)
                INSERT INTO C_CARD
                (       COMP_CD
                        ,CARD_ID
                        ,PIN_NO
                        ,CUST_ID
                        ,CARD_STAT
                        ,BRAND_CD
                        ,REP_CARD_YN
                        ,USE_YN
                        ,INST_DT
                        ,INST_USER
                        ,UPD_DT
                        ,UPD_USER
                        ,CARD_TYPE
               ) VALUES (   
                        P_COMP_CD
                        ,ENCRYPT(P_GIFTCARD_ID)
                        ,P_PIN_NO
                        ,P_CUST_ID
                        ,'10'
                        ,P_BRAND_CD
                        ,'N'
                        ,'Y'
                        ,SYSDATE
                        ,P_USER_ID
                        ,SYSDATE
                        ,P_USER_ID
                        ,'1'
                );
                
               EXCEPTION
                   WHEN OTHERS THEN 
                   ROLLBACK;
                   v_result_cd := '702'; -- 모바일카드 등록도중 문제가 발생했습니다.
           END;
           
        ELSE
              SELECT   CUST_ID INTO v_card_CUST_ID
              FROM     C_CARD
              WHERE    CARD_ID = ENCRYPT(P_GIFTCARD_ID)
              AND      P_PIN_NO = P_PIN_NO;
              
              IF v_card_CUST_ID IS NULL OR v_card_CUST_ID ='' THEN
                    
                  UPDATE   C_CARD
                  SET      CUST_ID             = P_CUST_ID
                          ,USE_YN              = DECODE(P_CARD_STAT, 'Y', 'Y', 'N')
                          ,UPD_USER            = P_USER_ID
                          ,UPD_DT              = SYSDATE
                  WHERE    CARD_ID             = ENCRYPT(P_GIFTCARD_ID)
                  AND      PIN_NO              = P_PIN_NO
                  AND      REP_CARD_YN         = 'N';
              
              ELSE
                  IF v_card_CUST_ID = P_CUST_ID THEN
                  
                      UPDATE   C_CARD
                      SET      CUST_ID             = P_CUST_ID
                              ,USE_YN              = DECODE(P_CARD_STAT, 'Y', 'Y', 'N')
                              ,UPD_USER            = P_USER_ID
                              ,UPD_DT              = SYSDATE
                      WHERE    CARD_ID             = ENCRYPT(P_GIFTCARD_ID)
                      AND      PIN_NO              = P_PIN_NO
                      AND      REP_CARD_YN         = 'N';
                      
                  ELSE
                  
                      v_result_cd := '2';
                      RAISE ERR_REMAPPING;
                      
                  END IF;
                          
              END IF;
           
        END IF;

--        UPDATE   C_CARD
--        SET      CUST_ID             = P_CUST_ID
--                ,USE_YN              = DECODE(P_CARD_STAT, 'Y', 'Y', 'N')
--                ,UPD_USER            = P_USER_ID
--                ,UPD_DT              = SYSDATE
--        WHERE    CARD_ID             = ENCRYPT(P_GIFTCARD_ID)
--        AND      PIN_NO              = P_PIN_NO
--        AND      REP_CARD_YN         = 'N';

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN ERR_REMAPPING THEN
        O_RTN_CD  := '2'; --실패
    
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
      
END API_GIFTCARD_MAPPING;

/
