--------------------------------------------------------
--  DDL for Procedure STORE_GP_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."STORE_GP_CODE_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-23
-- Description	:	매장그룹 코드 목록 조회
-- Test			:	exec STORE_GP_CODE_SELECT ''
-- ==========================================================================================
        P_USER_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.STOR_GP_ID  AS CODE_CD
                 , A.STOR_GP_NM AS CODE_NM
                 , A.REMARK AS REMARK
        FROM       STORE_GP A
        WHERE      A.USE_YN = 'Y'
        --AND        EXISTS (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y')
        ORDER BY 
                   A.STOR_GP_NM ASC;
END STORE_GP_CODE_SELECT;

/
