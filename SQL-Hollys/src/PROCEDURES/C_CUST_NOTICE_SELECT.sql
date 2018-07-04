--------------------------------------------------------
--  DDL for Procedure C_CUST_NOTICE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_CUST_NOTICE_SELECT" (
    N_NOTICE_SEQ  IN  VARCHAR2,
    N_TITLE       IN  VARCHAR2,
    N_LANGUAGE_TP IN  VARCHAR2,
    N_START_DT    IN  VARCHAR2,
    N_END_DT      IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)IS
    v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-11-16
    -- Description   :   멤버쉽 공지사항관리 공지사항 조회
    -- Test          :   
    -- ==========================================================================================
    v_query := 
            '
           SELECT  
              NOTICE_SEQ
              ,TITLE
              ,CONTENT
              ,NOTI_CATE
              ,GET_COMMON_CODE_NM(''N1000'', NOTI_CATE, ''' || N_LANGUAGE_TP || ''') AS NOTI_CATE_NM
              ,FILE_CNT
              ,FILE_ID
              ,READ_CNT
              ,TO_CHAR(POPUP_FR_DT, ''YYYY-MM-DD'') AS POPUP_FR_DT
              ,TO_CHAR(POPUP_TO_DT, ''YYYY-MM-DD'') AS POPUP_TO_DT
              ,POPUP_YN
              ,USE_YN
              ,INST_USER
              ,TO_CHAR(INST_DT, ''YYYY-MM-DD'') AS INST_DT
              ,TO_CHAR(UPD_DT, ''YYYY-MM-DD'') AS UPD_DT
              ,UPD_USER
              ,TOP_YN
           FROM C_NOTICE A
           WHERE (''' || N_NOTICE_SEQ || ''' IS NULL OR NOTICE_SEQ= ''' || N_NOTICE_SEQ || ''')
             AND (''' || N_TITLE || ''' IS NULL OR TITLE LIKE ''%'' || ''' || N_TITLE || ''' || ''%'' )
             AND (''' || N_START_DT || ''' IS NULL OR TO_CHAR(INST_DT, ''YYYYMMDD'') >= ''' || N_START_DT || ''')
             AND (''' || N_END_DT || ''' IS NULL OR TO_CHAR(INST_DT, ''YYYYMMDD'') <= ''' || N_END_DT || ''')
             AND A.USE_YN = ''Y''
           ORDER BY DECODE(TOP_YN,''Y'', 0, 1), NOTICE_SEQ DESC
          ';
    
    OPEN O_CURSOR FOR v_query; 
    
END C_CUST_NOTICE_SELECT;

/
