--------------------------------------------------------
--  DDL for Procedure STORE_GP_DT_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_DT_SELECT" (
    N_STOR_GP_ID    IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 상세매장목록 조회
    -- Test          :   
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      A.STOR_GP_ID
      ,A.STOR_CD
      ,A.USE_YN
      ,B.STOR_NM
    FROM STORE_GP_IN_STORE A , STORE B 
    WHERE A.STOR_CD = B.STOR_CD
      AND A.STOR_GP_ID = N_STOR_GP_ID
      AND B.USE_YN = 'Y'
      AND A.USE_YN = 'Y'
    ; 
    
END STORE_GP_DT_SELECT;

/
