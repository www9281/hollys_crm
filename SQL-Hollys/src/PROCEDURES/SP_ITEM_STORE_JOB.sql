--------------------------------------------------------
--  DDL for Procedure SP_ITEM_STORE_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ITEM_STORE_JOB" 
(
  PSV_COMP_CD    IN   STRING, -- Company Code
  PSV_YMD        IN   STRING  -- 일자
) IS
-------------------------------------------------------------------------------
--  Procedure Name   : SP_ITEM_STORE_JOB
--  Description      : 매장 판매가 수정일자 변경 ( 매일 AM:5시 실행)
--  Ref. Table       : ITEM_STORE
-------------------------------------------------------------------------------
--  Create Date      : 2013-04-15
--  Modify Date      : 2013-04-15
-------------------------------------------------------------------------------
  ERR_HANDLER      EXCEPTION;
  ls_stmt          VARCHAR2(1000);
BEGIN

  UPDATE ITEM_STORE
     SET UPD_DT        = SYSDATE
   WHERE COMP_CD       = PSV_COMP_CD
     AND SALE_START_DT = PSV_YMD
     AND USE_YN        = 'Y';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
END;

/
