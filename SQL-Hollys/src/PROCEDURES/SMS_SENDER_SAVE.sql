--------------------------------------------------------
--  DDL for Procedure SMS_SENDER_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SENDER_SAVE" 
(
  N_SMS_SENDER_ID IN VARCHAR2 
, P_SENDER_NAME IN VARCHAR2 
, P_PHONE IN VARCHAR2 
, P_USE_YN IN VARCHAR2 
, N_REMARK IN VARCHAR2 
, P_MY_USER_ID IN VARCHAR2 
, O_SMS_SENDER_ID OUT VARCHAR2 
) AS 
BEGIN
        IF      N_SMS_SENDER_ID IS NULL OR N_SMS_SENDER_ID = '' THEN
                SELECT  SQ_SMS_SENDER_ID.NEXTVAL
                INTO    O_SMS_SENDER_ID
                FROM    DUAL;
                
                INSERT  INTO  SMS_SENDER    (
                        SMS_SENDER_ID,
                        SENDER_NAME,
                        PHONE,
                        USE_YN,
                        REMARK,
                        INST_USER,
                        INST_DT,
                        UDP_USER,
                        UDP_DT
                )       VALUES                (
                        O_SMS_SENDER_ID,
                        P_SENDER_NAME,
                        P_PHONE,
                        P_USE_YN,
                        N_REMARK,
                        P_MY_USER_ID,
                        SYSDATE,
                        NULL,
                        NULL
                );
        ELSE
                UPDATE  SMS_SENDER
                SET   SENDER_NAME   = P_SENDER_NAME,
                      PHONE         = P_PHONE,
                      USE_YN        = P_USE_YN,
                      REMARK        = N_REMARK,
                      UDP_USER      = P_MY_USER_ID,
                      UDP_DT        = SYSDATE
                WHERE SMS_SENDER_ID = N_SMS_SENDER_ID;
        END     IF;
END SMS_SENDER_SAVE;

/
