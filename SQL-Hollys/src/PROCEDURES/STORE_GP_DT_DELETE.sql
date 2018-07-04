--------------------------------------------------------
--  DDL for Procedure STORE_GP_DT_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_DT_DELETE" (
    P_STOR_GP_ID    IN  VARCHAR2,
    P_STOR_CD       IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 상세매장목록 삭제
    -- Test          :   
    -- ==========================================================================================
    DELETE FROM STORE_GP_IN_STORE
    WHERE STOR_GP_ID = P_STOR_GP_ID
      AND STOR_CD = P_STOR_CD
    ;
    
END STORE_GP_DT_DELETE;

/
