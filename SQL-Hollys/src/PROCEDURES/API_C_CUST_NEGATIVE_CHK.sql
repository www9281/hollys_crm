--------------------------------------------------------
--  DDL for Procedure API_C_CUST_NEGATIVE_CHK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_NEGATIVE_CHK" 
(
  P_DI_STR        IN   VARCHAR2,
  O_NEGATIVE_YN   OUT  VARCHAR2
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-11
    -- API REQUEST   :   HLS_CRM_IF_0070
    -- Description   :   부정회원체크		
    -- ==========================================================================================
    SELECT
      NVL(MAX(NEGATIVE_USER_YN), 'N') INTO O_NEGATIVE_YN
    FROM C_CUST
    WHERE DI_STR = P_DI_STR;
      
END API_C_CUST_NEGATIVE_CHK;

/
