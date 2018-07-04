--------------------------------------------------------
--  DDL for Function DECRYPT_128
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."DECRYPT_128" (input_string IN VARCHAR2, key_data IN VARCHAR2 := '0@1234AzR6f12#56') 
     RETURN VARCHAR2
    IS
        key_raw RAW(16) := UTL_RAW.CAST_TO_RAW(key_data);
        output_raw RAW(1024);
        v_out_string VARCHAR2(1024);
        AES_CBC_PKCS5 CONSTANT PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_ECB + DBMS_CRYPTO.PAD_PKCS5;
    BEGIN
        IF input_string IS NULL THEN
         RETURN NULL;
        end IF;

        output_raw := DBMS_CRYPTO.DECRYPT(
                src => input_string,
                typ => AES_CBC_PKCS5,
                key => key_raw);

        v_out_string := UTL_I18N.RAW_TO_CHAR(output_raw, 'AL32UTF8');
        RETURN v_out_string;
    END decrypt_128 ;

/
