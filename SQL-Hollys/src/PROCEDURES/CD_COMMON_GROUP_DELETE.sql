--------------------------------------------------------
--  DDL for Procedure CD_COMMON_GROUP_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_GROUP_DELETE" (
        P_GROUP_CODE	  IN  CHAR
) AS 
BEGIN
        DELETE    CD_COMMON_GROUP
        WHERE     GROUP_CODE      = P_GROUP_CODE;
END CD_COMMON_GROUP_DELETE;

/
