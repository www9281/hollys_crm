--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SELECT_ONE2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SELECT_ONE2" (
    P_COMP_CD     IN  VARCHAR2,
    P_BRAND_CD    IN  VARCHAR2,
    N_CUST_ID     IN  VARCHAR2,
    N_MOBILE      IN  VARCHAR2,
    N_CARD_ID     IN  VARCHAR2,
    N_CUST_WEB_ID IN  VARCHAR2,
    O_RTN_CD      OUT VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
    v_result_cd VARCHAR2(7) := '1';
    v_query_into VARCHAR2(3000);
    v_query VARCHAR2(30000);
    v_cust_cnt  NUMBER;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-24
    -- Description   :   POS API용 멤버쉽 회원관리 회원정보 단건조회
    -- ==========================================================================================
    
    IF N_CUST_ID IS NULL AND N_MOBILE IS NULL AND N_CARD_ID IS NULL AND N_CUST_WEB_ID IS NULL THEN
      Dbms_Output.Put_Line('회원번호, 전화번호, 카드번호, 회원ID 값중 적어도 하나의 값은 필수입니다.');
      v_result_cd := '180';
    ELSE 
      v_query_into := '
        SELECT
          COUNT(*)
        FROM C_CUST A
        WHERE A.COMP_CD = ''' || P_COMP_CD || '''
          AND A.BRAND_CD = ''' || P_BRAND_CD || '''
          AND A.USE_YN = ''Y''
          AND EXISTS (SELECT 1 FROM C_CARD WHERE CUST_ID = A.CUST_ID)
      ';
      
      IF N_CUST_ID IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
      END IF;
      
      IF N_MOBILE IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.MOBILE = ''' || N_MOBILE || '''';
      END IF;
      
      IF N_CARD_ID IS NOT NULL THEN
        v_query_into := v_query_into || ' AND EXISTS (SELECT 1 FROM C_CARD WHERE COMP_CD = A.COMP_CD AND CUST_ID = A.CUST_ID AND CARD_ID = ENCRYPT(''' || N_CARD_ID || '''))';
      END IF;
      
      EXECUTE IMMEDIATE v_query_into INTO v_cust_cnt;

      IF v_cust_cnt > 0 THEN
        v_query := '
        SELECT 
             A.COMP_CD
             , A.BRAND_CD
             , A.STOR_CD
             , A.CUST_ID
             , A.CUST_WEB_ID
             , CASE WHEN B.CARD_STAT = ''80'' THEN ''3''
                    ELSE A.CUST_STAT END AS CUST_STAT
             , A.SEX_DIV
             , A.LUNAR_DIV
             , A.CUST_NM
             , A.LVL_CD
             , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = A.COMP_CD AND LVL_CD = A.LVL_CD) AS LVL_NM
             , A.BIRTH_DT
             , A.SMS_RCV_YN
             , A.PUSH_RCV_YN
             , A.EMAIL_RCV_YN
             , A.MOBILE
             , A.EMAIL
             , A.CASH_BILL_DIV
             , A.ISSUE_MOBILE
             , A.ISSUE_BUSI_NO
             , A.ADDR_DIV
             , A.ZIP_CD
             , A.ADDR1
             , A.ADDR2
             , A.REMARKS
             , A.JOIN_DT
             , A.LEAVE_DT
             , A.MLG_SAV_DT
             , A.MLG_DIV
             , (SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)
                FROM    C_CARD              CRD
                      , C_CARD_SAV_USE_HIS  HIS
                WHERE   CRD.COMP_CD  = HIS.COMP_CD
                AND     CRD.CARD_ID  = HIS.CARD_ID
                AND     CRD.COMP_CD  = A.COMP_CD
                AND     CRD.CUST_ID  = A.CUST_ID
                AND     HIS.SAV_MLG != HIS.USE_MLG
                AND     HIS.LOS_MLG_YN  = ''N'') AS SAV_MLG
             , A.CASH_USE_DT
             , (SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE)
                FROM    C_CARD                 CRD
                      , C_CARD_SAV_USE_PT_HIS  HIS
                WHERE   CRD.COMP_CD  = HIS.COMP_CD
                AND     CRD.CARD_ID  = HIS.CARD_ID
                AND     CRD.COMP_CD  = A.COMP_CD
                AND     CRD.CUST_ID  = A.CUST_ID
                AND     HIS.SAV_PT != HIS.USE_PT
                AND     HIS.LOS_PT_YN  = ''N'') AS SAV_PT
             , A.UPD_DT
             , A.SAV_CASH - A.USE_CASH as SAV_CASH
             , A.BAD_CUST_YN
             , A.LEAVE_RMK
             , A.BAD_CUST_COMPLAIN
             , A.USE_YN  
             , TO_CHAR(A.LVL_CHG_DT, ''YYYY-MM-DD'') AS LVL_START_DT 
             , TO_CHAR(ADD_MONTHS(A.LVL_CHG_DT, 12), ''YYYY-MM-DD'') AS LVL_CLOSE_DT 
             , (SELECT DECODE(COUNT(*), 0, ''Y'', ''N'') FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_USE_YN
             , (SELECT GET_ITEM_NM(MAX(ITEM_CD)) FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_ITEM_NM
             , B.CARD_ID
             , A.DI_STR
        FROM C_CUST A, C_CARD B
        WHERE A.COMP_CD = ''' || P_COMP_CD || '''
          AND A.BRAND_CD = ''' || P_BRAND_CD || '''
          AND A.COMP_CD = B.COMP_CD
          AND A.CUST_ID = B.CUST_ID
          AND B.REP_CARD_YN = ''Y''
          AND B.USE_YN = ''Y''
        ';
        
        IF N_CUST_ID IS NOT NULL THEN
          v_query := v_query || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
        END IF;
        
        IF N_MOBILE IS NOT NULL THEN
          v_query := v_query || ' AND A.MOBILE = ''' || N_MOBILE || '''';
        END IF;
        
        IF N_CARD_ID IS NOT NULL THEN
          v_query := v_query || ' AND EXISTS (SELECT 1 
                                   FROM C_CARD B 
                                   WHERE B.COMP_CD = A.COMP_CD 
                                     AND B.CUST_ID = A.CUST_ID 
                                     AND B.CARD_ID = ''' || N_CARD_ID || '''
                                     AND B.USE_YN = ''Y''
                                     AND B.CARD_STAT = ''10'')';
        END IF;
      ELSE 
        v_query := '
        SELECT 
             A.COMP_CD
             , A.BRAND_CD
             , A.STOR_CD
             , A.CUST_ID
             , A.CUST_WEB_ID
             , ''8'' AS CUST_STAT -- 휴면
             , A.SEX_DIV
             , A.LUNAR_DIV
             , A.CUST_NM
             , A.LVL_CD
             , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = A.COMP_CD AND LVL_CD = A.LVL_CD) AS LVL_NM
             , A.BIRTH_DT
             , A.SMS_RCV_YN
             , A.PUSH_RCV_YN
             , A.EMAIL_RCV_YN
             , A.MOBILE
             , A.EMAIL
             , A.CASH_BILL_DIV
             , A.ISSUE_MOBILE
             , A.ISSUE_BUSI_NO
             , A.ADDR_DIV
             , A.ZIP_CD
             , A.ADDR1
             , A.ADDR2
             , A.REMARKS
             , A.JOIN_DT
             , A.LEAVE_DT
             , A.MLG_SAV_DT
             , A.MLG_DIV
             , (SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)
                FROM    C_CARD              CRD
                      , C_CARD_SAV_USE_HIS  HIS
                WHERE   CRD.COMP_CD  = HIS.COMP_CD
                AND     CRD.CARD_ID  = HIS.CARD_ID
                AND     CRD.COMP_CD  = A.COMP_CD
                AND     CRD.CUST_ID  = A.CUST_ID
                AND     HIS.SAV_MLG != HIS.USE_MLG
                AND     HIS.LOS_MLG_YN  = ''N'') AS SAV_MLG
             , A.CASH_USE_DT
             , (SELECT  SUM(HIS.SAV_PT - HIS.USE_PT - HIS.LOS_PT_UNUSE)
                FROM    C_CARD                 CRD
                      , C_CARD_SAV_USE_PT_HIS  HIS
                WHERE   CRD.COMP_CD  = HIS.COMP_CD
                AND     CRD.CARD_ID  = HIS.CARD_ID
                AND     CRD.COMP_CD  = A.COMP_CD
                AND     CRD.CUST_ID  = A.CUST_ID
                AND     HIS.SAV_PT != HIS.USE_PT
                AND     HIS.LOS_PT_YN  = ''N'') AS SAV_PT
             , A.UPD_DT
             , A.SAV_CASH - A.USE_CASH as SAV_CASH
             , A.BAD_CUST_YN
             , A.LEAVE_RMK
             , A.BAD_CUST_COMPLAIN
             , A.USE_YN  
             , TO_CHAR(A.LVL_CHG_DT, ''YYYY-MM-DD'') AS LVL_START_DT 
             , TO_CHAR(ADD_MONTHS(A.LVL_CHG_DT, 12), ''YYYY-MM-DD'') AS LVL_CLOSE_DT 
             , (SELECT DECODE(COUNT(*), 0, ''Y'', ''N'') FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_USE_YN
             , (SELECT GET_ITEM_NM(MAX(ITEM_CD)) FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_ITEM_NM
             , B.CARD_ID
             , A.DI_STR
        FROM C_CUST_REST A, C_CARD B
        WHERE A.COMP_CD = ''' || P_COMP_CD || '''
          AND A.BRAND_CD = ''' || P_BRAND_CD || '''
          AND A.COMP_CD = B.COMP_CD
          AND A.CUST_ID = B.CUST_ID
          AND B.REP_CARD_YN = ''Y''
          AND B.USE_YN = ''Y''
        ';
        
        IF N_CUST_ID IS NOT NULL THEN
          v_query := v_query || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
        END IF;
        
        IF N_MOBILE IS NOT NULL THEN
          v_query := v_query || ' AND A.MOBILE = ''' || N_MOBILE || '''';
        END IF;
        
        IF N_CARD_ID IS NOT NULL THEN
          v_query := v_query || ' AND EXISTS (SELECT 1 
                                   FROM C_CARD B 
                                   WHERE B.COMP_CD = A.COMP_CD 
                                     AND B.CUST_ID = A.CUST_ID 
                                     AND B.CARD_ID = ''' || N_CARD_ID || '''
                                     AND B.USE_YN = ''Y''
                                     AND B.CARD_STAT = ''10'')';
        END IF;
      END IF;
      
      
      OPEN O_CURSOR FOR v_query;
    END IF;
    O_RTN_CD := v_result_cd;
END API_C_CUST_SELECT_ONE2;

/
