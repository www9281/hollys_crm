--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_REP_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_REP_INSERT" (
    P_COMP_CD         IN   VARCHAR2,
    P_CARD_TYPE       IN   VARCHAR2,
    P_ISSUE_DT        IN   VARCHAR2,
    P_USE_YN          IN   VARCHAR2,
    P_START_CARD_CD   IN   VARCHAR2,
    P_CLOSE_CARD_CD   IN   VARCHAR2,
    P_MY_USER_ID      IN   VARCHAR2
) IS
BEGIN
      ----------------------- 카드타입 상세 카드정보 저장 -----------------------
      
    MERGE INTO C_CARD_TYPE_REP
    USING DUAL
       ON ( 
                COMP_CD         = P_COMP_CD
            AND CARD_TYPE       = P_CARD_TYPE
            AND START_CARD_CD   = ENCRYPT(P_START_CARD_CD)
            AND CLOSE_CARD_CD   = ENCRYPT(P_CLOSE_CARD_CD)
          )
    WHEN MATCHED  THEN
        UPDATE
           SET  ISSUE_DT        = P_ISSUE_DT
             ,  USE_YN          = DECODE(P_USE_YN, 'Y', 'Y', '1', 'Y', 'N')
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = P_MY_USER_ID
    WHEN NOT MATCHED THEN
        INSERT 
        (
                COMP_CD
             ,  CARD_TYPE
             ,  START_CARD_CD
             ,  CLOSE_CARD_CD
             ,  ISSUE_DT
             ,  USE_YN
             ,  INST_DT 
             ,  INST_USER 
             ,  UPD_DT 
             ,  UPD_USER
        ) VALUES (
                P_COMP_CD
             ,  P_CARD_TYPE
             ,  ENCRYPT(P_START_CARD_CD)
             ,  ENCRYPT(P_CLOSE_CARD_CD)
             ,  P_ISSUE_DT
             ,  DECODE(P_USE_YN, 'Y', 'Y', '1', 'Y', 'N')
             ,  SYSDATE
             ,  P_MY_USER_ID
             ,  SYSDATE
             ,  P_MY_USER_ID
        );
        
END C_CARD_TYPE_REP_INSERT;

/
