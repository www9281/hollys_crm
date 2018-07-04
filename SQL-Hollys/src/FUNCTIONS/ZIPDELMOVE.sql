--------------------------------------------------------
--  DDL for Function ZIPDELMOVE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."ZIPDELMOVE" (dirName varchar2, fileName varchar2, fmode varchar2) return varchar2 as
 language java name 'UnZip.zipDelMove(java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

/
