--------------------------------------------------------
--  DDL for Procedure SY_CONTENT_FILE_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_CONTENT_FILE_INSERT" (
    N_TABLE_NAME  IN  VARCHAR2,
    N_REF_ID      IN	VARCHAR2,
    N_FILE_TYPE	  IN  VARCHAR2,
    P_FOLDER	    IN  VARCHAR2,
    P_FILE_NAME	  IN  VARCHAR2,
    P_FILE_EXT	  IN  VARCHAR2,
    O_FILE_ID     OUT VARCHAR2,
    O_FILE_INDEX	OUT VARCHAR2
) AS
BEGIN
        SELECT  SQ_CONTENT_FILE_ID.nextval
        INTO    O_FILE_ID
        FROM    DUAL;
        
        IF      N_TABLE_NAME IS NOT NULL AND N_REF_ID IS NOT NULL AND N_FILE_TYPE IS NOT NULL THEN
                SELECT  MAX(FILE_INDEX) + 1
                INTO    O_FILE_INDEX
                FROM    SY_CONTENT_FILE
                WHERE   TABLE_NAME = N_TABLE_NAME
                AND     REF_ID = N_REF_ID
                AND     FILE_TYPE = N_FILE_TYPE;
        END     IF;
        
        INSERT INTO SY_CONTENT_FILE
        (
          FILE_ID
          ,TABLE_NAME
          ,REF_ID
          ,FILE_TYPE
          ,FILE_INDEX
          ,FOLDER
          ,FILE_NAME
          ,FILE_EXT
          ,CREATE_DATE
          ,UPDATE_DATE
        ) VALUES (
          O_FILE_ID
          ,N_TABLE_NAME
          ,N_REF_ID
          ,N_FILE_TYPE
          ,O_FILE_INDEX
          ,P_FOLDER
          ,P_FILE_NAME
          ,P_FILE_EXT
          ,SYSTIMESTAMP
          ,SYSDATE
        );
    
END SY_CONTENT_FILE_INSERT;

/
