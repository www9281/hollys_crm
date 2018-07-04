--------------------------------------------------------
--  DDL for Function FN_GET_FORMAT_CRAD
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_FORMAT_CRAD" (
    PSV_CARD_NO IN VARCHAR2
)
RETURN VARCHAR2 IS
    vCHK_DIGT           NUMBER := 0;
    vCHG_FORMT_CARD     VARCHAR2(1024) := NULL;
    vCHG_FORMT_STR      VARCHAR2(1024) := NULL;
BEGIN
    FOR i IN 1..LENGTH(PSV_CARD_NO) LOOP
        vCHG_FORMT_STR := vCHG_FORMT_STR || SUBSTR(PSV_CARD_NO, i, 1);
        
        DBMS_OUTPUT.PUT_LINE(vCHG_FORMT_STR);
        IF MOD(i, 4) = 0 THEN
            IF i != LENGTH(PSV_CARD_NO) THEN
                vCHG_FORMT_STR := vCHG_FORMT_STR || '-';
            END IF;    
        END IF;
    END LOOP;
    
    RETURN vCHG_FORMT_STR;
EXCEPTION
    WHEN OTHERS THEN
        RETURN PSV_CARD_NO;
END;

/
