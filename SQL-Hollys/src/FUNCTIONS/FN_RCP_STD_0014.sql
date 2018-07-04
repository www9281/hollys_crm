--------------------------------------------------------
--  DDL for Function FN_RCP_STD_0014
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_RCP_STD_0014" (   PSV_COMP_CD  IN VARCHAR2,
                                                    PSV_BRAND_CD IN VARCHAR2,
                                                    PSV_STD_YM  IN VARCHAR2
                                                )
RETURN VARCHAR2 IS
    CURSOR CUR_1 IS
        SELECT  START_DT
             ,  NVL(LEAD(TO_CHAR(TO_DATE(START_DT, 'YYYYMMDD') - 1, 'YYYYMMDD'), 1) OVER (ORDER BY START_DT), PSV_STD_YM||'31') AS CLOSE_DT
            FROM  (
                    SELECT  START_DT
                      FROM  ITEM_CHAIN_RCP_PCT1
                     WHERE  COMP_CD     = PSV_COMP_CD
                       AND  BRAND_CD    = PSV_BRAND_CD
                       AND  CALC_YM     = PSV_STD_YM
                     GROUP  BY START_DT
                );

    nC_ITEM_USE_QTY NUMBER(15, 6) := 0;         -- 메뉴 판매수량(디버깅용)
    nC_ITEM_TOT_QTY NUMBER(15, 6) := 0;         -- 원자재가 포함된 메뉴 전체 판매수량(디버깅용)
    ls_cost_div     PARA_BRAND.PARA_VAL%TYPE;   -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]

BEGIN
    BEGIN
      SELECT PARA_VAL
        INTO ls_cost_div
        FROM PARA_BRAND
       WHERE COMP_CD  = PSV_COMP_CD
         AND BRAND_CD = PSV_BRAND_CD
         AND PARA_CD  = '1005'; -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_cost_div      := 'C'; -- 최종매입가
    END;

    DBMS_OUTPUT.PUT_LINE('1. DELETE ITEM_CHAIN_RCP_PCT1 '||TO_CHAR(SYSDATE, 'HH24MISS'));    
    DELETE  ITEM_CHAIN_RCP_PCT1
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  CALC_YM     = PSV_STD_YM
       AND  BRAND_CD    = PSV_BRAND_CD;

    DBMS_OUTPUT.PUT_LINE('2. INSERT ITEM_CHAIN_RCP_PCT1 '||TO_CHAR(SYSDATE, 'HH24MISS'));
    INSERT  INTO ITEM_CHAIN_RCP_PCT1
    SELECT  COMP_CD                                 -- 회사 코드
         ,  DATA_DIV                                -- 데이터구분[1:Recipe, 2:Set Option]
         ,  PSV_STD_YM      AS CALC_YM              -- 처리년월
         ,  BRAND_CD                                -- 브랜드 코드
         ,  STOR_TP                                 -- 직가맹구분
         ,  P_ITEM_CD                               -- 메뉴 코드
         ,  C_ITEM_CD                               -- 원자재코드
         ,  START_DT                                -- 시작일자
         ,  CLOSE_DT                                -- 종료일자
         ,  PRD_RCP_QTY                             -- 메뉴별 원자재별 합계 소모수량
      FROM  (
                SELECT  COMP_CD
                     ,  '1'                                                                             AS DATA_DIV
                     ,  BRAND_CD
                     ,  STOR_TP
                     ,  P_ITEM_CD
                     ,  C_ITEM_CD
                     ,  CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END   AS START_DT
                     ,  MAX(CLOSE_DT)                                                                   AS CLOSE_DT
                     ,  SUM(DO_QTY)                                                                     AS PRD_RCP_QTY    -- 메뉴별 원자재별 합계 소모수량
                  FROM  TABLE(FN_RCP_STD_0011(PSV_COMP_CD, PSV_BRAND_CD, PSV_STD_YM))
                 GROUP  BY COMP_CD
                     ,  BRAND_CD
                     ,  STOR_TP
                     ,  P_ITEM_CD
                     ,  C_ITEM_CD
                     ,  CASE WHEN START_DT < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE START_DT END
                UNION
                SELECT  SR.COMP_CD
                     ,  '2'                                                 AS DATA_DIV
                     ,  SR.BRAND_CD
                     ,  I.STOR_TP
                     ,  SR.ITEM_CD                                          AS R_ITEM_CD
                     ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)   AS C_ITEM_CD
                     ,  MIN(CASE WHEN NVL(OI.START_DT, SR.START_DT) < PSV_STD_YM||'01' THEN PSV_STD_YM||'01' ELSE NVL(OI.START_DT, SR.START_DT) END) AS START_DT
                     ,  MAX(NVL(OI.CLOSE_DT, SR.CLOSE_DT))                  AS CLOSE_DT
                     ,  MAX(NVL(OI.DO_QTY, 1))                              AS PRD_RCP_QTY
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
                        )   OI
                     ,  (
                            SELECT  STOR_TP
                              FROM  ITEM_CHAIN
                             WHERE  COMP_CD = PSV_COMP_CD
                               AND  BRAND_CD= PSV_BRAND_CD
                             GROUP  BY STOR_TP
                        )   I
                 WHERE  SR.COMP_CD  = OI.COMP_CD(+)
                   AND  SR.BRAND_CD = OI.BRAND_CD(+)
                   AND  SR.OPTN_ITEM_CD = OI.OPT_GRP(+)
                   AND  SR.COMP_CD  = PSV_COMP_CD
                   AND  SR.BRAND_CD = PSV_BRAND_CD
                   AND  NVL(OI.START_DT, SR.START_DT) <= PSV_STD_YM||'31'
                   AND  NVL(OI.CLOSE_DT, SR.CLOSE_DT) >= PSV_STD_YM||'01'
                   AND  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD) IS NOT NULL
                   --AND  SR.USE_YN   = 'Y'
                 GROUP  BY SR.COMP_CD
                     ,  SR.BRAND_CD
                     ,  I.STOR_TP
                     ,  SR.ITEM_CD
                     ,  DECODE(GRP_DIV, '0', SR.OPTN_ITEM_CD, OI.ITEM_CD)
            );

    DBMS_OUTPUT.PUT_LINE('2. DELETE ITEM_CHAIN_RCP_PCT2 '||TO_CHAR(SYSDATE, 'HH24MISS'));    
    DELETE  ITEM_CHAIN_RCP_PCT2
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  CALC_YM     = PSV_STD_YM
       AND  BRAND_CD    = PSV_BRAND_CD;

    DBMS_OUTPUT.PUT_LINE('2. INSERT ITEM_CHAIN_RCP_PCT2 '||TO_CHAR(SYSDATE, 'HH24MISS'));
    INSERT  INTO ITEM_CHAIN_RCP_PCT2
    SELECT  M.COMP_CD
         ,  M.PRC_YM
         ,  M.BRAND_CD
         ,  M.STOR_CD
         ,  M.ITEM_CD
         ,  NVL(I.COST, 0) / NVL(I.ORD_UNIT_QTY, 1) * NVL(I.WEIGHT_UNIT, 1)     AS C_COST
         ,  NVL(M.END_COST, 0) / NVL(I.ORD_UNIT_QTY, 1) * NVL(I.WEIGHT_UNIT, 1) AS P_COST
         ,  M.BEGIN_QTY
         ,  M.END_QTY
         ,  M.ORD_QTY
         ,  M.RTN_QTY
         ,  M.MV_IN_QTY
         ,  M.MV_OUT_QTY
         ,  (
              M.BEGIN_QTY
            - M.END_QTY
            + M.ORD_QTY
            - M.RTN_QTY
            + M.MV_IN_QTY
            - M.MV_OUT_QTY
            ) * NVL(I.WEIGHT_UNIT, 1)                                           AS USE_QTY
      FROM  MSTOCK  M
         ,  (
                SELECT  IC.COMP_CD
                     ,  IC.BRAND_CD
                     ,  IC.STOR_TP
                     ,  IC.ITEM_CD
                     ,  NVL(IC.ORD_UNIT_QTY, 1)     AS ORD_UNIT_QTY
                     ,  NVL(IC.WEIGHT_UNIT, 1)      AS WEIGHT_UNIT
                     ,  NVL(ICH.COST, IC.COST)      AS COST
                  FROM  ITEM_CHAIN      IC
                     ,  (
                            SELECT  COMP_CD
                                 ,  BRAND_CD
                                 ,  STOR_TP
                                 ,  ITEM_CD
                                 ,  COST
                              FROM  ITEM_CHAIN_HIS  ICH
                             WHERE  COMP_CD     = PSV_COMP_CD
                               AND  BRAND_CD    = PSV_BRAND_CD
                               AND  USE_YN      = 'Y'
                               AND  START_DT    = (
                                                    SELECT  MAX(START_DT)
                                                      FROM  ITEM_CHAIN_HIS
                                                     WHERE  COMP_CD     = ICH.COMP_CD
                                                       AND  BRAND_CD    = ICH.BRAND_CD
                                                       AND  STOR_TP     = ICH.STOR_TP
                                                       AND  ITEM_CD     = ICH.ITEM_CD
                                                       AND  START_DT    <= PSV_STD_YM||'31'
                                                       AND  USE_YN      = 'Y'
                                                  )
                        )   ICH
                 WHERE  IC.COMP_CD  = ICH.COMP_CD(+)
                   AND  IC.BRAND_CD = ICH.BRAND_CD(+)
                   AND  IC.STOR_TP  = ICH.STOR_TP(+)
                   AND  IC.ITEM_CD  = ICH.ITEM_CD(+)
                   AND  IC.COMP_CD  = PSV_COMP_CD
                   AND  IC.BRAND_CD = PSV_BRAND_CD
            )   I
     WHERE  M.COMP_CD   = I.COMP_CD
       AND  M.BRAND_CD  = I.BRAND_CD
       AND  M.ITEM_CD   = I.ITEM_CD
       AND  I.STOR_TP   = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = M.COMP_CD AND BRAND_CD = M.BRAND_CD AND STOR_CD = M.STOR_CD )
       AND  M.COMP_CD   = PSV_COMP_CD
       AND  M.PRC_YM    = PSV_STD_YM
       AND  M.BRAND_CD  = PSV_BRAND_CD;

    DBMS_OUTPUT.PUT_LINE('3. DELETE ITEM_CHAIN_RCP_PCT3 '||TO_CHAR(SYSDATE, 'HH24MISS'));    
    DELETE  ITEM_CHAIN_RCP_PCT3
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  CALC_YM     = PSV_STD_YM
       AND  BRAND_CD    = PSV_BRAND_CD;

    DBMS_OUTPUT.PUT_LINE('3. INSERT ITEM_CHAIN_RCP_PCT3 '||TO_CHAR(SYSDATE, 'HH24MISS'));
    FOR MYREC IN CUR_1 LOOP
        MERGE   INTO ITEM_CHAIN_RCP_PCT3    PCT3
        USING  (
                    SELECT  COMP_CD
                         ,  CALC_YM
                         ,  BRAND_CD
                         ,  STOR_CD
                         ,  P_ITEM_CD
                         ,  C_ITEM_CD
                         ,  RCP_QTY
                         ,  C_COST
                         ,  P_COST
                         ,  USE_QTY
                         ,  NVL(MENU_USE_QTY, 0)    AS MENU_USE_QTY
                         ,  NVL(ITEM_TOT_QTY, 0)    AS ITEM_TOT_QTY
                         ,  0                       AS RUN_QTY
                      FROM  (
                                SELECT  --+ NO_MERGE USE_HASH(R S)
                                        R.COMP_CD
                                     ,  R.CALC_YM
                                     ,  R.BRAND_CD
                                     ,  R.STOR_CD
                                     ,  R.P_ITEM_CD
                                     ,  R.C_ITEM_CD
                                     ,  MAX(RCP_QTY)    AS RCP_QTY
                                     ,  MAX(C_COST)     AS C_COST
                                     ,  MAX(P_COST)     AS P_COST
                                     ,  MAX(USE_QTY)    AS USE_QTY
                                     ,  SUM(NVL(SALE_QTY, 0) * RCP_QTY)                                                                                     AS MENU_USE_QTY
                                     ,  SUM(SUM(NVL(SALE_QTY, 0) * RCP_QTY)) OVER (PARTITION BY R.COMP_CD, R.CALC_YM, R.BRAND_CD, R.STOR_CD, R.C_ITEM_CD)   AS ITEM_TOT_QTY
                                  FROM  (
                                            SELECT  PCT1.COMP_CD
                                                 ,  PCT1.CALC_YM
                                                 ,  PCT1.BRAND_CD
                                                 ,  PCT2.STOR_CD
                                                 ,  PCT1.P_ITEM_CD
                                                 ,  PCT1.C_ITEM_CD
                                                 ,  MAX(PCT1.RCP_QTY)   AS RCP_QTY
                                                 ,  MAX(PCT2.C_COST)    AS C_COST
                                                 ,  MAX(PCT2.P_COST)    AS P_COST
                                                 ,  MAX(PCT2.USE_QTY)   AS USE_QTY
                                              FROM  ITEM_CHAIN_RCP_PCT1     PCT1
                                                 ,  ITEM_CHAIN_RCP_PCT2     PCT2
                                             WHERE  PCT1.COMP_CD    = PCT2.COMP_CD
                                               AND  PCT1.CALC_YM    = PCT2.CALC_YM
                                               AND  PCT1.BRAND_CD   = PCT2.BRAND_CD
                                               AND  PCT1.STOR_TP    = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = PCT2.COMP_CD AND BRAND_CD = PCT2.BRAND_CD AND STOR_CD = PCT2.STOR_CD )
                                               AND  PCT1.C_ITEM_CD  = PCT2.C_ITEM_CD
                                               AND  PCT1.COMP_CD    = PSV_COMP_CD
                                               AND  PCT1.CALC_YM    = PSV_STD_YM
                                               AND  PCT1.BRAND_CD   = PSV_BRAND_CD
                                               --AND  MYREC.START_DT  BETWEEN PCT1.START_DT AND PCT1.CLOSE_DT
                                             GROUP  BY PCT1.COMP_CD
                                                 ,  PCT1.CALC_YM
                                                 ,  PCT1.BRAND_CD
                                                 ,  PCT2.STOR_CD
                                                 ,  PCT1.P_ITEM_CD
                                                 ,  PCT1.C_ITEM_CD
                                        )   R
                                     ,  SALE_JDM    S
                                 WHERE  S.COMP_CD(+)   = R.COMP_CD
                                   AND  S.SALE_DT(+)   BETWEEN MYREC.START_DT AND MYREC.CLOSE_DT
                                   AND  S.BRAND_CD(+)  = R.BRAND_CD
                                   AND  S.STOR_CD(+)   = R.STOR_CD
                                   AND  S.ITEM_CD(+)   = R.P_ITEM_CD
                                 GROUP  BY R.COMP_CD
                                     ,  R.CALC_YM
                                     ,  R.BRAND_CD
                                     ,  R.STOR_CD
                                     ,  R.P_ITEM_CD
                                     ,  R.C_ITEM_CD
                            )
                ) V01
        ON (
                    PCT3.COMP_CD        = V01.COMP_CD
                AND PCT3.CALC_YM        = V01.CALC_YM
                AND PCT3.BRAND_CD       = V01.BRAND_CD
                AND PCT3.STOR_CD        = V01.STOR_CD
                AND PCT3.P_ITEM_CD      = V01.P_ITEM_CD
                AND PCT3.C_ITEM_CD      = V01.C_ITEM_CD
           )
        WHEN MATCHED THEN
            UPDATE SET  MENU_USE_QTY    = PCT3.MENU_USE_QTY  + V01.MENU_USE_QTY
                     ,  ITEM_TOT_QTY    = PCT3.ITEM_TOT_QTY  + V01.ITEM_TOT_QTY
                     ,  RUN_QTY         = PCT3.RUN_QTY       + V01.RUN_QTY
        WHEN NOT MATCHED THEN
            INSERT 
            (
                        COMP_CD
                     ,  CALC_YM
                     ,  BRAND_CD
                     ,  STOR_CD
                     ,  P_ITEM_CD
                     ,  C_ITEM_CD
                     ,  RCP_QTY
                     ,  C_COST
                     ,  P_COST
                     ,  USE_QTY
                     ,  MENU_USE_QTY
                     ,  ITEM_TOT_QTY
                     ,  RUN_QTY
            ) VALUES (
                        V01.COMP_CD
                     ,  V01.CALC_YM
                     ,  V01.BRAND_CD
                     ,  V01.STOR_CD
                     ,  V01.P_ITEM_CD
                     ,  V01.C_ITEM_CD
                     ,  V01.RCP_QTY
                     ,  V01.C_COST
                     ,  V01.P_COST
                     ,  V01.USE_QTY
                     ,  V01.MENU_USE_QTY
                     ,  V01.ITEM_TOT_QTY
                     ,  V01.RUN_QTY
            );

        /*  
        SELECT  MENU_USE_QTY
             ,  ITEM_TOT_QTY
          INTO  nC_ITEM_USE_QTY, nC_ITEM_TOT_QTY
          FROM  ITEM_CHAIN_RCP_PCT3
         WHERE  STOR_CD = '1010001'
           AND  P_ITEM_CD = '0100001'
           AND  C_ITEM_CD = '110201';

         DBMS_OUTPUT.PUT_LINE(' START_DT => '||MYREC.START_DT||', CLOSE_DT => '||MYREC.CLOSE_DT||', MENU_USE_QTY => '||nC_ITEM_USE_QTY||', ITEM_TOT_QTY => '||nC_ITEM_TOT_QTY);
        */

    END LOOP;

    DBMS_OUTPUT.PUT_LINE('4. DELETE ITEM_CHAIN_RCP '||TO_CHAR(SYSDATE, 'HH24MISS'));
    DELETE  ITEM_CHAIN_RCP
    WHERE   COMP_CD  = PSV_COMP_CD
    AND     BRAND_CD = PSV_BRAND_CD
    AND     CALC_YM  = PSV_STD_YM;

    DBMS_OUTPUT.PUT_LINE('4. INSERT ITEM_CHAIN_RCP '||TO_CHAR(SYSDATE, 'HH24MISS'));
    -- 레시피 및 세트옵션에 포함된 식자재 집계
    INSERT  INTO ITEM_CHAIN_RCP
    SELECT  COMP_CD
         ,  CALC_YM
         ,  BRAND_CD
         ,  STOR_CD
         ,  P_ITEM_CD
         ,  C_ITEM_CD
         ,  DECODE(ls_cost_div, 'C', C_COST, P_COST)                        AS COST
         ,  MENU_USE_QTY                                                    AS STD_QTY
         ,  RCP_QTY * DECODE(ls_cost_div, 'C', C_COST, P_COST)              AS STD_COST
         ,  MENU_USE_QTY * DECODE(ls_cost_div, 'C', C_COST, P_COST)         AS STD_AMT
         ,  CASE WHEN ITEM_TOT_QTY <> 0 THEN MENU_USE_QTY / ITEM_TOT_QTY ELSE 0 END * USE_QTY   AS RUN_QTY
         ,  RCP_QTY * DECODE(ls_cost_div, 'C', C_COST, P_COST)              AS RUN_COST
         ,  CASE WHEN ITEM_TOT_QTY <> 0 THEN MENU_USE_QTY / ITEM_TOT_QTY ELSE 0 END * USE_QTY * DECODE(ls_cost_div, 'C', C_COST, P_COST)    AS RUN_AMT
         ,  SYSDATE
         ,  'SYSTEM'
         ,  SYSDATE
         ,  'SYSTEM'
      FROM  ITEM_CHAIN_RCP_PCT3
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  BRAND_CD    = PSV_BRAND_CD
       AND  CALC_YM     = PSV_STD_YM;

    -- 레시피 및 세트옵션에 포함이 되지 않은 식자재의 집계(매장 소모품등)
    INSERT  INTO ITEM_CHAIN_RCP
    SELECT  M.COMP_CD
         ,  M.PRC_YM
         ,  M.BRAND_CD
         ,  M.STOR_CD
         ,  M.ITEM_CD
         ,  M.ITEM_CD
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST)                        AS COST
         ,  0                                                                   AS STD_QTY
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY       AS STD_COST
         ,  0                                                                   AS STD_AMT
         ,  (M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) AS RUN_QTY
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY                   AS RUN_COST
         ,  (M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) * I.WEIGHT_UNIT * (DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY)  AS RUN_AMT
         ,  SYSDATE
         ,  'SYSTEM'
         ,  SYSDATE
         ,  'SYSTEM'
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
                   --AND  IC.ORD_SALE_DIV IN ('2', '3')
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
       AND  NOT EXISTS  ( 
                            SELECT  1
                              FROM  ITEM_CHAIN_RCP RCP
                             WHERE  RCP.COMP_CD   = M.COMP_CD
                               AND  RCP.CALC_YM   = M.PRC_YM
                               AND  RCP.BRAND_CD  = M.BRAND_CD
                               AND  RCP.STOR_CD   = M.STOR_CD
                               AND  RCP.C_ITEM_CD = M.ITEM_CD
                               AND  RCP.RUN_QTY  <> 0
                        )
       AND  I.STOR_TP   = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = M.COMP_CD AND BRAND_CD = M.BRAND_CD AND STOR_CD = M.STOR_CD );

    -- 레시피 및 세트옵션에 포함이 되지 않은 주문판매상품
    INSERT  INTO ITEM_CHAIN_RCP
    SELECT  M.COMP_CD
         ,  M.PRC_YM
         ,  M.BRAND_CD
         ,  M.STOR_CD
         ,  M.ITEM_CD
         ,  M.ITEM_CD
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST)                        AS COST
         ,  0                                                                   AS STD_QTY
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY       AS STD_COST
         ,  0                                                                   AS STD_AMT
         ,  (M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) AS RUN_QTY
         ,  DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY                   AS RUN_COST
         ,  (M.BEGIN_QTY - M.END_QTY + M.ORD_QTY - M.RTN_QTY + M.MV_IN_QTY - M.MV_OUT_QTY ) * I.WEIGHT_UNIT * (DECODE(ls_cost_div, 'P', M.END_COST, I.COST) / I.ORD_UNIT_QTY)  AS RUN_AMT
         ,  SYSDATE
         ,  'SYSTEM'
         ,  SYSDATE
         ,  'SYSTEM'
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
                   --AND  IC.ORD_SALE_DIV IN ('2', '3')
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
       AND  NOT EXISTS  ( 
                            SELECT  1
                              FROM  ITEM_CHAIN_RCP RCP
                             WHERE  RCP.COMP_CD   = M.COMP_CD
                               AND  RCP.CALC_YM   = M.PRC_YM
                               AND  RCP.BRAND_CD  = M.BRAND_CD
                               AND  RCP.STOR_CD   = M.STOR_CD
                               AND  RCP.P_ITEM_CD = M.ITEM_CD
                               AND  RCP.C_ITEM_CD = M.ITEM_CD
                        )
       AND  EXISTS      (
                            SELECT  1
                              FROM  SALE_JDM    S
                             WHERE  S.COMP_CD   = M.COMP_CD
                               AND  SUBSTR(S.SALE_DT, 1, 6) = M.PRC_YM
                               AND  S.BRAND_CD  = M.BRAND_CD
                               AND  S.STOR_CD   = M.STOR_CD
                               AND  S.ITEM_CD   = M.ITEM_CD
                        )
       AND  I.STOR_TP   = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = M.COMP_CD AND BRAND_CD = M.BRAND_CD AND STOR_CD = M.STOR_CD );

    DBMS_OUTPUT.PUT_LINE('5. DELETE ITEM_CHAIN_STD '||TO_CHAR(SYSDATE, 'HH24MISS'));
    DELETE  ITEM_CHAIN_STD
    WHERE   COMP_CD  = PSV_COMP_CD
    AND     BRAND_CD = PSV_BRAND_CD
    AND     CALC_YM  = PSV_STD_YM;

    DBMS_OUTPUT.PUT_LINE('5. INSERT ITEM_CHAIN_STD '||TO_CHAR(SYSDATE, 'HH24MISS'));
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
            GROUP BY
                    R1.COMP_CD,
                    R1.CALC_YM,
                    R1.BRAND_CD,
                    R1.STOR_CD,
                    R1.P_ITEM_CD
           ) ICR
    WHERE   SJM.COMP_CD  = ICR.COMP_CD
    AND     SJM.SALE_YM  = ICR.CALC_YM
    AND     SJM.BRAND_CD = ICR.BRAND_CD
    AND     SJM.STOR_CD  = ICR.STOR_CD
    AND     SJM.ITEM_CD  = ICR.P_ITEM_CD;
    COMMIT;

    RETURN '0';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR => '||SQLERRM);
        RETURN SQLERRM;
END FN_RCP_STD_0014;

/
