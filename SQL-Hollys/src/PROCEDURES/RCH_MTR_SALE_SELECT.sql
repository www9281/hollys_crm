--------------------------------------------------------
--  DDL for Procedure RCH_MTR_SALE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_MTR_SALE_SELECT" (
    P_RCH_NO     IN  VARCHAR2,
    N_STOR_CD    IN  VARCHAR2,
    P_START_DT   IN  VARCHAR2,
    P_END_DT     IN  VARCHAR2,
    P_MY_USER_ID IN  VARCHAR2,
    O_CURSOR     OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-08
    -- Description   :   설문조사 매출대비 모니터평가 비교 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      A.*
    FROM (
      SELECT
        A.STOR_CD, STO.STOR_NM, '매출' AS RESULT_DIV, (SELECT USER_NM FROM HQ_USER WHERE USER_ID = STO.SV_USER_ID) AS SV_USER_NM
        ,SUM(DECODE(A.SALE_YM, '01' , A.TOT_GRD_AMT, 0)) AS JANUARY
        ,SUM(DECODE(A.SALE_YM, '02' , A.TOT_GRD_AMT, 0)) AS FEBRUARY
        ,SUM(DECODE(A.SALE_YM, '03' , A.TOT_GRD_AMT, 0)) AS MARCH
        ,SUM(DECODE(A.SALE_YM, '04' , A.TOT_GRD_AMT, 0)) AS APRIL
        ,SUM(DECODE(A.SALE_YM, '05' , A.TOT_GRD_AMT, 0)) AS MAY
        ,SUM(DECODE(A.SALE_YM, '06' , A.TOT_GRD_AMT, 0)) AS JUNE
        ,SUM(DECODE(A.SALE_YM, '07' , A.TOT_GRD_AMT, 0)) AS JULY
        ,SUM(DECODE(A.SALE_YM, '08' , A.TOT_GRD_AMT, 0)) AS AUGUST
        ,SUM(DECODE(A.SALE_YM, '09' , A.TOT_GRD_AMT, 0)) AS SEPTEMBER
        ,SUM(DECODE(A.SALE_YM, '10' , A.TOT_GRD_AMT, 0)) AS OCTOBER
        ,SUM(DECODE(A.SALE_YM, '11' , A.TOT_GRD_AMT, 0)) AS NOVEMBER
        ,SUM(DECODE(A.SALE_YM, '12' , A.TOT_GRD_AMT, 0)) AS DECEMBER
        ,AVG(A.TOT_GRD_AMT) AS AVG_MONTH
      FROM (
          SELECT  
              STO.STOR_CD
              , SUBSTR(JDS.SALE_DT, 5, 2 ) AS SALE_YM
              , SUM(JDS.GRD_AMT) AS TOT_GRD_AMT
          FROM SALE_JDS JDS
               ,STORE  STO
          WHERE   STO.BRAND_CD = JDS.BRAND_CD
            AND   STO.STOR_CD  = JDS.STOR_CD
            AND   (N_STOR_CD IS NULL OR STO.STOR_CD = N_STOR_CD)
            AND   EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = STO.BRAND_CD AND USE_YN = 'Y')
            AND   JDS.SALE_DT  >= P_START_DT || '01'
            AND   JDS.SALE_DT  <= P_END_DT || '31'
          GROUP BY STO.STOR_CD, SUBSTR(JDS.SALE_DT, 5, 2))A, STORE STO
      WHERE A.STOR_CD = STO.STOR_CD
      GROUP BY A.STOR_CD, STO.STOR_NM, STO.SV_USER_ID
      UNION ALL
      SELECT
        A.STOR_CD, A.STOR_NM, A.RESULT_DIV, A.SV_USER_NM
        ,SUM(DECODE(A.RCH_YM, '01' , A.RCH_LV_RPLY_PT, 0)) AS JANUARY
        ,SUM(DECODE(A.RCH_YM, '02' , A.RCH_LV_RPLY_PT, 0)) AS FEBRUARY
        ,SUM(DECODE(A.RCH_YM, '03' , A.RCH_LV_RPLY_PT, 0)) AS MARCH
        ,SUM(DECODE(A.RCH_YM, '04' , A.RCH_LV_RPLY_PT, 0)) AS APRIL
        ,SUM(DECODE(A.RCH_YM, '05' , A.RCH_LV_RPLY_PT, 0)) AS MAY
        ,SUM(DECODE(A.RCH_YM, '06' , A.RCH_LV_RPLY_PT, 0)) AS JUNE
        ,SUM(DECODE(A.RCH_YM, '07' , A.RCH_LV_RPLY_PT, 0)) AS JULY
        ,SUM(DECODE(A.RCH_YM, '08' , A.RCH_LV_RPLY_PT, 0)) AS AUGUST
        ,SUM(DECODE(A.RCH_YM, '09' , A.RCH_LV_RPLY_PT, 0)) AS SEPTEMBER
        ,SUM(DECODE(A.RCH_YM, '10' , A.RCH_LV_RPLY_PT, 0)) AS OCTOBER
        ,SUM(DECODE(A.RCH_YM, '11' , A.RCH_LV_RPLY_PT, 0)) AS NOVEMBER
        ,SUM(DECODE(A.RCH_YM, '12' , A.RCH_LV_RPLY_PT, 0)) AS DECEMBER
        ,AVG(A.RCH_LV_RPLY_PT) AS AVG_MONTH
      FROM (
        SELECT
          STO.STOR_CD
          ,STO.STOR_NM
          , '모니터 평가' AS RESULT_DIV
          , (SELECT USER_NM FROM HQ_USER WHERE USER_ID = STO.SV_USER_ID) AS SV_USER_NM
          , TO_CHAR(A.INST_DT, 'MM') AS RCH_YM
          , SUM(A.RCH_LV_RPLY_PT) AS RCH_LV_RPLY_PT
        FROM RCH_LEVEL_REPLY A, STORE STO
        WHERE A.STOR_CD = STO.STOR_CD
          AND RCH_NO = P_RCH_NO
          AND (N_STOR_CD IS NULL OR A.STOR_CD = N_STOR_CD)
          AND TO_CHAR(A.INST_DT, 'YYYYMM') >= P_START_DT
          AND TO_CHAR(A.INST_DT, 'YYYYMM') <= P_END_DT
        GROUP BY STO.STOR_CD, STO.STOR_NM, STO.SV_USER_ID, TO_CHAR(A.INST_DT, 'MM')) A
      GROUP BY A.STOR_CD, A.STOR_NM, A.RESULT_DIV, A.SV_USER_NM) A
    ORDER BY A.STOR_CD, RESULT_DIV;
      
END RCH_MTR_SALE_SELECT;

/
