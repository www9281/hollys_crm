--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CUST_ID      IN  VARCHAR2,
    N_STOR_CD      IN  VARCHAR2,
    N_BRAND_CD     IN  VARCHAR2,
    N_START_DT     IN  VARCHAR2,
    N_END_DT       IN  VARCHAR2,
    N_USER_ID      IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드 조회] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', '', 'level_10' 'KOR')
    -- ==========================================================================================

      v_query := 
                'SELECT  
                      TO_CHAR(NVL(CARD.UPD_DT, CARD.INST_DT),''YYYY-MM-DD HH24:MI:SS'') AS UPD_DT
                      , TO_CHAR(TO_DATE(CARD.ISSUE_DT,''YYYYMMDDHH24MISS''),''YYYY-MM-DD'') AS ISSUE_DT
                      , CARD.CARD_STAT
                      , GET_COMMON_CODE_NM(''01725'', CARD.CARD_STAT, ''' || N_LANGUAGE_TP || ''' )  AS CARD_STAT_NM
                      , (SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)
                          FROM    C_CARD              CRD
                                , C_CARD_SAV_USE_HIS  HIS
                          WHERE   CRD.COMP_CD  = HIS.COMP_CD
                          AND     CRD.CARD_ID  = HIS.CARD_ID
                          AND     CRD.COMP_CD  = CARD.COMP_CD
                          AND     CRD.CARD_ID  = CARD.CARD_ID
                          AND     HIS.SAV_MLG != HIS.USE_MLG
                          AND     HIS.LOS_MLG_YN  = ''N'') AS SAV_MLG
                      , (SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE)
                          FROM    C_CARD                 CRD
                                , C_CARD_SAV_USE_PT_HIS  HIS
                          WHERE   CRD.COMP_CD  = HIS.COMP_CD
                          AND     CRD.CARD_ID  = HIS.CARD_ID
                          AND     CRD.COMP_CD  = CARD.COMP_CD
                          AND     CRD.CARD_ID  = CARD.CARD_ID
                          AND     HIS.SAV_PT != HIS.USE_PT
                          AND     HIS.LOS_PT_YN  = ''N'') AS SAV_PT
                      , CARD.SAV_CASH - CARD.USE_CASH AS SAV_CASH
                      , DECRYPT(CARD.CARD_ID) AS CARD_ID
                      , CARD.STOR_CD
                      , (SELECT STOR_NM FROM STORE WHERE STOR_CD = CARD.STOR_CD) AS STOR_NM
                      , CARD.DISP_YN
                      , DECODE(CARD.REP_CARD_YN, ''Y'', ''멤버쉽카드'', ''기프트카드'') AS CARD_DIV
                      , CARD.REMARKS
--                      ,(
--                        SELECT  GET_COMMON_CODE_NM(''01950'', CCT.CARD_DIV, ''' || N_LANGUAGE_TP || ''' ) AS CARD_DIV
--                        FROM    C_CARD_TYPE_REP CTR
--                              , C_CARD_TYPE     CCT
--                        WHERE   CTR.COMP_CD   = CCT.COMP_CD
--                        AND     CTR.CARD_TYPE = CCT.CARD_TYPE
--                        AND     CTR.COMP_CD   = CARD.COMP_CD
--                        AND     DECRYPT(CTR.START_CARD_CD) <= DECRYPT(CARD.CARD_ID)
--                        AND     DECRYPT(CTR.CLOSE_CARD_CD) >= DECRYPT(CARD.CARD_ID)
--                       ) AS CARD_DIV
                 FROM   C_CUST CUST
                    ,   C_CARD CARD
                WHERE CUST.COMP_CD  = ''' || P_COMP_CD || '''
                  AND (CUST.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                       AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = CUST.BRAND_CD AND USE_YN = ''Y'')))
                  AND CUST.CUST_ID  = ''' || P_CUST_ID || '''
                  AND (''' || N_STOR_CD || ''' IS NULL OR CARD.STOR_CD = ''' || N_STOR_CD || ''')
                  AND CUST.USE_YN = ''Y''   
                  AND CARD.USE_YN = ''Y''  
                  AND CUST.COMP_CD   = CARD.COMP_CD
                  AND CUST.BRAND_CD  = CARD.BRAND_CD
                  AND CUST.CUST_ID   = CARD.CUST_ID
                  AND (''' || N_START_DT || ''' IS NULL OR TO_CHAR(TO_DATE(CARD.ISSUE_DT,''YYYYMMDDHH24MISS''),''YYYYMMDD'') >= ''' || N_START_DT || ''')
                  AND (''' || N_END_DT || ''' IS NULL OR TO_CHAR(TO_DATE(CARD.ISSUE_DT,''YYYYMMDDHH24MISS''),''YYYYMMDD'') <= ''' || N_END_DT || ''')
                ORDER BY CARD.ISSUE_DT DESC, CARD.UPD_DT DESC';
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_CARD_SELECT;

/
