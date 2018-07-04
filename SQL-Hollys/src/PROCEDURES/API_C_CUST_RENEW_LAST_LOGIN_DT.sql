--------------------------------------------------------
--  DDL for Procedure API_C_CUST_RENEW_LAST_LOGIN_DT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_RENEW_LAST_LOGIN_DT" (
      P_COMP_CD       IN  VARCHAR2,
      P_STOR_CD       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
      P_CUST_ID       IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      N_REST_USER_YN  IN  VARCHAR2,
      O_RTN_CD        OUT VARCHAR2,
      O_CURSOR        OUT SYS_REFCURSOR
) IS
      v_result_cd VARCHAR2(7) := '1';
      v_cust_cnt NUMBER;
BEGIN 
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-15
      -- API REQUEST   :   미정 
      -- Description   :   사용자 마지막 로그인 일자 갱신
      -- ==========================================================================================
      IF N_REST_USER_YN IS NULL OR N_REST_USER_YN = 'N' THEN
          -- 1.휴먼회원이 아닌 대상자의 마지막 로그인 일자를 갱신
          SELECT  
            COUNT(1) AS CNT
            INTO v_cust_cnt
          FROM C_CUST CUST
          WHERE CUST.COMP_CD = P_COMP_CD
            AND CUST.STOR_CD = P_STOR_CD
            AND CUST.BRAND_CD = P_BRAND_CD
            AND CUST.CUST_ID = P_CUST_ID;
            
          IF v_cust_cnt > 0 THEN
            -- 1-1.최종 로그인 일자 갱신
            UPDATE C_CUST SET
              LAST_LOGIN_DT = SYSDATE
              , UPD_DT = SYSDATE
              , UPD_USER = P_USER_ID
            WHERE COMP_CD = P_COMP_CD
            AND STOR_CD = P_STOR_CD
            AND BRAND_CD = P_BRAND_CD
            AND CUST_ID = P_CUST_ID;
          ELSE
            -- 요청 대상자를 찾을 수 없습니다.
            v_result_cd := '170';
          END IF;
      ELSIF N_REST_USER_YN = 'Y' THEN
          -- 2.휴먼회원이 다시 로그인을 할 경우
          SELECT
            COUNT(1) AS CNT
            INTO v_cust_cnt
          FROM C_CUST_REST CUST
          WHERE CUST.COMP_CD = P_COMP_CD
            AND CUST.STOR_CD = P_STOR_CD
            AND CUST.BRAND_CD = P_BRAND_CD
            AND CUST.CUST_ID = P_CUST_ID;
            
          IF v_cust_cnt > 0 THEN
            -- 2-1.마지막 로그인 일자 갱신
            UPDATE C_CUST_REST SET
              LAST_LOGIN_DT = SYSDATE
              , UPD_DT = SYSDATE
              , UPD_USER = P_USER_ID
            WHERE COMP_CD = P_COMP_CD
            AND STOR_CD = P_STOR_CD
            AND BRAND_CD = P_BRAND_CD
            AND CUST_ID = P_CUST_ID;
            
            -- 2-2.회원 테이블에 데이터 복사
            INSERT INTO C_CUST
            SELECT * FROM C_CUST_REST CUST
            WHERE CUST.COMP_CD = P_COMP_CD
              AND CUST.STOR_CD = P_STOR_CD
              AND CUST.BRAND_CD = P_BRAND_CD
              AND CUST.CUST_ID = P_CUST_ID;
               
            -- 2-3.휴면계정 정보 삭제   
            DELETE FROM C_CUST_REST
            WHERE COMP_CD = P_COMP_CD
              AND STOR_CD = P_STOR_CD
              AND BRAND_CD = P_BRAND_CD
              AND CUST_ID = P_CUST_ID;
          ELSE
            -- 요청 대상자를 찾을 수 없습니다.
            v_result_cd := '170';
          END IF;
      ELSE 
        -- N_REST_USER_YN(휴면계정여부)가 [NULL, N, Y] 값이 아닐 경우 오류
        v_result_cd := '2';
      END IF;
      
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
END API_C_CUST_RENEW_LAST_LOGIN_DT;

/
