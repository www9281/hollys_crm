--------------------------------------------------------
--  DDL for Procedure C_CUST_SELECT_ONE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_SELECT_ONE" (
    P_COMP_CD     IN  VARCHAR2,
    P_CUST_ID     IN  VARCHAR2,
    N_BRAND_CD    IN  VARCHAR2,
    N_STOR_CD     IN  VARCHAR2,
    N_USER_ID     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 회원정보 단건조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', '', '', 'admin')
    -- ==========================================================================================
    v_query := 
              'SELECT 
                 COMP_CD
                 , BRAND_CD
                 , STOR_CD
                 , CUST_ID
                 , CUST_WEB_ID
                 , CUST_STAT
                 , SEX_DIV
                 , LUNAR_DIV
                 , decrypt(CUST_NM) as CUST_NM
                 , LVL_CD
                 , BIRTH_DT
                 , SMS_RCV_YN
                 , PUSH_RCV_YN
                 , EMAIL_RCV_YN
                 , FN_GET_FORMAT_HP_NO(decrypt(MOBILE)) as MOBILE
                 , EMAIL
                 , CASH_BILL_DIV
                 , FN_GET_FORMAT_HP_NO(decrypt(ISSUE_MOBILE))  as ISSUE_MOBILE
                 , ISSUE_BUSI_NO
                 , ADDR_DIV
                 , SUBSTR(ZIP_CD,1,3) || ''-'' || SUBSTR(ZIP_CD,4,3) as  ZIP_CD
                 , ADDR1
                 , ADDR2
                 , REMARKS
                 , CASE WHEN JOIN_DT IS NOT NULL THEN SUBSTR(JOIN_DT,1,4)|| ''-'' ||SUBSTR(JOIN_DT,5,2)|| ''-'' ||SUBSTR(JOIN_DT,7,2) END as JOIN_DT
                 , CASE WHEN LEAVE_DT IS NOT NULL THEN SUBSTR(LEAVE_DT,1,4)|| ''-'' ||SUBSTR(LEAVE_DT,5,2)|| ''-'' ||SUBSTR(LEAVE_DT,7,2) END as LEAVE_DT
                 , CASE WHEN MLG_SAV_DT IS NOT NULL THEN SUBSTR(MLG_SAV_DT,1,4)|| ''-'' ||SUBSTR(MLG_SAV_DT,5,2)|| ''-'' ||SUBSTR(MLG_SAV_DT,7,2) END as MLG_SAV_DT
                 , MLG_DIV
                 , (SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)
                    FROM    C_CUST              CST
                          , C_CARD              CRD
                          , C_CARD_SAV_USE_HIS  HIS
                    WHERE   CST.COMP_CD  = CRD.COMP_CD
                    AND     CST.CUST_ID  = CRD.CUST_ID
                    AND     CRD.COMP_CD  = HIS.COMP_CD
                    AND     CRD.CARD_ID  = HIS.CARD_ID
                    AND     CRD.COMP_CD  = A.COMP_CD
                    AND     CRD.CUST_ID  = A.CUST_ID
                    AND     HIS.SAV_MLG != HIS.USE_MLG
                    AND     HIS.LOS_MLG_YN  = ''N'') AS SAV_MLG
                 , CASE WHEN CASH_USE_DT IS NOT NULL THEN SUBSTR(CASH_USE_DT,1,4)|| ''-'' ||SUBSTR(CASH_USE_DT,5,2)|| ''-'' ||SUBSTR(CASH_USE_DT,7,2) END as CASH_USE_DT                 
                 , (SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE)
                    FROM    C_CUST                 CST
                          , C_CARD                 CRD
                          , C_CARD_SAV_USE_PT_HIS  HIS
                    WHERE   CST.COMP_CD  = CRD.COMP_CD
                    AND     CST.CUST_ID  = CRD.CUST_ID
                    AND     CRD.COMP_CD  = HIS.COMP_CD
                    AND     CRD.CARD_ID  = HIS.CARD_ID
                    AND     CRD.COMP_CD  = A.COMP_CD
                    AND     CRD.CUST_ID  = A.CUST_ID
                    AND     HIS.SAV_PT != HIS.USE_PT
                    AND     HIS.LOS_PT_YN  = ''N'') AS SAV_PT
                 , TO_CHAR(UPD_DT, ''YYYY-MM-DD'') as UPD_DT
                 , SAV_CASH - USE_CASH as SAV_CASH  
                 , BAD_CUST_YN
                 , LEAVE_RMK
                 , BAD_CUST_COMPLAIN
                 , USE_YN  
                 , TO_CHAR(LVL_CHG_DT, ''YYYY-MM-DD'') AS LVL_START_DT
                 , TO_CHAR(ADD_MONTHS(LVL_CHG_DT-1, 12), ''YYYY-MM-DD'') AS LVL_CLOSE_DT
                 , A.NEGATIVE_USER_YN
            FROM C_CUST A
            WHERE COMP_CD  =  ''' || P_COMP_CD || '''
              AND (A.BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                    AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = A.BRAND_CD AND USE_YN = ''Y'')))
              AND (''' || N_STOR_CD || ''' IS NULL OR  STOR_CD = ''' || N_STOR_CD || ''')
              AND CUST_ID=''' || P_CUST_ID || '''
            ';
            
    OPEN O_CURSOR FOR v_query;
      
END C_CUST_SELECT_ONE;

/
