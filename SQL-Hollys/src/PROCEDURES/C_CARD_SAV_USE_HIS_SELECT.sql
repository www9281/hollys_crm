--------------------------------------------------------
--  DDL for Procedure C_CARD_SAV_USE_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SAV_USE_HIS_SELECT" (
        --N_BRAND_CD      IN   VARCHAR2,
        P_START_DATE    IN   VARCHAR2,
        P_END_DATE      IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN     O_CURSOR  FOR
        SELECT   SUBSTR(USE_DT ,1 ,6)    AS USE_YM
               , SUM(SAV_MLG)            AS SAV_MLG
               --, SUM(CASE WHEN MEMB_DIV = '0' THEN SAV_MLG ELSE 0 END) AS SAV_MLG_P
               --, SUM(CASE WHEN MEMB_DIV = '1' THEN SAV_MLG ELSE 0 END) AS SAV_MLG_M
               , SUM(USE_MLG)            AS USE_MLG
               --, SUM(CASE WHEN MEMB_DIV = '0' THEN USE_MLG ELSE 0 END) AS USE_MLG_P
               --, SUM(CASE WHEN MEMB_DIV = '1' THEN USE_MLG ELSE 0 END) AS USE_MLG_M
               , SUM(LOS_MLG_UNUSE)      AS LOS_MLG
               --, SUM(CASE WHEN MEMB_DIV = '0' THEN LOS_MLG_UNUSE ELSE 0 END) AS LOS_MLG_P
               --, SUM(CASE WHEN MEMB_DIV = '1' THEN LOS_MLG_UNUSE ELSE 0 END) AS LOS_MLG_M
               , SUM(SAV_MLG - USE_MLG - LOS_MLG_UNUSE)  AS REM_MLG
               --, SUM(CASE WHEN MEMB_DIV = '0' THEN SAV_MLG - USE_MLG - LOS_MLG_UNUSE ELSE 0 END) AS REM_MLG_P
               --, SUM(CASE WHEN MEMB_DIV = '1' THEN SAV_MLG - USE_MLG - LOS_MLG_UNUSE ELSE 0 END) AS REM_MLG_M
        FROM     C_CARD_SAV_USE_HIS
        WHERE    COMP_CD  = '016'
        --AND      BRAND_CD = N_BRAND_CD
        AND      USE_DT  >= P_START_DATE||'01'
        AND      USE_DT  <= P_END_DATE||'31'
        AND      USE_YN   = 'Y'
        GROUP BY 
                SUBSTR(USE_DT, 1 ,6)
        ORDER BY 
                1 DESC;
END C_CARD_SAV_USE_HIS_SELECT;

/
