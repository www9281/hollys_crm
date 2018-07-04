--------------------------------------------------------
--  DDL for Function GET_SHA1_STR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_SHA1_STR" (buffer IN VARCHAR2) 
return VARCHAR2 as LANGUAGE JAVA NAME 
'SHA1.makeSha1Str(java.lang.String) 
return java.lang.String';

/
