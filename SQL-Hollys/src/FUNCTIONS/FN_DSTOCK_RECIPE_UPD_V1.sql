--------------------------------------------------------
--  DDL for Function FN_DSTOCK_RECIPE_UPD_V1
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_DSTOCK_RECIPE_UPD_V1" (vCOMP_CD IN VARCHAR2) 
RETURN VARCHAR2 IS
    CURSOR CUR_1 IS
        SELECT  JDM.COMP_CD, 
                JDM.BRAND_CD, 
                JDM.STOR_CD, 
                JDM.ITEM_CD, 
                JDM.SALE_DT, 
                JDM.SALE_QTY,
                STO.STOR_TP,
                ITM.STOCK_DIV,
                ITM.SALE_UNIT_QTY
        FROM    SALE_JDM    JDM,
                ITEM        ITM,
                STORE       STO
        WHERE   JDM.COMP_CD  = STO.COMP_CD
        AND     JDM.BRAND_CD = STO.BRAND_CD
        AND     JDM.STOR_CD  = STO.STOR_CD 
        AND     JDM.COMP_CD = ITM.COMP_CD
        AND     JDM.ITEM_CD = ITM.ITEM_CD
        AND     JDM.COMP_CD = '001'
        AND     JDM.SALE_DT LIKE '201402%';

    CURSOR CUR_2(vCOMP_CD VARCHAR2, vBRAND_CD VARCHAR2, vSTOR_TP VARCHAR2, vITEM_CD VARCHAR2, vSTD_YMD VARCHAR) IS
        SELECT  A.COMP_CD      COMP_CD
             ,  A.BRAND_CD     BRAND_CD
             ,  A.C_ITEM_CD    C_ITEM_CD
             ,  A.DO_UNIT      DO_UNIT
             ,  B.STOCK_DIV    STOCK_DIV
             ,  B.SALE_UNIT_QTY
             ,  SUM(A.DO_QTY)  RCP_QTY
             ,  SUM(A.DO_COST) RCP_COST
        FROM    TABLE(FN_RECIPE_USE_L0(vCOMP_CD, vBRAND_CD, vSTOR_TP, vITEM_CD, vSTD_YMD)) A,
                ITEM   B
        WHERE   B.ITEM_CD = A.C_ITEM_CD        
        GROUP BY 
                A.COMP_CD, 
                A.BRAND_CD, 
                A.C_ITEM_CD, 
                A.DO_UNIT,
                B.STOCK_DIV,
                B.SALE_UNIT_QTY;

    MYREC1      CUR_1%ROWTYPE;
    MYREC2      CUR_2%ROWTYPE;
    nRECCNT     NUMBER(5) := 0;
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        SELECT COUNT(*) INTO nRECCNT
        FROM   RECIPE_BRAND_FOOD
        WHERE  COMP_CD   = MYREC1.COMP_CD
        AND    BRAND_CD  = MYREC1.BRAND_CD
        AND    P_ITEM_CD = MYREC1.ITEM_CD
        AND    CLOSE_DT >= MYREC1.SALE_DT;

        IF nRECCNT = 0 THEN
            IF MYREC1.STOCK_DIV IN ('A', 'D') THEN 
                UPDATE  DSTOCK
                SET     SALE_QTY = SALE_QTY + (MYREC1.SALE_QTY * MYREC1.SALE_UNIT_QTY)
                WHERE   COMP_CD  = MYREC1.COMP_CD
                AND     BRAND_CD = MYREC1.BRAND_CD
                AND     STOR_CD  = MYREC1.STOR_CD
                AND     ITEM_CD  = MYREC1.ITEM_CD
                AND     PRC_DT   = MYREC1.SALE_DT;
            END IF;    
        ELSE
            FOR MYREC2 IN CUR_2(MYREC1.COMP_CD, MYREC1.BRAND_CD, MYREC1.STOR_TP, MYREC1.ITEM_CD, MYREC1.SALE_DT) LOOP
                IF MYREC2.STOCK_DIV IN ('A', 'D') THEN 
                    UPDATE  DSTOCK
                    SET     SALE_QTY = SALE_QTY + (MYREC1.SALE_QTY * MYREC2.RCP_QTY * MYREC2.SALE_UNIT_QTY)
                    WHERE   COMP_CD  = MYREC1.COMP_CD
                    AND     BRAND_CD = MYREC1.BRAND_CD
                    AND     STOR_CD  = MYREC1.STOR_CD
                    AND     ITEM_CD  = MYREC2.C_ITEM_CD
                    AND     PRC_DT   = MYREC1.SALE_DT;
                END IF;    
            END LOOP;
        END IF;    
    END LOOP;

    COMMIT;

    RETURN '0';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN SQLERRM;
END;

/
