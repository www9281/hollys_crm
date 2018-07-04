--------------------------------------------------------
--  DDL for Procedure SMS_INDIVI_SEND
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_INDIVI_SEND" 
(
      P_MOBILE            IN VARCHAR2
    , N_CUST_NM           IN VARCHAR2
    , N_CUST_ID           IN VARCHAR2  
    , N_SMS_SENDER_ID     IN VARCHAR2 
    , N_SUBJECT           IN VARCHAR2 
    , N_CONTENT           IN VARCHAR2 
    , N_IMAGE_URL         IN VARCHAR2 
    , N_CUST_IMAGE_YN     IN VARCHAR2 
    , N_RESERVATION_DATE  IN VARCHAR2 
    , P_USER_ID           IN VARCHAR2
    , O_RTN_CD           OUT VARCHAR2 
) IS
    L_SMS_TYPE          VARCHAR2(1);
    L_SENDER_NUMBER     VARCHAR2(13);
    L_RESERVATION_DATE  DATE;
          
    L_TR_NUM            NUMBER(11, 0);
    L_MSGKEY            NUMBER(11, 0);
    L_CONTENT           VARCHAR(2000);
    L_IMAGE_URL         VARCHAR(200);
    L_SMS_SEND_ID       NUMBER;
        
BEGIN

    IF      N_SMS_SENDER_ID IS NOT NULL     THEN
            SELECT  REPLACE(PHONE, '-', '')
            INTO    L_SENDER_NUMBER
            FROM    SMS_SENDER
            WHERE   SMS_SENDER_ID = N_SMS_SENDER_ID;
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
            
 
    SELECT  SQ_SMS_SEND_ID.NEXTVAL,
            CASE  WHEN  L_SMS_TYPE = 'S'
                  THEN  MMS_MSG_SEQ.NEXTVAL
                  ELSE  NULL
            END,
            CASE  WHEN  L_SMS_TYPE != 'S'
                  THEN  MMS_MSG_SEQ.NEXTVAL
                  ELSE  NULL
            END
    INTO    L_SMS_SEND_ID,
            L_TR_NUM,
            L_MSGKEY
    FROM    DUAL;
    
       
    
    
    BEGIN        
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
        ) VALUES (
                L_SMS_SEND_ID,
                NULL,
                NULL,
                NULL,
                N_SMS_SENDER_ID,
                NULL,
                L_SMS_TYPE,
                L_SENDER_NUMBER,
                N_SUBJECT,
                N_CONTENT,
                N_IMAGE_URL,
                NULL,
                CASE  WHEN  N_RESERVATION_DATE IS NOT NULL
                      THEN  L_RESERVATION_DATE
                      ELSE  NULL
                END,
                P_USER_ID,
                SYSDATE
        );
    EXCEPTION
        WHEN OTHERS THEN
            O_RTN_CD  := '2';
            dbms_output.put_line('1XX========' || SQLERRM );
            ROLLBACK;
            RETURN;
    END;        
            
    BEGIN                   
                                    
        SELECT  CASE  WHEN  L_SMS_TYPE = 'S'
                      THEN  MMS_MSG_SEQ.NEXTVAL
                      ELSE  NULL
                END,
                CASE  WHEN  L_SMS_TYPE != 'S'
                      THEN  MMS_MSG_SEQ.NEXTVAL
                      ELSE  NULL
                END,
                CASE  WHEN  N_CONTENT IS NOT NULL AND N_CONTENT != ''
                      THEN  REPLACE(N_CONTENT, '{고객명}', N_CUST_NM)
                      ELSE  N_CONTENT
                END,
                CASE  WHEN  N_CUST_IMAGE_YN = 'Y' AND N_IMAGE_URL IS NOT NULL AND N_IMAGE_URL != ''
                      THEN  REPLACE(N_IMAGE_URL, '.', '_'||N_CUST_ID||'.')
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
                        P_MOBILE, 
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
                        P_MOBILE, 
                        L_SENDER_NUMBER, 
                        '0', 
                        L_RESERVATION_DATE, 
                        L_CONTENT, 
                        CASE  WHEN  LENGTH(L_IMAGE_URL) > 0 
                              THEN  1
                              ELSE  0
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
                L_SMS_SEND_ID,
                NVL(P_USER_ID, 'SMS_INDIVI'),
                L_TR_NUM,
                L_MSGKEY
        );   
                  
    
    EXCEPTION
        WHEN OTHERS THEN
            O_RTN_CD  := '2';
            dbms_output.put_line('2========' || SQLERRM );
            ROLLBACK;
            RETURN;
    END;
    
    O_RTN_CD := '1';
    dbms_output.put_line('3========>' || O_RTN_CD );
        
    EXCEPTION
        WHEN OTHERS THEN
            O_RTN_CD  := '2';
            dbms_output.put_line('4========' || SQLERRM );
            ROLLBACK;
            
END SMS_INDIVI_SEND;

/
