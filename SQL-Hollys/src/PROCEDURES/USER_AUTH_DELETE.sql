--------------------------------------------------------
--  DDL for Procedure USER_AUTH_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."USER_AUTH_DELETE" (
        P_USER_ID         IN  VARCHAR2,
        P_BRAND_CD        IN  VARCHAR2,
        P_AUTH_LEVEL      IN  VARCHAR2,
        P_AUTH_DEPT_CD    IN  VARCHAR2,
        P_AUTH_TEAM_CD    IN  VARCHAR2,
        P_AUTH_STOR_TP    IN  VARCHAR2,
        P_AUTH_SV_USER_ID IN  VARCHAR2,
        P_AUTH_STOR_CD    IN  VARCHAR2,
        P_MY_USER_ID     	IN  VARCHAR2
)IS
BEGIN
        UPDATE USER_AUTH SET
          USE_YN       = 'N',
          UPD_DT       = SYSDATE,
          UPD_USER     = P_MY_USER_ID
        WHERE USER_ID            = P_USER_ID
          AND BRAND_CD           = P_BRAND_CD
          AND AUTH_LEVEL         = P_AUTH_LEVEL
          AND AUTH_DEPT_CD       = P_AUTH_DEPT_CD
          AND AUTH_TEAM_CD       = P_AUTH_TEAM_CD
          AND AUTH_STOR_TP       = P_AUTH_STOR_TP
          AND AUTH_SV_USER_ID    = P_AUTH_SV_USER_ID
          AND AUTH_STOR_CD       = P_AUTH_STOR_CD
        ;
END USER_AUTH_DELETE;

/
