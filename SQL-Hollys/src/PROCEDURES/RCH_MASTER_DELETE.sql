--------------------------------------------------------
--  DDL for Procedure RCH_MASTER_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_MASTER_DELETE" (
    P_RCH_NO              IN VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 정보 제거
    -- ==========================================================================================
    
    -- 1. 설문조사에 할당된 문항목록 제거
    DELETE FROM RCH_LEVEL_INFO
    WHERE RCH_NO = P_RCH_NO;
     
    -- 2. 설문조사 메인정보 제거
    DELETE FROM RCH_MASTER
    WHERE RCH_NO = P_RCH_NO;
    
END RCH_MASTER_DELETE;

/
