--------------------------------------------------------
--  DDL for Procedure C_NOTICE_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_SAVE" (
    N_NOTICE_SEQ    IN  VARCHAR2,
    P_TITLE         IN  VARCHAR2,
    P_CONTENT       IN  VARCHAR2,
    N_NOTI_CATE     IN  VARCHAR2,
    N_POPUP_FR_DT   IN  VARCHAR2,
    N_POPUP_TO_DT   IN  VARCHAR2,
    N_POPUP_YN      IN  VARCHAR2,
    N_USE_YN        IN  VARCHAR2,
    N_TOP_YN        IN  VARCHAR2,
    P_MY_USER_ID 	  IN  VARCHAR2,
    O_NOTICE_SEQ    OUT VARCHAR2,
    O_PR_RTN_CD     OUT VARCHAR2,
    O_PR_RTN_MSG    OUT VARCHAR2
)IS 
  ERR_HANDLER     EXCEPTION;
BEGIN
    ----------------------- 공지사항 등록 -----------------------
    IF N_NOTICE_SEQ IS NULL THEN
      SELECT 
        SQ_NOTICE_SEQ.nextval
        INTO O_NOTICE_SEQ
      FROM DUAL;
      
      INSERT INTO C_NOTICE (
        NOTICE_SEQ
        ,TITLE
        ,CONTENT
        ,NOTI_CATE
        ,READ_CNT
        ,POPUP_FR_DT
        ,POPUP_TO_DT
        ,POPUP_YN
        ,USE_YN
        ,TOP_YN
        ,INST_DT
        ,INST_USER
        ,UPD_DT
        ,UPD_USER
      ) VALUES (
        O_NOTICE_SEQ
        ,P_TITLE
        ,P_CONTENT
        ,N_NOTI_CATE
        ,0
        ,N_POPUP_FR_DT
        ,N_POPUP_TO_DT
        ,N_POPUP_YN
        ,N_USE_YN
        ,N_TOP_YN
        ,SYSDATE
        ,P_MY_USER_ID
        ,SYSDATE
        ,P_MY_USER_ID
      );
      
    ELSE
      UPDATE C_NOTICE SET
        TITLE        = P_TITLE
        ,CONTENT      = P_CONTENT
        ,NOTI_CATE    = N_NOTI_CATE
        ,POPUP_FR_DT  = NVL(N_POPUP_FR_DT, '')
        ,POPUP_TO_DT  = NVL(N_POPUP_TO_DT, '')
        ,POPUP_YN     = N_POPUP_YN
        ,USE_YN       = N_USE_YN
        ,TOP_YN       = N_TOP_YN
        ,UPD_DT       = SYSDATE
        ,UPD_USER     = P_MY_USER_ID
      WHERE NOTICE_SEQ = N_NOTICE_SEQ;
      
      O_NOTICE_SEQ := N_NOTICE_SEQ;
    END IF;
    
    O_PR_RTN_CD := '0';
    O_PR_RTN_MSG := '성공';
    
EXCEPTION
    WHEN ERR_HANDLER THEN
        O_PR_RTN_CD  := SQLCODE;
        O_PR_RTN_MSG := SQLERRM ;
       dbms_output.put_line( O_PR_RTN_MSG ) ;
    WHEN OTHERS THEN
        O_PR_RTN_CD  := '4999999' ;
        O_PR_RTN_MSG := SQLERRM ;
        dbms_output.put_line( O_PR_RTN_MSG ) ;
END C_NOTICE_SAVE;

/
