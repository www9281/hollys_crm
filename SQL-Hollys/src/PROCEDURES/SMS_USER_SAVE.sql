--------------------------------------------------------
--  DDL for Procedure SMS_USER_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_USER_SAVE" 
(
  P_USER_ID IN VARCHAR2 
, N_SMS_SENDER_IDS IN VARCHAR2 
, N_STOR_CDS IN VARCHAR2 
, P_MY_USER_ID IN VARCHAR2 
) IS 
    L_COLUMN            VARCHAR2(1)     := CHR(29); 
BEGIN
        DELETE
        FROM    SMS_USER_SENDER
        WHERE   USER_ID = P_USER_ID;
        
        DELETE
        FROM    SMS_USER_STORE
        WHERE   USER_ID = P_USER_ID;
        
        IF      LENGTH(N_SMS_SENDER_IDS) > 0  THEN
                INSERT  INTO  SMS_USER_SENDER (
                        USER_ID,
                        SMS_SENDER_ID,
                        INST_USER,
                        INST_DT
                )
                SELECT  P_USER_ID,
                        TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL)) AS SMS_SENDER_ID,
                        P_MY_USER_ID,
                        SYSDATE
                FROM    (SELECT N_SMS_SENDER_IDS AS DATA FROM DUAL)
                CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0;
        END IF;
        
        IF      LENGTH(N_STOR_CDS) > 0  THEN
                INSERT  INTO  SMS_USER_STORE (
                        USER_ID,
                        STOR_CD,
                        INST_USER,
                        INST_DT
                )
                SELECT  P_USER_ID,
                        TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL)) AS STOR_CD,
                        P_MY_USER_ID,
                        SYSDATE
                FROM    (SELECT N_STOR_CDS AS DATA FROM DUAL)
                CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0;
        END IF;
        
        
END SMS_USER_SAVE;

/
