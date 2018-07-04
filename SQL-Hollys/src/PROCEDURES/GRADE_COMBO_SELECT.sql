--------------------------------------------------------
--  DDL for Procedure GRADE_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."GRADE_COMBO_SELECT" (
    P_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 회원등급 콤보 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT  
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM
       FROM (SELECT '' AS CODE_CD, P_REQ_TEXT AS CODE_NM FROM DUAL) A
       UNION ALL
       SELECT *
       FROM (
         SELECT  
            LVL_CD   AS CODE_CD
            ,  LVL_NM   AS CODE_NM
         FROM  C_CUST_LVL 
         WHERE  USE_YN  = 'Y'
         ORDER BY LVL_RANK);
END GRADE_COMBO_SELECT;

/
