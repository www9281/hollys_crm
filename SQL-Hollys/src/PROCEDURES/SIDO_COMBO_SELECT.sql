--------------------------------------------------------
--  DDL for Procedure SIDO_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SIDO_COMBO_SELECT" (
    N_CODE_TP     IN   VARCHAR2,
    P_LANGUAGE    IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    P_MY_USER_ID  IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 국가목록 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT  
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
       WHERE (N_REQ_TEXT IS NULL AND 1=0
              OR
              N_REQ_TEXT IS NOT NULL)
       UNION ALL
       SELECT
          CODE_CD
          , CODE_NM
       FROM (
           SELECT
            REGION_CD AS CODE_CD
            , REGION_NM AS CODE_NM
           FROM REGION
           WHERE CITY_CD = '000');
END SIDO_COMBO_SELECT;

/
