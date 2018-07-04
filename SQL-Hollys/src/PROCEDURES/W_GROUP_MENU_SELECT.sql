--------------------------------------------------------
--  DDL for Procedure W_GROUP_MENU_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."W_GROUP_MENU_SELECT" (
    P_GROUP_NO     IN  VARCHAR2,
    N_LANGUAGE_TP  IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
)
IS
    v_query  VARCHAR2(30000);
BEGIN
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-10-31
      -- Description   :   사용자 메뉴 그룹에 포함된 메뉴리스트 조회
      -- Test          :   W_GROUP_MENU_SELECT ('10', 'KOR')
      -- ==========================================================================================
      v_query :=
          'SELECT ''' || P_GROUP_NO || ''' AS GROUP_NO
               ,  B1.MENU_CD
               ,  B1.MENU_RF
               ,  B1.MENU_CD   AS MENU_NO
               ,  B1.DEPTH
               ,  LPAD('' '', B1.DEPTH*2) || B1.MENU_NM AS MENU_NM
               ,  B1.USE_YN
           FROM  (
                      SELECT  DISTINCT
                              A1.MENU_CD
                           ,  NVL(C1.LANG_MENU_NM , A1.MENU_NM_KOR)        AS MENU_NM
                           ,  A1.MENU_IDX                                  AS MENU_IX
                           ,  A1.MENU_REF                                  AS MENU_RF
                           ,  A1.PROG_TP                                   AS MENU_TP
                           ,  A1.MENU_DIV                                  AS MENU_DIV
                           ,  DECODE(A2.MENU_CD, NULL, ''N'', A2.USE_YN)   AS USE_YN
                           ,  A1.PROG_NM
                           ,  A1.DEPTH
                        FROM  W_MENU  A1, W_GROUP_MENU A2
                           ,  (
                                  SELECT  PK_COL   AS LANG_MENU_CD
                                       ,  LANG_NM  AS LANG_MENU_NM
                                    FROM  LANG_TABLE
                                   WHERE  TABLE_NM    = ''W_MENU''
                                     AND  LANGUAGE_TP = ''' || N_LANGUAGE_TP || '''
                                     AND  USE_YN      = ''Y''
                              ) C1
                       WHERE  A1.MENU_CD  = C1.LANG_MENU_CD(+)
                         AND  A1.MENU_CD  = A2.MENU_CD (+)
                         AND  A2.GROUP_NO(+) = ''' || P_GROUP_NO || '''
                         AND  MENU_DIV IN (''M'', ''L'', ''C'')
                  )   B1
           WHERE 1=1
           CONNECT BY PRIOR MENU_CD = MENU_RF
           START WITH MENU_RF = 0
           ORDER SIBLINGS BY MENU_IX'
           ;
           
    OPEN O_CURSOR FOR v_query;
    
END W_GROUP_MENU_SELECT;

/
