--------------------------------------------------------
--  DDL for Procedure SMS_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_USER_SELECT" 
(
    P_USER_ID     IN  VARCHAR2,
    N_SENDER      IN  VARCHAR2,
    O_CURSOR_1    OUT SYS_REFCURSOR,
    O_CURSOR_2    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN O_CURSOR_1 FOR
        SELECT  A.SMS_SENDER_ID,
                A.SENDER_NAME,
                A.PHONE AS PHONE,
                CASE  WHEN  B.USER_ID IS NOT NULL
                      THEN    1
                      ELSE    0
                END AS IS_USE
        FROM    SMS_SENDER A
        LEFT OUTER JOIN    SMS_USER_SENDER B
        ON      A.SMS_SENDER_ID = B.SMS_SENDER_ID
        AND     B.USER_ID = P_USER_ID
        WHERE   (N_SENDER IS NULL OR N_SENDER = '' OR A.SENDER_NAME LIKE '%'||N_SENDER||'%');
        
        OPEN O_CURSOR_2 FOR
        SELECT  A.STOR_CD,
                A.STOR_NM,
                A.TEL_NO,
                CASE  WHEN  B.USER_ID IS NOT NULL
                      THEN    1
                      ELSE    0
                END AS IS_USE
        FROM    STORE A
        LEFT OUTER JOIN SMS_USER_STORE B
        ON      A.STOR_CD = B.STOR_CD
        AND     B.USER_ID = P_USER_ID
        WHERE   (N_SENDER IS NULL OR N_SENDER = '' OR A.STOR_NM LIKE '%'||N_SENDER||'%');
END SMS_USER_SELECT;

/
