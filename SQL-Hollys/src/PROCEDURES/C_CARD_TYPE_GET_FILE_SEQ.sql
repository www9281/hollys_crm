--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_GET_FILE_SEQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_GET_FILE_SEQ" (
    O_FILE_ID   OUT   VARCHAR2
)IS
BEGIN
    ----------------------- 카드타입 파일 시퀀스 취득 -------------------------
    SELECT 
        SQ_CONTENT_FILE_ID.nextval
        INTO O_FILE_ID
      FROM DUAL;
END C_CARD_TYPE_GET_FILE_SEQ;

/
