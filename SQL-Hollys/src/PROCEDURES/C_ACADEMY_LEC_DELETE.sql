--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_LEC_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_LEC_DELETE" (
   P_LEC_IDX  IN  VARCHAR2,
   P_MY_USER_ID  IN  VARCHAR2
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌 삭제 (강좌에 포함되어있는 클래스 정보 포함)
    -- ==========================================================================================
    
    -- 1. 강좌 삭제
    UPDATE C_ACADEMY_LEC SET
      USE_YN = 'N'
      , UPD_DT = SYSDATE
      , UPD_USER = P_MY_USER_ID
    WHERE LEC_IDX = P_LEC_IDX;
    
    -- 1. 클래스 삭제
    UPDATE C_ACADEMY_CLS SET
      USE_YN = 'N'
      , UPD_DT = SYSDATE
      , UPD_USER = P_MY_USER_ID
    WHERE LEC_IDX = P_LEC_IDX;
    
END C_ACADEMY_LEC_DELETE;

/
