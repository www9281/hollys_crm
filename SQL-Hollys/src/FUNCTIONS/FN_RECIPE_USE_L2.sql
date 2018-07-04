--------------------------------------------------------
--  DDL for Function FN_RECIPE_USE_L2
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RECIPE_USE_L2" (
                                                PSV_COMP_CD     IN VARCHAR2, -- Company Code
                                                PSV_BRAND_CD    IN VARCHAR2, -- Brand Code
                                                PSV_STOR_TP     IN VARCHAR2, -- 점포코드
                                                PSV_STD_YMD     IN VARCHAR2, -- 기준년월일
                                                PSV_ITEM_CD     IN VARCHAR2  -- 메뉴코드
                                               )
RETURN VARCHAR2 AS
    /****************************************************************/
    /*      레시피 브렌드 테이블 사용량 갱신(RCP_QTY)               */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT *
        FROM   TABLE(FN_RECIPE_USE_L0(PSV_COMP_CD,PSV_BRAND_CD,PSV_STOR_TP,PSV_STD_YMD,PSV_ITEM_CD));

    MYREC           CUR_1%ROWTYPE;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        UPDATE RECIPE_BRAND_FOOD
        SET    RCP_QTY = MYREC.DO_QTY
        WHERE  ROWID   = MYREC.C_ITEM_RID;
    END LOOP;

    COMMIT;

    RETURN '0';
EXCEPTION
    WHEN OTHERS THEN
        --PSV_ERR_MSG := SQLERRM;

        RETURN SQLERRM; 
END FN_RECIPE_USE_L2;

/
