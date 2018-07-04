--------------------------------------------------------
--  DDL for Procedure C_VOC_SEND
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_VOC_SEND" (
    P_VOC_SEQ     IN    VARCHAR2,
    P_MY_USER_ID  IN    VARCHAR2,
    O_CURSOR      OUT   SYS_REFCURSOR
) AS 
BEGIN
    UPDATE  C_VOC
       SET  SEND_YN = 'Y'
         ,  UPD_DT = SYSDATE
         ,  UPD_USER = P_MY_USER_ID
    WHERE   VOC_SEQ = P_VOC_SEQ;
    
    -- 답변목록 조회
    OPEN O_CURSOR FOR
    SELECT
      A.CONTENT
      ,TO_CHAR(A.INST_DT, 'YYYY-MM-DD') AS INST_DT
      ,(SELECT USER_NM FROM HQ_USER WHERE USER_ID = A.INST_USER) AS USER_NM
    FROM C_VOC_REPLY A
    WHERE A.VOC_SEQ = P_VOC_SEQ
      AND A.DEL_YN = 'N'
    ORDER BY A.VOC_REPLY_SEQ;
    
END C_VOC_SEND;

/
