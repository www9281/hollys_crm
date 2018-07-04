--------------------------------------------------------
--  DDL for Procedure W_MENU_USER_GROUP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_USER_GROUP_SELECT" (
    P_USER_ID      IN  W_MENU_USER.USER_NO%TYPE,
    N_AUTH_CD      IN  VARCHAR2,
    N_STOR_CD      IN  NUMBER,
    N_BRAND_CD     IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)
IS
    v_query  VARCHAR2(30000);
BEGIN
    IF N_AUTH_CD = '90' THEN
      -- 점포
      v_query := 
                  'SELECT   MENU_CD       
                   ,        USER_USE_YN
                   ,        USER_ID
                   ,        MENU_RF
                   ,        MENU_NO
                   ,        MENU_NM                      
                   ,        PROG_NM 
                   ,        MENU_TP                       
                   ,        MENU_DIV                      
                   ,        AUTH_TP                       
                   ,        HELP_YN 
                   ,        USE_YN  
                   ,        ''' || N_AUTH_CD || '''  AS AUTH_CD
                   ,        ''' || N_STOR_CD || '''  AS STOR_CD
                   ,        ''' || N_BRAND_CD || ''' AS BRAND_CD
                   FROM     (
                               SELECT   B1.MENU_CD                                AS MENU_CD
                               ,        DECODE(B2.MENU_CD , NULL, ''N'', ''Y'')   AS USER_USE_YN
                               ,        ''' || P_USER_ID || '''                   AS USER_ID
                               ,        B1.MENU_REF                               AS MENU_RF
                               ,        B1.MENU_CD                                AS MENU_NO
                               ,        B1.MENU_NM_KOR                            AS MENU_NM
                               ,        B1.PROG_NM                                AS PROG_NM
                               ,        B1.PROG_TP                                AS MENU_TP
                               ,        B1.MENU_DIV                               AS MENU_DIV
                               ,        ''W''                                     AS AUTH_TP
                               ,        ''''                                      AS HELP_YN
                               ,        B1.USE_YN                                 AS USE_YN
                               ,        B1.MENU_IDX                               AS MENU_IX
                               FROM     W_MENU B1
                               ,        (
                                           SELECT   A1.MENU_CD
                                           FROM     (
                                                       SELECT   ''W_MENU_STORE_TP'' AS USE_TABLE_NM
                                                       ,        MENU_CD
                                                       FROM     W_MENU_GROUP
                                                       WHERE    PGM_MENU_GRP = ( SELECT PGM_MENU_GRP FROM STORE WHERE STOR_CD = ''' || N_STOR_CD || ''' )
                                                         AND    USE_YN = ''Y''
                                                       UNION    
                                                       SELECT   ''W_MENU_STORE_USER''         AS USE_TABLE_NM
                                                       ,        MENU_CD
                                                       FROM     W_MENU_STORE_USER
                                                       WHERE    USER_ID = ''' || P_USER_ID || '''
                                                    ) A1
                                           ,        (
                                                       SELECT 
                                                           CASE WHEN ( SELECT EMP_DIV  FROM STORE_USER          WHERE USER_ID = ''' || P_USER_ID || ''' AND BRAND_CD = ''' || N_BRAND_CD || ''' AND ROWNUM = 1)     IN ( ''1'' , ''2'' )  AND 
                                                                     ( SELECT COUNT(*) FROM W_MENU_STORE_USER   WHERE USER_ID = ''' || P_USER_ID || ''') = 0                                  THEN  ''W_MENU_STORE_TP'' 
                                                                WHEN ( SELECT EMP_DIV  FROM STORE_USER          WHERE USER_ID = ''' || P_USER_ID || ''' AND BRAND_CD = ''' || N_BRAND_CD || ''' AND ROWNUM = 1) NOT IN ( ''1'' , ''2'' )  THEN  ''W_MENU_STORE_USER'' 
                                                                WHEN ( SELECT EMP_DIV  FROM STORE_USER          WHERE USER_ID = ''' || P_USER_ID || ''' AND BRAND_CD = ''' || N_BRAND_CD || ''' AND ROWNUM = 1)     IN ( ''1'' , ''2'' ) AND 
                                                                     ( SELECT COUNT(*) FROM W_MENU_STORE_USER   WHERE USER_ID = ''' || P_USER_ID || ''') <> 0                                 THEN  ''W_MENU_STORE_USER'' 
                                                                END AS USE_TABLE_NM
                                                       FROM DUAL
                                                    ) A2
                                           WHERE    A1.USE_TABLE_NM = A2.USE_TABLE_NM
                                        ) B2
                               ,        (
                                           SELECT   PK_COL   AS LANG_MENU_CD
                                           ,        LANG_NM  AS LANG_MENU_NM
                                           FROM     LANG_TABLE
                                           WHERE    TABLE_NM    = ''W_MENU''
                                           AND      LANGUAGE_TP = ''' || N_LANGUAGE_TP || '''
                                       ) B3
                               WHERE    B1.MENU_CD = B2.MENU_CD(+)
                               AND      B1.MENU_CD = B3.LANG_MENU_CD(+)
                               AND      B1.USE_YN  = ''Y''
                            )
                   ORDER BY MENU_RF, MENU_IX, MENU_NM ';
         
    ELSE
      -- 회원
      v_query :=
                  'SELECT  B1.MENU_CD
                       ,  ''' || P_USER_ID || ''' USER_ID
                       ,  B1.USER_USE_YN
                       ,  B1.MENU_RF
                       ,  B1.MENU_CD   AS MENU_NO
                       ,  B1.MENU_NM
                       ,  B1.PROG_NM
                       ,  B1.MENU_TP
                       ,  B1.MENU_DIV
                       ,  ''W''          AS AUTH_TP
                       ,  ''''           AS HELP_YN
                       ,  B1.USE_YN
                       ,  ''' || N_AUTH_CD || '''  AS AUTH_CD
                       ,  ''' || N_STOR_CD || '''  AS STOR_CD
                       ,  ''' || N_BRAND_CD || ''' AS BRAND_CD
                   FROM  (
                              SELECT  DISTINCT
                                      A1.MENU_CD
                                   ,  DECODE(B1.MENU_CD , NULL, ''N'', ''Y'') AS USER_USE_YN
                                   ,  A1.MENU_NM_KOR                          AS MENU_NM
                                   ,  A1.MENU_IDX                             AS MENU_IX
                                   ,  A1.MENU_REF                             AS MENU_RF
                                   ,  A1.PROG_TP                              AS MENU_TP
                                   ,  A1.MENU_DIV                             AS MENU_DIV
                                   ,  A1.USE_YN                               AS USE_YN
                                   ,  A1.PROG_NM
                                FROM  W_MENU  A1, (SELECT MENU_CD, USER_ID FROM HQ_USER HU, W_MENU_USER MU WHERE HU.USER_ID = MU.USER_NO AND HU.USER_ID = ''' || P_USER_ID || ''') B1
                               WHERE  A1.MENU_CD  = B1.MENU_CD(+)
                                 AND  A1.USE_YN = ''Y''
                          )   B1
                   WHERE 1=1
                   ORDER BY B1.MENU_RF, B1.MENU_IX, B1.MENU_NM';
    END IF;
    OPEN O_CURSOR FOR v_query;
    
END W_MENU_USER_GROUP_SELECT;

/
