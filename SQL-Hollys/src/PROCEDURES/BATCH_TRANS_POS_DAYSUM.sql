--------------------------------------------------------
--  DDL for Procedure BATCH_TRANS_POS_DAYSUM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_TRANS_POS_DAYSUM" (
  PI_YMD   IN   VARCHAR2,
  PO_RETC  OUT  VARCHAR2
)
IS
  V_COMP_CD     VARCHAR2(3);
  V_YMD         VARCHAR2(8);
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-05-23
  --                   2018-05-23
  -- Description   :   POS DB의 정보이관 프로시저(일집계)
  --                    SALE_JDD,SALE_JDI,SALE_JDM,SALE_JDS,SALE_JIM,SALE_JTM,SALE_JTS
  -- ==========================================================================================

  PO_RETC := NULL;

  SELECT '016'
       , DECODE(PI_YMD,NULL,TO_CHAR(SYSDATE,'YYYYMMDD'),PI_YMD)
  INTO   V_COMP_CD
       , V_YMD
  FROM   DUAL
  ;

  ---------------------------------------------------------------------------------------------------
  --1.상품 할인 일집계(SALE_JDD)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JDD                       T
      USING (SELECT *
             FROM   SALE_JDD@HPOSDB
             WHERE  COMP_CD = V_COMP_CD
             AND    SALE_DT = V_YMD    )   S
      ON    (    T.SALE_DT  = S.SALE_DT
             AND T.BRAND_CD = S.BRAND_CD
             AND T.STOR_CD  = S.STOR_CD
             AND T.GIFT_DIV = S.GIFT_DIV
             AND T.ITEM_CD  = S.ITEM_CD
             AND T.FREE_DIV = S.FREE_DIV
             AND T.DC_DIV   = S.DC_DIV
             AND T.DC_RATE  = S.DC_RATE
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
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT , BRAND_CD , STOR_CD  , GIFT_DIV , ITEM_CD        -- 1, 2, 3, 4, 5
                                    , FREE_DIV, DC_DIV   , DC_RATE  , SALE_QTY , SALE_AMT       -- 6, 7, 8, 9,10
                                    , DC_AMT  , ENR_AMT  , GRD_AMT  , GRD_I_AMT, GRD_O_AMT      --11,12,13,14,15
                                    , VAT_AMT , VAT_I_AMT, VAT_O_AMT, SVC_AMT  , SVC_VAT_AMT    --16,17,18,19,20
                                    , DC_QTY  , FREE_QTY                                     )  --21,22
                             VALUES ( S.SALE_DT                                                 -- 1.SALE_DT
                                    , S.BRAND_CD                                                -- 2.BRAND_CD
                                    , S.STOR_CD                                                 -- 3.STOR_CD
                                    , S.GIFT_DIV                                                -- 4.GIFT_DIV
                                    , S.ITEM_CD                                                 -- 5.ITEM_CD
                                    , S.FREE_DIV                                                -- 6.FREE_DIV
                                    , S.DC_DIV                                                  -- 7.DC_DIV
                                    , S.DC_RATE                                                 -- 8.DC_RATE
                                    , S.SALE_QTY                                                -- 9.SALE_QTY
                                    , S.SALE_AMT                                                --10.SALE_AMT
                                    , S.DC_AMT                                                  --11.DC_AMT
                                    , S.ENR_AMT                                                 --12.ENR_AMT
                                    , S.GRD_AMT                                                 --13.GRD_AMT
                                    , S.GRD_I_AMT                                               --14.GRD_I_AMT
                                    , S.GRD_O_AMT                                               --15.GRD_O_AMT
                                    , S.VAT_AMT                                                 --16.VAT_AMT
                                    , S.VAT_I_AMT                                               --17.VAT_I_AMT
                                    , S.VAT_O_AMT                                               --18.VAT_O_AMT
                                    , S.SVC_AMT                                                 --19.SVC_AMT
                                    , S.SVC_VAT_AMT                                             --20.SVC_VAT_AMT
                                    , S.DC_QTY                                                  --21.DC_QTY
                                    , S.FREE_QTY                                                --22.FREE_QTY
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '1.상품 할인 일집계(SALE_JDD)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --2.메뉴 부가상품 일집계(SALE_JDI)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JDI                          T
      USING (SELECT *
             FROM   SALE_JDI@HPOSDB
             WHERE  COMP_CD    = V_COMP_CD
             AND    SALE_DT    = V_YMD    )   S
      ON    (    T.SALE_DT     = S.SALE_DT
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
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT    , BRAND_CD , STOR_CD    , ITEM_CD, SUB_FG       -- 1, 2, 3, 4, 5
                                    , SUB_ITEM_CD, SALE_QTY , SALE_AMT   , DC_AMT , ENR_AMT      -- 6, 7, 8, 9,10
                                    , GRD_AMT    , GRD_I_AMT, GRD_O_AMT  , VAT_AMT, VAT_I_AMT    --11,12,13,14,15
                                    , VAT_O_AMT  , SVC_AMT  , SVC_VAT_AMT                     )  --16,17,18
                             VALUES ( S.SALE_DT                                                  -- 1.SALE_DT
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
        PO_RETC := '2.메뉴 부가상품 일집계(SALE_JDI)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --3.상품 일매출(SALE_JDM)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JDM                        T
      USING (SELECT *
             FROM   SALE_JDM@HPOSDB
             WHERE  COMP_CD  = V_COMP_CD
             AND    SALE_DT  = V_YMD    )   S
      ON    (    T.SALE_DT   = S.SALE_DT
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
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT  , BRAND_CD , STOR_CD    , SALE_TYPE, GIFT_DIV     -- 1, 2, 3, 4, 5
                                    , ITEM_CD  , SALE_QTY , SALE_AMT   , DC_AMT   , ENR_AMT      -- 6, 7, 8, 9,10
                                    , GRD_AMT  , GRD_I_AMT, GRD_O_AMT  , VAT_AMT  , VAT_I_AMT    --11,12,13,14,15
                                    , VAT_O_AMT, SVC_AMT  , SVC_VAT_AMT, DC_QTY   , FREE_QTY  )  --16,17,18,19,20
                             VALUES ( S.SALE_DT                                                  -- 1.SALE_DT
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
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '3.상품 일매출(SALE_JDM)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --4.고객 유형별 매출 일집계(SALE_JDS)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JDS                        T
      USING (SELECT *
             FROM   SALE_JDS@HPOSDB
             WHERE  COMP_CD  = V_COMP_CD
             AND    SALE_DT  = V_YMD    )   S
      ON    (    T.SALE_DT   = S.SALE_DT
             AND T.BRAND_CD  = S.BRAND_CD
             AND T.STOR_CD   = S.STOR_CD
             AND T.SALE_TYPE = S.SALE_TYPE
             AND T.GIFT_DIV  = S.GIFT_DIV
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.BILL_CNT    = S.BILL_CNT
                                    , T.CUST_M_CNT  = S.CUST_M_CNT
                                    , T.CUST_F_CNT  = S.CUST_F_CNT
                                    , T.ETC_M_CNT   = S.ETC_M_CNT
                                    , T.ETC_F_CNT   = S.ETC_F_CNT
                                    , T.TABLE_CNT   = S.TABLE_CNT
                                    , T.STAY_TIME   = S.STAY_TIME
                                    , T.SALE_QTY    = S.SALE_QTY
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
                                    , T.R_BILL_CNT  = S.R_BILL_CNT
                                    , T.R_SALE_QTY  = S.R_SALE_QTY
                                    , T.R_SALE_AMT  = S.R_SALE_AMT
                                    , T.R_GRD_AMT   = S.R_GRD_AMT
                                    , T.R_VAT_AMT   = S.R_VAT_AMT
                                    , T.SAV_PT      = S.SAV_PT
                                    , T.SAV_MLG     = S.SAV_MLG
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT   , BRAND_CD  , STOR_CD   , SALE_TYPE  , GIFT_DIV     -- 1, 2, 3, 4, 5
                                    , BILL_CNT  , CUST_M_CNT, CUST_F_CNT, ETC_M_CNT  , ETC_F_CNT    -- 6, 7, 8, 9,10
                                    , TABLE_CNT , STAY_TIME , SALE_QTY  , SALE_AMT   , DC_AMT       --11,12,13,14,15
                                    , ENR_AMT   , GRD_AMT   , GRD_I_AMT , GRD_O_AMT  , VAT_AMT      --16,17,18,19,20
                                    , VAT_I_AMT , VAT_O_AMT , SVC_AMT   , SVC_VAT_AMT, R_BILL_CNT   --21,22,23,24,25
                                    , R_SALE_QTY, R_SALE_AMT, R_GRD_AMT , R_VAT_AMT  , SAV_PT       --26,27,28,29,30
                                    , SAV_MLG                                                     ) --31
                             VALUES ( S.SALE_DT                                                     -- 1.SALE_DT
                                    , S.BRAND_CD                                                    -- 2.BRAND_CD
                                    , S.STOR_CD                                                     -- 3.STOR_CD
                                    , S.SALE_TYPE                                                   -- 4.SALE_TYPE
                                    , S.GIFT_DIV                                                    -- 5.GIFT_DIV
                                    , S.BILL_CNT                                                    -- 6.BILL_CNT
                                    , S.CUST_M_CNT                                                  -- 7.CUST_M_CNT
                                    , S.CUST_F_CNT                                                  -- 8.CUST_F_CNT
                                    , S.ETC_M_CNT                                                   -- 9.ETC_M_CNT
                                    , S.ETC_F_CNT                                                   --10.ETC_F_CNT
                                    , S.TABLE_CNT                                                   --11.TABLE_CNT
                                    , S.STAY_TIME                                                   --12.STAY_TIME
                                    , S.SALE_QTY                                                    --13.SALE_QTY
                                    , S.SALE_AMT                                                    --14.SALE_AMT
                                    , S.DC_AMT                                                      --15.DC_AMT
                                    , S.ENR_AMT                                                     --16.ENR_AMT
                                    , S.GRD_AMT                                                     --17.GRD_AMT
                                    , S.GRD_I_AMT                                                   --18.GRD_I_AMT
                                    , S.GRD_O_AMT                                                   --19.GRD_O_AMT
                                    , S.VAT_AMT                                                     --20.VAT_AMT
                                    , S.VAT_I_AMT                                                   --21.VAT_I_AMT
                                    , S.VAT_O_AMT                                                   --22.VAT_O_AMT
                                    , S.SVC_AMT                                                     --23.SVC_AMT
                                    , S.SVC_VAT_AMT                                                 --24.SVC_VAT_AMT
                                    , S.R_BILL_CNT                                                  --25.R_BILL_CNT
                                    , S.R_SALE_QTY                                                  --26.R_SALE_QTY
                                    , S.R_SALE_AMT                                                  --27.R_SALE_AMT
                                    , S.R_GRD_AMT                                                   --28.R_GRD_AMT
                                    , S.R_VAT_AMT                                                   --29.R_VAT_AMT
                                    , S.SAV_PT                                                      --30.SAV_PT
                                    , S.SAV_MLG                                                     --31.SAV_MLG
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '4.고객 유형별 매출 일집계(SALE_JDS)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --5.부가메뉴 시간대 일매출(SALE_JIM)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JIM                          T
      USING (SELECT *
             FROM   SALE_JIM@HPOSDB
             WHERE  COMP_CD    = V_COMP_CD
             AND    SALE_DT    = V_YMD    )   S
      ON    (    T.SALE_DT     = S.SALE_DT
             AND T.BRAND_CD    = S.BRAND_CD
             AND T.STOR_CD     = S.STOR_CD
             AND T.SEC_DIV     = S.SEC_DIV
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
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT  , BRAND_CD   , STOR_CD  , SEC_DIV    , ITEM_CD    -- 1, 2, 3, 4, 5
                                    , SUB_FG   , SUB_ITEM_CD, SALE_QTY , SALE_AMT   , DC_AMT     -- 6, 7, 8, 9,10
                                    , ENR_AMT  , GRD_AMT    , GRD_I_AMT, GRD_O_AMT  , VAT_AMT    --11,12,13,14,15
                                    , VAT_I_AMT, VAT_O_AMT  , SVC_AMT  , SVC_VAT_AMT          )  --16,17,18,19
                             VALUES ( S.SALE_DT                                                  -- 1.SALE_DT
                                    , S.BRAND_CD                                                 -- 2.BRAND_CD
                                    , S.STOR_CD                                                  -- 3.STOR_CD
                                    , S.SEC_DIV                                                  -- 4.SEC_DIV
                                    , S.ITEM_CD                                                  -- 5.ITEM_CD
                                    , S.SUB_FG                                                   -- 6.SUB_FG
                                    , S.SUB_ITEM_CD                                              -- 7.SUB_ITEM_CD
                                    , S.SALE_QTY                                                 -- 8.SALE_QTY
                                    , S.SALE_AMT                                                 -- 9.SALE_AMT
                                    , S.DC_AMT                                                   --10.DC_AMT
                                    , S.ENR_AMT                                                  --11.ENR_AMT
                                    , S.GRD_AMT                                                  --12.GRD_AMT
                                    , S.GRD_I_AMT                                                --13.GRD_I_AMT
                                    , S.GRD_O_AMT                                                --14.GRD_O_AMT
                                    , S.VAT_AMT                                                  --15.VAT_AMT
                                    , S.VAT_I_AMT                                                --16.VAT_I_AMT
                                    , S.VAT_O_AMT                                                --17.VAT_O_AMT
                                    , S.SVC_AMT                                                  --18.SVC_AMT
                                    , S.SVC_VAT_AMT                                              --19.SVC_VAT_AMT
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '5.부가메뉴 시간대 일매출(SALE_JIM)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --6.상품 시간대 일매출(SALE_JTM)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JTM                        T
      USING (SELECT *
             FROM   SALE_JTM@HPOSDB
             WHERE  COMP_CD  = V_COMP_CD
             AND    SALE_DT  = V_YMD    )   S
      ON    (    T.SALE_DT   = S.SALE_DT
             AND T.BRAND_CD  = S.BRAND_CD
             AND T.STOR_CD   = S.STOR_CD
             AND T.SALE_TYPE = S.SALE_TYPE
             AND T.SEC_FG    = S.SEC_FG
             AND T.SEC_DIV   = S.SEC_DIV
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
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT  , BRAND_CD , STOR_CD  , SALE_TYPE  , SEC_FG     -- 1, 2, 3, 4, 5
                                    , SEC_DIV  , ITEM_CD  , SALE_QTY , SALE_AMT   , DC_AMT     -- 6, 7, 8, 9,10
                                    , ENR_AMT  , GRD_AMT  , GRD_I_AMT, GRD_O_AMT  , VAT_AMT    --11,12,13,14,15
                                    , VAT_I_AMT, VAT_O_AMT, SVC_AMT  , SVC_VAT_AMT          )  --16,17,18,19
                             VALUES ( S.SALE_DT                                                -- 1.SALE_DT
                                    , S.BRAND_CD                                               -- 2.BRAND_CD
                                    , S.STOR_CD                                                -- 3.STOR_CD
                                    , S.SALE_TYPE                                              -- 4.SALE_TYPE
                                    , S.SEC_FG                                                 -- 5.SEC_FG
                                    , S.SEC_DIV                                                -- 6.SEC_DIV
                                    , S.ITEM_CD                                                -- 7.ITEM_CD
                                    , S.SALE_QTY                                               -- 8.SALE_QTY
                                    , S.SALE_AMT                                               -- 9.SALE_AMT
                                    , S.DC_AMT                                                 --10.DC_AMT
                                    , S.ENR_AMT                                                --11.ENR_AMT
                                    , S.GRD_AMT                                                --12.GRD_AMT
                                    , S.GRD_I_AMT                                              --13.GRD_I_AMT
                                    , S.GRD_O_AMT                                              --14.GRD_O_AMT
                                    , S.VAT_AMT                                                --15.VAT_AMT
                                    , S.VAT_I_AMT                                              --16.VAT_I_AMT
                                    , S.VAT_O_AMT                                              --17.VAT_O_AMT
                                    , S.SVC_AMT                                                --18.SVC_AMT
                                    , S.SVC_VAT_AMT                                            --19.SVC_VAT_AMT
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '6.상품 시간대 일매출(SALE_JTM)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

  ---------------------------------------------------------------------------------------------------
  --7.시간대별 고객 유형별 매출 일집계(SALE_JTS)...
  ---------------------------------------------------------------------------------------------------
  IF PO_RETC IS NULL THEN
    BEGIN
      MERGE
      INTO  SALE_JTS                        T
      USING (SELECT *
             FROM   SALE_JTS@HPOSDB
             WHERE  COMP_CD  = V_COMP_CD
             AND    SALE_DT  = V_YMD    )   S
      ON    (    T.SALE_DT   = S.SALE_DT
             AND T.BRAND_CD  = S.BRAND_CD
             AND T.STOR_CD   = S.STOR_CD
             AND T.SALE_TYPE = S.SALE_TYPE
             AND T.GIFT_DIV  = S.GIFT_DIV
             AND T.SEC_FG    = S.SEC_FG
             AND T.SEC_DIV   = S.SEC_DIV
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.BILL_CNT    = S.BILL_CNT
                                    , T.CUST_M_CNT  = S.CUST_M_CNT
                                    , T.CUST_F_CNT  = S.CUST_F_CNT
                                    , T.ETC_M_CNT   = S.ETC_M_CNT
                                    , T.ETC_F_CNT   = S.ETC_F_CNT
                                    , T.TABLE_CNT   = S.TABLE_CNT
                                    , T.STAY_TIME   = S.STAY_TIME
                                    , T.SALE_QTY    = S.SALE_QTY
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
                                    , T.R_BILL_CNT  = S.R_BILL_CNT
                                    , T.R_SALE_QTY  = S.R_SALE_QTY
                                    , T.R_SALE_AMT  = S.R_SALE_AMT
                                    , T.R_GRD_AMT   = S.R_GRD_AMT
                                    , T.R_VAT_AMT   = S.R_VAT_AMT
                                    , T.SAV_PT      = S.SAV_PT
                                    , T.SAV_MLG     = S.SAV_MLG
                                    , T.UPD_DT      = SYSDATE
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT    , BRAND_CD  , STOR_CD   , SALE_TYPE , GIFT_DIV     -- 1, 2, 3, 4, 5
                                    , SEC_FG     , SEC_DIV   , BILL_CNT  , CUST_M_CNT, CUST_F_CNT   -- 6, 7, 8, 9,10
                                    , ETC_M_CNT  , ETC_F_CNT , TABLE_CNT , STAY_TIME , SALE_QTY     --11,12,13,14,15
                                    , SALE_AMT   , DC_AMT    , ENR_AMT   , GRD_AMT   , GRD_I_AMT    --16,17,18,19,20
                                    , GRD_O_AMT  , VAT_AMT   , VAT_I_AMT , VAT_O_AMT , SVC_AMT      --21,22,23,24,25
                                    , SVC_VAT_AMT, R_BILL_CNT, R_SALE_QTY, R_SALE_AMT, R_GRD_AMT    --26,27,28,29,30
                                    , R_VAT_AMT  , SAV_PT    , SAV_MLG                           )  --31,32,33
                             VALUES ( S.SALE_DT                                                     -- 1.SALE_DT
                                    , S.BRAND_CD                                                    -- 2.BRAND_CD
                                    , S.STOR_CD                                                     -- 3.STOR_CD
                                    , S.SALE_TYPE                                                   -- 4.SALE_TYPE
                                    , S.GIFT_DIV                                                    -- 5.GIFT_DIV
                                    , S.SEC_FG                                                      -- 6.SEC_FG
                                    , S.SEC_DIV                                                     -- 7.SEC_DIV
                                    , S.BILL_CNT                                                    -- 8.BILL_CNT
                                    , S.CUST_M_CNT                                                  -- 9.CUST_M_CNT
                                    , S.CUST_F_CNT                                                  --10.CUST_F_CNT
                                    , S.ETC_M_CNT                                                   --11.ETC_M_CNT
                                    , S.ETC_F_CNT                                                   --12.ETC_F_CNT
                                    , S.TABLE_CNT                                                   --13.TABLE_CNT
                                    , S.STAY_TIME                                                   --14.STAY_TIME
                                    , S.SALE_QTY                                                    --15.SALE_QTY
                                    , S.SALE_AMT                                                    --16.SALE_AMT
                                    , S.DC_AMT                                                      --17.DC_AMT
                                    , S.ENR_AMT                                                     --18.ENR_AMT
                                    , S.GRD_AMT                                                     --19.GRD_AMT
                                    , S.GRD_I_AMT                                                   --20.GRD_I_AMT
                                    , S.GRD_O_AMT                                                   --21.GRD_O_AMT
                                    , S.VAT_AMT                                                     --22.VAT_AMT
                                    , S.VAT_I_AMT                                                   --23.VAT_I_AMT
                                    , S.VAT_O_AMT                                                   --24.VAT_O_AMT
                                    , S.SVC_AMT                                                     --25.SVC_AMT
                                    , S.SVC_VAT_AMT                                                 --26.SVC_VAT_AMT
                                    , S.R_BILL_CNT                                                  --27.R_BILL_CNT
                                    , S.R_SALE_QTY                                                  --28.R_SALE_QTY
                                    , S.R_SALE_AMT                                                  --29.R_SALE_AMT
                                    , S.R_GRD_AMT                                                   --30.R_GRD_AMT
                                    , S.R_VAT_AMT                                                   --31.R_VAT_AMT
                                    , S.SAV_PT                                                      --32.SAV_PT
                                    , S.SAV_MLG                                                     --33.SAV_MLG
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        PO_RETC := '7.시간대별 고객 유형별 매출 일집계(SALE_JTS)-' || V_YMD
                || '('
                || SQLERRM
                || ')';
    END;
  END IF;

    PO_RETC := 'ALL OK-' || V_YMD;

END BATCH_TRANS_POS_DAYSUM;

/
