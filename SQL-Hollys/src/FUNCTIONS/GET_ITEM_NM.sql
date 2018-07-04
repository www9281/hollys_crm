--------------------------------------------------------
--  DDL for Function GET_ITEM_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_ITEM_NM" 
(
     P_ITEM_CD    VARCHAR2
) RETURN          VARCHAR2
IS
     v_item_nm    VARCHAR2(60);
BEGIN
      SELECT  TRIM(A.ITEM_NM) AS ITEM_NM 
      INTO    v_item_nm
      FROM    ITEM A
      WHERE   A.ITEM_CD = TRIM(P_ITEM_CD) 
      AND     A.USE_YN = 'Y';
         
      RETURN v_item_nm;

END GET_ITEM_NM;

/
