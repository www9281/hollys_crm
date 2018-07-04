--------------------------------------------------------
--  DDL for Procedure PROMOTION_TARGET_MN_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_TARGET_MN_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상메뉴 사용안함처리
-- Test			:	exec PROMOTION_TARGET_MN_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID         IN   VARCHAR2,
        P_ITEM_CD         IN   VARCHAR2,
        P_USER_ID         IN   VARCHAR2,
        O_PRMT_ID         OUT  VARCHAR2
) AS 
BEGIN  
        MERGE INTO PROMOTION_TARGET_MN 
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
              AND   ITEM_CD = P_ITEM_CD
           )
        WHEN MATCHED THEN

        UPDATE    
           SET   USE_YN      = 'N'
                 ,UPD_USER   = P_USER_ID
                 ,UPD_DT     = SYSDATE
        WHERE    PRMT_ID     = P_PRMT_ID
        AND      ITEM_CD     = P_ITEM_CD;

       O_PRMT_ID := P_PRMT_ID;

END PROMOTION_TARGET_MN_UPDATE;

/
