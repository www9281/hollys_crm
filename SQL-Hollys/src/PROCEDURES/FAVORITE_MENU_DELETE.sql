--------------------------------------------------------
--  DDL for Procedure FAVORITE_MENU_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."FAVORITE_MENU_DELETE" (
    P_MENU_CD     IN  VARCHAR2,
    P_MY_USER_ID  IN  VARCHAR2
)IS
BEGIN
    ----------------------- 즐겨찾기 메뉴 등록 -----------------------
    DELETE  FROM  W_MENU_FAVORITE
    WHERE   USER_ID  = P_MY_USER_ID
      AND   MENU_CD  = P_MENU_CD;

END FAVORITE_MENU_DELETE;

/
