--------------------------------------------------------
--  DDL for Procedure W_GROUP_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_SAVE" (
    N_GROUP_NO    IN  VARCHAR2,
    P_GROUP_NM    IN  VARCHAR2,
    P_USE_YN      IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-31
    -- Description   :   사용자 메뉴 그룹정보 저장
    -- Test          :   W_GROUP_SAVE (NULL, '그룹명', 'Y')
    -- ==========================================================================================
    
    MERGE INTO W_GROUP A
    USING DUAL
    ON (A.GROUP_NO = N_GROUP_NO)
    WHEN MATCHED THEN
      UPDATE SET
        GROUP_NM   = P_GROUP_NM
        ,USE_YN     = P_USE_YN
        ,UPT_DT     = SYSDATE
        ,UPT_USER   = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT
      (
        GROUP_NO
        ,GROUP_NM
        ,USE_YN
        ,INST_DT
        ,INST_USER 
      ) VALUES (
        SQ_GROUP_NO.nextval
        ,P_GROUP_NM
        ,P_USE_YN
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
END W_GROUP_SAVE;

/
