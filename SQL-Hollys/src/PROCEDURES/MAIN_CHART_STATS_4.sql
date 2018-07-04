--------------------------------------------------------
--  DDL for Procedure MAIN_CHART_STATS_4
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MAIN_CHART_STATS_4" (
    O_CURSOR  OUT SYS_REFCURSOR
) IS 
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   메인화면의 차트 데이터 조회 [금월까지 12개월 간의 매출을 선그래프로 표시]
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    WITH CUR AS (
    SELECT 
      TO_CHAR(ADD_MONTHS(SYSDATE, (LEVEL - 24)), 'YYYYMM') AS YMD 
      ,CASE WHEN ADD_MONTHS(SYSDATE, (LEVEL - 24)) < ADD_MONTHS(SYSDATE, -11) THEN 'COMPARE'
            ELSE 'NOW'
            END AS TYPE
    FROM DUAL
    CONNECT BY ADD_MONTHS(SYSDATE,(LEVEL - 24)) <= SYSDATE
    )
    SELECT
      SUBSTR(B.YMD, 5, 2) AS SALE_MM
      ,NVL(SUM(CASE WHEN B.TYPE = 'COMPARE' THEN A.GRD_AMT END)/1000, 0) AS COMPARE
      ,NVL(SUM(CASE WHEN B.TYPE = 'NOW' THEN A.GRD_AMT END), 0) AS NOW
    FROM (
        SELECT
          SUBSTR(B.SALE_DT, 0, 6) AS SALE_DT
          ,TRUNC(SUM(B.GRD_I_AMT + B.GRD_O_AMT)/10000) AS GRD_AMT
        FROM SALE_HD B
        GROUP BY SUBSTR(B.SALE_DT, 0, 6)
      ) A, CUR B
    WHERE B.YMD = A.SALE_DT(+)
    GROUP BY SUBSTR(B.YMD, 5, 2)
    ORDER BY SUBSTR(B.YMD, 5, 2)
    ;
    
END MAIN_CHART_STATS_4;

/
