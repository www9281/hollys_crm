--------------------------------------------------------
--  DDL for Procedure C_VOC_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_DELETE" (
        P_VOC_SEQ           IN    VARCHAR2,
        P_MY_USER_ID        IN    VARCHAR2
) AS 
BEGIN
        UPDATE  C_VOC
           SET  DEL_YN       = 'Y'
             ,  UPD_DT       = SYSDATE
             ,  UPD_USER     = P_MY_USER_ID
        WHERE   VOC_SEQ      = P_VOC_SEQ;
        
END C_VOC_DELETE;

/
