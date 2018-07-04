--------------------------------------------------------
--  DDL for Procedure RCH_PROMOTION_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_PROMOTION_SELECT" (
    N_RCH_NO  IN  VARCHAR2,
    O_CURSOR  OUT SYS_REFCURSOR
) AS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-06
    -- Description   :   설문조사 프로모션 정보 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      A.PRMT_ID AS CODE_CD
      , A.PRMT_NM AS CODE_NM 
    FROM PROMOTION A  
    WHERE A.PRMT_TYPE = 'C6020'
      AND (N_RCH_NO IS NULL OR A.PRMT_ID NOT IN (SELECT PROMOTION_ID FROM RCH_MASTER WHERE PROMOTION_ID IS NOT NULL AND RCH_NO != N_RCH_NO))
    ORDER BY INST_DT DESC
    ; 
    
END RCH_PROMOTION_SELECT;

/
