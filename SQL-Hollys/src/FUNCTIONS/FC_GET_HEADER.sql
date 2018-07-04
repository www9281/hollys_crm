--------------------------------------------------------
--  DDL for Function FC_GET_HEADER
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_HEADER" 
          ( asCompCd    IN  VARCHAR2,  -- Company Code
            asLanguage  IN  VARCHAR2,  -- Language Type
            asColNm     IN  VARCHAR2   -- Column Name
          )  RETURN VARCHAR2 AS 

---------------------------------------------------------------------------------------------------
--  Function Name    : FC_GET_HEADER
--  Description      : 
-- Ref. Table        : 
---------------------------------------------------------------------------------------------------
--  Create Date      : 2010-05-03
--  Create Programer : 박인수
--  Modify Date      : 2010-05-03
--  Modify Programer :     
---------------------------------------------------------------------------------------------------

lsRetVal      COMMON.CODE_NM%TYPE;

BEGIN     
    SELECT NVL(L.CODE_NM, C.CODE_NM)  
      INTO lsRetVal
      FROM COMMON C,  
           ( SELECT COMP_CD,
                    CODE_TP, 
                    CODE_CD, 
                    CODE_NM  
               FROM LANG_COMMON                
              WHERE CODE_TP     = '60000'      
                AND LANGUAGE_TP = asLanguage  
                AND USE_YN      = 'Y'          
           )   L                               
     WHERE C.COMP_CD  = L.COMP_CD(+) 
       AND C.CODE_CD  = L.CODE_CD(+)
       AND C.CODE_TP  = '60000'
       AND C.COMP_CD  = asCompCd
       AND C.VAL_C1   = asColNm
       AND C.USE_YN   = 'Y';         

   return lsRetVal ;

EXCEPTION  WHEN OTHERS THEN 
   return '';

END FC_GET_HEADER ;

/
