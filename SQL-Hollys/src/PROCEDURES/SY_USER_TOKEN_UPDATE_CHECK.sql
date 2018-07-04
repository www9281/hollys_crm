--------------------------------------------------------
--  DDL for Procedure SY_USER_TOKEN_UPDATE_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SY_USER_TOKEN_UPDATE_CHECK" (
        P_TOKEN       IN    SY_USER_TOKEN.TOKEN%TYPE,
        O_USER_ID     OUT   SY_USER_TOKEN.USER_ID%TYPE
) AS 
        L_COUNT       NUMBER;
BEGIN
        SELECT  COUNT(*)
        INTO    L_COUNT
        FROM    SY_USER_TOKEN
        WHERE   TOKEN = P_TOKEN
        AND		  LAST_DATE + 1/24 > SYSDATE;
        
        IF      L_COUNT > 0   THEN
                SELECT  USER_ID
                INTO    O_USER_ID
                FROM    SY_USER_TOKEN
                WHERE   TOKEN = P_TOKEN;
        
                UPDATE    SY_USER_TOKEN
                SET       LAST_DATE = SYSDATE
                WHERE     TOKEN = P_TOKEN;
        END IF;
END SY_USER_TOKEN_UPDATE_CHECK;

/
