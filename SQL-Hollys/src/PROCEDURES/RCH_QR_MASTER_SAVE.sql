--------------------------------------------------------
--  DDL for Procedure RCH_QR_MASTER_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_QR_MASTER_SAVE" (
    N_RCH_NO            IN  VARCHAR2,
    N_STOR_CD           IN  VARCHAR2,
    N_DAY_STAND_ISSUE   IN  VARCHAR2,
    N_DAY_MEM_ISSUE     IN  VARCHAR2,
    N_MONTH_STAND_ISSUE IN  VARCHAR2,
    N_MONTH_MEM_ISSUE   IN  VARCHAR2,
    O_CURSOR            OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 QR관리 목록 저장
    -- ==========================================================================================
            
    MERGE INTO RCH_QR_MASTER
    USING DUAL
    ON  (
          RCH_NO = N_RCH_NO
          AND STOR_CD = N_STOR_CD
        )
    WHEN MATCHED THEN
      UPDATE SET
        DAY_STAND_ISSUE = N_DAY_STAND_ISSUE
        ,DAY_MEM_ISSUE = N_DAY_MEM_ISSUE
        ,MONTH_STAND_ISSUE = N_MONTH_STAND_ISSUE
        ,MONTH_MEM_ISSUE = N_MONTH_MEM_ISSUE
    WHEN NOT MATCHED THEN
      INSERT (
        RCH_NO
        ,STOR_CD
        ,DAY_STAND_ISSUE
        ,DAY_MEM_ISSUE
        ,MONTH_STAND_ISSUE
        ,MONTH_MEM_ISSUE
      ) VALUES (
        N_RCH_NO
        ,N_STOR_CD
        ,N_DAY_STAND_ISSUE
        ,N_DAY_MEM_ISSUE
        ,N_MONTH_STAND_ISSUE
        ,N_MONTH_MEM_ISSUE
      )
    ;
      
END RCH_QR_MASTER_SAVE;

/
