--------------------------------------------------------
--  DDL for Procedure ALL_ARGUMENTS_SELECT_PROCEDURE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."ALL_ARGUMENTS_SELECT_PROCEDURE" (
        P_OBJECT_ID         IN    SYS.ALL_ARGUMENTS.OBJECT_ID%TYPE,
        O_CURSOR            OUT   SYS_REFCURSOR 
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  ARGUMENT_NAME,
                DATA_TYPE,
                IN_OUT,
                DATA_LENGTH
        FROM    SYS.ALL_ARGUMENTS
        WHERE   OBJECT_ID = P_OBJECT_ID
        ORDER   BY
                SEQUENCE;
END ALL_ARGUMENTS_SELECT_PROCEDURE;

/
