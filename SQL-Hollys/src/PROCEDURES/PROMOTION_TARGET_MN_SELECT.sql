--------------------------------------------------------
--  DDL for Procedure PROMOTION_TARGET_MN_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_TARGET_MN_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상메뉴 목록 조회
-- Test			:	exec PROMOTION_TARGET_MN_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.ITEM_CD AS ITEM_CD
                 , B.ITEM_NM AS ITEM_NM
                 , A.ITEM_DIV AS ITEM_DIV
                 , A.QTY AS QTY
                 , B.SALE_PRC AS REGULAR_PRC
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')  AS USE_YN
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_TARGET_MN A
        LEFT JOIN  ITEM B 
        ON         B.ITEM_CD = A.ITEM_CD
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.ITEM_CD ASC;
END PROMOTION_TARGET_MN_SELECT;

/
