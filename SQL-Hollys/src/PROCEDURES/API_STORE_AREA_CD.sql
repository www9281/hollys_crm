--------------------------------------------------------
--  DDL for Procedure API_STORE_AREA_CD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_STORE_AREA_CD" (
    P_NATION_CD IN  VARCHAR2,
    N_SIDO_CD   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-07
    -- Description   :   API 홈페이지 매장지역코드 조회
    -- ==========================================================================================
    
    IF P_NATION_CD = '01' THEN
      -- 해외
      OPEN O_CURSOR FOR
      SELECT
        NATION_CD AS CODE_CD
        , NATION_NM AS CODE_NM
      FROM L_NATION;
    ELSIF P_NATION_CD = '00' THEN
      -- 국내
      IF N_SIDO_CD IS NULL THEN
        -- 시도목록 조회
        OPEN O_CURSOR FOR
        SELECT
          REGION_CD AS CODE_CD
          , REGION_NM AS CODE_NM
        FROM REGION
        WHERE CITY_CD = '000';
      ELSE
        -- 지역구 목록 조회
        OPEN O_CURSOR FOR
        SELECT
          REGION_CD AS CODE_CD
          , REGION_NM AS CODE_NM
        FROM REGION
        WHERE CITY_CD = N_SIDO_CD;
      END IF;
    END IF;
    
END API_STORE_AREA_CD;

/
