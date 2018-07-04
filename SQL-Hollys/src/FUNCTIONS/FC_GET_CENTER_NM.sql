--------------------------------------------------------
--  DDL for Function FC_GET_CENTER_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_GET_CENTER_NM" (
    argCompCd  IN VARCHAR2,   -- Company Code
    argLangTp  IN VARCHAR2,  -- Language Tpye
    argStoreCd IN VARCHAR2  -- Store Code
)
RETURN VARCHAR2 AS
CODE_NAME VARCHAR2(500):=NULL;
BEGIN

      SELECT  NVL(LC.CODE_NM, AA.CODE_NM) INTO CODE_NAME
        FROM  COMMON AA, STORE BB
           ,  (SELECT  COMP_CD
                    ,  CODE_TP
                    ,  CODE_CD
                    ,  CODE_NM
                 FROM  LANG_COMMON
                WHERE  CODE_TP = '00805'
                  AND  LANGUAGE_TP = DECODE(argLangTp, NULL, ' ', argLangTp)
                  AND  USE_YN      = 'Y') LC
       WHERE  AA.CODE_TP  = '00805'
         AND  AA.CODE_CD  = BB.CENTER_CD
         AND  AA.COMP_CD  = BB.COMP_CD
         AND  BB.STOR_CD  = argStoreCd
         AND  BB.COMP_CD  = argCompCd
         AND  AA.CODE_TP  = LC.CODE_TP(+)
         AND  AA.CODE_CD  = LC.CODE_CD(+)
         AND  AA.COMP_CD  = LC.COMP_CD(+);

RETURN CODE_NAME;
END;

/
