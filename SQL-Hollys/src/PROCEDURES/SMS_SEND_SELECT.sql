--------------------------------------------------------
--  DDL for Procedure SMS_SEND_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_SELECT" 
(
  N_START_DT IN VARCHAR2 
, N_END_DT IN VARCHAR2 
, N_USER IN VARCHAR2 
, N_SENDER IN VARCHAR2 
, N_CONTENT IN VARCHAR2 
, N_SEND_YN IN VARCHAR2
, O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR FOR
        SELECT  A.SMS_SEND_ID,
                TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') AS INST_DT,
                B.USER_NM,
                CASE  WHEN  A.SMS_SENDER_ID IS NOT NULL
                      THEN  C.SENDER_NAME
                      ELSE  D.STOR_NM
                END AS SENDER_NAME,
                CASE  WHEN  A.SMS_SENDER_ID IS NOT NULL
                      THEN  C.PHONE
                      ELSE  D.TEL_NO
                END AS SENDER_PHONE,
                DECODE(A.SMS_TYPE, 'S', 'SMS', 'L', 'LMS', 'M', 'MMS', NULL) AS SMS_TYPE,
                DECODE(A.SMS_TYPE, 'S', A.CONTENT, 'L', A.CONTENT, 'M', '멀티미디어 이미지', NULL) AS CONTENT
        FROM    SMS_SEND A
        LEFT    OUTER JOIN    HQ_USER B
        ON      A.INST_USER = B.USER_ID
        LEFT    OUTER JOIN SMS_SENDER C
        ON      A.SMS_SENDER_ID = C.SMS_SENDER_ID
        LEFT    OUTER JOIN STORE D
        ON      A.STOR_CD = D.STOR_CD
        WHERE   (N_START_DT IS NULL OR N_START_DT = '' OR TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') >= N_START_DT)
        AND     (N_END_DT IS NULL OR N_END_DT = '' OR TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') <= N_END_DT)
        AND     (N_USER IS NULL OR N_USER = '' OR A.INST_USER LIKE '%'||N_USER||'%' OR B.USER_NM LIKE '%'||N_USER||'%')
        AND     (N_SENDER IS NULL OR N_SENDER = '' OR C.SENDER_NAME LIKE '%'||N_SENDER||'%' OR D.STOR_NM LIKE '%'||N_SENDER||'%' OR C.PHONE LIKE '%'||N_SENDER||'%' OR D.TEL_NO LIKE '%'||N_SENDER||'%')
        AND     (N_CONTENT IS NULL OR N_CONTENT = '' OR A.SUBJECT LIKE '%'|| N_CONTENT ||'%' OR A.CONTENT LIKE '%'|| N_CONTENT ||'%')
        AND     (N_SEND_YN IS NULL OR N_SEND_YN = ''  OR  (
                                                            N_SEND_YN = 'Y'   AND
                                                            NOT EXISTS  (
                                                                            SELECT  1
                                                                            FROM    SC_TRAN
                                                                            WHERE   TR_NUM  IN  (
                                                                                                    SELECT  TR_NUM
                                                                                                    FROM    SMS_SEND_CUST
                                                                                                    WHERE   SMS_SEND_ID = A.SMS_SEND_ID
                                                                                                )
                                                                        )   AND
                                                            NOT EXISTS  (
                                                                            SELECT  1
                                                                            FROM    MMS_MSG
                                                                            WHERE   MSGKEY  IN  (
                                                                                                    SELECT  MSGKEY
                                                                                                    FROM    SMS_SEND_CUST
                                                                                                    WHERE   SMS_SEND_ID = A.SMS_SEND_ID
                                                                                                )
                                                                        )
                                                          )
                                                      OR  (
                                                            N_SEND_YN = 'N'   AND
                                                            (
                                                                EXISTS  (
                                                                                SELECT  1
                                                                                FROM    SC_TRAN
                                                                                WHERE   TR_NUM  IN  (
                                                                                                        SELECT  TR_NUM
                                                                                                        FROM    SMS_SEND_CUST
                                                                                                        WHERE   SMS_SEND_ID = A.SMS_SEND_ID
                                                                                                    )
                                                                            )   OR
                                                                EXISTS  (
                                                                                SELECT  1
                                                                                FROM    MMS_MSG
                                                                                WHERE   MSGKEY  IN  (
                                                                                                        SELECT  MSGKEY
                                                                                                        FROM    SMS_SEND_CUST
                                                                                                        WHERE   SMS_SEND_ID = A.SMS_SEND_ID
                                                                                                    )
                                                                            )
                                                                )
                                                          )
                )
        ORDER   BY
                A.INST_DT DESC;
END SMS_SEND_SELECT;

/
