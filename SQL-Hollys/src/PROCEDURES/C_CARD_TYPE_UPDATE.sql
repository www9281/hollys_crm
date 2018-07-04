--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_UPDATE" (
    P_COMP_CD       IN  VARCHAR2,
    N_CARD_TYPE     IN  VARCHAR2,
    N_CARD_TYPE_SEQ IN  VARCHAR2,
    P_CATEGORY_DIV  IN  VARCHAR2,
    P_CATEGORY_CD   IN  VARCHAR2,
    N_TSMS_BRAND_CD IN  VARCHAR2,
    P_USE_YN        IN  VARCHAR2,
    N_MMS_FILE_NM   IN  VARCHAR2,
    P_MY_USER_ID 	  IN  VARCHAR2 
)IS
BEGIN
    ----------------------- 카드타입 정보 저장 -------------------------
    MERGE INTO C_CARD_TYPE
    USING DUAL
       ON (
                COMP_CD         = P_COMP_CD
            AND CARD_TYPE_SEQ   = N_CARD_TYPE_SEQ
          )
    WHEN MATCHED  THEN
        UPDATE
           SET  
             CATEGORY_DIV    = P_CATEGORY_DIV
             ,  CARD_TYPE       = N_CARD_TYPE
             ,  CATEGORY_CD     = P_CATEGORY_CD
             ,  TSMS_BRAND_CD   = N_TSMS_BRAND_CD
             ,  USE_YN          = DECODE(P_USE_YN, 'Y', 'Y', '1', 'Y', 'N')
             ,  UPD_DT          = SYSDATE
             ,  UPD_USER        = P_MY_USER_ID
             ,  MMS_FILE_NM     = N_MMS_FILE_NM
    WHEN NOT MATCHED THEN
        INSERT 
        (
                COMP_CD
             ,  CARD_TYPE_SEQ
             ,  CATEGORY_DIV
             ,  CATEGORY_CD
             ,  CARD_TYPE
             ,  TSMS_BRAND_CD
             ,  USE_YN
             ,  INST_DT 
             ,  INST_USER 
             ,  UPD_DT 
             ,  UPD_USER
             ,  MMS_FILE_NM
        ) VALUES (
                P_COMP_CD
             ,  NVL(N_CARD_TYPE_SEQ, SQ_CARD_TYPE_SEQ.NEXTVAL)
             ,  P_CATEGORY_DIV
             ,  P_CATEGORY_CD
             ,  (SELECT LPAD(NVL(MAX(CARD_TYPE), 0) + 1, 3, '0') FROM C_CARD_TYPE WHERE COMP_CD = '016' AND CATEGORY_DIV = P_CATEGORY_DIV AND CATEGORY_CD = P_CATEGORY_CD)
             ,  N_TSMS_BRAND_CD
             ,  DECODE(P_USE_YN, 'Y', 'Y', '1', 'Y', 'N')
             ,  SYSDATE
             ,  P_MY_USER_ID
             ,  SYSDATE
             ,  P_MY_USER_ID
             ,  N_MMS_FILE_NM
      );
    
END C_CARD_TYPE_UPDATE;

/
