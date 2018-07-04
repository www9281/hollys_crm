--------------------------------------------------------
--  DDL for Procedure HQ_USER_BRAND_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_BRAND_SELECT" (
    P_USER_ID IN  HQ_USER.USER_ID%TYPE,
    O_CURSOR  OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN O_CURSOR FOR
    SELECT
      P_USER_ID AS USER_ID
      , A.BRAND_NM
      , A.BRAND_CD
      , DECODE(B.BRAND_CD, NULL, 'N', B.USE_YN) AS USE_YN
    FROM BRAND A, HQ_USER_BRAND B
    WHERE B.USER_ID (+) = P_USER_ID
      AND A.BRAND_CD = B.BRAND_CD (+)
      AND A.USE_YN = 'Y'
    ORDER BY A.BRAND_CD
    ;
END HQ_USER_BRAND_SELECT;

/
