--------------------------------------------------------
--  DDL for Procedure W_GROUP_MENU_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_MENU_SAVE" (
    P_GROUP_NO    IN  VARCHAR2,
    P_MENU_CD     IN  VARCHAR2,
    P_USE_YN      IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-01
    -- Description   :   사용자 메뉴 그룹별 메뉴저장
    -- Test          :   W_GROUP_MENU_SAVE ('10', '1111', 'Y')
    -- ==========================================================================================
    
    MERGE INTO W_GROUP_MENU A
    USING DUAL
    ON (
          A.GROUP_NO = P_GROUP_NO
          AND A.MENU_CD = P_MENU_CD
        )
    WHEN MATCHED THEN
      UPDATE SET
        USE_YN     = P_USE_YN
        ,UPT_DT     = SYSDATE
        ,UPT_USER   = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT
      (
        MENU_CD
        ,GROUP_NO
        ,USE_YN
        ,INST_DT
        ,INST_USER
      ) VALUES (
        P_MENU_CD
        ,P_GROUP_NO
        ,P_USE_YN
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
END W_GROUP_MENU_SAVE;

/
