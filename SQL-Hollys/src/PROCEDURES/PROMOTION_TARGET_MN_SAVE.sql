--------------------------------------------------------
--  DDL for Procedure PROMOTION_TARGET_MN_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_TARGET_MN_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 대상메뉴 등록/수정
-- Test			:	exec PROMOTION_TARGET_MN_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_ITEM_DIV      IN   VARCHAR2,
        P_ITEM_CD       IN   VARCHAR2,
        P_QTY           IN   VARCHAR2,
        P_USE_YN        IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,
        O_PRMT_ID       OUT  VARCHAR2
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
           SET   ITEM_DIV       = P_ITEM_DIV
                 ,QTY           = P_QTY
                 ,USE_YN        = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                 ,UPD_USER      = P_USER_ID
                 ,UPD_DT        = SYSDATE
        WHERE    PRMT_ID        = P_PRMT_ID
        AND      ITEM_CD        = P_ITEM_CD

        WHEN NOT MATCHED THEN

        INSERT 
        (      
                PRMT_ID
                ,ITEM_DIV
                ,ITEM_CD
                ,QTY
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
       ) VALUES (   
                P_PRMT_ID
                ,P_ITEM_DIV
                ,P_ITEM_CD
                ,P_QTY
                ,DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
       );
       
       O_PRMT_ID := P_PRMT_ID;
       
END PROMOTION_TARGET_MN_SAVE;

/
