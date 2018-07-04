--------------------------------------------------------
--  DDL for Procedure C_CARD_CTG_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CTG_UPDATE" (
    P_COMP_CD       IN  VARCHAR2,
    P_CATEGORY_DIV  IN  VARCHAR2,
    P_CATEGORY_CD   IN  VARCHAR2,
    P_CATEGORY_NM   IN  VARCHAR2,
    P_SORT_ORDER    IN  NUMBER,
    P_USE_YN        IN  VARCHAR2,
    P_MY_USER_ID 	  IN  VARCHAR2
)IS
BEGIN
    ----------------------- 카드 카테고리 입력 -----------------------
    UPDATE  C_CARD_CTG SET
         CATEGORY_NM  = P_CATEGORY_NM
         ,  SORT_ORDER   = P_SORT_ORDER
         ,  USE_YN       = P_USE_YN
         ,  UPD_DT       = SYSDATE
         ,  UPD_USER     = P_MY_USER_ID
    WHERE   COMP_CD      = P_COMP_CD
    AND     CATEGORY_DIV = P_CATEGORY_DIV
    AND     CATEGORY_CD  = P_CATEGORY_CD
    ; 
        
END C_CARD_CTG_UPDATE;

/
