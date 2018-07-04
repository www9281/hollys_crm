--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_AUTO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_AUTO_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
--------------------------------- 카드수정탭 자동충전정보 조회 ----------------------------------
      v_query := 
                'SELECT  
                      COMP_CD
                      , DECRYPT(CARD_ID) AS CARD_ID
                      , CRG_FRDT
                      , CRG_TODT
                      , CRG_AMT
                      , TERM_DIV
                      , MIN_AMT
                      , REPEAT_DT
                FROM    C_CARD_AUTO
                WHERE   COMP_CD = ''' || P_COMP_CD || '''
                AND     CARD_ID = ENCRYPT(''' || P_CARD_ID || ''')';
                     
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_CARD_AUTO_SELECT;

/
