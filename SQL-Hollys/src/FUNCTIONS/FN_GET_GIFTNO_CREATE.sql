--------------------------------------------------------
--  DDL for Function FN_GET_GIFTNO_CREATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_GIFTNO_CREATE" 
(
    PSV_COMP_CD IN VARCHAR2, -- 회사코드
    PSV_IN_DT   IN VARCHAR2, -- 발행일자
    PSV_IN_SEQ  IN VARCHAR2  -- 발행순번
) RETURN VARCHAR2 IS
    -- LOCAL 변수            
    vCOMP_CD_ABBR   VARCHAR2(01) := 'P';    -- 회사약어    
    vGIFT_CD        VARCHAR2(02) := NULL;   -- 권종코드
    vGIFT_NO        VARCHAR2(16) := NULL;   -- 상품권번호

    nRECCNT1        NUMBER       := 0;      -- 체크용
    nRECCNT2        NUMBER       := 0;      -- 체크용

BEGIN
    BEGIN
        SELECT  GIFT_CD INTO vGIFT_CD
        FROM    GIFT_IN_HD
        WHERE   COMP_CD = PSV_COMP_CD
        AND     IN_DT   = PSV_IN_DT
        AND     IN_SEQ  = PSV_IN_SEQ;

        LOOP
            -- 상품권번호 채번
            SELECT  X.GIFT_NO || MOD( SUBSTR(X.GIFT_NO, 2, 1)*1 + SUBSTR(X.GIFT_NO, 3, 1)*3 
                                    + SUBSTR(X.GIFT_NO, 4, 1)*1 + SUBSTR(X.GIFT_NO, 5, 1)*3 
                                    + SUBSTR(X.GIFT_NO, 6, 1)*1 + SUBSTR(X.GIFT_NO, 7, 1)*3
                                    + SUBSTR(X.GIFT_NO, 8, 1)*1 + SUBSTR(X.GIFT_NO, 9, 1)*3 
                                    + SUBSTR(X.GIFT_NO,10, 1)*1 + SUBSTR(X.GIFT_NO,11, 1)*3 
                                    + SUBSTR(X.GIFT_NO,12, 1)*1 + SUBSTR(X.GIFT_NO,13, 1)*3
                                    + SUBSTR(X.GIFT_NO,14, 1)*1 + SUBSTR(X.GIFT_NO,15, 1)*3, 10)
            INTO    vGIFT_NO
            FROM   (
                    SELECT vCOMP_CD_ABBR || SUBSTR(PSV_IN_DT, 3, 4) || vGIFT_CD || TO_CHAR(ROUND(dbms_random.value(11111111, 99999999)), 'FM00000000')  GIFT_NO
                    FROM DUAL
                   ) X;

            -- 상품권 마스터 체크                   
            SELECT  COUNT(*) INTO nRECCNT1
            FROM    GIFT_MST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     GIFT_NO = vGIFT_NO;

            -- 상품권 마스터 체크                   
            SELECT  COUNT(*) INTO nRECCNT2
            FROM    GIFT_IN_DT
            WHERE   COMP_CD = PSV_COMP_CD
            AND     GIFT_NO = vGIFT_NO;

            EXIT WHEN (nRECCNT1 + nRECCNT2) = 0;
        END LOOP;
    END;

    RETURN vGIFT_NO;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;    
END FN_GET_GIFTNO_CREATE;

/
