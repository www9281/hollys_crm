--------------------------------------------------------
--  DDL for Procedure RCH_MASTER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_MASTER_SELECT" (
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-31
    -- Description   :   설문조사 정보 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      RCH_NO
      ,RCH_NM
      ,TO_CHAR(TO_DATE(RCH_START_DT), 'YYYY-MM-DD') AS RCH_START_DT
      ,TO_CHAR(TO_DATE(RCH_END_DT), 'YYYY-MM-DD') AS RCH_END_DT
      ,QR_URL
      ,PROMOTION_ID
      ,RCH_TOT_POINT
      ,RCH_TOT_LEVEL
      ,RCH_1_LEVEL
      ,RCH_2_LEVEL
      ,RCH_3_LEVEL
      ,RCH_4_LEVEL
      ,RCH_5_LEVEL
      ,RCH_6_LEVEL
      ,RCH_7_LEVEL
      ,TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.INST_USER) AS INST_USER
      ,TO_CHAR(UPD_DT, 'YYYY-MM-DD') AS UPD_DT
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.UPD_USER) AS UPD_USER
    FROM RCH_MASTER A
    ORDER BY A.INST_DT ASC
    ;
    
END RCH_MASTER_SELECT;

/
