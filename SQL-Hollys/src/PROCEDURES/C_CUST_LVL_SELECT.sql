--------------------------------------------------------
--  DDL for Procedure C_CUST_LVL_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_LVL_SELECT" (
    N_REQ_TEXT   IN   VARCHAR2,
    O_CURSOR     OUT  SYS_REFCURSOR
) AS
BEGIN
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-29
      -- Description   :   회원 등급리스트 조회
      -- ==========================================================================================
       OPEN O_CURSOR FOR
       SELECT  
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM
          , 0 AS LVL_RANK
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
       WHERE N_REQ_TEXT IS NOT NULL
       UNION ALL
       SELECT  
          LVL_CD  AS CODE_CD
          , LVL_NM  AS CODE_NM
          , LVL_RANK
       FROM C_CUST_LVL
       WHERE COMP_CD = '016'
         AND USE_YN = 'Y'
       ORDER BY LVL_RANK;
       
END C_CUST_LVL_SELECT;

/
