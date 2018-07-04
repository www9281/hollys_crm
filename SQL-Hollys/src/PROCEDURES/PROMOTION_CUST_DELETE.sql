--------------------------------------------------------
--  DDL for Procedure PROMOTION_CUST_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CUST_DELETE" (
    P_PRMT_ID     IN  VARCHAR2,
    P_CUST_ID     IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-18
    -- Description   :   프로모션 고객관리 삭제
    -- ==========================================================================================
    UPDATE PROMOTION_CUST SET
      USE_YN = 'N'
    WHERE PRMT_ID = P_PRMT_ID
      AND CUST_ID = P_CUST_ID; 
END PROMOTION_CUST_DELETE;

/
