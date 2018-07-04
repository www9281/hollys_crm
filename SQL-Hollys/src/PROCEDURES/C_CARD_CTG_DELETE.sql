--------------------------------------------------------
--  DDL for Procedure C_CARD_CTG_DELETE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CTG_DELETE" (
    P_COMP_CD       IN  VARCHAR2,
    P_CATEGORY_DIV  IN  VARCHAR2,
    P_CATEGORY_CD   IN  VARCHAR2
)IS
BEGIN
    ----------------------- 카드 카테고리 삭제 -----------------------
    
    IF P_CATEGORY_DIV = '000' THEN
      -- 상위 카테고리 삭제의 경우 하위 카테고리분류도 삭제
      DELETE FROM C_CARD_CTG
      WHERE   COMP_CD      = P_COMP_CD
      AND     CATEGORY_DIV = P_CATEGORY_CD
      ;
    END IF;
    
    DELETE FROM C_CARD_CTG
    WHERE   COMP_CD      = P_COMP_CD
    AND     CATEGORY_DIV = P_CATEGORY_DIV
    AND     CATEGORY_CD  = P_CATEGORY_CD
    ;
        
END C_CARD_CTG_DELETE;

/
