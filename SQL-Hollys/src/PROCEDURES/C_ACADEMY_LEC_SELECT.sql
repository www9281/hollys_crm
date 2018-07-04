--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_LEC_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_LEC_SELECT" (
   P_LEC_IDX  IN  VARCHAR2,
   O_CURSOR   OUT SYS_REFCURSOR
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌등록정보 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      LEC_NM
      ,LEC_AMT
      ,LEC_CONTENT
      ,CAMPUS_DIV
      ,VIEW_YN
    FROM C_ACADEMY_LEC
    WHERE LEC_IDX = P_LEC_IDX
      AND USE_YN = 'Y'
    ;
    
END C_ACADEMY_LEC_SELECT;

/
