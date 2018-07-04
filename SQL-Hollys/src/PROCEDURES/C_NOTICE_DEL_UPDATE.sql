--------------------------------------------------------
--  DDL for Procedure C_NOTICE_DEL_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_DEL_UPDATE" (
    P_NOTICE_SEQ  IN  VARCHAR2,
    P_MY_USER_ID 	IN  VARCHAR2,
    P_USE_YN      IN  VARCHAR2
)IS
BEGIN
    ----------------------- 공지사항 삭제(사용유무만 N으로) -----------------------
    UPDATE C_NOTICE SET
        USE_YN       = P_USE_YN
        ,UPD_DT       = SYSDATE
        ,UPD_USER     = P_MY_USER_ID
      WHERE NOTICE_SEQ = P_NOTICE_SEQ;
     
END C_NOTICE_DEL_UPDATE;

/
