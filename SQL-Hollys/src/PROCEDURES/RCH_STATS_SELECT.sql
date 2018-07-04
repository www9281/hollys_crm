--------------------------------------------------------
--  DDL for Procedure RCH_STATS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_STATS_SELECT" (
    O_CURSOR   OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 현황 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
       TO_CHAR(TO_DATE(A.RCH_START_DT), 'YYYY-MM-DD') AS RCH_START_DT
       ,TO_CHAR(TO_DATE(A.RCH_END_DT), 'YYYY-MM-DD') AS RCH_END_DT
       ,A.RCH_NM
       ,TRUNC(TO_DATE(A.RCH_END_DT)) - TRUNC(TO_DATE(A.RCH_START_DT)) AS RCH_DATE_TERM
       ,CASE WHEN TO_CHAR(SYSDATE, 'YYYYMMDD') >= A.RCH_START_DT AND TO_CHAR(SYSDATE, 'YYYYMMDD') <= A.RCH_END_DT THEN '진행중'
             ELSE '진행완료'
        END AS END_YN
       ,TO_CHAR(A.INST_DT, 'YYYY-MM-DD') AS INST_DT
       ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.INST_USER) AS INST_USER
       ,TO_CHAR(A.UPD_DT, 'YYYY-MM-DD') AS UPD_DT
       ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.UPD_USER) AS UPD_USER
    FROM RCH_MASTER A
    ; 
      
END RCH_STATS_SELECT;

/
