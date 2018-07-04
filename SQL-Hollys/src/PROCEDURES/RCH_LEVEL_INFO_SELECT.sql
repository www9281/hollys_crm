--------------------------------------------------------
--  DDL for Procedure RCH_LEVEL_INFO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_LEVEL_INFO_SELECT" (
    N_RCH_NO      IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-01
    -- Description   :   설문조사 정보 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      RCH_NO
      ,RCH_LV
      ,RCH_LV_CD
      ,RCH_LV_NO
      ,RCH_LV_TITLE
      ,RCH_LV_CONT
      ,RCH_LV_DIV
      ,RCH_LV_RPLY_TYPE
      ,RCH_LV_RPLY_PT
      ,RCH_LV_RPLY_TEXT
      ,RCH_LV_RPLY_CNT
    FROM RCH_LEVEL_INFO A 
    WHERE RCH_NO = N_RCH_NO
    ORDER BY RCH_NO
            ,RCH_LV
            ,RCH_LV_CD
            ,RCH_LV_NO
    ;
    
END RCH_LEVEL_INFO_SELECT;

/
