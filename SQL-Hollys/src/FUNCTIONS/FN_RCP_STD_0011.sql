--------------------------------------------------------
--  DDL for Function FN_RCP_STD_0011
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RCP_STD_0011" (
                                                    PSV_COMP_CD     IN VARCHAR2, -- 회사코드
                                                    PSV_BRAND_CD    IN VARCHAR2, -- 영업조직
                                                    PSV_STD_YM      IN VARCHAR2  -- 조회기준년월
                                                   )
RETURN TBL_RECIPE_BRAND_FOOD AS
    /****************************************************************/
    /*      ITEM_CHAIN_STD(메뉴표준/실단가) 기준 레시피 정보  취득  */
    /*      레시피 원자재 기준 DATA(원자재 -> 반재품 -> 상품 순)    */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT  /*+ NO_MERGE LEADING(RBF PRT CLD)
                    INDEX(CLD PK_ITEM_CHAIN) */
                RBF.COMP_CD,
                RBF.BRAND_CD,
                CLD.STOR_TP,
                RBF.R_ITEM_CD,
                RBF.ISLEAF,
                RBF.ISLVL,
                RBF.P_ITEM_CD,
                RBF.C_ITEM_CD,
                RBF.START_DT,
                RBF.CLOSE_DT,
                RBF.DO_UNIT,
                RBF.RCP_QTY,
                RBF.REUSE_YN,
                RBF.USE_YN,
                NVL(CLD.YIELD_RATE,  1) AS YIELD_RATE,
                NVL(CLD.WEIGHT_UNIT, 1) AS WEIGHT_UNIT,
                CASE WHEN CLD.STOCK_UNIT = CLD.DO_UNIT THEN 1 ELSE 0 END UNIT_FLG,
                NVL(HIS.COST, CLD.COST) / NVL(CLD.ORD_UNIT_QTY, 1) COST, -- 재고단위당 원가
                RBF.RID,
                RBF.R_NUM,
                ROW_NUMBER() OVER(PARTITION BY RBF.R_ITEM_CD ORDER BY RBF.R_NUM) R_ITEM_SEQ
        FROM    ITEM_CHAIN CLD,
               (
                SELECT  COMP_CD,
                        BRAND_CD,
                        STOR_TP,
                        ITEM_CD,
                        COST,
                        ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_TP, ITEM_CD ORDER BY START_DT DESC) AS R_NUM
                FROM    ITEM_CHAIN_HIS
                WHERE   COMP_CD   = PSV_COMP_CD
                AND     BRAND_CD  = PSV_BRAND_CD
                AND     START_DT <= PSV_STD_YM||'31'
               )           HIS,
               (
                SELECT  COMP_CD,
                        BRAND_CD,
                        CONNECT_BY_ROOT(C_ITEM_CD)AS R_ITEM_CD,
                        CONNECT_BY_ISLEAF AS ISLEAF,
                        LEVEL                ISLVL,
                        P_ITEM_CD,
                        C_ITEM_CD,
                        START_DT,
                        CLOSE_DT,
                        DO_UNIT,
                        RCP_QTY,
                        REUSE_YN,
                        USE_YN,
                        RID,
                        ROWNUM R_NUM
                FROM   (
                        SELECT  COMP_CD,
                                BRAND_CD,
                                P_ITEM_CD,
                                C_ITEM_CD,
                                START_DT,
                                CLOSE_DT,
                                DO_UNIT,
                                RCP_QTY,
                                REUSE_YN,
                                USE_YN,
                                ROWID RID
                        FROM    RECIPE_BRAND_FOOD RBF
                        WHERE   COMP_CD    = PSV_COMP_CD
                        AND     BRAND_CD   = PSV_BRAND_CD
                        AND     START_DT <= PSV_STD_YM||'31'
                        AND     CLOSE_DT >= PSV_STD_YM||'01'
                        --AND     TO_CHAR(LAST_DAY(TO_DATE(PSV_STD_YM, 'YYYYMM')), 'YYYYMMDD') BETWEEN START_DT  AND CLOSE_DT
                        AND     USE_YN     = 'Y'
                        AND     EXISTS  (
                                            SELECT  /*+ INDEX(ITM PK_ITEM) */
                                                    1
                                            FROM    ITEM              ITM
                                            WHERE   ITM.COMP_CD  = RBF.COMP_CD
                                            AND     ITM.ITEM_CD  = RBF.C_ITEM_CD
                                            AND     1 = (CASE WHEN (RBF.P_ITEM_CD  = ' ' AND ITM.RECIPE_DIV = '3') THEN 0 ELSE 1END)
                                           )
                       )
                START WITH
                        P_ITEM_CD = ' '
                CONNECT BY  PRIOR C_ITEM_CD = P_ITEM_CD
                        --AND START_DT  BETWEEN PRIOR START_DT AND PRIOR CLOSE_DT
                ORDER SIBLINGS BY C_ITEM_CD
               ) RBF
        WHERE   RBF.COMP_CD    = CLD.COMP_CD
        AND     RBF.BRAND_CD   = CLD.BRAND_CD
        AND     RBF.C_ITEM_CD  = CLD.ITEM_CD
        AND     CLD.COMP_CD    = HIS.COMP_CD (+)
        AND     CLD.BRAND_CD   = HIS.BRAND_CD(+)
        AND     CLD.STOR_TP    = HIS.STOR_TP (+)
        AND     CLD.ITEM_CD    = HIS.ITEM_CD (+)
        AND     1              = HIS.R_NUM   (+)
        AND     RBF.P_ITEM_CD != ' '
        ORDER BY
                RBF.COMP_CD,
                RBF.BRAND_CD,
                CLD.STOR_TP,
                RBF.R_NUM;

    MYREC               CUR_1%ROWTYPE;
    RCP_RESULT_S        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- SINGLE RECORD
    RCP_RESULT_M        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- MULTI RECORD
    nP_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 무모 레시피 사용량
    nC_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 자식 레시피 사용량
    nC_ITEM_RCP_COST    NUMBER(15, 6) := 1;                                 -- 자식 레시피 원가
    nTMP_ISLVL          NUMBER(5)     := 0;                                 -- 레벨 비교용

    TYPE T_P_ITEM IS TABLE OF RECIPE_BRAND_FOOD.DO_QTY%TYPE INDEX BY BINARY_INTEGER;
    TMP_P_ITEM  T_P_ITEM;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        IF (MYREC.R_ITEM_SEQ = 1 OR MYREC.R_ITEM_CD = MYREC.P_ITEM_CD) THEN
            nP_ITEM_RCP_QTY := 1;

            -- 레시피 레벨 및 부모의 중량 저장
            nTMP_ISLVL := MYREC.ISLVL;
            TMP_P_ITEM(MYREC.ISLVL) := nP_ITEM_RCP_QTY;
        END IF;

        -- 레벨이 증가하면 현재 부모의 중량을 저장
        IF nTMP_ISLVL != MYREC.ISLVL THEN
            IF nTMP_ISLVL > MYREC.ISLVL THEN
                nP_ITEM_RCP_QTY := TMP_P_ITEM(MYREC.ISLVL);
            ELSE
                TMP_P_ITEM(MYREC.ISLVL) := nP_ITEM_RCP_QTY;
            END IF;
        END IF;

        IF MYREC.YIELD_RATE = 0 THEN
            nC_ITEM_RCP_QTY  := nP_ITEM_RCP_QTY * MYREC.RCP_QTY;
        ELSE
            nC_ITEM_RCP_QTY  := nP_ITEM_RCP_QTY * (MYREC.RCP_QTY / MYREC.YIELD_RATE);
        END IF;

        -- 레시피의 최종 LEAF이면(0:자식레코드 있음, 1:최종 레코드)
        IF MYREC.ISLEAF = 0 THEN
            nP_ITEM_RCP_QTY  := nC_ITEM_RCP_QTY;
        ELSE
            IF MYREC.WEIGHT_UNIT = 0 OR MYREC.UNIT_FLG = 1 THEN
                nC_ITEM_RCP_COST := nC_ITEM_RCP_QTY * MYREC.COST;
            ELSE
                nC_ITEM_RCP_COST := nC_ITEM_RCP_QTY * (MYREC.COST / MYREC.WEIGHT_UNIT);
            END IF;

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
                            MYREC.C_ITEM_CD     C_ITEM_CD,
                            MYREC.START_DT      START_DT,
                            MYREC.CLOSE_DT      CLOSE_DT,
                            MYREC.RID           C_ITEM_RID,
                            MYREC.DO_UNIT       DO_UNIT,
                            nC_ITEM_RCP_QTY     DO_QTY,
                            nC_ITEM_RCP_COST    DO_COST,
                            MYREC.REUSE_YN,
                            MYREC.USE_YN
                    FROM    DUAL
                   );

            RCP_RESULT_M.EXTEND;
            RCP_RESULT_M(RCP_RESULT_M.LAST) := RCP_RESULT_S(RCP_RESULT_S.LAST);
        END IF;

        -- 레시피 레벨
        nTMP_ISLVL := MYREC.ISLVL;
    END LOOP;

    RETURN RCP_RESULT_M;
EXCEPTION
    WHEN OTHERS THEN
        --PSV_ERR_MSG := SQLERRM;

        RETURN RCP_RESULT_M;
END FN_RCP_STD_0011;

/
