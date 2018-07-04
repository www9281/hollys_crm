--------------------------------------------------------
--  DDL for Procedure C_CARD_SCHEDURE_LOS_PT_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SCHEDURE_LOS_PT_SELECT" (
        P_SEARCH_DATE      IN   VARCHAR2,
        O_CURSOR           OUT  SYS_REFCURSOR
) AS 
BEGIN 
        OPEN     O_CURSOR  FOR
        SELECT   CRD.COMP_CD
               , DECRYPT(CRD.CARD_ID)    AS CARD_ID
               , CST.CUST_ID
               , DECRYPT(CST.CUST_NM)    AS CUST_NM
               , FN_GET_FORMAT_HP_NO(REPLACE(DECRYPT(CST.MOBILE), '-', '')) AS MOBILE
               , CRD.SAV_PT
               , CRD.USE_PT
               , CRD.LOS_PT
               , CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT    AS VAL_PT
               , NVL(CASE WHEN NVL(CSH.T_SAV_PT, 0) > NVL(CSH.T_USE_PT, 0) THEN  NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) END, 0) AS TERM_PLAN_PT
               , CRD.SAV_PT - CRD.USE_PT - CRD.LOS_PT - 
                 NVL(CASE WHEN NVL(CSH.T_SAV_PT, 0) > NVL(CSH.T_USE_PT, 0) THEN  NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) END, 0) AS REM_VAL_PT 
        FROM     C_CARD  CRD
               , C_CUST  CST
               ,(
                 SELECT  COMP_CD
                       , CARD_ID
                       --, SUM(CASE WHEN LOS_MLG_DT <= ${SCH_GFR_DATE} THEN C_SAV_PT ELSE 0 END) AS T_SAV_PT
                       , SUM(CASE WHEN LOS_MLG_DT <= P_SEARCH_DATE THEN C_SAV_PT ELSE 0 END) AS T_SAV_PT
                       , SUM(C_USE_PT)                                                         AS T_USE_PT
                 FROM   (
                         SELECT  COMP_CD
                               , CARD_ID
                               , LOS_MLG_DT
                               , CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN ABS(CSH.USE_PT)
                                      ELSE 0
                                 END                                                 AS C_SAV_PT         -- 실제 적립포인트
                               , CASE WHEN CSH.SAV_USE_DIV IN ('102', '202')                  THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT)
                                      WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) > 0 THEN ABS(CSH.USE_PT)
                                      ELSE 0
                                 END                                                 AS C_USE_PT         -- 실제 사용포인트
                         FROM    C_CARD_SAV_HIS CSH
                         --WHERE   COMP_CD     = ${SCH_COMP_CD}
                         WHERE   COMP_CD     = '016'
                         AND     LOS_MLG_YN  = 'N'
                       ) CSH
                 GROUP BY
                         COMP_CD
                       , CARD_ID
                 ) CSH
        WHERE    CRD.COMP_CD       = CST.COMP_CD(+)
        AND      CRD.CUST_ID       = CST.CUST_ID(+)
        AND      CRD.COMP_CD       = CSH.COMP_CD
        AND      CRD.CARD_ID       = CSH.CARD_ID
        --AND      CRD.COMP_CD       = ${SCH_COMP_CD}
        AND      CRD.COMP_CD       = '016'
        AND      CRD.USE_YN        = 'Y'
        AND      NVL(CSH.T_SAV_PT, 0) - NVL(CSH.T_USE_PT, 0) > 0
        ORDER BY 
                 CRD.CARD_ID;
END C_CARD_SCHEDURE_LOS_PT_SELECT;

/
