--------------------------------------------------------
--  DDL for Procedure USER_AUTH_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."USER_AUTH_INSERT" (
        P_USER_ID         IN  VARCHAR2,
        P_BRAND_CD        IN  VARCHAR2,
        P_AUTH_LEVEL      IN  VARCHAR2,
        P_AUTH_DEPT_CD    IN  VARCHAR2,
        P_AUTH_TEAM_CD    IN  VARCHAR2,
        P_AUTH_STOR_TP    IN  VARCHAR2,
        P_AUTH_SV_USER_ID IN  VARCHAR2,
        P_AUTH_STOR_CD    IN  VARCHAR2,
        P_USE_YN          IN  CHAR,
        P_MY_USER_ID	    IN  VARCHAR2
)IS
BEGIN
        MERGE INTO USER_AUTH
        USING DUAL
        ON (
          USER_ID                = P_USER_ID
          AND BRAND_CD           = P_BRAND_CD
          AND AUTH_LEVEL         = P_AUTH_LEVEL
          AND AUTH_DEPT_CD       = P_AUTH_DEPT_CD
          AND AUTH_TEAM_CD       = P_AUTH_TEAM_CD
          AND AUTH_STOR_TP       = P_AUTH_STOR_TP
          AND AUTH_SV_USER_ID    = P_AUTH_SV_USER_ID
          AND AUTH_STOR_CD       = P_AUTH_STOR_CD
        )
        WHEN MATCHED THEN
          UPDATE SET
            UPD_DT      = SYSDATE,
            UPD_USER    = P_MY_USER_ID,
            USE_YN      = P_USE_YN
        WHEN NOT MATCHED THEN
          INSERT
          (
                USER_ID
                ,BRAND_CD
                ,AUTH_LEVEL
                ,AUTH_DEPT_CD
                ,AUTH_TEAM_CD
                ,AUTH_STOR_TP
                ,AUTH_SV_USER_ID
                ,AUTH_STOR_CD
                ,USE_YN
                ,INST_DT
                ,INST_USER
          ) VALUES (
                P_USER_ID
                ,P_BRAND_CD
                ,P_AUTH_LEVEL
                ,P_AUTH_DEPT_CD
                ,P_AUTH_TEAM_CD
                ,P_AUTH_STOR_TP
                ,P_AUTH_SV_USER_ID
                ,P_AUTH_STOR_CD
                ,'Y'
                ,SYSDATE
                ,P_MY_USER_ID
          );
        
END USER_AUTH_INSERT;

/
