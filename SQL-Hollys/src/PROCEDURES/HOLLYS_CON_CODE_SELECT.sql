--------------------------------------------------------
--  DDL for Procedure HOLLYS_CON_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HOLLYS_CON_CODE_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	할리스콘 코드 조회
-- Test			:	exec HOLLYS_CON_CODE_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD     IN   VARCHAR2,
        P_BRAND_CD    IN   VARCHAR2,
        O_CURSOR      OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     A.PRMT_ID  AS CODE_CD
                 , A.PRMT_NM  AS CODE_NM 
        FROM       PROMOTION A 
        WHERE      A.COMP_CD = P_COMP_CD 
        AND        A.BRAND_CD = P_BRAND_CD
        AND        A.PRMT_CLASS = 'C5004'
        ORDER BY   
                   A.PRMT_NM ASC;
END HOLLYS_CON_CODE_SELECT;

/
