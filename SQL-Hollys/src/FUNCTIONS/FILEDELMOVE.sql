--------------------------------------------------------
--  DDL for Function FILEDELMOVE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FILEDELMOVE" (dir varchar2, fmode varchar2) return varchar2 as
 language java name 'DirList.fileDelMove(java.lang.String, java.lang.String) return java.lang.String';

/
