--------------------------------------------------------
--  DDL for Function FN_GET_CERT_NO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_CERT_NO" 
(
    PSV_BRAND_CD  IN VARCHAR2,
    PSV_CHARGE_YN IN VARCHAR2
) RETURN VARCHAR2 IS
    vCertNo         CS_MEMBERSHIP_SALE.CERT_NO%TYPE         := NULL;        -- 인증번호
    nApprSeq        CS_MEMBERSHIP_SALE_HIS.APPR_SEQ%TYPE    := 1;           -- 승인순번
    nCheckDigit     NUMBER(7) := 0;
BEGIN
    -- 1.2  인증번호 조회
    SELECT  TO_CHAR(SYSDATE, 'YYMM')  ||
            PSV_BRAND_CD              ||
            PSV_CHARGE_YN             ||
            LPAD(SQ_MEMBERSHIP_CERT_NO.NEXTVAL, 6, '0')  AS CERT_NO
      INTO  vCertNo
      FROM  DUAL;

    nCheckDigit := MOD(
                        TO_NUMBER(SUBSTR(vCertNo, 1 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 2 , 1)) * 2 +  
                        TO_NUMBER(SUBSTR(vCertNo, 3 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 4 , 1)) * 2 +  
                        TO_NUMBER(SUBSTR(vCertNo, 5 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 6 , 1)) * 2 + 
                        TO_NUMBER(SUBSTR(vCertNo, 7 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 8 , 1)) * 2 +  
                        TO_NUMBER(SUBSTR(vCertNo, 9 , 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 10, 1)) * 2 +  
                        TO_NUMBER(SUBSTR(vCertNo, 11, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 12, 1)) * 2 + 
                        TO_NUMBER(SUBSTR(vCertNo, 13, 1)) * 3 + TO_NUMBER(SUBSTR(vCertNo, 14, 1)) * 2
                       , 10);

    vCertNo := vCertNo || nCheckDigit;

    RETURN vCertNo;              
END FN_GET_CERT_NO;

/
