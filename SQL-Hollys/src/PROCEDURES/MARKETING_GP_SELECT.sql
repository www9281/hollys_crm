--------------------------------------------------------
--  DDL for Procedure MARKETING_GP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."MARKETING_GP_SELECT" 
(
  N_BRAND_CD    IN VARCHAR2 
, N_START_DT    IN VARCHAR2 
, N_END_DT      IN VARCHAR2 
, N_CUST_GP_NM  IN VARCHAR2 
, O_CURSOR      OUT SYS_REFCURSOR
) AS 
BEGIN
    OPEN    O_CURSOR FOR
    SELECT  CUST_GP_ID,
            CUST_GP_NM,
            CUST_GP_ID AS CODE_CD,
            CUST_GP_NM AS CODE_NM,
            SMS_SEND_YN,
            NOTES,
            INST_USER,
            TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT,
            (
                SELECT  BRAND_NM
                FROM    BRAND
                WHERE   BRAND_CD = MARKETING_GP.BRAND_CD
            ) AS BRAND_NM,
            (
                SELECT  COUNT(*)
                FROM    MARKETING_GP_CUST
                WHERE   CUST_GP_ID = MARKETING_GP.CUST_GP_ID
            ) AS CUST_QTY,
            CASE  WHEN  EXISTS  (
                                        SELECT  1
                                        FROM    MARKETING_GP_SEARCH
                                        WHERE   CUST_GP_ID = MARKETING_GP.CUST_GP_ID
                                )
                  THEN  1
                  ELSE  0
            END IS_SEARCH
    FROM    MARKETING_GP
    WHERE   (TRIM(N_BRAND_CD) IS NULL OR BRAND_CD = N_BRAND_CD)  
    AND     (TRIM(N_CUST_GP_NM) IS NULL OR CUST_GP_NM LIKE '%' || N_CUST_GP_NM || '%')
    AND     (N_START_DT IS NULL OR N_START_DT = '' OR TO_CHAR(INST_DT, 'YYYYMMDD') >= N_START_DT)
    AND     (N_END_DT IS NULL OR N_END_DT = '' OR TO_CHAR(INST_DT, 'YYYYMMDD') <= N_END_DT)
    ORDER   BY
            CUST_GP_ID DESC;
END MARKETING_GP_SELECT;

/
