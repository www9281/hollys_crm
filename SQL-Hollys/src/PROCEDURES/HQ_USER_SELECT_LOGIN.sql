--------------------------------------------------------
--  DDL for Procedure HQ_USER_SELECT_LOGIN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_SELECT_LOGIN" 
(
        P_USER_ID     IN    HQ_USER.USER_ID%TYPE,
        P_PWD         IN    HQ_USER.PWD%TYPE,
        O_USER_NM     OUT   HQ_USER.USER_NM%TYPE,
        O_BRAND_CD    OUT   HQ_USER.BRAND_CD%TYPE,
        O_DEPT_CD     OUT   HQ_USER.DEPT_CD%TYPE,
        O_TEAM_CD     OUT   HQ_USER.TEAM_CD%TYPE,
        O_TOKEN       OUT   SY_USER_TOKEN.TOKEN%TYPE
) IS 
        L_EXISTS     NUMBER(1);
BEGIN
        SELECT  COUNT(*)
        INTO    L_EXISTS
        FROM    HQ_USER
        WHERE   USER_ID = P_USER_ID
        AND     PWD = P_PWD
        AND     USE_YN = 'Y';
        
        IF      L_EXISTS > 0
        THEN
                SELECT  NVL(USER_NM, ''),
                        NVL(BRAND_CD, ''),
                        NVL(DEPT_CD, ''),
                        NVL(TEAM_CD, ''),
                        SYS_GUID()
                INTO    O_USER_NM,
                        O_BRAND_CD,
                        O_DEPT_CD,
                        O_TEAM_CD,
                        O_TOKEN
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
        END IF;
END;

/
