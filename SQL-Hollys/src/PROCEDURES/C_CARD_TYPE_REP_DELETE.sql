--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_REP_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_REP_DELETE" (
    P_COMP_CD         IN   VARCHAR2,
    P_CARD_TYPE       IN   VARCHAR2,
    P_START_CARD_CD   IN   VARCHAR2,
    P_CLOSE_CARD_CD   IN   VARCHAR2,
    P_MY_USER_ID      IN   VARCHAR2
) IS
BEGIN
      ----------------------- 카드타입 상세 카드정보 삭제 -----------------------
      
    UPDATE  C_CARD_TYPE_REP
       SET  USE_YN          = 'N'
         ,  UPD_DT          = SYSDATE
         ,  UPD_USER        = P_MY_USER_ID
    WHERE   COMP_CD         = P_COMP_CD
       AND  CARD_TYPE       = P_CARD_TYPE
       AND  START_CARD_CD   = ENCRYPT(P_START_CARD_CD)
       AND  CLOSE_CARD_CD   = ENCRYPT(P_CLOSE_CARD_CD)
    ;
        
END C_CARD_TYPE_REP_DELETE;

/
