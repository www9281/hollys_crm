--------------------------------------------------------
--  DDL for Function FN_GET_RECIPE_ITEM_COST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_RECIPE_ITEM_COST" (
                                                        PSV_COMP_CD     IN VARCHAR2, -- Company Code
                                                        PSV_BRAND_CD    IN VARCHAR2, -- Brand Code   
                                                        PSV_ITEM_CD     IN VARCHAR2  -- 원가분석 상품코드
                                                       ) 
RETURN NUMBER IS
    /****************************************************************/
    /*      레시피 월자재별 소요 단가 정보 취득 FUNCTION            */
    /*      레시피 원자재 기준 DATA(상품 -> 반재품 -> 상품 순)      */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT  1                            END_LEAFS,
                ITC.ITEM_CD                  P_ITEM_CD,
                ITC.ITEM_CD                  C_ITEM_CD,
                ITC.ITEM_NM                  ITEM_NM,
                ITC.WEIGHT_UNIT              RCP_QTY,
                ITC.WEIGHT_UNIT              WEIGHT_UNIT,
                ITC.YIELD_RATE               MAIN_YIL_RATE,
                ITC.COST/ITC.WEIGHT_UNIT     RATE_UNIT_COST
        FROM    ITEM_CHAIN   ITC
        WHERE   ITC.COMP_CD     =  PSV_COMP_CD
        AND     ITC.ITEM_CD     =  PSV_ITEM_CD
        AND     ITC.BRAND_CD    =  PSV_BRAND_CD
        AND     NOT EXISTS (SELECT  1
                            FROM    RECIPE_BRAND_FOOD RBF
                            WHERE   RBF.COMP_CD    = ITC.COMP_CD
                            AND     RBF.P_ITEM_CD  = ITC.ITEM_CD
                            AND     RBF.BRAND_CD   = ITC.BRAND_CD)
        UNION ALL
        SELECT CONNECT_BY_ISLEAF            END_LEAFS,
               RBF.P_ITEM_CD                P_ITEM_CD,
               RBF.C_ITEM_CD                C_ITEM_CD,
               IC1.ITEM_NM                  ITEM_NM,
               RBF.RCP_QTY                  RCP_QTY,
               IC2.WEIGHT_UNIT              WEIGHT_UNIT,
               IC2.YIELD_RATE               MAIN_YIL_RATE,
               CASE WHEN CONNECT_BY_ISLEAF = 0 THEN 0 
                    ELSE IC1.COST/IC1.WEIGHT_UNIT/NVL(IC1.YIELD_RATE, 1) 
                    END                     RATE_UNIT_COST
        FROM   RECIPE_BRAND_FOOD RBF,
               ITEM_CHAIN        IC1,
               ITEM_CHAIN        IC2
        WHERE  RBF.COMP_CD       = IC1.COMP_CD
          AND  RBF.BRAND_CD      = IC1.BRAND_CD
          AND  RBF.C_ITEM_CD     = IC1.ITEM_CD
          AND  RBF.COMP_CD       = IC2.COMP_CD
          AND  RBF.BRAND_CD      = IC2.BRAND_CD
          AND  RBF.P_ITEM_CD     = IC2.ITEM_CD
          AND  RBF.COMP_CD       = PSV_COMP_CD
          AND  RBF.BRAND_CD      = PSV_BRAND_CD
          AND  RBF.P_ITEM_CD     = PSV_ITEM_CD
        START WITH RBF.COMP_CD   = PSV_COMP_CD
               AND RBF.BRAND_CD  = PSV_BRAND_CD
               AND RBF.P_ITEM_CD = PSV_ITEM_CD
        CONNECT BY NOCYCLE PRIOR RBF.C_ITEM_CD = RBF.P_ITEM_CD;

    MYREC       CUR_1%ROWTYPE;
    nITEMCOST   NUMBER(11,3) := 0;
    nRTNCOST    NUMBER(11,3) := 0;
    nITEMAMT    NUMBER(11,3) := 0;
    nITEMCAPA   NUMBER(11,3) := 0;
    nITEMRATE   NUMBER(11,3) := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('IN PARAM : '|| PSV_COMP_CD||'/'||PSV_BRAND_CD||'/'||PSV_ITEM_CD);

    FOR MYREC IN CUR_1 LOOP
        DBMS_OUTPUT.PUT_LINE('IN PARAM 2 : '||MYREC.P_ITEM_CD||'/'||MYREC.C_ITEM_CD||'/'||MYREC.END_LEAFS);

        IF MYREC.END_LEAFS = 0 THEN
            nITEMCOST := FN_GET_RECIPE_ITEM_COST(PSV_COMP_CD, PSV_BRAND_CD, MYREC.C_ITEM_CD);
        ELSE
            nITEMCOST := MYREC.RATE_UNIT_COST;
        END IF;

        DBMS_OUTPUT.PUT_LINE(MYREC.P_ITEM_CD||'/'||MYREC.C_ITEM_CD||'/'||nITEMCOST);

        nITEMAMT  := nITEMAMT + (MYREC.RCP_QTY * nITEMCOST);
        nITEMCAPA := MYREC.WEIGHT_UNIT;
        nITEMRATE := MYREC.MAIN_YIL_RATE;
    END LOOP;

    nRTNCOST  :=  nITEMAMT / nITEMCAPA / nITEMRATE;

    DBMS_OUTPUT.PUT_LINE(nITEMAMT||'/'||nITEMCAPA||'/'||nITEMRATE||'/'||nRTNCOST);

    RETURN nRTNCOST;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0; 
END FN_GET_RECIPE_ITEM_COST;

/
