--------------------------------------------------------
--  DDL for Procedure W_MENU_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_INSERT" (
      P_MENU_CD     IN  NUMBER,
      P_MENU_NM     IN  VARCHAR2,
      P_MENU_RF     IN  NUMBER,
      P_MENU_DIV    IN  CHAR,
      N_PROG_NM     IN  VARCHAR2,
      N_MENU_TP     IN  CHAR,
      N_BRAND_CD    IN  VARCHAR2,
      N_STOR_TP     IN  VARCHAR2,
      P_USE_YN      IN  VARCHAR2,
      P_MY_USER_ID 	IN  VARCHAR2
)  
IS
  menu_seq number;
BEGIN
      SELECT 
        NVL(MAX(MENU_CD)+1, 8000) 
        INTO menu_seq
      FROM W_MENU WHERE MENU_CD LIKE '8%';
      
      INSERT INTO W_MENU ( 
            MENU_CD
            ,MENU_NM_KOR
            --,MENU_NM_ENG
            --,MENU_NM_CHN
            --,MENU_NM_FRN
            ,PROG_NM
            ,MENU_REF
            ,MENU_IDX
            ,MENU_DIV
            ,PROG_TP
            ,BRAND_CD
            ,STOR_TP
            ,USE_YN
            ,INS_USER_NO
            ,INS_DT
      ) VALUES (
            menu_seq
            , P_MENU_NM
            , N_PROG_NM
            , P_MENU_RF
            , (SELECT NVL(MAX(MENU_IDX)+1, 0) FROM W_MENU WHERE MENU_REF = P_MENU_RF)
            , P_MENU_DIV
            , N_MENU_TP
            , N_BRAND_CD
            , N_STOR_TP
            , P_USE_YN
            , P_MY_USER_ID
            , SYSDATE
      );
    
END W_MENU_INSERT;

/
