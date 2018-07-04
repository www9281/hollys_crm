--------------------------------------------------------
--  DDL for Procedure BRAND_STOR_TP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BRAND_STOR_TP" (
    N_BRAND_CD  IN  VARCHAR2,
    N_STOR_TP   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) IS
    v_query varchar(20000);
BEGIN
    v_query := 
           'SELECT
              STOR_NM     -- 매장명
              ,STOR_TP    -- 매장구분코드 (직영, 가맹)
              ,STOR_CD    -- 매장코드
              ,SIDO_CD    -- 지역
              ,SV_USER_ID -- 담당자
            FROM STORE
            WHERE STOR_TP = ''' || N_STOR_TP || '''';
        IF N_BRAND_CD IS NOT NULL THEN
          v_query := v_query ||
             'AND BRAND_CD =''' || N_BRAND_CD || '''';
        END IF;
        
    OPEN O_CURSOR FOR v_query;
END BRAND_STOR_TP;

/
