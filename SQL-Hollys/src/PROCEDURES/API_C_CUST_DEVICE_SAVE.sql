--------------------------------------------------------
--  DDL for Procedure API_C_CUST_DEVICE_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_DEVICE_SAVE" (
    P_CUST_ID         IN  VARCHAR2,
    N_DEVICE_DIV      IN  VARCHAR2,
    N_DEVICE_NM       IN  VARCHAR2,
    N_AUTH_ID         IN  VARCHAR2,
    N_AUTH_TOKEN      IN  VARCHAR2,
    N_DOWN_COUPON_YN  IN  VARCHAR2,
    N_USE_YN          IN  VARCHAR2,
    O_RTN_CD          OUT VARCHAR2
)IS
    v_result_cd VARCHAR2(7) := '1';
    v_cust_cnt NUMBER;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-22
    -- Description   :   HOMEPAGE API용 고객 APP DEVICE정보 등록 및 수정
    -- ==========================================================================================
     
    -- 변수로 들어온 고객번호가 유효한번호인지 체크
    SELECT
      COUNT(*) INTO v_cust_cnt
    FROM C_CUST
    WHERE CUST_ID = P_CUST_ID;
    
    IF v_cust_cnt > 0 THEN
      MERGE INTO C_CUST_DEVICE A
      USING DUAL
      ON (A.CUST_ID = P_CUST_ID)
      WHEN MATCHED THEN
        UPDATE SET
          DEVICE_DIV = N_DEVICE_DIV
          ,DEVICE_NM = N_DEVICE_NM
          ,AUTH_ID = N_AUTH_ID
          ,AUTH_TOKEN = N_AUTH_TOKEN
          ,DOWN_COUPON_YN = N_DOWN_COUPON_YN
          ,USE_YN = N_USE_YN
          ,UPD_DT = SYSDATE
      WHEN NOT MATCHED THEN
        INSERT (
          CUST_ID
          ,DEVICE_DIV
          ,DEVICE_NM
          ,AUTH_ID
          ,AUTH_TOKEN
          ,DOWN_COUPON_YN
          ,USE_YN
          ,INST_DT
        ) VALUES (
          P_CUST_ID
          ,N_DEVICE_DIV
          ,N_DEVICE_NM
          ,N_AUTH_ID
          ,N_AUTH_TOKEN
          ,N_DOWN_COUPON_YN
          ,N_USE_YN
          ,SYSDATE
        );
    ELSE
      -- 요청 대상자를 찾을 수 없습니다.
      v_result_cd := '170';
    END IF;
    
    O_RTN_CD := v_result_cd;
END API_C_CUST_DEVICE_SAVE;

/
