--------------------------------------------------------
--  DDL for Function FN_GET_COUPON_CERT
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_COUPON_CERT" 
( 
    PSV_COMP_CD     IN  VARCHAR2, -- 브랜드코드
    PSV_CUST_STAT   IN  VARCHAR2, -- 브랜드코드
    PSV_RTN_CD      OUT NUMBER  , -- 응답코드
    PSV_RTN_MSG     OUT VARCHAR2  -- 응답메시지
)
RETURN VARCHAR2 IS
    vCERTCODE C_COUPON_CUST.CERT_NO%TYPE := NULL;
BEGIN
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := 'OK';
    
    SELECT  CASE WHEN PSV_CUST_STAT IN ('3', '7') THEN 'U0'
                 ELSE 'C0'
            END                                                                      || -- 쿠폰 인증법호 영문자 고정(C0)
            SUBSTR(TO_CHAR(ORA_HASH(PSV_COMP_CD, 100), '000'), 2)                    || -- 영업조직 해쉬값 3자리 000 ~ 999
            SUBSTR(TO_CHAR(SYSDATE, 'YYYY'), 3, 2)                                   || -- 년 2자리    14 ~ 99
            CHR(TO_NUMBER(TO_CHAR(SYSDATE, 'MM')) + 64)                              || -- 월 1자리    A  ~ L
            SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 2, 1)                         || -- 순번 1자리  0  ~ 9
            TO_CHAR(SYSDATE, 'DD')                                                   || -- 일 2자리    01 ~ 31
            SUBSTR(TO_CHAR(LEVEL + CERT_CNT,  '00000'),  3, 1)                       || -- 순번 1자리  0  ~ 9
            CHR(TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) + 64)                            || -- 시간 1자리  A  ~ Y
            SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 4, 1)                         || -- 순번 1자리  0  ~ 9
            TO_CHAR(SYSDATE, 'MI')                                                   || -- 분   2자리  00 ~ 59
            SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 5, 1)                         || -- 순번 1자리  0  ~ 9
            TO_CHAR(SYSDATE, 'SS')                                                   || -- 초   2자리  00 ~ 59
            SUBSTR(TO_CHAR(LEVEL + CERT_CNT, '00000'), 6, 1)            AS CERT_NO      -- 순번 1자리  0  ~ 9
    INTO    vCERTCODE      
    FROM  (
            SELECT  MOD(COUNT(*), 99999) AS CERT_CNT
            FROM    C_COUPON_CUST
            WHERE   COMP_CD = PSV_COMP_CD
          )
    CONNECT  BY ROWNUM <= 1;
    
    RETURN vCERTCODE;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD := SQLCODE;
        PSV_RTN_CD := SQLERRM;
END;

/
