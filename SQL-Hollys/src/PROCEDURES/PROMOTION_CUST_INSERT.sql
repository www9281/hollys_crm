--------------------------------------------------------
--  DDL for Procedure PROMOTION_CUST_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CUST_INSERT" (
    P_PRMT_ID     IN  VARCHAR2,
    P_CUST_ID     IN  VARCHAR2,
    P_MY_USER_ID	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-18
    -- Description   :   프로모션 고객관리 저장
    -- ==========================================================================================
    INSERT INTO PROMOTION_CUST (
      PRMT_ID
      ,CUST_ID
      ,USE_YN
    ) VALUES (
      P_PRMT_ID
      ,P_CUST_ID
      ,'Y'
    );    
      
END PROMOTION_CUST_INSERT;

/
