--------------------------------------------------------
--  DDL for Procedure PROMOTION_PUSH_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_PUSH_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 PUSH 상세보기
-- Test			:	exec PROMOTION_PUSH_VIEW '002', 'Y'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  

        OPEN       O_CURSOR  FOR
        SELECT     A.PUSH_NO AS PUSH_NO
                 , A.PUSH_TYPE AS PUSH_TYPE
                 , DECODE(A.PUSH_YN, 'Y', 'Y', 'N')  AS PUSH_YN
                 , A.PUSH_SEND_DIV AS PUSH_SEND_DIV
                 , A.PUSH_LINK AS PUSH_LINK
                 , A.PUSH_TITLE AS PUSH_TITLE
                 , A.PUSH_CONTENTS AS PUSH_CONTENTS
                 , A.BOOK_DT  AS BOOK_DT
                 , A.BOOK_HOUR  AS BOOK_HOUR
                 , A.BOOK_MINUTE  AS BOOK_MINUTE
                 , A.INST_USER  AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD')  AS INST_DT
                 , CASE WHEN B.FILE_ID IS NULL
                        THEN  ''
                        ELSE  B.FOLDER || '/' || B.FILE_ID || '.' || B.FILE_EXT
                    END AS IMG_URL
                 , B.FILE_ID
        FROM       PROMOTION_PUSH A
        LEFT       OUTER JOIN SY_CONTENT_FILE B
        ON         TABLE_NAME = 'PROMOTION_PUSH'
        AND        A.PRMT_ID = B.REF_ID
        WHERE      A.PRMT_ID = P_PRMT_ID;

END PROMOTION_PUSH_VIEW;

/
