--------------------------------------------------------
--  DDL for Function GET_PROMOTION_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_PROMOTION_NM" 
(
     P_PRMT_ID   VARCHAR2
    ,P_COMP_CD   VARCHAR2
) RETURN         VARCHAR2
IS
      v_prmt_nm     VARCHAR2(255);
BEGIN

      SELECT
             A.PRMT_NM
             INTO v_prmt_nm
      FROM   PROMOTION A
      WHERE  A.PRMT_ID = P_PRMT_ID
      AND    A.COMP_CD = P_COMP_CD; 

      RETURN v_prmt_nm;

END GET_PROMOTION_NM;

/
