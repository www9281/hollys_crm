--------------------------------------------------------
--  DDL for Procedure SP_MECD1060L1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MECD1060L1" IS
    vSTDYM      VARCHAR2(6)    := NULL;
    vRTNCODE    VARCHAR2(2000) := NULL;
    vRTNMSG     VARCHAR2(2000) := NULL;
BEGIN
    vSTDYM := TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM');
    
    SP_MECD1060L0('000', 'KOR', vSTDYM, vRTNCODE, vRTNMSG);
    
END SP_MECD1060L1;

/
