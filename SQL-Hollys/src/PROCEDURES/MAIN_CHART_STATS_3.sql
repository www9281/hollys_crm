--------------------------------------------------------
--  DDL for Procedure MAIN_CHART_STATS_3
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MAIN_CHART_STATS_3" (
    O_CURSOR  OUT SYS_REFCURSOR
) IS 
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-20
    -- Description   :   메인화면의 차트 데이터 조회 [상담완료를 제외한 상담상태별 미완료 건수를 원그래프로 표시]
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    SELECT 
      PRCS_STATE
      ,GET_COMMON_CODE_NM('C4001', PRCS_STATE) AS PRCS_STATE_NM
      ,COUNT(*) AS VOC_CNT
    FROM C_VOC
    WHERE PRCS_STATE != '03' -- 상담완료 제외
    GROUP BY PRCS_STATE
    ORDER BY VOC_CNT desc
    ;
    
END MAIN_CHART_STATS_3;

/
