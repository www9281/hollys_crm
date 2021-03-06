--------------------------------------------------------
--  DDL for Procedure API_C_CUST_DEVICE_SET_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_DEVICE_SET_SELECT" (
    P_CUST_ID       IN  VARCHAR2,
    O_RTN_CD        OUT VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_result_cd VARCHAR2(7) := '1';
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-22
    -- Description   :   HOMEPAGE API용 고객 APP DEVICE 설정 정보 조회
    -- ==========================================================================================
     
    OPEN O_CURSOR FOR
    SELECT
      CUST_ID
      ,DIV_NM
      ,DIV_YN
      ,TO_CHAR(INST_DT, 'YYYYMMDD') AS INST_DT
      ,TO_CHAR(UPD_DT, 'YYYYMMDD') AS UPD_DT
    FROM C_CUST_DEVICE_PUSH A
    WHERE A.CUST_ID = P_CUST_ID
    ;
    
    O_RTN_CD := v_result_cd;
END API_C_CUST_DEVICE_SET_SELECT;

/
