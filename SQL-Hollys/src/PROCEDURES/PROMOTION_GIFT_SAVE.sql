--------------------------------------------------------
--  DDL for Procedure PROMOTION_GIFT_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_GIFT_SAVE" (
    P_CARD_ID    IN   VARCHAR2,
    P_PIN_NO     IN   VARCHAR2,
    P_MY_USER_ID IN   VARCHAR2,
    O_CURSOR     OUT  SYS_REFCURSOR
) AS 
BEGIN  
    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-18
    -- Description	:	프로모션 모바일 상품권 저장
    -- ==========================================================================================
    MERGE INTO GIFTCARD
    USING DUAL
    ON (CARD_ID = P_CARD_ID
        AND PIN_NO = P_PIN_NO)
    WHEN NOT MATCHED THEN
      INSERT (
        CARD_ID
        ,PIN_NO
        ,CARD_STAT
        ,INST_USER
        ,INST_DT
      ) VALUES (
        P_CARD_ID
        ,P_PIN_NO
        ,'G0101'
        ,P_MY_USER_ID
        ,SYSDATE
      );
    
END PROMOTION_GIFT_SAVE;

/
