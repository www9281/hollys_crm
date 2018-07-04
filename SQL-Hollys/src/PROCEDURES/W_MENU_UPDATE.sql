--------------------------------------------------------
--  DDL for Procedure W_MENU_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_UPDATE" (
      P_MENU_CD     IN  NUMBER,
      P_MENU_NM     IN  VARCHAR2,
      P_MENU_DIV    IN  CHAR,
      N_PROG_NM     IN  VARCHAR2,
      N_MENU_TP     IN  CHAR,
      N_BRAND_CD    IN  VARCHAR2,
      N_STOR_TP     IN  VARCHAR2,
      P_USE_YN      IN  VARCHAR2,
      P_MY_USER_ID 	IN  VARCHAR2
)
IS
BEGIN 
      UPDATE W_MENU SET
            MENU_NM_KOR   =   P_MENU_NM
            ,PROG_NM      =   N_PROG_NM
            ,MENU_DIV     =   P_MENU_DIV
            ,PROG_TP      =   N_MENU_TP
            ,BRAND_CD     =   N_BRAND_CD
            ,STOR_TP      =   N_STOR_TP
            ,USE_YN       =   P_USE_YN
            ,UPD_USER_NO  =   P_MY_USER_ID
            ,UPD_DT       =   SYSDATE
      WHERE MENU_CD = P_MENU_CD;
END W_MENU_UPDATE;

/
