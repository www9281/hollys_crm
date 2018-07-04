--------------------------------------------------------
--  DDL for Procedure API_C_CUST_PW_CHANGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_PW_CHANGE" 
(
  P_CUST_ID     IN  VARCHAR2,
  N_BE_CUST_PW  IN  VARCHAR2,
  N_AF_CUST_PW  IN  VARCHAR2,
  P_MOD_USER_ID IN  VARCHAR2,
  O_RTN_CD      OUT VARCHAR2
) IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-27
    -- API REQUEST   :   HLS_CRM_IF_0061
    -- Description   :   회원 비밀번호 변경
    -- ==========================================================================================
    O_RTN_CD := '1';
      
    IF N_BE_CUST_PW IS NULL AND N_AF_CUST_PW IS NULL THEN
      -- 비밀번호 변경기간 연장
      UPDATE C_CUST SET
        LAST_CHG_PWD = SYSDATE
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MOD_USER_ID
      WHERE COMP_CD = '016'
        AND BRAND_CD = '100'
        AND CUST_ID = P_CUST_ID
        AND USE_YN = 'Y';
    ELSIF N_BE_CUST_PW IS NULL AND N_AF_CUST_PW IS NOT NULL THEN    
      -- 비밀번호 신규설정
      UPDATE C_CUST SET
        CUST_PW = FN_SHAENCRYPTOR(N_AF_CUST_PW)
        ,LAST_CHG_PWD = SYSDATE
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MOD_USER_ID
      WHERE COMP_CD = '016'
        AND BRAND_CD = '100'
        AND CUST_ID = P_CUST_ID
        AND USE_YN = 'Y';
      
    ELSIF N_BE_CUST_PW IS NOT NULL AND N_AF_CUST_PW IS NOT NULL THEN
      -- 비밀번호 변경
      UPDATE C_CUST SET
        CUST_PW = FN_SHAENCRYPTOR(N_AF_CUST_PW)
        ,LAST_CHG_PWD = SYSDATE
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MOD_USER_ID
      WHERE COMP_CD = '016'
        AND BRAND_CD = '100'
        AND CUST_ID = P_CUST_ID
        AND CUST_PW = FN_SHAENCRYPTOR(N_BE_CUST_PW)
        AND USE_YN = 'Y';
      
      IF SQL%ROWCOUNT < 1 THEN
        Dbms_Output.Put_Line('패스워드가 일치하지 않습니다.');
        O_RTN_CD := '350';
      END IF;
    ELSE 
      -- 맞는 케이스없음 오류 RETURN
      O_RTN_CD := '190';
    END IF;
    

END API_C_CUST_PW_CHANGE;

/
