--------------------------------------------------------
--  DDL for Procedure C_CUST_CHG_REST_STATS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CHG_REST_STATS" (
    P_CUST_ID      IN  VARCHAR2
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-03-18
    -- Description   :   멤버쉽 회원관리 [회원 조회] 휴면회원 휴면해제처리
    -- ==========================================================================================
    
    --- 1. 휴면회원테이블의 정보를 회원테이블로 이동
    INSERT INTO C_CUST
    VALUE
    SELECT * FROM C_CUST_REST
    WHERE CUST_ID = P_CUST_ID;
    
    --- 2. 휴면회원테이블에서 제거
    DELETE FROM C_CUST_REST
    WHERE CUST_ID = P_CUST_ID;
    
END C_CUST_CHG_REST_STATS;

/
