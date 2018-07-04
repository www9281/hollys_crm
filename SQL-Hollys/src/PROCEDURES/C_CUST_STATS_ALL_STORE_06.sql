--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_ALL_STORE_06
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_ALL_STORE_06" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    P_MY_USER_ID	 IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-07
    -- Description   :   회원분석 전체회원 현황 [매장별 탭]
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
          (SELECT USER_ID FROM HQ_USER WHERE USER_ID = CUST.SV_USER_ID) AS DIV_TYPE1
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = CUST.STOR_CD) AS DIV_TYPE2
          , NVL(MSS.SALE_YM, JDS.SALE_YM) as SALE_YM
          
          -- 신규회원
          , CUST.TOT_CUST_CNT    -- 전체회원
          , CUST.NEW_CUST_CNT    -- 신규회원
          , MSS.CST_CUST_CNT     -- 구매(영수건수)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CUST.TOT_CUST_CNT * 100 END AS OPER_RATE  -- 가동률
          
          -- 회원방문횟수          
          , (SELECT SUM(BILL_CNT) FROM C_CUST_MSS WHERE SALE_YM <= CUST.SALE_YM) AS MSS_VISIT_CNT  -- 방문횟수(누적)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS_VISIT.CNT / CUST.TOT_CUST_CNT * 100 END AS MSS_VISIT_CNT_AVG  -- 회원당 방문횟수(평균)
          
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
              STO.SV_USER_ID
              , STO.STOR_CD
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
              AND (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
              AND CUST.STOR_CD = STO.STOR_CD
            GROUP BY STO.SV_USER_ID, STO.STOR_CD, L01.SALE_YM
          ) CUST
          ,(
            SELECT  
                  MSS.STOR_CD
                  , MSS.SALE_YM
                  , MSS.SV_USER_ID
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
                          , STO.SV_USER_ID
                          , ROW_NUMBER() OVER(PARTITION BY MSS.COMP_CD, MSS.STOR_CD, MSS.SALE_YM, MSS.CUST_ID ORDER BY MSS.CUST_LVL) R_NUM
                    FROM    C_CUST_MSS MSS
                          , STORE    STO
                    WHERE   STO.BRAND_CD = MSS.BRAND_CD
                    AND     STO.STOR_CD  = MSS.STOR_CD
                    AND     MSS.COMP_CD  = P_COMP_CD
                    AND     (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
                    AND     (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
                    AND     MSS.SALE_YM >= P_START_DT
                    AND     MSS.SALE_YM <= P_END_DT
                   ) MSS
            GROUP BY
                    MSS.STOR_CD
                  , MSS.SALE_YM
                  , MSS.SV_USER_ID
           ) MSS
          ,(
            SELECT  
                JDS.STOR_CD
                ,   STO.SV_USER_ID
                ,   SUBSTR(JDS.SALE_DT, 1, 6 )  AS SALE_YM
                ,   SUM(JDS.BILL_CNT)           AS TOT_BILL_CNT
                ,   SUM(JDS.SALE_QTY)           AS TOT_SALE_QTY
                ,   SUM(JDS.GRD_AMT)            AS TOT_GRD_AMT
            FROM    SALE_JDS JDS
                  , STORE  STO
            WHERE   STO.BRAND_CD = JDS.BRAND_CD
            AND     STO.STOR_CD  = JDS.STOR_CD
            AND     (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
            AND     (STO.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                       AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')))
            AND     JDS.SALE_DT  >= P_START_DT || '01'
            AND     JDS.SALE_DT  <= P_END_DT || '31'
            GROUP BY
                    JDS.STOR_CD
                  , STO.SV_USER_ID
                  , SUBSTR(JDS.SALE_DT, 1, 6 )
           ) JDS
           ,(
              SELECT
                MSS.SALE_YM
                ,SUM(MSS.BILL_CNT) AS CNT
              FROM C_CUST_MSS MSS
              WHERE MSS.SALE_YM <= P_END_DT
              GROUP BY MSS.SALE_YM
           ) MSS_VISIT
    WHERE  CUST.STOR_CD  = JDS.STOR_CD
    AND    CUST.SV_USER_ID  = JDS.SV_USER_ID
    AND    CUST.SALE_YM  = JDS.SALE_YM
    AND    JDS.STOR_CD  = MSS.STOR_CD (+)
    AND    JDS.SV_USER_ID  = MSS.SV_USER_ID (+)
    AND    JDS.SALE_YM  = MSS.SALE_YM (+)
    AND    JDS.SALE_YM  = MSS_VISIT.SALE_YM (+)
    ORDER BY CUST.SV_USER_ID, CUST.STOR_CD, CUST.SALE_YM;
    
END C_CUST_STATS_ALL_STORE_06;

/
