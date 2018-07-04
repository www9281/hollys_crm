--------------------------------------------------------
--  DDL for Function FILEENCPROC
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FILEENCPROC" (dirName varchar2, srcFile varchar2, dstFile varchar2) return VARCHAR2 as
 language java name 'fileEncProc.fileEncExec(java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

/
