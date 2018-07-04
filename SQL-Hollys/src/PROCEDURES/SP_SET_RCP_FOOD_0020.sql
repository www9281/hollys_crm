--------------------------------------------------------
--  DDL for Procedure SP_SET_RCP_FOOD_0020
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_RCP_FOOD_0020" (PSV_COMP_CD  IN VARCHAR2,  -- 회사코드
                                                      PSV_REV_YM   IN VARCHAR2,  -- 대상년월
                                                      PSV_REV_VER  IN VARCHAR2,  -- 대상버전
                                                      PSV_BRAND_CD IN VARCHAR2,  -- 브랜드코드
                                                      PSV_ITEM_CD  IN VARCHAR2,  -- 상품코드(레시피 재계산 메뉴 OR 반제품)
                                                      PSV_RTN_CD   OUT VARCHAR2, -- 처리결과코드
                                                      PSV_RTN_MSG  OUT VARCHAR2) -- 처리결과메시지
IS
    CURSOR CUR_1 IS
        SELECT  RB1.COMP_CD,
                RB1.BRAND_CD,
                RB1.P_ITEM_CD,
                RB1.C_ITEM_CD,
                RB1.START_DT,
                RB1.DO_QTY,
                ITM.PROD_QTY,
                RB1.LOSS_RATE,
                RB1.ROWID C_ITEM_RID
        FROM    RECIPE_BRAND_FOOD_REV RB1,
                ITEM                  ITM
        WHERE   ITM.ITEM_CD    = RB1.P_ITEM_CD
        AND     RB1.COMP_CD    = PSV_COMP_CD
        AND     RB1.REV_YM     = PSV_REV_YM
        AND     RB1.REV_VER    = PSV_REV_VER
        AND     RB1.BRAND_CD   = PSV_BRAND_CD
        AND     RB1.USE_YN     = 'Y'
        AND     EXISTS( SELECT  1
                        FROM    RECIPE_BRAND_FOOD_REV RB2
                        WHERE   RB2.COMP_CD   = RB1.COMP_CD
                        AND     RB2.REV_YM    = RB1.REV_YM
                        AND     RB2.REV_VER   = RB1.REV_VER
                        AND     RB2.BRAND_CD  = RB1.BRAND_CD
                        AND     RB2.C_ITEM_CD = RB1.P_ITEM_CD /* ▼ NULL :전체, 그외 제품 */
                        AND     RB2.C_ITEM_CD = NVL(PSV_ITEM_CD, RB2.C_ITEM_CD)
                        AND     RB2.P_ITEM_CD = ' ')
        ORDER BY P_ITEM_CD, C_ITEM_CD;

    MYREC       CUR_1%ROWTYPE;
BEGIN
    PSV_RTN_CD  := '0';
    PSV_RTN_MSG := NULL;

    FOR MYREC IN CUR_1 LOOP
        IF MYREC.PROD_QTY = 0 THEN
            PSV_RTN_CD  := '-9000';
            PSV_RTN_MSG := 'PROD_QTY MUST HAVE A VALUES';

            ROLLBACK;
            EXIT;
        END IF;

        UPDATE RECIPE_BRAND_FOOD_REV
        SET    RCP_QTY = MYREC.DO_QTY/MYREC.PROD_QTY * (1 + MYREC.LOSS_RATE / 100)
        WHERE  ROWID   = MYREC.C_ITEM_RID;
    END LOOP;

    -- 정상처리 완료
    COMMIT;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := '-9999';
        PSV_RTN_MSG := SQLERRM;

        -- 취소 처리
        ROLLBACK;

        RETURN;
END;

/
