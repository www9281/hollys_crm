--------------------------------------------------------
--  DDL for Procedure API_C_CUST_TEST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_TEST" (
      P_TEST_STR       IN  VARCHAR2, 
      O_CURSOR       OUT SYS_REFCURSOR
) IS
    v_tel_str   VARCHAR2(20000);
    v_query     VARCHAR2(30000);
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-15
    -- API REQUEST   :   HLS_CRM_IF_0011
    -- Description   :   카드번호 중복 체크		
    -- ==========================================================================================
    
    dbms_output.put_line( '''' || replace(P_TEST_STR, ',', ''',''') || '''');
    v_tel_str := replace(P_TEST_STR, ',', ''',''');
    
    v_query := 'SELECT
                  *
                FROM C_CUST A
                WHERE DECRYPT(MOBILE) IN (''' || v_tel_str || ''')';
    dbms_output.put_line(v_query);
    OPEN O_CURSOR FOR v_query;
--    OPEN O_CURSOR FOR
--    SELECT
--      *
--    FROM C_CUST A
--    WHERE CUST_WEB_ID IN (
--          SELECT     
--            SUBSTR(STR, INSTR (STR, ',', 1, LEVEL) + 1,
--                       INSTR (STR, ',', 1, LEVEL + 1) - INSTR (STR, ',', 1, LEVEL)- 1
--                   )
--          FROM (SELECT ',' || TEST_STR || ',' STR FROM DUAL)
--          CONNECT BY LEVEL <= LENGTH (STR) - LENGTH (REPLACE (STR, ',')) - 1);
          
END API_C_CUST_TEST;

/
