--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_CHARGE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_CHARGE_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드충전조정] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', '', '', 'level_10' 'KOR')
    -- ==========================================================================================
      v_query := 
                'SELECT   
                     decrypt(CSH.CARD_ID)         AS T5_CARD_ID
                     ,  TO_CHAR(SYSDATE, ''YYYYMMDD'') AS T5_CRG_DT
                     ,  CSH.CARD_STAT                AS T5_CARD_STAT
                     ,  NULL                         AS T5_CRG_FG
                     ,  NULL                         AS T5_CRG_DIV 
                     ,  NULL                         AS T5_ORG_CHANNEL
                     ,  NULL                         AS T5_CRG_SCOPE
                     ,  0                            AS T5_CRG_AMT
                     ,  NULL                         AS T5_CRG_REMARKS
                     ,  NULL                         AS T5_STOR_CD
                     ,  MEMB_DIV                     AS T5_MEMB_DIV
                     ,  CSH.ISSUE_BRAND_CD           AS BRNAD_CD
                     ,  CSH.COMP_CD
                FROM    C_CARD CSH
                WHERE   CSH.COMP_CD = ''' || P_COMP_CD || '''
                AND     CSH.CARD_ID = encrypt(''' || P_CARD_ID || ''')';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_CARD_CHARGE_SELECT;

/
