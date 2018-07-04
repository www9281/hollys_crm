--------------------------------------------------------
--  DDL for Procedure C_CUST_STATS_LEVEL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_STATS_LEVEL_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    P_INFO_DIV1    IN  VARCHAR2,
    P_STD_YMD      IN  VARCHAR2,
    
    O_CURSOR       OUT SYS_REFCURSOR
) IS


BEGIN
    
OPEN O_CURSOR FOR 

    -- 'PK.정보구분2(1:회원상태-정상,2:회원상태-휴면,3:회원상태-신규,4:회원상태-탈퇴)';
        SELECT
               CASE
                    WHEN INFO_DIV2 = '1' THEN '정상'
                    WHEN INFO_DIV2 = '2' THEN '휴면'
                    WHEN INFO_DIV2 = '3' THEN '신규'
                    WHEN INFO_DIV2 = '4' THEN '탈퇴'
                    ELSE 
                        ''
               END  AS INFO_DIV2_NM
             , (SELECT LVL_NM FROM C_CUST_LVL WHERE LVL_CD = A.LVL_CD) AS LVL_NM
             , TOTL     
             , AAPP    
             , UAPP    
             , TOKN_ALL
             , TOKN_NOR
             , TOKN_BAD
             , COUP_END
             , COUP_MAK
             , PRMT_EVT
        FROM(
            SELECT
                   INFO_DIV2
                 , LVL_CD
                 , SUM(TOTL    ) AS  TOTL     
                 , SUM(AAPP    ) AS  AAPP    
                 , SUM(UAPP    ) AS  UAPP    
                 , SUM(TOKN_ALL) AS  TOKN_ALL
                 , SUM(TOKN_NOR) AS  TOKN_NOR
                 , SUM(TOKN_BAD) AS  TOKN_BAD
                 , SUM(COUP_END) AS  COUP_END
                 , SUM(COUP_MAK) AS  COUP_MAK
                 , SUM(PRMT_EVT) AS  PRMT_EVT
             FROM  STAT_APP_INST
             WHERE COMP_CD   = P_COMP_CD
             AND   (N_BRAND_CD    IS NULL OR BRAND_CD = N_BRAND_CD  )
             AND   INFO_DIV1 = P_INFO_DIV1
             AND   STD_YMD   = P_STD_YMD
             GROUP BY INFO_DIV2 , LVL_CD
         ) A
         ORDER BY INFO_DIV2 , LVL_CD DESC 
        ;

END C_CUST_STATS_LEVEL_SELECT;

/
