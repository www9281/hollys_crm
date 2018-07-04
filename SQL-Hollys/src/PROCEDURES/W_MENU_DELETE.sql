--------------------------------------------------------
--  DDL for Procedure W_MENU_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_DELETE" (
      P_MENU_CD     IN  NUMBER,
      P_MENU_DIV    IN  CHAR
)IS
BEGIN
            
      IF P_MENU_DIV = 'M' THEN
        -- 2뎁스 메뉴 조회
        FOR M_CURSOR IN (SELECT * FROM W_MENU WHERE MENU_REF = P_MENU_CD)
        LOOP
          -- 3뎁스 메뉴 삭제
          DELETE FROM W_MENU
          WHERE MENU_REF = M_CURSOR.MENU_CD;
        END LOOP;
        
        -- 2뎁스 메뉴 삭제
        DELETE FROM W_MENU
        WHERE MENU_REF = P_MENU_CD;
        
        -- 1뎁스 메뉴 삭제
        DELETE FROM W_MENU
        WHERE MENU_CD = P_MENU_CD;
        
      ELSIF P_MENU_DIV = 'L' THEN
        -- 3뎁스 메뉴 삭제
        DELETE FROM W_MENU
        WHERE MENU_REF = P_MENU_CD;
          
        -- 2뎁스 메뉴 삭제
        DELETE FROM W_MENU
        WHERE MENU_CD = P_MENU_CD;
      ELSIF P_MENU_DIV = 'C' THEN
        -- 3뎁스 메뉴 삭제
        DELETE FROM W_MENU
        WHERE MENU_CD = P_MENU_CD;
      END IF;
      
    
END W_MENU_DELETE;

/
