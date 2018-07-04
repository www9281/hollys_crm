--------------------------------------------------------
--  DDL for Procedure API_RCH_RPLY_TYPE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_RCH_RPLY_TYPE_SELECT" (
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   API 홈페이지 설문조사 답변분류 코드 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      CODE_CD
      ,CODE_NM
    FROM COMMON
    WHERE CODE_TP = 'R1000';
    
END API_RCH_RPLY_TYPE_SELECT;

/
