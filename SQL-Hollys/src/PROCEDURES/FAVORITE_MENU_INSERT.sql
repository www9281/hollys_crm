--------------------------------------------------------
--  DDL for Procedure FAVORITE_MENU_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."FAVORITE_MENU_INSERT" (
    P_MENU_CD     IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    ----------------------- 즐겨찾기 메뉴 등록 -----------------------
    MERGE INTO W_MENU_FAVORITE
    USING   DUAL
    ON  (
              USER_ID   = P_MY_USER_ID
          AND MENU_CD   = P_MENU_CD
            )
    WHEN  MATCHED  THEN
      UPDATE  SET  USE_YN     =  'Y'--:USE_YN
                   ,   UPD_DT     =  SYSDATE
                   ,   UPD_USER   =  P_MY_USER_ID
    WHEN  NOT MATCHED THEN
      INSERT(  USER_ID
              ,   MENU_CD
              ,   USE_YN
              ,   INST_DT
              ,   INST_USER
              ,   UPD_DT
              ,   UPD_USER
         )
      VALUES(
              P_MY_USER_ID
              , P_MENU_CD  
              , 'Y'
              ,  SYSDATE    
              ,  P_MY_USER_ID 
              ,  SYSDATE  
              ,  P_MY_USER_ID
         );
    
    OPEN O_CURSOR FOR
    SELECT 
      A.USER_ID
      ,A.MENU_CD
      ,(SELECT MENU_NM_KOR FROM W_MENU WHERE MENU_CD = A.MENU_CD) AS MENU_NM
    FROM W_MENU_FAVORITE A
    WHERE A.USER_ID   = P_MY_USER_ID
      AND A.MENU_CD   = P_MENU_CD
      AND A.USE_YN    = 'Y';
      
END FAVORITE_MENU_INSERT;

/
