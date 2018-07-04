--------------------------------------------------------
--  DDL for Function GET_LANG_ITEM_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_LANG_ITEM_NM" 
(
     A_ITEM_CD    VARCHAR2
   , A_LANGUAGE_TP   VARCHAR2  := 'KOR'
) RETURN          VARCHAR2
IS
    L_RET_VALUE     VARCHAR2(60);
BEGIN
      SELECT  NVL(LS.ITEM_NM, S.ITEM_NM ) AS ITEM_NM 
         INTO  L_RET_VALUE
        FROM  ITEM S
            ,  (
                  SELECT  ITEM_CD
                           ,  ITEM_NM
                 FROM  LANG_ITEM
                WHERE  ITEM_CD      = A_ITEM_CD
                  AND  LANGUAGE_TP = A_LANGUAGE_TP
                  AND  USE_YN           = 'Y'
               ) LS
       WHERE  S.ITEM_CD     = A_ITEM_CD 
           AND  S.ITEM_CD      = LS.ITEM_CD(+) 
           AND  S.USE_YN        = 'Y';
         
  RETURN L_RET_VALUE;

END GET_LANG_ITEM_NM;

/
