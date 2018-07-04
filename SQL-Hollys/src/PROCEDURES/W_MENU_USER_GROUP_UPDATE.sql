--------------------------------------------------------
--  DDL for Procedure W_MENU_USER_GROUP_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_USER_GROUP_UPDATE" (
    P_USER_ID      IN  W_MENU_USER.USER_NO%TYPE,
    P_MENU_CD      IN  VARCHAR2,
    P_AUTH_CD      IN  VARCHAR2,
    P_STOR_CD      IN  NUMBER,
    P_BRAND_CD     IN  VARCHAR2,
    P_USER_USE_YN  IN  CHAR,
    P_MY_USER_ID 	IN  VARCHAR2
)
IS
    v_pgm_menu_grp varchar(2);
    v_menu_cnt     number;
BEGIN
    
    IF P_AUTH_CD = '90' THEN
      
      SELECT 
        PGM_MENU_GRP 
        INTO v_pgm_menu_grp
      FROM STORE 
      WHERE STOR_CD = P_STOR_CD;
       
      MERGE INTO W_MENU_GROUP A 
      USING DUAL
      ON (A.PGM_MENU_GRP = v_pgm_menu_grp AND A.MENU_CD = P_MENU_CD)
      WHEN MATCHED THEN 
        UPDATE SET
          USE_YN = P_USER_USE_YN
          ,UPD_DT = SYSDATE
          ,UPD_USER = P_MY_USER_ID
      WHEN NOT MATCHED THEN
        INSERT (
          PGM_MENU_GRP
          ,MENU_CD
          ,AUTHORITY
          ,USE_YN
          ,INST_DT
          ,INST_USER
        ) VALUES (
          v_pgm_menu_grp
          ,P_MENU_CD
          ,'C'
          ,'Y'
          ,SYSDATE
          ,P_MY_USER_ID
        )
      ;
          
    ELSE
      SELECT
        COUNT(*)
        INTO v_menu_cnt
      FROM W_MENU_USER
      WHERE USER_NO = P_USER_ID
        AND MENU_CD = P_MENU_CD;
      
      IF P_USER_USE_YN = 'Y' THEN
      
        MERGE INTO W_MENU_USER A
        USING DUAL
        ON (A.USER_NO = P_USER_ID AND A.MENU_CD = P_MENU_CD)
        WHEN NOT MATCHED THEN
          INSERT (
            USER_NO
            ,MENU_CD
            ,REG_DTE
            ,REG_EMP
          ) VALUES (
            P_USER_ID
            ,P_MENU_CD
            ,SYSDATE
            ,P_MY_USER_ID
          );
          
      ELSIF P_USER_USE_YN = 'N' THEN
        DELETE FROM W_MENU_USER
        WHERE USER_NO = P_USER_ID
        AND MENU_CD = P_MENU_CD;
      END IF;
        
    END IF;
    
END W_MENU_USER_GROUP_UPDATE;

/
