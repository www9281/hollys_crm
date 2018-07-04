--------------------------------------------------------
--  DDL for Procedure PROMOTION_PRINT_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_PRINT_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	프로모션 영수증 상세보기
-- Test			:	exec PROMOTION_PRINT_VIEW '30', 'level_10'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID AS PRMT_ID
                 , A.RECEIPT_TYPE AS RECEIPT_TYPE
                 , A.EFFECTIVE_TIME AS EFFECTIVE_TIME
                 , A.BILL_COUNT AS BILL_COUNT
                 , A.PAY_METHOD AS PAY_METHOD
                 , A.PRINT_RECEIPT AS PRINT_RECEIPT
                 , A.PRINT_METHOD AS PRINT_METHOD 
                 , A.STOR_PUBL_QTY AS STOR_PUBL_QTY
                 , A.REUSE_YN AS REUSE_YN
                 , A.PRINT_TYPE_1 AS PRINT_TYPE_1
                 , A.PREFACE AS PREFACE
                 , A.MAIN_TEXT AS MAIN_TEXT
                 , A.FOOTER AS FOOTER
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD')AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
                 --, A.PRINT_TYPE_2 AS PRINT_TYPE_2
                 , A.PRINT_TYPE_3 AS PRINT_TYPE_3
                 , A.BILL_COUNT AS BILL_COUNT
                 , A.MENU_COUNT AS MENU_COUNT
                 , A.PRINT_URL AS PRINT_URL
        FROM       PROMOTION_PRINT A
        WHERE      A.PRMT_ID = P_PRMT_ID;
END PROMOTION_PRINT_VIEW;

/
