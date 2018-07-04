--------------------------------------------------------
--  DDL for Procedure C_ACADEMY_LEC_SELECT_LIST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_ACADEMY_LEC_SELECT_LIST" (
   N_CAMPUS_DIV   IN  VARCHAR2,
   N_VIEW_YN      IN  VARCHAR2,
   N_CONN_DIV     IN  VARCHAR2,
   N_CONN_TEXT    IN  VARCHAR2,
   O_CURSOR       OUT SYS_REFCURSOR
)IS 
    v_query   VARCHAR2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-21
    -- Description   :   아카데미 강좌목록 조회
    -- ==========================================================================================
    v_query :=
      '
        SELECT
          ROWNUM AS RNUM
          ,LEC_IDX
          ,LEC_NM
          ,TO_CHAR(LEC_AMT) AS LEC_AMT
          ,LEC_CONTENT
          ,DECODE(CAMPUS_DIV, ''01'', ''서울'', ''02'', ''부산'') AS CAMPUS_DIV
          ,VIEW_YN
          ,TO_CHAR(INST_DT, ''YYYY-MM-DD'') AS INST_DT
        FROM C_ACADEMY_LEC
        WHERE (''' || N_CAMPUS_DIV || ''' IS NULL OR CAMPUS_DIV = ''' || N_CAMPUS_DIV || ''')';
      IF N_VIEW_YN = 'N' THEN
        v_query := v_query ||
          '
            AND VIEW_YN = ''Y''
          ';
      END IF;
      v_query := v_query ||
      '
          AND (''' || N_CONN_DIV || ''' IS NULL 
                      OR ''' || N_CONN_DIV || ''' IS NOT NULL AND LEC_NM LIKE ''%'' || ''' || N_CONN_TEXT || ''' || ''%''
                      OR ''' || N_CONN_DIV || ''' IS NOT NULL AND LEC_CONTENT LIKE ''%'' || ''' || N_CONN_TEXT || ''' || ''%'')
          AND USE_YN = ''Y''
          ORDER BY INST_DT DESC
      ';
    OPEN O_CURSOR FOR v_query;
    
END C_ACADEMY_LEC_SELECT_LIST;

/
