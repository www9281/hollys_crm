--------------------------------------------------------
--  DDL for Procedure RCH_QR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_QR_SELECT" (
    N_RCH_NO      IN  VARCHAR2,
    N_SV_USER_ID  IN  VARCHAR2,
    N_STOR_CD     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 조회
    -- ==========================================================================================
             
    OPEN O_CURSOR FOR
    SELECT
      A.*
      ,ROWNUM AS RNUM
    FROM (
      SELECT
        NVL(A.RCH_NO, N_RCH_NO) AS RCH_NO
        ,B.STOR_CD
        ,B.STOR_NM
        ,NVL(A.DAY_STAND_ISSUE, 0) AS DAY_STAND_ISSUE
        ,NVL(A.DAY_MEM_ISSUE, 0) AS DAY_MEM_ISSUE
        ,NVL(A.MONTH_STAND_ISSUE, 0) AS MONTH_STAND_ISSUE
        ,NVL(A.MONTH_MEM_ISSUE, 0) AS MONTH_MEM_ISSUE
        ,A.SAVE_YN
      FROM RCH_QR_MASTER A, STORE B
      WHERE A.STOR_CD (+)= B.STOR_CD
        AND A.RCH_NO (+)= N_RCH_NO
        AND (N_SV_USER_ID IS NULL OR B.SV_USER_ID = N_SV_USER_ID)
        AND (N_STOR_CD IS NULL OR B.STOR_CD = N_STOR_CD)
      ORDER BY B.STOR_NM ASC
    ) A
    ;
      
END RCH_QR_SELECT;

/
