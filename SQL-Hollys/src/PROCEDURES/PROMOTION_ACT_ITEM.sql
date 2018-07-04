--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_ITEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_ITEM" (
    N_CLASS_L   IN  VARCHAR2,
    N_CLASS_M   IN  VARCHAR2,
    N_CLASS_S   IN  VARCHAR2,
    N_CLASS_D   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN  

    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-20
    -- Description	:	프로모션 본사분담금액 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT
      A.ITEM_CD
      ,A.ITEM_NM
      ,A.SALE_PRC
      ,B.HQ_AMT
    FROM ITEM A, PROMOTION_ACCOUNT_ITEM B
    WHERE A.ITEM_CD = B.ITEM_CD (+)
      AND A.USE_YN = 'Y'
      AND (N_CLASS_L IS NULL OR A.L_CLASS_CD = N_CLASS_L)
      AND (N_CLASS_M IS NULL OR A.M_CLASS_CD = N_CLASS_M)
      AND (N_CLASS_S IS NULL OR A.S_CLASS_CD = N_CLASS_S)
      AND (N_CLASS_D IS NULL OR A.D_CLASS_CD = N_CLASS_D)
    ;
    
END PROMOTION_ACT_ITEM;

/
