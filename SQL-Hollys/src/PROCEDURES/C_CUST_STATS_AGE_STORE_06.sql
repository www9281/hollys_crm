--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_AGE_STORE_06
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_AGE_STORE_06" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_START_DT     IN  VARCHAR2,
    P_END_DT       IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_CUST_AGE     IN  VARCHAR2,
    P_MY_USER_ID	 IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-14
    -- Description   :   회원분석 연령대 현황 [매장별 탭]
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
          GET_COMMON_CODE_NM('01760', CUST.CUST_AGE_GROUP, 'KOR') AS AGE_GROUP
          , (SELECT USER_ID FROM HQ_USER WHERE USER_ID = CUST.SV_USER_ID) AS DIV_TYPE1
          , (SELECT STOR_NM FROM STORE WHERE STOR_CD = CUST.STOR_CD) AS DIV_TYPE2
          , CUST.SALE_YM AS SALE_YM
          
          -- 신규회원
          , CUST.TOT_CUST_CNT    -- 전체회원
          , CUST.NEW_CUST_CNT    -- 신규회원
          , MSS.CST_CUST_CNT     -- 구매(영수건수)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE MSS.CST_CUST_CNT / CUST.TOT_CUST_CNT * 100 END AS OPER_RATE  -- 가동률
          
          -- 회원방문횟수          
          , (SELECT SUM(BILL_CNT) FROM C_CUST_MSS A, STORE B WHERE A.STOR_CD = B.STOR_CD AND GET_AGE_GROUP(A.CUST_AGE) = CUST.CUST_AGE_GROUP AND B.SV_USER_ID = CUST.SV_USER_ID AND B.STOR_CD = CUST.STOR_CD AND SALE_YM <= CUST.SALE_YM) AS MSS_VISIT_CNT  -- 방문횟수(누적)
          , CASE WHEN CUST.TOT_CUST_CNT = 0 THEN 0 ELSE (SELECT SUM(BILL_CNT) FROM C_CUST_MSS A, STORE B WHERE A.STOR_CD = B.STOR_CD AND GET_AGE_GROUP(A.CUST_AGE) = CUST.CUST_AGE_GROUP AND B.SV_USER_ID = CUST.SV_USER_ID AND B.STOR_CD = CUST.STOR_CD AND SALE_YM <= CUST.SALE_YM) / CUST.TOT_CUST_CNT END AS MSS_VISIT_CNT_AVG  -- 회원당 방문횟수
          
          -- 조단가
          , CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_BILL_AMT
          
          -- 객단가
          , CASE WHEN CST_SALE_QTY = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_SALE_QTY END AS CST_SALE_AMT
          
          --구매수량
          , MSS.CST_SALE_QTY
          
          -- 회원당 구매수량          
          , CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_SALE_QTY / MSS.CST_BILL_CNT END AS CST_SALE_AVG  -- 회원당 구매수량 (회원)
      
          --구매금액
          , MSS.CST_GRD_AMT
          
          -- 회원당 구매금액            
          , CASE WHEN CST_BILL_CNT = 0 THEN 0 ELSE MSS.CST_GRD_AMT / MSS.CST_BILL_CNT END AS CST_GRD_AVG  -- 회원당 구매금액 (회원)
    FROM  (
            SELECT
              CUST.CUST_AGE_GROUP
              , STO.SV_USER_ID
              , STO.STOR_CD
              , L01.SALE_YM
              , SUM(CASE WHEN TO_CHAR(CUST.INST_DT, 'YYYYMMDD') <=   L01.SALE_YM || '31' AND SUBSTR(NVL(CUST.LEAVE_DT, '99991231'), 1, 8) >= L01.SALE_YM || '31' THEN 1 ELSE 0 END) TOT_CUST_CNT
              , SUM(CASE WHEN TO_CHAR(CUST.INST_DT, 'YYYYMMDD') LIKE L01.SALE_YM || '%'  AND SUBSTR(NVL(CUST.LEAVE_DT, '99991231'), 1, 8) >= L01.SALE_YM || '31' THEN 1 ELSE 0 END) NEW_CUST_CNT
            FROM 
                (
                  SELECT
                    A.*
                    ,GET_AGE_GROUP(
                       CASE WHEN REGEXP_INSTR(CASE WHEN A.LUNAR_DIV = 'L' THEN UF_LUN2SOL(A.BIRTH_DT, '0') ELSE A.BIRTH_DT END, '^(19|20)[0-9]{2}(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])') = 1
                            THEN TRUNC((TO_NUMBER(SUBSTR(TO_CHAR(SYSDATE, 'YYYYMMDD'), 1, 6)) - TO_NUMBER(SUBSTR(CASE WHEN A.LUNAR_DIV = 'L' THEN UF_LUN2SOL(BIRTH_DT, '0') ELSE A.BIRTH_DT END, 1, 6))) / 100 + 1)
                       ELSE 999 END) AS CUST_AGE_GROUP
                  FROM C_CUST A
                  WHERE A.COMP_CD = P_COMP_CD
                    AND (A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL
                                  AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y')))
                    AND SUBSTR(NVL(A.LEAVE_DT, '99991231'), 1, 8)  >= P_START_DT || '01'
                    AND A.CUST_STAT IN ('1', '2', '9')
                    AND TO_CHAR(A.INST_DT, 'YYYYMMDD') <= P_END_DT || '31'
                    AND A.USE_YN = 'Y'
                ) CUST
                , STORE STO
                ,(
                    SELECT TO_CHAR(ADD_MONTHS(TO_DATE(P_START_DT, 'YYYYMM'), ROWNUM - 1), 'YYYYMM') SALE_YM
                    FROM   TAB
                    WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE(P_END_DT, 'YYYYMM'), TO_DATE(P_START_DT, 'YYYYMM')) + 1)
                  ) L01
            WHERE CUST.STOR_CD = STO.STOR_CD
              AND (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
            GROUP BY CUST.CUST_AGE_GROUP, STO.SV_USER_ID, STO.STOR_CD, L01.SALE_YM
          ) CUST
          ,(
            SELECT  
                  MSS.CUST_AGE_GROUP 
                  , MSS.SV_USER_ID
                  , MSS.STOR_CD
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
                          , MSS.CUST_LVL
                          , MSS.BILL_CNT
                          , MSS.SALE_QTY
                          , MSS.GRD_AMT
                          , GET_AGE_GROUP(MSS.CUST_AGE) AS CUST_AGE_GROUP
                          , STO.SV_USER_ID
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
                    AND     (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
                   ) MSS
            GROUP BY
                    MSS.CUST_AGE_GROUP
                    , MSS.SV_USER_ID
                    , MSS.STOR_CD
                    , MSS.SALE_YM
           ) MSS
    WHERE  (N_CUST_AGE IS NULL OR CUST.CUST_AGE_GROUP = N_CUST_AGE)
    AND    CUST.CUST_AGE_GROUP  = MSS.CUST_AGE_GROUP (+)
    AND    CUST.SV_USER_ID = MSS.SV_USER_ID (+)
    AND    CUST.STOR_CD = MSS.STOR_CD (+)
    AND    CUST.SALE_YM  = MSS.SALE_YM (+)
    ORDER BY CUST.CUST_AGE_GROUP, CUST.SV_USER_ID, CUST.STOR_CD, CUST.SALE_YM;
    
END C_CUST_STATS_AGE_STORE_06;

/
