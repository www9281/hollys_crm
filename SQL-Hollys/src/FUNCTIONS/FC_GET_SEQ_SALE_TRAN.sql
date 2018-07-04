--------------------------------------------------------
--  DDL for Function FC_GET_SEQ_SALE_TRAN
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_SEQ_SALE_TRAN" 
 RETURN  VARCHAR2
  IS
  ls_lognum   VARCHAR2(16);
  ls_use_yn   CHAR(1);
BEGIN

------------------------------------------------------------------
--  GET SEQUENCE NUMBER
--  TRANSACTION LOG DATA 
------------------------------------------------------------------   
   BEGIN
      SELECT  TO_CHAR(SQ_SALE_TRAN.NEXTVAL,'FM0999999999999999')
        INTO ls_lognum
        FROM DUAL;
   END;

   RETURN ls_lognum;

END;

/
