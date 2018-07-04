--------------------------------------------------------
--  DDL for Procedure C_NOTICE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_DELETE" (
    P_NOTICE_SEQ  IN  VARCHAR2,
    P_MY_USER_ID 	IN  VARCHAR2
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-16
    -- Description   :   멤버쉽 공지사항관리 공지사항 삭제
    -- Test          :   
    -- ==========================================================================================
    DELETE FROM C_NOTICE
    WHERE NOTICE_SEQ = P_NOTICE_SEQ;
     
END C_NOTICE_DELETE;

/
