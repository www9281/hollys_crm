--------------------------------------------------------
--  DDL for Procedure SMS_SEND_INSERT_GIFTCARD_RE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SMS_SEND_INSERT_GIFTCARD_RE" 
(
P_GIFTCARD_ID IN VARCHAR2
, P_PIN_NO IN VARCHAR2
, P_MY_USER_ID IN VARCHAR2
,O_SMS_SEND_ID OUT VARCHAR2
) IS
        L_SMS_SEND_ID     NUMBER;
        L_MSGKEY          NUMBER(11, 0);
        L_CUST_ID         VARCHAR2(20);
        L_MOBILE          VARCHAR2(20); 
        L_SENDER_NUMBER   VARCHAR2(20);
        L_IMAGE_URL       VARCHAR2(200);
        v_giftcard_his_seq VARCHAR2(11);
BEGIN
        SELECT  SQ_SMS_SEND_ID.NEXTVAL,
                MMS_MSG_SEQ.NEXTVAL
        INTO    O_SMS_SEND_ID,
                L_MSGKEY
        FROM    DUAL;
        
           
        SELECT 
            MAX(decrypt(RECEPTION_MOBILE)) INTO L_MOBILE
        FROM GIFTCARD_HIS 
        WHERE GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID) 
        AND  PIN_NO = P_PIN_NO
        ;
        
                
        SELECT  A.SMS_SEND_ID,
                A.SENDER_NUMBER,
                A.IMAGE_URL,
                B.CUST_ID
        INTO    L_SMS_SEND_ID,
                L_SENDER_NUMBER,
                L_IMAGE_URL,
                L_CUST_ID
        FROM    SMS_SEND A
        JOIN    SMS_SEND_CUST B
        ON      A.SMS_SEND_ID = B.SMS_SEND_ID
        JOIN    C_CUST C
        ON      B.CUST_ID = C.CUST_ID
        WHERE   A.GIFTCARD_ID = P_GIFTCARD_ID
        AND     ROWNUM = 1
        ORDER   BY
                SMS_SEND_ID;
        
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
        )
        SELECT  O_SMS_SEND_ID,
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
                P_MY_USER_ID,
                SYSDATE
        FROM    SMS_SEND
        WHERE   SMS_SEND_ID = L_SMS_SEND_ID;
        
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
                NULL, 
                L_MOBILE, 
                L_SENDER_NUMBER, 
                '0', 
                SYSDATE, 
                NULL, 
                '1', 
                L_IMAGE_URL, 
                '0'
        );
        
        INSERT  INTO  SMS_SEND_CUST (
                SMS_SEND_ID,
                CUST_ID,
                TR_NUM,
                MSGKEY
        )       VALUES              (
                O_SMS_SEND_ID,
                L_CUST_ID,
                NULL,
                L_MSGKEY
        );
        
        SELECT GIFTCARD_HIS_SEQ.NEXTVAL
        INTO v_giftcard_his_seq
        FROM DUAL;

        -- Giftcard 테이블 기록
        INSERT INTO GIFTCARD_HIS
        (       GIFTCARD_HIS_SEQ
                ,GIFTCARD_ID
                ,PIN_NO
                ,CARD_ID
                ,CUST_ID
                ,CUST_NM
                ,MOBILE 
                ,AMOUNT
                ,CREDIT_PAYMENT
                ,MOBILE_PAYMENT
                ,USE_PT
                ,TO_CUST_ID
                ,TO_CUST_NM
                ,RECEPTION_MOBILE
                ,BUY_DT
                ,CARD_STAT
                ,CANCEL_DT
                ,SEND_DT
                ,SEND_COUNT
                ,IS_RECHARGE
                ,SEND_MSG
                ,SEND_IMG
                ,PAYMENT_REQ
                ,INST_USER
                ,INST_DT
       )
       SELECT   A.* 
       FROM (
                   SELECT   v_giftcard_his_seq
                            ,GIFTCARD_ID
                            ,PIN_NO
                            ,CARD_ID
                            ,CUST_ID
                            ,CUST_NM
                            ,MOBILE
                            ,AMOUNT
                            ,CREDIT_PAYMENT
                            ,MOBILE_PAYMENT
                            ,USE_PT
                            ,TO_CUST_ID
                            ,TO_CUST_NM
                            ,RECEPTION_MOBILE
                            ,BUY_DT
                            ,'G0107'
                            ,''
                            ,SEND_DT
                            ,(CASE WHEN SEND_COUNT IS NOT NULL THEN TO_NUMBER(SEND_COUNT) +1
                                   ELSE 1
                              END
                            )
                            ,IS_RECHARGE
                            ,SEND_MSG
                            ,SEND_IMG
                            ,PAYMENT_REQ
                            ,P_MY_USER_ID
                            ,SYSDATE
                   FROM     GIFTCARD_HIS
                   WHERE    GIFTCARD_ID = ENCRYPT(P_GIFTCARD_ID)
                   AND      PIN_NO = P_PIN_NO
                   ORDER BY GIFTCARD_HIS_SEQ DESC
       )A 
       WHERE ROWNUM = 1;
        
END SMS_SEND_INSERT_GIFTCARD_RE;

/
