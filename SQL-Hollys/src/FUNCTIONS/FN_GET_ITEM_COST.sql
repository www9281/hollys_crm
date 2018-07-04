--------------------------------------------------------
--  DDL for Function FN_GET_ITEM_COST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_GET_ITEM_COST" 
(
  v_comp_cd       IN  VARCHAR2 ,                -- 회사코드
  v_brand_cd      IN  VARCHAR2 ,                -- 영업조직
  v_stor_cd       IN  VARCHAR2 ,                -- 매장코드
  v_item_cd       IN  VARCHAR2 ,                -- 상품코드
  v_proc_dt       IN  VARCHAR2                  -- 처리일자
) RETURN NUMBER IS
  x_stor_tp         STORE.STOR_TP%TYPE;
  x_cost            ITEM.COST%TYPE;

  vERRMSG           VARCHAR2(2000);     
BEGIN
    BEGIN
        BEGIN
            SELECT  END_COST INTO x_cost
            FROM    MSTOCK
            WHERE   COMP_CD     = v_comp_cd
            AND     PRC_YM      = SUBSTR(v_proc_dt, 1, 6)
            AND     BRAND_CD    = v_brand_cd
            AND     STOR_CD     = v_stor_cd
            AND     ITEM_CD     = v_item_cd;
        EXCEPTION 
            WHEN OTHERS THEN
                vERRMSG := SQLERRM;
                x_cost := 0;
        END;

        /*
        IF x_cost = 0 THEN
            BEGIN
                SELECT  STOR_TP
                INTO    x_stor_tp
                FROM    STORE
                WHERE   COMP_CD  = v_comp_cd
                AND     BRAND_CD = v_brand_cd
                AND     STOR_CD  = v_stor_cd
                AND     USE_YN   = 'Y';
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RETURN 0;
            END;

            SELECT  COST INTO x_cost
            FROM  (
                    SELECT  COST
                          , ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_TP, ITEM_CD ORDER BY START_DT DESC) R_NUM  
                    FROM    ITEM_CHAIN_HIS
                    WHERE   COMP_CD  = v_comp_cd
                    AND     BRAND_CD = v_brand_cd
                    AND     STOR_TP  = x_stor_tp
                    AND     ITEM_CD  = v_item_cd
                    AND     v_proc_dt BETWEEN START_DT AND NVL(CLOSE_DT, '99991231')
                    AND     USE_YN   = 'Y'
                   )
            WHERE   R_NUM = 1;
        END IF;
        */

        RETURN x_cost;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END;
END;

/
