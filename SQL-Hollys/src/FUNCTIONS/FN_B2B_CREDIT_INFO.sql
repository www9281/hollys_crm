--------------------------------------------------------
--  DDL for Function FN_B2B_CREDIT_INFO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_B2B_CREDIT_INFO" (vB2BCODE IN VARCHAR2)
    RETURN NUMBER IS

    vCREDITVALUE       VARCHAR2(32767) := NULL;
BEGIN
    IF vB2BCODE IS NULL THEN
        vCREDITVALUE := '0';
    ELSE    
        SELECT UTL_HTTP.REQUEST('http://121.78.170.201:8388/EXEC_WPOS/UTIL/ProcedureCall.jsp?SCH_CUST_ID=2200005')
        INTO   vCREDITVALUE
        FROM   DUAL;
    END IF;

    RETURN TO_NUMBER(vCREDITVALUE);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        RETURN 0;
END;

/
