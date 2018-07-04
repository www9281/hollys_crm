--------------------------------------------------------
--  DDL for Function DIRLIST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."DIRLIST" (compcd varchar2, dir varchar2, ftype varchar2) return varchar2 as
 language java name 'DirList.getList(java.lang.String, java.lang.String, java.lang.String) return java.lang.String';

/
