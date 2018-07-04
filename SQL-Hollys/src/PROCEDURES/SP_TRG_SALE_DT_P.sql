--------------------------------------------------------
--  DDL for Procedure SP_TRG_SALE_DT_P
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_TRG_SALE_DT_P" 
( prv_sale_dt      IN  PKG_TYPE.TRG_SALE_DT,
  psr_return_cd   OUT  NUMBER, -- 메세지코드
  psr_msg         OUT  STRING  -- 메세지
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_TRG_SALE_DT_P
--  Description      : SALE_DT TRIGGER
--  Ref. Table       : SALE_DT
--------------------------------------------------------------------------------
--  Create Date      : 2010-03-26
--  Modify Date      : 2013-09-17 폴바셋 PJT
--------------------------------------------------------------------------------
  liv_msg_code    NUMBER(9)  := 0;
  lsv_msg_text    VARCHAR2(500);

  ls_inout_div    VARCHAR2(1);

  ERR_HANDLER     EXCEPTION;

BEGIN

  liv_msg_code    := 0;
  lsv_msg_text    := ' ';

  IF prv_sale_dt.t_seq = 0 THEN
     BEGIN
       IF prv_sale_dt.SALE_DIV = '1' THEN
          ls_inout_div := prv_sale_dt.INOUT_DIV;
       ELSE
          IF prv_sale_dt.INOUT_DIV = '1' THEN
             ls_inout_div := '2';
          ELSE
             ls_inout_div := '1';
          END IF;
       END IF;
       -- 매장별 포장지 일집계
       MERGE INTO SALE_JDW
       USING DUAL
       ON (
               COMP_CD   = prv_sale_dt.COMP_CD
           AND SALE_DT   = prv_sale_dt.SALE_DT
           AND BRAND_CD  = prv_sale_dt.BRAND_CD
           AND STOR_CD   = prv_sale_dt.STOR_CD
           AND ITEM_CD   = prv_sale_dt.ITEM_CD
           AND INOUT_DIV = ls_inout_div
          )
       WHEN MATCHED THEN
            UPDATE
               SET SALE_QTY  = SALE_QTY + prv_sale_dt.SALE_QTY,
                   SALE_AMT  = SALE_AMT + prv_sale_dt.SALE_AMT,
                   DC_AMT    = DC_AMT   + prv_sale_dt.DC_AMT,
                   ENR_AMT   = ENR_AMT  + prv_sale_dt.ENR_AMT,
                   GRD_AMT   = GRD_AMT  + prv_sale_dt.GRD_AMT,
                   VAT_AMT   = VAT_AMT  + prv_sale_dt.VAT_AMT
       WHEN NOT MATCHED THEN
            INSERT
               (
                COMP_CD,
                SALE_DT,
                BRAND_CD,
                STOR_CD,
                ITEM_CD,
                INOUT_DIV,
                SALE_QTY,
                SALE_AMT,
                DC_AMT,
                ENR_AMT,
                GRD_AMT,
                VAT_AMT
               )
            VALUES
               (
                prv_sale_dt.COMP_CD,
                prv_sale_dt.SALE_DT,
                prv_sale_dt.BRAND_CD,
                prv_sale_dt.STOR_CD,
                prv_sale_dt.ITEM_CD,
                ls_inout_div,
                prv_sale_dt.SALE_QTY,
                prv_sale_dt.SALE_AMT,
                prv_sale_dt.DC_AMT,
                prv_sale_dt.ENR_AMT,
                prv_sale_dt.GRD_AMT,
                prv_sale_dt.VAT_AMT
               );
     EXCEPTION
       WHEN OTHERS THEN
            liv_msg_code := SQLCODE;
            lsv_msg_text := 'SALE_JDW:' || SQLERRM;
            RAISE ERR_HANDLER;
     END;
  END IF;

  psr_return_cd  := liv_msg_code;
  psr_msg        := lsv_msg_text;

EXCEPTION
  WHEN ERR_HANDLER THEN
       psr_return_cd := liv_msg_code;
       psr_msg       := lsv_msg_text;
  WHEN OTHERS THEN
       psr_return_cd := SQLCODE;
       psr_msg       := SQLERRM;
END;

/
