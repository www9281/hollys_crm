--------------------------------------------------------
--  DDL for Function FTPSEND
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FTPSEND" (compcd varchar2, dir varchar2) return varchar2 as
 language java name 'FtpSend.sendFile(java.lang.String, java.lang.String) return java.lang.String';

/
