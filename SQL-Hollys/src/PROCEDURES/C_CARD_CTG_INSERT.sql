--------------------------------------------------------
--  DDL for Procedure C_CARD_CTG_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CTG_INSERT" (
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
    
    INSERT INTO C_CARD_CTG ( 
        COMP_CD
        ,CATEGORY_DIV
        ,CATEGORY_CD
        ,CATEGORY_NM
        ,SORT_ORDER
        ,USE_YN
        ,INST_DT
        ,INST_USER
    ) VALUES (
        P_COMP_CD
        ,P_CATEGORY_DIV
        ,P_CATEGORY_CD
        ,P_CATEGORY_NM
        ,P_SORT_ORDER
        ,P_USE_YN
        ,SYSDATE
        ,P_MY_USER_ID
    );
    
END C_CARD_CTG_INSERT;

/
