--------------------------------------------------------
--  DDL for Procedure WORDPACK_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."WORDPACK_SELECT" (
    P_LANGUAGE_TP   IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
BEGIN
    ----------------------------- 언어별 워드팩 조회 -----------------------------
    
    OPEN O_CURSOR FOR 
    SELECT  KEY_WORD_CD, 
            WORD_NM 
    FROM    WORDPACK 
    WHERE   USE_YN = 'Y'
    AND     LANGUAGE_TP = P_LANGUAGE_TP;
      
END WORDPACK_SELECT;

/
