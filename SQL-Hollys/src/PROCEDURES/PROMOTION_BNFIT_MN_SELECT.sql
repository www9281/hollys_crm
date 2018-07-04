--------------------------------------------------------
--  DDL for Procedure PROMOTION_BNFIT_MN_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_BNFIT_MN_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 혜택메뉴 목록 조회
-- Test			:	exec PROMOTION_BNFIT_MN_SELECT ''
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT     A.PRMT_ID  AS PRMT_ID
                 , A.ITEM_CD AS ITEM_CD
                 , B.ITEM_NM AS ITEM_NM
                 , A.BNFIT_DIV AS BNFIT_DIV
                 , A.QTY AS QTY
                 , B.SALE_PRC AS REGULAR_PRC
                 , A.SALE_PRC AS SALE_PRC
                 , A.SALE_RATE AS SALE_RATE
                 , A.GIVE_REWARD AS GIVE_REWARD
                 , A.DC_AMT_H AS DC_AMT_H
                 , DECODE(A.USE_YN, 'Y', 'Y', 'N')  AS USE_YN
                 , A.INST_USER AS INST_USER
                 , TO_CHAR(A.INST_DT,'YYYY-MM-DD') AS INST_DT 
                 , A.UPD_USER AS UPD_USER
                 , TO_CHAR(A.UPD_DT,'YYYY-MM-DD') AS UPD_DT
        FROM       PROMOTION_BNFIT_MN A
        LEFT JOIN  ITEM B 
        ON         B.ITEM_CD = A.ITEM_CD 
        WHERE      A.PRMT_ID = P_PRMT_ID
        ORDER BY 
                   A.ITEM_CD ASC;
END PROMOTION_BNFIT_MN_SELECT;

/
