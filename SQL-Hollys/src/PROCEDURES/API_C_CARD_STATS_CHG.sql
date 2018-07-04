--------------------------------------------------------
--  DDL for Procedure API_C_CARD_STATS_CHG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CARD_STATS_CHG" (
    P_CUST_ID    IN  VARCHAR2,
    N_STATS_DIV   IN  VARCHAR2,
    O_CARD_STATS  OUT VARCHAR2
)AS
    L_COUNT_CARD    NUMBER;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 삭제
    -- ==========================================================================================
    
    IF N_STATS_DIV = '10' THEN
      UPDATE C_CARD SET
        CARD_STAT = N_STATS_DIV
        ,LOST_DT = ''
      WHERE CUST_ID = P_CUST_ID
        AND REP_CARD_YN = 'Y'
        AND USE_YN = 'Y';
    ELSIF N_STATS_DIV = '80' THEN
      UPDATE C_CARD SET
        CARD_STAT = N_STATS_DIV
        ,LOST_DT = TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
      WHERE CUST_ID = P_CUST_ID
        AND REP_CARD_YN = 'Y'
        AND USE_YN = 'Y';
    END IF;
    
    SELECT  COUNT(*)
    INTO    L_COUNT_CARD
    FROM    C_CARD A
    WHERE A.CUST_ID = P_CUST_ID
      AND A.REP_CARD_YN = 'Y'
      AND A.USE_YN = 'Y';
    
    IF    L_COUNT_CARD > 0  THEN
          SELECT
            A.CARD_STAT INTO O_CARD_STATS
          FROM C_CARD A
          WHERE A.CUST_ID = P_CUST_ID
            AND A.REP_CARD_YN = 'Y'
            AND A.USE_YN = 'Y';
    END IF;
      
END API_C_CARD_STATS_CHG;

/
