--------------------------------------------------------
--  DDL for Procedure W_MENU_FAVORITE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_FAVORITE_DELETE" (
        P_BRAND_CD    IN  VARCHAR2,
        P_STOR_CD     IN  VARCHAR2,
        P_USER_ID     IN  VARCHAR2,
        P_MENU_CD     IN  NUMBER,
        P_MY_USER_ID 	IN  VARCHAR2
)IS
BEGIN
        UPDATE W_MENU_FAVORITE SET
            UPD_DT        = SYSDATE
            ,UPD_USER     = P_MY_USER_ID
            ,USE_YN       = 'N'
        WHERE BRAND_CD  = P_BRAND_CD
          AND STOR_CD   = P_STOR_CD
          AND USER_ID   = P_USER_ID
          AND MENU_CD   = P_MENU_CD
        ;
END W_MENU_FAVORITE_DELETE;

/
