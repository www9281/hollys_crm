--------------------------------------------------------
--  DDL for Procedure C_CARD_CTG_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CTG_SELECT" (
    P_COMP_CD       IN  VARCHAR2,
    N_CATEGORY_DIV  IN  VARCHAR2,
    N_USE_YN        IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    ----------------------- 카드 카테고리 검색 -----------------------
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 카드관리 [카드카테고리관리] 정보 조회
    -- Test          :   C_CARD_CTG_SELECT ('000', 'level_10', '', '', '', '', 'level_10' 'KOR')
    -- ==========================================================================================
    v_query := 
            'SELECT 
                  COMP_CD
                  , CATEGORY_DIV
                  , CATEGORY_CD
                  , CATEGORY_NM
                  , SORT_ORDER
                  , USE_YN
            FROM    C_CARD_CTG
            WHERE   COMP_CD      = ''' || P_COMP_CD || '''';
        IF N_CATEGORY_DIV IS NULL THEN
          v_query := v_query ||
            ' AND     CATEGORY_DIV = ''000''';
        ELSE
          v_query := v_query ||
            ' AND     CATEGORY_DIV = ''' || N_CATEGORY_DIV || '''';
        END IF;
          v_query := v_query ||
            ' AND  (''' || N_USE_YN || ''' IS NULL OR USE_YN = ''' || N_USE_YN || ''')
            ORDER BY SORT_ORDER';
    
    OPEN O_CURSOR FOR v_query;
      
END C_CARD_CTG_SELECT;

/
