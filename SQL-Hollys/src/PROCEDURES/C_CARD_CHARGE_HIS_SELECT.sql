--------------------------------------------------------
--  DDL for Procedure C_CARD_CHARGE_HIS_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_CHARGE_HIS_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_START_DT    IN   VARCHAR2,
    N_END_DT      IN   VARCHAR2,
    N_USER_ID     IN   VARCHAR2,
    N_LANGUAGE_TP IN   VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
--------------------------------- 카드충전이력 조회 ----------------------------------
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드충전이력] 탭 정보 조회
    -- Test          :   C_CARD_CHARGE_HIS_SELECT
    -- ==========================================================================================
      v_query := 
                'SELECT  
                     decrypt(CCH.CARD_ID) AS CARD_ID
                     ,  CCH.CRG_DT
                     ,  CCH.CRG_SEQ
                     ,  CCH.CRG_FG
                     ,  CCH.CRG_AMT
                     ,  GET_COMMON_CODE_NM(''01735'', CCH.CRG_FG, ''' || N_LANGUAGE_TP || ''') AS CRG_FG_NM
                     ,  CCH.CRG_DIV
                     ,  GET_COMMON_CODE_NM(''01745'', CCH.CRG_DIV, ''' || N_LANGUAGE_TP || ''') AS CRG_DIV_NM
                     ,  CCH.CRG_SCOPE
                     ,  GET_COMMON_CODE_NM(''01970'', CCH.CRG_SCOPE, ''' || N_LANGUAGE_TP || ''') AS CRG_SCOPE_NM
                     ,  CCH.CHANNEL
                     ,  GET_COMMON_CODE_NM(''01755'', CCH.CHANNEL, ''' || N_LANGUAGE_TP || ''') AS CHANNEL_NM
                     ,  NVL(CCH.ORG_CHANNEL, CCH.CHANNEL) AS ORG_CHANNEL
                     ,  GET_COMMON_CODE_NM(''01755'', NVL(CCH.ORG_CHANNEL, CCH.CHANNEL), ''' || N_LANGUAGE_TP || ''') AS ORG_CHANNEL_NM
                     ,  CCH.CRG_AUTO_DIV
                     ,  GET_COMMON_CODE_NM(''01960'', CCH.CRG_AUTO_DIV, ''' || N_LANGUAGE_TP || ''') AS CRG_AUTO_DIV_NM
                     ,  CCH.STOR_CD
                     ,  STO.STOR_NM
                     ,  CCH.REMARKS
                FROM    C_CARD_CHARGE_HIS CCH
                     ,  STORE             STO
                WHERE   CCH.BRAND_CD = STO.BRAND_CD(+)
                AND     CCH.STOR_CD  = STO.STOR_CD (+)
                AND     CCH.COMP_CD  = ''' || P_COMP_CD || '''
                --AND     CCH.CARD_ID  = encrypt(''' || P_CARD_ID || ''')
                AND     (''' || N_STOR_CD || ''' IS NULL OR CCH.STOR_CD  = ''' || N_STOR_CD || ''')
                AND     (CCH.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                    AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = CCH.BRAND_CD AND USE_YN = ''Y'')))
                AND     (''' || N_START_DT || ''' IS NULL OR CCH.CRG_DT >= ''' || N_START_DT || ''')
                AND     (''' || N_END_DT || ''' IS NULL OR CCH.CRG_DT <= ''' || N_END_DT || ''')
                ORDER BY 
                        decrypt(CCH.CARD_ID)
                     ,  CCH.CRG_DT  DESC
                     ,  CCH.CRG_SEQ DESC';
                      
    OPEN O_CURSOR FOR v_query;
    
END C_CARD_CHARGE_HIS_SELECT;

/
