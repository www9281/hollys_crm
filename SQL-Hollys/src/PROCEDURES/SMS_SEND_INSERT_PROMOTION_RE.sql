--------------------------------------------------------
--  DDL for Procedure SMS_SEND_INSERT_PROMOTION_RE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_INSERT_PROMOTION_RE" 
(
P_COUPON_CD IN VARCHAR2
, P_MY_USER_ID IN VARCHAR2
,O_SMS_SEND_ID OUT VARCHAR2
) IS
        L_SMS_SEND_ID     NUMBER;
        L_MSGKEY          NUMBER(11, 0);
        L_MSGKEY_BEFORE   NUMBER(11, 0);
        L_COUNT           NUMBER;
        L_YYYYMM          VARCHAR(6);
BEGIN
        SELECT  COUNT(*)
        INTO    L_COUNT
        FROM    SMS_SEND
        WHERE   IMAGE_URL LIKE '%'||P_COUPON_CD||'%';
        
        IF      L_COUNT > 0 THEN
        
                SELECT  SMS_SEND_ID,
                        TO_CHAR(INST_DT, 'YYYYMM')
                INTO    L_SMS_SEND_ID,
                        L_YYYYMM
                FROM    SMS_SEND
                WHERE   IMAGE_URL LIKE '%'||P_COUPON_CD||'%'
                AND     ROWNUM < 2;
                
                SELECT  SQ_SMS_SEND_ID.NEXTVAL,
                        MMS_MSG_SEQ.NEXTVAL
                INTO    O_SMS_SEND_ID,
                        L_MSGKEY
                FROM    DUAL;
                
                INSERT  INTO SMS_SEND
                SELECT  O_SMS_SEND_ID,
                        PRMT_ID,
                        CUST_GP_ID,
                        SMS_SENDER_ID,
                        STOR_CD,
                        SMS_TYPE,
                        SENDER_NUMBER,
                        SUBJECT,
                        CONTENT,
                        IMAGE_URL,
                        RESERVATION_DATE,
                        INST_USER,
                        INST_DT,
                        CUST_IMAGE_YN,
                        GIFTCARD_ID
                FROM    SMS_SEND
                WHERE   SMS_SEND_ID = L_SMS_SEND_ID
                AND     ROWNUM < 2;
                
                SELECT  MSGKEY
                INTO    L_MSGKEY_BEFORE
                FROM    SMS_SEND_CUST
                WHERE   SMS_SEND_ID = L_SMS_SEND_ID;
                
                INSERT  INTO  SMS_SEND_CUST (
                        SMS_SEND_ID,
                        CUST_ID,
                        TR_NUM,
                        MSGKEY
                )       VALUES              (
                        O_SMS_SEND_ID,
                        '99999999',
                        NULL,
                        L_MSGKEY
                );
                
                EXECUTE IMMEDIATE
                'INSERT  INTO  MMS_MSG (
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
                )
                SELECT  '||L_MSGKEY||',
                        SUBJECT, 
                        PHONE, 
                        CALLBACK, 
                        ''0'', 
                        SYSDATE, 
                        MSG, 
                        FILE_CNT,
                        FILE_PATH1, 
                        ''0''
                FROM    MMS_LOG_'|| L_YYYYMM || '
                WHERE   MSGKEY = '||L_MSGKEY_BEFORE||'';
                
        
        END IF;
        
END SMS_SEND_INSERT_PROMOTION_RE;

/
