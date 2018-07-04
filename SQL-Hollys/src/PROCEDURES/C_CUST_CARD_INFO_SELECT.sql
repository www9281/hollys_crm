--------------------------------------------------------
--  DDL for Procedure C_CUST_CARD_INFO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_CARD_INFO_SELECT" (
    P_COMP_CD      IN  VARCHAR2,
    P_CARD_ID      IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [카드수정] 카드정보 기본 조회
    -- Test          :   C_CUST_UPDATE ()
    -- ==========================================================================================
      v_query := 
                'SELECT 
                     CARD.COMP_CD
                     ,  decrypt(CARD.CARD_ID) AS CARD_ID
                     ,  CARD.PIN_NO
                     ,  TO_CHAR(TO_DATE(CARD.ISSUE_DT, ''YYYYMMDDHH24MISS''), ''YYYY-MM-DD'') AS ISSUE_DT
                     ,  CARD.ISSUE_DIV
                     ,  CARD.STOR_CD    AS STOR_CD
                     ,  STO.STOR_NM
                     ,  CARD.CARD_STAT
                     , DECODE(CARD.REP_CARD_YN, ''Y'', ''멤버쉽카드'', ''기프트카드'') AS CARD_DIV
                     ,  HIS.HIS_INST_DTM
                     ,  CSH.LATE_SAV_DT
                     ,  CUH.LATE_BUY_DT
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
                     ,  CARD.SAV_CASH - CARD.USE_CASH             AS SAV_CASH
                     ,  TO_CHAR(CARD.UPD_DT, ''YYYY-MM-DD HH24:MI:SS'') AS UPD_DT
                     ,  CARD.BANK_CD
                     , (
                        SELECT  CODE_NM
                        FROM    COMMON
                        WHERE   CODE_TP = ''00615''
                        AND     CODE_CD = CARD.BANK_CD
                        AND     USE_YN  = ''Y''
                       )                           AS BANK_NM
                     ,  decrypt(CARD.ACC_NO)       AS ACC_NO
                     ,  decrypt(CARD.BANK_USER_NM) AS BANK_USER_NM
                     ,  CARD.REFUND_DT
                     ,  NULL AS REMARKS
                     ,  CASE WHEN CARD.CARD_STAT = ''92'' THEN ABS(CARD.REFUND_CASH) ELSE NULL END REFUND_CASH
                     ,  CARD.REFUND_STAT
                     , (
                        SELECT  CODE_NM
                        FROM    COMMON
                        WHERE   CODE_TP = ''01825''
                        AND     CODE_CD = CARD.REFUND_STAT
                        AND     USE_YN  = ''Y''
                       )                           AS REFUND_STAT_NM
                     , CARD.REFUND_MSG  
                     , (
                        SELECT  CCT.UNIQUE_YN
                        FROM    C_CARD_TYPE     CCT
                              , C_CARD_TYPE_REP CTR 
                        WHERE   CCT.COMP_CD   = CTR.COMP_CD
                        AND     CCT.CARD_TYPE = CTR.CARD_TYPE
                        AND     CTR.COMP_CD   = ''' || P_COMP_CD || '''
                        AND     ''' || P_CARD_ID || ''' BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)
                        AND     ROWNUM        = 1
                       )                           AS UNIQUE_YN
                     , CARD.USE_YN
                     , CARD.DISP_YN
                     , CARD.MEMB_DIV
                FROM    C_CARD CARD
                     ,  STORE  STO
                     , (
                        SELECT  /*+ INDEX(CC1 PK_C_CARD_USE_HIS) */
                                COMP_CD
                             ,  CARD_ID
                             ,  MAX(CC1.USE_DT) LATE_BUY_DT
                        FROM    C_CARD_SAV_HIS CC1
                        WHERE   CC1.COMP_CD  = ''' || P_COMP_CD || '''
                        AND     CC1.CARD_ID  = encrypt(''' || P_CARD_ID || ''')
                        AND     CC1.SAV_USE_FG = ''4''
                        GROUP BY
                                COMP_CD
                             ,  CARD_ID
                       ) CUH
                     , (
                        SELECT  /*+ INDEX(CC1 PK_C_CARD_SAV_HIS) */
                                COMP_CD
                             ,  CARD_ID
                             ,  MAX(CC1.USE_DT) LATE_SAV_DT
                        FROM    C_CARD_SAV_HIS CC1
                        WHERE   CC1.COMP_CD    = ''' || P_COMP_CD || '''
                        AND     CC1.CARD_ID    = encrypt(''' || P_CARD_ID || ''')
                        AND     CC1.SAV_USE_FG = ''1''
                        AND     NOT EXISTS(
                                           SELECT 1
                                           FROM   C_CARD_SAV_HIS CC2
                                           WHERE  CC2.COMP_CD     = CC1.COMP_CD
                                           AND    CC2.CARD_ID     = CC1.CARD_ID
                                           AND    CC2.ORG_USE_DT  = CC1.ORG_USE_DT
                                           AND    CC2.ORG_USE_SEQ = CC1.ORG_USE_SEQ
                                          )
                        GROUP BY
                                COMP_CD
                             ,  CARD_ID
                       ) CSH
                      ,(
                        SELECT  COMP_CD
                              , CARD_ID
                              , CHG_DT
                              , HIS_INST_DTM
                        FROM   (
                                SELECT  COMP_CD
                                      , CARD_ID
                                      , CHG_DT
                                      , TO_CHAR(INST_DT, ''YYYY-MM-DD HH24:MI:SS'') AS HIS_INST_DTM
                                      , ROW_NUMBER() OVER(PARTITION BY COMP_CD, CARD_ID ORDER BY CHG_DT DESC, CHG_SEQ DESC) R_NUM
                                FROM    C_CARD_STAT_HIS
                                WHERE   COMP_CD = ''' || P_COMP_CD || '''
                                AND     CARD_ID = encrypt(''' || P_CARD_ID || ''')
                               )
                        WHERE   R_NUM = 1
                       ) HIS
                WHERE   CARD.BRAND_CD       = STO.BRAND_CD(+) 
                AND     CARD.STOR_CD        = STO.STOR_CD (+)
                AND     CARD.COMP_CD        = CUH.COMP_CD (+)
                AND     CARD.CARD_ID        = CUH.CARD_ID (+)
                AND     CARD.COMP_CD        = CSH.COMP_CD (+)
                AND     CARD.CARD_ID        = CSH.CARD_ID (+)
                AND     CARD.COMP_CD        = HIS.COMP_CD (+)
                AND     CARD.CARD_ID        = HIS.CARD_ID (+)
                AND     CARD.COMP_CD        = ''' || P_COMP_CD || '''
                AND     CARD.CARD_ID        = encrypt(''' || P_CARD_ID || ''')
                AND     CARD.CARD_STAT IN (''10'',''80'',''99'')';
    
    dbms_output.put_line(v_query);
    OPEN O_CURSOR FOR v_query;
    
END C_CUST_CARD_INFO_SELECT;

/
