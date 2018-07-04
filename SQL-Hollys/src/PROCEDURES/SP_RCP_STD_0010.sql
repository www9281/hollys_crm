--------------------------------------------------------
--  DDL for Procedure SP_RCP_STD_0010
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_RCP_STD_0010" (   
                                                    PSV_COMP_CD IN  VARCHAR2,
                                                    PSV_STD_YM  IN  VARCHAR2,
                                                    PSV_RTN_CD  OUT VARCHAR2,
                                                    PSV_RTN_MSG OUT VARCHAR2
                                                 ) IS
    /* 매일유업 실행원가 작성 PROCEDURE */                                             
    CURSOR  CUR_1 IS
        SELECT  COMP_CD,
                BRAND_CD
        FROM    BRAND
        WHERE   COMP_CD = PSV_COMP_CD
          AND   USE_YN  = 'Y';

    MYREC       CUR_1%ROWTYPE;
    vPROCYM     VARCHAR2(6)    := NULL;
    vRTNMSG     VARCHAR2(2000) := NULL;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        vPROCYM := NVL(PSV_STD_YM, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'));

        vRTNMSG := FN_RCP_STD_0010(MYREC.COMP_CD, MYREC.BRAND_CD, vPROCYM);

        IF vRTNMSG != '0' THEN
            PSV_RTN_CD  := SUBSTR(vRTNMSG, 1, 1);
            PSV_RTN_MSG := SUBSTR(vRTNMSG, 2, LENGTHB(vRTNMSG) - 1);

            EXIT;
        END IF;    
    END LOOP;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := TO_CHAR(SQLCODE);
        PSV_RTN_MSG := SQLERRM;
        RETURN;
END SP_RCP_STD_0010;

/
