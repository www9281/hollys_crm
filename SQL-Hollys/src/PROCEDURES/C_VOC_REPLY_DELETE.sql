--------------------------------------------------------
--  DDL for Procedure C_VOC_REPLY_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_REPLY_DELETE" (
        P_VOC_SEQ           IN    NUMBER,
        P_BRAND_CD          IN    VARCHAR2,
        P_USER_ID           IN    VARCHAR2
) AS 
BEGIN
        UPDATE  C_VOC_REPLY
           SET  DEL_YN       = 'N'
             ,  UPD_DT       = SYSDATE
             ,  UPD_USER     = P_USER_ID
        WHERE   VOC_SEQ      = P_VOC_SEQ;
END C_VOC_REPLY_DELETE;

/
