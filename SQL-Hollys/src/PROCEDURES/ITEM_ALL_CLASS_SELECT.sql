--------------------------------------------------------
--  DDL for Procedure ITEM_ALL_CLASS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."ITEM_ALL_CLASS_SELECT" (
    N_LANGUAGE    IN   VARCHAR2,
    N_CLASS_TYPE  IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 상품 분류 콤보 조회 -----------------------
       OPEN O_CURSOR FOR       
       SELECT * FROM (
         SELECT   
            ILC.L_CLASS_CD AS    L_CODE_CD
            , '' AS  M_CODE_CD
            , '' AS  S_CODE_CD
            , '' AS  D_CODE_CD
            , CASE WHEN LT1.LANG_NM IS NULL THEN ILC.L_CLASS_NM
                   ELSE LT1.LANG_NM
              END AS CODE_NM
         FROM ITEM_L_CLASS ILC
            , (
                  SELECT   PK_COL
                     ,     LANG_NM
                  FROM LANG_TABLE
                  WHERE TABLE_NM = 'ITEM_L_CLASS'
                    AND COL_NM   = 'L_CLASS_NM'
                    AND LANGUAGE_TP = DECODE(N_LANGUAGE, NULL, ' ', N_LANGUAGE )
                    AND USE_YN      = 'Y'
               ) LT1
         WHERE ILC.L_CLASS_CD    = LT1.PK_COL(+)
           --AND (N_CODE_TP IS NULL OR ILC.ORG_CLASS_CD  = N_CODE_TP)
           AND ('L' = N_CLASS_TYPE OR N_CLASS_TYPE IS NULL OR N_CLASS_TYPE = '')
           AND ILC.USE_YN        = 'Y'
         ORDER BY ILC.SORT_ORDER
       )
       UNION ALL
       SELECT * FROM (
         SELECT   
            IMC.L_CLASS_CD AS  L_CODE_CD
            ,IMC.M_CLASS_CD AS    M_CODE_CD
            , '' AS  S_CODE_CD
            , '' AS  D_CODE_CD
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
            AND ('M' = N_CLASS_TYPE OR N_CLASS_TYPE IS NULL OR N_CLASS_TYPE = '')
            AND IMC.USE_YN ='Y'
          ORDER BY IMC.SORT_ORDER
       )
       UNION ALL
       SELECT * 
            FROM (
                     SELECT    
                            ISC.L_CLASS_CD AS  L_CODE_CD
                            ,ISC.M_CLASS_CD AS    M_CODE_CD 
                            ,ISC.S_CLASS_CD AS    S_CODE_CD
                            , '' AS  D_CODE_CD
                            , CASE WHEN LT1.LANG_NM IS NULL THEN ISC.S_CLASS_NM
                                   ELSE   LT1.LANG_NM
                                  END AS CODE_NM
           FROM ITEM_S_CLASS ISC
                , (
                  SELECT   PK_COL
                          ,LANG_NM
                  FROM     LANG_TABLE
                  WHERE    TABLE_NM    = 'ITEM_S_CLASS'
                    AND    COL_NM      = 'S_CLASS_NM'
                    AND    LANGUAGE_TP = DECODE(N_LANGUAGE, NULL, ' ', N_LANGUAGE )
                    AND    USE_YN      = 'Y'
              ) LT1
          WHERE ISC.S_CLASS_CD = LT1.PK_COL(+)
          --AND (N_CODE_TP IS NULL OR ISC.ORG_CLASS_CD = N_CODE_TP)
            AND ('S' = N_CLASS_TYPE OR N_CLASS_TYPE IS NULL OR N_CLASS_TYPE = '')
          AND ISC.USE_YN ='Y'
         ORDER BY ISC.SORT_ORDER
      )
      UNION ALL
      SELECT * 
            FROM (
                     SELECT   
                            IDC.L_CLASS_CD AS  L_CODE_CD
                            , IDC.M_CLASS_CD AS    M_CODE_CD 
                            , IDC.S_CLASS_CD AS    S_CODE_CD
                            , IDC.D_CLASS_CD AS    D_CODE_CD
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
      AND ('D' = N_CLASS_TYPE OR N_CLASS_TYPE IS NULL OR N_CLASS_TYPE = '')
      AND IDC.USE_YN ='Y'
      ORDER BY IDC.SORT_ORDER
      );

END ITEM_ALL_CLASS_SELECT;

/
