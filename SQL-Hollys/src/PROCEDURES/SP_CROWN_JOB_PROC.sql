--------------------------------------------------------
--  DDL for Procedure SP_CROWN_JOB_PROC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_JOB_PROC" IS
    nRTNCODE    NUMBER;
    vRTNMSG     VARCHAR2(2000) := NULL;
BEGIN
    -- 탈퇴고객 고객 포인트 소멸
    SP_CROWN_CUST_LEAVE_PTIME('010', '');

    -- 고객 포인트 소멸
    SP_CROWN_POINT_CHG_PTIME('010', 'kor', '', nRTNCODE, vRTNMSG);

    -- 고객등급 산정 매일
    IF TO_CHAR(SYSDATE, 'DD') = '01' THEN 
        SP_CROWN_GRADE_CHG_PTIME('010', 'kor', '', nRTNCODE, vRTNMSG);
    END IF;
END SP_CROWN_JOB_PROC;

/
