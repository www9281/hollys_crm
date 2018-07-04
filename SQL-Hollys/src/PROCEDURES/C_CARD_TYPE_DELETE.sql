--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_DELETE" (
    P_CARD_TYPE_SEQ IN  VARCHAR2,
    P_MY_USER_ID    IN   VARCHAR2
) IS
BEGIN
      ----------------------- 카드타입 정보 삭제 -----------------------
      
    UPDATE  C_CARD_TYPE
       SET  USE_YN          = 'N'
         ,  UPD_DT          = SYSDATE
         ,  UPD_USER        = P_MY_USER_ID
    WHERE   CARD_TYPE_SEQ = P_CARD_TYPE_SEQ
    ;
        
END C_CARD_TYPE_DELETE;

/
