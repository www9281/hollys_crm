--------------------------------------------------------
--  DDL for Procedure W_MENU_FAVORITE_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_FAVORITE_INSERT" (
        P_BRAND_CD    IN  VARCHAR2,
        P_STOR_CD     IN  VARCHAR2,
        P_USER_ID     IN  VARCHAR2,
        P_MENU_CD     IN  NUMBER,
        P_MY_USER_ID 	IN  VARCHAR2
)IS
BEGIN
        MERGE INTO W_MENU_FAVORITE A
        USING DUAL ON (
            A.BRAND_CD  = P_BRAND_CD
            AND A.STOR_CD   = P_STOR_CD
            AND A.USER_ID   = P_USER_ID
            AND A.MENU_CD   = P_MENU_CD
        )
        WHEN MATCHED THEN
            UPDATE SET
              UPD_DT   = SYSDATE
              ,UPD_USER    = P_MY_USER_ID
              ,USE_YN        = 'Y'
        WHEN NOT MATCHED THEN
            INSERT (
              BRAND_CD
              ,STOR_CD
              ,USER_ID
              ,MENU_CD
              ,USE_YN
              ,INST_DT
              ,INST_USER
            ) VALUES (
              P_BRAND_CD
              ,P_STOR_CD
              ,P_USER_ID
              ,P_MENU_CD
              ,'Y'
              ,SYSDATE
              ,P_MY_USER_ID
            )
        ;
END W_MENU_FAVORITE_INSERT;

/
