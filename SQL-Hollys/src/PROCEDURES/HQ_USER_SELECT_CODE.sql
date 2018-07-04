--------------------------------------------------------
--  DDL for Procedure HQ_USER_SELECT_CODE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_SELECT_CODE" (
    N_USER_ID_NAME  IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN O_CURSOR FOR
    SELECT  USER_ID, 
            USER_NM
    FROM    HQ_USER
    WHERE   (N_USER_ID_NAME IS NULL OR N_USER_ID_NAME = '' OR USER_ID LIKE '%'||N_USER_ID_NAME||'%' OR USER_NM LIKE '%'||N_USER_ID_NAME||'%');
END HQ_USER_SELECT_CODE;

/
