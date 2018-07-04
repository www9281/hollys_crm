--------------------------------------------------------
--  DDL for Procedure SP_SET_RCP_FOOD_0030
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_RCP_FOOD_0030" (PSV_COMP_CD  IN VARCHAR2,  -- 회사코드
                                                      PSV_BRAND_CD IN VARCHAR2,  -- 브랜드코드
                                                      PSV_RTN_CD   OUT VARCHAR2, -- 처리결과코드
                                                      PSV_RTN_MSG  OUT VARCHAR2) -- 처리결과메시지
IS
    CURSOR CUR_1 IS
        SELECT  RB1.COMP_CD
             ,  RB1.BRAND_CD
             ,  RB1.C_ITEM_CD
          FROM  RECIPE_BRAND_FOOD RB1
             ,  ITEM              ITM
         WHERE  RB1.COMP_CD     = ITM.COMP_CD
           AND  RB1.C_ITEM_CD   = ITM.ITEM_CD
           AND  RB1.COMP_CD     = PSV_COMP_CD
           AND  RB1.BRAND_CD    = PSV_BRAND_CD
           AND  RB1.CLOSE_DT   >= TO_CHAR(SYSDATE, 'YYYYMMDD')
           AND  RB1.USE_YN     = 'Y'
           AND  ITM.RECIPE_DIV IN ('1', '3')
         GROUP  BY RB1.COMP_CD, RB1.BRAND_CD, RB1.C_ITEM_CD;

    MYREC       CUR_1%ROWTYPE;
BEGIN
    PSV_RTN_CD  := '0';
    PSV_RTN_MSG := NULL;

    FOR MYREC IN CUR_1 LOOP
        SP_SET_RCP_FOOD_0010(MYREC.COMP_CD, MYREC.BRAND_CD, MYREC.C_ITEM_CD, PSV_RTN_CD, PSV_RTN_MSG);
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
