--------------------------------------------------------
--  DDL for Procedure SY_CONTENT_FILE_SELECT_BY_KEY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_CONTENT_FILE_SELECT_BY_KEY" (
    P_FILE_ID  IN    VARCHAR2,
    O_CURSOR   OUT   SYS_REFCURSOR
) IS
BEGIN
    OPEN O_CURSOR FOR
    SELECT
      FILE_ID
      ,TABLE_NAME
      ,REF_ID
      ,FILE_TYPE
      ,FILE_INDEX
      ,FOLDER
      ,FILE_NAME
      ,FILE_EXT
      ,FILE_ID || '_' || TABLE_NAME || '_' || REF_ID || '.' || FILE_EXT AS SERVER_FILE_ID
    FROM SY_CONTENT_FILE
    WHERE FILE_ID = P_FILE_ID;
    
END SY_CONTENT_FILE_SELECT_BY_KEY;

/
