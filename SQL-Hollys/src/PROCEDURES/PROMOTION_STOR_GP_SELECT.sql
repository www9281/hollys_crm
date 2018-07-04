--------------------------------------------------------
--  DDL for Procedure PROMOTION_STOR_GP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_STOR_GP_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상매장그룹 목록 조회
-- Test			:	exec PROMOTION_STOR_GP_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.STOR_GP_ID AS STOR_GP_ID
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N') AS USE_YN
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_STOR_GP A
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.STOR_GP_ID ASC;
END PROMOTION_STOR_GP_SELECT;

/
