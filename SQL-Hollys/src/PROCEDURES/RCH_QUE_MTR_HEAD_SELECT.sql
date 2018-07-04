--------------------------------------------------------
--  DDL for Procedure RCH_QUE_MTR_HEAD_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_QUE_MTR_HEAD_SELECT" (
    P_RCH_NO  IN  VARCHAR2,
    O_CURSOR  OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-05
    -- Description   :   설문조사 문항별 모니터링 결과조회 헤더목록 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      A.RCH_LV
      ,A.RCH_LV_CD
      ,A.RCH_LV || '-' || A.RCH_LV_CD AS LV_CD
      ,(SELECT DIV_NM FROM RCH_DIV_CODE WHERE DIV_CODE = A.RCH_LV_DIV) AS DIV_NM
      ,COUNT(*) OVER(PARTITION BY RCH_LV) AS CNT
    FROM RCH_LEVEL_INFO A
    WHERE A.RCH_LV_DIV IS NOT NULL
      AND A.RCH_NO = P_RCH_NO
    ORDER BY A.RCH_LV_DIV, A.RCH_LV_CD
    ;
    
END RCH_QUE_MTR_HEAD_SELECT;

/
