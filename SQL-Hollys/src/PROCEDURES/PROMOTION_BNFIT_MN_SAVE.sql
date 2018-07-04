--------------------------------------------------------
--  DDL for Procedure PROMOTION_BNFIT_MN_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_BNFIT_MN_SAVE" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 혜택메뉴 등록/수정
-- Test			:	exec PROMOTION_BNFIT_MN_SAVE '002', '', '', '' 
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_BNFIT_DIV     IN   VARCHAR2,
        P_ITEM_CD       IN   VARCHAR2,
        P_QTY           IN   VARCHAR2,
        N_SALE_PRC      IN   VARCHAR2,
        N_SALE_RATE     IN   VARCHAR2,
        P_USE_YN        IN   VARCHAR2,
        N_GIVE_REWARD   IN   VARCHAR2,
        P_DC_AMT_H      IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,
        O_PRMT_ID       OUT  VARCHAR2
) AS 
BEGIN  
        MERGE INTO PROMOTION_BNFIT_MN
        USING DUAL
        ON (
                    PRMT_ID = P_PRMT_ID
              AND   ITEM_CD = P_ITEM_CD 
           )
        WHEN MATCHED THEN

        UPDATE    
           SET   BNFIT_DIV     = P_BNFIT_DIV
                 ,QTY          = P_QTY
                 ,SALE_PRC     = N_SALE_PRC
                 ,SALE_RATE    = N_SALE_RATE
                 ,USE_YN       = DECODE(P_USE_YN, 'Y', 'Y', 'N')
                 ,GIVE_REWARD  = N_GIVE_REWARD
                 ,DC_AMT_H     = P_DC_AMT_H
                 ,UPD_USER     = P_USER_ID
                 ,UPD_DT       = SYSDATE
        WHERE    PRMT_ID       = P_PRMT_ID
        AND      ITEM_CD       = P_ITEM_CD

        WHEN NOT MATCHED THEN

        INSERT 
        (      
                PRMT_ID
                ,ITEM_CD
                ,QTY
                ,SALE_PRC
                ,SALE_RATE
                ,BNFIT_DIV
                ,GIVE_REWARD
                ,DC_AMT_H
                ,USE_YN
                ,INST_USER
                ,INST_DT
                ,UPD_USER
                ,UPD_DT
       ) VALUES (   
                P_PRMT_ID
                ,P_ITEM_CD
                ,P_QTY
                ,N_SALE_PRC
                ,N_SALE_RATE
                ,P_BNFIT_DIV
                ,N_GIVE_REWARD
                ,P_DC_AMT_H
                ,DECODE(P_USE_YN, 'Y', 'Y', 'N')
                ,P_USER_ID
                ,SYSDATE
                ,P_USER_ID
                ,SYSDATE
       );
       
       O_PRMT_ID := P_PRMT_ID;
       
END PROMOTION_BNFIT_MN_SAVE;

/
