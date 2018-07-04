--------------------------------------------------------
--  DDL for Procedure API_RCH_DIV_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_RCH_DIV_CODE_SELECT" (
    O_CURSOR   OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-06
    -- Description   :   홈페이지 설문조사 분류코드 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      DIV_CODE
      ,DIV_NM
    FROM RCH_DIV_CODE A
    ORDER BY A.DIV_CODE ASC
    ;
      
END API_RCH_DIV_CODE_SELECT;

/
