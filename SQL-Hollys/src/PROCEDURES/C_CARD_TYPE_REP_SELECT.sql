--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_REP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_REP_SELECT" (
    P_COMP_CD     IN   VARCHAR2,
    N_CARD_TYPE   IN   VARCHAR2,
    N_USE_YN      IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
      ----------------------- 카드타입 상세 카드정보 검색 -----------------------
      v_query :=
            'SELECT  *
             FROM  (
                        SELECT  COMP_CD
                             ,  CARD_TYPE
                             ,  DECRYPT(START_CARD_CD)  AS START_CARD_CD
                             ,  DECRYPT(CLOSE_CARD_CD)  AS CLOSE_CARD_CD
                             ,  ISSUE_DT
                             ,  USE_YN
                          FROM  C_CARD_TYPE_REP
                         WHERE  COMP_CD     = ''' || P_COMP_CD || '''
                           AND  CARD_TYPE   = ''' || N_CARD_TYPE || '''';
            IF N_USE_YN IS NOT NULL THEN
              v_query := v_query || ' AND  USE_YN = ''' || N_USE_YN || '''';
            END IF;
                           
      v_query := v_query || '
                    )
             ORDER  BY ISSUE_DT DESC, START_CARD_CD';
             
      OPEN O_CURSOR FOR v_query;
END C_CARD_TYPE_REP_SELECT;

/
