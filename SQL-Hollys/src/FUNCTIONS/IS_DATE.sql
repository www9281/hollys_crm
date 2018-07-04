--------------------------------------------------------
--  DDL for Function IS_DATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."IS_DATE" 
(
     IN_STR IN VARCHAR2
)    
     RETURN    DATE     
     DETERMINISTIC
AS
     L_NUM NUMBER;
BEGIN
     RETURN TO_CHAR(TO_DATE(SUBSTR(IN_STR, 0, 8)),'YYYYMMDD');
EXCEPTION
     WHEN OTHERS THEN
     RETURN NULL;
END;

/
