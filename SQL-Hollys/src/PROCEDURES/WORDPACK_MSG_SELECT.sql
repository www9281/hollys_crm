--------------------------------------------------------
--  DDL for Procedure WORDPACK_MSG_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."WORDPACK_MSG_SELECT" (
    P_LANGUAGE_TP   IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
BEGIN
    ----------------------------- 언어별 워드팩(메시지) 조회 -----------------------------
    
    OPEN O_CURSOR FOR 
    SELECT MSG_CD, LANGUAGE_TP, MESSAGE 
    FROM WORDPACK_MSG 
    WHERE USE_YN = 'Y'
    AND     LANGUAGE_TP = P_LANGUAGE_TP;
      
END WORDPACK_MSG_SELECT;

/
