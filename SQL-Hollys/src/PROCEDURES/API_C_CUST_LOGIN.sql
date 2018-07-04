--------------------------------------------------------
--  DDL for Procedure API_C_CUST_LOGIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_LOGIN" (
    P_CUST_WEB_ID     IN  VARCHAR2,
    N_CUST_PWD        IN  VARCHAR2,
    N_LOGIN_DIV       IN  VARCHAR2,
    N_LOGIN_IP        IN  VARCHAR2,
    O_CUST_ID         OUT VARCHAR2,
    O_LOGIN_YN        OUT VARCHAR2,
    O_REST_USER_YN    OUT VARCHAR2,
    O_LEAVE_USER_YN   OUT VARCHAR2,
    O_NGT_USER_YN     OUT VARCHAR2,
    O_LOCK_USER_YN    OUT VARCHAR2,
    O_LAST_CHG_DT     OUT VARCHAR2,
    O_LAST_LOGIN_DT   OUT VARCHAR2,
    O_DI_STR_CNT      OUT NUMBER,
    O_RTN_CD          OUT VARCHAR2,
    O_CURSOR          OUT SYS_REFCURSOR
)IS 
    v_result_cd VARCHAR2(7) := '1';
    v_cust_cnt  NUMBER;
    v_rest_cnt  NUMBER;
    v_di_cnt    NUMBER;
    v_di_rest_cnt NUMBER;
    v_cust_pwd  VARCHAR2(50);
    v_cust_di   CHAR(64);
BEGIN   
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-12-22
    -- Description   :   HOMEPAGE API용 고객 로그인
    -- ==========================================================================================
    O_LOGIN_YN        := 'Y';  -- 로그인 성공여부  
    O_REST_USER_YN    := 'N';  -- 휴면 회원 여부
    O_LEAVE_USER_YN   := 'N';  -- 탈퇴 회원 여부
    O_NGT_USER_YN     := 'N';  -- 부정 회원 여부
    O_LOCK_USER_YN    := 'N';  -- 잠김 회원 여부
    O_LAST_CHG_DT     := '';   -- 비밀번호 마지막 변경 일시
    
    
    -- 아이디와 패스워드에 매칭된 회원정보가 있는지 확인
    SELECT
      COUNT(*) INTO v_cust_cnt
    FROM C_CUST
    WHERE CUST_WEB_ID = P_CUST_WEB_ID
      AND USE_YN = 'Y';
    
    IF v_cust_cnt > 0 THEN
      -- 회원정보 조회
      SELECT
        CUST_ID
        , CUST_PW
        , DECODE(CUST_STAT, '9', 'Y', 'N')    -- 탈퇴 회원 여부
        , NVL(NEGATIVE_USER_YN, 'N')          -- 부정 회원 여부
        , LAST_CHG_PWD                        -- 비밀번호 마지막 변경 일시
        , DI_STR                              -- 본인인증DI
        , TO_CHAR(LAST_LOGIN_DT, 'YYYY-MM-DD HH24:MI:SS')
        INTO O_CUST_ID, v_cust_pwd, O_LEAVE_USER_YN, O_NGT_USER_YN, O_LAST_CHG_DT, v_cust_di, O_LAST_LOGIN_DT
      FROM C_CUST
      WHERE CUST_WEB_ID = P_CUST_WEB_ID
        AND USE_YN = 'Y'
        AND ROWNUM = 1;
      
      -- 잠김 회원 여부 확인 
      SELECT
        CASE WHEN NVL(MAX(FAIL_COUNT), 0) >= 5 THEN 'Y'
             ELSE 'N'
        END INTO O_LOCK_USER_YN
      FROM C_CUST_LOGIN_FAIL
      WHERE CUST_ID = O_CUST_ID;
      
      IF N_CUST_PWD IS NULL THEN
        -- 자동로그인 대상자 접속정보 수정
        UPDATE C_CUST SET
          LOGIN_DIV = N_LOGIN_DIV
          ,LOGIN_IP = N_LOGIN_IP
          ,LAST_LOGIN_DT = SYSDATE
        WHERE CUST_ID = O_CUST_ID
        AND USE_YN = 'Y';
        
      ELSIF v_cust_pwd = FN_SHAENCRYPTOR(N_CUST_PWD) THEN
        -- 패스워드 일치 잠김회원이 아닌경우 로그인 진행 ()
        IF O_LOCK_USER_YN = 'N' AND N_LOGIN_DIV IS NOT NULL AND N_LOGIN_IP IS NOT NULL THEN
          -- 로그인 성공!!!
          -- 패스워드 불일치 횟수 초기화
          DELETE FROM C_CUST_LOGIN_FAIL
          WHERE CUST_ID = O_CUST_ID;
          
          -- 로그인 대상자 접속정보 수정
          UPDATE C_CUST SET
            LOGIN_DIV = N_LOGIN_DIV
            ,LOGIN_IP = N_LOGIN_IP
            ,LAST_LOGIN_DT = SYSDATE
          WHERE CUST_WEB_ID = P_CUST_WEB_ID
          AND USE_YN = 'Y';
        
          -- DI 중복데이터 체크(휴면회원 테이블도 조회)
          SELECT
            COUNT(*) INTO v_di_cnt
          FROM C_CUST A
          WHERE A.DI_STR = v_cust_di
            AND A.USE_YN = 'Y';
            
          SELECT
            COUNT(*) INTO v_di_rest_cnt
          FROM C_CUST_REST A
          WHERE A.DI_STR = v_cust_di
            AND A.USE_YN = 'Y';
            
          O_DI_STR_CNT := v_di_cnt + v_di_rest_cnt;
          -- DI 중복데이터가 있을경우 중복 CUST_ID, CUST_WEB_ID 리스트로 묶어서 리턴
          IF v_di_rest_cnt > 0 THEN
            OPEN O_CURSOR FOR
            SELECT
              A.CUST_ID AS DI_CUST_ID, A.CUST_WEB_ID AS DI_CUST_WEB_ID
            FROM C_CUST_REST A
            WHERE A.DI_STR = v_cust_di
              AND A.CUST_ID <> O_CUST_ID
              AND A.USE_YN = 'Y';
          ELSIF O_DI_STR_CNT > 1 THEN
            OPEN O_CURSOR FOR
            SELECT
              A.CUST_ID AS DI_CUST_ID, A.CUST_WEB_ID AS DI_CUST_WEB_ID
            FROM C_CUST A
            WHERE A.DI_STR = v_cust_di
              AND A.CUST_ID <> O_CUST_ID
              AND A.USE_YN = 'Y';
          END IF;
          
          -- DI 중복데이터 체크 끝    
        END IF;
      ELSE 
        IF O_LEAVE_USER_YN != 'Y' AND O_NGT_USER_YN != 'Y' THEN
        -- 패스워드 일치하지않음 실패 횟수 증가
          MERGE INTO C_CUST_LOGIN_FAIL A
          USING DUAL
          ON (A.CUST_ID = O_CUST_ID)
          WHEN MATCHED THEN
            UPDATE SET 
              FAIL_COUNT = FAIL_COUNT + 1
              ,UPD_DT = SYSDATE
          WHEN NOT MATCHED THEN
            INSERT (
              CUST_ID
              ,FAIL_COUNT
            ) VALUES (
              O_CUST_ID
              ,1
            );
        END IF;
        
        -- 패스워드가 일치하지 않습니다.
        v_result_cd := '350';
        O_LOGIN_YN := 'N';
      END IF;
    ELSE
      -- 아이디에 매칭되는 회원이 없는경우 휴면회원 테이블을 조회
      SELECT
        COUNT(*) INTO v_rest_cnt
      FROM C_CUST_REST
      WHERE CUST_WEB_ID = P_CUST_WEB_ID
        --AND CUST_PW = N_CUST_PWD
        AND USE_YN = 'Y';
      
      IF v_rest_cnt > 0 THEN
        O_REST_USER_YN := 'Y';
        
        -- 패스워드체크
        SELECT
          CUST_ID, CUST_PW INTO O_CUST_ID, v_cust_pwd
        FROM C_CUST_REST
        WHERE CUST_WEB_ID = P_CUST_WEB_ID
          AND USE_YN = 'Y';
          
        IF v_cust_pwd <> FN_SHAENCRYPTOR(N_CUST_PWD) OR N_CUST_PWD IS NULL THEN
          v_result_cd := '350';
        END IF;
      ELSE
        -- 회원정보가 존재하지않습니다.
        v_result_cd := '341';
      END IF;
      
      O_LOGIN_YN := 'N';
    END IF;
    
    IF O_REST_USER_YN = 'Y' OR O_LEAVE_USER_YN = 'Y' OR O_NGT_USER_YN = 'Y' OR O_LOCK_USER_YN = 'Y' THEN
        -- 휴면 회원, 탈퇴회원, 부정 회원, 잠금 회원의 경우 로그인 불가처리
        O_LOGIN_YN := 'N';
    END IF;
    O_RTN_CD := v_result_cd;
END API_C_CUST_LOGIN;

/
