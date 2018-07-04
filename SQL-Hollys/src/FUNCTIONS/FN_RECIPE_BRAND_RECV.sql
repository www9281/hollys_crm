--------------------------------------------------------
--  DDL for Function FN_RECIPE_BRAND_RECV
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RECIPE_BRAND_RECV" (vITEM_CD IN VARCHAR2)
RETURN VARCHAR2 IS
    CURSOR CUR_1 IS
        SELECT  *
        FROM    TABLE(FN_RECIPE_USE_L0  ('000','001','10',TO_CHAR(SYSDATE, 'YYYYMMDD'),vITEM_CD));

    MYREC       CUR_1%ROWTYPE;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        UPDATE RECIPE_BRAND_FOOD
        SET    RCP_QTY = MYREC.DO_QTY
        WHERE  ROWID = MYREC.C_ITEM_RID;
    END LOOP;

    RETURN '0';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN SQLERRM;
END FN_RECIPE_BRAND_RECV;

/
