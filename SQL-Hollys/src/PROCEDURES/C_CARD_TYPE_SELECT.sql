--------------------------------------------------------
--  DDL for Procedure C_CARD_TYPE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CARD_TYPE_SELECT" (
    P_COMP_CD       IN  VARCHAR2,
    N_BRAND_CD      IN  VARCHAR2,
    N_CARD_TYPE_TXT IN  VARCHAR2,
    N_USE_YN        IN  VARCHAR2,
    N_USER_ID       IN  VARCHAR2,
    O_CURSOR        OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 카드관리 [카드타입관리] 정보 조회
    -- Test          :   C_CARD_TYPE_SELECT ('000', '', '', '')
    -- ==========================================================================================
    v_query := 
            'SELECT  
               C.CATEGORY_DIV
               ,  C.CARD_TYPE_SEQ
               ,  C.CATEGORY_CD
               ,  C.COMP_CD
               ,  C.CARD_TYPE
               ,  L.LANG_NM
               ,  C.CARD_DIV
               ,  D.FILE_NAME AS LC_FILE_NM
               ,  NVL(D.FILE_ID, '''') || '''' AS FILE_ID
               ,  D.FOLDER
               ,  D.FILE_NAME
               ,  D.FILE_ID
               ,  D.FILE_EXT
               ,  C.TSMS_BRAND_CD
               ,  C.USE_YN
               ,  C.MMS_FILE_NM
            FROM  C_CARD_TYPE     C
               ,  SY_CONTENT_FILE D
               ,  (
                      SELECT  PK_COL
                           ,  LANG_NM
                        FROM  LANG_TABLE
                       WHERE  TABLE_NM    = ''C_CARD_TYPE''
                         AND  COL_NM      = ''CARD_TYPE_NM''
                         AND  LANGUAGE_TP = ''KOR''
                         AND  USE_YN      = ''Y''
                  )               L
           WHERE  C.COMP_CD                   = ''' || P_COMP_CD || '''
             AND  LPAD(C.CARD_TYPE, 3, '' '')   = L.PK_COL(+)
             AND  C.CARD_TYPE_SEQ = D.REF_ID(+)
             AND  D.TABLE_NAME(+) = ''C_CARD''
             AND  (''' || N_BRAND_CD || ''' IS NULL OR C.TSMS_BRAND_CD = ''' || N_BRAND_CD || ''')
             AND  (C.TSMS_BRAND_CD = ''' || N_BRAND_CD || ''' OR (''' || N_BRAND_CD || ''' IS NULL
                    AND EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = ''' || N_USER_ID || ''' AND BRAND_CD = C.TSMS_BRAND_CD AND USE_YN = ''Y'')))
             AND  (''' || N_CARD_TYPE_TXT || ''' IS NULL 
                          OR C.CARD_TYPE LIKE ''%'' || ''' || N_CARD_TYPE_TXT || ''' || ''%'')
             AND  (''' || N_USE_YN || '''        IS NULL OR C.USE_YN = ''' || N_USE_YN || ''')
           ORDER  BY C.CATEGORY_DIV, C.CATEGORY_CD, C.CARD_TYPE';
    
    OPEN O_CURSOR FOR v_query;
      
END C_CARD_TYPE_SELECT;

/
