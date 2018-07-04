--------------------------------------------------------
--  DDL for Procedure STORE_SV_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_SV_USER_SELECT" (
    N_CODE_TP     IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR   OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 선택 점포의 팀내 SC담당자 목록 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT  
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM, 0 AS SORT_SEQ FROM DUAL) A
       UNION ALL
       SELECT
          DISTINCT B.USER_ID     AS CODE_CD
          , B.USER_NM   AS CODE_NM
       FROM STORE A, HQ_USER B
       WHERE A.TEAM_CD = N_CODE_TP;
         
END STORE_SV_USER_SELECT;

/
