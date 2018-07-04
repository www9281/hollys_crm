--------------------------------------------------------
--  DDL for Procedure SMS_SEND_CUST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_CUST_SELECT" 
(
      P_SMS_SEND_ID IN VARCHAR2,
      O_CURSOR      OUT SYS_REFCURSOR
) AS 
    L_SMS_TYPE  VARCHAR2(1);
    
BEGIN
        SELECT 
            SMS_TYPE INTO L_SMS_TYPE 
        FROM SMS_SEND WHERE SMS_SEND_ID = TO_NUMBER(P_SMS_SEND_ID)
        ;
        
        IF L_SMS_TYPE = 'S' THEN 
        
            OPEN    O_CURSOR FOR
            SELECT  A.CUST_ID,
                    decrypt(B.CUST_NM) AS CUST_NM,
                    FN_GET_FORMAT_HP_NO(decrypt(B.MOBILE)) AS MOBILE,
                    CASE  WHEN  C.TR_NUM IS NULL OR C.TR_NUM = ''
                          THEN  1
                          ELSE  0
                    END AS IS_SEND,
                    CASE  WHEN  C.TR_NUM IS NULL OR C.TR_NUM = ''
                          THEN  '수신'
                          ELSE  '미수신'
                    END AS IS_SEND_NAME
            FROM    SMS_SEND_CUST A
            LEFT    OUTER JOIN C_CUST B
            ON      A.CUST_ID = B.CUST_ID
            LEFT    OUTER JOIN SC_TRAN C
            ON      A.TR_NUM = C.TR_NUM
            WHERE   A.SMS_SEND_ID = TO_NUMBER(P_SMS_SEND_ID)
            ;
        
        ELSE
            
            OPEN    O_CURSOR FOR
            SELECT  A.CUST_ID,
                    decrypt(B.CUST_NM) AS CUST_NM,
                    FN_GET_FORMAT_HP_NO(decrypt(B.MOBILE)) AS MOBILE,
                    CASE  WHEN  D.MSGKEY IS NULL OR D.MSGKEY = ''
                          THEN  1
                          ELSE  0
                    END AS IS_SEND,
                    CASE  WHEN  D.MSGKEY IS NULL OR D.MSGKEY = ''
                          THEN  '수신'
                          ELSE  '미수신'
                    END AS IS_SEND_NAME
            FROM    SMS_SEND_CUST A
            LEFT    OUTER JOIN C_CUST B
            ON      A.CUST_ID = B.CUST_ID
            LEFT    OUTER JOIN MMS_MSG D
            ON      A.MSGKEY = D.MSGKEY
            WHERE   A.SMS_SEND_ID = TO_NUMBER(P_SMS_SEND_ID)
            ;
        
        END IF;
 

END SMS_SEND_CUST_SELECT;

/
