--------------------------------------------------------
--  DDL for Procedure SY_CONTENT_FILE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_CONTENT_FILE_DELETE" (
    P_FILE_ID     IN VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
) AS
BEGIN
    /*
        OPEN O_CURSOR FOR
        SELECT *
        FROM SY_CONTENT_FILE
        WHERE   FILE_ID     = TO_NUMBER(P_FILE_ID)
        ;
    */    
        DELETE  
        FROM    SY_CONTENT_FILE
        WHERE   FILE_ID     = TO_NUMBER(P_FILE_ID)
        ;
    
END SY_CONTENT_FILE_DELETE;

/
