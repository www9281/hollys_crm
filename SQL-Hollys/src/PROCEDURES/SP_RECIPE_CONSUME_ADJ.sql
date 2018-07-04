--------------------------------------------------------
--  DDL for Procedure SP_RECIPE_CONSUME_ADJ
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_RECIPE_CONSUME_ADJ" 
(
  v_comp_cd       IN  VARCHAR2 ,                -- 회사코드
  v_brand_cd      IN  VARCHAR2 ,                -- 영업조직
  v_stor_cd       IN  VARCHAR2 ,                -- 매장코드
  v_item_cd       IN  VARCHAR2 ,                -- 상품코드
  v_proc_dt       IN  VARCHAR2 ,                -- 처리일자
  v_adj_div       IN  VARCHAR2 ,                -- 조정구분[01245> 01:클레일, 02:시험연구-매장, 03:시험연구-본사, 04:샘플테스트, 05:로스, 06:폐기, 99:기타]
  v_adj_cost_div  IN  VARCHAR2 ,                -- 코스트센터[01250> 1:주방, 2:홀, 3:전체]
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
         RAISE_APPLICATION_ERROR(-20000, '[SP_RECIPE_CONSUME_ADJ] =>  STOR_CD[' || v_stor_cd || '][' || v_item_cd || ']' || SQLERRM);
  END;

  FOR R IN (SELECT A.C_ITEM_CD    RCP_ITEM_CD -- 매일유업 이력관리 목적으로 추가됨(2014.02.13)
                 , SUM(A.DO_QTY)  RCP_QTY     -- 원재료소모수량
                 , SUM(A.DO_COST) RCP_COST    -- 원재료소모원가
                 , A.DO_UNIT      DO_UNIT
                 , 0              LOSS_RATE
              FROM TABLE(FN_RECIPE_USE_L0(v_comp_cd, v_brand_cd, x_stor_tp, v_item_cd, v_proc_dt)) A
             WHERE REUSE_YN = 'N'
             GROUP BY A.C_ITEM_CD, A.DO_UNIT
           )
  LOOP
      MERGE INTO SALE_CDR DS
      USING DUAL
         ON ( DS.COMP_CD      = v_comp_cd        AND
              DS.SALE_DT      = v_proc_dt        AND
              DS.BRAND_CD     = v_brand_cd       AND
              DS.STOR_CD      = v_stor_cd        AND
              DS.P_ITEM_CD    = v_item_cd        AND
              DS.C_ITEM_CD    = R.RCP_ITEM_CD    AND
              DS.ADJ_DIV      = v_adj_div        AND
              DS.ADJ_COST_DIV = v_adj_cost_div )
      WHEN MATCHED THEN
           UPDATE
              SET DO_QTY      = DO_QTY + (v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY
      WHEN NOT MATCHED THEN
           INSERT (  COMP_CD
                   , SALE_DT
                   , BRAND_CD
                   , STOR_CD
                   , P_ITEM_CD
                   , C_ITEM_CD
                   , ADJ_DIV
                   , ADJ_COST_DIV
                   , DO_QTY
                  )
            VALUES
                  (  v_comp_cd
                   , v_proc_dt
                   , v_brand_cd
                   , v_stor_cd
                   , v_item_cd
                   , R.RCP_ITEM_CD
                   , v_adj_div
                   , v_adj_cost_div
                   , (v_proc_qty_n - NVL(v_proc_qty_o, 0)) * R.RCP_QTY
                  );
  END LOOP;
END;

/
