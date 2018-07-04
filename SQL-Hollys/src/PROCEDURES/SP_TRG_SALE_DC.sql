--------------------------------------------------------
--  DDL for Procedure SP_TRG_SALE_DC
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_TRG_SALE_DC" 
(
  prv_sale_dc      IN  PKG_TYPE.TRG_SALE_DC,
  psr_return_cd   OUT  NUMBER, -- 메세지코드
  psr_msg         OUT  STRING  -- 메세지
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_TRG_SALE_DC
--  Description      : SALE_DC TRIGGER 프로시저
--  Ref. Table       : SALE_DC
--------------------------------------------------------------------------------
--  Create Date      : 2017-10-18 할리스에프앤비 이중 DC
--  Modify Date      : 2017-10-18 
--------------------------------------------------------------------------------
  liv_msg_code        NUMBER(9)  := 0;
  lsv_msg_text        VARCHAR2(500);
  lsv_check           VARCHAR2(1);

  ERR_HANDLER         EXCEPTION;

BEGIN

  liv_msg_code    := 0;
  lsv_msg_text    := ' ';

  IF ( prv_sale_dc.FREE_DIV = '0' AND prv_sale_dc.DC_DIV <> 0)                            AND  -- 무료구분[0:상품판매]
     ( prv_sale_dc.SUB_TOUCH_DIV  IN('2', '3') OR prv_sale_dc.ITEM_SET_DIV IN('0', '1') ) THEN -- 부가상품구분[2:UPCHARGE, 3:선택메뉴], SET 상품여부[0:상품, 1:SET 상품]
     BEGIN
       BEGIN
         SELECT 'X'
           INTO lsv_check
           FROM DC_GIFT -- 할인 사은품
          WHERE COMP_CD  = prv_sale_dc.COMP_CD
          AND   BRAND_CD = prv_sale_dc.BRAND_CD
          AND   DC_DIV   = prv_sale_dc.DC_DIV
          GROUP BY DC_DIV;
         BEGIN
           -- 상품 할인 일집계[SALE_DT]
           MERGE INTO SALE_JDD
           USING DUAL
           ON (
                   COMP_CD     = prv_sale_dc.COMP_CD
               AND SALE_DT     = prv_sale_dc.SALE_DT
               AND BRAND_CD    = prv_sale_dc.BRAND_CD
               AND STOR_CD     = prv_sale_dc.STOR_CD
               AND GIFT_DIV    = prv_sale_dc.GIFT_DIV
               AND ITEM_CD     = prv_sale_dc.ITEM_CD
               AND FREE_DIV    = prv_sale_dc.FREE_DIV
               AND DC_DIV      = NVL(prv_sale_dc.DC_DIV,  0)
               AND DC_RATE     = NVL(prv_sale_dc.DC_RATE, 0)
              )
           WHEN MATCHED THEN
                UPDATE
                   SET SALE_QTY    = SALE_QTY    + prv_sale_dc.SALE_QTY,
                       SALE_AMT    = SALE_AMT    + prv_sale_dc.SALE_AMT,
                       DC_AMT      = DC_AMT      + prv_sale_dc.DC_AMT,
                       ENR_AMT     = ENR_AMT     + prv_sale_dc.ENR_AMT,
                       FREE_QTY    = FREE_QTY    + prv_sale_dc.SALE_QTY
           WHEN NOT MATCHED THEN
                INSERT
                   (
                    COMP_CD,
                    SALE_DT,
                    BRAND_CD,
                    STOR_CD,
                    GIFT_DIV,
                    ITEM_CD,
                    FREE_DIV,
                    DC_DIV,
                    DC_RATE,
                    SALE_QTY,
                    SALE_AMT,
                    DC_AMT,
                    ENR_AMT,
                    FREE_QTY
                   )
                VALUES
                   (
                    prv_sale_dc.COMP_CD,
                    prv_sale_dc.SALE_DT,
                    prv_sale_dc.BRAND_CD,
                    prv_sale_dc.STOR_CD,
                    prv_sale_dc.GIFT_DIV,
                    prv_sale_dc.ITEM_CD,
                    prv_sale_dc.FREE_DIV,
                    NVL(prv_sale_dc.DC_DIV,  0),
                    NVL(prv_sale_dc.DC_RATE, 0),
                    prv_sale_dc.SALE_QTY,
                    prv_sale_dc.SALE_AMT,
                    prv_sale_dc.DC_AMT,
                    prv_sale_dc.ENR_AMT,
                    prv_sale_dc.SALE_QTY
                   );
         EXCEPTION
           WHEN OTHERS THEN
                liv_msg_code := SQLCODE;
                lsv_msg_text := 'SALE_JDD:' || SQLERRM;
                RAISE ERR_HANDLER;
         END;
       EXCEPTION
         WHEN OTHERS THEN -- DC_GIFT가 없는 할인 처리
              BEGIN
                -- 상품 할인 일집계[SALE_DT]
                MERGE INTO SALE_JDD
                USING DUAL
                ON (
                        COMP_CD     = prv_sale_dc.COMP_CD
                    AND SALE_DT     = prv_sale_dc.SALE_DT
                    AND BRAND_CD    = prv_sale_dc.BRAND_CD
                    AND STOR_CD     = prv_sale_dc.STOR_CD
                    AND GIFT_DIV    = prv_sale_dc.GIFT_DIV
                    AND ITEM_CD     = prv_sale_dc.ITEM_CD
                    AND FREE_DIV    = prv_sale_dc.FREE_DIV
                    AND DC_DIV      = NVL(prv_sale_dc.DC_DIV,  0)
                    AND DC_RATE     = NVL(prv_sale_dc.DC_RATE, 0)
                   )
                WHEN MATCHED THEN
                     UPDATE
                        SET SALE_QTY    = SALE_QTY    + prv_sale_dc.SALE_QTY,
                            SALE_AMT    = SALE_AMT    + prv_sale_dc.SALE_AMT,
                            DC_AMT      = DC_AMT      + prv_sale_dc.DC_AMT,
                            ENR_AMT     = ENR_AMT     + prv_sale_dc.ENR_AMT,
                            GRD_AMT     = GRD_AMT     + prv_sale_dc.GRD_AMT,
                            GRD_I_AMT   = GRD_I_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.GRD_AMT ELSE 0 END,
                            GRD_O_AMT   = GRD_O_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.GRD_AMT END,
                            VAT_AMT     = VAT_AMT     + prv_sale_dc.VAT_AMT,
                            VAT_I_AMT   = VAT_I_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.VAT_AMT ELSE 0 END,
                            VAT_O_AMT   = VAT_O_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.VAT_AMT END,
                            SVC_AMT     = SVC_AMT     + prv_sale_dc.SVC_AMT,
                            SVC_VAT_AMT = SVC_VAT_AMT + prv_sale_dc.SVC_VAT_AMT,
                            DC_QTY      = DC_QTY      + DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, 0, prv_sale_dc.SALE_QTY),
                            FREE_QTY    = FREE_QTY    + DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, prv_sale_dc.SALE_QTY, 0)
                WHEN NOT MATCHED THEN
                     INSERT
                        (
                         COMP_CD,
                         SALE_DT,
                         BRAND_CD,
                         STOR_CD,
                         GIFT_DIV,
                         ITEM_CD,
                         FREE_DIV,
                         DC_DIV,
                         DC_RATE,
                         SALE_QTY,
                         SALE_AMT,
                         DC_AMT,
                         ENR_AMT,
                         GRD_AMT,
                         GRD_I_AMT,
                         GRD_O_AMT,
                         VAT_AMT,
                         VAT_I_AMT,
                         VAT_O_AMT,
                         SVC_AMT,
                         SVC_VAT_AMT,
                         DC_QTY,
                         FREE_QTY
                        )
                     VALUES
                        (
                         prv_sale_dc.COMP_CD,
                         prv_sale_dc.SALE_DT,
                         prv_sale_dc.BRAND_CD,
                         prv_sale_dc.STOR_CD,
                         prv_sale_dc.GIFT_DIV,
                         prv_sale_dc.ITEM_CD,
                         prv_sale_dc.FREE_DIV,
                         NVL(prv_sale_dc.DC_DIV,  0),
                         NVL(prv_sale_dc.DC_RATE, 0),
                         prv_sale_dc.SALE_QTY,
                         prv_sale_dc.SALE_AMT,
                         prv_sale_dc.DC_AMT,
                         prv_sale_dc.ENR_AMT,
                         prv_sale_dc.GRD_AMT,
                         CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.GRD_AMT ELSE 0 END,
                         CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.GRD_AMT END,
                         prv_sale_dc.VAT_AMT,
                         CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.VAT_AMT ELSE 0 END,
                         CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.VAT_AMT END,
                         prv_sale_dc.SVC_AMT,
                         prv_sale_dc.SVC_VAT_AMT,
                         DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, 0, prv_sale_dc.SALE_QTY),
                         DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, prv_sale_dc.SALE_QTY, 0)
                        );
              EXCEPTION
                WHEN OTHERS THEN
                     liv_msg_code := SQLCODE;
                     lsv_msg_text := 'SALE_JDD:' || SQLERRM;
                     RAISE ERR_HANDLER;
              END;
       END;
     END;

     IF prv_sale_dc.FREE_DIV IN('0')  THEN -- 무료구분[0:상품판매]
        BEGIN
          -- 점포별 할인 일매출[SALE_DT]
          MERGE INTO SALE_SDC
          USING DUAL
          ON (
                  COMP_CD     = prv_sale_dc.COMP_CD
              AND SALE_DT     = prv_sale_dc.SALE_DT
              AND BRAND_CD    = prv_sale_dc.BRAND_CD
              AND STOR_CD     = prv_sale_dc.STOR_CD
              AND GIFT_DIV    = prv_sale_dc.GIFT_DIV
              AND DC_DIV      = NVL(prv_sale_dc.DC_DIV,  0)
              AND DC_RATE     = NVL(prv_sale_dc.DC_RATE, 0)
             )
          WHEN MATCHED THEN
               UPDATE
                  SET SALE_QTY    = SALE_QTY    + prv_sale_dc.SALE_QTY,
                      SALE_AMT    = SALE_AMT    + prv_sale_dc.SALE_AMT,
                      DC_AMT      = DC_AMT      + prv_sale_dc.DC_AMT,
                      ENR_AMT     = ENR_AMT     + prv_sale_dc.ENR_AMT,
                      GRD_AMT     = GRD_AMT     + prv_sale_dc.GRD_AMT,
                      GRD_I_AMT   = GRD_I_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.GRD_AMT ELSE 0 END,
                      GRD_O_AMT   = GRD_O_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.GRD_AMT END,
                      VAT_AMT     = VAT_AMT     + prv_sale_dc.VAT_AMT,
                      VAT_I_AMT   = VAT_I_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.VAT_AMT ELSE 0 END,
                      VAT_O_AMT   = VAT_O_AMT   + CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.VAT_AMT END,
                      SVC_AMT     = SVC_AMT     + prv_sale_dc.SVC_AMT,
                      SVC_VAT_AMT = SVC_VAT_AMT + prv_sale_dc.SVC_VAT_AMT,
                      DC_QTY      = DC_QTY      + DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, 0, prv_sale_dc.SALE_QTY),
                      FREE_QTY    = FREE_QTY    + DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, prv_sale_dc.SALE_QTY, 0)
          WHEN NOT MATCHED THEN
               INSERT
                  (
                   COMP_CD,
                   SALE_DT,
                   BRAND_CD,
                   STOR_CD,
                   GIFT_DIV,
                   DC_DIV,
                   DC_RATE,
                   SALE_QTY,
                   SALE_AMT,
                   DC_AMT,
                   ENR_AMT,
                   GRD_AMT,
                   GRD_I_AMT,
                   GRD_O_AMT,
                   VAT_AMT,
                   VAT_I_AMT,
                   VAT_O_AMT,
                   SVC_AMT,
                   SVC_VAT_AMT,
                   DC_QTY,
                   FREE_QTY
                  )
               VALUES
                  (
                   prv_sale_dc.COMP_CD,
                   prv_sale_dc.SALE_DT,
                   prv_sale_dc.BRAND_CD,
                   prv_sale_dc.STOR_CD,
                   prv_sale_dc.GIFT_DIV,
                   NVL(prv_sale_dc.DC_DIV,  0),
                   NVL(prv_sale_dc.DC_RATE, 0),
                   prv_sale_dc.SALE_QTY,
                   prv_sale_dc.SALE_AMT,
                   prv_sale_dc.DC_AMT,
                   prv_sale_dc.ENR_AMT,
                   prv_sale_dc.GRD_AMT,
                   CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.GRD_AMT ELSE 0 END,
                   CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.GRD_AMT END,
                   prv_sale_dc.VAT_AMT,
                   CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN prv_sale_dc.VAT_AMT ELSE 0 END,
                   CASE WHEN prv_sale_dc.TAKE_DIV = '0' THEN 0 ELSE prv_sale_dc.VAT_AMT END,
                   prv_sale_dc.SVC_AMT,
                   prv_sale_dc.SVC_VAT_AMT,
                   DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, 0, prv_sale_dc.SALE_QTY),
                   DECODE(prv_sale_dc.SALE_AMT - prv_sale_dc.DC_AMT - prv_sale_dc.ENR_AMT, 0, prv_sale_dc.SALE_QTY, 0)
                  );
        EXCEPTION
          WHEN OTHERS THEN
               liv_msg_code := SQLCODE;
               lsv_msg_text := 'SALE_SDC:' || SQLERRM;
               RAISE ERR_HANDLER;
        END;
     END IF;
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
