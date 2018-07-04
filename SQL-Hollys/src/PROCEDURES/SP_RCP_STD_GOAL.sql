--------------------------------------------------------
--  DDL for Procedure SP_RCP_STD_GOAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_RCP_STD_GOAL" (   
                                                    PSV_COMP_CD IN  VARCHAR2,   -- 회사코드
                                                    PSV_STD_YM  IN  VARCHAR2,   -- 대상년월
                                                    PSV_EXE_FLG IN  VARCHAR2    -- A:ALL, R:RCP,G:GOAL
                                                 ) IS
    /* 실행원가 작성 PROCEDURE */                                             
    CURSOR  CUR_1 IS
        SELECT  COMP_CD,
                BRAND_CD
        FROM    BRAND
        WHERE   COMP_CD     = PSV_COMP_CD
        AND     USE_YN      = 'Y';

    MYREC       CUR_1%ROWTYPE;
    vPROCYM     VARCHAR2(6)    := NULL;
    vRTNCOD     VARCHAR2(2000) := NULL;
    vRTNMSG     VARCHAR2(2000) := NULL;    
BEGIN
    --IF TO_CHAR(SYSDATE, 'DD') IN ('01','02','03','04','05') THEN
        FOR MYREC IN CUR_1 LOOP
            vPROCYM := NVL(PSV_STD_YM, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'));

            -- 레시피 실행원가
            IF PSV_COMP_CD = '012' THEN
                vRTNMSG := FN_RCP_STD_0014(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM);
            ELSE
                vRTNMSG := FN_RCP_STD_0010(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM);
            END IF;

            IF vRTNMSG != '0' THEN
                DBMS_OUTPUT.PUT_LINE('RCP : ' ||vRTNMSG);
                ROLLBACK;
                CONTINUE; -- 에러나는 브랜드 제외하고 처리
            END IF;

            -- 손익
            IF PSV_COMP_CD = '012' THEN
                SP_SET_PL_GOAL_0011(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM, vRTNCOD, vRTNMSG);
            ELSE
                SP_SET_PL_GOAL_0010(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM, vRTNCOD, vRTNMSG);
            END IF;

            IF vRTNCOD != '0' THEN
                DBMS_OUTPUT.PUT_LINE('GOAL : ' ||vRTNMSG);
                ROLLBACK;
                EXIT;
            END IF;
        END LOOP;
    --END IF;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXCEPTION : ' ||SQLERRM);
        RETURN;
END SP_RCP_STD_GOAL;

/
