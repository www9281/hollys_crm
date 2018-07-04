--------------------------------------------------------
--  DDL for Procedure C_NOTICE_ADD_VIEW_CNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_ADD_VIEW_CNT" (
    N_NOTICE_SEQ  IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-16
    -- Description   :   멤버쉽 공지사항관리 공지사항 조회수 증가
    -- Test          :   
    -- ==========================================================================================
    
    UPDATE C_NOTICE SET
      READ_CNT = READ_CNT + 1
    WHERE NOTICE_SEQ = N_NOTICE_SEQ;
    
    
END C_NOTICE_ADD_VIEW_CNT;

/
