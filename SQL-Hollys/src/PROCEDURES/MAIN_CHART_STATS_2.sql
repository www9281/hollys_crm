--------------------------------------------------------
--  DDL for Procedure MAIN_CHART_STATS_2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MAIN_CHART_STATS_2" (
    O_CURSOR  OUT SYS_REFCURSOR
) IS 
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   메인화면의 차트 데이터 조회 [ㆍ전일부터 1주일간 상품의 판매 순위 5위까지 선정
    --                                             ㆍ나머지는 기타로 집계
    --                                             ㆍ데이터를 원그래프로 표시]
    --
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    SELECT 
      A.ITEM_CD
      , (SELECT ITEM_NM FROM ITEM WHERE ITEM_CD = A.ITEM_CD) AS ITEM_NM
      , CNT
    FROM (
      SELECT ITEM_CD, COUNT(*) AS CNT
      FROM SALE_DT A
      WHERE A.COMP_CD = '016'
      AND A.SALE_DT >= TO_CHAR(SYSDATE-8, 'YYYYMMDD')
      AND A.SALE_DT <= TO_CHAR(SYSDATE-1, 'YYYYMMDD')
      AND A.SUB_ITEM_DIV = '0'
      GROUP BY ITEM_CD
      ORDER BY CNT DESC)A
    WHERE ROWNUM <= 5
    ;
    
END MAIN_CHART_STATS_2;

/
