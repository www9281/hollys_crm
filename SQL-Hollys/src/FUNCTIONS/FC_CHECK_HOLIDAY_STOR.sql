--------------------------------------------------------
--  DDL for Function FC_CHECK_HOLIDAY_STOR
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FC_CHECK_HOLIDAY_STOR" (
                                                  PSV_COMP_CD  IN VARCHAR2, -- Company Code
                                                  PSV_BRAND_CD IN VARCHAR2, -- Brand Code
                                                  PSV_STOR_CD IN VARCHAR2, -- Stor Code
                                                  PSV_START_DT IN VARCHAR2  -- Input Parameter
                                                 )
RETURN VARCHAR IS
    CURSOR CUR_1 IS
        SELECT  SUM(CASE WHEN C.VAL_C1 = '1' THEN 1 ELSE 0 END) HOLI_CNT,
                SUM(CASE WHEN C.VAL_C1 = '1' THEN 0 ELSE 1 END) MEMO_CNT
        FROM    STORE_HOLIDAY   H
             ,  COMMON             C
        WHERE   H.HOL_DIV  = C.CODE_CD
        AND     H.COMP_CD  = C.COMP_CD
        AND     H.COMP_CD  = PSV_COMP_CD
        AND     H.BRAND_CD = PSV_BRAND_CD
        AND     H.STOR_CD = PSV_STOR_CD
        AND     H.START_DT = PSV_START_DT
        AND     H.USE_YN = 'Y'
        AND     C.CODE_TP  = '01015';

    vDavDiv         VARCHAR2(1) := '';   -- 요일구분[1:평일, 2:토요일, 3:일요일/국경일]

BEGIN
    FOR MYREC IN CUR_1 LOOP
        IF MYREC.HOLI_CNT >  0  THEN
            vDavDiv := '4'; -- 공휴일
        ELSIF MYREC.MEMO_CNT >  0  THEN
            vDavDiv := '3'; -- 공휴일
        ELSE
            SELECT  CASE DAY_NUM_IN_WEEK WHEN '7' THEN '3'
                                         WHEN '6' THEN '2'
                                         ELSE '1'
                    END
            INTO    vDavDiv
            FROM    CALENDAR
            WHERE  YMD = PSV_START_DT;
        END IF;
    END LOOP;

    RETURN vDavDiv;

EXCEPTION  WHEN OTHERS THEN
    RETURN '0';

END FC_CHECK_HOLIDAY_STOR;

/
