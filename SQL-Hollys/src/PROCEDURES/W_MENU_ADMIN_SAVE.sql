--------------------------------------------------------
--  DDL for Procedure W_MENU_ADMIN_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_ADMIN_SAVE" (
    P_MENU_NM     IN VARCHAR2,
    P_MENU_CD     IN VARCHAR2,
    P_DEPTH       IN VARCHAR2,
    P_MENU_IDX    IN VARCHAR2,
    P_MENU_DIV    IN VARCHAR2,
    P_USE_YN      IN VARCHAR2,
    P_PROG_NM     IN VARCHAR2,
    P_MENU_REF    IN VARCHAR2, 
    P_LANGUAGE_CD IN VARCHAR2,
    P_MY_USER_ID	IN VARCHAR2
)IS
    v_kor_nm  VARCHAR2(50) := '';
    v_eng_nm  VARCHAR2(50) := '';
    v_chn_nm  VARCHAR2(50) := '';
    v_frn_nm  VARCHAR2(50) := '';
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-23
    -- Description   :   관리자 메뉴관리 메뉴저장
    -- ==========================================================================================
    
    -- 선택 국가에 맞는 메뉴명 설정
    IF P_LANGUAGE_CD = 'K' THEN
      v_kor_nm := P_MENU_NM;
    ELSIF P_LANGUAGE_CD = 'E' THEN
      v_eng_nm := P_MENU_NM;
    ELSIF P_LANGUAGE_CD = 'C' THEN
      v_chn_nm := P_MENU_NM;
    ELSIF P_LANGUAGE_CD = 'F' THEN
      v_frn_nm := P_MENU_NM;
    END IF;
    
    MERGE INTO W_MENU A
    USING DUAL
    ON (A.MENU_CD = P_MENU_CD)
    WHEN MATCHED THEN
      UPDATE SET
        MENU_NM_KOR = v_kor_nm
        ,MENU_NM_ENG = v_eng_nm
        ,MENU_NM_CHN = v_chn_nm
        ,MENU_NM_FRN = v_frn_nm
        ,DEPTH = P_DEPTH
        ,MENU_IDX = P_MENU_IDX
        ,MENU_DIV = P_MENU_DIV
        ,USE_YN = P_USE_YN
        ,PROG_NM = P_PROG_NM
        ,MENU_REF = P_MENU_REF
        ,UPD_USER_NO = P_MY_USER_ID
        ,UPD_DT = SYSDATE
    WHEN NOT MATCHED THEN
      INSERT (
        MENU_CD
        ,MENU_NM_KOR
        ,MENU_NM_ENG
        ,MENU_NM_CHN
        ,MENU_NM_FRN
        ,DEPTH
        ,MENU_IDX
        ,MENU_DIV
        ,USE_YN
        ,PROG_NM
        ,MENU_REF
        ,INS_USER_NO
        ,INS_DT
      ) VALUES (
        P_MENU_CD
        ,v_kor_nm
        ,v_eng_nm
        ,v_chn_nm
        ,v_frn_nm
        ,P_DEPTH
        ,P_MENU_IDX
        ,P_MENU_DIV
        ,P_USE_YN
        ,P_PROG_NM
        ,P_MENU_REF
        ,P_MY_USER_ID
        ,SYSDATE
      )
      ;
      
END W_MENU_ADMIN_SAVE;

/
