--------------------------------------------------------
--  DDL for Procedure W_GROUP_USER_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_USER_SAVE" (
    P_USER_ID     IN  VARCHAR2,
    P_GROUP_NO    IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-01
    -- Description   :   사용자 그룹정보 수정
    -- Test          :   W_GROUP_USER_SAVE ('level_10', '4')
    -- ==========================================================================================
    
    UPDATE HQ_USER SET
      GROUP_NO = P_GROUP_NO
    WHERE USER_ID = P_USER_ID;
    
END W_GROUP_USER_SAVE;

/
