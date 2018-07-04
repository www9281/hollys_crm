--------------------------------------------------------
--  DDL for Function FN_RCP_STD_0041
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RCP_STD_0041" (
                                                  PSV_COMP_CD     IN VARCHAR2, -- 회사코드
                                                  PSV_BRAND_CD    IN VARCHAR2, -- 영업조직
                                                  PSV_STD_YM      IN VARCHAR2  -- 조회기준년월
                                                 )
RETURN TBL_RECIPE_BRAND_FOOD AS
    /****************************************************************/
    /*      레시피 원자재 기준 DATA(상품 -> 반재품 -> 원자재 순)    */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT  RCP.COMP_CD,
                RCP.BRAND_CD,
                ITC.STOR_TP,
                RCP.R_ITEM_CD,
                RCP.IS_LEAF,
                RCP.IS_LVL,
                RCP.P_ITEM_CD,
                RCP.RCP_ITEM_CD,
                RCP.RCP_DIV,
                RCP.START_DT,
                RCP.CLOSE_DT,
                RCP.RCP_QTY,
                RCP.REUSE_YN,
                RCP.USE_YN,
                RCP.ITEM_TOT_QTY,
                ITC.ORD_UNIT_QTY,
                ITC.SALE_UNIT_QTY,
                ITC.DO_UNIT,
                NVL(ICH.COST, ITC.COST) AS COST,
                ITC.RECIPE_DIV,
                NVL(ITC.YIELD_RATE,  1) AS YIELD_RATE,
                NVL(ICH.COST, ITC.COST) * ITC.SALE_UNIT_QTY / ITC.ORD_UNIT_QTY / NVL(ITC.WEIGHT_UNIT, 1)  AS UNIT_PRICE,
                NVL(ITC.WEIGHT_UNIT, 1) AS WEIGHT_UNIT,
                RCP.RID,
                RCP.R_NUM,
                ROW_NUMBER() OVER(PARTITION BY RCP.COMP_CD, RCP.BRAND_CD, RCP.R_ITEM_CD ORDER BY RCP.R_NUM)  AS R_ITEM_SEQ
        FROM    ITEM_CHAIN ITC,
               (
                SELECT  ICH.COMP_CD,
                        ICH.BRAND_CD,
                        ICH.STOR_TP,
                        ICH.ITEM_CD,
                        ICH.COST,
                        ROW_NUMBER() OVER(PARTITION BY ICH.COMP_CD, ICH.BRAND_CD, ICH.STOR_TP, ICH.ITEM_CD ORDER BY ICH.START_DT DESC) R_NUM
                FROM    ITEM_CHAIN_HIS ICH
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     BRAND_CD  = PSV_BRAND_CD
                AND     START_DT <= PSV_STD_YM||'31'
               ) ICH,
               (     
                SELECT  RCB.COMP_CD,
                        RCB.BRAND_CD,
                        CONNECT_BY_ROOT(RCB.ITEM_CD)    AS R_ITEM_CD,
                        CONNECT_BY_ISLEAF               AS IS_LEAF,
                        LEVEL                           AS IS_LVL,
                        RCB.ITEM_CD                     AS P_ITEM_CD,
                        RCB.RCP_ITEM_CD,
                        RCB.RCP_DIV,
                        RCB.START_DT,
                        RCB.CLOSE_DT,
                        RCB.RCP_QTY,
                        RCB.REUSE_YN,
                        RCB.USE_YN,
                        RCB.ITEM_TOT_QTY,
                        RCB.RID,
                        ROWNUM                          AS R_NUM
                FROM   (
                        SELECT  RB.COMP_CD,
                                RB.BRAND_CD,
                                RB.ITEM_CD,
                                RB.RCP_ITEM_CD,
                                RB.RCP_DIV,
                                RB.START_DT,
                                RB.CLOSE_DT,
                                RB.RCP_QTY,
                                RB.REUSE_YN,
                                RB.USE_YN,
                                SUM(RB.RCP_QTY) 
                                    OVER(PARTITION BY RB.COMP_CD, RB.BRAND_CD, RB.ITEM_CD) ITEM_TOT_QTY,
                                RB.ROWID RID
                        FROM    RECIPE_BRAND RB,
                                ITEM         IT
                        WHERE   IT.COMP_CD   = RB.COMP_CD
                        AND     IT.ITEM_CD   = RB.RCP_ITEM_CD
                        AND     RB.COMP_CD   = PSV_COMP_CD
                        AND     RB.BRAND_CD  = PSV_BRAND_CD
                        AND     RB.START_DT <= PSV_STD_YM||'31'
                        AND     RB.CLOSE_DT >= PSV_STD_YM||'01'
                       ) RCB
                START WITH RCP_DIV = '1'
                CONNECT BY 
                        PRIOR RCP_ITEM_CD = ITEM_CD
                AND     PRIOR BRAND_CD    = BRAND_CD
                AND     PRIOR COMP_CD     = COMP_CD
                ORDER SIBLINGS BY ITEM_CD, RCP_ITEM_CD
               ) RCP
        WHERE   ITC.COMP_CD  = RCP.COMP_CD
        AND     ITC.BRAND_CD = RCP.BRAND_CD
        AND     ITC.ITEM_CD  = RCP.RCP_ITEM_CD
        AND     ITC.COMP_CD  = ICH.COMP_CD (+)
        AND     ITC.BRAND_CD = ICH.BRAND_CD(+)
        AND     ITC.STOR_TP  = ICH.STOR_TP (+)
        AND     ITC.ITEM_CD  = ICH.ITEM_CD (+)
        AND     1            = ICH.R_NUM   (+)
        ORDER BY 
                RCP.COMP_CD,
                RCP.BRAND_CD,
                ITC.STOR_TP,
                RCP.R_NUM;

    MYREC               CUR_1%ROWTYPE;
    RCP_RESULT_S        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- SINGLE RECORD
    RCP_RESULT_M        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- MULTI RECORD
    nP_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 무모 레시피 사용량
    nC_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 자식 레시피 사용량
    nC_ITEM_RCP_COST    NUMBER(15, 6) := 1;                                 -- 자식 레시피 원가
    nTMP_IS_LVL         NUMBER(5)     := 0;                                 -- 레벨 비교용
    vTMP_ITEM_CD        VARCHAR2(200) := NULL;

    TYPE T_P_ITEM IS TABLE OF RECIPE_BRAND_FOOD.DO_QTY%TYPE INDEX BY BINARY_INTEGER;
    TMP_P_ITEM  T_P_ITEM;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        IF (MYREC.R_ITEM_SEQ = 1 OR MYREC.R_ITEM_CD = MYREC.P_ITEM_CD) THEN
            nP_ITEM_RCP_QTY := 1;

            -- 레시피 레벨 및 부모의 중량 저장
            nTMP_IS_LVL := MYREC.IS_LVL;
            TMP_P_ITEM(MYREC.IS_LVL) := nP_ITEM_RCP_QTY;
        END IF;

        -- 레벨이 증가하면 현재 부모의 중량을 저장
        IF nTMP_IS_LVL != MYREC.IS_LVL THEN
            IF nTMP_IS_LVL > MYREC.IS_LVL THEN
                nP_ITEM_RCP_QTY := TMP_P_ITEM(MYREC.IS_LVL);
            ELSE
                TMP_P_ITEM(MYREC.IS_LVL) := nP_ITEM_RCP_QTY;
            END IF;
        END IF;

        -- 소모량
        IF MYREC.IS_LVL = 1 THEN
            -- 수율 적용(2014/0427 MODIFY BY JSS)
            IF MYREC.YIELD_RATE = 0 THEN
                nC_ITEM_RCP_QTY := MYREC.RCP_QTY;
            ELSE
                nC_ITEM_RCP_QTY := ROUND(MYREC.RCP_QTY / MYREC.YIELD_RATE, 6);
            END IF;    
        ELSE
            -- 수율 적용(2014/0427 MODIFY BY JSS)
            IF MYREC.YIELD_RATE = 0 THEN
                nC_ITEM_RCP_QTY := ROUND(nP_ITEM_RCP_QTY * (MYREC.RCP_QTY / MYREC.ITEM_TOT_QTY), 6);
            ELSE
                nC_ITEM_RCP_QTY := ROUND(nP_ITEM_RCP_QTY * (MYREC.RCP_QTY / MYREC.ITEM_TOT_QTY) / MYREC.YIELD_RATE, 6);
            END IF;    
        END IF;

        -- 레시피의 최종 LEAF이면(0:자식레코드 있음, 1:최종 레코드)
        IF MYREC.IS_LEAF = 0 THEN
            nP_ITEM_RCP_QTY  := nC_ITEM_RCP_QTY * MYREC.WEIGHT_UNIT;
        ELSE
            nC_ITEM_RCP_COST := ROUND(nC_ITEM_RCP_QTY * (MYREC.UNIT_PRICE / MYREC.WEIGHT_UNIT) , 6) * MYREC.WEIGHT_UNIT;

            /* 리턴 자료 생성 */
            SELECT  OT_RECIPE_BRAND_FOOD
                   (
                    COMP_CD,
                    BRAND_CD,
                    STOR_TP,
                    P_ITEM_CD,
                    C_ITEM_CD,
                    START_DT,
                    CLOSE_DT,
                    C_ITEM_RID,
                    DO_UNIT,
                    DO_QTY,
                    DO_COST,
                    REUSE_YN,
                    USE_YN
                   )
            BULK COLLECT INTO RCP_RESULT_S
            FROM   (
                    SELECT  MYREC.COMP_CD       COMP_CD,
                            MYREC.BRAND_CD      BRAND_CD,
                            MYREC.STOR_TP       STOR_TP,
                            MYREC.R_ITEM_CD     P_ITEM_CD,
                            MYREC.RCP_ITEM_CD   C_ITEM_CD,
                            MYREC.START_DT      START_DT,
                            MYREC.CLOSE_DT      CLOSE_DT,
                            MYREC.RID           C_ITEM_RID,
                            MYREC.DO_UNIT       DO_UNIT,
                            nC_ITEM_RCP_QTY     DO_QTY,
                            nC_ITEM_RCP_COST    DO_COST,
                            MYREC.REUSE_YN      REUSE_YN,
                            MYREC.USE_YN        USE_YN
                    FROM    DUAL
                   );

            RCP_RESULT_M.EXTEND;
            RCP_RESULT_M(RCP_RESULT_M.LAST) := RCP_RESULT_S(RCP_RESULT_S.LAST);
        END IF;

        -- 레시피 레벨
        nTMP_IS_LVL := MYREC.IS_LVL;
    END LOOP;

    RETURN RCP_RESULT_M;
EXCEPTION
    WHEN OTHERS THEN
         --PSV_ERR_MSG := SQLERRM;

         RETURN RCP_RESULT_M;
END FN_RCP_STD_0041;

/
