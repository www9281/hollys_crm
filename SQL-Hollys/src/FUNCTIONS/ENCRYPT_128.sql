--------------------------------------------------------
--  DDL for Function ENCRYPT_128
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."ENCRYPT_128" (input_string IN VARCHAR2, key_data IN VARCHAR2 := '0@1234AzR6f12#56')
     RETURN RAW
    IS
        input_raw RAW(1024);
        key_raw RAW(16) := UTL_RAW.CAST_TO_RAW(key_data);
        v_out_raw RAW(1024);
        AES_CBC_PKCS5 CONSTANT PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_ECB + DBMS_CRYPTO.PAD_PKCS5;
    BEGIN
        IF input_string IS NULL THEN
           RETURN NULL;
        end IF;

        input_raw := UTL_I18N.STRING_TO_RAW(input_string,'AL32UTF8');
        dbms_output.put_line('========' || input_raw );

        v_out_raw := DBMS_CRYPTO.ENCRYPT(
                src => input_raw,
                typ => AES_CBC_PKCS5,
                key => key_raw);
    RETURN v_out_raw;
    END encrypt_128;

/
