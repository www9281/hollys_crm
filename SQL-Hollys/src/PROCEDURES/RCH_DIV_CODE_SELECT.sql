--------------------------------------------------------
--  DDL for Procedure RCH_DIV_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_DIV_CODE_SELECT" (
    O_CURSOR   OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      DIV_CODE
      ,DIV_NM
      ,TO_CHAR(A.INST_DT, 'YYYY-MM-DD') AS INST_DT
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.INST_USER) AS INST_USER
      ,TO_CHAR(A.UPD_DT, 'YYYY-MM-DD') AS UPD_DT
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.UPD_USER) AS UPD_USER
    FROM RCH_DIV_CODE A
    ORDER BY A.DIV_CODE ASC
    ;
      
END RCH_DIV_CODE_SELECT;

/
