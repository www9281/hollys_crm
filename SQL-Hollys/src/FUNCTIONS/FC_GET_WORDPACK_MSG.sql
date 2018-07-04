--------------------------------------------------------
--  DDL for Function FC_GET_WORDPACK_MSG
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_WORDPACK_MSG" 
( asCompcd    IN  VARCHAR2,
  asLanguage  IN  VARCHAR2,
  asMsgCd     IN  VARCHAR2
) RETURN VARCHAR2 AS
--------------------------------------------------------------------------------
--  Function Name    : FC_GET_WORDPACK_MSG
--  Description      : 
-- Ref. Table        : WORDPACK_MSG
--------------------------------------------------------------------------------
--  Create Date      : 2011-11-19
--  Modify Date      : 2011-11-19
--------------------------------------------------------------------------------

  lsRetVal      WORDPACK_MSG.MESSAGE%TYPE;

BEGIN
  SELECT MESSAGE
    INTO lsRetVal
    FROM WORDPACK_MSG
   WHERE LANGUAGE_TP = asLanguage
     AND MSG_CD      = asMsgCd
     AND USE_YN      = 'Y';

  RETURN lsRetVal;

EXCEPTION
  WHEN OTHERS THEN
       RETURN '';
END FC_GET_WORDPACK_MSG;

/
