--------------------------------------------------------
--  DDL for Procedure RCH_DIV_CODE_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_DIV_CODE_SAVE" (
    N_DIV_CODE    IN  VARCHAR2,
    P_DIV_NM      IN  VARCHAR2,
    P_MY_USER_ID  IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 저장
    -- ==========================================================================================
    MERGE INTO RCH_DIV_CODE
    USING DUAL
    ON (
          DIV_CODE = N_DIV_CODE
    ) 
    WHEN MATCHED THEN
      UPDATE SET
        DIV_NM = P_DIV_NM
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT (
        DIV_CODE
        ,DIV_NM
        ,INST_DT
        ,INST_USER
      ) VALUES (
        SQ_RCP_DIV_CODE.NEXTVAL
        ,P_DIV_NM
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
END RCH_DIV_CODE_SAVE;

/
