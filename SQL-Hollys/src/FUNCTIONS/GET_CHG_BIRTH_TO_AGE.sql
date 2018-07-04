--------------------------------------------------------
--  DDL for Function GET_CHG_BIRTH_TO_AGE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_CHG_BIRTH_TO_AGE" 
(
    PSV_COMP_CD     IN  VARCHAR2,
    PSV_CUST_ID     IN  VARCHAR2
) 
RETURN              VARCHAR2 IS
    L_RET_VALUE     NUMBER := 0;
BEGIN
    SELECT CASE WHEN REGEXP_INSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1 THEN
                     TRUNC((TO_CHAR(SYSDATE, 'YYYYMM') - SUBSTR(CASE WHEN LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE BIRTH_DT END, 1, 6)) / 100 + 1)
                ELSE 999 
            END
    INTO    L_RET_VALUE
    FROM    C_CUST
    WHERE   COMP_CD = PSV_COMP_CD
    AND     CUST_ID = PSV_CUST_ID;

    RETURN L_RET_VALUE;
EXCEPTION 
    WHEN OTHERS THEN
    RETURN 0;
END GET_CHG_BIRTH_TO_AGE;

/
