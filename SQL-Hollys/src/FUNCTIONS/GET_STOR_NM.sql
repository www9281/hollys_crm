--------------------------------------------------------
--  DDL for Function GET_STOR_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_STOR_NM" 
(
     A_BRAND_CD  VARCHAR2
   , A_STOR_CD    VARCHAR2
   , A_LANGUAGE_TP   VARCHAR2  := 'KOR'
) RETURN          VARCHAR2
IS
    L_RET_VALUE     STORE.STOR_NM%TYPE;
BEGIN
      SELECT  NVL(LS.STOR_NM, S.STOR_NM ) AS STOR_NM
         INTO  L_RET_VALUE
        FROM  STORE S
            ,  (
                  SELECT  STOR_CD
                           ,  STOR_NM
                 FROM  LANG_STORE
                WHERE  BRAND_CD      = A_BRAND_CD
                    AND  STOR_CD        = A_STOR_CD 
                    AND  LANGUAGE_TP = A_LANGUAGE_TP
                    AND  USE_YN          = 'Y'
               ) LS
       WHERE   S.BRAND_CD  = A_BRAND_CD  
         AND   S.STOR_CD      = A_STOR_CD 
         AND   S.STOR_CD      = LS.STOR_CD(+) 
         AND   S.USE_YN         = 'Y';
         
  RETURN L_RET_VALUE;

END GET_STOR_NM;

/
