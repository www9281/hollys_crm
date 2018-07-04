--------------------------------------------------------
--  DDL for Procedure HQ_USER_BRAND_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_BRAND_SAVE" (
    P_USER_ID     IN  VARCHAR2,
    P_BRAND_CD    IN  VARCHAR2,
    P_USE_YN      IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-03
    -- Description   :   사용자 관리 브랜드 설정 저장
    -- Test          :   W_GROUP_SAVE ('level_10', '001', 'Y')
    -- ==========================================================================================
    
    MERGE INTO HQ_USER_BRAND A
    USING DUAL
    ON (A.USER_ID = P_USER_ID
        AND A.BRAND_CD = P_BRAND_CD)
    WHEN MATCHED THEN
      UPDATE SET
        USE_YN     = P_USE_YN
        ,UPD_DT     = SYSDATE
        ,UPD_USER   = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT
      (
        USER_ID
        ,BRAND_CD
        ,USE_YN
        ,INST_DT
        ,INST_USER 
      ) VALUES (
        P_USER_ID
        ,P_BRAND_CD
        ,'Y'
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
END HQ_USER_BRAND_SAVE;

/
