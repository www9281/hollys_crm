--------------------------------------------------------
--  DDL for Procedure C_CUST_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_HIS_SELECT" (
    P_COMP_CD      IN   VARCHAR2,
    P_CUST_ID      IN   VARCHAR2,
    N_START_DT     IN   VARCHAR2,
    N_END_DT       IN   VARCHAR2,
    N_LANGUAGE_TP  IN   VARCHAR2,
    O_CURSOR       OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [회원 변경이력] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', 'KOR')
    -- ==========================================================================================
      v_query :=
            'SELECT 
                 HIS.CHG_DT
                 , HIS.CHG_SEQ
                 , GET_COMMON_CODE_NM(''01750'', HIS.CHG_DIV, ''' || N_LANGUAGE_TP || ''' ) AS CHG_DIV
                 , CASE  HIS.CHG_DIV WHEN ''01'' THEN DECRYPT(HIS.CHG_FR)
                                     WHEN ''02'' THEN GET_COMMON_CODE_NM(''00315'', HIS.CHG_FR, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''09'' THEN GET_COMMON_CODE_NM(''01730'', HIS.CHG_FR, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''05'' THEN FN_GET_FORMAT_HP_NO(DECRYPT(HIS.CHG_FR))
                                     WHEN ''13'' THEN GET_COMMON_CODE_NM(''01720'', HIS.CHG_FR, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''15'' THEN ( SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = HIS.COMP_CD AND LVL_CD = HIS.CHG_FR AND USE_YN = ''Y'' AND ROWNUM=1)
                                     WHEN ''16'' THEN GET_COMMON_CODE_NM(''01890'', HIS.CHG_FR, ''' || N_LANGUAGE_TP || ''') 
                                     ELSE HIS.CHG_FR
                   END AS CHG_FR
                 , CASE  HIS.CHG_DIV WHEN ''01'' THEN DECRYPT(HIS.CHG_TO)
                                     WHEN ''02'' THEN GET_COMMON_CODE_NM(''00315'', HIS.CHG_TO, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''09'' THEN GET_COMMON_CODE_NM(''01730'', HIS.CHG_TO, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''05'' THEN FN_GET_FORMAT_HP_NO(DECRYPT(HIS.CHG_TO))
                                     WHEN ''13'' THEN GET_COMMON_CODE_NM(''01720'', HIS.CHG_TO, ''' || N_LANGUAGE_TP || ''')
                                     WHEN ''15'' THEN ( SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = HIS.COMP_CD AND LVL_CD = HIS.CHG_TO AND USE_YN = ''Y'' AND ROWNUM=1)
                                     WHEN ''16'' THEN GET_COMMON_CODE_NM(''01890'', HIS.CHG_FR, ''' || N_LANGUAGE_TP || ''') 
                                     ELSE HIS.CHG_TO
                   END AS CHG_TO
                 , REMARKS
                 , (SELECT HQ.USER_NM FROM HQ_USER HQ WHERE HQ.USER_ID = HIS.INST_USER AND ROWNUM = 1) AS INST_USER
                 , TO_CHAR(HIS.INST_DT, ''YYYY-MM-DD HH24:MI:SS'') as INST_DT
              FROM C_CUST_HIS HIS
             WHERE HIS.COMP_CD = ''' || P_COMP_CD || '''
               AND HIS.CUST_ID = ''' || P_CUST_ID || '''
               AND (''' || N_START_DT || ''' IS NULL OR HIS.CHG_DT >= ''' || N_START_DT || ''')
               AND (''' || N_END_DT || ''' IS NULL OR HIS.CHG_DT <= ''' || N_END_DT || ''')
               AND HIS.USE_YN = ''Y''
             ORDER BY HIS.CHG_DT DESC, HIS.CHG_SEQ DESC, HIS.CHG_DIV'; 
             
      OPEN O_CURSOR FOR v_query; 
END C_CUST_HIS_SELECT;

/
