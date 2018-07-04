--------------------------------------------------------
--  DDL for Procedure API_C_CUST_DEVICE_PUSH_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_DEVICE_PUSH_SAVE" (
    P_CUST_ID   IN  VARCHAR2,
    N_DIV_NM    IN  VARCHAR2,
    N_DIV_YN    IN  VARCHAR2,
    O_RTN_CD    OUT VARCHAR2
)IS
    v_result_cd VARCHAR2(7) := '1';
    v_cust_cnt NUMBER;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-22
    -- Description   :   HOMEPAGE API용 고객 APP DEVICE 설정 정보 등록 및 수정
    -- ==========================================================================================
    
    -- 변수로 들어온 고객번호가 유효한번호인지 체크
    SELECT
      COUNT(*) INTO v_cust_cnt
    FROM C_CUST
    WHERE CUST_ID = P_CUST_ID;
    
    IF v_cust_cnt > 0 THEN
      MERGE INTO C_CUST_DEVICE_PUSH A
      USING DUAL
      ON (A.CUST_ID = P_CUST_ID
          AND A.DIV_NM = N_DIV_NM)
      WHEN MATCHED THEN
        UPDATE SET
          DIV_YN = N_DIV_YN
          ,UPD_DT = SYSDATE
      WHEN NOT MATCHED THEN
        INSERT (
          CUST_ID
          ,DIV_NM
          ,DIV_YN
          ,INST_DT
        ) VALUES (
          P_CUST_ID
          ,N_DIV_NM
          ,N_DIV_YN
          ,SYSDATE
        );
    ELSE
      -- 요청 대상자를 찾을 수 없습니다.
      v_result_cd := '170';
    END IF;
    
    O_RTN_CD := v_result_cd;
END API_C_CUST_DEVICE_PUSH_SAVE;

/
