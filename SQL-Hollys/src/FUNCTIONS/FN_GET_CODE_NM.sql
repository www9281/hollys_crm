--------------------------------------------------------
--  DDL for Function FN_GET_CODE_NM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_CODE_NM" 
(
     P_CODE_GROUP   VARCHAR2
   , P_CODE         VARCHAR2
) RETURN          VARCHAR2
IS
    v_code_nm     VARCHAR2(60);
BEGIN

      SELECT
        B.CODE_NAME
        INTO v_code_nm
      FROM CD_COMMON_GROUP A, CD_COMMON_CODE B
      WHERE A.GROUP_CODE = B.GROUP_CODE
        AND A.GROUP_CODE = P_CODE_GROUP
        AND B.CODE = P_CODE; 
      
  RETURN v_code_nm;

END FN_GET_CODE_NM;

/
