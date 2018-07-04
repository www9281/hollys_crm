--------------------------------------------------------
--  DDL for Procedure C_CUST_POP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_POP_SELECT" (
    N_CUST_NM       IN  VARCHAR2,
    N_CUST_ID       IN  VARCHAR2,
    N_CUST_WEB_ID   IN  VARCHAR2,
    N_MOBILE        IN  VARCHAR2,
    N_CARD_ID       IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
   v_query  VARCHAR2(30000);
BEGIN
    ----------------------- 회원 검색 공통팝업 조회 -----------------------
    
    v_query := '
      SELECT  
        A.BRAND_CD             AS BRAND_CD
        , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) AS BRAND_NM
        , DECRYPT(A.CUST_NM)    AS CUST_NM
        , A.CUST_ID             AS CUST_ID
        , A.CUST_WEB_ID         AS CUST_WEB_ID
        , DECRYPT(A.MOBILE)     AS MOBILE
        , DECRYPT(B.CARD_ID)    AS CARD_ID
        , BIRTH_DT
        , GET_COMMON_CODE_NM(''00315'', A.SEX_DIV, ''KOR'') AS SEX_DIV
        , A.EMAIL
        , A.EMAIL_RCV_YN
        , (SELECT LVL_NM FROM C_CUST_LVL WHERE LVL_CD = A.LVL_CD) AS CUST_LVL
      FROM C_CUST A, C_CARD B
      WHERE A.CUST_ID = B.CUST_ID (+)
    ';
    
    IF N_CUST_NM IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_NM = ENCRYPT(''' || TRIM(N_CUST_NM) || ''')';
    END IF;
    
    IF N_CUST_ID IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_ID = ''' || TRIM(N_CUST_ID) || '''';
    END IF;
    
    IF N_CUST_WEB_ID IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_WEB_ID = ''' || TRIM(N_CUST_WEB_ID) || '''';
    END IF;
    
    IF N_MOBILE IS NOT NULL THEN
      v_query := v_query || ' AND A.MOBILE = ENCRYPT(REPLACE(''' || TRIM(N_MOBILE) || ''', ''-'', ''''))';
    END IF;
    
    IF N_CARD_ID IS NOT NULL THEN
      v_query := v_query || ' AND B.CARD_ID = ENCRYPT(''' || TRIM(N_CARD_ID) || ''')';
    END IF;
    
    v_query := v_query || '
      AND A.USE_YN = ''Y''
      AND B.USE_YN(+) = ''Y''
      AND B.REP_CARD_YN (+) = ''Y''
      UNION ALL
      SELECT  
        A.BRAND_CD             AS BRAND_CD
        , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) AS BRAND_NM
        , DECRYPT(A.CUST_NM)    AS CUST_NM
        , A.CUST_ID             AS CUST_ID
        , A.CUST_WEB_ID         AS CUST_WEB_ID
        , DECRYPT(A.MOBILE)     AS MOBILE
        , DECRYPT(B.CARD_ID)    AS CARD_ID
        , BIRTH_DT
        , GET_COMMON_CODE_NM(''00315'', A.SEX_DIV, ''KOR'') AS SEX_DIV
        , A.EMAIL
        , A.EMAIL_RCV_YN
        , (SELECT LVL_NM FROM C_CUST_LVL WHERE LVL_CD = A.LVL_CD) AS CUST_LVL
      FROM C_CUST_REST A, C_CARD B
      WHERE A.CUST_ID = B.CUST_ID (+)
    ';
    
    IF N_CUST_NM IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_NM = ENCRYPT(''' || TRIM(N_CUST_NM) || ''')';
    END IF;
    
    IF N_CUST_ID IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_ID = ''' || TRIM(N_CUST_ID) || '''';
    END IF;
    
    IF N_CUST_WEB_ID IS NOT NULL THEN
      v_query := v_query || ' AND A.CUST_WEB_ID = ''' || TRIM(N_CUST_WEB_ID) || '''';
    END IF;
    
    IF N_MOBILE IS NOT NULL THEN
      v_query := v_query || ' AND A.MOBILE = ENCRYPT(REPLACE(''' || TRIM(N_MOBILE) || ''', ''-'', ''''))';
    END IF;
    
    IF N_CARD_ID IS NOT NULL THEN
      v_query := v_query || ' AND B.CARD_ID = ENCRYPT(''' || TRIM(N_CARD_ID) || ''')';
    END IF;
    
    dbms_output.put_line('v_query' || v_query);
    OPEN O_CURSOR FOR v_query;
END C_CUST_POP_SELECT;

/
