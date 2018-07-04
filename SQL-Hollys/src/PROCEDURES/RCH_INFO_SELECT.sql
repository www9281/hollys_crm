--------------------------------------------------------
--  DDL for Procedure RCH_INFO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_INFO_SELECT" (
    P_QR_NO      IN  VARCHAR2,
    O_RCH_NO     OUT VARCHAR2,
    O_CUST_ID    OUT VARCHAR2,
    O_MOBILE     OUT VARCHAR2, 
    O_STOR_CD    OUT VARCHAR2,
    O_ISSUE_CHK  OUT VARCHAR2,
    O_PRMT_ID    OUT VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-08
    -- Description   :   API 설문조사 완료처리시 해당 설문의 정보를 조회하는 프로시저
    -- ==========================================================================================
    -- 해당응모번호의 고객정보 조회
    SELECT
      MAX(A.RCH_NO), MAX(B.CUST_ID), MAX(DECRYPT(B.MOBILE)), MAX(A.STOR_CD), MAX(C.PROMOTION_ID) INTO O_RCH_NO, O_CUST_ID, O_MOBILE, O_STOR_CD, O_PRMT_ID
    FROM RCH_QR_ISSUE A, C_CUST B, RCH_MASTER C
    WHERE A.QR_NO = P_QR_NO
      AND A.RCH_NO = C.RCH_NO
      AND (A.DAY_STAND_ISSUE != 0 OR A.DAY_MEM_ISSUE != 0)
      AND EXISTS (SELECT 1 FROM RCH_MASTER WHERE RCH_NO = A.RCH_NO AND RCH_START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD') AND RCH_END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
      AND A.CUST_ID = B.CUST_ID (+);
     
    -- 해당 응모번호로 이미 설문조사 발행했는지 체크(Y : 이미발행 N: 발행안됨)
    SELECT
      CASE WHEN (SUM(A.MONTH_STAND_ISSUE) + SUM(A.MONTH_MEM_ISSUE)) > 0 THEN 'Y' ELSE 'N' END INTO O_ISSUE_CHK
    FROM RCH_QR_ISSUE A
    WHERE A.QR_NO = P_QR_NO;
      
END RCH_INFO_SELECT;

/
