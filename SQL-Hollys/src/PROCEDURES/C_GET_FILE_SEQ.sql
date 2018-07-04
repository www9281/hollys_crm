--------------------------------------------------------
--  DDL for Procedure C_GET_FILE_SEQ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_GET_FILE_SEQ" (
    O_CARD_TYPE_SEQ   OUT   VARCHAR2
)IS
BEGIN
    ----------------------- 카드타입 파일 시퀀스 취득 -------------------------
    SELECT 
        SQ_CARD_TYPE_SEQ.nextval
        INTO O_CARD_TYPE_SEQ
      FROM DUAL;
END C_GET_FILE_SEQ;

/
