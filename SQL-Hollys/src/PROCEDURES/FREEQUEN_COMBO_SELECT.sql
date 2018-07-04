--------------------------------------------------------
--  DDL for Procedure FREEQUEN_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."FREEQUEN_COMBO_SELECT" (
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 쿠폰 목록 조회 -----------------------
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
          A.CODE_CD || '' AS CODE_CD
          ,A.CODE_NM
       FROM (
         SELECT PRMT_ID AS CODE_CD, PRMT_NM AS CODE_NM
         FROM   PROMOTION
         WHERE  PRMT_TYPE = 'C6017' 
        ) A
        ORDER BY CODE_CD NULLS FIRST
      ;
END FREEQUEN_COMBO_SELECT;

/
