--------------------------------------------------------
--  DDL for Function DECRYPT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."DECRYPT" 
( input_string  IN  VARCHAR2
, key_data      IN  VARCHAR2 := '!!fWadF29aF8fBhky_df9ga0d9fFeEE@'
) RETURN VARCHAR2 DETERMINISTIC IS
--------------------------------------------------------------------------------
--  Procedure Name   : DECRYPT
--  Description      : 암호 해제 AES256[CRM]
--  Ref. Table       : 
--------------------------------------------------------------------------------
--  Create Date      : 2017-11-17
--  Modify Date      : 
--------------------------------------------------------------------------------
  output_string      VARCHAR2 (200);         -- 복호화된 문자열
  decrypted_raw      RAW (2000);             -- 복호화된 raw타입 데이터
  key_bytes_raw      RAW (32);               -- 256bit 암호화 key
  encryption_type    PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
BEGIN
  IF input_string       IS NOT NULL THEN
    key_bytes_raw := UTL_I18N.STRING_TO_RAW(key_data, 'AL32UTF8');
    decrypted_raw := DBMS_CRYPTO.DECRYPT
        (
            src => UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(input_string)),
            typ => encryption_type,
            key => key_bytes_raw
        );
   output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');

  END IF;
  RETURN output_string  ;
END DECRYPT;

/
