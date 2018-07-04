--------------------------------------------------------
--  DDL for Procedure W_MENU_FAVORITE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_FAVORITE_SELECT" (
        P_BRAND_CD  IN  VARCHAR2,
        P_STOR_CD   IN  VARCHAR2,
        P_USER_ID   IN  VARCHAR2,
        P_MENU_CD   IN  NUMBER,
        O_CURSOR    OUT SYS_REFCURSOR
)IS
BEGIN
        OPEN O_CURSOR FOR
        SELECT
              BRAND_CD
              ,STOR_CD
              ,USER_ID
              ,MENU_CD
        FROM W_MENU_FAVORITE
        WHERE BRAND_CD  = P_BRAND_CD
          AND STOR_CD   = P_STOR_CD
          AND USER_ID   = P_USER_ID
          AND MENU_CD   = P_MENU_CD
          AND USE_YN    = 'Y'
        ;
END W_MENU_FAVORITE_SELECT;

/
