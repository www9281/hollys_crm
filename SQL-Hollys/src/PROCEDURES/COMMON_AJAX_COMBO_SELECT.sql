--------------------------------------------------------
--  DDL for Procedure COMMON_AJAX_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COMMON_AJAX_COMBO_SELECT" (
    P_CODE_TP     IN   VARCHAR2,
    N_LANGUAGE    IN   VARCHAR2,
    N_VAL_C1      IN   VARCHAR2,
    N_REQ_TEXT    IN   VARCHAR2,
    N_EXCEPT_CD   IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
      ----------------------- 그리드 내 콤보 공통코드 조회 -----------------------
      v_query := '';
            IF N_REQ_TEXT IS NOT NULL THEN 
              v_query := v_query ||
                'SELECT  
                  A.CODE_CD     AS CODE_CD
                  , A.CODE_NM   AS CODE_NM
                  , A.SORT_SEQ  AS SORT_SEQ
                 FROM (SELECT '''' AS CODE_CD, ''' || N_REQ_TEXT || ''' AS CODE_NM, NULL AS SORT_SEQ FROM DUAL) A
                 UNION ALL';
            END IF;
            
        v_query := v_query ||
            '
            SELECT  
                 C.CODE_CD                                     AS CODE_CD
                 , DECODE(L.CODE_NM, NULL, C.CODE_NM, L.CODE_NM) AS CODE_NM
                 , C.SORT_SEQ
             FROM COMMON C,
                 (
                   SELECT CODE_CD, CODE_NM
                   FROM LANG_COMMON
                   WHERE CODE_TP   = ''' || P_CODE_TP || '''
                     AND LANGUAGE_TP = ''' || N_LANGUAGE || '''
                     AND USE_YN = ''Y''
                 ) L
             WHERE C.CODE_CD = L.CODE_CD(+)
             AND C.CODE_TP = ''' || P_CODE_TP || '''
             AND C.USE_YN  = ''Y''';
      IF N_VAL_C1 IS NOT NULL THEN
        v_query := v_query ||
            'AND C.VAL_C1 = ''' || N_VAL_C1 || '''';
      END IF;
      
      IF N_EXCEPT_CD IS NOT NULL THEN
        v_query := v_query ||
            'AND C.CODE_CD NOT IN (''' || N_EXCEPT_CD || ''')';
      END IF;
      
      v_query := v_query || ' ORDER BY SORT_SEQ NULLS FIRST';
              
      OPEN O_CURSOR FOR v_query;
END COMMON_AJAX_COMBO_SELECT;

/
