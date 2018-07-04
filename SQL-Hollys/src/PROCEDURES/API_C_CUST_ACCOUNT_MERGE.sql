--------------------------------------------------------
--  DDL for Procedure API_C_CUST_ACCOUNT_MERGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_ACCOUNT_MERGE" 
(
  P_USER_ID   IN  VARCHAR2,
  M_CUST_ID   IN  VARCHAR2,
  S_CUST_ID   IN  VARCHAR2,
  O_RTN_CD    OUT VARCHAR2
) IS
  v_sav_pt  number := 0;
  v_sav_mlg  number := 0;
  v_card_id VARCHAR2(100);
  NOT_FOUND_CARD_ID EXCEPTION;
BEGIN   
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-19
    -- API REQUEST   :   HLS_CRM_IF_0024 
    -- Description   :   하나의 DI에 여러 계정이 있는경우 통합하는 작업수행 (미사용)
    -- ==========================================================================================
    
    -- 1.메인회원정보의 멤버쉽 카드번호정보 확인
    SELECT 
      CARD_ID INTO v_card_id
    FROM C_CARD 
    WHERE CUST_ID = M_CUST_ID 
      AND REP_CARD_YN = 'Y'
      AND USE_YN = 'Y';
    
    IF v_card_id IS NULL THEN
      RAISE NOT_FOUND_CARD_ID; 
    END IF;
    
    -- 2. 통합대상의 카드정보를 메인 CUST_ID로 교체한다
    FOR CUST IN (
                SELECT
                  A.CARD_ID
                FROM C_CARD A
                WHERE CUST_ID = S_CUST_ID
                )
    LOOP
      UPDATE C_CARD SET
        CARD_STAT = DECODE(REP_CARD_YN, 'Y', '99', CARD_STAT)
        , USE_YN = DECODE(REP_CARD_YN, 'Y', 'N', USE_YN)
        , UPD_DT = SYSDATE
        , UPD_USER = P_USER_ID
        , REISSUE_RSN = '계정통합으로인한 고객번호이전'
      WHERE CARD_ID = CUST.CARD_ID;
    END LOOP;
    
    -- 통합이 완료되고 남은 계정은 탈퇴처리한다.
    UPDATE C_CUST SET
      CUST_STAT = '9'
      ,LEAVE_RMK = '계정통합으로 인한 탈퇴처리'
      ,MOBILE=''          -- 통합되고난 후 휴대폰번호 NULL처리
      ,DI_STR=''
      ,USE_YN='N'
      ,UPD_DT = SYSDATE
      ,UPD_USER = P_USER_ID
    WHERE COMP_CD = '016'
      AND BRAND_CD = '100'
      AND CUST_ID = S_CUST_ID;
    
    -- 성공결과처리
    O_RTN_CD := '1';
EXCEPTION
    WHEN NOT_FOUND_CARD_ID THEN
      O_RTN_CD := '210'; -- 카드정보가 없습니다
      ROLLBACK;
END;

/
