--------------------------------------------------------
--  DDL for Procedure C_STORE_POP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_STORE_POP_SELECT" (
    N_BRAND_CD    IN  VARCHAR2,
    N_STOR_TP     IN  VARCHAR2,
    N_TEAM_CD     IN  VARCHAR2,
    N_SC_USER_ID  IN  VARCHAR2,
    N_STOR_CD     IN  VARCHAR2,
    N_LANGUAGE_TP IN  VARCHAR2,
    N_USER_ID     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    ----------------------- 매장 검색 공통팝업 조회 -----------------------
    OPEN O_CURSOR FOR
    SELECT
      STOR_CD                                                       -- 점포코드
      , STOR_NM                                                     -- 점포명
      , (SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) AS BRAND_CD
      , STOR_TP                                                     -- 가맹유형
      , GET_COMMON_CODE_NM('00565', STOR_TP, 'KOR') AS STOR_TP_NM                 -- 가맹유형명
      , A.SIDO_CD
      , A.REGION_CD
      , (SELECT REGION_NM FROM REGION WHERE REGION_CD = A.REGION_CD) AS REGION_NM -- 지역
      , (SELECT USER_NM FROM HQ_USER WHERE USER_ID = SV_USER_ID) AS SV_USER_ID    -- 담당 SC
      , APP_DIV                                                     -- 운영상태
    FROM STORE A 
    WHERE (TRIM(N_BRAND_CD) IS NULL OR A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = N_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y'))                                                                      )
      AND ((N_STOR_TP IS NULL AND A.STOR_TP IN ('10', '20')) OR A.STOR_TP = N_STOR_TP)
      AND (N_TEAM_CD IS NULL OR A.TEAM_CD = N_TEAM_CD)
      AND (N_SC_USER_ID IS NULL OR A.SV_USER_ID = N_SC_USER_ID)
      AND (TRIM(N_STOR_CD) IS NULL OR A.STOR_CD LIKE '%' || TRIM(N_STOR_CD) || '%' OR A.STOR_NM LIKE '%' || TRIM(N_STOR_CD) || '%')
      AND A.USE_YN = 'Y'
      ORDER BY STOR_CD ASC; 
      
END C_STORE_POP_SELECT;

/
