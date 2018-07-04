--------------------------------------------------------
--  DDL for Procedure STORE_GP_DT_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_DT_SAVE" (
    P_STOR_GP_ID    IN  VARCHAR2,
    P_STOR_CD       IN  VARCHAR2,
    P_USE_YN        IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 상세매장목록 저장
    -- Test          :   
    -- ==========================================================================================
    MERGE INTO STORE_GP_IN_STORE
    USING DUAL
    ON (STOR_GP_ID = P_STOR_GP_ID
        AND STOR_CD = P_STOR_CD)
    WHEN MATCHED THEN
      UPDATE SET
        USE_YN = P_USE_YN
        ,UPD_USER = P_MY_USER_ID
        ,UPD_DT = SYSDATE
    WHEN NOT MATCHED THEN
      INSERT (
        STOR_GP_ID
        ,STOR_CD
        ,USE_YN
        ,INST_USER
        ,INST_DT
        ,UPD_USER
        ,UPD_DT
      ) VALUES (
        P_STOR_GP_ID
        ,P_STOR_CD
        ,P_USE_YN
        ,P_MY_USER_ID
        ,SYSDATE
        ,P_MY_USER_ID
        ,SYSDATE
      )
    ;
    
    
END STORE_GP_DT_SAVE;

/
