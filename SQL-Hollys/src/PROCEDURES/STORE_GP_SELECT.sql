--------------------------------------------------------
--  DDL for Procedure STORE_GP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_SELECT" (
    N_BRAND_CD    IN  VARCHAR2,
    N_STOR_NM     IN  VARCHAR2,
    N_USE_YN      IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 조회
    -- Test          :   
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      A.STOR_GP_ID
      ,A.STOR_GP_NM
      ,A.REMARK
      ,A.USE_YN
      ,A.BRAND_CD
      ,(SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) AS BRAND_NM
    FROM STORE_GP A 
    WHERE (N_BRAND_CD IS NULL OR BRAND_CD = N_BRAND_CD)
      AND (N_STOR_NM IS NULL OR STOR_GP_NM LIKE '%' || N_STOR_NM || '%')
      AND (N_USE_YN IS NULL OR USE_YN = N_USE_YN)
    ORDER BY A.STOR_GP_NM
    ; 
    
END STORE_GP_SELECT;

/
