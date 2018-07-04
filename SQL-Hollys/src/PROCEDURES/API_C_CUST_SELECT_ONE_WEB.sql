--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SELECT_ONE_WEB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SELECT_ONE_WEB" (
    P_COMP_CD       IN  VARCHAR2,
    P_BRAND_CD      IN  VARCHAR2,
    N_CUST_ID       IN  VARCHAR2,
    N_MOBILE        IN  VARCHAR2,
    N_CARD_ID       IN  VARCHAR2,
    N_CUST_WEB_ID   IN  VARCHAR2,
    N_DI_STR        IN  VARCHAR2,
    N_EMAIL         IN  VARCHAR2,
    O_RTN_CD        OUT VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_result_cd VARCHAR2(7) := '1';
    v_cust_cnt  NUMBER;
    v_query VARCHAR2(30000);
    v_query_into VARCHAR2(3000);
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-24
    -- Description   :   POS API용 멤버쉽 회원관리 회원정보 단건조회
    -- ==========================================================================================
    
    IF N_CUST_ID IS NULL AND N_MOBILE IS NULL AND N_CARD_ID IS NULL AND N_CUST_WEB_ID IS NULL AND N_DI_STR IS NULL AND N_EMAIL IS NULL THEN
      Dbms_Output.Put_Line('CUST_ID, MOBILE, CARD_ID, CUST_WEB_ID, DI_STR, EMAIL 중 한개 필수입력');
      v_result_cd := '191';
    ELSE
      -- 회원테이블에서 해당 회원 데이터 있는지 확인(없으면 휴면테이블 조회)
      v_query_into := '
          SELECT
            COUNT(*)
          FROM C_CUST A
          WHERE A.COMP_CD = ''' || P_COMP_CD || '''
            AND A.BRAND_CD = ''' || P_BRAND_CD || '''
            AND A.USE_YN = ''Y''
      ';
      
      IF N_CUST_ID IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
      END IF;
      
      IF N_MOBILE IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.MOBILE = ENCRYPT(''' || N_MOBILE || ''')';
      END IF;
      
      IF N_CARD_ID IS NOT NULL THEN
        v_query_into := v_query_into || ' AND EXISTS (SELECT 1 FROM C_CARD WHERE COMP_CD = A.COMP_CD AND CUST_ID = A.CUST_ID AND CARD_ID = ENCRYPT(''' || N_CARD_ID || '''))';
      END IF;
      
      IF N_CUST_WEB_ID IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.CUST_WEB_ID = ''' || N_CUST_WEB_ID || '''';
      END IF;
      
      IF N_DI_STR IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.DI_STR = ''' || N_DI_STR || '''';
      END IF;
      
      IF N_EMAIL IS NOT NULL THEN
        v_query_into := v_query_into || ' AND A.EMAIL = ''' || N_EMAIL || '''';
      END IF;
    
      EXECUTE IMMEDIATE v_query_into INTO v_cust_cnt;
      
      IF v_cust_cnt > 0 THEN
        v_query := '
            SELECT 
               COMP_CD
               , BRAND_CD
               , STOR_CD
               , CUST_ID
               , CUST_WEB_ID
               , CASE WHEN (SELECT SUM(FAIL_COUNT) FROM C_CUST_LOGIN_FAIL WHERE CUST_ID = A.CUST_ID) >= 5 THEN ''11''
                      ELSE A.CUST_STAT
                 END AS CUST_STAT
               , SEX_DIV
               , LUNAR_DIV
               , DECRYPT(CUST_NM) AS CUST_NM
               , LVL_CD
               , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = A.COMP_CD AND LVL_CD = A.LVL_CD) AS LVL_NM
               , BIRTH_DT
               , SMS_RCV_YN
               , PUSH_RCV_YN
               , EMAIL_RCV_YN
               , DECRYPT(MOBILE) AS MOBILE
               , EMAIL
               , CASH_BILL_DIV
               , DECRYPT(ISSUE_MOBILE) AS ISSUE_MOBILE
               , ISSUE_BUSI_NO
               , ADDR_DIV
               , ZIP_CD
               , ADDR1
               , ADDR2
               , OWN_CERTI_DIV
               , REMARKS
               , JOIN_DT
               , LEAVE_DT
               , MLG_SAV_DT
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
               , CASH_USE_DT
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
               , UPD_DT
               , SAV_CASH - USE_CASH as SAV_CASH  
               , BAD_CUST_YN
               , LEAVE_RMK
               , BAD_CUST_COMPLAIN
               , USE_YN  
               , TO_CHAR(LVL_CHG_DT, ''YYYY-MM-DD'') AS LVL_START_DT 
               , TO_CHAR(ADD_MONTHS(LVL_CHG_DT, 12), ''YYYY-MM-DD'') AS LVL_CLOSE_DT 
               , (SELECT DECODE(COUNT(*), 0, ''Y'', ''N'') FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_USE_YN
               , (SELECT GET_ITEM_NM(MAX(ITEM_CD)) FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_ITEM_NM
               , (SELECT
                    DECRYPT(CARD_ID)
                  FROM C_CARD
                  WHERE COMP_CD = A.COMP_CD
                    AND CUST_ID = A.CUST_ID
                    AND REP_CARD_YN = ''Y''
                    AND USE_YN = ''Y''
                  ) AS CARD_ID
               , (SELECT
                    CARD_STAT
                  FROM C_CARD
                  WHERE COMP_CD = A.COMP_CD
                    AND CUST_ID = A.CUST_ID
                    AND REP_CARD_YN = ''Y''
                    AND USE_YN = ''Y''
                  ) AS CARD_STAT
               , A.DI_STR
               , A.LOGIN_DIV
               , A.LOGIN_IP
               , TO_CHAR(A.LAST_LOGIN_DT, ''YYYY-MM-DD HH24:MI:SS'') AS LAST_LOGIN_DT
               , ''N'' AS REST_USER_YN -- 휴면회원여부
               ,(SELECT COUNT(COUPON_CD) FROM PROMOTION_COUPON WHERE CUST_ID = A.CUST_ID AND COUPON_STATE = ''P0303''
               AND START_DT <= TO_CHAR(SYSDATE, ''YYYYMMDD'')
               AND END_DT >= TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS COUPON_CNT
          FROM C_CUST A
          WHERE A.COMP_CD = ''' || P_COMP_CD || '''
            AND A.BRAND_CD = ''' || P_BRAND_CD || '''
            AND A.USE_YN = ''Y''
          ';
          
          IF N_CUST_ID IS NOT NULL THEN
            v_query := v_query || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
          END IF;
          
          IF N_MOBILE IS NOT NULL THEN
            v_query := v_query || ' AND A.MOBILE = ENCRYPT(''' || N_MOBILE || ''')';
          END IF;
          
          IF N_CUST_WEB_ID IS NOT NULL THEN
            v_query := v_query || ' AND A.CUST_WEB_ID = ''' || N_CUST_WEB_ID || '''';
          END IF;
          
          IF N_CARD_ID IS NOT NULL THEN
            v_query := v_query || ' AND EXISTS (SELECT 1 FROM C_CARD WHERE COMP_CD = A.COMP_CD AND CUST_ID = A.CUST_ID AND CARD_ID = ENCRYPT(''' || N_CARD_ID || '''))';
          END IF;
          
          IF N_DI_STR IS NOT NULL THEN
            v_query := v_query || ' AND A.DI_STR = ''' || N_DI_STR || '''';
          END IF;
          
          IF N_EMAIL IS NOT NULL THEN
            v_query := v_query || ' AND A.EMAIL = ''' || N_EMAIL || '''';
          END IF;
            
          OPEN O_CURSOR FOR v_query;
      ELSE
        dbms_output.put_line('11');
        v_query := '
          SELECT
            COMP_CD
           , BRAND_CD
           , STOR_CD
           , CUST_ID
           , CUST_WEB_ID
           , CASE WHEN (SELECT SUM(FAIL_COUNT) FROM C_CUST_LOGIN_FAIL WHERE CUST_ID = A.CUST_ID) >= 5 THEN ''11''
                  ELSE A.CUST_STAT
             END AS CUST_STAT
           , SEX_DIV
           , LUNAR_DIV
           , DECRYPT(CUST_NM) AS CUST_NM
           , LVL_CD
           , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = A.COMP_CD AND LVL_CD = A.LVL_CD) AS LVL_NM
           , BIRTH_DT
           , SMS_RCV_YN
           , PUSH_RCV_YN
           , EMAIL_RCV_YN
           , DECRYPT(MOBILE) AS MOBILE
           , EMAIL
           , CASH_BILL_DIV
           , DECRYPT(ISSUE_MOBILE) AS ISSUE_MOBILE
           , ISSUE_BUSI_NO
           , ADDR_DIV
           , ZIP_CD
           , ADDR1
           , ADDR2
           , OWN_CERTI_DIV
           , REMARKS
           , JOIN_DT
           , LEAVE_DT
           , MLG_SAV_DT
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
           , CASH_USE_DT
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
           , UPD_DT
           , SAV_CASH - USE_CASH as SAV_CASH  
           , BAD_CUST_YN
           , LEAVE_RMK
           , BAD_CUST_COMPLAIN
           , USE_YN  
           , TO_CHAR(LVL_CHG_DT, ''YYYY-MM-DD'') AS LVL_START_DT 
           , TO_CHAR(ADD_MONTHS(LVL_CHG_DT-1, 12),''YYYY-MM-DD'') AS LVL_CLOSE_DT  
           , (SELECT DECODE(COUNT(*), 0, ''Y'', ''N'') FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_USE_YN
           , (SELECT GET_ITEM_NM(MAX(ITEM_CD)) FROM MEMBER_BNFIT WHERE COMP_CD = A.COMP_CD AND BRAND_CD = A.BRAND_CD AND CUST_ID = A.CUST_ID AND USE_DT = TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS BENEFIT_ITEM_NM
           , (SELECT
                DECRYPT(CARD_ID)
              FROM C_CARD
              WHERE COMP_CD = A.COMP_CD
                AND CUST_ID = A.CUST_ID
                AND REP_CARD_YN = ''Y''
                AND USE_YN = ''Y''
              ) AS CARD_ID
           , (SELECT
                CARD_STAT
              FROM C_CARD
              WHERE COMP_CD = A.COMP_CD
                AND CUST_ID = A.CUST_ID
                AND REP_CARD_YN = ''Y''
                AND USE_YN = ''Y''
              ) AS CARD_STAT
           , A.DI_STR
           , A.LOGIN_DIV
           , A.LOGIN_IP
           , TO_CHAR(A.LAST_LOGIN_DT, ''YYYY-MM-DD HH24:MI:SS'') AS LAST_LOGIN_DT 
           , ''Y'' AS REST_USER_YN -- 휴면회원여부
           ,(SELECT COUNT(COUPON_CD) FROM PROMOTION_COUPON WHERE CUST_ID = A.CUST_ID AND COUPON_STATE = ''P0303''
               AND START_DT <= TO_CHAR(SYSDATE, ''YYYYMMDD'')
               AND END_DT >= TO_CHAR(SYSDATE, ''YYYYMMDD'')) AS COUPON_CNT
          FROM C_CUST_REST A
          WHERE A.COMP_CD = ''' || P_COMP_CD || '''
            AND A.BRAND_CD = ''' || P_BRAND_CD || '''
            AND A.USE_YN = ''Y''
        ';
        
        IF N_CUST_ID IS NOT NULL THEN
          v_query := v_query || ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
        END IF;
        
        IF N_MOBILE IS NOT NULL THEN
          v_query := v_query || ' AND A.MOBILE = ENCRYPT(''' || N_MOBILE || ''')';
        END IF;
        
        IF N_CUST_WEB_ID IS NOT NULL THEN
          v_query := v_query || ' AND A.CUST_WEB_ID = ''' || N_CUST_WEB_ID || '''';
        END IF;
          
        IF N_CARD_ID IS NOT NULL THEN
          v_query := v_query || ' AND EXISTS (SELECT 1 FROM C_CARD WHERE COMP_CD = A.COMP_CD AND CUST_ID = A.CUST_ID AND CARD_ID = ENCRYPT(''' || N_CARD_ID || '''))';
        END IF;
        
        IF N_DI_STR IS NOT NULL THEN
          v_query := v_query || ' AND A.DI_STR = ''' || N_DI_STR || '''';
        END IF;
        
        IF N_EMAIL IS NOT NULL THEN
          v_query := v_query || ' AND A.EMAIL = ''' || N_EMAIL || '''';
        END IF;

        OPEN O_CURSOR FOR v_query;
      END IF;
    END IF;
    
    O_RTN_CD := v_result_cd;
END API_C_CUST_SELECT_ONE_WEB;

/
