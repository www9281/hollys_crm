--------------------------------------------------------
--  DDL for Procedure API_AREA_STORE_CD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_AREA_STORE_CD" (
    N_SIDO_CD     IN  VARCHAR2,
    N_REGION_CD   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)IS
    v_query VARCHAR2(30000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-19
    -- Description   :   API 홈페이지 지역내 매장코드 조회
    -- ==========================================================================================
    v_query := '
      SELECT
        STOR_CD
        , STOR_NM
      FROM STORE
      WHERE BRAND_CD = ''100''
    ';
    
    IF N_SIDO_CD IS NOT NULL THEN
      v_query := v_query || ' AND SIDO_CD = ''' || N_SIDO_CD || '''';
    END IF;
      
    IF N_REGION_CD IS NOT NULL THEN
      v_query := v_query || ' AND REGION_CD = ''' || N_REGION_CD || '''';
    END IF;
    
    v_query := v_query || '
      ORDER BY STOR_NM
    ';
    
    OPEN O_CURSOR FOR v_query;
END API_AREA_STORE_CD;

/
