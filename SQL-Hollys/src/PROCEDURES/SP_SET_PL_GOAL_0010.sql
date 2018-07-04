--------------------------------------------------------
--  DDL for Procedure SP_SET_PL_GOAL_0010
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_PL_GOAL_0010" ( PSV_COMP_CD  IN VARCHAR2,  -- 회사코드
                                                      PSV_BRAND_CD IN VARCHAR2,  -- 브랜드코드
                                                      PSV_STD_YM   IN VARCHAR2,  -- 기준년월
                                                      PSV_RTN_CD   OUT VARCHAR2, -- 처리결과코드
                                                      PSV_RTN_MSG  OUT VARCHAR2) -- 처리결과메시지
IS
    -- 월실적
    CURSOR CUR_1 IS
        SELECT  /*+ NO_MERGE LEADING(STO) */
                STO.COMP_CD,
                STO.BRAND_CD,
                STO.STOR_CD,
                TO_NUMBER(SUBSTR(TO_CHAR(LAST_DAY(TO_DATE(PSV_STD_YM||'01', 'YYYYMMDD')), 'YYYYMMDD'), 7, 2)) AS LAST_DAY_MON,
                NVL(SHD.STO_HOLI, 0) AS STO_HOLI,
                NVL(STO.SEAT,     1) AS SEAT,
                JDS.BILL_CNT,
                JMM.SALE_AMT,
                JMM.DC_AMT,
                JMM.GRD_AMT,
                JMM.FOOD_SALE_AMT,
                JMM.FOOD_DC_AMT,
                JMM.FOOD_GRD_AMT,
                JMM.BEGE_SALE_AMT,
                JMM.BEGE_DC_AMT,
                JMM.BEGE_GRD_AMT,
                JMM.ETC_SALE_AMT,
                JMM.ETC_DC_AMT,
                JMM.ETC_GRD_AMT,
                NVL(ICS.RUN_AMT, 0)         RUN_AMT,
                NVL(ICS.FOOD_RUN_AMT, 0)    FOOD_RUN_AMT,
                NVL(ICS.BEGE_RUN_AMT, 0)    BEGE_RUN_AMT,
                NVL(ICS.ETC_RUN_AMT, 0)     ETC_RUN_AMT
        FROM    STORE  STO,
               (
                SELECT  JDS.COMP_CD,
                        JDS.BRAND_CD,
                        JDS.STOR_CD,
                        SUM(CASE WHEN NVL(BPA.PARA_VAL, 'B') = 'C' 
                                 THEN JDS.ETC_M_CNT + JDS.ETC_F_CNT
                                 ELSE JDS.BILL_CNT  - JDS.R_BILL_CNT END) AS BILL_CNT    -- D:영수건수, C:고객수
                FROM    SALE_JDS   JDS,
                        PARA_BRAND BPA       
                WHERE   JDS.COMP_CD    = BPA.COMP_CD (+)
                AND     JDS.BRAND_CD   = BPA.BRAND_CD(+)
                AND     BPA.PARA_CD(+) = '1005' -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]
                AND     JDS.COMP_CD    = PSV_COMP_CD
                AND     JDS.BRAND_CD   = PSV_BRAND_CD
                AND     JDS.SALE_DT    LIKE PSV_STD_YM||'%'
                GROUP BY
                        JDS.COMP_CD,
                        JDS.BRAND_CD,
                        JDS.STOR_CD
               ) JDS,
               (
                SELECT  /*+ NO_MERGE LEADING(JMM) */
                        JMM.COMP_CD,
                        JMM.BRAND_CD,
                        JMM.STOR_CD,
                        SUM(JMM.SALE_AMT) AS SALE_AMT,               -- 총매출액(VAT제외)
                        SUM(JMM.DC_AMT)   AS DC_AMT,                 -- 할인금액(VAT제외)
                        SUM(JMM.GRD_AMT)  AS GRD_AMT,                -- 순매출액(VAT제외)
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13002' THEN JMM.SALE_AMT ELSE 0 END) FOOD_SALE_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13002' THEN JMM.DC_AMT   ELSE 0 END) FOOD_DC_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13002' THEN JMM.GRD_AMT  ELSE 0 END) FOOD_GRD_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13001' THEN JMM.SALE_AMT ELSE 0 END) BEGE_SALE_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13001' THEN JMM.DC_AMT   ELSE 0 END) BEGE_DC_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13001' THEN JMM.GRD_AMT  ELSE 0 END) BEGE_GRD_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD > '13002' THEN JMM.SALE_AMT ELSE 0 END) ETC_SALE_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD > '13002' THEN JMM.DC_AMT   ELSE 0 END) ETC_DC_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD > '13002' THEN JMM.GRD_AMT  ELSE 0 END) ETC_GRD_AMT
                FROM   (
                        SELECT  /*+ LEADING(SJM) */
                                SJM.COMP_CD,
                                SJM.BRAND_CD,
                                SJM.STOR_CD,
                                SJM.ITEM_CD,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN SJM.SALE_AMT / (1 + ITM.SALE_VAT_IN_RATE) 
                                     ELSE SJM.SALE_AMT             END AS SALE_AMT,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN(SJM.DC_AMT + SJM.ENR_AMT) / (1 + ITM.SALE_VAT_IN_RATE) 
                                     ELSE SJM.DC_AMT + SJM.ENR_AMT END AS DC_AMT,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN SJM.GRD_AMT / (1 + ITM.SALE_VAT_IN_RATE)
                                     ELSE SJM.GRD_AMT              END AS GRD_AMT
                        FROM    SALE_JMM    SJM,
                                ITEM        ITM
                        WHERE   SJM.COMP_CD     = ITM.COMP_CD
                        AND     SJM.ITEM_CD     = ITM.ITEM_CD
                        AND     SJM.COMP_CD     = PSV_COMP_CD
                        AND     SJM.BRAND_CD    = PSV_BRAND_CD
                        AND     SJM.SALE_YM     = PSV_STD_YM
                       ) JMM,        
                        ITEM_CLASS  CLS
                WHERE   JMM.COMP_CD     = CLS.COMP_CD
                AND     JMM.ITEM_CD     = CLS.ITEM_CD
                AND     CLS.ORG_CLASS_CD= '00'
                GROUP BY
                        JMM.COMP_CD,
                        JMM.BRAND_CD,
                        JMM.STOR_CD
               ) JMM,
               (
                SELECT  V02.COMP_CD,
                        V02.BRAND_CD,
                        V02.STOR_CD,
                        SUM(V02.RUN_AMT) AS RUN_AMT,                           -- 실행원가
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13002' THEN V02.RUN_AMT ELSE 0 END) FOOD_RUN_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13001' THEN V02.RUN_AMT ELSE 0 END) BEGE_RUN_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD > '13002' THEN V02.RUN_AMT ELSE 0 END) ETC_RUN_AMT
                FROM   (/* 레시피 상품(메뉴) */    
                        SELECT  COMP_CD,
                                BRAND_CD,
                                STOR_CD,
                                ITEM_CD,
                                RUN_AMT
                        FROM    ITEM_CHAIN_STD ICS
                        WHERE   COMP_CD      = PSV_COMP_CD
                        AND     BRAND_CD     = PSV_BRAND_CD
                        AND     CALC_YM      = PSV_STD_YM
                        UNION ALL
                        /* 레시피 이외의 상품(메뉴) */
                        SELECT  V01.COMP_CD,
                                V01.BRAND_CD,
                                V01.STOR_CD,
                                V01.ITEM_CD,
                                V01.SALE_QTY *
                                NVL(LAST_VALUE(DST.COST) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD, V01.ITEM_CD 
                                                              ORDER BY DST.PRC_DT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), V01.COST) /
                                V01.ORD_UNIT_QTY AS RUN_AMT 
                        FROM    DSTOCK  DST,
                               (
                                SELECT  /*+ NO_MERGE LEADING(STO) */
                                        JMM.COMP_CD,
                                        JMM.BRAND_CD,
                                        JMM.STOR_CD,
                                        JMM.ITEM_CD,
                                        JMM.SALE_QTY,
                                        NVL(ICH.ORD_UNIT_QTY, 1) ORD_UNIT_QTY,
                                        NVL(HIS.COST, ICH.COST) COST 
                                FROM    STORE      STO,
                                        SALE_JMM   JMM,
                                        ITEM_CHAIN ICH,
                                       (
                                        SELECT  COMP_CD,
                                                BRAND_CD,
                                                STOR_TP,
                                                ITEM_CD,
                                                COST,
                                                ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_TP, ITEM_CD ORDER BY START_DT DESC) R_NUM
                                        FROM    ITEM_CHAIN_HIS 
                                        WHERE   COMP_CD   = PSV_COMP_CD
                                        AND     BRAND_CD  = PSV_BRAND_CD
                                        AND     START_DT <= PSV_STD_YM||'31'
                                       ) HIS
                                WHERE   STO.COMP_CD  = JMM.COMP_CD
                                AND     STO.BRAND_CD = JMM.BRAND_CD
                                AND     STO.STOR_CD  = JMM.STOR_CD
                                AND     ICH.COMP_CD  = JMM.COMP_CD
                                AND     ICH.BRAND_CD = JMM.BRAND_CD
                                AND     ICH.ITEM_CD  = JMM.ITEM_CD
                                AND     ICH.STOR_TP  = STO.STOR_TP
                                AND     ICH.COMP_CD  = HIS.COMP_CD (+)
                                AND     ICH.BRAND_CD = HIS.BRAND_CD(+)
                                AND     ICH.STOR_TP  = HIS.STOR_TP (+)
                                AND     ICH.ITEM_CD  = HIS.ITEM_CD (+)
                                AND     1            = HIS.R_NUM   (+)
                                AND     JMM.COMP_CD  = PSV_COMP_CD
                                AND     JMM.BRAND_CD = PSV_BRAND_CD
                                AND     JMM.SALE_YM  = PSV_STD_YM
                                AND     NOT EXISTS( SELECT  1
                                                    FROM    RECIPE_BRAND_FOOD RBF
                                                    WHERE   RBF.COMP_CD   = JMM.COMP_CD
                                                    AND     RBF.BRAND_CD  = JMM.BRAND_CD
                                                    AND     RBF.P_ITEM_CD = JMM.ITEM_CD
                                                    AND     RBF.CLOSE_DT >= PSV_STD_YM||'01')
                               ) V01
                        WHERE   V01.COMP_CD      = DST.COMP_CD (+)
                        AND     V01.BRAND_CD     = DST.BRAND_CD(+)
                        AND     V01.STOR_CD      = DST.STOR_CD (+)
                        AND     V01.ITEM_CD      = DST.ITEM_CD (+)
                        AND     PSV_STD_YM||'31' > DST.PRC_DT  (+)
                       )         V02,
                        ITEM_CLASS     CLS
                WHERE   V02.COMP_CD      = CLS.COMP_CD
                AND     V02.ITEM_CD      = CLS.ITEM_CD
                AND     V02.COMP_CD      = PSV_COMP_CD
                AND     V02.BRAND_CD     = PSV_BRAND_CD
                AND     CLS.ORG_CLASS_CD = '00'
                GROUP BY
                        V02.COMP_CD,
                        V02.BRAND_CD,
                        V02.STOR_CD
               ) ICS,
               ( 
                SELECT  COMP_CD,
                        BRAND_CD,
                        STOR_CD,
                        COUNT(*) STO_HOLI
                FROM    STORE_HOLIDAY HOL
                WHERE   COMP_CD    = PSV_COMP_CD
                AND     BRAND_CD   = PSV_BRAND_CD
                GROUP BY
                        COMP_CD,
                        BRAND_CD,
                        STOR_CD
               ) SHD
        WHERE   STO.COMP_CD    = JDS.COMP_CD
        AND     STO.BRAND_CD   = JDS.BRAND_CD
        AND     STO.STOR_CD    = JDS.STOR_CD
        AND     STO.COMP_CD    = JMM.COMP_CD
        AND     STO.BRAND_CD   = JMM.BRAND_CD
        AND     STO.STOR_CD    = JMM.STOR_CD
        AND     STO.COMP_CD    = ICS.COMP_CD (+)
        AND     STO.BRAND_CD   = ICS.BRAND_CD(+)
        AND     STO.STOR_CD    = ICS.STOR_CD (+)
        AND     STO.COMP_CD    = SHD.COMP_CD (+)
        AND     STO.BRAND_CD   = SHD.BRAND_CD(+)
        AND     STO.STOR_CD    = SHD.STOR_CD (+)
        AND     STO.COMP_CD    = PSV_COMP_CD
        AND     STO.BRAND_CD   = PSV_BRAND_CD;

    -- 일실적    
    CURSOR CUR_2 IS
        SELECT  /*+ NO_MERGE LEADING(V01) */
                V01.COMP_CD,
                V01.BRAND_CD,
                V01.STOR_CD,
                V01.MON_DAYS,
                V01.HOLI_FG,
                SUM(CASE WHEN V01.HOLI_FG = 'N' THEN 1 ELSE 0 END) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_WORK_DAYS,
                JDS.BILL_CNT,
                SUM(JDS.BILL_CNT)     OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_BILL_CNT,
                JDM.GRD_AMT,
                SUM(JDM.GRD_AMT)      OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_GRD_AMT,
                JDM.FOOD_GRD_AMT,
                SUM(JDM.FOOD_GRD_AMT) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_FOOD_GRD_AMT,
                JDM.BEGE_GRD_AMT,
                SUM(JDM.BEGE_GRD_AMT) OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_BEGE_GRD_AMT,
                JDM.ETC_GRD_AMT,
                SUM(JDM.ETC_GRD_AMT)  OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD)  AS TOT_ETC_GRD_AMT,
                ROW_NUMBER() OVER(PARTITION BY V01.COMP_CD, V01.BRAND_CD, V01.STOR_CD ORDER BY V01.MON_DAYS) R_NUM
        FROM   (
                SELECT  /*+ NO_MERGE LEADING(STO) */
                        STO.COMP_CD,
                        STO.BRAND_CD,
                        STO.STOR_CD,
                        STO.MON_DAYS,
                        CASE WHEN SHO.START_DT IS NULL THEN 'N' ELSE 'Y' END AS HOLI_FG
                FROM    STORE_HOLIDAY SHO,
                       (
                        SELECT  /*+ NO_MERGE LEADING(STO) */
                                STO.COMP_CD,
                                STO.BRAND_CD,
                                STO.STOR_CD,
                                W01.MON_DAYS
                        FROM    STORE STO,          
                               (
                                SELECT  PSV_COMP_CD     COMP_CD,
                                        PSV_BRAND_CD    BRAND_CD,
                                        PSV_STD_YM||TO_CHAR(ROWNUM, 'FM00') MON_DAYS
                                FROM    TAB
                                WHERE   ROWNUM <= 31
                               ) W01
                        WHERE   STO.COMP_CD  = W01.COMP_CD
                        AND     STO.BRAND_CD = W01.BRAND_CD
                        ORDER BY
                                STO.COMP_CD,
                                STO.BRAND_CD,
                                STO.STOR_CD,
                                W01.MON_DAYS
                       ) STO               
                WHERE   STO.COMP_CD  = SHO.COMP_CD (+)
                AND     STO.BRAND_CD = SHO.BRAND_CD(+)
                AND     STO.STOR_CD  = SHO.STOR_CD (+)
                AND     'Y'          = SHO.USE_YN  (+)
                AND     STO.MON_DAYS = SHO.START_DT(+)
                AND     STO.COMP_CD  = PSV_COMP_CD
                AND     STO.BRAND_CD = PSV_BRAND_CD
               ) V01,
               (
                SELECT  JDS.COMP_CD,
                        JDS.BRAND_CD,
                        JDS.STOR_CD,
                        JDS.SALE_DT,
                       (CASE WHEN NVL(BPA.PARA_VAL, 'B') = 'C' 
                             THEN JDS.ETC_M_CNT + JDS.ETC_F_CNT
                             ELSE JDS.BILL_CNT  - JDS.R_BILL_CNT END) AS BILL_CNT    -- D:영수건수, C:고객수
                FROM    SALE_JDS   JDS,
                        PARA_BRAND BPA
                WHERE   JDS.COMP_CD    = BPA.COMP_CD (+)
                AND     JDS.BRAND_CD   = BPA.BRAND_CD(+)
                AND     BPA.PARA_CD(+) = '1005' -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]
                AND     JDS.COMP_CD    = PSV_COMP_CD
                AND     JDS.BRAND_CD   = PSV_BRAND_CD
                AND     JDS.SALE_DT    LIKE PSV_STD_YM||'%'
               ) JDS,
               (
                SELECT  /*+ NO_MERGE LEADING(JDM) */
                        JDM.COMP_CD,
                        JDM.BRAND_CD,
                        JDM.STOR_CD,
                        JDM.SALE_DT,
                        SUM(JDM.GRD_AMT)  AS GRD_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13002' THEN JDM.GRD_AMT  ELSE 0 END) AS FOOD_GRD_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD = '13001' THEN JDM.GRD_AMT  ELSE 0 END) AS BEGE_GRD_AMT,
                        SUM(CASE WHEN CLS.M_CLASS_CD NOT IN ('13001','13002') THEN JDM.GRD_AMT  ELSE 0 END) ETC_GRD_AMT
                FROM   (
                        SELECT  /*+ LEADING(SJD) */
                                SJD.COMP_CD,
                                SJD.BRAND_CD,
                                SJD.STOR_CD,
                                SJD.ITEM_CD,
                                SJD.SALE_DT,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN SJD.SALE_AMT / (1 + ITM.SALE_VAT_IN_RATE) 
                                     ELSE SJD.SALE_AMT             END AS SALE_AMT,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN(SJD.DC_AMT + SJD.ENR_AMT) / (1 + ITM.SALE_VAT_IN_RATE) 
                                     ELSE SJD.DC_AMT + SJD.ENR_AMT END AS DC_AMT,
                                CASE WHEN ITM.SALE_VAT_YN = 'Y' 
                                     THEN SJD.GRD_AMT / (1 + ITM.SALE_VAT_IN_RATE)
                                     ELSE SJD.GRD_AMT              END AS GRD_AMT
                        FROM    SALE_JDM    SJD,
                                ITEM        ITM
                        WHERE   SJD.COMP_CD     = ITM.COMP_CD
                        AND     SJD.ITEM_CD     = ITM.ITEM_CD
                        AND     SJD.COMP_CD     = PSV_COMP_CD
                        AND     SJD.BRAND_CD    = PSV_BRAND_CD
                        AND     SJD.SALE_DT  LIKE PSV_STD_YM||'%'
                       ) JDM,        
                        ITEM_CLASS  CLS
                WHERE   JDM.COMP_CD     = CLS.COMP_CD
                AND     JDM.ITEM_CD     = CLS.ITEM_CD
                AND     CLS.ORG_CLASS_CD= '00'
                GROUP BY
                        JDM.COMP_CD,
                        JDM.BRAND_CD,
                        JDM.STOR_CD,
                        JDM.SALE_DT
               ) JDM
        WHERE   V01.COMP_CD    = JDS.COMP_CD (+)
        AND     V01.BRAND_CD   = JDS.BRAND_CD(+)
        AND     V01.STOR_CD    = JDS.STOR_CD (+)
        AND     V01.MON_DAYS   = JDS.SALE_DT (+)
        AND     V01.COMP_CD    = JDM.COMP_CD (+)
        AND     V01.BRAND_CD   = JDM.BRAND_CD(+)
        AND     V01.STOR_CD    = JDM.STOR_CD (+)
        AND     V01.MON_DAYS   = JDM.SALE_DT (+)
        AND     V01.COMP_CD    = PSV_COMP_CD
        AND     V01.BRAND_CD   = PSV_BRAND_CD;

    --월 계정 과목
    CURSOR CUR_3 IS
        SELECT  ACC_CD, ACC_NM
        FROM    PL_ACC_MST
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     TERM_DIV = '2'
        AND     ACC_CD   < '20000'
        ORDER BY 
                ACC_CD;

    --일 계정 과목
    CURSOR CUR_4 IS
        SELECT  ACC_CD, ACC_NM
        FROM    PL_ACC_MST
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     TERM_DIV = '1'
        AND     ACC_CD   < '20000'
        ORDER BY 
                ACC_CD;

        --일 계정 과목
    CURSOR CUR_5 IS
        SELECT  ACC_CD, ACC_NM
        FROM    PL_ACC_MST
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     TERM_DIV = '2'
        AND     ACC_CD  IN('30000', '50000')
        ORDER BY 
                ACC_CD;

    TYPE T_WORK_DAY IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;
    TYPE T_BILL_CNT IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;
    TYPE T_GRD_AMT  IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;
    TYPE T_FOOD_AMT IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;
    TYPE T_BEGE_AMT IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;
    TYPE T_ETC_AMT  IS TABLE OF NUMBER(11) INDEX BY BINARY_INTEGER;

    MYREC1          CUR_1%ROWTYPE;
    MYREC2          CUR_2%ROWTYPE;
    MYREC3          CUR_3%ROWTYPE;
    MYREC4          CUR_4%ROWTYPE;
    MYREC5          CUR_5%ROWTYPE;

    ARR_WORK_DAY    T_WORK_DAY;
    ARR_BILL_CNT    T_BILL_CNT;
    ARR_GRD_AMT     T_GRD_AMT;
    ARR_FOOD_AMT    T_FOOD_AMT;
    ARR_BEGE_AMT    T_BEGE_AMT;
    ARR_ETC_AMT     T_ETC_AMT;

    nCOLVAL         NUMBER(12, 2) := 0;
BEGIN
    PSV_RTN_CD  := '0';
    PSV_RTN_MSG := NULL;

    /* 월 실적 작성 */
    BEGIN
        /* 월별 손익 실적 삭제 */
        DELETE  
        FROM    PL_GOAL_YM
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     BRAND_CD = PSV_BRAND_CD
        AND     GOAL_YM  = PSV_STD_YM
        AND     TO_NUMBER(ACC_CD) < 20000
        AND     GOAL_DIV = '3'
        AND     COST_DIV = '3'; -- 실적

        FOR MYREC1 IN CUR_1 LOOP
            FOR MYREC3 IN CUR_3 LOOP
                nCOLVAL := CASE WHEN MYREC3.ACC_CD = '10300' THEN MYREC1.BILL_CNT/MYREC1.SEAT/(MYREC1.LAST_DAY_MON - MYREC1.STO_HOLI)
                                WHEN MYREC3.ACC_CD = '10500' THEN MYREC1.GRD_AMT /(MYREC1.LAST_DAY_MON - MYREC1.STO_HOLI)
                                WHEN MYREC3.ACC_CD = '10600' THEN MYREC1.SALE_AMT
                                WHEN MYREC3.ACC_CD = '10605' THEN MYREC1.FOOD_SALE_AMT
                                WHEN MYREC3.ACC_CD = '10610' THEN MYREC1.BEGE_SALE_AMT
                                WHEN MYREC3.ACC_CD = '10615' THEN MYREC1.ETC_SALE_AMT
                                WHEN MYREC3.ACC_CD = '10700' THEN MYREC1.DC_AMT
                                WHEN MYREC3.ACC_CD = '10705' THEN MYREC1.FOOD_DC_AMT
                                WHEN MYREC3.ACC_CD = '10710' THEN MYREC1.BEGE_DC_AMT
                                WHEN MYREC3.ACC_CD = '10715' THEN MYREC1.ETC_DC_AMT
                                WHEN MYREC3.ACC_CD = '10900' THEN MYREC1.RUN_AMT
                                WHEN MYREC3.ACC_CD = '10905' THEN MYREC1.FOOD_RUN_AMT
                                WHEN MYREC3.ACC_CD = '10910' THEN MYREC1.BEGE_RUN_AMT
                                WHEN MYREC3.ACC_CD = '10915' THEN MYREC1.ETC_RUN_AMT
                                WHEN MYREC3.ACC_CD = '11000' THEN MYREC1.GRD_AMT      - MYREC1.RUN_AMT
                                WHEN MYREC3.ACC_CD = '11005' THEN MYREC1.FOOD_GRD_AMT - MYREC1.FOOD_RUN_AMT
                                WHEN MYREC3.ACC_CD = '11010' THEN MYREC1.BEGE_GRD_AMT - MYREC1.BEGE_RUN_AMT
                                WHEN MYREC3.ACC_CD = '11015' THEN MYREC1.ETC_GRD_AMT  - MYREC1.ETC_RUN_AMT
                                ELSE 0 END;

                INSERT INTO PL_GOAL_YM( COMP_CD,  GOAL_YM,  
                                        BRAND_CD, STOR_CD, 
                                        GOAL_DIV, COST_DIV, 
                                        ACC_CD,   GOAL_AMT, 
                                        INST_DT,  INST_USER,
                                        UPD_DT,   UPD_USER)

                VALUES (MYREC1.COMP_CD,         PSV_STD_YM,
                        MYREC1.BRAND_CD,        MYREC1.STOR_CD,
                        '3',                    '3',
                        MYREC3.ACC_CD,          nCOLVAL,
                        SYSDATE,                'SYSADMIN',
                        SYSDATE,                'SYSADMIN');
            END LOOP;            
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            PSV_RTN_CD  := '-1000';
            PSV_RTN_MSG := SQLERRM;

            -- 취소 처리
            ROLLBACK;

            RETURN;
    END;

    /* 월 실적 매장직접이익, 외식본부 손익 */
    BEGIN
        DELETE  
        FROM    PL_GOAL_YM
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     BRAND_CD = PSV_BRAND_CD
        AND     GOAL_YM  = PSV_STD_YM
        AND     ACC_CD  IN ('30000', '50000')
        AND     GOAL_DIV = '3'  -- 실적
        AND     COST_DIV = '3';

        FOR MYREC5 IN CUR_5 LOOP
            INSERT INTO PL_GOAL_YM
                SELECT  COMP_CD,  
                        GOAL_YM,  
                        BRAND_CD, 
                        STOR_CD, 
                        '3' GOAL_DIV, 
                        '3' COST_DIV, 
                        MYREC5.ACC_CD,   
                        SUM(CASE WHEN MYREC5.ACC_CD = '30000' THEN DECODE(ACC_CD, '11000', GOAL_AMT, '20000', GOAL_AMT * (-1), 0)
                                 ELSE DECODE(ACC_CD, '11000', GOAL_AMT, GOAL_AMT * (-1)) END),
                        SYSDATE,  
                        'SYSADMIN',
                        SYSDATE,   
                        'SYSADMIN'
                FROM    PL_GOAL_YM        
                WHERE   COMP_CD  = PSV_COMP_CD
                AND     BRAND_CD = PSV_BRAND_CD
                AND     GOAL_YM  = PSV_STD_YM
                AND     ACC_CD  IN ('11000', '20000', '40000')
                AND     GOAL_DIV = '3'
                AND     COST_DIV = '3'
                GROUP BY
                        COMP_CD,  
                        GOAL_YM,  
                        BRAND_CD, 
                        STOR_CD;

        END LOOP;       
    EXCEPTION 
        WHEN OTHERS THEN
            PSV_RTN_CD  := '-1001';
            PSV_RTN_MSG := SQLERRM;

            ROLLBACK;
            RETURN;            
    END;

    /* 일 실적 작성 */
    BEGIN 
        /* 월별 손익 실적 삭제 */
        DELETE  
        FROM    PL_GOAL_DD
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     BRAND_CD = PSV_BRAND_CD
        AND     GOAL_YM  = PSV_STD_YM
        AND     TO_NUMBER(ACC_CD) < 20000
        AND     GOAL_DIV = '3'; -- 실적

        FOR MYREC2 IN CUR_2 LOOP
            ARR_WORK_DAY(MYREC2.R_NUM) := CASE WHEN MYREC2.HOLI_FG = 'N' THEN 1 ELSE 0 END;
            ARR_BILL_CNT(MYREC2.R_NUM) := NVL(MYREC2.BILL_CNT, 0);
            ARR_GRD_AMT (MYREC2.R_NUM) := NVL(MYREC2.GRD_AMT,  0);
            ARR_FOOD_AMT(MYREC2.R_NUM) := NVL(MYREC2.FOOD_GRD_AMT, 0);
            ARR_BEGE_AMT(MYREC2.R_NUM) := NVL(MYREC2.BEGE_GRD_AMT, 0);
            ARR_ETC_AMT (MYREC2.R_NUM) := NVL(MYREC2.ETC_GRD_AMT,  0);

            IF MYREC2.R_NUM = 31 THEN
                FOR MYREC4 IN CUR_4 LOOP
                    -- 영업일수
                    IF MYREC4.ACC_CD = '10100' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,   PSV_STD_YM,       MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,   '3',              MYREC4.ACC_CD,
                                ARR_WORK_DAY(1),  ARR_WORK_DAY(2),  ARR_WORK_DAY(3),
                                ARR_WORK_DAY(4),  ARR_WORK_DAY(5),  ARR_WORK_DAY(6),
                                ARR_WORK_DAY(7),  ARR_WORK_DAY(8),  ARR_WORK_DAY(9),
                                ARR_WORK_DAY(10), ARR_WORK_DAY(11), ARR_WORK_DAY(12),
                                ARR_WORK_DAY(13), ARR_WORK_DAY(14), ARR_WORK_DAY(15),
                                ARR_WORK_DAY(16), ARR_WORK_DAY(17), ARR_WORK_DAY(18),
                                ARR_WORK_DAY(19), ARR_WORK_DAY(20), ARR_WORK_DAY(21),
                                ARR_WORK_DAY(22), ARR_WORK_DAY(23), ARR_WORK_DAY(24),
                                ARR_WORK_DAY(25), ARR_WORK_DAY(26), ARR_WORK_DAY(27),
                                ARR_WORK_DAY(28), ARR_WORK_DAY(29), ARR_WORK_DAY(30),
                                ARR_WORK_DAY(31), NVL(MYREC2.TOT_WORK_DAYS, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;           

                    -- 객수
                    IF MYREC4.ACC_CD = '10200' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,   PSV_STD_YM,       MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,   '3',              MYREC4.ACC_CD,
                                ARR_BILL_CNT(1),  ARR_BILL_CNT(2),  ARR_BILL_CNT(3),
                                ARR_BILL_CNT(4),  ARR_BILL_CNT(5),  ARR_BILL_CNT(6),
                                ARR_BILL_CNT(7),  ARR_BILL_CNT(8),  ARR_BILL_CNT(9),
                                ARR_BILL_CNT(10), ARR_BILL_CNT(11), ARR_BILL_CNT(12),
                                ARR_BILL_CNT(13), ARR_BILL_CNT(14), ARR_BILL_CNT(15),
                                ARR_BILL_CNT(16), ARR_BILL_CNT(17), ARR_BILL_CNT(18),
                                ARR_BILL_CNT(19), ARR_BILL_CNT(20), ARR_BILL_CNT(21),
                                ARR_BILL_CNT(22), ARR_BILL_CNT(23), ARR_BILL_CNT(24),
                                ARR_BILL_CNT(25), ARR_BILL_CNT(26), ARR_BILL_CNT(27),
                                ARR_BILL_CNT(28), ARR_BILL_CNT(29), ARR_BILL_CNT(30),
                                ARR_BILL_CNT(31), NVL(MYREC2.TOT_BILL_CNT, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;

                    --객단가
                    IF MYREC4.ACC_CD = '10400' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,   PSV_STD_YM,       MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,   '3',              MYREC4.ACC_CD,
                                CASE WHEN ARR_BILL_CNT(1)  = 0 THEN 0 ELSE ARR_GRD_AMT(1)  / ARR_BILL_CNT(1)  END,
                                CASE WHEN ARR_BILL_CNT(2)  = 0 THEN 0 ELSE ARR_GRD_AMT(2)  / ARR_BILL_CNT(2)  END,
                                CASE WHEN ARR_BILL_CNT(3)  = 0 THEN 0 ELSE ARR_GRD_AMT(3)  / ARR_BILL_CNT(3)  END,
                                CASE WHEN ARR_BILL_CNT(4)  = 0 THEN 0 ELSE ARR_GRD_AMT(4)  / ARR_BILL_CNT(4)  END,
                                CASE WHEN ARR_BILL_CNT(5)  = 0 THEN 0 ELSE ARR_GRD_AMT(5)  / ARR_BILL_CNT(5)  END,
                                CASE WHEN ARR_BILL_CNT(6)  = 0 THEN 0 ELSE ARR_GRD_AMT(6)  / ARR_BILL_CNT(6)  END,
                                CASE WHEN ARR_BILL_CNT(7)  = 0 THEN 0 ELSE ARR_GRD_AMT(7)  / ARR_BILL_CNT(7)  END,
                                CASE WHEN ARR_BILL_CNT(8)  = 0 THEN 0 ELSE ARR_GRD_AMT(8)  / ARR_BILL_CNT(8)  END,
                                CASE WHEN ARR_BILL_CNT(9)  = 0 THEN 0 ELSE ARR_GRD_AMT(9)  / ARR_BILL_CNT(9)  END,
                                CASE WHEN ARR_BILL_CNT(10) = 0 THEN 0 ELSE ARR_GRD_AMT(10) / ARR_BILL_CNT(10) END,
                                CASE WHEN ARR_BILL_CNT(11) = 0 THEN 0 ELSE ARR_GRD_AMT(11) / ARR_BILL_CNT(11) END,
                                CASE WHEN ARR_BILL_CNT(12) = 0 THEN 0 ELSE ARR_GRD_AMT(12) / ARR_BILL_CNT(12) END,
                                CASE WHEN ARR_BILL_CNT(13) = 0 THEN 0 ELSE ARR_GRD_AMT(13) / ARR_BILL_CNT(13) END,
                                CASE WHEN ARR_BILL_CNT(14) = 0 THEN 0 ELSE ARR_GRD_AMT(14) / ARR_BILL_CNT(14) END,
                                CASE WHEN ARR_BILL_CNT(15) = 0 THEN 0 ELSE ARR_GRD_AMT(15) / ARR_BILL_CNT(15) END,
                                CASE WHEN ARR_BILL_CNT(16) = 0 THEN 0 ELSE ARR_GRD_AMT(16) / ARR_BILL_CNT(16) END,
                                CASE WHEN ARR_BILL_CNT(17) = 0 THEN 0 ELSE ARR_GRD_AMT(17) / ARR_BILL_CNT(17) END,
                                CASE WHEN ARR_BILL_CNT(18) = 0 THEN 0 ELSE ARR_GRD_AMT(18) / ARR_BILL_CNT(18) END,
                                CASE WHEN ARR_BILL_CNT(19) = 0 THEN 0 ELSE ARR_GRD_AMT(19) / ARR_BILL_CNT(19) END,
                                CASE WHEN ARR_BILL_CNT(20) = 0 THEN 0 ELSE ARR_GRD_AMT(20) / ARR_BILL_CNT(20) END,
                                CASE WHEN ARR_BILL_CNT(21) = 0 THEN 0 ELSE ARR_GRD_AMT(21) / ARR_BILL_CNT(21) END,
                                CASE WHEN ARR_BILL_CNT(22) = 0 THEN 0 ELSE ARR_GRD_AMT(22) / ARR_BILL_CNT(22) END,
                                CASE WHEN ARR_BILL_CNT(23) = 0 THEN 0 ELSE ARR_GRD_AMT(23) / ARR_BILL_CNT(23) END,
                                CASE WHEN ARR_BILL_CNT(24) = 0 THEN 0 ELSE ARR_GRD_AMT(24) / ARR_BILL_CNT(24) END,
                                CASE WHEN ARR_BILL_CNT(25) = 0 THEN 0 ELSE ARR_GRD_AMT(25) / ARR_BILL_CNT(25) END,
                                CASE WHEN ARR_BILL_CNT(26) = 0 THEN 0 ELSE ARR_GRD_AMT(26) / ARR_BILL_CNT(26) END,
                                CASE WHEN ARR_BILL_CNT(27) = 0 THEN 0 ELSE ARR_GRD_AMT(27) / ARR_BILL_CNT(27) END,
                                CASE WHEN ARR_BILL_CNT(28) = 0 THEN 0 ELSE ARR_GRD_AMT(28) / ARR_BILL_CNT(28) END,
                                CASE WHEN ARR_BILL_CNT(29) = 0 THEN 0 ELSE ARR_GRD_AMT(29) / ARR_BILL_CNT(29) END,
                                CASE WHEN ARR_BILL_CNT(30) = 0 THEN 0 ELSE ARR_GRD_AMT(30) / ARR_BILL_CNT(30) END,
                                CASE WHEN ARR_BILL_CNT(31) = 0 THEN 0 ELSE ARR_GRD_AMT(31) / ARR_BILL_CNT(31) END,
                                CASE WHEN NVL(MYREC2.TOT_BILL_CNT, 0) = 0 THEN 0 ELSE NVL(MYREC2.TOT_GRD_AMT, 0) / MYREC2.TOT_BILL_CNT END,
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;

                    -- 순매출액
                    IF MYREC4.ACC_CD = '10800' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,  PSV_STD_YM,      MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,  '3',             MYREC4.ACC_CD,
                                ARR_GRD_AMT(1),  ARR_GRD_AMT(2),  ARR_GRD_AMT(3),
                                ARR_GRD_AMT(4),  ARR_GRD_AMT(5),  ARR_GRD_AMT(6),
                                ARR_GRD_AMT(7),  ARR_GRD_AMT(8),  ARR_GRD_AMT(9),
                                ARR_GRD_AMT(10), ARR_GRD_AMT(11), ARR_GRD_AMT(12),
                                ARR_GRD_AMT(13), ARR_GRD_AMT(14), ARR_GRD_AMT(15),
                                ARR_GRD_AMT(16), ARR_GRD_AMT(17), ARR_GRD_AMT(18),
                                ARR_GRD_AMT(19), ARR_GRD_AMT(20), ARR_GRD_AMT(21),
                                ARR_GRD_AMT(22), ARR_GRD_AMT(23), ARR_GRD_AMT(24),
                                ARR_GRD_AMT(25), ARR_GRD_AMT(26), ARR_GRD_AMT(27),
                                ARR_GRD_AMT(28), ARR_GRD_AMT(29), ARR_GRD_AMT(30),
                                ARR_GRD_AMT(31), NVL(MYREC2.TOT_GRD_AMT, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;

                    -- FOOD 순매출액
                    IF MYREC4.ACC_CD = '10805' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,  PSV_STD_YM,        MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,  '3',               MYREC4.ACC_CD,
                                ARR_FOOD_AMT(1),  ARR_FOOD_AMT(2),  ARR_FOOD_AMT(3),
                                ARR_FOOD_AMT(4),  ARR_FOOD_AMT(5),  ARR_FOOD_AMT(6),
                                ARR_FOOD_AMT(7),  ARR_FOOD_AMT(8),  ARR_FOOD_AMT(9),
                                ARR_FOOD_AMT(10), ARR_FOOD_AMT(11), ARR_FOOD_AMT(12),
                                ARR_FOOD_AMT(13), ARR_FOOD_AMT(14), ARR_FOOD_AMT(15),
                                ARR_FOOD_AMT(16), ARR_FOOD_AMT(17), ARR_FOOD_AMT(18),
                                ARR_FOOD_AMT(19), ARR_FOOD_AMT(20), ARR_FOOD_AMT(21),
                                ARR_FOOD_AMT(22), ARR_FOOD_AMT(23), ARR_FOOD_AMT(24),
                                ARR_FOOD_AMT(25), ARR_FOOD_AMT(26), ARR_FOOD_AMT(27),
                                ARR_FOOD_AMT(28), ARR_FOOD_AMT(29), ARR_FOOD_AMT(30),
                                ARR_FOOD_AMT(31), NVL(MYREC2.TOT_FOOD_GRD_AMT, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;

                    -- BEVERAGE 순매출액
                    IF MYREC4.ACC_CD = '10810' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,  PSV_STD_YM,      MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,  '3',             MYREC4.ACC_CD,
                                ARR_BEGE_AMT(1),  ARR_BEGE_AMT(2),  ARR_BEGE_AMT(3),
                                ARR_BEGE_AMT(4),  ARR_BEGE_AMT(5),  ARR_BEGE_AMT(6),
                                ARR_BEGE_AMT(7),  ARR_BEGE_AMT(8),  ARR_BEGE_AMT(9),
                                ARR_BEGE_AMT(10), ARR_BEGE_AMT(11), ARR_BEGE_AMT(12),
                                ARR_BEGE_AMT(13), ARR_BEGE_AMT(14), ARR_BEGE_AMT(15),
                                ARR_BEGE_AMT(16), ARR_BEGE_AMT(17), ARR_BEGE_AMT(18),
                                ARR_BEGE_AMT(19), ARR_BEGE_AMT(20), ARR_BEGE_AMT(21),
                                ARR_BEGE_AMT(22), ARR_BEGE_AMT(23), ARR_BEGE_AMT(24),
                                ARR_BEGE_AMT(25), ARR_BEGE_AMT(26), ARR_BEGE_AMT(27),
                                ARR_BEGE_AMT(28), ARR_BEGE_AMT(29), ARR_BEGE_AMT(30),
                                ARR_BEGE_AMT(31), NVL(MYREC2.TOT_BEGE_GRD_AMT, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;

                    -- 기타 순매출액
                    IF MYREC4.ACC_CD = '10815' THEN
                        INSERT INTO PL_GOAL_DD (
                                                COMP_CD, GOAL_YM,  BRAND_CD,
                                                STOR_CD, GOAL_DIV, ACC_CD,
                                                G_D01,   G_D02,    G_D03,
                                                G_D04,   G_D05,    G_D06,
                                                G_D07,   G_D08,    G_D09,
                                                G_D10,   G_D11,    G_D12,
                                                G_D13,   G_D14,    G_D15,
                                                G_D16,   G_D17,    G_D18,
                                                G_D19,   G_D20,    G_D21,
                                                G_D22,   G_D23,    G_D24,
                                                G_D25,   G_D26,    G_D27,
                                                G_D28,   G_D29,    G_D30,
                                                G_D31,   G_SUM,
                                                INST_DT, INST_USER,
                                                UPD_DT,  UPD_USER
                                               )
                        VALUES (
                                MYREC2.COMP_CD,  PSV_STD_YM,      MYREC2.BRAND_CD, 
                                MYREC2.STOR_CD,  '3',             MYREC4.ACC_CD,
                                ARR_ETC_AMT(1),  ARR_ETC_AMT(2),  ARR_ETC_AMT(3),
                                ARR_ETC_AMT(4),  ARR_ETC_AMT(5),  ARR_ETC_AMT(6),
                                ARR_ETC_AMT(7),  ARR_ETC_AMT(8),  ARR_ETC_AMT(9),
                                ARR_ETC_AMT(10), ARR_ETC_AMT(11), ARR_ETC_AMT(12),
                                ARR_ETC_AMT(13), ARR_ETC_AMT(14), ARR_ETC_AMT(15),
                                ARR_ETC_AMT(16), ARR_ETC_AMT(17), ARR_ETC_AMT(18),
                                ARR_ETC_AMT(19), ARR_ETC_AMT(20), ARR_ETC_AMT(21),
                                ARR_ETC_AMT(22), ARR_ETC_AMT(23), ARR_ETC_AMT(24),
                                ARR_ETC_AMT(25), ARR_ETC_AMT(26), ARR_ETC_AMT(27),
                                ARR_ETC_AMT(28), ARR_ETC_AMT(29), ARR_ETC_AMT(30),
                                ARR_ETC_AMT(31), NVL(MYREC2.TOT_ETC_GRD_AMT, 0),
                                SYSDATE,          'SYSADMIN',
                                SYSDATE,          'SYSADMIN'
                               );
                    END IF;
                END LOOP;
            END IF;
        END LOOP;
    EXCEPTION 
        WHEN OTHERS THEN
            PSV_RTN_CD  := '-2000';
            PSV_RTN_MSG := SQLERRM;

            -- 취소 처리
            ROLLBACK;

            RETURN;
    END;    

    PSV_RTN_CD  := '0';
    PSV_RTN_MSG := 'OK';

    -- 정상처리 완료
    COMMIT;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := '-9999';
        PSV_RTN_MSG := SQLERRM;

        -- 취소 처리
        ROLLBACK;

        RETURN;
END;

/
