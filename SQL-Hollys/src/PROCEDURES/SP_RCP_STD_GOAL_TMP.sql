--------------------------------------------------------
--  DDL for Procedure SP_RCP_STD_GOAL_TMP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_RCP_STD_GOAL_TMP" (PSV_COMP_CD IN  VARCHAR2) 
IS
    /* 실행원가 작성 PROCEDURE */                                             
    CURSOR  CUR_1 IS
        SELECT  COMP_CD,
                BRAND_CD
        FROM    BRAND
        WHERE   COMP_CD     = PSV_COMP_CD
        AND     USE_YN      = 'Y';

    MYREC       CUR_1%ROWTYPE;
    vPROCYM     VARCHAR2(6)    := '201509';
    vRTNCOD     VARCHAR2(2000) := NULL;
    vRTNMSG     VARCHAR2(2000) := NULL;
    LOOPCNT     NUMBER         := 0;    
BEGIN
    IF TO_CHAR(SYSDATE, 'DD') IN ('01','02','03','04','05') THEN
        FOR MYREC IN CUR_1 LOOP
        --    LOOP
        --        EXIT WHEN LOOPCNT > 4;
        --        vPROCYM := TO_CHAR(ADD_MONTHS(TO_DATE(vPROCYM, 'YYYYMM'), LOOPCNT), 'YYYYMM');
        --        LOOPCNT := LOOPCNT + 1;

                -- 레시피 실행원가
                vRTNMSG := FN_RCP_STD_0014(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM);

                IF vRTNMSG != '0' THEN
                    DBMS_OUTPUT.PUT_LINE('RCP : ' ||vRTNMSG);
                    ROLLBACK;
                    CONTINUE; -- 에러나는 브랜드 제외하고 처리
                END IF;
        --    END LOOP;
        END LOOP;
    END IF;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION : ' ||SQLERRM);
        RETURN;
END SP_RCP_STD_GOAL_TMP;

/
