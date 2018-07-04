--------------------------------------------------------
--  DDL for Function GET_COMMON_CODE_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_COMMON_CODE_NM" 
(
  --A_COMP_CD       VARCHAR2
    A_CODE_TP       VARCHAR2
   ,A_CODE_CD       VARCHAR2
   ,A_LANGUAGE_TP   VARCHAR2  := 'KOR'
) RETURN            VARCHAR2
IS
   L_RET_VALUE      VARCHAR2(60);
BEGIN

    SELECT 
           DISTINCT NVL(T1.CODE_NM, T2.CODE_NM)  AS "CODE_NM"
           INTO L_RET_VALUE
    FROM   COMMON      T1
         LEFT OUTER JOIN  LANG_COMMON T2  
          ON     T2.CODE_TP      (+) = T1.CODE_TP
          AND    T2.CODE_CD      (+) = T1.CODE_CD
   --WHERE T1.COMP_CD          = A_COMP_CD
    WHERE  T1.CODE_TP          = A_CODE_TP
    AND    T1.CODE_CD          = A_CODE_CD
    --AND    T2.LANGUAGE_TP      = A_LANGUAGE_TP
     --AND T2.COMP_CD      (+) = T1.COMP_CD

   ;

    RETURN L_RET_VALUE;

END GET_COMMON_CODE_NM;

/
