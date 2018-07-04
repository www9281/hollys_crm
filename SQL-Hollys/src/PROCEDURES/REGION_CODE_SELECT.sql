--------------------------------------------------------
--  DDL for Procedure REGION_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."REGION_CODE_SELECT" (
        P_CITY_CD    IN    VARCHAR2,
        O_CURSOR   OUT   SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  REGION_CD  AS CODE_CD,
                REGION_NM  AS CODE_NM
        FROM  REGION
        WHERE CITY_CD = P_CITY_CD
        ORDER BY 
                REGION_CD ASC;
END REGION_CODE_SELECT;

/
