--------------------------------------------------------
--  DDL for Procedure C_CARD_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_SELECT" (
    N_STOR_CD     IN  VARCHAR2,
    N_CUST_ID     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    ----------------------- 카드 검색 -----------------------
    v_query := 
          'SELECT 
            DECRYPT(A.CARD_ID) CARD_ID -- 카드번호
            , TO_CHAR(TO_DATE(ISSUE_DT, ''YYYYMMDDHH24MISS''), ''YYYY-MM-DD'') ISSUE_DT -- 등록일
            , C.STOR_CD   -- 등록매장코드
            , C.STOR_NM   -- 등록매장명
            , B.MEMB_DIV  -- 멤버쉽구분코드
            , B.CARD_STAT -- 카드상태코드
            , GET_COMMON_CODE_NM(''01725'', B.CARD_STAT) MEMB_DIV_NM  -- 카드상태
            -- 카드 종류
            -- 유효 왕관
            -- 유효 포인트
            -- 카드 잔액
            , B.DISP_YN
          FROM C_CUST A, C_CARD B, STORE C
          WHERE A.CUST_ID = B.CUST_ID
            AND B.STOR_CD = C.STOR_CD (+)';
      IF N_STOR_CD IS NOT NULL THEN
        v_query := v_query ||
          ' AND C.STOR_CD = ''' || N_STOR_CD || '''';
      END IF;
      
      IF N_CUST_ID IS NOT NULL THEN
        v_query := v_query ||
          ' AND A.CUST_ID = ''' || N_CUST_ID || '''';
      END IF;
    
    OPEN O_CURSOR FOR v_query;
      
END C_CARD_SELECT;

/
