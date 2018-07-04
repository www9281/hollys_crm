--------------------------------------------------------
--  DDL for Procedure SMS_SEND_INSERT_PROMOTION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_INSERT_PROMOTION" 
(
  P_PRMT_ID IN NUMBER 
, P_COUPON_CD IN VARCHAR2 
, N_CUST_ID IN VARCHAR2
, P_CUST_NM IN VARCHAR2
, P_MOBILE IN VARCHAR2
, N_IMAGE_PATH IN VARCHAR2
, P_MY_USER_ID IN VARCHAR2 
,O_SMS_SEND_ID OUT VARCHAR2
) IS
        L_SMS_SENDER_ID   NUMBER;
        L_SENDER_NUMBER   VARCHAR(20);
        L_SMS_TYPE        VARCHAR2(1);
        L_SUBJECT         VARCHAR2(80);
        L_CONTENT         VARCHAR2(2000);  
        L_TR_NUM          NUMBER(11, 0); 
        L_MSGKEY          NUMBER(11, 0);
BEGIN   
        SELECT  A.SMS_SENDER_ID,
                B.PHONE,
                A.SMS_TITLE,
                CASE  WHEN  A.SMS_CONTENTS IS NULL OR A.SMS_CONTENTS != ''
                      THEN  NULL
                      ELSE  REPLACE(A.SMS_CONTENTS, '{고객명}', P_CUST_NM)
                END AS CONTENTS,
                CASE  WHEN  N_IMAGE_PATH IS NOT NULL
                      THEN  'M'
                      ELSE  CASE  WHEN  LENGTH(A.SMS_CONTENTS) > 90
                                  THEN  'L'
                                  ELSE  'S'
                            END
                END AS SMS_TYPE
        INTO    L_SMS_SENDER_ID,
                L_SENDER_NUMBER,
                L_SUBJECT,
                L_CONTENT,
                L_SMS_TYPE
        FROM    PROMOTION_SMS A
        JOIN    SMS_SENDER B
        ON      A.SMS_SENDER_ID = B.SMS_SENDER_ID
        WHERE   A.PRMT_ID = P_PRMT_ID;
        
        SELECT  SQ_SMS_SEND_ID.NEXTVAL,
                CASE  WHEN  L_SMS_TYPE = 'S'
                      THEN  MMS_MSG_SEQ.NEXTVAL
                      ELSE  NULL
                END,
                CASE  WHEN  L_SMS_TYPE != 'S'
                      THEN  MMS_MSG_SEQ.NEXTVAL
                      ELSE  NULL
                END
        INTO    O_SMS_SEND_ID,
                L_TR_NUM,
                L_MSGKEY
        FROM    DUAL;
        
        INSERT  INTO  SMS_SEND  (
                SMS_SEND_ID,
                PRMT_ID,
                CUST_GP_ID,
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
                P_PRMT_ID,
                NULL,
                L_SMS_SENDER_ID,
                NULL,
                L_SMS_TYPE,
                L_SENDER_NUMBER,
                L_SUBJECT,
                L_CONTENT,
                N_IMAGE_PATH,
                NULL,
                NULL,
                P_MY_USER_ID,
                SYSDATE
        );
        
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
                        SYSDATE, 
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
                        L_SUBJECT, 
                        P_MOBILE, 
                        L_SENDER_NUMBER, 
                        '0', 
                        SYSDATE, 
                        L_CONTENT, 
                        --CASE  WHEN  N_IMAGE_PATH IS NOT NULL AND N_IMAGE_PATH != ''
                        CASE  WHEN  N_IMAGE_PATH IS NOT NULL
                              THEN  '1'
                              ELSE  '0'
                        END, 
                        N_IMAGE_PATH, 
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
                CASE  WHEN  N_CUST_ID IS NULL
                      THEN  '99999999'
                      ELSE  N_CUST_ID
                END,
                L_TR_NUM,
                L_MSGKEY
        );
        
END SMS_SEND_INSERT_PROMOTION;

/
