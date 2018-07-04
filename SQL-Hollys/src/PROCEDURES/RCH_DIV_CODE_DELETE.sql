--------------------------------------------------------
--  DDL for Procedure RCH_DIV_CODE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_DIV_CODE_DELETE" (
    P_DIV_CODE    IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 삭제
    -- ==========================================================================================
    
    DELETE FROM RCH_DIV_CODE
    WHERE DIV_CODE = P_DIV_CODE;
      
END RCH_DIV_CODE_DELETE;

/
