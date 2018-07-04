--------------------------------------------------------
--  DDL for Procedure USER_OBJECTS_SELECT_PROCEDURE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."USER_OBJECTS_SELECT_PROCEDURE" (
        P_PROCEDURE_NAME    IN    USER_OBJECTS.OBJECT_NAME%TYPE,
        O_OBJECT_ID         OUT   USER_OBJECTS.OBJECT_ID%TYPE
        
) AS 
BEGIN
        SELECT  OBJECT_ID
        INTO    O_OBJECT_ID
        FROM    USER_OBJECTS
        WHERE   UPPER(OBJECT_TYPE) = 'PROCEDURE'
        AND     OBJECT_NAME = P_PROCEDURE_NAME;
        EXCEPTION
                WHEN  NO_DATA_FOUND THEN  NULL;
                WHEN  OTHERS        THEN  NULL;
END USER_OBJECTS_SELECT_PROCEDURE;

/
