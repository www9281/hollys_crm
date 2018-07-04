--------------------------------------------------------
--  DDL for Function FN_RECIPE_USE_L0
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RECIPE_USE_L0" (
                                                    PSV_COMP_CD     IN VARCHAR2, -- 회사코드
                                                    PSV_BRAND_CD    IN VARCHAR2, -- 영업조직
                                                    PSV_STOR_TP     IN VARCHAR2, -- 직가맹구분
                                                    PSV_ITEM_CD     IN VARCHAR2, -- 메뉴
                                                    PSV_YMD         IN VARCHAR2  -- 조회일자
                                                   )
RETURN TBL_RECIPE_BRAND_FOOD AS
    /****************************************************************/
    /*      ITEM_CHAIN_STD(메뉴표준/실단가) 기준 레시피 정보  취득  */
    /*      레시피 원자재 기준 DATA(원자재 -> 반재품 -> 상품 순)    */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT  /*+ NO_MERGE LEADING(RBF PRT CLD) 
                    INDEX(PRT PK_ITEM) 
                    INDEX(CLD PK_ITEM_CHAIN) */
                RBF.COMP_CD,
                RBF.BRAND_CD,
                RBF.R_ITEM_CD,
                RBF.ISLEAF,
                RBF.ISLVL,
                RBF.P_ITEM_CD,
                RBF.C_ITEM_CD,
                RBF.DO_UNIT,
                RBF.RCP_QTY,
                RBF.REUSE_YN,
                RBF.USE_YN,
                NVL(CLD.YIELD_RATE, 1) AS YIELD_RATE,
                NVL(CLD.WEIGHT_UNIT,1) AS WEIGHT_UNIT,
                CLD.COST,
                RBF.RID,
                RBF.R_NUM,
                ROW_NUMBER() OVER(PARTITION BY RBF.R_ITEM_CD ORDER BY R_NUM) R_ITEM_SEQ
        FROM    ITEM       PRT,
                ITEM_CHAIN CLD,
               (
                SELECT  COMP_CD,
                        BRAND_CD,
                        CONNECT_BY_ROOT(C_ITEM_CD)AS R_ITEM_CD,
                        CONNECT_BY_ISLEAF AS ISLEAF,
                        LEVEL                ISLVL,
                        P_ITEM_CD,
                        C_ITEM_CD,
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
                                DO_UNIT,
                                RCP_QTY,
                                REUSE_YN,
                                USE_YN,
                                ROWID RID
                        FROM    RECIPE_BRAND_FOOD
                        WHERE   COMP_CD    = PSV_COMP_CD
                        AND     BRAND_CD   = PSV_BRAND_CD
                        AND     PSV_YMD    BETWEEN START_DT AND CLOSE_DT
                        AND     USE_YN     = 'Y'
                        AND     DO_YN      = 'Y'
                       )
                START WITH
                        P_ITEM_CD = ' '
                CONNECT BY PRIOR C_ITEM_CD = P_ITEM_CD
                ORDER SIBLINGS BY C_ITEM_CD
               ) RBF
        WHERE   RBF.COMP_CD    = PRT.COMP_CD
        AND     RBF.R_ITEM_CD  = PRT.ITEM_CD
        AND     RBF.COMP_CD    = CLD.COMP_CD
        AND     RBF.BRAND_CD   = CLD.BRAND_CD
        AND     RBF.C_ITEM_CD  = CLD.ITEM_CD
        AND     PSV_STOR_TP    = CLD.STOR_TP 
        --AND     PRT.RECIPE_DIV = '1'
        AND     RBF.P_ITEM_CD != ' '
        AND     RBF.R_ITEM_CD  = PSV_ITEM_CD
        ORDER BY R_NUM;
         
    MYREC               CUR_1%ROWTYPE;
    RCP_RESULT_S        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- SINGLE RECORD
    RCP_RESULT_M        TBL_RECIPE_BRAND_FOOD := TBL_RECIPE_BRAND_FOOD();   -- MULTI RECORD
    nP_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 무모 레시피 사용량
    nC_ITEM_RCP_QTY     NUMBER(15, 6) := 1;                                 -- 자식 레시피 사용량
    nC_ITEM_RCP_COST    NUMBER(15, 6) := 1;                                 -- 자식 레시피 원가
    nTMP_ISLVL          NUMBER(5)     := 0;                                 -- 레벨 비교용
    
    TYPE T_P_ITEM IS TABLE OF RECIPE_BRAND_FOOD.DO_QTY%TYPE INDEX BY BINARY_INTEGER;
    TMP_P_ITEM  T_P_ITEM;
    PSV_ERR_MSG     VARCHAR2(2000) := NULL;
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
        
        nC_ITEM_RCP_QTY  := nP_ITEM_RCP_QTY * (MYREC.RCP_QTY / MYREC.YIELD_RATE);
        
        -- 레시피의 최종 LEAF이면 
        IF MYREC.ISLEAF = 0 THEN
            nP_ITEM_RCP_QTY  := nC_ITEM_RCP_QTY;
        ELSE
            IF MYREC.WEIGHT_UNIT = 0 THEN
                nC_ITEM_RCP_COST := nC_ITEM_RCP_QTY * MYREC.COST;
            ELSE
                nC_ITEM_RCP_COST := nC_ITEM_RCP_QTY * (MYREC.COST / MYREC.WEIGHT_UNIT);
            END IF;
            
            --nC_ITEM_RCP_COST := nC_ITEM_RCP_QTY * (MYREC.COST / MYREC.WEIGHT_UNIT);
            
            /* 리턴 자료 생성 */
            SELECT  OT_RECIPE_BRAND_FOOD
                   (
                    COMP_CD,
                    BRAND_CD,
                    STOR_TP,
                    P_ITEM_CD,
                    C_ITEM_CD,
                    START_DT,
                    CLSOE_DT,
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
                            PSV_STOR_TP         STOR_TP,
                            MYREC.R_ITEM_CD     P_ITEM_CD,
                            MYREC.C_ITEM_CD     C_ITEM_CD,
                            NULL                START_DT,
                            NULL                CLSOE_DT,
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
        nTMP_ISLVL := MYREC.ISLVL;
    END LOOP;

    RETURN RCP_RESULT_M;
EXCEPTION
    WHEN OTHERS THEN
        PSV_ERR_MSG := SQLERRM;
        
        RETURN RCP_RESULT_M; 
END FN_RECIPE_USE_L0;

/
