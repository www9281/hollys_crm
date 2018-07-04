--------------------------------------------------------
--  DDL for Procedure COUPON_MEMBER_HIST_ACCDB_S
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_MEMBER_HIST_ACCDB_S" AS 
BEGIN
  SELECT  *
  FROM    COUPON_MEMBER_HIST_ACCDB
  WHERE   SUBSTR(종료일자, 1, 10) >= '2018-03-08'
  AND     사용유무 = '사용안함'
END COUPON_MEMBER_HIST_ACCDB_S;

/
