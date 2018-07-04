--------------------------------------------------------
--  DDL for Function FN_SET_RCP_FOOD_0010
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_SET_RCP_FOOD_0010" (PSV_COMP_CD  IN VARCHAR2,  -- 회사코드
                                                     PSV_BRAND_CD IN VARCHAR2,  -- 브랜드코드
                                                     PSV_ITEM_CD  IN VARCHAR2)  -- 상품코드(레시피 재계산 메뉴 OR 반제품)
RETURN VARCHAR2 IS
    CURSOR CUR_1 IS
        SELECT  RB1.COMP_CD,
                RB1.BRAND_CD,
                RB1.P_ITEM_CD,
                RB1.C_ITEM_CD,
                RB1.START_DT,
                RB1.DO_QTY,
                ITM.PROD_QTY,
                RB1.DO_QTY/ITM.PROD_QTY PER_UNIT_QTY,
                RB1.ROWID C_ITEM_RID
        FROM    RECIPE_BRAND_FOOD RB1,
                ITEM              ITM
        WHERE   ITM.ITEM_CD    = RB1.P_ITEM_CD
        AND     RB1.COMP_CD    = PSV_COMP_CD
        AND     RB1.BRAND_CD   = PSV_BRAND_CD
        AND     RB1.CLOSE_DT  >= TO_CHAR(SYSDATE, 'YYYYMMDD')
        AND     EXISTS( SELECT  1
                        FROM    RECIPE_BRAND_FOOD RB2
                        WHERE   RB2.COMP_CD   = RB1.COMP_CD
                        AND     RB2.BRAND_CD  = RB1.BRAND_CD
                        AND     RB2.C_ITEM_CD = RB1.P_ITEM_CD /* ▼ NULL :전체, 그외 제품 */
                        AND     RB2.C_ITEM_CD = NVL(PSV_ITEM_CD, RB2.C_ITEM_CD)
                        AND     RB2.P_ITEM_CD = ' ')
        ORDER BY P_ITEM_CD, C_ITEM_CD;

    MYREC       CUR_1%ROWTYPE;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        UPDATE RECIPE_BRAND_FOOD
        SET    RCP_QTY = MYREC.PER_UNIT_QTY
        WHERE  ROWID   = MYREC.C_ITEM_RID;
    END LOOP;

    COMMIT;

    RETURN '0';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN SQLERRM;
END;

/
