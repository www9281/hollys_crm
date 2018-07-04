--------------------------------------------------------
--  DDL for Function ZIPDELROOT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."ZIPDELROOT" (dirName varchar2, fileName varchar2, fmode varchar2) return varchar2 as
 language java name 'UnZip.zipDelRoot(java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

/
