--------------------------------------------------------
--  DDL for Procedure PROMOTION_SEND_SMS_PUBLISH
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_SEND_SMS_PUBLISH" 
(
      P_PRMT_ID           IN VARCHAR2
    , P_GUBUN             IN VARCHAR2  -- 그룹 OR 아이디
    , P_PUBLISH_LIST      IN VARCHAR2 -- 그룹 OR 아이디 리스트
    , P_MY_USER_ID        IN VARCHAR2   -- 전송자
    , N_STOR_CD           IN VARCHAR2   
    , O_RTN_CD            OUT VARCHAR2 
) IS
      L_SMS_TYPE          VARCHAR2(1);
      L_IMAGE_URL         VARCHAR(200);
      L_CONTENTS          VARCHAR(2000);
      L_SEQ               NUMBER(11, 0);
      
      L_SMS_SEND_ID       NUMBER;
      
      NOT_FOUND           EXCEPTION;
        
BEGIN 

        SELECT 
              CASE WHEN S.FOLDER IS NULL THEN NULL 
                   ELSE S.FOLDER || S.FILE_NAME
              END
                 , P.SMS_CONTENTS 
            INTO   L_IMAGE_URL 
                 , L_CONTENTS
        FROM     PROMOTION_SMS P, (SELECT TO_NUMBER(MAX(REF_ID)) AS REF_ID , MAX(FOLDER) AS FOLDER , MAX(FILE_NAME) AS FILE_NAME 
                                   FROM SY_CONTENT_FILE WHERE REF_ID = P_PRMT_ID) S
        WHERE    P.PRMT_ID = S.REF_ID (+)
        AND      P.PRMT_ID = P_PRMT_ID
        ;
            
                    
        IF L_CONTENTS IS NULL OR L_CONTENTS = '' THEN
          RAISE NOT_FOUND; 
        END IF;
      

        IF      L_IMAGE_URL IS NOT NULL  OR  L_IMAGE_URL <> ''    THEN
                L_SMS_TYPE := 'M';
        ELSE
            SELECT  
                CASE WHEN LENGTHB(CONVERT(REPLACE(L_CONTENTS, '@$', CHR(13)||CHR(10)),'KO16KSC5601')) > 90 THEN 'L'
                     ELSE 'S'
                END INTO L_SMS_TYPE
          FROM  DUAL;        
        END     IF;
        
         
        SELECT  SQ_SMS_SEND_ID.NEXTVAL
        INTO    L_SMS_SEND_ID
        FROM    DUAL;
        
        
        INSERT  INTO  SMS_SEND  (
                SMS_SEND_ID
              , PRMT_ID
              , CUST_GP_ID
              , GIFTCARD_ID
              , SMS_SENDER_ID
              , STOR_CD
              , SMS_TYPE
              , SENDER_NUMBER
              , SUBJECT
              , CONTENT
              , IMAGE_URL
              , CUST_IMAGE_YN
              , RESERVATION_DATE
              , INST_USER
              , INST_DT
        )
        SELECT  
                L_SMS_SEND_ID     AS SMS_SEND_ID
              , S.PRMT_ID         AS PRMT_ID
              , NULL              AS CUST_GP_ID
              , NULL              AS GIFTCARD_ID
              , S.SMS_SENDER_ID   AS SMS_SENDER_ID 
              , N_STOR_CD         AS STOR_CD 
              , L_SMS_TYPE        AS SMS_TYPE
              , (SELECT PHONE FROM SMS_SENDER WHERE SMS_SENDER_ID = S.SMS_SENDER_ID) AS SENDER_NUMBER
              , S.SMS_TITLE       AS SUBJECT
              , S.SMS_CONTENTS    AS CONTENT
              , L_IMAGE_URL       AS IMAGE_URL
              , S.CUST_IMAGE_YN
              , SYSDATE
              , P_MY_USER_ID
              , SYSDATE
        FROM    PROMOTION_SMS S, (SELECT TO_NUMBER(MAX(REF_ID)) AS REF_ID , MAX(FOLDER) AS FOLDER , MAX(FILE_NAME) AS FILE_NAME 
                                   FROM SY_CONTENT_FILE WHERE REF_ID = P_PRMT_ID) F
        WHERE   S.PRMT_ID = F.REF_ID (+)
        AND     S.PRMT_ID = P_PRMT_ID
        ;
        
        --------------------------------------------
        IF P_GUBUN = 'G' THEN
        
            IF L_SMS_TYPE = 'S' THEN
            dbms_output.put_line(L_SMS_SEND_ID||'--------------->31') ;
            
                INSERT ALL  
                INTO  SC_TRAN (
                       TR_NUM 
                     , TR_SENDDATE 
                     , TR_SENDSTAT 
                     , TR_MSGTYPE 
                     , TR_PHONE
                     , TR_CALLBACK 
                     , TR_MSG
                )VALUES(
                       MMS_MSG_SEQ.NEXTVAL
                     , X_TR_SENDDATE
                     , X_TR_SENDSTAT
                     , X_TR_MSGTYPE
                     , X_TR_PHONE 
                     , X_TR_CALLBACK
                     , X_TR_MSG
                )
                INTO  SMS_SEND_CUST (
                       SMS_SEND_ID
                     , CUST_ID
                     , TR_NUM
                     , MSGKEY
                )VALUES(
                       X_SMS_SEND_ID
                     , X_CUST_ID
                     , MMS_MSG_SEQ.NEXTVAL
                     , NULL
                )            
                SELECT DISTINCT 
                       L_SMS_SEND_ID       AS X_SMS_SEND_ID
                     , SYSDATE             AS X_TR_SENDDATE
                     , '0'                 AS X_TR_SENDSTAT
                     , '0'                 AS X_TR_MSGTYPE
                     , DECRYPT(U.MOBILE)   AS X_TR_PHONE 
                     , U.CUST_ID           AS X_CUST_ID 
                     , ( SELECT PHONE FROM SMS_SENDER WHERE SMS_SENDER_ID = S.SMS_SENDER_ID) AS  X_TR_CALLBACK
                     , REPLACE(S.SMS_CONTENTS, '{고객명}', DECRYPT(U.CUST_NM))               AS  X_TR_MSG
                FROM   PROMOTION_COUPON C,   PROMOTION_COUPON_PUBLISH P , PROMOTION_SMS S , C_CUST U
                WHERE  C.PUBLISH_ID = P.PUBLISH_ID
                AND    P.PRMT_ID = S.PRMT_ID
                AND    P.PRMT_ID = P_PRMT_ID
                AND    C.CUST_ID = U.CUST_ID
                AND    P.PUBLISH_ID IN( SELECT TO_NUMBER(REGEXP_SUBSTR(P_PUBLISH_LIST,'[^,]+', 1, LEVEL)) FROM DUAL
                                        CONNECT BY REGEXP_SUBSTR(P_PUBLISH_LIST, '[^,]+', 1, LEVEL) IS NOT NULL  )
                AND    U.SMS_RCV_YN = 'Y'
                AND    U.MOBILE IS NOT NULL
            ;
            
            ELSE
                INSERT ALL
                INTO  MMS_MSG (
                       MSGKEY 
                     , SUBJECT 
                     , PHONE 
                     , CALLBACK 
                     , STATUS 
                     , REQDATE 
                     , MSG 
                     , FILE_CNT
                     , FILE_PATH1 
                     , TYPE
                )VALUES(
                       MMS_MSG_SEQ.NEXTVAL 
                     , X_SMS_TITLE 
                     , X_PHONE 
                     , X_CALLBACK 
                     , X_STATUS
                     , X_REQDATE 
                     , X_MSG 
                     , X_FILE_CNT
                     , X_FILE_PATH1 
                     , X_TYPE
                )
                INTO  SMS_SEND_CUST (
                       SMS_SEND_ID
                     , CUST_ID
                     , TR_NUM
                     , MSGKEY
                )VALUES(
                       X_SMS_SEND_ID
                     , X_CUST_ID
                     , NULL
                     , MMS_MSG_SEQ.NEXTVAL
                )   
                SELECT  DISTINCT
                        L_SMS_SEND_ID      AS X_SMS_SEND_ID
                     , S.SMS_TITLE         AS X_SMS_TITLE
                     , DECRYPT(U.MOBILE)   AS X_PHONE
                     , SYSDATE             AS X_TR_SENDDATE
                     , '0'                 AS X_TR_SENDSTAT
                     , '0'                 AS X_TR_MSGTYPE
                     , ( SELECT PHONE FROM SMS_SENDER WHERE SMS_SENDER_ID = S.SMS_SENDER_ID) AS  X_CALLBACK
                     , '0'                 AS X_STATUS
                     , SYSDATE             AS X_REQDATE
                     , REPLACE(S.SMS_CONTENTS, '{고객명}', DECRYPT(U.CUST_NM)               ) AS X_MSG
                     , CASE  
                           WHEN  L_IMAGE_URL IS NOT NULL AND L_IMAGE_URL != ''  THEN  '1'
                           ELSE  NULL
                       END  X_FILE_CNT 
                     --, L_IMAGE_URL         AS X_FILE_PATH1
                     , CASE  
                           WHEN  S.CUST_IMAGE_YN = 'Y' AND L_IMAGE_URL IS NOT NULL AND L_IMAGE_URL != '' THEN  REPLACE(L_IMAGE_URL, '.', '_'||C.CUST_ID||'.')
                           ELSE  L_IMAGE_URL 
                       END                 AS X_FILE_PATH1
                     , '0'                 AS X_TYPE
                     , U.CUST_ID           AS X_CUST_ID
                FROM   PROMOTION_SMS S
                     , PROMOTION_COUPON C,   PROMOTION_COUPON_PUBLISH P , C_CUST U
                WHERE  C.PUBLISH_ID = P.PUBLISH_ID
                AND    P.PRMT_ID = S.PRMT_ID
                AND    P.PRMT_ID = P_PRMT_ID
                AND    C.CUST_ID = U.CUST_ID
                AND    P.PUBLISH_ID IN( SELECT TO_NUMBER(REGEXP_SUBSTR(P_PUBLISH_LIST,'[^,]+', 1, LEVEL)) FROM DUAL
                                        CONNECT BY REGEXP_SUBSTR(P_PUBLISH_LIST, '[^,]+', 1, LEVEL) IS NOT NULL  )
                AND    U.SMS_RCV_YN = 'Y'
                AND    U.MOBILE IS NOT NULL
                ;
                
            
            END IF;
        
        ELSIF  P_GUBUN = 'U' THEN
        
            IF L_SMS_TYPE = 'S' THEN
            
                INSERT ALL  
                INTO  SC_TRAN (
                       TR_NUM
                     , TR_SENDDATE 
                     , TR_SENDSTAT 
                     , TR_MSGTYPE 
                     , TR_PHONE
                     , TR_CALLBACK 
                     , TR_MSG
                )VALUES(
                       MMS_MSG_SEQ.NEXTVAL
                     , X_TR_SENDDATE
                     , X_TR_SENDSTAT
                     , X_TR_MSGTYPE
                     , X_TR_PHONE 
                     , X_TR_CALLBACK
                     , X_TR_MSG
                )
                INTO  SMS_SEND_CUST (
                       SMS_SEND_ID
                     , CUST_ID
                     , TR_NUM
                     , MSGKEY
                )VALUES(
                       X_SMS_SEND_ID
                     , X_CUST_ID
                     , MMS_MSG_SEQ.NEXTVAL
                     , NULL
                )            
                SELECT DISTINCT
                       L_SMS_SEND_ID       AS X_SMS_SEND_ID
                     , SYSDATE             AS X_TR_SENDDATE
                     , '0'                 AS X_TR_SENDSTAT
                     , '0'                 AS X_TR_MSGTYPE
                     , DECRYPT(U.MOBILE)   AS X_TR_PHONE 
                     , U.CUST_ID           AS X_CUST_ID 
                     , ( SELECT PHONE FROM SMS_SENDER WHERE SMS_SENDER_ID = S.SMS_SENDER_ID) AS  X_TR_CALLBACK
                     , REPLACE(S.SMS_CONTENTS, '{고객명}', DECRYPT(U.CUST_NM))               AS  X_TR_MSG
                FROM   PROMOTION_COUPON C,   PROMOTION_COUPON_PUBLISH P , PROMOTION_SMS S , C_CUST U
                WHERE  C.PUBLISH_ID = P.PUBLISH_ID
                AND    P.PRMT_ID = S.PRMT_ID
                AND    P.PRMT_ID = P_PRMT_ID
                AND    C.CUST_ID = U.CUST_ID
                AND    C.CUST_ID IN( SELECT TO_NUMBER(REGEXP_SUBSTR(P_PUBLISH_LIST,'[^,]+', 1, LEVEL)) FROM DUAL
                                        CONNECT BY REGEXP_SUBSTR(P_PUBLISH_LIST, '[^,]+', 1, LEVEL) IS NOT NULL  )
                AND    U.SMS_RCV_YN = 'Y'
                AND    U.MOBILE IS NOT NULL
            ;
            
            ELSE
                INSERT ALL
                INTO  MMS_MSG (
                       MSGKEY 
                     , SUBJECT 
                     , PHONE
                     , CALLBACK 
                     , STATUS 
                     , REQDATE 
                     , MSG 
                     , FILE_CNT
                     , FILE_PATH1 
                     , TYPE
                )VALUES(
                       MMS_MSG_SEQ.NEXTVAL 
                     , X_SMS_TITLE 
                     , X_PHONE 
                     , X_CALLBACK 
                     , X_STATUS 
                     , X_REQDATE 
                     , X_MSG 
                     , X_FILE_CNT
                     , X_FILE_PATH1 
                     , X_TYPE
                )
                INTO  SMS_SEND_CUST (
                       SMS_SEND_ID
                     , CUST_ID
                     , TR_NUM
                     , MSGKEY
                )VALUES(
                       X_SMS_SEND_ID
                     , X_CUST_ID
                     , NULL
                     , MMS_MSG_SEQ.NEXTVAL
                )   
                SELECT DISTINCT
                       L_SMS_SEND_ID       AS X_SMS_SEND_ID
                     , S.SMS_TITLE         AS X_SMS_TITLE
                     , DECRYPT(U.MOBILE)   AS X_PHONE
                     , SYSDATE             AS X_TR_SENDDATE
                     , '0'                 AS X_TR_SENDSTAT
                     , '0'                 AS X_TR_MSGTYPE
                     , ( SELECT PHONE FROM SMS_SENDER WHERE SMS_SENDER_ID = S.SMS_SENDER_ID) AS  X_CALLBACK
                     , '0'                 AS X_STATUS
                     , SYSDATE             AS X_REQDATE
                     , REPLACE(S.SMS_CONTENTS, '{고객명}', DECRYPT(U.CUST_NM)               ) AS X_MSG
                     , CASE  
                            WHEN  L_IMAGE_URL IS NOT NULL AND L_IMAGE_URL != ''  THEN  '1'
                            ELSE  NULL
                       END  X_FILE_CNT 
                     , CASE  
                            WHEN  S.CUST_IMAGE_YN = 'Y' AND L_IMAGE_URL IS NOT NULL AND L_IMAGE_URL != '' THEN  REPLACE(L_IMAGE_URL, '.', '_'||C.CUST_ID||'.')
                            ELSE  L_IMAGE_URL 
                       END                 AS X_FILE_PATH1
                     , '0'                 AS X_TYPE
                     , U.CUST_ID           AS X_CUST_ID
                FROM   PROMOTION_COUPON C,   PROMOTION_COUPON_PUBLISH P , PROMOTION_SMS S , C_CUST U
                WHERE  C.PUBLISH_ID = P.PUBLISH_ID
                AND    P.PRMT_ID = S.PRMT_ID
                AND    P.PRMT_ID = P_PRMT_ID
                AND    C.CUST_ID = U.CUST_ID
                AND    C.CUST_ID IN( SELECT TO_NUMBER(REGEXP_SUBSTR(P_PUBLISH_LIST,'[^,]+', 1, LEVEL)) FROM DUAL
                                      CONNECT BY REGEXP_SUBSTR(P_PUBLISH_LIST, '[^,]+', 1, LEVEL) IS NOT NULL  )
                AND    U.SMS_RCV_YN = 'Y'
                AND    U.MOBILE IS NOT NULL
                ;
            
            END IF;
            
        ELSE
            O_RTN_CD := '2';
            RETURN;
        END IF;
        
        O_RTN_CD := '1';
        
EXCEPTION 
    WHEN NOT_FOUND THEN 
      O_RTN_CD := 'NOT_FOUND';
      ROLLBACK;
    
    WHEN OTHERS THEN
        O_RTN_CD := SQLERRM;
        ROLLBACK;
        
END PROMOTION_SEND_SMS_PUBLISH;

/
