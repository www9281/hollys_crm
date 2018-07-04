--------------------------------------------------------
--  DDL for Procedure STORE_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_CODE_SELECT" (
        P_BRAND_CD   IN  VARCHAR2,
        P_SIDO_CD    IN  VARCHAR2,
        P_GUGUN_CD   IN  VARCHAR2,
        O_CURSOR     OUT  SYS_REFCURSOR
) AS 
BEGIN
        OPEN     O_CURSOR  FOR
        SELECT   STOR_CD   AS CODE_CD,
                 STOR_NM   AS CODE_NM
        FROM     STORE
        WHERE    BRAND_CD = P_BRAND_CD
        AND      (TRIM(P_SIDO_CD) IS NULL OR SIDO_CD = P_SIDO_CD)
        AND      (TRIM(P_GUGUN_CD) IS NULL OR REGION_CD = P_GUGUN_CD)
        ORDER BY STOR_NM ASC;
END STORE_CODE_SELECT;

/
