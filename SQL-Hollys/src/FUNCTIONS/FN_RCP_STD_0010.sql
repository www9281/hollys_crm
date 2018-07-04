--------------------------------------------------------
--  DDL for Function FN_RCP_STD_0010
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RCP_STD_0010" (   PSV_COMP_CD  IN VARCHAR2,
                                                    PSV_BRAND_CD IN VARCHAR2,
                                                    PSV_STD_YM  IN VARCHAR2
                                                )
RETURN VARCHAR2 IS
    CURSOR CUR_1 IS
        WITH RBF AS
        (
            SELECT  COMP_CD,                                -- 회사 코드
                    BRAND_CD,                               -- 브랜드 코드
                    STOR_TP,                                -- 직가맹구분
                    R_ITEM_CD,                              -- 메뉴 코드
                    C_ITEM_CD,                              -- 원자재코드
                    START_DT,                               -- 시작일자
                    CLOSE_DT,                               -- 종료일자
                    PRD_RCP_QTY,                            -- 메뉴별 원자재별 합계 소모수량
                    ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, C_ITEM_CD ORDER BY R_ITEM_CD) R_NUM
            FROM   (
                    SELECT  COMP_CD,                        -- 회사 코드
                            BRAND_CD,                       -- 브랜드 코드
                            STOR_TP,                        -- 직가맹구분
                            P_ITEM_CD     AS R_ITEM_CD,     -- 메뉴 코드
                            C_ITEM_CD,                      -- 원자재코드
                            CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END     AS START_DT,      -- 시작일자
                            MAX(CLOSE_DT) AS CLOSE_DT,      -- 종료일자
                            SUM(DO_QTY)   AS PRD_RCP_QTY    -- 메뉴별 원자재별 합계 소모수량
                    FROM    TABLE(FN_RCP_STD_0011(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM))
                    GROUP BY
                            COMP_CD,
                            BRAND_CD,
                            STOR_TP,
                            P_ITEM_CD,
                            C_ITEM_CD,
                            CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END
                    UNION
                    SELECT  SR.COMP_CD
                         ,  SR.BRAND_CD
                         ,  I.STOR_TP
                         ,  SR.ITEM_CD                                      AS R_ITEM_CD
                         ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)    AS C_ITEM_CD
                         ,  MIN(CASE WHEN NVL(OI.START_DT, SR.START_DT) < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE NVL(OI.START_DT, SR.START_DT) END)  AS START_DT
                         ,  MAX(NVL(OI.CLOSE_DT, SR.CLOSE_DT))              AS CLOSE_DT
                         ,  SUM(NVL(OI.DO_QTY, 1))                          AS PRD_RCP_QTY
                      FROM  SET_RULE    SR
                         ,  (
                                SELECT  OI.COMP_CD
                                     ,  OI.BRAND_CD
                                     ,  OI.OPT_GRP
                                     ,  NVL(R.C_ITEM_CD, OI.ITEM_CD)    AS ITEM_CD
                                     ,  R.START_DT
                                     ,  R.CLOSE_DT
                                     ,  R.DO_QTY
                                  FROM  (
                                            SELECT  OI.COMP_CD
                                                 ,  OI.BRAND_CD
                                                 ,  OI.OPT_GRP
                                                 ,  OI.ITEM_CD
                                              FROM  OPTION_ITEM     OI
                                                 ,  SALE_DT         SD
                                             WHERE  OI.COMP_CD          = SD.COMP_CD
                                               AND  OI.OPT_GRP          = SD.SUB_TOUCH_GR_CD 
                                               AND  OI.OPT_CD           = SD.SUB_TOUCH_CD 
                                               AND  OI.ITEM_CD          = SD.ITEM_CD 
                                               AND  OI.COMP_CD          = PSV_COMP_CD
                                               AND  OI.BRAND_CD         = PSV_BRAND_CD
                                               AND  SD.SALE_DT          BETWEEN PSV_STD_YM||'01' AND PSV_STD_YM||'31'
                                             GROUP  BY OI.COMP_CD
                                                 ,  OI.BRAND_CD
                                                 ,  OI.OPT_GRP
                                                 ,  OI.ITEM_CD
                                        )   OI
                                     ,  TABLE(FN_RCP_STD_0011(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM))   R
                                 WHERE  OI.COMP_CD  = R.COMP_CD(+)
                                   AND  OI.BRAND_CD = R.BRAND_CD(+)
                                   AND  OI.ITEM_CD  = R.P_ITEM_CD(+)
                                   --AND  OI.USE_YN   = 'Y'
                            )   OI
                         ,  (
                                SELECT  STOR_TP
                                  FROM  ITEM_CHAIN
                                 WHERE  COMP_CD = PSV_COMP_CD
                                   AND  BRAND_CD= PSV_BRAND_CD
                                 GROUP  BY STOR_TP
                            )           I
                     WHERE  SR.COMP_CD  = OI.COMP_CD(+)
                       AND  SR.BRAND_CD = OI.BRAND_CD(+)
                       AND  SR.OPTN_ITEM_CD = OI.OPT_GRP(+)
                       AND  SR.COMP_CD  = PSV_COMP_CD
                       AND  SR.BRAND_CD = PSV_BRAND_CD
                       AND  NVL(OI.START_DT, SR.START_DT) <= PSV_STD_YM||'31'
                       AND  NVL(OI.CLOSE_DT, SR.CLOSE_DT) >= PSV_STD_YM||'01'
                       --AND  TO_CHAR(LAST_DAY(TO_DATE(PSV_STD_YM, 'YYYYMM')), 'YYYYMMDD') BETWEEN NVL(OI.START_DT, SR.START_DT)  AND NVL(OI.CLOSE_DT, SR.CLOSE_DT)
                       --AND  SR.USE_YN   = 'Y'
                     GROUP  BY SR.COMP_CD
                         ,  SR.BRAND_CD
                         ,  I.STOR_TP
                         ,  SR.ITEM_CD
                         ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)
                   )
        )
        SELECT  MST.COMP_CD,                            /* 회사코드                           */
                MST.PRC_YM,                             /* 기준년월                           */
                MST.BRAND_CD,                           /* 브랜드코드                         */
                MST.STOR_CD,                            /* 회사코드                           */
                RBF.STOR_TP,                            /* 직가맹구분                         */
                RBF.R_ITEM_CD,                          /* 메뉴코드                           */
                RBF.C_ITEM_CD,                          /* 자재코드                           */
                MIN(RBF.START_DT)   AS START_DT,                           /* 자재 사용 시작일자                 */
                MAX(RBF.CLOSE_DT)   AS CLOSE_DT,                           /* 자재 사용 종료일자                 */
                MAX(NVL(HIS.COST, ITM.COST)/(DECODE(NVL(ITM.ORD_UNIT_QTY, 1), 0, 1, NVL(ITM.ORD_UNIT_QTY, 1)) * DECODE(NVL(ITM.WEIGHT_UNIT, 1), 0, 1, NVL(ITM.WEIGHT_UNIT, 1))))
                                       AS C_COST,    /* 소모단위 당 원가(최종매입가)       */
                MAX(NVL(MST.END_COST, 0)/(DECODE(NVL(ITM.ORD_UNIT_QTY, 1), 0, 1, NVL(ITM.ORD_UNIT_QTY, 1)) * DECODE(NVL(ITM.WEIGHT_UNIT, 1), 0, 1, NVL(ITM.WEIGHT_UNIT, 1))))
                                       AS P_COST,    /* 소모단위 당 원가(총평균원가)       */
               MAX(MST.BEGIN_QTY)      AS BEGIN_QTY,
               MAX(MST.END_QTY)        AS END_QTY,
               SUM(DST.ORD_QTY)        AS ORD_QTY,
               SUM(DST.RTN_QTY)        AS RTN_QTY,
               SUM(DST.MV_IN_QTY)      AS MV_IN_QTY,
               SUM(DST.MV_OUT_QTY)     AS MV_OUT_QTY,
               (
                MAX(MST.BEGIN_QTY)      -
                MAX(MST.END_QTY)        +
                SUM(DST.ORD_QTY)        -
                SUM(DST.RTN_QTY)        +
                SUM(DST.MV_IN_QTY)      -
                SUM(DST.MV_OUT_QTY)
               ) * MAX(NVL(ITM.WEIGHT_UNIT, 1))  AS REAL_USE_QTY, /* 실사용 수량(RECIPE DO_UNIT 기준    */
                MAX(RBF.PRD_RCP_QTY)    AS PRD_RCP_QTY,                        /* 레시피 표준 소모 수량              */
                ROW_NUMBER() OVER(PARTITION BY MST.COMP_CD, MST.STOR_CD ORDER BY MST.COMP_CD, MST.STOR_CD, RBF.C_ITEM_CD) STOR_R_NUM
        FROM    STORE       STO,
                ITEM_CHAIN  ITM,
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
               )            HIS,
                MSTOCK      MST,
                RBF         RBF,
               (
                SELECT  /*+     제품 일재고      */
                        V1.COMP_CD,
                        V1.PRC_DT,
                        V1.BRAND_CD,
                        V1.STOR_CD,
                        V1.ITEM_CD,
                        SUM(V1.ORD_QTY)    AS ORD_QTY,
                        SUM(V1.MV_IN_QTY)  AS MV_IN_QTY,
                        SUM(V1.MV_OUT_QTY) AS MV_OUT_QTY,
                        SUM(V1.RTN_QTY)    AS RTN_QTY
                FROM   (
                        SELECT  /*+     제품 일재고      */
                                RB1.COMP_CD,
                                DST.PRC_DT,
                                RB1.BRAND_CD,
                                RB1.STOR_CD,
                                RB1.C_ITEM_CD          AS ITEM_CD,
                                NVL(DST.ORD_QTY   , 0) AS ORD_QTY,
                                NVL(DST.MV_IN_QTY , 0) AS MV_IN_QTY,
                                NVL(DST.MV_OUT_QTY, 0) AS MV_OUT_QTY,
                                NVL(DST.RTN_QTY   , 0) AS RTN_QTY,
                                LAST_VALUE(DST.COST)
                                    OVER(PARTITION BY DST.COMP_CD, DST.BRAND_CD, DST.STOR_CD, DST.ITEM_CD
                                         ORDER BY DST.PRC_DT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                                       AS LAST_COST
                        FROM    DSTOCK  DST,
                               (
                                SELECT  RBF.COMP_CD,
                                        RBF.BRAND_CD,
                                        STO.STOR_CD,
                                        RBF.C_ITEM_CD,
                                        RBF.START_DT,
                                        MIN(RBF.CLOSE_DT)   AS CLOSE_DT
                                FROM    RBF   RBF,
                                        STORE STO
                                WHERE   RBF.COMP_CD  = STO.COMP_CD
                                AND     RBF.BRAND_CD = STO.BRAND_CD
                                AND     RBF.STOR_TP  = STO.STOR_TP
                                GROUP   BY RBF.COMP_CD,
                                        RBF.BRAND_CD,
                                        STO.STOR_CD,
                                        RBF.C_ITEM_CD,
                                        RBF.START_DT
                               ) RB1
                        WHERE   DST.COMP_CD (+) = RB1.COMP_CD
                        AND     DST.BRAND_CD(+) = RB1.BRAND_CD
                        AND     DST.STOR_CD (+) = RB1.STOR_CD
                        AND     DST.ITEM_CD (+) = RB1.C_ITEM_CD
                        AND     DST.PRC_DT  (+) LIKE PSV_STD_YM||'%'
                        AND     SUBSTR(DST.PRC_DT, 1, 6) = PSV_STD_YM
                       ) V1
                GROUP BY
                        V1.COMP_CD,
                        V1.PRC_DT,
                        V1.BRAND_CD,
                        V1.STOR_CD,
                        V1.ITEM_CD
               )        DST
        WHERE   MST.STOR_CD  = STO.STOR_CD
        AND     MST.COMP_CD  = RBF.COMP_CD
        AND     MST.BRAND_CD = RBF.BRAND_CD
        AND     MST.ITEM_CD  = RBF.C_ITEM_CD
        AND     STO.STOR_TP  = RBF.STOR_TP
        AND     MST.COMP_CD  = ITM.COMP_CD
        AND     MST.BRAND_CD = ITM.BRAND_CD
        AND     MST.ITEM_CD  = ITM.ITEM_CD
        AND     STO.STOR_TP  = ITM.STOR_TP
        AND     ITM.COMP_CD  = HIS.COMP_CD (+)
        AND     ITM.BRAND_CD = HIS.BRAND_CD(+)
        AND     ITM.ITEM_CD  = HIS.ITEM_CD (+)
        AND     ITM.STOR_TP  = HIS.STOR_TP (+)
        AND     1            = HIS.R_NUM   (+)
        AND     MST.COMP_CD  = DST.COMP_CD
        AND     MST.PRC_YM   = SUBSTR(DST.PRC_DT, 1, 6)
        AND     MST.BRAND_CD = DST.BRAND_CD
        AND     MST.STOR_CD  = DST.STOR_CD
        AND     MST.ITEM_CD  = DST.ITEM_CD
        AND     MST.STOR_CD  = '1010001'
        GROUP BY
                MST.COMP_CD,
                MST.PRC_YM,
                MST.BRAND_CD,
                MST.STOR_CD,
                RBF.STOR_TP,
                RBF.R_ITEM_CD,
                RBF.C_ITEM_CD
        ORDER BY
                MST.COMP_CD,
                MST.PRC_YM,
                MST.BRAND_CD,
                MST.STOR_CD,
                RBF.C_ITEM_CD;

    MYREC           CUR_1%ROWTYPE;
    nC_ITEM_USE_QTY NUMBER(15, 6) := 0;     -- 메뉴 판매수량
    nC_ITEM_TOT_QTY NUMBER(15, 6) := 0;     -- 원자재가 포함된 메뉴 전체 판매수량
    nC_ITEM_RATE    NUMBER        := 0;     -- 원자재가 포함된 메뉴 전체 판매수량 대비 비율
    vCURDATA        VARCHAR2(30)  := NULL;
    nCOST_DIV       VARCHAR2(1);
    nCOST           NUMBER        := 0;
    nSTOR_CD        STORE.STOR_CD%TYPE;
    nP_ITEM_CD      RECIPE_BRAND_FOOD.P_ITEM_CD%TYPE;
    nC_ITEM_CD      RECIPE_BRAND_FOOD.C_ITEM_CD%TYPE;

BEGIN
    DBMS_OUTPUT.PUT_LINE('A1 -'||TO_CHAR(SYSDATE, 'HH24MISS'));

    IF PSV_STD_YM >= TO_CHAR(SYSDATE, 'YYYYMM') THEN
        RETURN 'Execution Date Is Less Than The Current Month.';
    END IF;

    SELECT PARA_VAL
      INTO nCOST_DIV
      FROM PARA_BRAND
     WHERE COMP_CD  = PSV_COMP_CD
       AND BRAND_CD = PSV_BRAND_CD
       AND PARA_CD  = '1005'; -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]

    --DATA CLEAR
    DELETE
    FROM    ITEM_CHAIN_RCP
    WHERE   COMP_CD  = PSV_COMP_CD
    AND     BRAND_CD = PSV_BRAND_CD
    AND     CALC_YM  = PSV_STD_YM
    AND     STOR_CD  = '1010001';

    DBMS_OUTPUT.PUT_LINE('A2 -'||TO_CHAR(SYSDATE, 'HH24MISS'));
    -- 직가맹별 표준단가[레시피] 작성 시작
    FOR MYREC IN CUR_1 LOOP

        nSTOR_CD    := MYREC.STOR_CD;
        nP_ITEM_CD  := MYREC.R_ITEM_CD;
        nC_ITEM_CD  := MYREC.C_ITEM_CD;

        IF MYREC.STOR_R_NUM = 1 THEN
            COMMIT;
        END IF;

        IF nCOST_DIV = 'P' THEN
            nCOST := MYREC.P_COST;
        ELSE
            nCOST := MYREC.C_COST;
        END IF;

        -- 메뉴별 총 소모 수량 계산
        WITH W_RCP AS
        (
            SELECT  COMP_CD,
                    BRAND_CD,
                    R_ITEM_CD           AS P_ITEM_CD,
                    MAX(PRD_RCP_QTY)    AS C_ITM_RCP_QTY
            FROM   (
                    SELECT  COMP_CD,                        -- 회사 코드
                            BRAND_CD,                       -- 브랜드 코드
                            STOR_TP,                        -- 직가맹구분
                            P_ITEM_CD     AS R_ITEM_CD,     -- 메뉴 코드
                            C_ITEM_CD,                      -- 원자재코드
                            CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END     AS START_DT,      -- 시작일자
                            MAX(CLOSE_DT) AS CLOSE_DT,      -- 종료일자
                            SUM(DO_QTY)   AS PRD_RCP_QTY    -- 메뉴별 원자재별 합계 소모수량
                    FROM    TABLE(FN_RCP_STD_0011(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM))
                    WHERE   C_ITEM_CD = MYREC.C_ITEM_CD
                    GROUP BY
                            COMP_CD,
                            BRAND_CD,
                            STOR_TP,
                            P_ITEM_CD,
                            C_ITEM_CD,
                            CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END
                    UNION
                    SELECT  SR.COMP_CD
                         ,  SR.BRAND_CD
                         ,  I.STOR_TP
                         ,  SR.ITEM_CD                                      AS R_ITEM_CD
                         ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)    AS C_ITEM_CD
                         ,  MIN(CASE WHEN NVL(OI.START_DT, SR.START_DT) < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE NVL(OI.START_DT, SR.START_DT) END)  AS START_DT
                         ,  MAX(NVL(OI.CLOSE_DT, SR.CLOSE_DT))              AS CLOSE_DT
                         ,  SUM(NVL(OI.DO_QTY, 1))                          AS PRD_RCP_QTY
                      FROM  SET_RULE    SR
                         ,  (
                                SELECT  OI.COMP_CD
                                     ,  OI.BRAND_CD
                                     ,  OI.OPT_GRP
                                     ,  NVL(R.C_ITEM_CD, OI.ITEM_CD)    AS ITEM_CD
                                     ,  R.START_DT
                                     ,  R.CLOSE_DT
                                     ,  R.DO_QTY
                                  FROM  (
                                            SELECT  OI.COMP_CD
                                                 ,  OI.BRAND_CD
                                                 ,  OI.OPT_GRP
                                                 ,  OI.ITEM_CD
                                              FROM  OPTION_ITEM     OI
                                                 ,  SALE_DT         SD
                                             WHERE  OI.COMP_CD          = SD.COMP_CD
                                               AND  OI.OPT_GRP          = SD.SUB_TOUCH_GR_CD 
                                               AND  OI.OPT_CD           = SD.SUB_TOUCH_CD 
                                               AND  OI.ITEM_CD          = SD.ITEM_CD 
                                               AND  OI.COMP_CD          = PSV_COMP_CD
                                               AND  OI.BRAND_CD         = PSV_BRAND_CD
                                               AND  SD.SALE_DT          BETWEEN PSV_STD_YM||'01' AND PSV_STD_YM||'31'
                                             GROUP  BY OI.COMP_CD
                                                 ,  OI.BRAND_CD
                                                 ,  OI.OPT_GRP
                                                 ,  OI.ITEM_CD
                                        )   OI
                                     ,  TABLE(FN_RCP_STD_0011(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM))   R
                                 WHERE  OI.COMP_CD  = R.COMP_CD(+)
                                   AND  OI.BRAND_CD = R.BRAND_CD(+)
                                   AND  OI.ITEM_CD  = R.P_ITEM_CD(+)
                                   --AND  OI.USE_YN   = 'Y'
                            )   OI
                         ,  (
                                SELECT  STOR_TP
                                  FROM  ITEM_CHAIN
                                 WHERE  COMP_CD = PSV_COMP_CD
                                   AND  BRAND_CD= PSV_BRAND_CD
                                 GROUP  BY STOR_TP
                            )           I
                     WHERE  SR.COMP_CD  = OI.COMP_CD(+)
                       AND  SR.BRAND_CD = OI.BRAND_CD(+)
                       AND  SR.OPTN_ITEM_CD = OI.OPT_GRP(+)
                       AND  SR.COMP_CD  = PSV_COMP_CD
                       AND  SR.BRAND_CD = PSV_BRAND_CD
                       AND  NVL(OI.START_DT, SR.START_DT) <= PSV_STD_YM||'31'
                       AND  NVL(OI.CLOSE_DT, SR.CLOSE_DT) >= PSV_STD_YM||'01'
                       AND  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD) = MYREC.C_ITEM_CD
                       --AND  TO_CHAR(LAST_DAY(TO_DATE(PSV_STD_YM, 'YYYYMM')), 'YYYYMMDD') BETWEEN NVL(OI.START_DT, SR.START_DT)  AND NVL(OI.CLOSE_DT, SR.CLOSE_DT)
                       --AND  SR.USE_YN   = 'Y'
                     GROUP  BY SR.COMP_CD
                         ,  SR.BRAND_CD
                         ,  I.STOR_TP
                         ,  SR.ITEM_CD
                         ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)
                   )
            GROUP BY
                    COMP_CD,
                    BRAND_CD,
                    R_ITEM_CD
        )
        SELECT  NVL(SUM(C_ITEM_USE_QTY * C_ITM_RCP_QTY), 0) AS C_ITEM_USE_QTY, -- 원재료가 포함된 현재 메뉴의 판매수량
                NVL(SUM(C_ITEM_TOT_QTY * C_ITM_RCP_QTY), 0) AS C_ITEM_TOT_QTY  -- 원재료가 포함된 전체 메뉴의 판매수량
        INTO    nC_ITEM_USE_QTY, nC_ITEM_TOT_QTY
        FROM   (        /*+ 원자재 기준 메뉴의 사용가능 기간까지의 매출 */
                SELECT  /*+ LEADING(V01) Index(SJM IDX01_SALE_JDM)      */
                        DECODE(V01.P_ITEM_CD, MYREC.R_ITEM_CD, SJM.SALE_QTY, 0) AS C_ITEM_USE_QTY,
                        0                                                       AS C_ITEM_TOT_QTY,
                        V01.C_ITM_RCP_QTY                                       AS C_ITM_RCP_QTY
                FROM    SALE_JDM SJM,
                        W_RCP    V01
                WHERE   SJM.COMP_CD     = V01.COMP_CD
                AND     SJM.BRAND_CD    = V01.BRAND_CD
                AND     SJM.ITEM_CD     = V01.P_ITEM_CD
                AND     SJM.COMP_CD     = MYREC.COMP_CD
                AND     SJM.BRAND_CD    = MYREC.BRAND_CD
                AND     SJM.STOR_CD     = MYREC.STOR_CD
                AND     SJM.SALE_DT  LIKE MYREC.PRC_YM||'%'
                AND     SJM.SALE_DT    >= MYREC.START_DT
                AND     SJM.SALE_DT    <= MYREC.CLOSE_DT
                UNION ALL /*+ 원자재 기준 메뉴의 전체 매출           */
                SELECT    /*+ LEADING(V01) Index(SMM IDX01_SALE_JMM) */
                        0                                                       AS C_ITEM_USE_QTY,
                        SMM.SALE_QTY                                            AS C_ITEM_TOT_QTY,
                        V01.C_ITM_RCP_QTY                                       AS C_ITM_RCP_QTY
                FROM    SALE_JMM SMM,
                        W_RCP    V01
                WHERE   SMM.COMP_CD     = V01.COMP_CD
                AND     SMM.BRAND_CD    = V01.BRAND_CD
                AND     SMM.ITEM_CD     = V01.P_ITEM_CD
                AND     SMM.COMP_CD     = MYREC.COMP_CD
                AND     SMM.BRAND_CD    = MYREC.BRAND_CD
                AND     SMM.STOR_CD     = MYREC.STOR_CD
                AND     SMM.SALE_YM     = MYREC.PRC_YM
               );

        -- 원자재가 포함된 메뉴 전체 판매수량 대비 비율
        IF nC_ITEM_TOT_QTY = 0 THEN
            nC_ITEM_RATE  := 0;
        ELSE
            nC_ITEM_RATE  := nC_ITEM_USE_QTY / nC_ITEM_TOT_QTY;
        END IF;

        --vCURDATA := MYREC.BRAND_CD||'/'||MYREC.R_ITEM_CD||'/'||MYREC.C_ITEM_CD;
        --DBMS_OUTPUT.PUT_LINE(vCURDATA);
        -- 직가맹별 표준단가[레시피] 작성
        MERGE   INTO ITEM_CHAIN_RCP ICR
        USING  (
                SELECT  X01.COMP_CD,
                        X01.BRAND_CD,
                        X01.STOR_CD,
                        X01.ITEM_CD,
                        DECODE(nCOST_DIV, 'P', X03.P_COST, NVL(X02.LAST_COST, X01.COST))/DECODE(NVL(X01.ORD_UNIT_QTY, 1), 0, 1, NVL(X01.ORD_UNIT_QTY, 1)) AS COST,
                        X01.WEIGHT_UNIT,
                        X01.YIELD_RATE,
                        DECODE(nCOST_DIV, 'P', X03.P_COST, NVL(X02.LAST_COST, X01.COST))/(DECODE(NVL(X01.ORD_UNIT_QTY, 1), 0, 1, NVL(X01.ORD_UNIT_QTY, 1)) * DECODE(X01.UNIT_FLG, 0, NVL(X01.WEIGHT_UNIT, 1), 1)) AS PRD_PER_COST,
                        DECODE(nCOST_DIV, 'P', X03.P_COST, NVL(X02.LAST_COST, X01.COST)) AS LAST_COST
                FROM   (
                        SELECT  STO.COMP_CD,
                                STO.BRAND_CD,
                                STO.STOR_CD,
                                ITC.ITEM_CD,
                                NVL(HIS.COST, ITC.COST) COST,
                                ITC.WEIGHT_UNIT,
                                ITC.ORD_UNIT_QTY,
                                CASE WHEN ITC.STOCK_UNIT = ITC.DO_UNIT THEN 0 ELSE 1 END UNIT_FLG,
                                ITC.YIELD_RATE
                        FROM    STORE      STO,
                                ITEM_CHAIN ITC,
                               (
                                SELECT  COMP_CD,
                                        BRAND_CD,
                                        STOR_TP,
                                        ITEM_CD,
                                        COST, -- NVL(SUB_COST_PRC, COST) COST
                                        ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_TP, ITEM_CD ORDER BY START_DT DESC) AS R_NUM
                                FROM    ITEM_CHAIN_HIS
                                WHERE   COMP_CD   = MYREC.COMP_CD
                                AND     BRAND_CD  = MYREC.BRAND_CD
                                AND     STOR_TP   = MYREC.STOR_TP
                                AND     START_DT <= PSV_STD_YM||'31'
                               ) HIS
                        WHERE   STO.COMP_CD  = ITC.COMP_CD
                        AND     STO.BRAND_CD = ITC.BRAND_CD
                        AND     STO.STOR_TP  = ITC.STOR_TP
                        AND     ITC.COMP_CD  = HIS.COMP_CD (+)
                        AND     ITC.BRAND_CD = HIS.BRAND_CD(+)
                        AND     ITC.STOR_TP  = HIS.STOR_TP (+)
                        AND     ITC.ITEM_CD  = HIS.ITEM_CD (+)
                        AND     1            = HIS.R_NUM   (+)
                        AND     STO.COMP_CD  = MYREC.COMP_CD
                        AND     STO.BRAND_CD = MYREC.BRAND_CD
                        AND     STO.STOR_CD  = MYREC.STOR_CD
                        AND     ITC.ITEM_CD  = MYREC.C_ITEM_CD
                       ) X01,
                       (
                        SELECT  SDK.COMP_CD,
                                SDK.BRAND_CD,
                                SDK.STOR_CD,
                                SDK.ITEM_CD,
                                SDK.COST        AS LAST_COST,
                                ROW_NUMBER() OVER(PARTITION BY SDK.ITEM_CD ORDER BY SDK.PRC_DT DESC) R_NUM
                        FROM    DSTOCK     SDK
                        WHERE   SDK.COMP_CD  = MYREC.COMP_CD
                        AND     SDK.BRAND_CD = MYREC.BRAND_CD
                        AND     SDK.STOR_CD  = MYREC.STOR_CD
                        AND     SDK.ITEM_CD  = MYREC.C_ITEM_CD
                        AND     SDK.PRC_DT  <= MYREC.PRC_YM||'31'
                       ) X02,
                       (
                        SELECT  SDK.COMP_CD,
                                SDK.BRAND_CD,
                                SDK.STOR_CD,
                                SDK.ITEM_CD,
                                SDK.END_COST    AS P_COST
                        FROM    MSTOCK     SDK
                        WHERE   SDK.COMP_CD  = MYREC.COMP_CD
                        AND     SDK.BRAND_CD = MYREC.BRAND_CD
                        AND     SDK.STOR_CD  = MYREC.STOR_CD
                        AND     SDK.ITEM_CD  = MYREC.C_ITEM_CD
                        AND     SDK.PRC_YM   = MYREC.PRC_YM
                       ) X03
                WHERE   X01.COMP_CD  = X02.COMP_CD (+)
                AND     X01.BRAND_CD = X02.BRAND_CD(+)
                AND     X01.STOR_CD  = X02.STOR_CD (+)
                AND     X01.ITEM_CD  = X02.ITEM_CD (+)
                AND     1            = X02.R_NUM   (+)
                AND     X01.COMP_CD  = X03.COMP_CD (+)
                AND     X01.BRAND_CD = X03.BRAND_CD(+)
                AND     X01.STOR_CD  = X03.STOR_CD (+)
                AND     X01.ITEM_CD  = X03.ITEM_CD (+)
               ) V01
        ON (
                ICR.COMP_CD     = V01.COMP_CD
            AND ICR.CALC_YM     = MYREC.PRC_YM
            AND ICR.BRAND_CD    = V01.BRAND_CD
            AND ICR.STOR_CD     = V01.STOR_CD
            AND ICR.P_ITEM_CD   = MYREC.R_ITEM_CD
            AND ICR.C_ITEM_CD   = V01.ITEM_CD
           )
        WHEN MATCHED THEN
            UPDATE SET
                STD_QTY     = STD_QTY + nC_ITEM_USE_QTY,
                STD_AMT     = STD_AMT + nC_ITEM_USE_QTY * V01.PRD_PER_COST,
                RUN_QTY     = RUN_QTY + nC_ITEM_RATE * MYREC.REAL_USE_QTY,
                RUN_AMT     = RUN_AMT + nC_ITEM_RATE * MYREC.REAL_USE_QTY * RUN_COST
        WHEN NOT MATCHED THEN
            INSERT (
                    COMP_CD, CALC_YM, BRAND_CD, STOR_CD,
                    P_ITEM_CD, C_ITEM_CD, COST,
                    STD_QTY, STD_COST, STD_AMT,
                    RUN_QTY, RUN_COST, RUN_AMT,
                    INST_DT, INST_USER, UPD_DT, UPD_USER
                   )
            VALUES (
                    MYREC.COMP_CD,                                                          -- 회사코드
                    MYREC.PRC_YM,                                                           -- 처리년월
                    MYREC.BRAND_CD,                                                         -- 브랜드코드
                    MYREC.STOR_CD,                                                          -- 매장코드
                    MYREC.R_ITEM_CD,                                                        -- 부모코드(메뉴)
                    MYREC.C_ITEM_CD,                                                        -- 자식코드(원자재)
                    V01.LAST_COST,                                                          -- 최종 매입 원가
                    nC_ITEM_USE_QTY,                                                        -- 표준소모수량
                    V01.PRD_PER_COST * MYREC.PRD_RCP_QTY,                                   -- 표준원가
                    ROUND(nC_ITEM_USE_QTY * V01.PRD_PER_COST),                              -- 표준원가금액
                    nC_ITEM_RATE * MYREC.REAL_USE_QTY,                                      -- 실행소모수량(로스포함)
                    nCOST * MYREC.PRD_RCP_QTY,                                              -- 실행원가
                    ROUND(nC_ITEM_RATE * MYREC.REAL_USE_QTY * nCOST),                       -- 실행원가금액
                    SYSDATE,
                    'SYSTEM',
                    SYSDATE,
                    'SYSTEM'
                   );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('A4 -'||TO_CHAR(SYSDATE, 'HH24MISS'));
    -- 직가맹별 표준단가 작성 시작;
    --DATA CLEAR
    DELETE
    FROM    ITEM_CHAIN_STD
    WHERE   COMP_CD  = PSV_COMP_CD
    AND     BRAND_CD = PSV_BRAND_CD
    AND     CALC_YM  = PSV_STD_YM
    AND     STOR_CD  = '1010001';

    DBMS_OUTPUT.PUT_LINE('B2 -'||TO_CHAR(SYSDATE, 'HH24MISS'));
    -- 직가맹별 표준단가 작성 시작;
    BEGIN
        INSERT INTO ITEM_CHAIN_STD
            SELECT  /*+ LEADING(ICR) INDEX(SJM  PK_SALE_JMM) */
                    ICR.COMP_CD,
                    ICR.CALC_YM,
                    ICR.BRAND_CD,
                    ICR.STOR_CD,
                    ICR.P_ITEM_CD,
                    SJM.SALE_QTY, ICR.STD_COST, ICR.STD_AMT,
                    SJM.SALE_QTY, ICR.RUN_COST, ICR.RUN_AMT,
                    SJM.GRD_AMT, SJM.GRD_AMT - SJM.VAT_AMT,  SJM.VAT_AMT,
                    SYSDATE, 'SYSTEM',
                    SYSDATE, 'SYSTEM'
            FROM    SALE_JMM SJM,
                   (SELECT  /*+ INDEX(R1 PK_ITEM_CHAIN_RCP) */
                            R1.COMP_CD,
                            R1.CALC_YM,
                            R1.BRAND_CD,
                            R1.STOR_CD,
                            R1.P_ITEM_CD,
                            SUM(R1.STD_COST) AS STD_COST, SUM(R1.STD_AMT) AS STD_AMT,
                            SUM(R1.RUN_COST) AS RUN_COST, SUM(R1.RUN_AMT) AS RUN_AMT
                    FROM    ITEM_CHAIN_RCP R1
                    WHERE   COMP_CD  = PSV_COMP_CD
                    AND     BRAND_CD = PSV_BRAND_CD
                    AND     CALC_YM  = PSV_STD_YM
                    AND     STOR_CD  = '1010001'
                    GROUP BY
                            R1.COMP_CD,
                            R1.CALC_YM,
                            R1.BRAND_CD,
                            R1.STOR_CD,
                            R1.P_ITEM_CD
                    UNION ALL
                    SELECT  M.COMP_CD
                         ,  M.PRC_YM
                         ,  M.BRAND_CD
                         ,  M.STOR_CD
                         ,  M.ITEM_CD
                         ,  DECODE(nCOST_DIV, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY     AS STD_COST
                         ,  ROUND((M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) * I.WEIGHT_UNIT * DECODE(nCOST_DIV, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY)   AS STD_AMT
                         ,  DECODE(nCOST_DIV, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY     AS RUN_COST
                         ,  ROUND((M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) * I.WEIGHT_UNIT * DECODE(nCOST_DIV, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY)   AS RUN_AMT
                      FROM  MSTOCK      M
                         ,  (
                                SELECT  IC.COMP_CD
                                     ,  IC.BRAND_CD
                                     ,  IC.STOR_TP
                                     ,  IC.ITEM_CD
                                     ,  IC.ITEM_NM
                                     ,  NVL(IC.WEIGHT_UNIT, 1)  AS WEIGHT_UNIT
                                     ,  NVL(IC.ORD_UNIT_QTY, 1) AS ORD_UNIT_QTY
                                     ,  NVL(IH.COST, IC.COST)   AS COST
                                  FROM  ITEM_CHAIN      IC
                                     ,  ITEM_CHAIN_HIS  IH
                                 WHERE  IC.COMP_CD  = IH.COMP_CD
                                   AND  IC.BRAND_CD = IH.BRAND_CD
                                   AND  IC.STOR_TP  = IH.STOR_TP
                                   AND  IC.ITEM_CD  = IH.ITEM_CD
                                   AND  IC.COMP_CD  = PSV_COMP_CD
                                   AND  IC.BRAND_CD = PSV_BRAND_CD
                                   AND  IC.ORD_SALE_DIV IN ('2', '3')
                                   AND  START_DT    = (
                                                        SELECT  MAX(START_DT)
                                                          FROM  ITEM_CHAIN_HIS
                                                         WHERE  COMP_CD     = IH.COMP_CD
                                                           AND  BRAND_CD    = IH.BRAND_CD
                                                           AND  STOR_TP     = IH.STOR_TP
                                                           AND  ITEM_CD     = IH.ITEM_CD
                                                           AND  START_DT   <= PSV_STD_YM||'31'
                                                      )
                            )           I
                     WHERE  M.COMP_CD   = I.COMP_CD
                       AND  M.BRAND_CD  = I.BRAND_CD
                       AND  M.ITEM_CD   = I.ITEM_CD
                       AND  M.COMP_CD   = PSV_COMP_CD
                       AND  M.BRAND_CD  = PSV_BRAND_CD
                       AND  M.PRC_YM    = PSV_STD_YM
                       AND  M.ITEM_CD   NOT IN (
                                                    SELECT  P_ITEM_CD
                                                      FROM  ITEM_CHAIN_RCP
                                                     WHERE  COMP_CD     = PSV_COMP_CD
                                                       AND  BRAND_CD    = PSV_BRAND_CD
                                                       AND  CALC_YM     = PSV_STD_YM
                                               )
                       AND  I.STOR_TP   = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = M.COMP_CD AND BRAND_CD = M.BRAND_CD AND STOR_CD = M.STOR_CD )
                       AND  DECODE(nCOST_DIV, 'P', M.END_COST, I.COST) <> 0
                       AND  M.STOR_CD   = '1010001'
                   ) ICR
            WHERE   SJM.COMP_CD  = ICR.COMP_CD
            AND     SJM.SALE_YM  = ICR.CALC_YM
            AND     SJM.BRAND_CD = ICR.BRAND_CD
            AND     SJM.STOR_CD  = ICR.STOR_CD
            AND     SJM.ITEM_CD  = ICR.P_ITEM_CD;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN SQLERRM||'/'||vCURDATA;
    END;

    DBMS_OUTPUT.PUT_LINE('B2 -'||TO_CHAR(SYSDATE, 'HH24MISS'));

    COMMIT;
    RETURN '0';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR => STOR_CD : '||nSTOR_CD||', P_ITEM_CD : '||nP_ITEM_CD||', C_ITEM_CD : '||nC_ITEM_CD||' '||SQLERRM);
        RETURN SQLERRM||'/'||vCURDATA;
END FN_RCP_STD_0010;

/
