--------------------------------------------------------
--  DDL for Function FC_GET_SCHDNUM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_SCHDNUM" 
 RETURN  VARCHAR2
  IS
  ls_schdnum   VARCHAR2(10);
BEGIN

------------------------------------------------------------------
--  일정관리 SEQ
------------------------------------------------------------------  

   -- LS_SCHDNUM := TO_CHAR(SEQ_SCHDNUM.NEXTVAL,'FM0999999999') ;

      SELECT  TO_CHAR(SEQ_SCHDNUM.NEXTVAL,'FM0999999999')
        INTO ls_schdnum
        FROM DUAL;

    RETURN ls_schdnum;

END;

/
