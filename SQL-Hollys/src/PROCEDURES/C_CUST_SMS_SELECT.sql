--------------------------------------------------------
--  DDL for Procedure C_CUST_SMS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SMS_SELECT" 
(
    P_CUST_ID   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR FOR
        SELECT  A.SMS_SEND_ID,
                TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI') AS SEND_DATE,
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
                DECODE(A.SMS_TYPE, 'S', A.CONTENT, 'L', A.CONTENT, 'M', '멀티미디어 이미지', NULL) AS CONTENT,
                CASE  WHEN  E.TR_NUM IS NULL AND E.TR_NUM IS NULL
                      THEN  '수신'
                      ELSE  '미수신'
                END AS IS_SEND_NAME
        FROM    SMS_SEND A
        LEFT    OUTER JOIN    HQ_USER B
        ON      A.INST_USER = B.USER_ID
        LEFT    OUTER JOIN SMS_SENDER C
        ON      A.SMS_SENDER_ID = C.SMS_SENDER_ID
        LEFT    OUTER JOIN STORE D
        ON      A.STOR_CD = D.STOR_CD
        LEFT    OUTER JOIN SMS_SEND_CUST E
        ON      A.SMS_SEND_ID = E.SMS_SEND_ID
        WHERE   E.CUST_ID = P_CUST_ID
        ORDER BY A.INST_DT DESC;
END C_CUST_SMS_SELECT;

/
