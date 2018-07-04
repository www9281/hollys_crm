--------------------------------------------------------
--  DDL for Function FN_GET_DC_DIV
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_DC_DIV" 
(
    PSV_COMP_CD   IN VARCHAR2,
    PSV_BRAND_CD  IN VARCHAR2
) RETURN VARCHAR2 IS
    vDC_DIV         DC.DC_DIV%TYPE  := 0;        -- 할인코드
    nDUP_CHECK      NUMBER(10)      := 0;
    nREC_COUNT      NUMBER(10)      := 0;
BEGIN
    LOOP
        nDUP_CHECK := 0;
        nREC_COUNT := nREC_COUNT + 1;

        -- Type별 차수 카드 생성
        SELECT  DC_DIV + nREC_COUNT INTO  vDC_DIV
        FROM   (
                SELECT  MAX(DC_DIV) DC_DIV
                FROM    DC
                WHERE   COMP_CD    = PSV_COMP_CD
                AND     MEMB_DC_FG = '00'
               ) X;

        SELECT  COUNT(*)
        INTO    nDUP_CHECK
        FROM    DC
        WHERE   COMP_CD = PSV_COMP_CD
        AND     DC_DIV  = vDC_DIV;

        EXIT WHEN nDUP_CHECK = 0;
    END LOOP;

    IF vDC_DIV > 99999 THEN
        vDC_DIV := NULL;
    END IF;

    RETURN vDC_DIV;              
END FN_GET_DC_DIV;

/
