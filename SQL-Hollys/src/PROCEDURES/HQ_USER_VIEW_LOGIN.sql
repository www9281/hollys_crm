--------------------------------------------------------
--  DDL for Procedure HQ_USER_VIEW_LOGIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_VIEW_LOGIN" 
(
        P_USER_ID     IN    HQ_USER.USER_ID%TYPE,
        P_PWD         IN    HQ_USER.PWD%TYPE,
        O_HOLD_YN     OUT   VARCHAR,
        O_CHANGE_YN   OUT   VARCHAR,
        O_TOKEN       OUT   SY_USER_TOKEN.TOKEN%TYPE,
        O_USER_NM     OUT   HQ_USER.USER_NM%TYPE,
        O_DUTY_CD     OUT   HQ_USER.DUTY_CD%TYPE,
        O_COMP_CD     OUT   HQ_USER.COMP_CD%TYPE,
        O_BRAND_CD    OUT   HQ_USER.BRAND_CD%TYPE,
        O_LANGUAGE_TP OUT   HQ_USER.LANGUAGE_TP%TYPE,
        O_GROUP_NO    OUT   HQ_USER.GROUP_NO%TYPE
) IS 
        L_EXISTS      NUMBER(1);
        L_PWD         HQ_USER.PWD%TYPE;
        L_USER_NM     HQ_USER.USER_NM%TYPE;
        L_DUTY_CD     HQ_USER.DUTY_CD%TYPE;
        L_COMP_CD     HQ_USER.COMP_CD%TYPE;
        L_BRAND_CD    HQ_USER.BRAND_CD%TYPE;
        L_LANGUAGE_TP HQ_USER.LANGUAGE_TP%TYPE;
        L_GROUP_NO    HQ_USER.GROUP_NO%TYPE;
        L_FAIL_COUNT  NUMBER(1);
        L_LAST_FAIL   DATE;
BEGIN
        -- 회원정보가 있는지 확인
        SELECT  COUNT(*)
        INTO    L_EXISTS
        FROM    HQ_USER
        WHERE   USER_ID = P_USER_ID
        AND     USE_YN = 'Y';
        
        IF      L_EXISTS > 0
        THEN
                -- 회원정보를 일단 로컬변수에 담는다.
                SELECT  PWD,
                        USER_NM,
                        DUTY_CD,
                        COMP_CD,
                        BRAND_CD,
                        LANGUAGE_TP,
                        GROUP_NO
                INTO    L_PWD,
                        L_USER_NM,
                        L_DUTY_CD,
                        L_COMP_CD,
                        L_BRAND_CD,
                        L_LANGUAGE_TP,
                        L_GROUP_NO
                FROM    HQ_USER
                WHERE   USER_ID = P_USER_ID;
                
                -- 실패횟수
                SELECT  COUNT(*)
                INTO    L_FAIL_COUNT
                FROM    SY_ACCESS_FAIL
                WHERE   USER_ID = P_USER_ID;
                
                -- 마지막 실패시간
                SELECT  MAX(REG_DATE)
                INTO    L_LAST_FAIL
                FROM    SY_ACCESS_FAIL
                WHERE   USER_ID = P_USER_ID;
                
                -- 실패횟수고 5회가 넘으면서 마지막시간이 30분 이내면 실패
                IF      L_FAIL_COUNT >= 5 AND L_LAST_FAIL + 1/24/60*30 > SYSDATE
                THEN
                        -- 결과에 넣어주고
                        O_HOLD_YN := 'Y';
                        -- 마지막 데이터에 날짜를 업데이트 한다.
                        UPDATE  SY_ACCESS_FAIL
                        SET     REG_DATE = SYSDATE
                        WHERE   USER_ID = P_USER_ID
                        AND     REG_DATE = L_LAST_FAIL;
                ELSIF   L_PWD = P_PWD
                THEN
                          -- 로그인 성공
                          O_HOLD_YN := 'N';
                          O_USER_NM := L_USER_NM;
                          O_DUTY_CD := L_DUTY_CD;
                          O_COMP_CD := L_COMP_CD;
                          O_BRAND_CD := L_BRAND_CD;
                          O_LANGUAGE_TP := L_LANGUAGE_TP;
                          O_GROUP_NO := L_GROUP_NO;
                          
                          -- 패스워드 변경 권유
                          SELECT  DECODE(COUNT(*), 0, 'N', 1, 'Y')
                          INTO    O_CHANGE_YN
                          FROM    SY_USER_PWD_DATE
                          WHERE   USER_ID = P_USER_ID
                          AND     ADD_MONTHS(REG_DATE, 3) < SYSDATE;
                          
                          -- 실패로그 삭제
                          DELETE
                          FROM    SY_ACCESS_FAIL
                          WHERE   USER_ID = P_USER_ID;
                          
                          SELECT  SYS_GUID()
                          INTO    O_TOKEN
                          FROM    HQ_USER
                          WHERE   USER_ID = P_USER_ID
                          AND     PWD = P_PWD
                          AND     USE_YN = 'Y';
                          
                          INSERT  INTO  SY_USER_TOKEN
                          (
                                  TOKEN,
                                  USER_ID,
                                  REG_DATE,
                                  LAST_DATE
                          )       VALUES                (
                                  O_TOKEN,
                                  P_USER_ID,
                                  SYSDATE,
                                  SYSDATE
                          );
              ELSE    -- 로그인 실패
                        O_HOLD_YN := '';
                        INSERT  INTO  SY_ACCESS_FAIL  (
                                USER_ID,
                                SEQ,
                                REG_DATE
                        )
                        SELECT  P_USER_ID,
                                COUNT(*) + 1,
                                SYSDATE
                        FROM    SY_ACCESS_FAIL
                        WHERE   USER_ID = P_USER_ID;
                        
                
             END IF;
        END IF;
END HQ_USER_VIEW_LOGIN;

/
