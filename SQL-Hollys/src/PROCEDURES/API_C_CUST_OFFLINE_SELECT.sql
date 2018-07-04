--------------------------------------------------------
--  DDL for Procedure API_C_CUST_OFFLINE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_OFFLINE_SELECT" 
(
  P_MOBILE     IN  VARCHAR2,
  O_CURSOR     OUT SYS_REFCURSOR
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-29
    -- API REQUEST   :   HLS_CRM_IF_0034
    -- Description   :   간편가입 회원 조회
    -- ==========================================================================================
     
    -- 간편가입되어있는 대상자 목록 조회
    OPEN O_CURSOR FOR
    SELECT 
      A.CUST_ID
      ,DECRYPT(A.MOBILE) AS MOBILE
      ,A.INST_DT
      ,DECRYPT(B.CARD_ID) AS CARD_ID
    FROM C_CUST A, C_CARD B
    WHERE A.COMP_CD = '016'
      AND A.MOBILE = ENCRYPT(P_MOBILE)
      AND A.USE_YN = 'Y'
      AND A.LVL_CD = '000'
      AND A.CUST_STAT = '1'
      AND A.CUST_ID = B.CUST_ID
      AND B.REP_CARD_YN = 'Y'
      AND B.USE_YN = 'Y'
    ;
    
END API_C_CUST_OFFLINE_SELECT;

/
