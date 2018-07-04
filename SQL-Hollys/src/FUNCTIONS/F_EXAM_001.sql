--------------------------------------------------------
--  DDL for Function F_EXAM_001
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."F_EXAM_001" (ARGCLOG IN CLOB)
RETURN VARCHAR2 IS
    vSEP VARCHAR2(1000);
BEGIN
    vSEP := SUBSTR(ARGCLOG, 1, 3);
    
    RETURN vSEP;
EXCEPTION
    WHEN OTHERS THEN
        RETURN SQLERRM;
END;

/
