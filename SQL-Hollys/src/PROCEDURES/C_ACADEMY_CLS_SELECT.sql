--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_CLS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_CLS_SELECT" (
   P_LEC_IDX      IN  VARCHAR2,
   O_CURSOR       OUT SYS_REFCURSOR
)IS 
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌등록정보에 포함된 클래스 목록 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      CLS_IDX
      ,LEC_IDX
      ,CLS_DIV
      ,CLS_TERM
      ,CLS_NM
      ,TO_CHAR(CLS_OPEN_DT, 'YYYY-MM-DD') AS CLS_OPEN_DT
      ,CLS_PROC_DIV
    FROM C_ACADEMY_CLS
    WHERE LEC_IDX = P_LEC_IDX
      AND USE_YN = 'Y'
    ORDER BY INST_DT ASC
    ;
    
END C_ACADEMY_CLS_SELECT;

/
