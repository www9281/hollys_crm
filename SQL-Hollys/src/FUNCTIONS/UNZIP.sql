--------------------------------------------------------
--  DDL for Function UNZIP
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."UNZIP" (dirName varchar2, fileName varchar2) return varchar2 as
 language java name 'UnZip.UnZipExec(java.lang.String, java.lang.String) return java.lang.String';

/
