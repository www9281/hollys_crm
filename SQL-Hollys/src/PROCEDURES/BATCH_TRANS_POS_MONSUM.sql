--------------------------------------------------------
--  DDL for Procedure BATCH_TRANS_POS_MONSUM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_TRANS_POS_MONSUM" (
  PI_YYMM   IN  VARCHAR2,
  PO_RETC  OUT  VARCHAR2
)
IS
  V_COMP_CD     VARCHAR2(3);
  V_YYMM        VARCHAR2(6);
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-23
  --                   2018-05-23
  -- Description   :   POS DB의 정보이관 프로시저(월집계)
  --                    SALE_JMI, SALE_JMM
  -- ==========================================================================================

  PO_RETC := NULL;

  SELECT '016'
       , DECODE(PI_YYMM,NULL,TO_CHAR(SYSDATE,'YYYYMM'),PI_YYMM)
  INTO   V_COMP_CD
       , V_YYMM
  FROM   DUAL
  ;

  ---------------------------------------------------------------------------------------------------
  --1.부가메뉴 월매출(SALE_JMI)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JMI                          T
      USING (SELECT *
             FROM   SALE_JMI@HPOSDB
             WHERE  COMP_CD    = V_COMP_CD
             AND    SALE_YM    = V_YYMM   )   S
      ON    (    T.SALE_YM     = S.SALE_YM
             AND T.BRAND_CD    = S.BRAND_CD
             AND T.STOR_CD     = S.STOR_CD 
             AND T.ITEM_CD     = S.ITEM_CD 
             AND T.SUB_FG      = S.SUB_FG     
             AND T.SUB_ITEM_CD = S.SUB_ITEM_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.SALE_QTY    = S.SALE_QTY   
                                    , T.SALE_AMT    = S.SALE_AMT   
                                    , T.DC_AMT      = S.DC_AMT     
                                    , T.ENR_AMT     = S.ENR_AMT    
                                    , T.GRD_AMT     = S.GRD_AMT    
                                    , T.GRD_I_AMT   = S.GRD_I_AMT  
                                    , T.GRD_O_AMT   = S.GRD_O_AMT  
                                    , T.VAT_AMT     = S.VAT_AMT    
                                    , T.VAT_I_AMT   = S.VAT_I_AMT  
                                    , T.VAT_O_AMT   = S.VAT_O_AMT  
                                    , T.SVC_AMT     = S.SVC_AMT    
                                    , T.SVC_VAT_AMT = S.SVC_VAT_AMT
      WHEN  NOT MATCHED THEN INSERT ( SALE_YM    , BRAND_CD , STOR_CD    , ITEM_CD, SUB_FG       -- 1, 2, 3, 4, 5
                                    , SUB_ITEM_CD, SALE_QTY , SALE_AMT   , DC_AMT , ENR_AMT      -- 6, 7, 8, 9,10
                                    , GRD_AMT    , GRD_I_AMT, GRD_O_AMT  , VAT_AMT, VAT_I_AMT    --11,12,13,14,15
                                    , VAT_O_AMT  , SVC_AMT  , SVC_VAT_AMT                     )  --16,17,18
                             VALUES ( S.SALE_YM                                                  -- 1.SALE_DT    
                                    , S.BRAND_CD                                                 -- 2.BRAND_CD   
                                    , S.STOR_CD                                                  -- 3.STOR_CD    
                                    , S.ITEM_CD                                                  -- 4.ITEM_CD    
                                    , S.SUB_FG                                                   -- 5.SUB_FG     
                                    , S.SUB_ITEM_CD                                              -- 6.SUB_ITEM_CD
                                    , S.SALE_QTY                                                 -- 7.SALE_QTY   
                                    , S.SALE_AMT                                                 -- 8.SALE_AMT   
                                    , S.DC_AMT                                                   -- 9.DC_AMT     
                                    , S.ENR_AMT                                                  --10.ENR_AMT    
                                    , S.GRD_AMT                                                  --11.GRD_AMT    
                                    , S.GRD_I_AMT                                                --12.GRD_I_AMT  
                                    , S.GRD_O_AMT                                                --13.GRD_O_AMT  
                                    , S.VAT_AMT                                                  --14.VAT_AMT    
                                    , S.VAT_I_AMT                                                --15.VAT_I_AMT  
                                    , S.VAT_O_AMT                                                --16.VAT_O_AMT  
                                    , S.SVC_AMT                                                  --17.SVC_AMT    
                                    , S.SVC_VAT_AMT                                              --18.SVC_VAT_AMT
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '1.부가메뉴 월매출(SALE_JMI)-' || V_YYMM
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --2.상품 월매출(SALE_JMM)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JMM                        T
      USING (SELECT *
             FROM   SALE_JMM@HPOSDB
             WHERE  COMP_CD  = V_COMP_CD
             AND    SALE_YM  = V_YYMM   )   S
      ON    (    T.SALE_YM   = S.SALE_YM
             AND T.BRAND_CD  = S.BRAND_CD
             AND T.STOR_CD   = S.STOR_CD
             AND T.SALE_TYPE = S.SALE_TYPE
             AND T.GIFT_DIV  = S.GIFT_DIV
             AND T.ITEM_CD   = S.ITEM_CD
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.SALE_QTY    = S.SALE_QTY
                                    , T.SALE_AMT    = S.SALE_AMT
                                    , T.DC_AMT      = S.DC_AMT
                                    , T.ENR_AMT     = S.ENR_AMT
                                    , T.GRD_AMT     = S.GRD_AMT
                                    , T.GRD_I_AMT   = S.GRD_I_AMT
                                    , T.GRD_O_AMT   = S.GRD_O_AMT
                                    , T.VAT_AMT     = S.VAT_AMT
                                    , T.VAT_I_AMT   = S.VAT_I_AMT
                                    , T.VAT_O_AMT   = S.VAT_O_AMT
                                    , T.SVC_AMT     = S.SVC_AMT
                                    , T.SVC_VAT_AMT = S.SVC_VAT_AMT
                                    , T.DC_QTY      = S.DC_QTY
                                    , T.FREE_QTY    = S.FREE_QTY
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_YM  , BRAND_CD , STOR_CD    , SALE_TYPE, GIFT_DIV     -- 1, 2, 3, 4, 5
                                    , ITEM_CD  , SALE_QTY , SALE_AMT   , DC_AMT   , ENR_AMT      -- 6, 7, 8, 9,10
                                    , GRD_AMT  , GRD_I_AMT, GRD_O_AMT  , VAT_AMT  , VAT_I_AMT    --11,12,13,14,15
                                    , VAT_O_AMT, SVC_AMT  , SVC_VAT_AMT, DC_QTY   , FREE_QTY  )  --16,17,18,19,20
                             VALUES ( S.SALE_YM                                                  -- 1.SALE_YM
                                    , S.BRAND_CD                                                 -- 2.BRAND_CD
                                    , S.STOR_CD                                                  -- 3.STOR_CD
                                    , S.SALE_TYPE                                                -- 4.SALE_TYPE
                                    , S.GIFT_DIV                                                 -- 5.GIFT_DIV
                                    , S.ITEM_CD                                                  -- 6.ITEM_CD
                                    , S.SALE_QTY                                                 -- 7.SALE_QTY
                                    , S.SALE_AMT                                                 -- 8.SALE_AMT
                                    , S.DC_AMT                                                   -- 9.DC_AMT
                                    , S.ENR_AMT                                                  --10.ENR_AMT
                                    , S.GRD_AMT                                                  --11.GRD_AMT
                                    , S.GRD_I_AMT                                                --12.GRD_I_AMT
                                    , S.GRD_O_AMT                                                --13.GRD_O_AMT
                                    , S.VAT_AMT                                                  --14.VAT_AMT
                                    , S.VAT_I_AMT                                                --15.VAT_I_AMT
                                    , S.VAT_O_AMT                                                --16.VAT_O_AMT
                                    , S.SVC_AMT                                                  --17.SVC_AMT
                                    , S.SVC_VAT_AMT                                              --18.SVC_VAT_AMT
                                    , S.DC_QTY                                                   --19.DC_QTY
                                    , S.FREE_QTY                                                 --20.FREE_QTY
                                    )
      ;
      COMMIT;

      PO_RETC := 'ALL OK-' || V_YYMM;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '2.상품 월매출(SALE_JMM)-' || V_YYMM
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

END BATCH_TRANS_POS_MONSUM;

/
