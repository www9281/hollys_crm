--------------------------------------------------------
--  DDL for Procedure SP_MSTOCK_CALC_AMOUNT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MSTOCK_CALC_AMOUNT" 
(
  psv_comp_cd   IN VARCHAR2,  -- 회사코드
  psv_ym        IN  STRING    -- 대상년월
)
  IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_MSTOCK_CALC_AMOUNT
--  Description      : 
--  Ref. Table       : MSTOCK[IU], DSTOCK[S]
--------------------------------------------------------------------------------
--  Create Date      : 2013-12-02
--  Modify Date      : 2015-01-12 모스버거 TSMS PJT[총평균단가 적용]
--------------------------------------------------------------------------------
  ll_begin_cost         NUMBER; -- 기초단가
  ll_begin_amt          NUMBER; -- 기초금액
  ll_in_qty             NUMBER; -- 당월 입고수량
  ll_in_cost            NUMBER; -- 당월 입고단가
  ll_in_amt             NUMBER; -- 당월 입고금액
  ll_ord_camt           NUMBER; -- 당월 주문확정
  ll_ord_amt            NUMBER; -- 당월 주문확정금액
  ll_rtn_amt            NUMBER; -- 당월 반품확정금액
  ll_out_qty            NUMBER; -- 당월 출고수량
  ll_out_cost           NUMBER; -- 당월 출고단가
  ll_out_amt            NUMBER; -- 당월 출고금액
  ll_p_out_amt          NUMBER; -- 당월 출고금액(점간이동제외)
  ll_adj_cost           NUMBER; -- 당월 조정단가
  ll_adj_amt            NUMBER; -- 당월 조정금액
  ll_end_cost           NUMBER; -- 기말단가
  ll_end_amt            NUMBER; -- 기말금액
  ll_ord_unit_qty       NUMBER; -- 주문단위
  ll_avg_cost           NUMBER; -- 총평균단가(당월)
  ll_prev_avg_cost      NUMBER; -- 총평균단가(전월)
  ll_item_cost          NUMBER; -- 최종매입가
  ls_cost_div           PARA_BRAND.PARA_VAL%TYPE;    -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]

BEGIN
  FOR R IN (SELECT *
              FROM MSTOCK
             WHERE COMP_CD  = psv_comp_cd
               AND PRC_YM   = psv_ym
           )
  LOOP
    BEGIN
      SELECT PARA_VAL
        INTO ls_cost_div
        FROM PARA_BRAND
       WHERE COMP_CD     = R.COMP_CD
         AND BRAND_CD    = R.BRAND_CD
         AND PARA_CD     = '1005'; -- 재고자산 평가기준[C:최종매입가, P:총평균법, M:이동평균법]
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           ls_cost_div      := 'C'; -- 최종매입가
    END;
    -- 당월 기초단가, 기초금액(전월 참조)
    ll_begin_cost := 0;
    ll_begin_amt  := 0;

    BEGIN
        SELECT NVL(SUM(BEGIN_AMT), 0), NVL(MAX(M.END_COST), NVL(MAX(I.COST), 0)/NVL(MAX(I.ORD_UNIT_QTY), 1)), NVL(MAX(I.ORD_UNIT_QTY), 1), NVL(MAX(I.COST), 0)
          INTO ll_begin_amt, ll_prev_avg_cost, ll_ord_unit_qty, ll_item_cost
          FROM (
                    SELECT  I.COMP_CD
                         ,  I.BRAND_CD
                         ,  I.ITEM_CD
                         ,  I.ORD_UNIT_QTY
                         ,  IC.COST
                      FROM  ITEM_CHAIN      I
                         ,  ITEM_CHAIN_HIS  IC
                     WHERE  I.COMP_CD   = IC.COMP_CD
                       AND  I.BRAND_CD  = IC.BRAND_CD
                       AND  I.STOR_TP   = IC.STOR_TP
                       AND  I.ITEM_CD   = IC.ITEM_CD
                       AND  I.COMP_CD   = R.COMP_CD
                       AND  I.BRAND_CD  = R.BRAND_CD
                       AND  I.STOR_TP   = ( SELECT STOR_TP FROM STORE WHERE COMP_CD = R.COMP_CD AND BRAND_CD = R.BRAND_CD AND STOR_CD = R.STOR_CD )
                       AND  I.ITEM_CD   = R.ITEM_CD
                       AND  PSV_YM||'31' BETWEEN IC.START_DT AND NVL(IC.CLOSE_DT, '99991231')
               )        I
             , MSTOCK   M
         WHERE I.COMP_CD    = M.COMP_CD(+)
           AND I.BRAND_CD   = M.BRAND_CD(+)
           AND I.ITEM_CD    = M.ITEM_CD(+)
           AND I.COMP_CD    = R.COMP_CD
           AND I.BRAND_CD   = R.BRAND_CD
           AND I.ITEM_CD    = R.ITEM_CD
           AND M.PRC_YM(+)  = psv_ym
           AND M.STOR_CD(+) = R.STOR_CD;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ll_begin_amt := 0;
                ll_prev_avg_cost := 0;
                ll_ord_unit_qty := 1;
    END;

    IF DIVIDE_ZERO_DEF(ll_begin_amt, R.BEGIN_QTY, 0) <> 0 THEN
       ll_begin_cost := DIVIDE_ZERO_DEF(ll_begin_amt, R.BEGIN_QTY, 0);
    ELSE
       ll_begin_cost := ll_prev_avg_cost;
    END IF;

    -- 당월 입고단가, 입고금액
    ll_in_cost := 0;
    ll_in_amt  := 0;
    ll_ord_amt := 0;
    ll_rtn_amt := 0;

    BEGIN
        -- 당월 주문확정금액(주문 확정된 금액 ERP 연계 가능)
        SELECT NVL(SUM(CASE WHEN BP.PARA_VAL = '1' THEN OD.ORD_CAMT + OD.ORD_CVAT ELSE OD.ORD_CAMT END), 0)
          INTO ll_ord_camt
          FROM ORDER_DTV    OD
             , PARA_BRAND   BP
         WHERE OD.COMP_CD    = BP.COMP_CD(+)
           AND OD.BRAND_CD   = BP.BRAND_CD(+)
           AND BP.PARA_CD(+) = '1007'
           AND OD.STK_DT     BETWEEN R.PRC_YM || '01' AND R.PRC_YM || '31'
           AND OD.ORD_FG     = '1' -- 주문
           AND OD.COMP_CD    = R.COMP_CD
           AND OD.BRAND_CD   = R.BRAND_CD
           AND OD.STOR_CD    = R.STOR_CD
           AND OD.ITEM_CD    = R.ITEM_CD;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ll_ord_camt := 0;
    END;

    ll_in_amt   := ll_in_amt + ll_ord_camt;
    ll_ord_amt  := ll_ord_amt + ll_ord_camt;

    IF ls_cost_div = 'C' THEN -- 최종매입가
        BEGIN
            -- 당월 점간이동 시 입고금액
            SELECT NVL(SUM(IN_COST_AMT), 0)
              INTO ll_ord_camt
              FROM MOVE_STORE
             WHERE IN_CONF_DT  BETWEEN R.PRC_YM || '01' AND R.PRC_YM || '31'
               AND COMP_CD     = R.COMP_CD
               AND IN_BRAND_CD = R.BRAND_CD
               AND IN_STOR_CD  = R.STOR_CD
               AND ITEM_CD     = R.ITEM_CD
               AND CONFIRM_DIV = '4';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ll_ord_camt := 0;
        END;    

        ll_in_amt := ll_in_amt + ll_ord_camt;
    END IF;

    BEGIN
        -- 당월 주문반품금액
        SELECT NVL(SUM(CASE WHEN BP.PARA_VAL = '1' THEN OD.ORD_CAMT + OD.ORD_CVAT ELSE OD.ORD_CAMT END), 0)
          INTO ll_ord_camt
          FROM ORDER_DTV    OD
             , PARA_BRAND   BP
         WHERE OD.COMP_CD    = BP.COMP_CD(+)
           AND OD.BRAND_CD   = BP.BRAND_CD(+)
           AND BP.PARA_CD(+) = '1007'
           AND OD.STK_DT     BETWEEN R.PRC_YM || '01' AND R.PRC_YM || '31'
           AND OD.ORD_FG     = '2' -- 반품
           AND OD.COMP_CD    = R.COMP_CD
           AND OD.BRAND_CD   = R.BRAND_CD
           AND OD.STOR_CD    = R.STOR_CD
           AND OD.ITEM_CD    = R.ITEM_CD;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                ll_ord_camt := 0;
    END;

    ll_in_amt   := ll_in_amt - ll_ord_camt;
    ll_rtn_amt  := ll_rtn_amt + ll_ord_camt;

    IF ls_cost_div = 'C' THEN -- 최종매입가
       ll_in_qty  := R.ORD_QTY + R.MV_IN_QTY - R.RTN_QTY;
    ELSE
       ll_in_qty  := R.ORD_QTY - R.RTN_QTY;
    END IF;
    ll_in_cost := DIVIDE_ZERO_DEF(ll_in_amt, ll_in_qty, 0);

    IF ls_cost_div = 'P' THEN -- 총평균법
        -- 평균단가 산정
        IF DIVIDE_ZERO_DEF(ll_begin_amt + ll_in_amt, R.BEGIN_QTY + ll_in_qty, 0) * NVL(ll_ord_unit_qty, 1) <> 0 THEN
            ll_avg_cost := ROUND(DIVIDE_ZERO_DEF(ll_begin_amt + ll_in_amt, R.BEGIN_QTY + ll_in_qty, 0) * NVL(ll_ord_unit_qty, 1), 3);
        ELSE
            ll_avg_cost := ll_prev_avg_cost;
        END IF;
    ELSE
        -- 최종매입가
        ll_avg_cost := ll_item_cost;
    END IF;

    IF ls_cost_div = 'P' THEN -- 총평균법
       ll_in_amt := ll_in_amt + R.MV_IN_QTY * ll_in_cost / NVL(ll_ord_unit_qty, 1);
    END IF;

    -- 당월 출고단가, 출고금액 산정
    ll_out_qty  := R.MV_OUT_QTY + R.DISUSE_QTY + R.SALE_QTY + R.NOCHARGE_QTY;
    --ll_out_cost := CASE WHEN ll_out_qty = 0 THEN 0 ELSE ll_prev_avg_cost END;
    ll_out_cost := CASE WHEN ll_avg_cost = 0 THEN ll_prev_avg_cost ELSE ll_avg_cost END;
    ll_out_amt  := ll_out_qty * ROUND(ll_out_cost / NVL(ll_ord_unit_qty, 1), 3);
    ll_p_out_amt:= (R.DISUSE_QTY + R.SALE_QTY + R.NOCHARGE_QTY) * ROUND(ll_out_cost / NVL(ll_ord_unit_qty, 1), 3);

    -- 당월 조정(비규명로스)단가, 조정(비규명로스)금액
    --ll_adj_cost := CASE WHEN R.ADJ_QTY = 0 THEN 0 ELSE ll_prev_avg_cost END;
    ll_adj_cost := CASE WHEN ll_avg_cost = 0 THEN ll_prev_avg_cost ELSE ll_avg_cost END;
    ll_adj_amt  := R.ADJ_QTY * ROUND(ll_adj_cost / NVL(ll_ord_unit_qty, 1), 3);

    -- 기말단가, 기말금액
    --ll_end_cost := CASE WHEN R.END_QTY = 0 THEN 0 ELSE ll_avg_cost END;
    ll_end_cost := CASE WHEN ll_avg_cost = 0 THEN ll_prev_avg_cost ELSE ll_avg_cost END;
    ll_end_amt  := ROUND(R.END_QTY) * ROUND(ll_end_cost / NVL(ll_ord_unit_qty, 1), 3);

    UPDATE MSTOCK
       SET BEGIN_COST = ROUND(ll_begin_cost, 3)
         , BEGIN_AMT  = ROUND(ll_begin_amt)
         , IN_COST    = ROUND(ll_in_cost, 3)
         , IN_AMT     = ROUND(ll_in_amt)
         , OUT_COST   = ROUND(ll_out_cost, 3)
         , OUT_AMT    = ROUND(ll_out_amt)
         , ADJ_COST   = ROUND(ll_adj_cost, 3)
         , ADJ_AMT    = ROUND(ll_adj_amt)
         , END_COST   = ROUND(ll_avg_cost, 3)
         , END_AMT    = ROUND(ll_end_amt)
         , ORD_AMT    = ROUND(ll_ord_amt)
         , RTN_AMT    = ROUND(ll_rtn_amt)
         , P_OUT_AMT  = ROUND(ll_p_out_amt)
     WHERE COMP_CD    = R.COMP_CD
       AND PRC_YM     = R.PRC_YM
       AND BRAND_CD   = R.BRAND_CD
       AND STOR_CD    = R.STOR_CD
       AND ITEM_CD    = R.ITEM_CD;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       NULL;
END;

/
