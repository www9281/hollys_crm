--------------------------------------------------------
--  DDL for Procedure MAIN_CHART_STATS_5
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MAIN_CHART_STATS_5" (
    O_CURSOR  OUT SYS_REFCURSOR
) IS 
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   메인화면의 차트 데이터 조회 [어제까지 7일간의 평균 조단가를 선그래프로 표시]
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    WITH CUR AS (
      SELECT
        TO_CHAR(SYSDATE - LEVEL, 'YYYYMMDD') AS YMD
        ,TO_CHAR(SYSDATE - LEVEL, 'DY') AS DY
        ,CASE WHEN SYSDATE - LEVEL < SYSDATE - 7 THEN 'COMPARE'
              ELSE 'NOW'
              END AS TYPE
        ,CASE WHEN LEVEL > 7 THEN 15 - LEVEL 
              ELSE 8 - LEVEL
              END AS ORD_NUM
      FROM DUAL
      CONNECT BY (SYSDATE+(LEVEL-15)) < SYSDATE
    )
    SELECT
      B.DY AS SALE_DT
      ,SUM(CASE WHEN B.TYPE = 'COMPARE' THEN A.GRD_AMT END) AS COMPARE
      ,SUM(CASE WHEN B.TYPE = 'NOW' THEN A.GRD_AMT END) AS NOW
    FROM (SELECT /*+ INDEX (SALE_HD SALE_HD_INDEX1) */
            SALE_DT
            ,TRUNC(AVG(GRD_I_AMT + GRD_O_AMT)) AS GRD_AMT
          FROM SALE_HD
          WHERE COMP_CD = '016'
            AND SALE_DT BETWEEN TO_CHAR(SYSDATE-15,'YYYYMMDD') AND TO_CHAR(SYSDATE-1,'YYYYMMDD')
--            AND SALE_DIV = '1'
--            AND STOR_CD NOT IN ('180218')
          GROUP BY SALE_DT
          ORDER BY SALE_DT) A, CUR B
    WHERE A.SALE_DT = B.YMD
    GROUP BY B.DY, B.ORD_NUM
--    ORDER BY B.ORD_NUM DESC , B.DY ASC
    ORDER BY B.ORD_NUM
    ;
    
END MAIN_CHART_STATS_5;

/
