--------------------------------------------------------
--  DDL for Procedure STORE_GP_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_DELETE" (
    N_STOR_GP_ID    IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 삭제
    -- Test          :   
    -- ==========================================================================================
    UPDATE STORE_GP SET
      USE_YN = 'N'
      ,UPD_USER = P_MY_USER_ID
      ,UPD_DT = SYSDATE
    WHERE STOR_GP_ID = N_STOR_GP_ID;
    
END STORE_GP_DELETE;

/
