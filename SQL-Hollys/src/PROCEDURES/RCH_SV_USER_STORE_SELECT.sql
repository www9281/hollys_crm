--------------------------------------------------------
--  DDL for Procedure RCH_SV_USER_STORE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_SV_USER_STORE_SELECT" (
    N_USER_ID     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-02
    -- Description   :   설문조사 QR관리 SC별 매장조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT
      STOR_CD
      ,STOR_NM
    FROM STORE
    WHERE (N_USER_ID IS NULL OR SV_USER_ID = N_USER_ID)
    ORDER BY STOR_NM
    ;
    
      
END RCH_SV_USER_STORE_SELECT;

/
