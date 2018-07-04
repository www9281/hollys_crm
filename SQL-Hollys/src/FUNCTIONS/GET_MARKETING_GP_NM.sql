--------------------------------------------------------
--  DDL for Function GET_MARKETING_GP_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_MARKETING_GP_NM" 
(
     P_CUST_GP_ID    VARCHAR2
) RETURN             VARCHAR2
IS
     v_cust_gp_nm    VARCHAR2(100);
BEGIN
      SELECT  TRIM(A.CUST_GP_NM) AS CUST_GP_NM 
      INTO    v_cust_gp_nm
      FROM    MARKETING_GP A
      WHERE   A.CUST_GP_ID = TRIM(CUST_GP_ID);

      RETURN v_cust_gp_nm;

END GET_MARKETING_GP_NM;

/
