--------------------------------------------------------
--  DDL for Procedure PROMOTION_PUSH_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_PUSH_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 PUSH메세지 등록/수정
-- Test			:	exec PROMOTION_PUSH_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        N_PUSH_NO       IN   VARCHAR2,
        P_PUSH_YN       IN   CHAR,
        N_PUSH_TYPE     IN   VARCHAR2,
        P_PUSH_TITLE    IN   VARCHAR2,
        N_PUSH_CONTENTS IN   VARCHAR2,
        N_PUSH_LINK     IN   VARCHAR2,
        N_BOOK_DT       IN   VARCHAR2,
        N_BOOK_HOUR     IN   VARCHAR2, 
        N_BOOK_MINUTE   IN   VARCHAR2, 
        P_PUSH_SEND_DIV IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,
        O_PUSH_NO       OUT  VARCHAR2
) AS 

        v_img_url VARCHAR2(500);

BEGIN  
        SELECT    MAX(CASE WHEN B.FILE_ID IS NULL
                         THEN  ''
                         ELSE  B.FOLDER || '/' || B.FILE_ID || '.' || B.FILE_EXT
                  END) AS IMG_URL
        INTO      v_img_url
        FROM      PROMOTION_PUSH A
        LEFT      OUTER JOIN SY_CONTENT_FILE B
        ON        TABLE_NAME = 'PROMOTION_PUSH'
        AND       A.PRMT_ID = B.REF_ID
        WHERE     A.PRMT_ID = P_PRMT_ID;
        

        IF  N_PUSH_NO IS NULL THEN
            SELECT SQ_PUSH_NO.NEXTVAL
            INTO O_PUSH_NO
            FROM DUAL;
            
            INSERT  INTO PROMOTION_PUSH
            (      
                    PUSH_NO
                    ,PRMT_ID
                    ,PUSH_TYPE
                    ,PUSH_YN
                    ,PUSH_TITLE
                    ,PUSH_CONTENTS
                    ,PUSH_LINK
                    ,IMG_URL
                    ,BOOK_DT
                    ,BOOK_HOUR
                    ,BOOK_MINUTE
                    ,PUSH_SEND_DIV
                    ,INST_USER
                    ,INST_DT
                    ,UPD_USER
                    ,UPD_DT
           ) VALUES (   
                     O_PUSH_NO
                    ,P_PRMT_ID
                    ,N_PUSH_TYPE
                    ,DECODE(P_PUSH_YN, '0', 'Y', 'N')
                    ,P_PUSH_TITLE
                    ,N_PUSH_CONTENTS
                    ,N_PUSH_LINK
                    ,v_img_url
                    ,N_BOOK_DT
                    ,N_BOOK_HOUR
                    ,N_BOOK_MINUTE
                    ,P_PUSH_SEND_DIV
                    ,P_USER_ID
                    ,SYSDATE
                    ,P_USER_ID
                    ,SYSDATE
           );
           
           O_PUSH_NO := O_PUSH_NO;
           
        ELSE    
            UPDATE   PROMOTION_PUSH
               SET   PUSH_TYPE        = N_PUSH_TYPE
                     ,PUSH_YN         = DECODE(P_PUSH_YN, '0', 'Y', 'N')
                     ,PUSH_TITLE      = P_PUSH_TITLE
                     ,PUSH_CONTENTS   = N_PUSH_CONTENTS
                     ,PUSH_LINK       = N_PUSH_LINK
                     ,IMG_URL         = v_img_url
                     ,BOOK_DT         = N_BOOK_DT
                     ,BOOK_HOUR       = N_BOOK_HOUR
                     ,BOOK_MINUTE     = N_BOOK_MINUTE
                     ,PUSH_SEND_DIV   = P_PUSH_SEND_DIV
                     ,UPD_USER        = P_USER_ID
                     ,UPD_DT          = SYSDATE
            WHERE    PRMT_ID  = P_PRMT_ID
            AND      PUSH_NO  = N_PUSH_NO;
            
            O_PUSH_NO := N_PUSH_NO;
            
        END IF;   

END PROMOTION_PUSH_SAVE;

/
