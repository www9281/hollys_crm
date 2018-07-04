--------------------------------------------------------
--  DDL for Procedure SMS_SENDER_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SENDER_DELETE" 
(
  P_SMS_SENDER_IDS IN VARCHAR2 
) IS 
    L_COLUMN            VARCHAR2(1)     := CHR(29); 
BEGIN
        DELETE  
        FROM  SMS_SENDER
        WHERE SMS_SENDER_ID IN  (
                                        SELECT  TRIM(REGEXP_SUBSTR(DATA, '[^' || L_COLUMN || ']+', 1, LEVEL)) AS SMS_SENDER_ID
                                        FROM    (SELECT P_SMS_SENDER_IDS AS DATA FROM DUAL)
                                        CONNECT BY  INSTR(DATA, L_COLUMN, 1, LEVEL - 1) > 0
        );
END SMS_SENDER_DELETE;

/
