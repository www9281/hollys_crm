--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_AUTO_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_AUTO_HIS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
--------------------------------- 카드수정탭 자동충전 이력 조회 ----------------------------------
      v_query := 
                'SELECT  
                      COMP_CD
                      , DECRYPT(CARD_ID) AS CARD_ID
                      , CHG_DT
                      , CHG_SEQ
                      , CRG_FRDT
                      , CRG_TODT
                      , CRG_AMT
                      , TERM_DIV
                      , MIN_AMT
                      , REPEAT_DT
                FROM    C_CARD_AUTO_HIS
                WHERE   COMP_CD = ''' || P_COMP_CD || '''
                AND     CARD_ID = ENCRYPT(''' || P_CARD_ID || ''')
                ORDER BY 
                        CHG_DT  DESC
                      , CHG_SEQ DESC';
                     
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_CARD_AUTO_HIS_SELECT;

/
