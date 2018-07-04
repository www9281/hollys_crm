--------------------------------------------------------
--  DDL for Procedure STORE_GP_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_SAVE" (
    N_STOR_GP_ID    IN  VARCHAR2,
    P_STOR_GP_NM    IN  VARCHAR2,
    N_USE_YN        IN  VARCHAR2,
    N_REMARK        IN  VARCHAR2,
    P_BRAND_CD      IN  VARCHAR2,
    P_MY_USER_ID    IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-17
    -- Description   :   매장그룹관리 매장그룹 저장
    -- Test          :   
    -- ==========================================================================================
    MERGE INTO STORE_GP
    USING DUAL
    ON (STOR_GP_ID = N_STOR_GP_ID)
    WHEN MATCHED THEN
      UPDATE SET
        STOR_GP_NM = P_STOR_GP_NM
        ,REMARK = N_REMARK
        ,USE_YN = N_USE_YN
        ,UPD_USER = P_MY_USER_ID
        ,UPD_DT = SYSDATE
        ,BRAND_CD = P_BRAND_CD
      
    WHEN NOT MATCHED THEN
      INSERT (
        STOR_GP_ID
        ,STOR_GP_NM
        ,REMARK
        ,USE_YN
        ,INST_USER
        ,INST_DT
        ,BRAND_CD
      ) VALUES (
        LPAD(SQ_STORE_GP.NEXTVAL, 5, '0')
        ,P_STOR_GP_NM
        ,N_REMARK
        ,N_USE_YN
        ,P_MY_USER_ID
        ,SYSDATE
        ,P_BRAND_CD
      )
    ;
    
END STORE_GP_SAVE;

/
