--------------------------------------------------------
--  DDL for Function FC_GET_WEEK
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_WEEK" 
            (   asCompCd        IN      VARCHAR2,   -- Company Code
                asDate          IN      VARCHAR2,   --  
                asLangTp        IN      VARCHAR2    --  
            )   RETURN Varchar IS

---------------------------------------------------------------------------------------------------
--  Function Name    : FC_GET_WEEK
--  Description      :  
-- Ref. Table        :         
---------------------------------------------------------------------------------------------------
--  Create Date      : 2010-01-08
--  Create Programer : 박인수
--  Modify Date      : 2010-01-08
--  Modify Programer :     
---------------------------------------------------------------------------------------------------

lsWeek varchar(10) := '';

BEGIN         

      SELECT  NVL(LC.CODE_NM, AA.CODE_NM) 
        INTO lsWeek
        FROM  COMMON AA
           ,  (SELECT  CODE_CD
                    ,  CODE_NM
                 FROM  LANG_COMMON
                WHERE  COMP_CD = asCompCd
                  AND  CODE_TP = '00285'
                  AND  LANGUAGE_TP = DECODE(asLangTp, NULL, ' ', asLangTp)
                  AND  USE_YN      = 'Y'
              ) LC
       WHERE  AA.COMP_CD = asCompCd
         AND  AA.CODE_TP = '00285'
         AND  AA.CODE_CD = TO_CHAR(TO_DATE(asDate, 'YYYYMMDD'), 'D')
         AND  AA.CODE_CD = LC.CODE_CD(+);


   RETURN lsWeek;  

EXCEPTION  WHEN OTHERS THEN 
   RETURN '';  

END;

/
