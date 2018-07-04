--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SELECT" (
    P_COMP_CD       IN  VARCHAR2,
    P_PAGE_NO       IN  VARCHAR2,
    P_PAGE_SIZE     IN  VARCHAR2,
    N_DEVICE_DIV    IN  VARCHAR2,
    N_DEVICE_NM     IN  VARCHAR2,
    N_MOBILE_LIST   IN  VARCHAR2,
    N_ALERT_DIV     IN  VARCHAR2,
    O_RTN_CD        OUT VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_result_cd VARCHAR2(7) := '1';
    v_query     VARCHAR2(30000);
    v_tel_str   VARCHAR2(20000);
BEGIN  
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-30
    -- Description   :   POS API용 멤버쉽 회원관리 회원목록 조회
    -- ==========================================================================================
    IF N_MOBILE_LIST IS NOT NULL THEN
      v_tel_str := replace(N_MOBILE_LIST, ',', ''',''');
    END IF;
    
    v_query := '
    SELECT T.* FROM(
      SELECT A.*, ROWNUM AS RNUM FROM(
        SELECT
          CUST.*
        FROM (
              SELECT
                CUST.CUST_ID
                ,CUST.CUST_WEB_ID
                ,DECRYPT(CUST.MOBILE) AS MOBILE
                ,CD.DEVICE_DIV
                ,CD.DEVICE_NM
                ,CD.AUTH_ID
                ,CD.AUTH_TOKEN
                ,NVL((SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = CUST.CUST_ID AND DIV_NM = ''couponEnd''), ''Y'') AS COUPON_END_YN
                ,NVL((SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = CUST.CUST_ID AND DIV_NM = ''membershipCoupon''), ''Y'') AS MEMBERSHIP_COUPON_YN
                ,NVL((SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = CUST.CUST_ID AND DIV_NM = ''promotion''), ''Y'') AS PROMOTION_EVENT_YN
              FROM C_CUST CUST, C_CUST_DEVICE CD
              WHERE CUST.COMP_CD = ''' || P_COMP_CD || '''
                AND CUST.BRAND_CD = ''100''
                AND CUST.CUST_ID = CD.CUST_ID
                AND CUST.USE_YN = ''Y''
                AND CUST.CUST_STAT = ''2''
                AND CD.USE_YN = ''Y''
                AND (''' || N_DEVICE_DIV || ''' IS NULL OR CD.DEVICE_DIV = ''' || N_DEVICE_DIV || ''')
                AND (''' || N_DEVICE_NM || ''' IS NULL OR CD.DEVICE_NM = ''' || N_DEVICE_NM || ''')
                ';
              
    IF N_MOBILE_LIST IS NOT NULL THEN
      v_query := v_query || '
                AND DECRYPT(MOBILE) IN (''' || v_tel_str || ''')';
    END IF;
    
              
    v_query := v_query || '
        ) CUST
        WHERE 1=1';
    
    IF N_ALERT_DIV = '1' THEN
      v_query := v_query || '
          AND CUST.COUPON_END_YN = ''Y''';
    ELSIF N_ALERT_DIV = '2' THEN
      v_query := v_query || '
          AND MEMBERSHIP_COUPON_YN = ''Y''';
    ELSIF N_ALERT_DIV = '3' THEN
      v_query := v_query || '
          AND PROMOTION_EVENT_YN = ''Y''';
    END IF;
    
    v_query := v_query || '
      )A WHERE ROWNUM <= ''' || P_PAGE_NO || ''' * ''' || P_PAGE_SIZE || '''
    )T WHERE T.RNUM >= (''' || P_PAGE_NO || ''' - 1) * ''' || P_PAGE_SIZE || ''' + 1
    ';
    
    DBMS_OUTPUT.put_line(v_query);
    OPEN O_CURSOR FOR v_query;
    
    O_RTN_CD := v_result_cd;
END API_C_CUST_SELECT;

/
