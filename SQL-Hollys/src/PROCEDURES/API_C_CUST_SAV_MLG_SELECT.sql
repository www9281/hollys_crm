--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAV_MLG_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAV_MLG_SELECT" (
      P_COMP_CD       IN  VARCHAR2,
      P_BRAND_CD      IN  VARCHAR2,
      P_USER_ID       IN  VARCHAR2,
      P_CUST_ID       IN  VARCHAR2,
      O_NEXT_LVL_CNT      OUT NUMBER,
      O_FREE_COUPON_STAND OUT NUMBER,
      O_FREE_COUPON_CNT   OUT NUMBER,
      O_STORE_CROWN       OUT NUMBER,
      O_LOS_CROWN         OUT NUMBER,
      O_NOW_GRADE         OUT VARCHAR2,
      O_RTN_CD            OUT VARCHAR2
) IS
      v_result_cd VARCHAR2(7) := '1';
      v_next_lvl_cnt  NUMBER := 0;             -- 다음등급까지 남은 CROWN
      v_free_coupon_stand NUMBER := 12;        -- FREE 쿠폰 기준 CROWN(12개)
      v_free_coupon_cnt NUMBER := 0;           -- FREE 쿠폰까지 남은 CROWN
      v_store_crown NUMBER := 0;               -- 누적 CROWN
      v_los_crown NUMBER := 0;                 -- 3개월 이내 소멸예정 CROWN
      
      v_tot_crown NUMBER := 0;
BEGIN   
      -- ==========================================================================================
      -- Author        :   박동수
      -- Create date   :   2017-11-15
      -- API REQUEST   :   HLS_CRM_IF_0005
      -- Description   :   회원 왕관 정보				
      -- ==========================================================================================
--      1. 다음등급까지 남은 CROWN
--      2. FREE 쿠폰 기준 CROWN
--      3. FREE 쿠폰까지 남은 CROWN
--      4. 누적 CROWN
--      5. 3개월 이내 소멸예정 CROWN
      
      
      -- FREE 쿠폰까지 남은 CROWN, 누적 CROWN, 3개월 이내 소멸예정 CROWN
      SELECT  
        12 - NVL(SUM(CASE WHEN HIS.LOS_MLG_YN  = 'N' THEN HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE ELSE 0 END), 0)
        , NVL(SUM(CASE WHEN HIS.LOS_MLG_YN  = 'N' THEN HIS.SAV_MLG ELSE 0 END), 0)
        , NVL(SUM(CASE WHEN HIS.LOS_MLG_YN  = 'N' AND ADD_MONTHS(TO_DATE(LOS_MLG_DT), -3) <= TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 1 ELSE 0 END), 0)
        , NVL(SUM(HIS.SAV_MLG), 0)
        INTO v_free_coupon_cnt, v_store_crown, v_los_crown, v_tot_crown
      FROM    C_CUST              CST
            , C_CARD              CRD
            , C_CARD_SAV_USE_HIS  HIS
      WHERE   CST.COMP_CD  = CRD.COMP_CD
      AND     CST.CUST_ID  = CRD.CUST_ID
      AND     CRD.COMP_CD  = HIS.COMP_CD
      AND     CRD.CARD_ID  = HIS.CARD_ID
      AND     CRD.COMP_CD  = '016'
      AND     CRD.CUST_ID  = P_CUST_ID;
      
      -- 다음등급까지 남은 CROWN
      SELECT
        CASE WHEN B.LVL_CD = '103' THEN 0
             WHEN B.LVL_STD_END - v_store_crown < 0 THEN 0
             ELSE B.LVL_STD_END - v_store_crown
        END, B.LVL_NM
        INTO v_next_lvl_cnt, O_NOW_GRADE
      FROM C_CUST A, C_CUST_LVL B
      WHERE A.COMP_CD = P_COMP_CD
        AND A.BRAND_CD = P_BRAND_CD
        AND A.CUST_ID = P_CUST_ID
        AND A.LVL_CD = B.LVL_CD
      ;
      
      O_NEXT_LVL_CNT := v_next_lvl_cnt;
      O_FREE_COUPON_STAND := v_free_coupon_stand;
      O_FREE_COUPON_CNT := v_free_coupon_cnt;
      O_STORE_CROWN := v_tot_crown;
      O_LOS_CROWN := v_los_crown;
      
      O_RTN_CD := v_result_cd;
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        dbms_output.put_line(SQLERRM) ;
END API_C_CUST_SAV_MLG_SELECT;

/
