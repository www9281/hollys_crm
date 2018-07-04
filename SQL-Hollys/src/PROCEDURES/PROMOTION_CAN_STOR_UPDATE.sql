--------------------------------------------------------
--  DDL for Procedure PROMOTION_CAN_STOR_UPDATE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CAN_STOR_UPDATE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 적용매장 사용안함처리
-- Test			:	exec PROMOTION_CAN_STOR_UPDATE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_STOR_CD       IN   VARCHAR2,
        P_USER_ID      IN   VARCHAR2,
        O_PRMT_ID       OUT  VARCHAR2
) AS 
BEGIN
        MERGE INTO PROMOTION_CAN_STOR
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
               AND  STOR_CD = P_STOR_CD
           )
        WHEN MATCHED THEN

        UPDATE    
           SET   USE_YN   = 'N'
                 ,UPD_USER = P_USER_ID
                 ,UPD_DT = SYSDATE
        WHERE    PRMT_ID  = P_PRMT_ID
        AND      STOR_CD  = P_STOR_CD;

       O_PRMT_ID := P_PRMT_ID;

END PROMOTION_CAN_STOR_UPDATE;

/
