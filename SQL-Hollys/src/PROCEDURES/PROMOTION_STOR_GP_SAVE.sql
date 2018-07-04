--------------------------------------------------------
--  DDL for Procedure PROMOTION_STOR_GP_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_STOR_GP_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상매장그룹 등록
-- Test			:	exec PROMOTION_STOR_GP_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_STOR_GP_ID    IN   VARCHAR2,
        P_USE_YN        IN   VARCHAR2,
        P_USER_ID     IN   VARCHAR2,
        O_PRMT_ID       OUT  VARCHAR2
) AS 
BEGIN
        MERGE INTO PROMOTION_STOR_GP
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
               AND  STOR_GP_ID = P_STOR_GP_ID
           )
        WHEN MATCHED THEN

        UPDATE    
           SET   USE_YN   = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                 ,UPD_USER = P_USER_ID
                 ,UPD_DT = SYSDATE
        WHERE    PRMT_ID  = P_PRMT_ID
        AND      STOR_GP_ID  = P_STOR_GP_ID   

        WHEN NOT MATCHED THEN

        INSERT 
        (       PRMT_ID
               ,STOR_GP_ID
               ,USE_YN
               ,INST_USER
               ,INST_DT
               ,UPD_USER
               ,UPD_DT
        ) VALUES (   
                P_PRMT_ID
               ,P_STOR_GP_ID
               ,DECODE(P_USE_YN, 'Y', 'Y', 'N')
               ,P_USER_ID
               ,SYSDATE
               ,P_USER_ID
               ,SYSDATE
        );

       O_PRMT_ID := P_PRMT_ID;

END PROMOTION_STOR_GP_SAVE;

/
