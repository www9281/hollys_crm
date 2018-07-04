--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_REP_DUP_CHECK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_REP_DUP_CHECK" (
    P_COMP_CD         IN   VARCHAR2,
    P_START_CARD_CD   IN   VARCHAR2,
    P_CLOSE_CARD_CD   IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) IS
      v_query varchar2(20000);
BEGIN
      ----------------------- 카드타입 상세 카드정보 중복체크 -----------------------
      v_query :=
            'SELECT  *
             FROM  (
                        SELECT  R.COMP_CD
                             ,  T.BRAND_CD
                             ,  T.BRAND_NM
                             ,  R.CARD_TYPE
                             ,  T.CARD_TYPE_NM
                             ,  DECRYPT(R.START_CARD_CD)    AS START_CARD_CD
                             ,  DECRYPT(R.CLOSE_CARD_CD)    AS CLOSE_CARD_CD
                          FROM  C_CARD_TYPE_REP     R
                             ,  (
                                    SELECT  C.COMP_CD
                                         ,  C.CARD_TYPE
                                         ,  NVL(L.LANG_NM, C.CARD_TYPE_NM)  AS CARD_TYPE_NM
                                         ,  C.TSMS_BRAND_CD                 AS BRAND_CD
                                         ,  B.BRAND_NM
                                      FROM  C_CARD_TYPE     C
                                         ,  (
                                                SELECT  B.COMP_CD
                                                     ,  B.BRAND_CD
                                                     ,  NVL(L.LANG_NM, B.BRAND_NM)  AS BRAND_NM
                                                  FROM  BRAND   B
                                                     ,  (
                                                            SELECT  PK_COL
                                                                 ,  LANG_NM
                                                              FROM  LANG_TABLE
                                                             WHERE  TABLE_NM    = ''BRAND''
                                                               AND  COL_NM      = ''BRAND_NM''
                                                               AND  LANGUAGE_TP = ''KOR''
                                                               AND  USE_YN      = ''Y''
                                                        )       L
                                                 WHERE  B.BRAND_CD  = L.PK_COL(+)
                                                   AND  B.COMP_CD   = ''' || P_COMP_CD || '''
                                                   AND  B.USE_YN    = ''Y''
                                            )                   B
                                         ,  (
                                                SELECT  PK_COL
                                                     ,  LANG_NM
                                                  FROM  LANG_TABLE
                                                 WHERE  TABLE_NM    = ''C_CARD_TYPE''
                                                   AND  COL_NM      = ''CARD_TYPE_NM''
                                                   AND  LANGUAGE_TP = ''KOR''
                                                   AND  USE_YN      = ''Y''
                                            )               L
                                     WHERE  C.COMP_CD           = B.COMP_CD
                                       AND  C.TSMS_BRAND_CD     = B.BRAND_CD
                                       AND  LPAD(C.CARD_TYPE, 3, '' '') = L.PK_COL(+)
                                       AND  C.COMP_CD   = ''' || P_COMP_CD || '''
                                       AND  C.USE_YN    = ''Y''
                                )                       T
                         WHERE  R.COMP_CD   = T.COMP_CD
                           AND  R.CARD_TYPE = T.CARD_TYPE
                           AND  R.COMP_CD   = ''' || P_COMP_CD || '''
                           AND  R.USE_YN    = ''Y''
                    )
             WHERE  ''' || P_START_CARD_CD || ''' BETWEEN START_CARD_CD AND CLOSE_CARD_CD
                OR  ''' || P_CLOSE_CARD_CD || ''' BETWEEN START_CARD_CD AND CLOSE_CARD_CD';
             
      OPEN O_CURSOR FOR v_query;
END C_CARD_TYPE_REP_DUP_CHECK;

/
