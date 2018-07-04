--------------------------------------------------------
--  DDL for Procedure BRAND_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BRAND_CODE_SELECT" (
        P_LANG_TP  IN    VARCHAR2,
        O_CURSOR   OUT   SYS_REFCURSOR
) AS 
BEGIN
        OPEN    O_CURSOR  FOR
        SELECT  M.BRAND_CD                                       AS CODE_CD 
             ,  DECODE(L.BRAND_NM, NULL, M.BRAND_NM, L.BRAND_NM) AS CODE_NM 
        FROM BRAND M,                         
             (
                 SELECT PK_COL     AS BRAND_CD, LANG_NM AS BRAND_NM               
                 FROM LANG_TABLE                                         
                 WHERE TABLE_NM    = 'BRAND'                                 
                 AND COL_NM      = 'BRAND_NM'                           
                 AND LANGUAGE_TP = DECODE(P_LANG_TP, NULL, ' ', P_LANG_TP)  
                 AND USE_YN = 'Y'                                     
             )     L                                                   
        WHERE M.BRAND_CD = L.BRAND_CD(+)       
        AND M.USE_YN   = 'Y'
        ORDER BY 
                CODE_CD ASC;
END BRAND_CODE_SELECT;

/
