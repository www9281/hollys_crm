--------------------------------------------------------
--  DDL for Procedure PROMOTION_BNFIT_MN_GP_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_BNFIT_MN_GP_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 혜택메뉴군 목록 조회
-- Test			:	exec PROMOTION_BNFIT_MN_GP_SELECT '002'
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
                 , A.BNFIT_DIV AS BNFIT_DIV
                 , A.QTY AS QTY
                 , A.SALE_PRC AS SALE_PRC
                 , A.SALE_RATE AS SALE_RATE
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_BNFIT_MN_GP A
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.D_CLASS_CD ASC;
END PROMOTION_BNFIT_MN_GP_SELECT;

/
