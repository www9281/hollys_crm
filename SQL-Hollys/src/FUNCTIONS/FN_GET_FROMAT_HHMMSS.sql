--------------------------------------------------------
--  DDL for Function FN_GET_FROMAT_HHMMSS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_FROMAT_HHMMSS" (nSEC IN NUMBER) 
    RETURN VARCHAR2 IS
    
    vRTNFORMAT      VARCHAR2(8) :=NULL;
BEGIN
    vRTNFORMAT := TO_CHAR(CASE WHEN FLOOR(NVL(nSEC, 0) / (60 * 60)) = 24 THEN 00 ELSE FLOOR(NVL(nSEC, 0) / (60 * 60)) END, 'FM99900') 
                  || ':'|| 
                  TO_CHAR (FLOOR(NVL(nSEC, 0) / 60), 'FM00')
                  || ':'|| 
                  TO_CHAR (MOD (NVL(nSEC, 0), 60), 'FM00');

    RETURN vRTNFORMAT;              
END FN_GET_FROMAT_HHMMSS;

/
