--------------------------------------------------------
--  DDL for Procedure W_GROUP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_SELECT" (
    N_USE_YN   IN  VARCHAR2, 
    O_CURSOR   OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-31
    -- Description   :   사용자 메뉴 그룹정보 조회
    -- Test          :   W_GROUP_SELECT (NULL)
    -- ==========================================================================================
    v_query := 
              '
              SELECT
                  GROUP_NO
                  ,GROUP_NM
                  ,USE_YN
                  ,TO_CHAR(INST_DT, ''YYYY-MM-DD'') AS INST_DT
                  ,INST_USER
              FROM W_GROUP
              WHERE USE_YN = NVL(''' || N_USE_YN || ''', USE_YN)
              ORDER BY GROUP_NO ASC
              ';
            
    OPEN O_CURSOR FOR v_query;
      
END W_GROUP_SELECT;

/
