--------------------------------------------------------
--  DDL for Procedure SY_CONTENT_FILE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_CONTENT_FILE_SELECT" (
    P_TABLE_NAME  IN    SY_CONTENT_FILE.TABLE_NAME%TYPE,
    P_REF_ID      IN	  SY_CONTENT_FILE.REF_ID%TYPE,
    O_CURSOR      OUT   SYS_REFCURSOR
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
    FROM SY_CONTENT_FILE
    WHERE TABLE_NAME = P_TABLE_NAME
      AND REF_ID = P_REF_ID
    ORDER BY FILE_INDEX ASC;
    
END SY_CONTENT_FILE_SELECT;

/
