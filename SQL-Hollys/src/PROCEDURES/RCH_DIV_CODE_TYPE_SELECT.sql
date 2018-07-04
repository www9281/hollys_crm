--------------------------------------------------------
--  DDL for Procedure RCH_DIV_CODE_TYPE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."RCH_DIV_CODE_TYPE_SELECT" (
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR   OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-30
    -- Description   :   설문조사 분류코드 조회
    -- ==========================================================================================
            
    OPEN O_CURSOR FOR
    SELECT  
       A.CODE_CD     AS CODE_CD
       , A.CODE_NM   AS CODE_NM
    FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
    WHERE (N_REQ_TEXT IS NULL AND 1=0
           OR
           N_REQ_TEXT IS NOT NULL)
    UNION ALL
    SELECT A.* FROM
      (SELECT
        DIV_CODE || '' AS CODE_CD
        ,DIV_NM AS CODE_NM
      FROM RCH_DIV_CODE A
      ORDER BY A.DIV_CODE ASC) A
    ;
      
END RCH_DIV_CODE_TYPE_SELECT;

/
