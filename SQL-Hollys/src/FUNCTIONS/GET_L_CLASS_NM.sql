--------------------------------------------------------
--  DDL for Function GET_L_CLASS_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_L_CLASS_NM" 
(
  A_COMP_CD       VARCHAR2
 ,A_ORG_CLASS_CD  VARCHAR2
 ,A_L_CLASS_CD    VARCHAR2
 ,A_LANGUAGE_TP   VARCHAR2  := 'KOR'
) RETURN          VARCHAR2
IS
  L_TABLE_NM      VARCHAR2(30);
  L_COL_NM        VARCHAR2(30);

  L_RET_VALUE     VARCHAR2(100);
BEGIN

  L_TABLE_NM := 'ITEM_L_CLASS';
  L_COL_NM   := 'L_CLASS_NM';

  SELECT NVL(T2.LANG_NM, T1.L_CLASS_NM)  AS "L_CLASS_NM"
    INTO L_RET_VALUE
    FROM ITEM_L_CLASS T1
        ,LANG_TABLE   T2
   WHERE T1.COMP_CD          = A_COMP_CD
     AND T1.ORG_CLASS_CD     = A_ORG_CLASS_CD
     AND T1.L_CLASS_CD       = A_L_CLASS_CD
     AND T2.TABLE_NM     (+) = L_TABLE_NM
     AND T2.COL_NM       (+) = L_COL_NM
     AND T2.LANGUAGE_TP  (+) = A_LANGUAGE_TP
     AND T2.COMP_CD      (+) = T1.COMP_CD
     AND T2.PK_COL       (+) = T1.COMP_CD||T1.ORG_CLASS_CD || T1.L_CLASS_CD
  ;

  RETURN L_RET_VALUE;

END GET_L_CLASS_NM;

/
