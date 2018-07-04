--------------------------------------------------------
--  DDL for Function FN_GET_FROMAT_MMSS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_FROMAT_MMSS" (nSEC IN NUMBER) 
    RETURN VARCHAR2 IS
    
    vRTNFORMAT      VARCHAR2(8) :=NULL;
BEGIN
    vRTNFORMAT := CASE WHEN FLOOR(NVL(nSEC, 0) / 60) > 60 THEN TO_CHAR(FLOOR(NVL(nSEC, 0) / (60 * 60)), 'FM00') || ':'|| TO_CHAR(FLOOR(MOD(NVL(nSEC, 0), 60 * 60) / 60), 'FM00') ELSE TO_CHAR(FLOOR(NVL(nSEC, 0) / 60), 'FM00') END 
                  || ':'|| 
                  TO_CHAR (MOD (NVL(nSEC, 0), 60), 'FM00');

    RETURN vRTNFORMAT;              
END FN_GET_FROMAT_MMSS;

/
