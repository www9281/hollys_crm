--------------------------------------------------------
--  DDL for Function ENCRYPT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."ENCRYPT" 
( input_string  IN  VARCHAR2
, key_data      IN  VARCHAR2 := '!!fWadF29aF8fBhky_df9ga0d9fFeEE@'
) RETURN            VARCHAR2 IS
--------------------------------------------------------------------------------
--  Procedure Name   : ENCRYPT
--  Description      : 암호화 AES256[CRM]
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2017-11-17
--  Modify Date      : 
--------------------------------------------------------------------------------
  return_base256 VARCHAR2(256);
  encrypted_raw RAW (2000);      -- encryption raw type date
  key_bytes_raw RAW (32);        -- encryption key (32raw => 32byte => 256bit)
  encryption_type PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
BEGIN

  IF input_string       IS NOT NULL THEN
          key_bytes_raw := UTL_I18N.STRING_TO_RAW(key_data, 'AL32UTF8');
          encrypted_raw := DBMS_CRYPTO.ENCRYPT ( src => UTL_I18N.STRING_TO_RAW(input_string, 'AL32UTF8'), typ => encryption_type, KEY => key_bytes_raw );
          return_base256 := UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(encrypted_raw));
  END IF;
  RETURN return_base256;
END ENCRYPT;

/
