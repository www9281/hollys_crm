--------------------------------------------------------
--  DDL for Procedure SMS_SENDER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SENDER_SELECT" 
(
    N_SENDER    IN  VARCHAR2,
    N_USE_YN    IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN O_CURSOR FOR
        SELECT  SMS_SENDER_ID,
                SENDER_NAME,
                PHONE,
                USE_YN,
                REMARK,
                INST_USER,
                TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT
        FROM    SMS_SENDER
        WHERE   (N_SENDER IS NULL OR N_SENDER = '' OR SENDER_NAME LIKE '%'||N_SENDER||'%' OR PHONE LIKE '%'||N_SENDER||'%')
        AND     (N_USE_YN IS NULL OR N_USE_YN = '' OR USE_YN = N_USE_YN)
        ORDER   BY SENDER_NAME;
END SMS_SENDER_SELECT;

/
