--------------------------------------------------------
--  DDL for Procedure API_LSM_MSG_PUSH_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_LSM_MSG_PUSH_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	LSM 쿠폰PUSH 전송(메세지목록)
-- Test			:	exec API_LSM_MSG_PUSH_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_START_DT      IN   VARCHAR2,
        P_END_DT        IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2, 
        O_RTN_CD        OUT  VARCHAR2, 
        O_CURSOR        OUT  SYS_REFCURSOR  
) AS 
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과) 
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     A.PUSH_NO AS PUSH_NO
                   ,A.PRMT_ID AS PRMT_ID   
                   ,(
                        SELECT F.STOR_NM
                        FROM   PROMOTION_CAN_STOR E 
                        JOIN   STORE F 
                        ON     E.STOR_CD = F.STOR_CD 
                        WHERE  E.PRMT_ID = C.PRMT_ID 
                   ) AS STOR_NM
                   ,A.PUSH_TYPE AS PUSH_TYPE
                   ,A.PUSH_YN AS PUSH_YN
                   ,A.PUSH_TITLE AS PUSH_TITLE
                   ,A.PUSH_CONTENTS AS PUSH_CONTENTS
                   ,A.PUSH_LINK AS PUSH_LINK
                   ,A.BOOK_DT AS BOOK_DT
                   ,A.BOOK_HOUR AS BOOK_HOUR
                   , (CASE WHEN A.PUSH_SEND_DIV = 'C6701' THEN 'all'
                           WHEN A.PUSH_SEND_DIV = 'C6702' THEN 'android'
                           WHEN A.PUSH_SEND_DIV = 'C6703' THEN 'ios'
                           ELSE ''
                      END
                   ) AS PUSH_SEND_DIV
                   ,A.INST_USER AS INST_USER
                   ,TO_CHAR(A.INST_DT,'YYYYMMDD') AS INST_DT
                   ,A.UPD_USER AS UPD_USER
                   ,TO_CHAR(A.UPD_DT,'YYYYMMDD') AS UPD_DT
                   ,A.IMG_URL AS PUSH_FILE
        FROM       PROMOTION_PUSH A
        JOIN       PROMOTION B
        ON         A.PRMT_ID = B.PRMT_ID
        JOIN       PROMOTION_COUPON_PUBLISH C
        ON         A.PRMT_ID = C.PRMT_ID
        JOIN       PROMOTION_COUPON D
        ON         D.PUBLISH_ID = C.PUBLISH_ID
        WHERE      B.PRMT_CLASS = 'C5002'
        AND        (B.PRMT_USE_DIV = 'C6923' OR B.PRMT_USE_DIV = 'C6924')
        AND        (P_START_DT <= TO_CHAR(D.INST_DT,'YYYYMMDDHH24') AND P_END_DT >= TO_CHAR(D.INST_DT,'YYYYMMDDHH24'))
        AND        C.OWN_YN = 'Y';
        
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END API_LSM_MSG_PUSH_SELECT;

/
