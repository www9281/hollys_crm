--------------------------------------------------------
--  DDL for Procedure RCH_TOT_MTR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_TOT_MTR_SELECT" (
    P_RCH_NO         IN  VARCHAR2,
    P_START_DT       IN  VARCHAR2,
    P_END_DT         IN  VARCHAR2,
    N_STOR_CD        IN  VARCHAR2,
    N_QR_CNT         IN  VARCHAR2,
    N_COUPON_CNT     IN  VARCHAR2,
    N_USE_COUPON_CNT IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-12
    -- Description   :   설문조사 온라인 쿠폰 발행 집계 모니터링 결과조회
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR 
    SELECT
      A.*
    FROM (
        SELECT
          A.RCH_NO
          ,A.STOR_CD
          ,(SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD) AS STOR_NM
          ,(SELECT FN_GET_CODE_NM('00605', TEAM_CD) FROM STORE WHERE STOR_CD = A.STOR_CD) AS TEAM_NM
          ,(SELECT (SELECT USER_NM FROM HQ_USER WHERE USER_ID = SV_USER_ID) FROM STORE WHERE STOR_CD = A.STOR_CD) AS SV_USER_NM
          ,SUM(DAY_STAND_ISSUE + DAY_MEM_ISSUE) AS ISSUE_QR_CNT
          ,SUM(MONTH_STAND_ISSUE + MONTH_MEM_ISSUE) AS ISSUE_COUPON_CNT
          ,SUM(CASE WHEN B.USE_DT IS NOT NULL THEN 1 ELSE 0 END) USE_COUPON_CNT
          ,SUM(DAY_STAND_ISSUE + DAY_MEM_ISSUE)/(TO_DATE(P_END_DT)-(TO_DATE(P_START_DT)-1)) ONE_DAY_ISSUE_QR
        FROM RCH_QR_ISSUE A LEFT OUTER JOIN PROMOTION_COUPON B
          ON A.COUPON_CD = B.COUPON_CD(+)
          WHERE A.RCH_NO = P_RCH_NO
          AND TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') >= P_START_DT
          AND TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') <= P_END_DT
          AND (N_STOR_CD IS NULL OR A.STOR_CD = N_STOR_CD)
        GROUP BY A.RCH_NO, A.STOR_CD
      ) A 
    WHERE (N_QR_CNT IS NULL OR A.ISSUE_QR_CNT >= N_QR_CNT)
      AND (N_COUPON_CNT IS NULL OR ISSUE_COUPON_CNT >= N_COUPON_CNT)
      AND (N_USE_COUPON_CNT IS NULL OR USE_COUPON_CNT >= N_USE_COUPON_CNT)
    ;
    
END RCH_TOT_MTR_SELECT;

/
