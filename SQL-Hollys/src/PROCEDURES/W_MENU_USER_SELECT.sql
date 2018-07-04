--------------------------------------------------------
--  DDL for Procedure W_MENU_USER_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_MENU_USER_SELECT" (
    P_USER_ID      IN  W_MENU_USER.USER_NO%TYPE,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)
IS
    v_query  VARCHAR2(30000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   로그인 사용자별 메뉴리스트 조회
    -- Test          :   W_MENU_USER_SELECT ('level_10', 'KOR')
    -- ==========================================================================================
      v_query :=
          'SELECT  B1.MENU_CD
               ,  B1.MENU_RF
               ,  B1.MENU_CD   AS MENU_NO
               ,  B1.MENU_NM
               ,  B1.PROG_NM
               ,  B1.MENU_TP
               ,  B1.MENU_DIV
               ,  ''W''          AS AUTH_TP
               ,  ''''           AS HELP_YN
               ,  B1.USE_YN
               ,  B1.DEPTH
           FROM  (
                      SELECT  DISTINCT
                              A1.MENU_CD
                           ,  NVL(C1.LANG_MENU_NM , A1.MENU_NM_KOR)   AS MENU_NM
                           ,  A1.MENU_IDX                             AS MENU_IDX
                           ,  A1.MENU_REF                             AS MENU_RF
                           ,  A1.PROG_TP                              AS MENU_TP
                           ,  A1.MENU_DIV                             AS MENU_DIV
                           ,  A1.USE_YN                               AS USE_YN
                           ,  A1.PROG_NM
                           ,  A1.DEPTH
                        FROM  W_MENU  A1
                           ,  (
                                  SELECT  PK_COL   AS LANG_MENU_CD
                                       ,  LANG_NM  AS LANG_MENU_NM
                                    FROM  LANG_TABLE
                                   WHERE  TABLE_NM    = ''W_MENU''
                                     AND  LANGUAGE_TP = ''' || N_LANGUAGE_TP || '''
                                     AND  USE_YN      = ''Y''
                              ) C1
                       WHERE  A1.MENU_CD  = C1.LANG_MENU_CD(+)
                         AND  MENU_DIV IN (''M'', ''L'', ''C'', ''T'')
                         AND  (MENU_DIV = ''T'' OR EXISTS (SELECT 1
                                      FROM W_GROUP_MENU GM, HQ_USER HU
                                      WHERE HU.USER_ID = ''' || P_USER_ID || '''
                                        AND GM.GROUP_NO = HU.GROUP_NO
                                        AND GM.MENU_CD = A1.MENU_CD
                                        AND GM.USE_YN = ''Y''))
                         AND  A1.USE_YN = ''Y''
                         ORDER BY MENU_IDX
                  )   B1
           WHERE 1=1
           CONNECT BY PRIOR MENU_CD = MENU_RF
           START WITH MENU_RF = 0
           ORDER SIBLINGS BY MENU_IDX'
           ;
    DBMS_OUTPUT.PUT_LINE(v_query);       
           
    OPEN O_CURSOR FOR v_query;
    
END W_MENU_USER_SELECT;

/
