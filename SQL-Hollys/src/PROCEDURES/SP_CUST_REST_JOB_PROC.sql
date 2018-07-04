--------------------------------------------------------
--  DDL for Procedure SP_CUST_REST_JOB_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST_REST_JOB_PROC" IS
    nRTNCODE    NUMBER;
    vRTNMSG     VARCHAR2(2000) := NULL;
BEGIN
    -- 휴면고객/탈퇴고객 예정 정보 추출(문자전송 포함)
    SP_CUST_REST_PLAN('000', 'KOR', '', nRTNCODE, vRTNMSG);

    -- 휴면고객/탈퇴고객 정보 분리
    SP_CUST_REST_PROC('000', 'KOR', '', nRTNCODE, vRTNMSG);
END SP_CUST_REST_JOB_PROC;

/
