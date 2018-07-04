--------------------------------------------------------
--  DDL for Function FN_SHAENCRYPTOR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_SHAENCRYPTOR" (name VARCHAR2) RETURN VARCHAR2
AS LANGUAGE JAVA
NAME 'SHA256Encryptor.SHA256Encryptor(java.lang.String) return java.lang.String';

/
