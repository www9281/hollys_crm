--------------------------------------------------------
--  DDL for Procedure API_C_VOC_SELECT_CODE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_VOC_SELECT_CODE" (
    P_SCH_DIV   IN  VARCHAR2,
    N_CODE      IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-31
    -- Description   :   VOC 상담분류조회
    -- ==========================================================================================
    
    IF P_SCH_DIV = '1' THEN
      -- 문의유형 조회
      OPEN O_CURSOR FOR
      SELECT
        CODE_CD,
        CODE_NM
      FROM COMMON
      WHERE CODE_TP = 'C2000';
    ELSIF P_SCH_DIV = '2' THEN
      -- 상담대분류	조회
      OPEN O_CURSOR FOR
      SELECT
        CODE_CD,
        CODE_NM
      FROM COMMON
      WHERE CODE_TP = 'C3000';
    ELSIF P_SCH_DIV = '3' THEN
      -- 상담중분류 조회
      OPEN O_CURSOR FOR
      SELECT
        CODE_CD,
        CODE_NM
      FROM COMMON
      WHERE CODE_TP = N_CODE;
    END IF;
    
END API_C_VOC_SELECT_CODE;

/
