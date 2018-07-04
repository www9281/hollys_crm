--------------------------------------------------------
--  DDL for Procedure SY_CONTENT_FILE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_CONTENT_FILE_UPDATE" (
    P_FILE_ID     IN VARCHAR2,
    P_FOLDER	    IN  VARCHAR2,
    P_FILE_NAME	  IN  VARCHAR2,
    P_FILE_EXT	  IN  VARCHAR2
) AS
BEGIN
        UPDATE  SY_CONTENT_FILE
        SET     FOLDER      = P_FOLDER,
                FILE_NAME   = P_FILE_NAME,
                FILE_EXT    = FILE_EXT
        WHERE   FILE_ID     = P_FILE_ID;
    
END SY_CONTENT_FILE_UPDATE;

/
