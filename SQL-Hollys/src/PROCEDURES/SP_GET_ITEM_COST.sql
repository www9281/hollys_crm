--------------------------------------------------------
--  DDL for Procedure SP_GET_ITEM_COST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_GET_ITEM_COST" 
(
  v_comp_cd       IN  VARCHAR2 ,                -- 회사코드
  v_brand_cd      IN  VARCHAR2 ,                -- 영업조직
  v_stor_cd       IN  VARCHAR2 ,                -- 매장코드
  v_item_cd       IN  VARCHAR2 ,                -- 상품코드
  v_proc_dt       IN  VARCHAR2 ,                -- 처리일자
  v_cost          OUT NUMBER   ,                -- 매입가
  v_sale_prc      OUT NUMBER                    -- 판매가
) IS
  x_stor_tp           STORE.STOR_TP%TYPE;
  x_cost              ITEM.COST%TYPE;
  x_sale_prc          ITEM.SALE_PRC%TYPE;
BEGIN
  BEGIN
     SELECT STOR_TP
       INTO x_stor_tp
       FROM STORE
      WHERE COMP_CD  = v_comp_cd
        AND BRAND_CD = v_brand_cd
        AND STOR_CD  = v_stor_cd
        AND USE_YN   = 'Y';
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20000, '[SP_GET_ITEM_COST] => STOR_CD[' || v_stor_cd || '][' || v_item_cd || ']' || SQLERRM);
  END;
  BEGIN
     SELECT COST,   SALE_PRC
       INTO v_cost, v_sale_prc
       FROM ITEM_CHAIN_HIS
      WHERE COMP_CD  = v_comp_cd
        AND BRAND_CD = v_brand_cd
        AND STOR_TP  = x_stor_tp
        AND ITEM_CD  = v_item_cd
        AND v_proc_dt BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
        AND USE_YN   = 'Y';
     -- 점상품 단가가 등록된 경우 점상품단가 적용, 없으면 ITEM_CHAIN_HIS에 있는 판매가를 적용
     BEGIN
        SELECT PRICE
          INTO v_sale_prc
          FROM ITEM_STORE
         WHERE COMP_CD       = v_comp_cd
           AND BRAND_CD      = v_brand_cd
           AND STOR_CD       = v_stor_cd
           AND ITEM_CD       = v_item_cd
           AND PRC_DIV       = '02'
           AND v_proc_dt     BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
           AND USE_YN        = 'Y';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
     END;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          --RAISE_APPLICATION_ERROR(-20000, '[SP_GET_ITEM_COST] => STOR_CD[' || v_stor_cd || '][' || v_item_cd || ']' || SQLERRM);
          v_cost        := 0;
          v_sale_prc    := 0;
  END;
END;

/
