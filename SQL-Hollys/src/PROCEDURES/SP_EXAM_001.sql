--------------------------------------------------------
--  DDL for Procedure SP_EXAM_001
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_EXAM_001" (nSEQ IN NUMBER) IS
BEGIN
    IF nSEQ = 1 THEN
        GOTO n1;  
    ELSE
        GOTO n2;
    END IF;
    
    <<n1>>
        DBMS_OUTPUT.PUT_LINE('NUMBER IS 1');
     
        CONTINUE;
       
    <<n2>>
        DBMS_OUTPUT.PUT_LINE('NUMBER IS 2');    
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;

/
