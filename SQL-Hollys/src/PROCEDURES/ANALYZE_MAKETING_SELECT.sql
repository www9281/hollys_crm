--------------------------------------------------------
--  DDL for Procedure ANALYZE_MAKETING_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."ANALYZE_MAKETING_SELECT" (
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-03-19
    -- Description   :   회원분석 마켓팅 목록 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      CUST_GP_ID AS CODE_CD
      ,CUST_GP_NM AS CODE_NM
    FROM MARKETING_GP;
    
END ANALYZE_MAKETING_SELECT;

/
