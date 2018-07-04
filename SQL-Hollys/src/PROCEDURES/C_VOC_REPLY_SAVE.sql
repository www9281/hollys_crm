--------------------------------------------------------
--  DDL for Procedure C_VOC_REPLY_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_REPLY_SAVE" (
        N_VOC_REPLY_SEQ     IN    VARCHAR2,
        P_VOC_SEQ           IN    VARCHAR2,
        P_REPLY_CONTENT     IN    VARCHAR2,
        N_ETC               IN    VARCHAR2,
        P_DEL_YN            IN    CHAR,
        P_USER_ID           IN    VARCHAR2,
        O_VOC_REPLY_SEQ     OUT   VARCHAR2
) AS 
BEGIN
        IF N_VOC_REPLY_SEQ IS NULL THEN
            SELECT 
               SQ_VOC_REPLY_SEQ.NEXTVAL
               INTO O_VOC_REPLY_SEQ
            FROM DUAL;
            INSERT INTO C_VOC_REPLY
               (        VOC_REPLY_SEQ
                    ,   VOC_SEQ
                    ,   CONTENT
                    ,   ETC
                    ,   DEL_YN
                    ,   INST_DT
                    ,   INST_USER
                    ,   UPD_DT
                    ,   UPD_USER
               ) VALUES (
                        N_VOC_REPLY_SEQ
                    ,   P_VOC_SEQ
                    ,   P_REPLY_CONTENT
                    ,   N_ETC
                    ,   DECODE(P_DEL_YN, 'Y', 'Y', 'N')
                    ,   SYSDATE
                    ,   P_USER_ID
                    ,   SYSDATE
                    ,   P_USER_ID
               );
        ELSE  
           UPDATE   C_VOC_REPLY
              SET   VOC_SEQ          = P_VOC_SEQ
                ,   CONTENT          = P_REPLY_CONTENT
                ,   ETC              = N_ETC
                ,   DEL_YN           = DECODE(P_DEL_YN, 'Y', 'Y', 'N')
                ,   UPD_DT           = SYSDATE
                ,   UPD_USER         = P_USER_ID;

                O_VOC_REPLY_SEQ := N_VOC_REPLY_SEQ;
        END IF;
END C_VOC_REPLY_SAVE;

/
