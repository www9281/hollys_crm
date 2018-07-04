--------------------------------------------------------
--  DDL for Function FN_GET_FROMAT_HHMM
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_FROMAT_HHMM" (nMINUTE IN NUMBER) 
    RETURN VARCHAR2 IS
    
    vRTNFORMAT      VARCHAR2(8) :=NULL;
BEGIN
    vRTNFORMAT := TO_CHAR(CASE WHEN FLOOR(NVL(nMINUTE, 0) / 60) = 24 THEN 00 ELSE FLOOR(NVL(nMINUTE, 0) / 60) END, 'FM99900') 
                  || ':'|| 
                  TO_CHAR (MOD (NVL(nMINUTE, 0), 60), 'FM00');

    RETURN vRTNFORMAT;              
END FN_GET_FROMAT_HHMM;

/
