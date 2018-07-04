CREATE OR REPLACE PACKAGE       PKG_TYPE AS
--------------------------------------------------------------------------------
--  TRIGGER NAME     : PKG_TYPE
--  DESCRIPTION      : 
--------------------------------------------------------------------------------
--  CREATE DATE      : 2010-03-26
--  MODIFY DATE      : 2010-03-26
--------------------------------------------------------------------------------
  TYPE TRG_SALE_DT IS RECORD
  (
    COMP_CD                PTIME.SALE_DT.COMP_CD%TYPE           ,
    SALE_DT                PTIME.SALE_DT.SALE_DT%TYPE           ,
    BRAND_CD               PTIME.SALE_DT.BRAND_CD%TYPE          ,
    STOR_CD                PTIME.SALE_DT.STOR_CD%TYPE           ,
    POS_NO                 PTIME.SALE_DT.POS_NO%TYPE            ,
    BILL_NO                PTIME.SALE_DT.BILL_NO%TYPE           ,
    SEQ                    PTIME.SALE_DT.SEQ%TYPE               ,
    SALE_DIV               PTIME.SALE_DT.SALE_DIV%TYPE          ,
    TAKE_DIV               PTIME.SALE_DT.TAKE_DIV%TYPE          ,
    GIFT_DIV               PTIME.SALE_DT.GIFT_DIV%TYPE          ,
    SORD_TM                PTIME.SALE_DT.SORD_TM%TYPE           ,
    DELIVER_TM             PTIME.SALE_DT.DELIVER_TM%TYPE        ,
    SALE_TM                PTIME.SALE_DT.SALE_TM%TYPE           ,
    ITEM_CD                PTIME.SALE_DT.ITEM_CD%TYPE           ,
    MAIN_ITEM_CD           PTIME.SALE_DT.MAIN_ITEM_CD%TYPE      ,
    T_SEQ                  PTIME.SALE_DT.T_SEQ%TYPE             ,
    ITEM_SET_DIV           PTIME.SALE_DT.ITEM_SET_DIV%TYPE      ,
    PACK_DIV               PTIME.SALE_DT.PACK_DIV%TYPE          ,
    SUB_ITEM_DIV           PTIME.SALE_DT.SUB_ITEM_DIV%TYPE      ,
    SUB_TOUCH_DIV          PTIME.SALE_DT.SUB_TOUCH_DIV%TYPE     ,
    SUB_TOUCH_GR_CD        PTIME.SALE_DT.SUB_TOUCH_GR_CD%TYPE   ,
    SUB_TOUCH_CD           PTIME.SALE_DT.SUB_TOUCH_CD%TYPE      ,
    FREE_DIV               PTIME.SALE_DT.FREE_DIV%TYPE          ,
    DC_DIV                 PTIME.SALE_DT.DC_DIV%TYPE            ,
    SALE_QTY               PTIME.SALE_DT.SALE_QTY%TYPE          ,
    SALE_PRC               PTIME.SALE_DT.SALE_PRC%TYPE          ,
    SALE_AMT               PTIME.SALE_DT.SALE_AMT%TYPE          ,
    DC_RATE                PTIME.SALE_DT.DC_RATE%TYPE           ,
    DC_AMT                 PTIME.SALE_DT.DC_AMT%TYPE            ,
    ENR_AMT                PTIME.SALE_DT.ENR_AMT%TYPE           ,
    GRD_AMT                PTIME.SALE_DT.GRD_AMT%TYPE           ,
    NET_AMT                PTIME.SALE_DT.NET_AMT%TYPE           ,
    VAT_RATE               PTIME.SALE_DT.VAT_RATE%TYPE          ,
    VAT_AMT                PTIME.SALE_DT.VAT_AMT%TYPE           ,
    SVC_RATE               PTIME.SALE_DT.SVC_RATE%TYPE          ,
    SVC_AMT                PTIME.SALE_DT.SVC_AMT%TYPE           ,
    SVC_VAT_AMT            PTIME.SALE_DT.SVC_VAT_AMT%TYPE       ,
    SALER_DT               PTIME.SALE_DT.SALER_DT%TYPE          ,
    SALE_TYPE              PTIME.SALE_DT.SALE_TYPE%TYPE         , -- 매일유업(2014.02.20)
    USER_ID                PTIME.SALE_DT.USER_ID%TYPE           , -- 폴바셋(2013.09.26)
    CUST_ID                PTIME.SALE_DT.CUST_ID%TYPE           , 
    SAV_MLG                PTIME.SALE_DT.SAV_MLG%TYPE           ,
    SAV_PT                 PTIME.SALE_DT.SAV_PT%TYPE            ,
    RTN_DIV                PTIME.SALE_DT.RTN_DIV%TYPE           ,
    ENTRY_NO               PTIME.SALE_DT.ENTRY_NO%TYPE          , -- 플레이타임(2016.05-27)
    ENTRY_SEQ              PTIME.SALE_DT.ENTRY_SEQ%TYPE         , -- 플레이타임(2016.05-27)
    PROGRAM_SEQ            PTIME.SALE_DT.PROGRAM_SEQ%TYPE       , -- 플레이타임(2016.05-27)
    ENTRY_DIV              PTIME.SALE_DT.ENTRY_DIV%TYPE         , -- 플레이타임(2016.05-27)
    CHILD_NO               PTIME.SALE_DT.CHILD_NO%TYPE          , -- 플레이타임(2016.05-27)
    PROGRAM_ID             PTIME.SALE_DT.PROGRAM_ID%TYPE        , -- 플레이타임(2016.05-27)
    MBS_NO                 PTIME.SALE_DT.MBS_NO%TYPE            , -- 플레이타임(2016.05-27)
    CERT_NO                PTIME.SALE_DT.CERT_NO%TYPE           , -- 플레이타임(2016.05-27)
    USE_TM                 PTIME.SALE_DT.USE_TM%TYPE            , -- 플레이타임(2016.05-27)
    USE_CNT                PTIME.SALE_DT.USE_CNT%TYPE           , -- 플레이타임(2016.05-27)
    USE_AMT                PTIME.SALE_DT.USE_AMT%TYPE           , -- 플레이타임(2016.05-27)
    USE_MCNT               PTIME.SALE_DT.USE_MCNT%TYPE          , -- 플레이타임(2016.05-27)
    USE_TMT                PTIME.SALE_DT.USE_TMT%TYPE          , -- 플레이타임(2016.05-27)
    INOUT_DIV              VARCHAR(1)
  );
  
  TYPE TRG_SALE_HD IS RECORD
  (
    COMP_CD                  SALE_HD.COMP_CD%TYPE              ,
    SALE_DT                  SALE_HD.SALE_DT%TYPE              ,
    BRAND_CD                 SALE_HD.BRAND_CD%TYPE             ,
    STOR_CD                  SALE_HD.STOR_CD%TYPE              ,
    POS_NO                   SALE_HD.POS_NO%TYPE               ,
    BILL_NO                  SALE_HD.BILL_NO%TYPE              ,
    CASHIER_ID               SALE_HD.CASHIER_ID%TYPE           ,
    SALE_DIV                 SALE_HD.SALE_DIV%TYPE             ,
    GIFT_DIV                 SALE_HD.GIFT_DIV%TYPE             ,
    SORD_TM                  SALE_HD.SORD_TM%TYPE              ,
    SALE_TM                  SALE_HD.SALE_TM%TYPE              ,
    ORDER_NO                 SALE_HD.ORDER_NO%TYPE             ,
    FLOOR                    SALE_HD.FLOOR%TYPE                ,
    TABLE_NO                 SALE_HD.TABLE_NO%TYPE             ,
    TABLE_CNT                SALE_HD.TABLE_CNT%TYPE            ,
    FOREIGN_DIV              SALE_HD.FOREIGN_DIV%TYPE          ,
    CUST_SEX                 SALE_HD.CUST_SEX%TYPE             ,
    CUST_AGE                 SALE_HD.CUST_AGE%TYPE             ,
    CUST_M_CNT               SALE_HD.CUST_M_CNT%TYPE           ,
    CUST_F_CNT               SALE_HD.CUST_F_CNT%TYPE           ,
    CUST_ID                  SALE_HD.CUST_ID%TYPE              ,
    VOID_BEFORE_DT           SALE_HD.VOID_BEFORE_DT%TYPE       ,
    VOID_BEFORE_NO           SALE_HD.VOID_BEFORE_NO%TYPE       ,
    RTN_REASON_CD            SALE_HD.RTN_REASON_CD%TYPE        ,
    RTN_MEMO                 SALE_HD.RTN_MEMO%TYPE             ,
    SALE_QTY                 SALE_HD.SALE_QTY%TYPE             ,
    SALE_AMT                 SALE_HD.SALE_AMT%TYPE             ,
    DC_AMT                   SALE_HD.DC_AMT%TYPE               ,
    ENR_AMT                  SALE_HD.ENR_AMT%TYPE              ,
    GRD_I_AMT                SALE_HD.GRD_I_AMT%TYPE            ,
    GRD_O_AMT                SALE_HD.GRD_O_AMT%TYPE            ,
    VAT_I_AMT                SALE_HD.VAT_I_AMT%TYPE            ,
    VAT_O_AMT                SALE_HD.VAT_O_AMT%TYPE            ,
    SVC_VAT_AMT              SALE_HD.SVC_VAT_AMT%TYPE          ,
    SVC_AMT                  SALE_HD.SVC_AMT%TYPE              ,
    PACK_AMT                 SALE_HD.PACK_AMT%TYPE             ,
    SALER_DT                 SALE_HD.SALER_DT%TYPE             ,
    SAVE_PT                  SALE_HD.SAVE_PT%TYPE              ,
    SALE_TYPE                SALE_HD.SALE_TYPE%TYPE            ,
    OVER_AMT                 SALE_HD.OVER_AMT%TYPE             ,
    TIPS                     SALE_HD.TIPS%TYPE                 ,
    ROUNDING                 SALE_HD.ROUNDING%TYPE             ,
    SVC_DC_AMT               SALE_HD.SVC_DC_AMT%TYPE           ,
    CNT_ORD_NO               SALE_HD.CNT_ORD_NO%TYPE           ,
    ENTRY_NO                 SALE_HD.ENTRY_NO%TYPE               -- 플레이타임(2016.05-27)
  );
  
  STOR_TP_DIR                CONSTANT CHAR(2) := '10';
END PKG_TYPE;

/
