--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_ERL_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_ERL_DELETE" (
   P_ERL_IDX      IN  VARCHAR2,
   P_MY_USER_ID   IN  VARCHAR2
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-22
    -- Description   :   아카데미 수강신청내역 삭제
    -- ==========================================================================================
    UPDATE C_ACADEMY_ERL SET
      USE_YN = 'N'
      ,UPD_DT = SYSDATE
      ,UPD_USER = P_MY_USER_ID
    WHERE ERL_IDX = P_ERL_IDX
    ;
    
END C_ACADEMY_ERL_DELETE;

/
