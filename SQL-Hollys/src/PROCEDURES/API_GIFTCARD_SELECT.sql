--------------------------------------------------------
--  DDL for Procedure API_GIFTCARD_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_GIFTCARD_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	모바일전자상품권 목록조회(나의목록)
-- Test			:	exec API_GIFTCARD_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     DECRYPT(A.CARD_ID) AS GIFTCARD_ID
                   ,A.PIN_NO
                   ,A.CUST_ID
                   ,A.CARD_IMG_NM AS CARD_IMG_NM
                   ,TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                   ,TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
                   ,DECODE(A.USE_YN, 'Y', 'Y', 'N') AS USE_YN
        FROM       C_CARD A
        WHERE      A.CUST_ID = P_CUST_ID
        AND        A.REP_CARD_YN = 'N'
        AND        A.COMP_CD = P_COMP_CD      
        --AND        A.BRAND_CD = P_BRAND_CD
        ORDER BY 
                   A.INST_DT DESC;
END API_GIFTCARD_SELECT;

/
