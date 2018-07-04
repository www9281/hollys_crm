--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ALL_STORE_05
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ALL_STORE_05" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_USER_ID	 IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-13
    -- Description   :   회원분석 전체회원 현황 [매장유형별 탭]
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT 
          GET_COMMON_CODE_NM('C9002', CUST.STOR_TG, 'KOR') AS DIV_TYPE1
          , JDS.SALE_YM AS SALE_YM
          
          -- 신규회원
          , CUST.TOT_CUST_CNT    -- 전체회원
          , CUST.NEW_CUST_CNT    -- 신규회원
          , MSS.CST_CUST_CNT     -- 구매(영수건수)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CUST.TOT_CUST_CNT * 100 END AS OPER_RATE  -- 가동률
          
          -- 회원방문횟수          
          , (SELECT SUM(BILL_CNT) FROM C_CUST_MSS A, STORE B WHERE A.STOR_CD = B.STOR_CD AND B.STOR_TG = CUST.STOR_TG AND SALE_YM <= CUST.SALE_YM) AS MSS_VISIT_CNT  -- 방문횟수(누적)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE (SELECT SUM(BILL_CNT) FROM C_CUST_MSS A, STORE B WHERE A.STOR_CD = B.STOR_CD AND B.STOR_TG = CUST.STOR_TG AND SALE_YM <= CUST.SALE_YM) / CUST.TOT_CUST_CNT END AS MSS_VISIT_CNT_AVG  -- 회원당 방문횟수
          
          -- 조단가
          , CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT
          , CASE WHEN (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0) ) <= 0 THEN 0
                 ELSE  (NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)) / (NVL(JDS.TOT_BILL_CNT,0) - NVL(MSS.CST_BILL_CNT,0))  END AS NCST_BILL_AMT
          
          -- 객단가
          , CASE WHEN CST_SALE_QTY = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_SALE_QTY END AS CST_SALE_AMT
          , CASE WHEN (NVL(JDS.TOT_SALE_QTY,0) - NVL(MSS.CST_SALE_QTY,0) ) <= 0 THEN 0
                 ELSE  (NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)) / (NVL(JDS.TOT_SALE_QTY,0) - NVL(MSS.CST_SALE_QTY,0))  END AS NCST_SALE_AMT
          
          --구매수량
          , MSS.CST_SALE_QTY
          , NVL(JDS.TOT_SALE_QTY,0) - NVL(MSS.CST_SALE_QTY,0) AS NCST_SALE_QTY
          , NVL(TO_CHAR(ROUND(MSS.CST_SALE_QTY/JDS.TOT_SALE_QTY *100, 2), '990.99'), '0')                     AS CST_SALE_RATE
          , NVL(TO_CHAR(ROUND((JDS.TOT_SALE_QTY - MSS.CST_SALE_QTY)/JDS.TOT_SALE_QTY*100, 2), '990.99'), '0') AS NCST_SALE_RATE
          
          -- 회원당 구매수량          
          , MSS.CST_SALE_QTY / MSS.CST_BILL_CNT AS CST_SALE_AVG  -- 회원당 구매수량 (회원)
          , (JDS.TOT_SALE_QTY-MSS.CST_SALE_QTY) / (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) AS NCST_SALE_AVG -- 회원당 구매수량 (비회원)
      
          --구매금액
          , MSS.CST_GRD_AMT
          , NVL(JDS.TOT_GRD_AMT,0) - NVL(MSS.CST_GRD_AMT,0)  AS NCST_GRD_AMT
          , NVL(TO_CHAR(ROUND(MSS.CST_GRD_AMT/JDS.TOT_GRD_AMT*100, 2), '990.99'), '0')                        AS CST_GRD_RATE
          , NVL(TO_CHAR(ROUND((JDS.TOT_GRD_AMT  - MSS.CST_GRD_AMT)/JDS.TOT_GRD_AMT*100, 2), '990.99'), '0')   AS NCST_GRD_RATE
          
          -- 회원당 구매금액            
          , MSS.CST_GRD_AMT / MSS.CST_BILL_CNT AS CST_GRD_AVG  -- 회원당 구매금액 (회원)
          , (JDS.TOT_GRD_AMT-MSS.CST_GRD_AMT) / (JDS.TOT_BILL_CNT - MSS.CST_BILL_CNT) AS NCST_GRD_AVG -- 회원당 구매금액 (비회원)
    FROM  (
            SELECT
              STO.STOR_TG
              , L01.SALE_YM
              , SUM(CASE WHEN TO_CHAR(CUST.INST_DT, 'YYYYMMDD') <=   L01.SALE_YM || '31' AND SUBSTR(NVL(CUST.LEAVE_DT, '99991231'), 1, 8) >= L01.SALE_YM || '31' THEN 1 ELSE 0 END) TOT_CUST_CNT
              , SUM(CASE WHEN TO_CHAR(CUST.INST_DT, 'YYYYMMDD') LIKE L01.SALE_YM || '%'  AND SUBSTR(NVL(CUST.LEAVE_DT, '99991231'), 1, 8) >= L01.SALE_YM || '31' THEN 1 ELSE 0 END) NEW_CUST_CNT
            FROM C_CUST CUST, STORE STO,
                (
                  SELECT TO_CHAR(ADD_MONTHS(TO_DATE(P_START_DT, 'YYYYMM'), ROWNUM - 1), 'YYYYMM') SALE_YM
                  FROM   TAB
                  WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE(P_END_DT, 'YYYYMM'), TO_DATE(P_START_DT, 'YYYYMM')) + 1)
                ) L01
            WHERE CUST.COMP_CD = P_COMP_CD
              AND (CUST.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                            AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = CUST.BRAND_CD AND USE_YN = 'Y')))
              AND SUBSTR(NVL(CUST.LEAVE_DT, '99991231'), 1, 8)  >= P_START_DT || '01'
              AND CUST.CUST_STAT IN ('1', '2', '9')
              AND TO_CHAR(CUST.INST_DT, 'YYYYMMDD') <= P_END_DT || '31'
              AND CUST.USE_YN = 'Y'
              AND CUST.STOR_CD = STO.STOR_CD
            GROUP BY STO.STOR_TG, L01.SALE_YM
          ) CUST
          ,(
            SELECT  
                  MSS.STOR_TG
                  , MSS.SALE_YM
                  , SUM(CASE WHEN R_NUM = 1 THEN 1 ELSE 0 END) CST_CUST_CNT
                  , SUM(MSS.BILL_CNT)           AS CST_BILL_CNT
                  , SUM(MSS.SALE_QTY)           AS CST_SALE_QTY
                  , SUM(MSS.GRD_AMT)            AS CST_GRD_AMT
            FROM   (
                    SELECT  
                          MSS.BRAND_CD
                          , MSS.STOR_CD
                          , MSS.SALE_YM
                          , MSS.CUST_ID
                          , MSS.BILL_CNT
                          , MSS.SALE_QTY
                          , MSS.GRD_AMT
                          , STO.STOR_TG
                          , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.STOR_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM
                    FROM    C_CUST_MSS MSS
                          , STORE    STO
                    WHERE   STO.BRAND_CD = MSS.BRAND_CD
                    AND     STO.STOR_CD  = MSS.STOR_CD
                    AND     MSS.COMP_CD  = P_COMP_CD
                    AND     (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                    AND     MSS.SALE_YM >= P_START_DT
                    AND     MSS.SALE_YM <= P_END_DT
                   ) MSS
            GROUP BY
                    MSS.STOR_TG
                  , MSS.SALE_YM
           ) MSS
          ,(
            SELECT  
                STO.STOR_TG
                ,   SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM
                ,   SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT
                ,   SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY
                ,   SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT
            FROM    SALE_JDS JDS
                  , STORE  STO
            WHERE   STO.BRAND_CD = JDS.BRAND_CD
            AND     STO.STOR_CD  = JDS.STOR_CD
            AND     (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                       AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
            AND     JDS.SALE_DT  >= P_START_DT || '01'
            AND     JDS.SALE_DT  <= P_END_DT || '31'
            GROUP BY 
                    STO.STOR_TG
                  , SUBSTR(JDS.SALE_DT, 1, 6 )
           ) JDS
    WHERE  CUST.STOR_TG        = JDS.STOR_TG
    AND    CUST.SALE_YM        = JDS.SALE_YM
    AND    JDS.STOR_TG         = MSS.STOR_TG (+)
    AND    JDS.SALE_YM         = MSS.SALE_YM (+)
    ORDER BY CUST.STOR_TG, JDS.SALE_YM;
    
END C_CUST_STATS_ALL_STORE_05;

/
