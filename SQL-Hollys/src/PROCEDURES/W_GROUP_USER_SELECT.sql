--------------------------------------------------------
--  DDL for Procedure W_GROUP_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_USER_SELECT" (
    N_USER_ID   IN  VARCHAR2, 
    O_CURSOR    OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-01
    -- Description   :   사용자 그룹설정을 위한 사용자 리스트 조회
    -- Test          :   W_GROUP_USER_SELECT ('level_10')
    -- ==========================================================================================
    v_query := 
              '
              SELECT
                COMP_CD,USER_ID,USER_NM,PWD,PWD_CHG_YN,PWD_CHG_DT,BRAND_CD,(SELECT BRAND_NM FROM BRAND WHERE BRAND_CD = A.BRAND_CD) AS BRAND_NM
                ,GET_COMMON_CODE_NM(''00600'', A.DEPT_CD) AS DEPT_NM ,DEPT_CD,TEAM_CD,GET_COMMON_CODE_NM(''00605'', TEAM_CD) AS TEAM_NM, POSITION_CD,USER_DIV,DUTY_CD,WEB_AUTH_CD,MST_ORG_CD,MNG_CARD_ID,TEL_NO,MOBILE_NO,E_MAIL,ZIP_CD,ADDR1,ADDR2
                ,NATION_CD,REGION_NO,LANGUAGE_TP,LOGIN_DTM,LOGIN_PERM_YN,LOGIN_FAIL_CNT,START_DT,USE_YN,ERP_USER_ID,GROUP_NO,INST_USER,UPD_DT,UPD_USER
              FROM HQ_USER A
              WHERE (''' || N_USER_ID || ''' IS NULL OR USER_ID = ''' || N_USER_ID || ''')
              ';
            
    OPEN O_CURSOR FOR v_query;
      
END W_GROUP_USER_SELECT;

/
