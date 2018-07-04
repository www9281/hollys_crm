--------------------------------------------------------
--  DDL for Procedure C_NOTICE_POPUP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_NOTICE_POPUP_SELECT" (
    O_CURSOR      OUT SYS_REFCURSOR
)IS
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2018-02-19
    -- Description   :   멤버쉽 공지사항관리 공지사항 팝업 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      NOTICE_SEQ
      ,TITLE
      ,CONTENT
      ,NOTI_CATE
      ,GET_COMMON_CODE_NM('N1000', NOTI_CATE) AS NOTI_CATE_NM
      ,FILE_CNT
      ,FILE_ID
      ,INST_USER
      ,TO_CHAR(INST_DT, 'YYYY-MM-DD') AS INST_DT
    FROM C_NOTICE A
    WHERE USE_YN = 'Y'
      AND POPUP_YN = 'Y'
      AND SYSDATE BETWEEN POPUP_FR_DT AND POPUP_TO_DT
    ORDER BY NOTICE_SEQ DESC
    ;
END C_NOTICE_POPUP_SELECT;

/
