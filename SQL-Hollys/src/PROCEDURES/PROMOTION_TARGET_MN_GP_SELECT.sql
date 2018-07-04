--------------------------------------------------------
--  DDL for Procedure PROMOTION_TARGET_MN_GP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_TARGET_MN_GP_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상메뉴군 목록 조회
-- Test			:	exec PROMOTION_TARGET_MN_GP_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.L_CLASS_CD AS L_CLASS_CD
                 , A.M_CLASS_CD AS M_CLASS_CD
                 , A.S_CLASS_CD AS S_CLASS_CD
                 , A.D_CLASS_CD AS D_CLASS_CD
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')  AS USE_YN
                 , A.ITEM_DIV AS ITEM_DIV
                 , A.QTY AS QTY
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_TARGET_MN_GP A
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.D_CLASS_CD ASC;
END PROMOTION_TARGET_MN_GP_SELECT;

/
