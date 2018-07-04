--------------------------------------------------------
--  DDL for Procedure SP_RECIPE_CONSUME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_RECIPE_CONSUME" 
(
  v_comp_cd       IN  VARCHAR2 ,                -- 회사코드
  v_brand_cd      IN  VARCHAR2 ,                -- 영업조직
  v_stor_cd       IN  VARCHAR2 ,                -- 매장코드
  v_item_cd       IN  VARCHAR2 ,                -- 상품코드
  v_proc_dt       IN  VARCHAR2 ,                -- 처리일자
  v_rcp_div       IN  VARCHAR2 ,                -- [1:PL, 2:BOM]
  v_proc_div      IN  VARCHAR2 ,                -- [1:생산, 2:타계정 출고]
  v_proc_qty_n    IN  NUMBER   ,                -- 처리수량(:NEW)
  v_proc_qty_o    IN  NUMBER                    -- 처리수량(:OLD)
) IS
  x_stor_tp           STORE.STOR_TP%TYPE;
BEGIN
  BEGIN
    SELECT STOR_TP
      INTO x_stor_tp
      FROM STORE
     WHERE COMP_CD  = v_comp_cd
       AND BRAND_CD = v_brand_cd
       AND STOR_CD  = v_stor_cd;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20000, '[SP_RECIPE_CONSUME] =>  STOR_CD[' || v_stor_cd || '][' || v_item_cd || ']' || SQLERRM);
  END;
  FOR R IN (SELECT A.C_ITEM_CD    RCP_ITEM_CD -- 매일유업 이력관리 목적으로 추가됨(2014.02.13)
                 , SUM(A.DO_QTY)  RCP_QTY     -- 원재료소모수량
                 , SUM(A.DO_COST) RCP_COST    -- 원재료소모원가
                 , A.DO_UNIT      DO_UNIT
                 , 0              LOSS_RATE
              FROM TABLE(FN_RECIPE_USE_L0(v_comp_cd, v_brand_cd, x_stor_tp, v_item_cd, v_proc_dt)) A
             WHERE v_rcp_div   = '2'       -- [1:PL, 2:BOM]
             GROUP BY A.C_ITEM_CD, A.DO_UNIT
            UNION ALL
            SELECT RCP_ITEM_CD -- 폴바셋 이력관리 목적으로 추가됨(2013.09.23)
                 , RCP_QTY
                 , 0 RCP_COST
                 , DO_UNIT
                 , LOSS_RATE
              FROM RECIPE_BRAND
             WHERE COMP_CD     = v_comp_cd
               AND BRAND_CD    = v_brand_cd
               AND ITEM_CD     = v_item_cd
               AND RCP_DIV     = '2'       -- 레시피구분[1:판매, 2:생산]
               AND USE_YN      = 'Y'
               AND DO_YN       = 'Y'
               AND v_proc_dt   BETWEEN START_DT AND CLOSE_DT
               AND v_rcp_div   = '1'       -- [1:PL, 2:BOM]
           )
  LOOP
      MERGE INTO DSTOCK DS
      USING DUAL
         ON ( DS.COMP_CD  = v_comp_cd      AND
              DS.PRC_DT   = v_proc_dt      AND
              DS.BRAND_CD = v_brand_cd     AND
              DS.STOR_CD  = v_stor_cd      AND
              DS.ITEM_CD  = R.RCP_ITEM_CD  )
      WHEN MATCHED THEN
           UPDATE
              SET PROD_OUT_QTY = PROD_OUT_QTY + DECODE(v_proc_div, '1', -- [1:생산, 2:타계정 출고]
                                                 DECODE(v_rcp_div, '1', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) + CASE WHEN R.DO_UNIT != 'EA' THEN ROUND(((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) * R.LOSS_RATE, 3) ELSE 0 END,
                                                                   '2', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY))
                                                                 , 0)
                , ETC_OUT_QTY  = ETC_OUT_QTY  + DECODE(v_proc_div, '2', -- [1:생산, 2:타계정 출고]
                                                 DECODE(v_rcp_div, '1', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) + CASE WHEN R.DO_UNIT != 'EA' THEN ROUND(((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) * R.LOSS_RATE, 3) ELSE 0 END,
                                                                   '2', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY))
                                                                 , 0)
      WHEN NOT MATCHED THEN
           INSERT (  COMP_CD
                   , PRC_DT
                   , BRAND_CD
                   , STOR_CD
                   , ITEM_CD
                   , PROD_OUT_QTY
                   , ETC_OUT_QTY
                 )
            VALUES
                 (   v_comp_cd
                   , v_proc_dt
                   , v_brand_cd
                   , v_stor_cd
                   , R.RCP_ITEM_CD
                   , DECODE(v_proc_div, '1', -- [1:생산, 2:타계정 출고]
                      DECODE(v_rcp_div, '1', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) + CASE WHEN R.DO_UNIT != 'EA' THEN ROUND(((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) * R.LOSS_RATE, 3) ELSE 0 END,
                                        '2', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY))
                                      , 0)
                   , DECODE(v_proc_div, '2', -- [1:생산, 2:타계정 출고]
                      DECODE(v_rcp_div, '1', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) + CASE WHEN R.DO_UNIT != 'EA' THEN ROUND(((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY) * R.LOSS_RATE, 3) ELSE 0 END,
                                        '2', ((v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY))
                                      , 0)
                 );
  END LOOP;
END;

/
