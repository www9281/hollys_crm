--------------------------------------------------------
--  DDL for Package Body PKG_COMMON_FC
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_COMMON_FC" AS
  FUNCTION F_RTN_MSG
  ( 
    PSV_COMP_CD   IN  VARCHAR2
  , PSV_LANG      IN  VARCHAR2
  , PSV_MSG_CD    IN  VARCHAR2 
  ) RETURN VARCHAR2 IS
    ls_message  MESSAGE_MST.MSG_NM%TYPE;
  BEGIN
    SELECT MSG_NM
      INTO ls_message
      FROM MESSAGE_MST A
     WHERE A.COMP_CD     = PSV_COMP_CD
       AND A.MSG_TP      = '01'
       AND A.LANGUAGE_TP = PSV_LANG
       AND A.MSG_CD      = PSV_MSG_CD;

    RETURN ls_message;

  EXCEPTION
    WHEN OTHERS THEN
         ls_message := '';
         RETURN ls_message;
  END;
END ;

/
