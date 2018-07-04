--------------------------------------------------------
--  DDL for Procedure PROMOTION_GIFT_STATS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_GIFT_STATS" (
    N_START_DT   IN   VARCHAR2,
    N_END_DT     IN   VARCHAR2,
    N_GIFT_STATE IN   VARCHAR2,
    N_CUST_ID    IN   VARCHAR2,
    N_GIFT_NO    IN   VARCHAR2,
    O_CURSOR     OUT  SYS_REFCURSOR
) AS 
BEGIN  
    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-18
    -- Description	:	프로모션 모바일 상품권 현황조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT 
        ROW_NUMBER() OVER (ORDER BY A.INST_DT ASC) AS RNUM
      , DECRYPT(A.GIFTCARD_ID) AS GIFT_NO
      ,A.PIN_NO AS PIN_NO
      ,DECRYPT(A.CARD_ID) AS CARD_ID
      ,DECRYPT(A.CUST_NM) AS CUST_NM
      ,FN_GET_FORMAT_HP_NO(DECRYPT(A.MOBILE)) AS MOBILE  
      ,A.AMOUNT AS AMOUNT
      ,DECRYPT(A.TO_CUST_NM) AS TO_CUST_NM
      ,FN_GET_FORMAT_HP_NO(DECRYPT(A.RECEPTION_MOBILE)) AS RECEPTION_MOBILE
      ,TO_CHAR(A.BUY_DT, 'YYYYMMDD') AS BUY_DT
      , USE_PT
      , CREDIT_PAYMENT
      , MOBILE_PAYMENT
      ,GET_COMMON_CODE_NM('01725', A.CARD_STAT) AS CARD_STAT
      ,TO_CHAR(TO_DATE(A.CANCEL_DT,'YYYY-MM-DD'), 'YYYY-MM-DD') AS CANCEL_DT
    FROM (SELECT A.*
                 , ROW_NUMBER() OVER(PARTITION BY A.GIFTCARD_ID ORDER BY A.GIFTCARD_HIS_SEQ DESC) AS SEQ
          FROM GIFTCARD_HIS A) A
    WHERE SEQ = '1'
      AND (TRIM(N_CUST_ID) IS NULL OR A.CUST_ID = N_CUST_ID)
      AND (TRIM(N_GIFT_NO) IS NULL OR DECRYPT(A.GIFTCARD_ID) LIKE '%' || N_GIFT_NO || '%')
      AND (TRIM(N_GIFT_STATE) IS NULL OR A.CARD_STAT = N_GIFT_STATE)
      AND (TRIM(N_START_DT) IS NULL OR TO_CHAR(A.BUY_DT, 'YYYYMMDD') >= N_START_DT)
      AND (TRIM(N_END_DT) IS NULL OR TO_CHAR(A.BUY_DT, 'YYYYMMDD') <= N_END_DT)
    ORDER BY INST_DT DESC
    ;
      
END PROMOTION_GIFT_STATS;

/
