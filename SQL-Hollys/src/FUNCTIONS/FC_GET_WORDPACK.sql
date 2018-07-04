--------------------------------------------------------
--  DDL for Function FC_GET_WORDPACK
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_WORDPACK" 
( asLanguage  IN  VARCHAR2,
  asColNm     IN  VARCHAR2
) RETURN VARCHAR2 AS
--------------------------------------------------------------------------------
--  Function Name    : FC_GET_WORDPACK
--  Description      : 
-- Ref. Table        : WORDPACK
--------------------------------------------------------------------------------
--  Create Date      : 2011-11-19
--  Modify Date      : 2011-11-19
--------------------------------------------------------------------------------

  lsRetVal      WORDPACK.WORD_NM%TYPE;

BEGIN
  SELECT WORD_NM
    INTO lsRetVal
    FROM WORDPACK
   WHERE LANGUAGE_TP = asLanguage
     AND KEY_WORD_CD = asColNm
     AND USE_YN      = 'Y';

  RETURN lsRetVal;

EXCEPTION
  WHEN OTHERS THEN
       RETURN '';
END FC_GET_WORDPACK;

/
