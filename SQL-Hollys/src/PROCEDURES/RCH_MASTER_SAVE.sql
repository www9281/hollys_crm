--------------------------------------------------------
--  DDL for Procedure RCH_MASTER_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_MASTER_SAVE" (
    N_RCH_NO              IN VARCHAR2,
    P_RCH_START_DT        IN VARCHAR2,
    P_RCH_END_DT          IN VARCHAR2,
    P_RCH_NM              IN VARCHAR2,
    N_QR_URL              IN VARCHAR2,
    N_PROMOTION_ID        IN VARCHAR2,
    N_RCH_TOT_POINT       IN VARCHAR2,
    N_RCH_TOT_LEVEL       IN VARCHAR2,
    N_RCH_1_LEVEL         IN VARCHAR2,
    N_RCH_2_LEVEL         IN VARCHAR2,
    N_RCH_3_LEVEL         IN VARCHAR2,
    N_RCH_4_LEVEL         IN VARCHAR2,
    N_RCH_5_LEVEL         IN VARCHAR2,         
    N_RCH_6_LEVEL         IN VARCHAR2,
    N_RCH_7_LEVEL         IN VARCHAR2,
    P_MY_USER_ID          IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 정보 저장
    -- ==========================================================================================
    
    -- 메인항목 변경
    MERGE INTO RCH_MASTER
    USING DUAL
    ON (
          RCH_NO = N_RCH_NO
       )
    WHEN MATCHED THEN
      UPDATE SET
        RCH_START_DT = P_RCH_START_DT
        ,RCH_END_DT = P_RCH_END_DT
        ,RCH_NM = P_RCH_NM
        ,QR_URL = N_QR_URL
        ,PROMOTION_ID = N_PROMOTION_ID
        ,RCH_TOT_POINT = N_RCH_TOT_POINT
        ,RCH_TOT_LEVEL = N_RCH_TOT_LEVEL
        ,RCH_1_LEVEL = N_RCH_1_LEVEL
        ,RCH_2_LEVEL = N_RCH_2_LEVEL
        ,RCH_3_LEVEL = N_RCH_3_LEVEL
        ,RCH_4_LEVEL = N_RCH_4_LEVEL
        ,RCH_5_LEVEL = N_RCH_5_LEVEL
        ,RCH_6_LEVEL = N_RCH_6_LEVEL
        ,RCH_7_LEVEL = N_RCH_7_LEVEL
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MY_USER_ID
    WHEN NOT MATCHED THEN
      INSERT (
        RCH_NO
        ,RCH_START_DT
        ,RCH_END_DT
        ,RCH_NM
        ,QR_URL
        ,PROMOTION_ID
        ,RCH_TOT_POINT
        ,RCH_TOT_LEVEL
        ,RCH_1_LEVEL
        ,RCH_2_LEVEL
        ,RCH_3_LEVEL
        ,RCH_4_LEVEL
        ,RCH_5_LEVEL
        ,RCH_6_LEVEL
        ,RCH_7_LEVEL
        ,INST_DT
        ,INST_USER
      ) VALUES (
        SQ_RCH_NO.NEXTVAL
        ,P_RCH_START_DT
        ,P_RCH_END_DT
        ,P_RCH_NM
        ,N_QR_URL
        ,N_PROMOTION_ID
        ,N_RCH_TOT_POINT
        ,N_RCH_TOT_LEVEL
        ,N_RCH_1_LEVEL
        ,N_RCH_2_LEVEL
        ,N_RCH_3_LEVEL
        ,N_RCH_4_LEVEL
        ,N_RCH_5_LEVEL
        ,N_RCH_6_LEVEL
        ,N_RCH_7_LEVEL
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
END RCH_MASTER_SAVE;

/
