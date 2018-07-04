--------------------------------------------------------
--  DDL for Procedure CD_COMMON_CODE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."CD_COMMON_CODE_DELETE" (
        P_GROUP_CODE	  IN  CHAR,
        P_CODE	        IN  CHAR
) AS 
BEGIN
        DELETE    CD_COMMON_CODE
        WHERE     GROUP_CODE      = P_GROUP_CODE
          AND     CODE            = P_CODE;
END CD_COMMON_CODE_DELETE;

/
