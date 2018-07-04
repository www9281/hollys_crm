--------------------------------------------------------
--  DDL for Procedure SMS_SEND_INSERT_MARKETING_GP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_INSERT_MARKETING_GP" 
(
  P_CUST_GP_ID        IN VARCHAR2 
, N_SMS_SENDER_ID     IN VARCHAR2 
, N_STOR_CD           IN VARCHAR2 
, N_SUBJECT           IN VARCHAR2 
, N_CONTENT           IN VARCHAR2 
, N_IMAGE_URL         IN VARCHAR2 
, N_CUST_IMAGE_YN     IN VARCHAR2 
, N_RESERVATION_DATE  IN VARCHAR2 
, P_MY_USER_ID        IN VARCHAR2 
, O_SMS_SEND_ID       OUT VARCHAR2 
) IS
        L_SMS_TYPE          VARCHAR2(1);
        L_SENDER_NUMBER     VARCHAR2(13);
        L_RESERVATION_DATE  DATE;
        CURSOR_CUST_ID      VARCHAR2(20);
        CURSOR_CUST_NM      VARCHAR2(20);
        CURSOR_MOBILE       VARCHAR2(20);
        L_TR_NUM            NUMBER(11, 0);
        L_MSGKEY            NUMBER(11, 0);
        L_CONTENT           VARCHAR(2000);
        L_IMAGE_URL         VARCHAR(200);
BEGIN
        IF      N_SMS_SENDER_ID IS NOT NULL     THEN
                SELECT  REPLACE(PHONE, '-', '')
                INTO    L_SENDER_NUMBER
                FROM    SMS_SENDER
                WHERE   SMS_SENDER_ID = N_SMS_SENDER_ID;
        ELSIF   N_STOR_CD IS NOT NULL           THEN
                SELECT  REPLACE(TEL_NO, '-', '')
                INTO    L_SENDER_NUMBER
                FROM    STORE
                WHERE   STOR_CD = N_STOR_CD;
        ELSE 
                RETURN;
        END     IF;
        
        IF      N_RESERVATION_DATE IS NOT NULL THEN
                L_RESERVATION_DATE := TO_DATE(N_RESERVATION_DATE, 'YYYY-MM-DD HH24:MI');
        ELSE    L_RESERVATION_DATE := SYSDATE;
        END     IF;
        
        IF      N_IMAGE_URL IS NOT NULL                       THEN
                L_SMS_TYPE := 'M';
        ELSIF   LENGTH(N_CONTENT) > 90                        THEN
                L_SMS_TYPE := 'L';
        ELSE    L_SMS_TYPE := 'S';
        END     IF;
        
        SELECT  SQ_SMS_SEND_ID.NEXTVAL
        INTO    O_SMS_SEND_ID
        FROM    DUAL;
        
        INSERT  INTO  SMS_SEND  (
                SMS_SEND_ID,
                PRMT_ID,
                CUST_GP_ID,
                GIFTCARD_ID,
                SMS_SENDER_ID,
                STOR_CD,
                SMS_TYPE,
                SENDER_NUMBER,
                SUBJECT,
                CONTENT,
                IMAGE_URL,
                CUST_IMAGE_YN,
                RESERVATION_DATE,
                INST_USER,
                INST_DT
        )       VALUES          (
                O_SMS_SEND_ID,
                NULL,
                P_CUST_GP_ID,
                NULL,
                N_SMS_SENDER_ID,
                N_STOR_CD,
                L_SMS_TYPE,
                L_SENDER_NUMBER,
                N_SUBJECT,
                N_CONTENT,
                N_IMAGE_URL,
                N_CUST_IMAGE_YN,
                CASE  WHEN  N_RESERVATION_DATE IS NOT NULL
                      THEN  L_RESERVATION_DATE
                      ELSE  NULL
                END,
                P_MY_USER_ID,
                SYSDATE
        );
        
        DECLARE CURSOR  CURSOR_CUST IS
        SELECT  A.CUST_ID,
                decrypt(B.CUST_NM) AS CUST_NM,
                decrypt(B.MOBILE) AS MOBILE
        INTO    CURSOR_CUST_ID,
                CURSOR_CUST_NM,
                CURSOR_MOBILE
        FROM    MARKETING_GP_CUST A
        JOIN    C_CUST B
        ON      A.CUST_ID = B.CUST_ID
        AND     A.CUST_GP_ID = P_CUST_GP_ID
        AND     B.SMS_RCV_YN = 'Y';
        
        BEGIN
                OPEN    CURSOR_CUST;
                
                LOOP
                        FETCH CURSOR_CUST
                        INTO  CURSOR_CUST_ID,
                              CURSOR_CUST_NM,
                              CURSOR_MOBILE;
                        EXIT  WHEN  CURSOR_CUST%NOTFOUND;
                        
                        
                        SELECT  CASE  WHEN  L_SMS_TYPE = 'S'
                                      THEN  MMS_MSG_SEQ.NEXTVAL
                                      ELSE  NULL
                                END,
                                CASE  WHEN  L_SMS_TYPE != 'S'
                                      THEN  MMS_MSG_SEQ.NEXTVAL
                                      ELSE  NULL
                                END,
                                CASE  WHEN  N_CONTENT IS NOT NULL AND N_CONTENT != ''
                                      THEN  REPLACE(N_CONTENT, '{고객명}', CURSOR_CUST_NM)
                                      ELSE  N_CONTENT
                                END,
                                CASE  WHEN  N_CUST_IMAGE_YN = 'Y' AND N_IMAGE_URL IS NOT NULL AND N_IMAGE_URL != ''
                                      THEN  REPLACE(N_IMAGE_URL, '.', '_'||CURSOR_CUST_ID||'.')
                                      ELSE  N_IMAGE_URL
                                END
                        INTO    L_TR_NUM,
                                L_MSGKEY,
                                L_CONTENT,
                                L_IMAGE_URL
                        FROM    DUAL;
                        
                        IF      L_SMS_TYPE = 'S'    THEN
                                INSERT  INTO  SC_TRAN (
                                        TR_NUM, 
                                        TR_SENDDATE, 
                                        TR_SENDSTAT, 
                                        TR_MSGTYPE, 
                                        TR_PHONE,
                                        TR_CALLBACK, 
                                        TR_MSG
                                )       VALUES        (
                                        L_TR_NUM, 
                                        L_RESERVATION_DATE, 
                                        '0', 
                                        '0', 
                                        CURSOR_MOBILE, 
                                        L_SENDER_NUMBER, 
                                        L_CONTENT
                                );
                        ELSE
                                INSERT  INTO  MMS_MSG (
                                        MSGKEY, 
                                        SUBJECT, 
                                        PHONE, 
                                        CALLBACK, 
                                        STATUS, 
                                        REQDATE, 
                                        MSG, 
                                        FILE_CNT,
                                        FILE_PATH1, 
                                        TYPE
                                )       VALUES        (
                                        L_MSGKEY,
                                        N_SUBJECT, 
                                        CURSOR_MOBILE, 
                                        L_SENDER_NUMBER, 
                                        '0', 
                                        L_RESERVATION_DATE, 
                                        L_CONTENT, 
                                        CASE  WHEN  L_IMAGE_URL IS NOT NULL AND L_IMAGE_URL != ''
                                              THEN  '1'
                                              ELSE  NULL
                                        END, 
                                        L_IMAGE_URL,  
                                        '0'
                                );
                        END     IF;
                        
                        INSERT  INTO  SMS_SEND_CUST (
                                SMS_SEND_ID,
                                CUST_ID,
                                TR_NUM,
                                MSGKEY
                        )       VALUES              (
                                O_SMS_SEND_ID,
                                CURSOR_CUST_ID,
                                L_TR_NUM,
                                L_MSGKEY
                        );
                    
                END LOOP;
        END;
        
        UPDATE  MARKETING_GP
        SET     SMS_SEND_YN = 'Y'
        WHERE   CUST_GP_ID = P_CUST_GP_ID;
        
        
END SMS_SEND_INSERT_MARKETING_GP;

/
