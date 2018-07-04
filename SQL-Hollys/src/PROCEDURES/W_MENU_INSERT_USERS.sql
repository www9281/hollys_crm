--------------------------------------------------------
--  DDL for Procedure W_MENU_INSERT_USERS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_INSERT_USERS" (
        P_MENU_CD	        IN    NUMBER,
        N_MENU_NM_KOR	    IN    VARCHAR2,
        N_MENU_NM_ENG	    IN    VARCHAR2,
        N_MENU_NM_CHN	    IN    VARCHAR2,
        N_MENU_NM_FRN	    IN    VARCHAR2,
        N_PROG_NM	        IN    VARCHAR2,
        N_MENU_REF	      IN    NUMBER,
        N_MENU_IDX	      IN    NUMBER,
        N_MENU_DIV	      IN    CHAR,
        N_PROG_TP	        IN    CHAR,
        N_BRAND_CD	      IN    VARCHAR2,
        N_STOR_TP	        IN    VARCHAR2,
        P_USE_YN	        IN    CHAR,
        P_MY_USER_ID     	IN    VARCHAR2,           -- 토큰 인증시 자동으로 넣어준다.
        P_DATA            IN    VARCHAR2
) IS 
        L_ROW         CHAR(1)   := CHR(28);
        L_COLUMN      CHAR(1)   := CHR(29);
        PRAGMA    AUTONOMOUS_TRANSACTION;
BEGIN
        INSERT    INTO    W_MENU   (
                  MENU_CD,
                  MENU_NM_KOR,
                  MENU_NM_ENG,
                  MENU_NM_CHN,
                  MENU_NM_FRN,
                  PROG_NM,
                  MENU_REF,
                  MENU_IDX,
                  MENU_DIV,
                  PROG_TP,
                  BRAND_CD,
                  STOR_TP,
                  USE_YN,
                  INS_USER_NO,
                  INS_DT,
                  UPD_USER_NO,
                  UPD_DT
        )         VALUES (
                  P_MENU_CD,
                  N_MENU_NM_KOR,
                  N_MENU_NM_ENG,
                  N_MENU_NM_CHN,
                  N_MENU_NM_FRN,
                  N_PROG_NM,
                  N_MENU_REF,
                  N_MENU_IDX,
                  N_MENU_DIV,
                  N_PROG_TP,
                  N_BRAND_CD,
                  N_STOR_TP,
                  P_USE_YN,
                  P_MY_USER_ID,
                  SYSDATE,
                  NULL, 
                  NULL
        );
        
        INSERT    INTO    W_MENU_USER  (
                  USER_NO,
                  MENU_CD,
                  REG_DTE,
                  REG_EMP,
                  CHG_DTE,
                  CHG_EMP
        )
        SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_ROW || ']+', 1, LEVEL)) AS USER_ID,
                P_MENU_CD,
                SYSDATE,
                P_MY_USER_ID,
                NULL,
                NULL
        FROM    (SELECT P_DATA AS DATA FROM DUAL)
        CONNECT BY  INSTR(DATA, L_ROW, 1, LEVEL - 1) > 0;
        
        COMMIT;
END W_MENU_INSERT_USERS;

/
