--------------------------------------------------------
--  DDL for Procedure W_MENU_ADMIN_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_ADMIN_DELETE" (
    P_MENU_CD     IN VARCHAR2,
    P_MY_USER_ID	IN VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-23
    -- Description   :   관리자 메뉴관리 메뉴삭제
    -- ==========================================================================================
    
    DELETE FROM W_MENU
    WHERE MENU_CD = P_MENU_CD;
      
END W_MENU_ADMIN_DELETE;

/
