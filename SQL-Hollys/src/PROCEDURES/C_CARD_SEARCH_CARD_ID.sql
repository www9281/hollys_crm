--------------------------------------------------------
--  DDL for Procedure C_CARD_SEARCH_CARD_ID
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SEARCH_CARD_ID" (
    P_COMP_CD      IN  VARCHAR2,    --회사코드
    P_CUST_ID      IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
--------------------------------- 카드정보 조회 (콤보용) ----------------------------------
      v_query := 
                'SELECT 
                     decrypt(CARD_ID) as CODE_CD
                     , decrypt(CARD_ID) as CODE_NM
                  FROM C_CARD
                 WHERE COMP_CD = ''' || P_COMP_CD || '''
                   AND CUST_ID = ''' || P_CUST_ID || '''
                   AND USE_YN = ''Y''
                   AND CARD_STAT = ''10''
                   AND REP_CARD_YN = ''Y''
                 ORDER BY 1';
    OPEN O_CURSOR FOR v_query;
    
END C_CARD_SEARCH_CARD_ID;

/
