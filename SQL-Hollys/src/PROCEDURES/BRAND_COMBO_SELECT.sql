--------------------------------------------------------
--  DDL for Procedure BRAND_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BRAND_COMBO_SELECT" (
    N_CODE_TP     IN   VARCHAR2,
    P_LANGUAGE    IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    P_MY_USER_ID  IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 영업조직 리스트 조회 -----------------------
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
           SELECT  M.BRAND_CD                                       AS CODE_CD 
             ,  DECODE(L.BRAND_NM, NULL, M.BRAND_NM, L.BRAND_NM) AS CODE_NM 
           FROM BRAND M,                         
                (
                    SELECT PK_COL     AS BRAND_CD, LANG_NM AS BRAND_NM               
                    FROM LANG_TABLE                                         
                    WHERE TABLE_NM    = 'BRAND'                                 
                    AND COL_NM      = 'BRAND_NM'                           
                    AND LANGUAGE_TP = DECODE(P_LANGUAGE, NULL, ' ', P_LANGUAGE)  
                    AND USE_YN = 'Y'                                     
                )     L                                                   
           WHERE M.BRAND_CD = L.BRAND_CD(+)  
           AND M.BRAND_CD <> '001'
           AND M.USE_YN = 'Y'
           AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_MY_USER_ID AND BRAND_CD = M.BRAND_CD AND USE_YN = 'Y')
           ORDER BY CODE_CD ASC);
END BRAND_COMBO_SELECT;

/
