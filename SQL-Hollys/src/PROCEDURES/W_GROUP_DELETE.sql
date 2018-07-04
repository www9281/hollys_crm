--------------------------------------------------------
--  DDL for Procedure W_GROUP_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_DELETE" (
    P_GROUP_NO   IN VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-31
    -- Description   :   사용자 메뉴 그룹정보 삭제
    -- Test          :   W_GROUP_DELETE ('10')
    -- ==========================================================================================
    UPDATE W_GROUP SET
      USE_YN = 'N'
    WHERE GROUP_NO = P_GROUP_NO;
END W_GROUP_DELETE;

/
