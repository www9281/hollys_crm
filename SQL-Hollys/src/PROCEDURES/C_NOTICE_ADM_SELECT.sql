--------------------------------------------------------
--  DDL for Procedure C_NOTICE_ADM_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_ADM_SELECT" (
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
    
    
    UPDATE C_NOTICE
    SET 
        READ_CNT = (READ_CNT) + 1
    WHERE  NOTICE_SEQ = N_NOTICE_SEQ
    ;
    commit;
    
    
    v_query := 
            '
           SELECT  
              A.NOTICE_SEQ
              ,A.TITLE
              ,A.CONTENT
              ,A.NOTI_CATE
              ,GET_COMMON_CODE_NM(''N1000'', NOTI_CATE, ''' || N_LANGUAGE_TP || ''') AS NOTI_CATE_NM
              ,A.FILE_CNT
              ,A.FILE_ID
              ,A.READ_CNT
              ,TO_CHAR(A.POPUP_FR_DT, ''YYYY-MM-DD'') AS POPUP_FR_DT
              ,TO_CHAR(A.POPUP_TO_DT, ''YYYY-MM-DD'') AS POPUP_TO_DT
              ,A.POPUP_YN
              ,A.USE_YN
              ,A.INST_USER
              ,TO_CHAR(A.INST_DT, ''YYYY-MM-DD'') AS INST_DT
              ,TO_CHAR(A.UPD_DT, ''YYYY-MM-DD'') AS UPD_DT
              ,A.UPD_USER
              ,A.TOP_YN
              ,NVL(B.FILE_ID, '''') || '''' AS FILE_ID
           FROM C_NOTICE A, SY_CONTENT_FILE B
           WHERE A.NOTICE_SEQ = B.REF_ID(+)
             AND B.TABLE_NAME(+) = ''C_NOTICE''
             AND B.FILE_TYPE(+) = ''0''
             AND (''' || N_NOTICE_SEQ || ''' IS NULL OR NOTICE_SEQ= ''' || N_NOTICE_SEQ || ''')
             AND (''' || N_TITLE || ''' IS NULL OR TITLE LIKE ''%'' || ''' || N_TITLE || ''' || ''%'' )
             AND (''' || N_START_DT || ''' IS NULL OR TO_CHAR(INST_DT, ''YYYYMMDD'') >= ''' || N_START_DT || ''')
             AND (''' || N_END_DT || ''' IS NULL OR TO_CHAR(INST_DT, ''YYYYMMDD'') <= ''' || N_END_DT || ''')
           ORDER BY A.INST_DT DESC , TOP_YN DESC,  NOTICE_SEQ DESC
          ';
    
    OPEN O_CURSOR FOR v_query;
    
    
     
    
END C_NOTICE_ADM_SELECT;

/
