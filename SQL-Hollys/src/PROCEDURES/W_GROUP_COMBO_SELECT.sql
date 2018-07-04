--------------------------------------------------------
--  DDL for Procedure W_GROUP_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_COMBO_SELECT" (
    N_REQ_TEXT    IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
      
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-01
    -- Description   :   사용자그룹설정에 필요한 그룹 콤보리스트 조회
    -- Test          :   W_GROUP_COMBO_SELECT ('선택')
    -- ==========================================================================================
      v_query := '';
            IF N_REQ_TEXT IS NOT NULL THEN
              v_query := v_query ||
                'SELECT  
                  A.CODE_CD     AS CODE_CD
                  , A.CODE_NM   AS CODE_NM
                 FROM (SELECT '''' AS CODE_CD, ''' || N_REQ_TEXT || ''' AS CODE_NM, 0 AS SORT_SEQ FROM DUAL) A
                 UNION ALL';
            END IF;
            
      v_query := v_query ||
            '
            SELECT
                  GROUP_NO AS CODE_CD
                  ,GROUP_NM AS CODE_NM
              FROM W_GROUP
              WHERE USE_YN = ''Y''
              ORDER BY CODE_CD NULLS FIRST
            ';
                   
      OPEN O_CURSOR FOR v_query;
END W_GROUP_COMBO_SELECT;

/
