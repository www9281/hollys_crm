--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_ITEM_SAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_ITEM_SAVE" (
    P_ITEM_CD     IN  VARCHAR2,
    N_HQ_AMT      IN  VARCHAR2,
    P_MY_USER_ID  IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
) AS 
BEGIN  
    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-20
    -- Description	:	프로모션 본사분담금액 저장
    -- ==========================================================================================
    MERGE INTO PROMOTION_ACCOUNT_ITEM
    USING DUAL
    ON (ITEM_CD = P_ITEM_CD)
    WHEN NOT MATCHED THEN
      INSERT (
        ITEM_CD
        ,HQ_AMT
        ,INST_DT
        ,INST_USER
      ) VALUES (
        P_ITEM_CD
        ,NVL(N_HQ_AMT, 0)
        ,SYSDATE
        ,P_MY_USER_ID
      )
    WHEN MATCHED THEN
      UPDATE SET
        HQ_AMT = NVL(N_HQ_AMT, 0)
        ,UPD_DT = SYSDATE
        ,UPD_USER = P_MY_USER_ID
    ;
    
END PROMOTION_ACT_ITEM_SAVE;

/
