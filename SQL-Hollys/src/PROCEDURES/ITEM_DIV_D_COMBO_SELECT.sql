--------------------------------------------------------
--  DDL for Procedure ITEM_DIV_D_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."ITEM_DIV_D_COMBO_SELECT" (
    N_LANGUAGE    IN   VARCHAR2,
    N_CLASS_L     IN   VARCHAR2,
    N_CLASS_M     IN   VARCHAR2,
    N_CLASS_S     IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 상품 세분류 콤보 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT  
              A.CODE_CD   AS CODE_CD
             ,A.CODE_NM   AS CODE_NM
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
       UNION ALL
       SELECT * 
            FROM (
                     SELECT   
                              IDC.D_CLASS_CD AS    CODE_CD
                            , CASE WHEN LT1.LANG_NM IS NULL THEN IDC.D_CLASS_NM
                                   ELSE   LT1.LANG_NM
                              END AS CODE_NM 
       FROM ITEM_D_CLASS IDC
            , (
              SELECT   PK_COL
                      ,LANG_NM
              FROM     LANG_TABLE
              WHERE    TABLE_NM    = 'ITEM_D_CLASS'
                AND    COL_NM      = 'D_CLASS_NM'
                AND    LANGUAGE_TP = DECODE(N_LANGUAGE, NULL, ' ', N_LANGUAGE )
                AND    USE_YN      = 'Y'
          ) LT1
      WHERE IDC.D_CLASS_CD = LT1.PK_COL(+)
      --AND (P_CODE_TP IS NULL OR IDC.ORG_CLASS_CD = P_CODE_TP)
      AND IDC.L_CLASS_CD = N_CLASS_L
      AND IDC.M_CLASS_CD = N_CLASS_M
      AND IDC.S_CLASS_CD = N_CLASS_S
      AND IDC.USE_YN ='Y'
      ORDER BY IDC.SORT_ORDER
      );

END ITEM_DIV_D_COMBO_SELECT;

/
