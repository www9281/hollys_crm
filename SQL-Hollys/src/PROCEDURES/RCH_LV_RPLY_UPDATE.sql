--------------------------------------------------------
--  DDL for Procedure RCH_LV_RPLY_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_LV_RPLY_UPDATE" (
    P_RCH_NO            IN VARCHAR2,
    P_RCH_LV            IN VARCHAR2,
    P_RCH_LV_CD         IN VARCHAR2,
    N_RCH_LV_NO         IN VARCHAR2,
    N_RCH_LV_TITLE      IN VARCHAR2,
    N_RCH_LV_CONT       IN VARCHAR2,
    N_RCH_LV_DIV        IN VARCHAR2,
    N_RCH_LV_RPLY_TYPE  IN VARCHAR2,
    N_RCH_LV_RPLY_PT    IN VARCHAR2,
    N_RCH_LV_RPLY_TEXT  IN VARCHAR2,
    N_RCH_LV_RPLY_CNT   IN VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 질의정보 저장 및 질의별 선택항목 저장
    -- ==========================================================================================

    UPDATE RCH_LEVEL_INFO SET
      RCH_LV_NO = N_RCH_LV_NO
      ,RCH_LV_TITLE = N_RCH_LV_TITLE
      ,RCH_LV_CONT = N_RCH_LV_CONT
      ,RCH_LV_DIV = N_RCH_LV_DIV
      ,RCH_LV_RPLY_TYPE = N_RCH_LV_RPLY_TYPE
      ,RCH_LV_RPLY_PT = N_RCH_LV_RPLY_PT
      ,RCH_LV_RPLY_TEXT = N_RCH_LV_RPLY_TEXT
      ,RCH_LV_RPLY_CNT = N_RCH_LV_RPLY_CNT
    WHERE RCH_NO = P_RCH_NO
      AND RCH_LV = P_RCH_LV
      AND RCH_LV_CD = P_RCH_LV_CD
    ;
    
END RCH_LV_RPLY_UPDATE;

/
