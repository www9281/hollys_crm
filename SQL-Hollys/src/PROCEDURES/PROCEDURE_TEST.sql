--------------------------------------------------------
--  DDL for Procedure PROCEDURE_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROCEDURE_TEST" 
(
PARAM_A IN NUMBER
,PARAM_B IN NUMBER
,PARAM_C OUT NUMBER
)IS
BEGIN
    SELECT 1 AS NN INTO PARAM_C FROM DUAL;
END PROCEDURE_TEST;

/
