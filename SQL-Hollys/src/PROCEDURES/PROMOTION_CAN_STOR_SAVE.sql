--------------------------------------------------------
--  DDL for Procedure PROMOTION_CAN_STOR_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_CAN_STOR_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 적용매장 등록
-- Test			:	exec PROMOTION_CAN_STOR_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN    VARCHAR2,
        P_STOR_CD       IN    VARCHAR2,
        P_USE_YN        IN    CHAR,
        P_USER_ID     IN    VARCHAR2,
        O_PRMT_ID       OUT   VARCHAR2
) AS 
BEGIN

        MERGE INTO PROMOTION_CAN_STOR
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
                AND STOR_CD = P_STOR_CD

           )
        WHEN MATCHED THEN

        UPDATE    
           SET   USE_YN   = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                 ,UPD_USER = P_USER_ID
                 ,UPD_DT = SYSDATE
        WHERE    PRMT_ID  = P_PRMT_ID
        AND      STOR_CD  = P_STOR_CD

        WHEN NOT MATCHED THEN

        INSERT 
        (       PRMT_ID
               ,STOR_CD
               ,USE_YN
               ,INST_USER
               ,INST_DT
               ,UPD_USER
               ,UPD_DT
        ) VALUES (   
                P_PRMT_ID
               ,P_STOR_CD
               ,DECODE(P_USE_YN, 'Y', 'Y', 'N')
               ,P_USER_ID
               ,SYSDATE
               ,P_USER_ID
               ,SYSDATE
        );
        
        O_PRMT_ID := P_PRMT_ID; 

END PROMOTION_CAN_STOR_SAVE;

/
