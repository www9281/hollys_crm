--------------------------------------------------------
--  DDL for Procedure SMS_SENDER_SELECT_CODE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SENDER_SELECT_CODE" 
(
    P_MY_USER_ID IN VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN
        OPEN O_CURSOR FOR
        SELECT  X.*
        FROM    (
                        SELECT  0 AS IS_STORE,
                                CAST(A.SMS_SENDER_ID AS VARCHAR2(20)) AS SENDER_ID,
                                A.SENDER_NAME,
                                A.PHONE
                        FROM    SMS_SENDER A
                        JOIN    SMS_USER_SENDER B
                        ON      A.SMS_SENDER_ID = B.SMS_SENDER_ID
                        WHERE   A.USE_YN = 'Y'
                        AND     B.USER_ID = P_MY_USER_ID
                        UNION   ALL
                        SELECT  1 AS IS_STORE,
                                A.STOR_CD AS SENDER_ID,
                                A.STOR_NM AS SENDER_NAME,
                                A.TEL_NO AS PHONE
                        FROM    STORE A
                        JOIN    SMS_USER_STORE B
                        ON      A.STOR_CD = B.STOR_CD
                        WHERE   A.USE_YN = 'Y'
                        AND     B.USER_ID = P_MY_USER_ID
                ) X
        ORDER   BY
                X.IS_STORE,
                X.SENDER_NAME;
END SMS_SENDER_SELECT_CODE;

/
