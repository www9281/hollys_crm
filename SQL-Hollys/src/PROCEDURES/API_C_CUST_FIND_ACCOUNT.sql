--------------------------------------------------------
--  DDL for Procedure API_C_CUST_FIND_ACCOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_FIND_ACCOUNT" 
(
  P_F_TYPE        IN   VARCHAR2,
  N_CUST_NM       IN   VARCHAR2,
  N_EMAIL         IN   VARCHAR2,
  N_MOBILE        IN   VARCHAR2,
  N_CUST_WEB_ID   IN   VARCHAR2,
  N_DI_STR        IN   VARCHAR2,
  O_RTN_CD        OUT  VARCHAR2,
  O_CURSOR        OUT  SYS_REFCURSOR
) IS
  v_cust_cnt  NUMBER;
  REQ_EXCEPTION EXCEPTION;
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-27
    -- API REQUEST   :   HLS_CRM_IF_0062
    -- Description   :   회원 아이디찾기
    -- ==========================================================================================
     
    IF P_F_TYPE != 'ID' AND P_F_TYPE != 'PWD' THEN
      RAISE REQ_EXCEPTION;
    END IF;
    
    -- 1.아이디 찾기
    IF P_F_TYPE = 'ID' THEN
      BEGIN
        -- 이름, 이메일
        -- 이름, 핸드폰번호
        -- DI
        IF (N_CUST_NM IS NULL OR N_EMAIL IS NULL) AND (N_CUST_NM IS NULL OR N_MOBILE IS NULL) AND N_DI_STR IS NULL THEN
          RAISE REQ_EXCEPTION;
        END IF;
        
        IF N_CUST_NM IS NOT NULL AND N_EMAIL IS NOT NULL THEN
          OPEN O_CURSOR FOR
          SELECT
            CUST_ID, CUST_WEB_ID
          FROM (SELECT * 
                FROM C_CUST 
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND EMAIL = N_EMAIL
                  AND USE_YN = 'Y'
                UNION ALL 
                SELECT * 
                FROM C_CUST_REST
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND EMAIL = N_EMAIL
                  AND USE_YN = 'Y')
          ORDER BY CUST_WEB_ID ASC NULLS LAST
          ;
        ELSIF N_CUST_NM IS NOT NULL AND N_MOBILE IS NOT NULL THEN
          OPEN O_CURSOR FOR
          SELECT
            CUST_ID, CUST_WEB_ID
          FROM (SELECT * 
                FROM C_CUST 
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND MOBILE = ENCRYPT(N_MOBILE)
                  AND USE_YN = 'Y'
                UNION ALL 
                SELECT * 
                FROM C_CUST_REST
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND MOBILE = ENCRYPT(N_MOBILE)
                  AND USE_YN = 'Y')
          ORDER BY CUST_WEB_ID ASC NULLS LAST;
        ELSIF N_DI_STR IS NOT NULL THEN
          OPEN O_CURSOR FOR
          SELECT
            CUST_ID, CUST_WEB_ID
          FROM (SELECT * 
                FROM C_CUST 
                WHERE DI_STR = N_DI_STR
                  AND USE_YN = 'Y'
                UNION ALL 
                SELECT * 
                FROM C_CUST_REST
                WHERE DI_STR = N_DI_STR
                  AND USE_YN = 'Y')
          ORDER BY CUST_WEB_ID ASC NULLS LAST;
        END IF;

      END;
    END IF;
    
    -- 2.패스워드 확인
    IF P_F_TYPE = 'PWD' THEN
      BEGIN
        -- 이름, 아이디, 이메일
        -- 아이디, DI
        IF (N_CUST_NM IS NULL OR N_CUST_WEB_ID IS NULL OR N_EMAIL IS NULL) AND (N_CUST_NM IS NULL OR N_DI_STR IS NULL) THEN
          RAISE REQ_EXCEPTION;
        END IF;

        IF N_CUST_NM IS NOT NULL AND N_CUST_WEB_ID IS NOT NULL AND N_EMAIL IS NOT NULL THEN
          OPEN O_CURSOR FOR
          SELECT
            CUST_ID, CUST_WEB_ID
          FROM (SELECT * 
                FROM C_CUST 
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND CUST_WEB_ID = N_CUST_WEB_ID
                  AND EMAIL = N_EMAIL
                  AND USE_YN = 'Y'
                UNION ALL 
                SELECT * 
                FROM C_CUST_REST
                WHERE CUST_NM = ENCRYPT(N_CUST_NM)
                  AND CUST_WEB_ID = N_CUST_WEB_ID
                  AND EMAIL = N_EMAIL
                  AND USE_YN = 'Y')
          ORDER BY CUST_WEB_ID ASC NULLS LAST;
        ELSIF N_CUST_NM IS NULL OR N_DI_STR IS NULL THEN
          OPEN O_CURSOR FOR
          SELECT
            CUST_ID, CUST_WEB_ID
          FROM (SELECT * 
                FROM C_CUST 
                WHERE CUST_WEB_ID = N_CUST_WEB_ID
                  AND DI_STR = N_DI_STR
                  AND USE_YN = 'Y'
                UNION ALL 
                SELECT * 
                FROM C_CUST_REST
                WHERE CUST_WEB_ID = N_CUST_WEB_ID
                  AND DI_STR = N_DI_STR
                  AND USE_YN = 'Y')
          ORDER BY CUST_WEB_ID ASC NULLS LAST;
        END IF;
      END;
    END IF; 
    
    O_RTN_CD := '1';
EXCEPTION
    WHEN REQ_EXCEPTION THEN
        O_RTN_CD  := '191';
END API_C_CUST_FIND_ACCOUNT;

/
