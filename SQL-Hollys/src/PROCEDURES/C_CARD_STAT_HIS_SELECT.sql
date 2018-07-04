--------------------------------------------------------
--  DDL for Procedure C_CARD_STAT_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_STAT_HIS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    N_START_DT     IN  VARCHAR2,
    N_END_DT       IN  VARCHAR2,
    N_LANGUAGE_TP IN   VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드상태이력] 정보 조회
    -- Test          :   C_CARD_STAT_HIS_SELECT ('000', '1040011260508635', '', '', 'KOR')
    -- ==========================================================================================
      v_query := 
                'SELECT  
                     decrypt(CSH.CARD_ID) AS CARD_ID
                     ,  CSH.CHG_DT
                     ,  CSH.CHG_SEQ
                     ,  CSH.REMARKS
                     ,  CSH.CARD_STAT_FR 
                     ,  GET_COMMON_CODE_NM(''01725'', CSH.CARD_STAT_FR, ''' || N_LANGUAGE_TP || ''') AS CARD_STAT_NM_FR
                     ,  CSH.CARD_STAT_TO
                     ,  GET_COMMON_CODE_NM(''01725'', CSH.CARD_STAT_TO, ''' || N_LANGUAGE_TP || ''') AS CARD_STAT_NM_TO
                     ,  CSH.INST_USER
                     ,  CSH.INST_DT
                FROM    C_CARD_STAT_HIS CSH
                WHERE   CSH.COMP_CD = ''' || P_COMP_CD || '''
                AND     CSH.CARD_ID = encrypt(''' || P_CARD_ID || ''')';
      IF N_START_DT IS NOT NULL THEN
         v_query := v_query || ' AND CSH.CHG_DT >= ''' || N_START_DT || '''';
      END IF;
      
      IF N_END_DT IS NOT NULL THEN
         v_query := v_query || ' AND CSH.CHG_DT <= ''' || N_END_DT || '''';
      END IF;
      
      v_query := v_query || '
                ORDER BY 
                        CSH.CHG_DT  DESC
                     ,  CSH.CHG_SEQ DESC';
    OPEN O_CURSOR FOR v_query;
    
END C_CARD_STAT_HIS_SELECT;

/
