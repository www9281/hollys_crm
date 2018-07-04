--------------------------------------------------------
--  DDL for Function FC_GET_MAIL_DO_SEQ
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_MAIL_DO_SEQ" 
  RETURN  VARCHAR2 IS
--------------------------------------------------------------------------------
--  Function Name    : FC_GET_MAIL_DO_SEQ
--  Description      : 
--  Ref. Table       : 
  vMAILDOSEQ   VARCHAR2(13);
  
BEGIN

  SELECT '2'||TO_CHAR(SYSDATE, 'YYMMDD')||TO_CHAR(SQ_MAIL_DO_SEQ.NEXTVAL, 'FM000000')
    INTO vMAILDOSEQ
    FROM DUAL;
   
  RETURN TO_NUMBER(vMAILDOSEQ);
END;

/
