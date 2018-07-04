--------------------------------------------------------
--  DDL for Procedure RCH_RESULT_QR_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_RESULT_QR_SELECT" (
    P_RCH_NO        IN  VARCHAR2,
    N_STOR_CD       IN  VARCHAR2,
    N_SCH_DIV       IN  VARCHAR2,
    N_SCH_TEXT      IN  VARCHAR2,
    P_START_DT      IN  VARCHAR2,
    P_END_DT        IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-12
    -- Description   :   설문조사 매장별 답변결과 응모정보조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      (SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD) AS STOR_NM
      ,(CASE WHEN (SELECT STOR_TP FROM STORE WHERE STOR_CD = A.STOR_CD) = '10' THEN '직영' 
         WHEN (SELECT STOR_TP FROM STORE WHERE STOR_CD = A.STOR_CD) = '20' THEN '가맹' ELSE '가타' END) AS STOR_TP
      , ( SELECT COM.CODE_NM FROM COMMON COM WHERE COM.CODE_TP = '00605' AND COM.CODE_CD = (SELECT TEAM_CD FROM STORE WHERE STOR_CD = A.STOR_CD)) AS TEAM_NM
      ,(SELECT (SELECT USER_NM FROM HQ_USER WHERE USER_ID = SV_USER_ID) FROM STORE WHERE STOR_CD = A.STOR_CD) AS SV_USER_NM
      --,A.QR_NO
      ,A.RCH_NO
      ,A.STOR_CD
    FROM RCH_QR_ISSUE A
    WHERE A.RCH_NO = P_RCH_NO
      AND A.COUPON_CD IS NOT NULL
      AND (A.MONTH_STAND_ISSUE + A.MONTH_MEM_ISSUE) > 0
      AND TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') >= P_START_DT
      AND TO_CHAR(A.ISSUE_DT, 'YYYYMMDD') <= P_END_DT
      AND (N_SCH_TEXT IS NULL OR
                (
                  (N_SCH_DIV = '1' AND EXISTS (SELECT 1 FROM C_CUST WHERE DECRYPT(CUST_NM) LIKE '%' || N_SCH_TEXT || '%'))
                  OR
                  (N_SCH_DIV = '2' AND EXISTS (SELECT 1 FROM C_CUST WHERE DECRYPT(MOBILE) LIKE '%' || N_SCH_TEXT || '%'))
                  OR
                  (N_SCH_DIV = '3' AND A.COUPON_CD = N_SCH_TEXT)
                )
          )
    GROUP BY A.RCH_NO, A.STOR_CD
    ;
END RCH_RESULT_QR_SELECT;

/
