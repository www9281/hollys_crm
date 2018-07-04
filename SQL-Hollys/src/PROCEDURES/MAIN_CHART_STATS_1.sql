--------------------------------------------------------
--  DDL for Procedure MAIN_CHART_STATS_1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MAIN_CHART_STATS_1" (
    --O_GRADE OUT SYS_REFCURSOR,
    --O_ITEM  OUT SYS_REFCURSOR,
    O_DATA  OUT SYS_REFCURSOR
) IS 
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   메인화면의 차트 데이터 조회 [전일부터 1주일간 총매출 순위 5위까지의 매장]
    -- ==========================================================================================
    
--    -- 등급목록
--    OPEN O_GRADE FOR
--    SELECT
--      LVL_NM
--    FROM C_CUST_LVL
--    ORDER BY LVL_CD
--    ;
--    
--    -- 판매 상위 5개 항목
--    OPEN O_ITEM FOR
--    SELECT A.ITEM_CD, A.ITEM_NM FROM (
--      SELECT A.ITEM_CD, (SELECT ITEM_NM FROM ITEM WHERE ITEM_CD = A.ITEM_CD) AS ITEM_NM, SUM(GRD_AMT) AS GRD_AMT FROM C_CUST_MMS A
--      GROUP BY A.ITEM_CD
--      ORDER BY SUM(A.GRD_AMT) DESC) A
--    WHERE ROWNUM < 6
--    ;
    
    OPEN O_DATA FOR
    SELECT 
      A.STOR_CD
      ,(SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD AND ROWNUM = 1) AS STOR_NM
      ,NVL(MEM_NON, 0) AS MEM_NON
      ,NVL(MEM_SIMPLE, 0) AS MEM_SIMPLE
      ,NVL(MEM_SILVER, 0) AS MEM_SILVER
      ,NVL(MEM_GOLD, 0) AS MEM_GOLD
      ,NVL(MEM_RED, 0) AS MEM_RED
    FROM (
        SELECT
          A.STOR_CD
          ,SUM(CASE WHEN B.LVL_CD IS NULL THEN A.GRD_I_AMT + A.GRD_O_AMT END) AS MEM_NON
          ,SUM(CASE WHEN B.LVL_CD = '000' THEN A.GRD_I_AMT + A.GRD_O_AMT END) AS MEM_SIMPLE
          ,SUM(CASE WHEN B.LVL_CD = '101' THEN A.GRD_I_AMT + A.GRD_O_AMT END) AS MEM_SILVER
          ,SUM(CASE WHEN B.LVL_CD = '102' THEN A.GRD_I_AMT + A.GRD_O_AMT END) AS MEM_GOLD
          ,SUM(CASE WHEN B.LVL_CD = '103' THEN A.GRD_I_AMT + A.GRD_O_AMT END) AS MEM_RED
          ,SUM(A.GRD_I_AMT + A.GRD_O_AMT) AS GRD_AMT
        FROM SALE_HD A, C_CUST B
        WHERE A.COMP_CD = '016'
          AND A.SALE_DT >= TO_CHAR(SYSDATE-8, 'YYYYMMDD')
          AND A.SALE_DT <= TO_CHAR(SYSDATE-1, 'YYYYMMDD')
          AND A.CUST_ID = B.CUST_ID(+)
          AND A.STOR_CD NOT IN ('180218')
        GROUP BY A.STOR_CD
        ORDER BY GRD_AMT DESC)A
    WHERE ROWNUM <= 5
    ;
    
END MAIN_CHART_STATS_1;

/
