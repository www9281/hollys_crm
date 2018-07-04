--------------------------------------------------------
--  DDL for Procedure ITEM_DIV_M_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."ITEM_DIV_M_COMBO_SELECT" (
    N_LANGUAGE    IN   VARCHAR2,
    N_CLASS_L     IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR 
) AS
BEGIN
       ----------------------- 상품 대분류 콤보 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT  
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM 
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
       UNION ALL
       SELECT * FROM (
         SELECT   
            IMC.M_CLASS_CD AS    CODE_CD
            , CASE WHEN LT1.LANG_NM IS NULL THEN IMC.M_CLASS_NM
                   ELSE LT1.LANG_NM
              END AS CODE_NM
         FROM ITEM_M_CLASS IMC 
            , (
                  SELECT   PK_COL
                     ,     LANG_NM
                  FROM LANG_TABLE
                  WHERE TABLE_NM    = 'ITEM_M_CLASS'
                    AND COL_NM      = 'M_CLASS_NM'
                    AND LANGUAGE_TP = DECODE(N_LANGUAGE, NULL, ' ', N_LANGUAGE )
                    AND USE_YN      = 'Y'
              ) LT1
          WHERE IMC.M_CLASS_CD = LT1.PK_COL(+)
            --AND (N_CODE_TP IS NULL OR IMC.ORG_CLASS_CD = N_CODE_TP)
            AND IMC.L_CLASS_CD = N_CLASS_L
            AND IMC.USE_YN ='Y'
          ORDER BY IMC.SORT_ORDER
       );
       
END ITEM_DIV_M_COMBO_SELECT;

/
