--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_CLS_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_CLS_DELETE" (
   P_LEC_IDX  IN  VARCHAR2,
   P_CLS_IDX  IN  VARCHAR2,
   P_MY_USER_ID  IN  VARCHAR2
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌의 클래스 목록 삭제
    -- ==========================================================================================
    UPDATE C_ACADEMY_CLS SET
      USE_YN = 'N'
      , UPD_DT = SYSDATE
      , UPD_USER = P_MY_USER_ID
    WHERE LEC_IDX = P_LEC_IDX
      AND CLS_IDX = P_CLS_IDX;
    
END C_ACADEMY_CLS_DELETE;

/
