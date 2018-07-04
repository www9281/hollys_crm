--------------------------------------------------------
--  DDL for Procedure PROMOTION_CODE_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CODE_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	서브프로모션 코드 조회
-- Test			:	exec PROMOTION_CODE_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD     IN   VARCHAR2,
        O_CURSOR      OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS CODE_CD
                 , A.PRMT_NM  AS CODE_NM  
        FROM       PROMOTION A 
        WHERE      A.COMP_CD = P_COMP_CD  
        AND        A.PRMT_NM LIKE '%' || '서브' || '%'
        ORDER BY  
                    A.PRMT_ID DESC;
END PROMOTION_CODE_SELECT;

/
