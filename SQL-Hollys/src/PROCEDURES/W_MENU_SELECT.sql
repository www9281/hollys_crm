--------------------------------------------------------
--  DDL for Procedure W_MENU_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_SELECT" (
    P_USER_ID      IN  W_MENU_USER.USER_NO%TYPE,
    N_AUTH_CD      IN  NUMBER,
    N_LANGUAGE_TP  IN  VARCHAR2,
    N_MENU_CD      IN  NUMBER,
    N_MENU_DIV     IN  CHAR,
    O_CURSOR       OUT SYS_REFCURSOR
)
IS 
    v_query  VARCHAR2(30000);
BEGIN
    v_query := 
                'SELECT  B1.MENU_CD
                     ,  B1.MENU_RF
                     ,  B1.MENU_CD     AS MENU_NO
                     ,  B1.MENU_NM
                     ,  B1.PROG_NM
                     ,  B1.MENU_TP
                     ,  B1.MENU_DIV
                     ,  ''W''          AS AUTH_TP
                     ,  ''''           AS HELP_YN
                     ,  B1.USE_YN
                     ,  BRAND_CD
                     ,  STOR_TP
                     ,  B1.INS_USER_NO
                     ,  B1.INS_DT
                 FROM  (
                            SELECT  DISTINCT
                                    A1.MENU_CD
                                 ,  NVL(C1.LANG_MENU_NM , A1.MENU_NM_KOR)   AS MENU_NM
                                 ,  A1.MENU_IDX                             AS MENU_IX
                                 ,  A1.MENU_REF                             AS MENU_RF
                                 ,  A1.PROG_TP                              AS MENU_TP
                                 ,  A1.MENU_DIV                             AS MENU_DIV
                                 ,  A1.USE_YN                               AS USE_YN
                                 ,  A1.PROG_NM
                                 ,  BRAND_CD
                                 ,  STOR_TP
                                 ,  A1.INS_USER_NO
                                 ,  TO_CHAR(A1.INS_DT, ''YYYY.MM.DD'') AS INS_DT
                              FROM  W_MENU  A1, W_MENU_USER B1
                                 ,  (
                                        SELECT  PK_COL   AS LANG_MENU_CD
                                             ,  LANG_NM  AS LANG_MENU_NM
                                          FROM  LANG_TABLE
                                         WHERE  TABLE_NM    = ''W_MENU''
                                           AND  LANGUAGE_TP = ''' || N_LANGUAGE_TP || '''
                                           AND  USE_YN      = ''Y''
                                    ) C1
                             WHERE  A1.MENU_CD  = B1.MENU_CD(+)
                               AND  A1.MENU_CD  = C1.LANG_MENU_CD(+)
                               AND  DECODE(''' || N_AUTH_CD || ''', ''0'', ''' || P_USER_ID || ''',B1.USER_NO) = ''' || P_USER_ID || '''
                        )   B1
                 WHERE 1=1';
                 
                 IF N_MENU_DIV = 'M' OR N_MENU_DIV = 'L' THEN
                    v_query := v_query || 'AND MENU_RF = ''' || N_MENU_CD || '''';
                 ELSE
                    v_query := v_query || 'AND MENU_DIV = ''M''';
                 END IF;
           
           v_query := v_query || 'ORDER BY B1.MENU_RF, B1.MENU_IX, B1.MENU_NM';
         
    OPEN O_CURSOR FOR v_query;
    
END W_MENU_SELECT;

/
