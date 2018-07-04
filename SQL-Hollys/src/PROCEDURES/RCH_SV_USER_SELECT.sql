--------------------------------------------------------
--  DDL for Procedure RCH_SV_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_SV_USER_SELECT" (
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      SV_USER_ID AS USER_ID
      , (SELECT USER_NM FROM HQ_USER WHERE USER_ID = SV_USER_ID) AS USER_NM
    FROM STORE
    WHERE SV_USER_ID IS NOT NULL
    GROUP BY SV_USER_ID;
      
END RCH_SV_USER_SELECT;

/
