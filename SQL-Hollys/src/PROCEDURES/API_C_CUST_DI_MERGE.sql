--------------------------------------------------------
--  DDL for Procedure API_C_CUST_DI_MERGE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_DI_MERGE" 
(
  P_USER_ID   IN  VARCHAR2,
  P_M_CUST_ID   IN  VARCHAR2,
  P_S_CUST_ID   IN  VARCHAR2,
  O_RTN_CD    OUT VARCHAR2
) IS
  V_DI_STR  CHAR(64);
  v_sav_pt NUMBER := 0;
  v_sav_mlg NUMBER := 0;
  v_card_id VARCHAR2(100);
  NOT_FOUND_CARD_ID EXCEPTION;
BEGIN 
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-01-19
    -- API REQUEST   :   HLS_CRM_IF_0024
    -- Description   :   하나의 DI에 여러 계정이 있는경우 통합하는 작업수행
    --                    2018-03-14 김우진 수정
    --                    여러개일때를 고려하여 처리
    --                    대표카드는 선택카드로 하고 나머지는 폐기
    --                    이력(포인트, 왕관)은 합쳐주기
    --                    등급은 제일 높은것으로 혹은 재조정
    -- ==========================================================================================
      
    -- 1.메인회원정보의 멤버쉽 카드번호 획득
    SELECT 
      CARD_ID INTO v_card_id
    FROM C_CARD 
    WHERE CUST_ID = P_M_CUST_ID 
      AND REP_CARD_YN = 'Y'
      AND USE_YN='Y';
    
    SELECT  DI_STR
    INTO    V_DI_STR
    FROM    C_CUST
    WHERE   CUST_ID = P_M_CUST_ID;
    
    IF v_card_id IS NULL OR V_DI_STR IS NULL THEN
      RAISE NOT_FOUND_CARD_ID; 
    END IF;
    
    -- 2.통합되고 사라질 계정의 정보가 휴면테이블에 있을경우 우선 회원정보로 정보 이관
    INSERT  INTO  C_CUST
    SELECT  *
    FROM    C_CUST_REST
    WHERE   CUST_ID IN  (
                                SELECT  CUST_ID
                                FROM    C_CUST
                                WHERE   DI_STR = V_DI_STR
                        );
    
    -- 3.카드정보통합
    -- 멤버십카드는 사용중지 처리 함
    UPDATE  C_CARD
    SET     CUST_ID = P_M_CUST_ID,
            USE_YN  = CASE  WHEN  REP_CARD_YN = 'Y'       -- 멤버십 카드는 사용 정지 처리
                            THEN  'N'
                            ELSE  'Y'                     -- 멤버십카드가 아니면 명의만 변경
                      END,
            DISUSE_DT  = CASE  WHEN  REP_CARD_YN = 'Y'    -- 멤버쉽카드는 폐기일 설정 
                               THEN  TO_CHAR(SYSDATE, 'YYYYMMDD')
                               ELSE  ''                     
                         END
    WHERE   CUST_ID IN  (                                 -- 메인 외 다른 계정의 카드를 검색
                                SELECT  CUST_ID
                                FROM    C_CUST
                                WHERE   DI_STR = V_DI_STR
                                AND     CUST_ID <> P_M_CUST_ID
                        );
                        
    UPDATE  C_CUST                                        -- 최대 레벨을 적용
    SET     LVL_CD  = (
                              SELECT  MAX(LVL_CD)
                              FROM    C_CUST
                              WHERE   DI_STR = V_DI_STR
                      )
            ,DEGRADE_YN = 'Y'
            ,LVL_CHG_DT = SYSDATE
    WHERE   CUST_ID = P_M_CUST_ID;
    
    -- 4.통합이 완료되고 남은 계정은 탈퇴처리한다.
    UPDATE C_CUST SET
      CUST_STAT = '9'
      ,LEAVE_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
      ,LEAVE_RMK = '계정통합으로 인한 탈퇴처리'
      ,MOBILE=''          -- 통합되고난 후 휴대폰번호 NULL처리
      ,DI_STR=''
      ,USE_YN='N'
      ,UPD_DT = SYSDATE
      ,UPD_USER = P_USER_ID
    WHERE   CUST_ID IN  (                                 -- 메인 외 다른 계정
                                SELECT  CUST_ID
                                FROM    C_CUST
                                WHERE   DI_STR = V_DI_STR
                                AND     CUST_ID <> P_M_CUST_ID
                        );
                        
      -- 20180524 손영재 추가 작업  사유 : 김수련과장 요청 내용 :  아이디 통합 시 쿠폰 정보 이관
      UPDATE PROMOTION_COUPON     
      SET CUST_ID = P_M_CUST_ID
      WHERE   CUST_ID IN  (                                 -- 메인 외 다른 계정
                                SELECT  CUST_ID
                                FROM    C_CUST
                                WHERE   DI_STR = V_DI_STR
                                AND     CUST_ID <> P_M_CUST_ID
                        );
      
      -- 20180524 손영재 추가 작업  사유 : 김수련과장 요청 내용 :  아이디 통합 시 쿠폰 정보 이관
      UPDATE PROMOTION_COUPON_HIS
      SET CUST_ID = P_M_CUST_ID
      WHERE   CUST_ID IN  (                                 -- 메인 외 다른 계정
                                SELECT  CUST_ID
                                FROM    C_CUST
                                WHERE   DI_STR = V_DI_STR
                                AND     CUST_ID <> P_M_CUST_ID
                        );
                        
                        
                      
      
    -- 성공결과처리
    O_RTN_CD := '1';
EXCEPTION
    WHEN NOT_FOUND_CARD_ID THEN
      O_RTN_CD := '210'; -- 카드정보가 없습니다
      ROLLBACK;
END API_C_CUST_DI_MERGE;

/
