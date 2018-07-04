--------------------------------------------------------
--  DDL for Procedure API_RCH_LEVEL_REPLY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_RCH_LEVEL_REPLY" (
    P_QR_NO                 IN  VARCHAR2,
    P_STOR_CD               IN  VARCHAR2,
    P_RCH_NO                IN  VARCHAR2,
    P_RCH_LV                IN  VARCHAR2,
    P_RCH_LV_CD             IN  VARCHAR2,
    P_RCH_LV_RPLY_SEQ       IN  VARCHAR2,
    N_RCH_LV_RPLY_PT        IN  VARCHAR2,
    N_RCH_LV_RPLY_USER      IN  VARCHAR2,
    N_RCH_LV_RPLY_CHK_YN    IN  VARCHAR2,
    P_USER_ID               IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-07
    -- Description   :   API 홈페이지 설문조사 고객답변 항목 전송
    -- ==========================================================================================
     
    ---------------- 설문&점포별 고객답변결과 저장
    MERGE INTO RCH_LEVEL_REPLY
    USING DUAL
    ON (RCH_NO = P_RCH_NO
        AND STOR_CD = P_STOR_CD
        AND QR_NO = P_QR_NO
        AND RCH_LV = P_RCH_LV
        AND RCH_LV_CD = P_RCH_LV_CD
        AND RCH_LV_RPLY_SEQ = P_RCH_LV_RPLY_SEQ)
    WHEN MATCHED THEN
      UPDATE SET
        RCH_LV_RPLY_PT = N_RCH_LV_RPLY_PT
        , RCH_LV_RPLY_USER = N_RCH_LV_RPLY_USER
        , RCH_LV_RPLY_CHK_YN = N_RCH_LV_RPLY_CHK_YN
    WHEN NOT MATCHED THEN
      INSERT (
        RCH_NO, STOR_CD, QR_NO, RCH_LV, RCH_LV_CD
        , RCH_LV_RPLY_SEQ, RCH_LV_RPLY_PT, RCH_LV_RPLY_USER, RCH_LV_RPLY_CHK_YN
        , INST_USER, INST_DT
      ) VALUES (
        P_RCH_NO, P_STOR_CD, P_QR_NO, P_RCH_LV, P_RCH_LV_CD
        , P_RCH_LV_RPLY_SEQ, N_RCH_LV_RPLY_PT, N_RCH_LV_RPLY_USER, N_RCH_LV_RPLY_CHK_YN
        , P_USER_ID, SYSDATE
      );
   
    
   
END API_RCH_LEVEL_REPLY;

/
