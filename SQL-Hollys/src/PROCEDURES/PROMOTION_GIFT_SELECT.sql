--------------------------------------------------------
--  DDL for Procedure PROMOTION_GIFT_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_GIFT_SELECT" (
    N_START_DT   IN   VARCHAR2,
    N_END_DT     IN   VARCHAR2,
    N_GIFT_STATE IN   VARCHAR2,
    N_GIFT_NO    IN   VARCHAR2,
    O_CURSOR     OUT  SYS_REFCURSOR
) AS 
BEGIN  
    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-18
    -- Description	:	프로모션 모바일 상품권 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
        ROW_NUMBER() OVER (ORDER BY INST_DT ASC) AS RNUM
      , CARD_ID
      ,PIN_NO
      ,GET_COMMON_CODE_NM('01725', CARD_STAT) AS CARD_STAT
      ,TO_CHAR(SEND_DT, 'YYYY-MM-DD') AS SEND_DT
      ,INST_USER 
      ,TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT 
      ,UPD_USER
      ,UPD_DT
    FROM GIFTCARD
    WHERE 1=1
      AND (N_GIFT_STATE IS NULL OR CARD_STAT = N_GIFT_STATE)
      AND (N_START_DT IS NULL OR TO_CHAR(INST_DT, 'YYYYMMDD') >= N_START_DT)
      AND (N_END_DT IS NULL OR TO_CHAR(INST_DT, 'YYYYMMDD') <= N_END_DT)
      AND (N_GIFT_NO IS NULL OR CARD_ID LIKE '%' || N_GIFT_NO || '%')
      AND ROWNUM <= 1000
      ORDER BY RNUM DESC
      ;
        
END PROMOTION_GIFT_SELECT;

/
