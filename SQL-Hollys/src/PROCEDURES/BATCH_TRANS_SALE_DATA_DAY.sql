--------------------------------------------------------
--  DDL for Procedure BATCH_TRANS_SALE_DATA_DAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_TRANS_SALE_DATA_DAY" (
  PI_STR_DT  IN   VARCHAR2,
  PO_RET_CD  OUT  VARCHAR2
)
IS
BEGIN 
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-04-23
  -- Description   :   POS DB의 SALE_HD, SALE_DT, SALE_ST, SALE_DC 정보이관 프로시저
  -- ==========================================================================================

  PO_RET_CD := NULL;

  ---------------------------------------------------------------------------------------------
  -----------------------------------------  SALE_HD  -----------------------------------------
  ---------------------------------------------------------------------------------------------
  IF PO_RET_CD IS NULL THEN 
    BEGIN
      MERGE
      INTO  SALE_HD                         T
      USING (SELECT *
             FROM   SALE_HD@HPOSDB
             WHERE  COMP_CD = '016'
             AND    SALE_DT = PI_STR_DT)    S
      ON    (    T.COMP_CD  = S.COMP_CD
             AND T.SALE_DT  = S.SALE_DT
             AND T.BRAND_CD = S.BRAND_CD
             AND T.STOR_CD  = S.STOR_CD
             AND T.POS_NO   = S.POS_NO
             AND T.BILL_NO  = S.BILL_NO
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.CASHIER_ID     = S.CASHIER_ID
                                    , T.SALE_DIV       = S.SALE_DIV
                                    , T.GIFT_DIV       = S.GIFT_DIV
                                    , T.SORD_TM        = S.SORD_TM
                                    , T.SALE_TM        = S.SALE_TM
                                    , T.ORDER_NO       = S.ORDER_NO
                                    , T.FLOOR          = S.FLOOR
                                    , T.TABLE_NO       = S.TABLE_NO
                                    , T.TABLE_CNT      = S.TABLE_CNT
                                    , T.FOREIGN_DIV    = S.FOREIGN_DIV
                                    , T.CUST_SEX       = S.CUST_SEX
                                    , T.CUST_AGE       = S.CUST_AGE
                                    , T.CUST_M_CNT     = S.CUST_M_CNT
                                    , T.CUST_F_CNT     = S.CUST_F_CNT
                                    , T.VOID_BEFORE_DT = S.VOID_BEFORE_DT
                                    , T.VOID_BEFORE_NO = S.VOID_BEFORE_NO
                                    , T.RTN_REASON_CD  = S.RTN_REASON_CD
                                    , T.RTN_MEMO       = S.RTN_MEMO
                                    , T.SALE_QTY       = S.SALE_QTY
                                    , T.SALE_AMT       = S.SALE_AMT
                                    , T.DC_AMT         = S.DC_AMT
                                    , T.ENR_AMT        = S.ENR_AMT
                                    , T.GRD_I_AMT      = S.GRD_I_AMT
                                    , T.GRD_O_AMT      = S.GRD_O_AMT
                                    , T.VAT_I_AMT      = S.VAT_I_AMT
                                    , T.VAT_O_AMT      = S.VAT_O_AMT
                                    , T.SVC_AMT        = S.SVC_AMT
                                    , T.SVC_DC_AMT     = S.SVC_DC_AMT
                                    , T.SVC_VAT_AMT    = S.SVC_VAT_AMT
                                    , T.CREDIT_AMT     = S.CREDIT_AMT
                                    , T.PACK_AMT       = S.PACK_AMT
                                    , T.SALER_DT       = S.SALER_DT
                                    , T.SAP_IF_YN      = S.SAP_IF_YN
                                    , T.SAP_IF_DT      = S.SAP_IF_DT
                                    , T.SALE_TYPE      = S.SALE_TYPE
                                    , T.CNT_ORD_NO     = S.CNT_ORD_NO
                                    , T.SAV_MLG        = S.SAV_MLG
                                    , T.SAV_PT         = S.SAV_PT
                                    , T.CUST_ID        = S.CUST_ID
                                    , T.CARD_ID        = S.CARD_ID
                                    , T.CUST_NM        = S.CUST_NM
                                    , T.INST_DT        = S.INST_DT
                                    , T.SEND_YN        = 'N'
      WHEN  NOT MATCHED THEN INSERT ( COMP_CD   , SALE_DT   , BRAND_CD      , STOR_CD       , POS_NO       , BILL_NO      -- 1, 2, 3, 4, 5, 6
                                    , CASHIER_ID, SALE_DIV  , GIFT_DIV      , SORD_TM       , SALE_TM      , ORDER_NO     -- 7, 8, 9,10,11,12
                                    , FLOOR     , TABLE_NO  , TABLE_CNT     , FOREIGN_DIV   , CUST_SEX     , CUST_AGE     --13,14,15,16,17,18
                                    , CUST_M_CNT, CUST_F_CNT, VOID_BEFORE_DT, VOID_BEFORE_NO, RTN_REASON_CD, RTN_MEMO     --19,20,21,22,23,24
                                    , SALE_QTY  , SALE_AMT  , DC_AMT        , ENR_AMT       , GRD_I_AMT    , GRD_O_AMT    --25,26,27,28,29,30
                                    , VAT_I_AMT , VAT_O_AMT , SVC_AMT       , SVC_DC_AMT    , SVC_VAT_AMT  , CREDIT_AMT   --31,32,33,34,35,36
                                    , PACK_AMT  , SALER_DT  , SAP_IF_YN     , SAP_IF_DT     , SALE_TYPE    , CNT_ORD_NO   --37,38,39,40,41,42
                                    , SAV_MLG   , SAV_PT    , CUST_ID       , CARD_ID       , CUST_NM      , INST_DT      --43,44,45,46,47,48
                                    , SEND_YN                                                                          )  --49
                             VALUES ( S.COMP_CD                                                                           -- 1.COMP_CD
                                    , S.SALE_DT                                                                           -- 2.SALE_DT
                                    , S.BRAND_CD                                                                          -- 3.BRAND_CD
                                    , S.STOR_CD                                                                           -- 4.STOR_CD
                                    , S.POS_NO                                                                            -- 5.POS_NO
                                    , S.BILL_NO                                                                           -- 6.BILL_NO
                                    , S.CASHIER_ID                                                                        -- 7.CASHIER_ID
                                    , S.SALE_DIV                                                                          -- 8.SALE_DIV
                                    , S.GIFT_DIV                                                                          -- 9.GIFT_DIV
                                    , S.SORD_TM                                                                           --10.SORD_TM
                                    , S.SALE_TM                                                                           --11.SALE_TM
                                    , S.ORDER_NO                                                                          --12.ORDER_NO
                                    , S.FLOOR                                                                             --13.FLOOR
                                    , S.TABLE_NO                                                                          --14.TABLE_NO
                                    , S.TABLE_CNT                                                                         --15.TABLE_CNT
                                    , S.FOREIGN_DIV                                                                       --16.FOREIGN_DIV
                                    , S.CUST_SEX                                                                          --17.CUST_SEX
                                    , S.CUST_AGE                                                                          --18.CUST_AGE
                                    , S.CUST_M_CNT                                                                        --19.CUST_M_CNT
                                    , S.CUST_F_CNT                                                                        --20.CUST_F_CNT
                                    , S.VOID_BEFORE_DT                                                                    --21.VOID_BEFORE_DT
                                    , S.VOID_BEFORE_NO                                                                    --22.VOID_BEFORE_NO
                                    , S.RTN_REASON_CD                                                                     --23.RTN_REASON_CD
                                    , S.RTN_MEMO                                                                          --24.RTN_MEMO
                                    , S.SALE_QTY                                                                          --25.SALE_QTY
                                    , S.SALE_AMT                                                                          --26.SALE_AMT
                                    , S.DC_AMT                                                                            --27.DC_AMT
                                    , S.ENR_AMT                                                                           --28.ENR_AMT
                                    , S.GRD_I_AMT                                                                         --29.GRD_I_AMT
                                    , S.GRD_O_AMT                                                                         --30.GRD_O_AMT
                                    , S.VAT_I_AMT                                                                         --31.VAT_I_AMT
                                    , S.VAT_O_AMT                                                                         --32.VAT_O_AMT
                                    , S.SVC_AMT                                                                           --33.SVC_AMT
                                    , S.SVC_DC_AMT                                                                        --34.SVC_DC_AMT
                                    , S.SVC_VAT_AMT                                                                       --35.SVC_VAT_AMT
                                    , S.CREDIT_AMT                                                                        --36.CREDIT_AMT
                                    , S.PACK_AMT                                                                          --37.PACK_AMT
                                    , S.SALER_DT                                                                          --38.SALER_DT
                                    , S.SAP_IF_YN                                                                         --39.SAP_IF_YN
                                    , S.SAP_IF_DT                                                                         --40.SAP_IF_DT
                                    , S.SALE_TYPE                                                                         --41.SALE_TYPE
                                    , S.CNT_ORD_NO                                                                        --42.CNT_ORD_NO
                                    , S.SAV_MLG                                                                           --43.SAV_MLG
                                    , S.SAV_PT                                                                            --44.SAV_PT
                                    , S.CUST_ID                                                                           --45.CUST_ID
                                    , S.CARD_ID                                                                           --46.CARD_ID
                                    , S.CUST_NM                                                                           --47.CUST_NM
                                    , S.INST_DT                                                                           --48.INST_DT
                                    , 'N'                                                                                 --49.SEND_YN
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN 
        ROLLBACK;
        PO_RET_CD := 'HD-' || PI_STR_DT
                  || '('   || SQLERRM   || ')';
    END;
  END IF;  

  ---------------------------------------------------------------------------------------------
  -----------------------------------------  SALE_DT  -----------------------------------------
  ---------------------------------------------------------------------------------------------
  IF PO_RET_CD IS NULL THEN 
    BEGIN
      MERGE
      INTO  SALE_DT                         T
      USING (SELECT *
             FROM   SALE_DT@HPOSDB
             WHERE  COMP_CD = '016'
             AND    SALE_DT = PI_STR_DT)    S
      ON    (    T.COMP_CD  = S.COMP_CD
             AND T.SALE_DT  = S.SALE_DT
             AND T.BRAND_CD = S.BRAND_CD
             AND T.STOR_CD  = S.STOR_CD
             AND T.POS_NO   = S.POS_NO
             AND T.BILL_NO  = S.BILL_NO
             AND T.SEQ      = S.SEQ
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.SALE_DIV        = S.SALE_DIV
                                    , T.TAKE_DIV        = S.TAKE_DIV
                                    , T.GIFT_DIV        = S.GIFT_DIV
                                    , T.SORD_TM         = S.SORD_TM
                                    , T.DELIVER_TM      = S.DELIVER_TM
                                    , T.SALE_TM         = S.SALE_TM
                                    , T.ITEM_CD         = S.ITEM_CD
                                    , T.MAIN_ITEM_CD    = S.MAIN_ITEM_CD
                                    , T.T_SEQ           = S.T_SEQ
                                    , T.ITEM_SET_DIV    = S.ITEM_SET_DIV
                                    , T.PACK_DIV        = S.PACK_DIV
                                    , T.SUB_ITEM_DIV    = S.SUB_ITEM_DIV
                                    , T.SUB_TOUCH_DIV   = S.SUB_TOUCH_DIV
                                    , T.SUB_TOUCH_GR_CD = S.SUB_TOUCH_GR_CD
                                    , T.SUB_TOUCH_CD    = S.SUB_TOUCH_CD
                                    , T.SUB_ITEM_CD     = S.SUB_ITEM_CD
                                    , T.TR_GR_NO        = S.TR_GR_NO
                                    , T.FREE_DIV        = S.FREE_DIV
                                    , T.DC_DIV          = S.DC_DIV
                                    , T.SALE_QTY        = S.SALE_QTY
                                    , T.SALE_PRC        = S.SALE_PRC
                                    , T.SALE_AMT        = S.SALE_AMT
                                    , T.DC_RATE         = S.DC_RATE
                                    , T.DC_AMT          = S.DC_AMT
                                    , T.ENR_AMT         = S.ENR_AMT
                                    , T.GRD_AMT         = S.GRD_AMT
                                    , T.NET_AMT         = S.NET_AMT
                                    , T.VAT_RATE        = S.VAT_RATE
                                    , T.VAT_AMT         = S.VAT_AMT
                                    , T.SVC_RATE        = S.SVC_RATE
                                    , T.SVC_AMT         = S.SVC_AMT
                                    , T.SVC_VAT_AMT     = S.SVC_VAT_AMT
                                    , T.SALER_DT        = S.SALER_DT
                                    , T.SALE_TYPE       = S.SALE_TYPE
                                    , T.RTN_DIV         = S.RTN_DIV
                                    , T.USER_ID         = S.USER_ID
                                    , T.CUST_ID         = S.CUST_ID
                                    , T.CARD_ID         = S.CARD_ID
                                    , T.SAV_MLG         = S.SAV_MLG
                                    , T.SAV_PT          = S.SAV_PT
                                    , T.DC_QTY          = S.DC_QTY
                                    , T.FREE_QTY        = S.FREE_QTY
                                    , T.INST_DT         = S.INST_DT
                                    , T.SEND_YN         = 'N'
      WHEN  NOT MATCHED THEN INSERT ( COMP_CD        , SALE_DT     , BRAND_CD   , STOR_CD     , POS_NO         -- 1, 2, 3, 4, 5
                                    , BILL_NO        , SEQ         , SALE_DIV   , TAKE_DIV    , GIFT_DIV       -- 6, 7, 8, 9,10
                                    , SORD_TM        , DELIVER_TM  , SALE_TM    , ITEM_CD     , MAIN_ITEM_CD   --11,12,13,14,15
                                    , T_SEQ          , ITEM_SET_DIV, PACK_DIV   , SUB_ITEM_DIV, SUB_TOUCH_DIV  --16,17,18,19,20
                                    , SUB_TOUCH_GR_CD, SUB_TOUCH_CD, SUB_ITEM_CD, TR_GR_NO    , FREE_DIV       --21,22,23,24,25
                                    , DC_DIV         , SALE_QTY    , SALE_PRC   , SALE_AMT    , DC_RATE        --26,27,28,29,30
                                    , DC_AMT         , ENR_AMT     , GRD_AMT    , NET_AMT     , VAT_RATE       --31,32,33,34,35
                                    , VAT_AMT        , SVC_RATE    , SVC_AMT    , SVC_VAT_AMT , SALER_DT       --36,37,38,39,40
                                    , SALE_TYPE      , RTN_DIV     , USER_ID    , CUST_ID     , CARD_ID        --41,42,43,44,45
                                    , SAV_MLG        , SAV_PT      , DC_QTY     , FREE_QTY    , INST_DT        --46,47,48,49,50
                                    , SEND_YN                                                                ) --51
                             VALUES ( S.COMP_CD                                                                -- 1.COMP_CD
                                    , S.SALE_DT                                                                -- 2.SALE_DT
                                    , S.BRAND_CD                                                               -- 3.BRAND_CD
                                    , S.STOR_CD                                                                -- 4.STOR_CD
                                    , S.POS_NO                                                                 -- 5.POS_NO
                                    , S.BILL_NO                                                                -- 6.BILL_NO
                                    , S.SEQ                                                                    -- 7.SEQ
                                    , S.SALE_DIV                                                               -- 8.SALE_DIV
                                    , S.TAKE_DIV                                                               -- 9.TAKE_DIV
                                    , S.GIFT_DIV                                                               --10.GIFT_DIV
                                    , S.SORD_TM                                                                --11.SORD_TM
                                    , S.DELIVER_TM                                                             --12.DELIVER_TM
                                    , S.SALE_TM                                                                --13.SALE_TM
                                    , S.ITEM_CD                                                                --14.ITEM_CD
                                    , S.MAIN_ITEM_CD                                                           --15.MAIN_ITEM_CD
                                    , S.T_SEQ                                                                  --16.T_SEQ
                                    , S.ITEM_SET_DIV                                                           --17.ITEM_SET_DIV
                                    , S.PACK_DIV                                                               --18.PACK_DIV
                                    , S.SUB_ITEM_DIV                                                           --19.SUB_ITEM_DIV
                                    , S.SUB_TOUCH_DIV                                                          --20.SUB_TOUCH_DIV
                                    , S.SUB_TOUCH_GR_CD                                                        --21.SUB_TOUCH_GR_CD
                                    , S.SUB_TOUCH_CD                                                           --22.SUB_TOUCH_CD
                                    , S.SUB_ITEM_CD                                                            --23.SUB_ITEM_CD
                                    , S.TR_GR_NO                                                               --24.TR_GR_NO
                                    , S.FREE_DIV                                                               --25.FREE_DIV
                                    , S.DC_DIV                                                                 --26.DC_DIV
                                    , S.SALE_QTY                                                               --27.SALE_QTY
                                    , S.SALE_PRC                                                               --28.SALE_PRC
                                    , S.SALE_AMT                                                               --29.SALE_AMT
                                    , S.DC_RATE                                                                --30.DC_RATE
                                    , S.DC_AMT                                                                 --31.DC_AMT
                                    , S.ENR_AMT                                                                --32.ENR_AMT
                                    , S.GRD_AMT                                                                --33.GRD_AMT
                                    , S.NET_AMT                                                                --34.NET_AMT
                                    , S.VAT_RATE                                                               --35.VAT_RATE
                                    , S.VAT_AMT                                                                --36.VAT_AMT
                                    , S.SVC_RATE                                                               --37.SVC_RATE
                                    , S.SVC_AMT                                                                --38.SVC_AMT
                                    , S.SVC_VAT_AMT                                                            --39.SVC_VAT_AMT
                                    , S.SALER_DT                                                               --40.SALER_DT
                                    , S.SALE_TYPE                                                              --41.SALE_TYPE
                                    , S.RTN_DIV                                                                --42.RTN_DIV
                                    , S.USER_ID                                                                --43.USER_ID
                                    , S.CUST_ID                                                                --44.CUST_ID
                                    , S.CARD_ID                                                                --45.CARD_ID
                                    , S.SAV_MLG                                                                --46.SAV_MLG
                                    , S.SAV_PT                                                                 --47.SAV_PT
                                    , S.DC_QTY                                                                 --48.DC_QTY
                                    , S.FREE_QTY                                                               --49.FREE_QTY
                                    , S.INST_DT                                                                --50.INST_DT
                                    , 'N'                                                                      --51.SEND_YN
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN 
        ROLLBACK;
        PO_RET_CD := 'DT-' || PI_STR_DT
                  || '('   || SQLERRM   || ')';
    END;
  END IF;  

  ---------------------------------------------------------------------------------------------
  -----------------------------------------  SALE_ST  -----------------------------------------
  ---------------------------------------------------------------------------------------------
  IF PO_RET_CD IS NULL THEN 
    BEGIN
      MERGE
      INTO  SALE_ST                         T
      USING (SELECT *
             FROM   SALE_ST@HPOSDB
             WHERE  COMP_CD = '016'
             AND    SALE_DT = PI_STR_DT)    S
      ON    (    T.SALE_DT  = S.SALE_DT
             AND T.BRAND_CD = S.BRAND_CD
             AND T.STOR_CD  = S.STOR_CD
             AND T.POS_NO   = S.POS_NO
             AND T.BILL_NO  = S.BILL_NO
             AND T.SEQ      = S.SEQ
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.PAY_DIV        = S.PAY_DIV
                                    , T.CURRENCY_CD    = S.CURRENCY_CD
                                    , T.EXC_RATE       = S.EXC_RATE
                                    , T.SALE_DIV       = S.SALE_DIV
                                    , T.GIFT_DIV       = S.GIFT_DIV
                                    , T.APPR_VAN_CD    = S.APPR_VAN_CD
                                    , T.APPR_MAEIP_CD  = S.APPR_MAEIP_CD
                                    , T.APPR_MAEIP_NM  = S.APPR_MAEIP_NM
                                    , T.APPR_VAL_CD    = S.APPR_VAL_CD
                                    , T.COOP_CARD      = S.COOP_CARD
                                    , T.CARD_NO        = S.CARD_NO
                                    , T.CARD_NM        = S.CARD_NM
                                    , T.CARD_LMT       = S.CARD_LMT
                                    , T.ALLOT_LMT      = S.ALLOT_LMT
                                    , T.READ_DIV       = S.READ_DIV
                                    , T.APPR_DIV       = S.APPR_DIV
                                    , T.APPR_NO        = S.APPR_NO
                                    , T.APPR_DT        = S.APPR_DT
                                    , T.APPR_TM        = S.APPR_TM
                                    , T.APPR_AMT       = S.APPR_AMT
                                    , T.CHANGE_AMT     = S.CHANGE_AMT
                                    , T.ORG_AMT        = S.ORG_AMT
                                    , T.PAY_AMT        = S.PAY_AMT
                                    , T.REMAIN_AMT     = S.REMAIN_AMT
                                    , T.CHANGE_CASHAMT = S.CHANGE_CASHAMT
                                    , T.APPR_QTY       = S.APPR_QTY
                                    , T.SALER_DT       = S.SALER_DT
                                    , T.SALE_TYPE      = S.SALE_TYPE
                                    , T.CUST_ID        = S.CUST_ID
                                    , T.CARD_ID        = S.CARD_ID
                                    , T.SALE_TM        = S.SALE_TM
                                    , T.INST_DT        = S.INST_DT
                                    , T.SEND_YN        = 'N'
      WHEN  NOT MATCHED THEN INSERT ( SALE_DT       , BRAND_CD   , STOR_CD      , POS_NO       , BILL_NO       -- 1, 2, 3, 4, 5
                                    , SEQ           , PAY_DIV    , CURRENCY_CD  , EXC_RATE     , SALE_DIV      -- 6, 7, 8, 9,10
                                    , GIFT_DIV      , APPR_VAN_CD, APPR_MAEIP_CD, APPR_MAEIP_NM, APPR_VAL_CD   --11,12,13,14,15
                                    , COOP_CARD     , CARD_NO    , CARD_NM      , CARD_LMT     , ALLOT_LMT     --16,17,18,19,20
                                    , READ_DIV      , APPR_DIV   , APPR_NO      , APPR_DT      , APPR_TM       --21,22,23,24,25
                                    , APPR_AMT      , CHANGE_AMT , ORG_AMT      , PAY_AMT      , REMAIN_AMT    --26,27,28,29,30
                                    , CHANGE_CASHAMT, APPR_QTY   , SALER_DT     , SALE_TYPE    , CUST_ID       --31,32,33,34,35
                                    , CARD_ID       , SALE_TM    , INST_DT      , SEND_YN                   )  --36,37,38,39
                             VALUES ( S.SALE_DT                                                                -- 1.SALE_DT
                                    , S.BRAND_CD                                                               -- 2.BRAND_CD
                                    , S.STOR_CD                                                                -- 3.STOR_CD
                                    , S.POS_NO                                                                 -- 4.POS_NO
                                    , S.BILL_NO                                                                -- 5.BILL_NO
                                    , S.SEQ                                                                    -- 6.SEQ
                                    , S.PAY_DIV                                                                -- 7.PAY_DIV
                                    , S.CURRENCY_CD                                                            -- 8.CURRENCY_CD
                                    , S.EXC_RATE                                                               -- 9.EXC_RATE
                                    , S.SALE_DIV                                                               --10.SALE_DIV
                                    , S.GIFT_DIV                                                               --11.GIFT_DIV
                                    , S.APPR_VAN_CD                                                            --12.APPR_VAN_CD
                                    , S.APPR_MAEIP_CD                                                          --13.APPR_MAEIP_CD
                                    , S.APPR_MAEIP_NM                                                          --14.APPR_MAEIP_NM
                                    , S.APPR_VAL_CD                                                            --15.APPR_VAL_CD
                                    , S.COOP_CARD                                                              --16.COOP_CARD
                                    , S.CARD_NO                                                                --17.CARD_NO
                                    , S.CARD_NM                                                                --18.CARD_NM
                                    , S.CARD_LMT                                                               --19.CARD_LMT
                                    , S.ALLOT_LMT                                                              --20.ALLOT_LMT
                                    , S.READ_DIV                                                               --21.READ_DIV
                                    , S.APPR_DIV                                                               --22.APPR_DIV
                                    , S.APPR_NO                                                                --23.APPR_NO
                                    , S.APPR_DT                                                                --24.APPR_DT
                                    , S.APPR_TM                                                                --25.APPR_TM
                                    , S.APPR_AMT                                                               --26.APPR_AMT
                                    , S.CHANGE_AMT                                                             --27.CHANGE_AMT
                                    , S.ORG_AMT                                                                --28.ORG_AMT
                                    , S.PAY_AMT                                                                --29.PAY_AMT
                                    , S.REMAIN_AMT                                                             --30.REMAIN_AMT
                                    , S.CHANGE_CASHAMT                                                         --31.CHANGE_CASHAMT
                                    , S.APPR_QTY                                                               --32.APPR_QTY
                                    , S.SALER_DT                                                               --33.SALER_DT
                                    , S.SALE_TYPE                                                              --34.SALE_TYPE
                                    , S.CUST_ID                                                                --35.CUST_ID
                                    , S.CARD_ID                                                                --36.CARD_ID
                                    , S.SALE_TM                                                                --37.SALE_TM
                                    , S.INST_DT                                                                --38.INST_DT
                                    , 'N'                                                                      --39.SEND_YN
                                    )
      ;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN 
        ROLLBACK;
        PO_RET_CD := 'ST-' || PI_STR_DT
                  || '('   || SQLERRM   || ')';
    END;
  END IF;  

  ---------------------------------------------------------------------------------------------
  -----------------------------------------  SALE_DC  -----------------------------------------
  ---------------------------------------------------------------------------------------------
  IF PO_RET_CD IS NULL THEN 
    BEGIN
      MERGE
      INTO  SALE_DC                         T
      USING (SELECT *
             FROM   SALE_DC@HPOSDB
             WHERE  COMP_CD = '016'
             AND    SALE_DT = PI_STR_DT)    S
      ON    (    T.COMP_CD  = S.COMP_CD
             AND T.SALE_DT  = S.SALE_DT
             AND T.BRAND_CD = S.BRAND_CD
             AND T.STOR_CD  = S.STOR_CD
             AND T.POS_NO   = S.POS_NO
             AND T.BILL_NO  = S.BILL_NO
             AND T.SEQ      = S.SEQ
             AND T.DC_SEQ   = S.DC_SEQ
            )
      WHEN  MATCHED     THEN UPDATE
                             SET      T.SALE_DIV      = S.SALE_DIV
                                    , T.TAKE_DIV      = S.TAKE_DIV
                                    , T.GIFT_DIV      = S.GIFT_DIV
                                    , T.ITEM_CD       = S.ITEM_CD
                                    , T.MAIN_ITEM_CD  = S.MAIN_ITEM_CD
                                    , T.T_SEQ         = S.T_SEQ
                                    , T.ITEM_SET_DIV  = S.ITEM_SET_DIV
                                    , T.SUB_TOUCH_DIV = S.SUB_TOUCH_DIV
                                    , T.FREE_DIV      = S.FREE_DIV
                                    , T.DC_DIV        = S.DC_DIV
                                    , T.SALE_QTY      = S.SALE_QTY
                                    , T.SALE_PRC      = S.SALE_PRC
                                    , T.SALE_AMT      = S.SALE_AMT
                                    , T.DC_RATE       = S.DC_RATE
                                    , T.DC_AMT        = S.DC_AMT
                                    , T.ENR_AMT       = S.ENR_AMT
                                    , T.GRD_AMT       = S.GRD_AMT
                                    , T.VAT_AMT       = S.VAT_AMT
                                    , T.SVC_AMT       = S.SVC_AMT
                                    , T.SVC_VAT_AMT   = S.SVC_VAT_AMT
                                    , T.SALE_TYPE     = S.SALE_TYPE
                                    , T.USER_ID       = S.USER_ID
                                    , T.CUST_ID       = S.CUST_ID
                                    , T.CARD_ID       = S.CARD_ID
                                    , T.DC_AMT_H      = S.DC_AMT_H
                                    , T.DC_AMT_S      = S.DC_AMT_S
                                    , T.INST_DT       = S.INST_DT
                                    , T.ORG_AUTH_NO   = S.ORG_AUTH_NO
                                    , T.ORG_AUTH_DT   = S.ORG_AUTH_DT
                                    , T.SEND_YN       = 'N'
      WHEN  NOT MATCHED THEN INSERT ( COMP_CD      , SALE_DT , BRAND_CD    , STOR_CD  , POS_NO         -- 1, 2, 3, 4, 5
                                    , BILL_NO      , SEQ     , DC_SEQ      , SALE_DIV , TAKE_DIV       -- 6, 7, 8, 9,10
                                    , GIFT_DIV     , ITEM_CD , MAIN_ITEM_CD, T_SEQ    , ITEM_SET_DIV   --11,12,13,14,15
                                    , SUB_TOUCH_DIV, FREE_DIV, DC_DIV      , SALE_QTY , SALE_PRC       --16,17,18,19,20
                                    , SALE_AMT     , DC_RATE , DC_AMT      , ENR_AMT  , GRD_AMT        --21,22,23,24,25
                                    , VAT_AMT      , SVC_AMT , SVC_VAT_AMT , SALE_TYPE, USER_ID        --26,27,28,29,30
                                    , CUST_ID      , CARD_ID , DC_AMT_H    , DC_AMT_S , INST_DT        --31,32,33,34,35
                                    , ORG_AUTH_NO  , ORG_AUTH_DT, SEND_YN                            ) --36,37,38
                             VALUES ( S.COMP_CD                                                        -- 1.COMP_CD
                                    , S.SALE_DT                                                        -- 2.SALE_DT
                                    , S.BRAND_CD                                                       -- 3.BRAND_CD
                                    , S.STOR_CD                                                        -- 4.STOR_CD
                                    , S.POS_NO                                                         -- 5.POS_NO
                                    , S.BILL_NO                                                        -- 6.BILL_NO
                                    , S.SEQ                                                            -- 7.SEQ
                                    , S.DC_SEQ                                                         -- 8.DC_SEQ
                                    , S.SALE_DIV                                                       -- 9.SALE_DIV
                                    , S.TAKE_DIV                                                       --10.TAKE_DIV
                                    , S.GIFT_DIV                                                       --11.GIFT_DIV
                                    , S.ITEM_CD                                                        --12.ITEM_CD
                                    , S.MAIN_ITEM_CD                                                   --13.MAIN_ITEM_CD
                                    , S.T_SEQ                                                          --14.T_SEQ
                                    , S.ITEM_SET_DIV                                                   --15.ITEM_SET_DIV
                                    , S.SUB_TOUCH_DIV                                                  --16.SUB_TOUCH_DIV
                                    , S.FREE_DIV                                                       --17.FREE_DIV
                                    , S.DC_DIV                                                         --18.DC_DIV
                                    , S.SALE_QTY                                                       --19.SALE_QTY
                                    , S.SALE_PRC                                                       --20.SALE_PRC
                                    , S.SALE_AMT                                                       --21.SALE_AMT
                                    , S.DC_RATE                                                        --22.DC_RATE
                                    , S.DC_AMT                                                         --23.DC_AMT
                                    , S.ENR_AMT                                                        --24.ENR_AMT
                                    , S.GRD_AMT                                                        --25.GRD_AMT
                                    , S.VAT_AMT                                                        --26.VAT_AMT
                                    , S.SVC_AMT                                                        --27.SVC_AMT
                                    , S.SVC_VAT_AMT                                                    --28.SVC_VAT_AMT
                                    , S.SALE_TYPE                                                      --29.SALE_TYPE
                                    , S.USER_ID                                                        --30.USER_ID
                                    , S.CUST_ID                                                        --31.CUST_ID
                                    , S.CARD_ID                                                        --32.CARD_ID
                                    , S.DC_AMT_H                                                       --33.DC_AMT_H
                                    , S.DC_AMT_S                                                       --34.DC_AMT_S
                                    , S.INST_DT                                                        --35.INST_DT
                                    , S.ORG_AUTH_NO                                                    --36.ORG_AUTH_NO
                                    , S.ORG_AUTH_DT                                                    --37.ORG_AUTH_DT
                                    , 'N'                                                              --38.SEND_YN
                                    )
      ;
      COMMIT;
      
      PO_RET_CD := 'OK-' || PI_STR_DT;
    EXCEPTION
      WHEN OTHERS THEN 
        ROLLBACK;
        PO_RET_CD := 'DC-' || PI_STR_DT
                  || '('   || SQLERRM   || ')';
    END;
  END IF;  
  
END BATCH_TRANS_SALE_DATA_DAY;

/
