--------------------------------------------------------
--  DDL for Procedure HQ_USER_SELECT_INFO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HQ_USER_SELECT_INFO" 
(
        N_USER_ID     IN    HQ_USER.USER_ID%TYPE,
        O_CURSOR      OUT   SYS_REFCURSOR
) AS
        v_query     varchar(30000);
BEGIN
        v_query :=
             'SELECT   A.BRAND_CD
                   ,   A.STOR_CD
                   ,   A.STOR_NM
                   ,   A.STOR_TP
                   ,   A.USER_ID
                   ,   A.USER_NM
                   ,   A.USER_POS_PW
                   ,   A.EMP_DIV
                   ,   A.WEB_AUTH_CD
                   ,   A.AUTH_CD
                   ,   A.CERTIFY_YN
                   ,   FC_PW_EXPIRE_CHECK(A.USER_ID)    AS EXPIRE_YN
                   ,   A.ITEM_CONF_YN
                   ,   A.STOR_CONF_YN
                   ,   A.NATION_CD
                   ,   A.MULTI_LANGUAGE_YN
                   ,   NVL(A.COMP_LANGUAGE_TP, ''KOR'') AS COMP_LANGUAGE_TP
                   ,   A.LANGUAGE_TP
                   ,   A.DEPT_CD
                   ,   A.TEAM_CD
                   ,   A.COMP_CD
                   ,   A.COMP_NM
                   ,   A.USE_YN 
                   ,   A.GW_USER_ID  AS GW_USER_ID
                   ,   A.USER_DIV
                   ,   B.VAL_C1      AS SALES_DIV
                   ,   C.VAL_C1      AS LMS_TRAD_DIV
                   ,   CASE WHEN RETIRE_DT IS NOT NULL AND LENGTH(RETIRE_DT) = 8 THEN (CASE WHEN TO_CHAR(SYSDATE, ''YYYYMMDD'') >= RETIRE_DT THEN ''Y'' ELSE ''N'' END)
                            ELSE ''N''
                       END RETIRE_YN
                FROM   (
                          SELECT   U.BRAND_CD                AS BRAND_CD
                               ,   U.STOR_CD                 AS STOR_CD
                               ,   S.STOR_NM                 AS STOR_NM
                               ,   S.STOR_TP                 AS STOR_TP
                               ,   U.USER_ID                 AS USER_ID
                               ,   U.USER_NM                 AS USER_NM
                               ,   U.WEB_PWD                 AS USER_PW
                               ,   U.POS_PWD                 AS USER_POS_PW
                               ,   ''S''                     AS USER_DIV
                               ,   U.EMP_DIV                 AS EMP_DIV
                               ,   NVL(U.WEB_AUTH_CD, ''99'')  AS WEB_AUTH_CD
                               ,   ''90''                    AS AUTH_CD
                               ,   ''N''                     AS CERTIFY_YN
                               ,   ''''                      AS ITEM_CONF_YN
                               ,   ''''                      AS STOR_CONF_YN
                               ,   C.LANGUAGE_TP             AS COMP_LANGUAGE_TP
                               ,   C.NATION_CD               AS NATION_CD
                               ,   C.MULTI_LANGUAGE_YN       AS MULTI_LANGUAGE_YN
                               ,   U.LANGUAGE_TP             AS LANGUAGE_TP
                               ,   ''''                      AS DEPT_CD
                               ,   ''''                      AS TEAM_CD
                               ,   ''''                      AS DUTY_CD
                               ,   U.USE_YN                  AS USE_YN
                               ,   C.COMP_CD
                               ,   C.COMP_NM
                               ,   ''''                        AS GW_USER_ID
                               ,   U.RETIRE_DT
                            FROM   STORE_USER   U
                               ,   BRAND        B
                               ,   COMPANY      C
                               ,   STORE        S
                           WHERE   U.BRAND_CD = B.BRAND_CD
                             AND   B.COMP_CD  = C.COMP_CD
                             AND   U.BRAND_CD = S.BRAND_CD
                             AND   U.STOR_CD  = S.STOR_CD';
                             
                 IF N_USER_ID IS NOT NULL THEN
                    v_query :=    v_query ||
                           ' AND   U.USER_ID  = ''' || N_USER_ID || '''';
                 END IF;
                
                v_query :=    v_query ||
                           ' AND   U.USE_YN   = ''Y''
                          UNION ALL
                          SELECT   U.BRAND_CD                AS BRAND_CD
                               ,   ''99999''                 AS STOR_CD
                               ,   ''''                      AS STOR_NM
                               ,   ''''                      AS STOR_TP
                               ,   U.USER_ID                 AS USER_ID
                               ,   U.USER_NM                 AS USER_NM
                               ,   U.PWD                     AS USER_PW
                               ,   ''''                      AS USER_POS_PW
                               ,   ''H''                     AS USER_DIV
                               ,   ''''                      AS EMP_DIV
                               ,   U.WEB_AUTH_CD             AS WEB_AUTH_CD
                               ,   U.DUTY_CD                 AS AUTH_CD
                               ,   NVL(U.CERTIFY_YN, ''N'')  AS CERTIFY_YN
                               ,   U.ITEM_CONF_YN            AS ITEM_CONF_YN
                               ,   U.STOR_CONF_YN            AS STOR_CONF_YN
                               ,   C.LANGUAGE_TP             AS COMP_LANGUAGE_TP
                               ,   C.NATION_CD               AS NATION_CD
                               ,   C.MULTI_LANGUAGE_YN       AS MULTI_LANGUAGE_YN
                               ,   U.LANGUAGE_TP             AS LANGUAGE_TP
                               ,   U.DEPT_CD                 AS DEPT_CD
                               ,   U.TEAM_CD                 AS TEAM_CD
                               ,   U.DUTY_CD                 AS DUTY_CD
                               ,   U.USE_YN                  AS USE_YN
                               ,   C.COMP_CD
                               ,   C.COMP_NM
                               ,   U.GW_USER_ID              AS GW_USER_ID
                               ,   NULL                      AS RETIRE_DT
                            FROM   HQ_USER   U
                               ,   COMPANY   C
                           WHERE   U.COMP_CD = C.COMP_CD';
             IF N_USER_ID IS NOT NULL THEN
             v_query :=    v_query ||
                           ' AND   U.USER_ID = ''' || N_USER_ID || '''';
             END IF;
             
             v_query :=    v_query ||               
                       '
                       )  A
                   ,   (
                          SELECT   VAL_C1 
                            FROM   COMMON 
                           WHERE   CODE_TP = ''01435'' 
                             AND   CODE_CD = ''200'' 
                             AND USE_YN = ''Y''
                       ) B
                   ,   (
                          SELECT   VAL_C1 
                            FROM   COMMON 
                           WHERE   CODE_TP = ''01435'' 
                             AND   CODE_CD = ''230'' 
                             AND   USE_YN = ''Y''
                       ) C';
                       
            OPEN O_CURSOR FOR v_query;
END HQ_USER_SELECT_INFO;

/
