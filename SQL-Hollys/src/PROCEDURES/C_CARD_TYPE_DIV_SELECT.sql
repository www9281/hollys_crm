--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_DIV_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_DIV_SELECT" (
    N_CATEGORY_DIV  IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    ----------------------- 카드 카테고리 검색 -----------------------
    v_query := 
            'SELECT 
                  CATEGORY_DIV
                  , CATEGORY_CD   AS CODE_CD
                  , CATEGORY_NM   AS CODE_NM
            FROM    C_CARD_CTG
            WHERE   COMP_CD      = ''016''';
        IF N_CATEGORY_DIV IS NULL THEN
          v_query := v_query ||
            ' AND     CATEGORY_DIV = ''000''';
        ELSIF N_CATEGORY_DIV = 'empty' THEN
          v_query := v_query ||
            ' AND     CATEGORY_DIV != ''000''';
        ELSE
          v_query := v_query ||
            ' AND     CATEGORY_DIV = ''' || N_CATEGORY_DIV || '''';
        END IF;
          v_query := v_query ||
            ' AND  USE_YN =''Y''
            ORDER BY SORT_ORDER';
    
    OPEN O_CURSOR FOR v_query;
      
END C_CARD_TYPE_DIV_SELECT;

/
