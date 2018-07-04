--------------------------------------------------------
--  DDL for Function FN_GET_RECIPE_ITEM_USING_COST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_RECIPE_ITEM_USING_COST" (
                                                                PSV_COMP_CD     IN VARCHAR2, -- Company Code
                                                                PSV_BRAND_CD    IN VARCHAR2, -- Brand Code
                                                                PSV_ROWID       IN VARCHAR2, -- 원가분석 시작 원자재의 ROWID
                                                                PSV_ITEM_CD     IN VARCHAR2  -- 원가분석 최종 상품코드
                                                               )
RETURN NUMBER IS
    /****************************************************************/
    /*      레시피 원자재 기준 단가 정보 취득 FUNCTION              */
    /*      레시피 원자재 기준 DATA(원자재 -> 반재품 -> 상품 순)    */
    /****************************************************************/
    CURSOR CUR_1 IS
        SELECT  ITEM_LVL,       -- 계층레벨
                GROUP_END,      -- 계층최종
                P_ITEM_CD,      -- 레시피 MAIN
                C_ITEM_CD,      -- 레시피 SUB
                ITEM_NM,        -- SUB 상품 명
                RCP_QTY,        -- SUB 상품 중량
                MST_WEI_QTY,    -- SUB 상품 마스터 중량
                HEI_WEI_QTY,    -- 상위 상품 마스터 중량
                MST_YIL_RATE,   -- SUB 상품 마스터 수율
                HEI_YIL_RATE,   -- 상위 상품 마스터 수율
                COST            -- SUB 상품 매입원가
        FROM   (        
                SELECT  /*+ NO_MERGE */
                        LEVEL                                           ITEM_LVL,       -- 계층레벨
                        DECODE(LEVEL, 1, 9, 0)                          GROUP_END,      -- 계층최종 
                        RBF.P_ITEM_CD                                   P_ITEM_CD,      -- 레시피 MAIN
                        RBF.C_ITEM_CD                                   C_ITEM_CD,      -- 레시피 SUB
                        ITC.ITEM_NM                                     ITEM_NM,        -- SUB 상품 명
                        RBF.RCP_QTY                                     RCP_QTY,        -- SUB 상품 중량
                        ITC.WEIGHT_UNIT                                 MST_WEI_QTY,    -- SUB 상품 마스터 중량
                        LEAD(ITC.WEIGHT_UNIT, 1) OVER(ORDER BY LEVEL)   HEI_WEI_QTY,    -- 상위 상품 마스터 중량
                        ITC.YIELD_RATE                                  MST_YIL_RATE,   -- SUB 상품 마스터 수율
                        LEAD(ITC.YIELD_RATE,  1) OVER(ORDER BY LEVEL)   HEI_YIL_RATE,   -- 상위 상품 마스터 수율
                        ITC.COST                                        COST            -- SUB 상품 매입원가
                FROM    RECIPE_BRAND_FOOD RBF,
                        ITEM_CHAIN        ITC
                WHERE   RBF.COMP_CD     = ITC.COMP_CD
                AND     RBF.BRAND_CD    = ITC.BRAND_CD
                AND     RBF.C_ITEM_CD   = ITC.ITEM_CD
                AND     RBF.COMP_CD     = PSV_COMP_CD
                AND     RBF.BRAND_CD    = PSV_BRAND_CD 
                START WITH RBF.ROWID    = PSV_ROWID
                CONNECT BY NOCYCLE PRIOR  RBF.P_ITEM_CD = RBF.C_ITEM_CD
              ) V1
        ORDER BY ITEM_LVL DESC;

    MYREC       CUR_1%ROWTYPE;
    nPROCKBN    NUMBER       := 0;
    nRTNCOST    NUMBER(15,7) := 0;
    nITEMAMT    NUMBER(15,7) := 0;
    nITEMQTY    NUMBER(15,7) := 0;
    nITEMRATE   NUMBER(15,7) := 0;

BEGIN
    FOR MYREC IN CUR_1 LOOP
        /* 원가분석 최종 상품일때 원가 계산 시작 */
        IF MYREC.P_ITEM_CD = PSV_ITEM_CD THEN
            nPROCKBN := 1;
        END IF;

        IF nPROCKBN <> 0 THEN
            /* 루트인 경우 계산 안함 */
            IF nPROCKBN = 1 THEN
                nITEMQTY := MYREC.RCP_QTY;
            ELSE
                DBMS_OUTPUT.PUT_LINE(MYREC.P_ITEM_CD ||'/'|| MYREC.RCP_QTY ||'/'|| nITEMQTY ||'/'|| MYREC.HEI_WEI_QTY ||'/'|| MYREC.HEI_YIL_RATE);
                nITEMQTY := MYREC.RCP_QTY*(nITEMQTY/MYREC.HEI_WEI_QTY/MYREC.HEI_YIL_RATE);
            END IF;

            /* END LEAF인 경우 원가금액 */
            IF MYREC.GROUP_END = 9 THEN
                nITEMAMT := nITEMQTY * (MYREC.COST/MYREC.MST_WEI_QTY/MYREC.MST_YIL_RATE);
            END IF;
            DBMS_OUTPUT.PUT_LINE(MYREC.P_ITEM_CD ||'/'|| TO_CHAR(nITEMQTY) ||'/'|| TO_CHAR(nITEMAMT));

            nPROCKBN := nPROCKBN + 1;
        END IF;    
    END LOOP;

    RETURN nITEMAMT;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0; 
END FN_GET_RECIPE_ITEM_USING_COST;

/
