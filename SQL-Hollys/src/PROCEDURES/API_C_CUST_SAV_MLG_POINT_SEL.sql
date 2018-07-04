--------------------------------------------------------
--  DDL for Procedure API_C_CUST_SAV_MLG_POINT_SEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_C_CUST_SAV_MLG_POINT_SEL" (
      P_COMP_CD           IN  VARCHAR2,
      P_BRAND_CD          IN  VARCHAR2,
      P_USER_ID           IN  VARCHAR2,
      P_CUST_ID           IN  VARCHAR2,
      O_NEXT_LVL_CNT      OUT NUMBER  ,
      O_FREE_COUPON_STAND OUT NUMBER  ,
      O_FREE_COUPON_CNT   OUT NUMBER  ,
      O_STORE_CROWN       OUT NUMBER  ,
      O_LOS_CROWN         OUT NUMBER  ,
      O_SAV_PT            OUT NUMBER  ,
      O_USE_PT            OUT NUMBER  ,
      O_LOS_PT            OUT NUMBER  ,
      O_TOT_SAV_PT        OUT NUMBER  ,
      O_NOW_GRADE         OUT VARCHAR2,
      O_COUPON_CNT        OUT NUMBER,
      O_RTN_CD            OUT VARCHAR2
  
      
) IS
      v_result_cd         VARCHAR2(7) := '1';
      v_free_coupon_stand NUMBER := 12;            -- FREE 쿠폰 기준 CROWN(12개)
      v_free_coupon_cnt   NUMBER := 0;             -- FREE 쿠폰까지 남은 CROWN
      v_store_crown       NUMBER := 0;             -- 누적 CROWN
      v_los_crown         NUMBER := 0;             -- 3개월 이내 소멸예정 CROWN
      v_tot_crown         NUMBER := 0;

      v_next_lvl_cnt      NUMBER := 0;             -- 다음등급까지 남은 CROWN
      v_now_grade         VARCHAR2(10);            -- 현재 등급

      v_sav_pt            NUMBER := 0;
      v_use_pt            NUMBER := 0;
      v_los_pt            NUMBER := 0;
      v_tot_sav_pt        NUMBER := 0;
      v_coupon_cnt        NUMBER := 0;
      
BEGIN   
      -- ==========================================================================================
      -- Author        :   
      -- Create date   :   2018-05-21
      -- API REQUEST   :   HLS_CRM_IF_0101
      -- Description   :   회원 왕관/포인트 정보				
      -- ==========================================================================================
--      1. 다음등급까지 남은 CROWN
--      2. FREE 쿠폰 기준 CROWN
--      3. FREE 쿠폰까지 남은 CROWN
--      4. 누적 CROWN
--      5. 3개월 이내 소멸예정 CROWN
      
      
      -- FREE 쿠폰까지 남은 CROWN, 누적 CROWN, 3개월 이내 소멸예정 CROWN
      SELECT 12 - NVL(SUM(CASE WHEN T3.LOS_MLG_YN  = 'N' THEN T3.SAV_MLG - T3.USE_MLG - T3.LOS_MLG_UNUSE                                ELSE 0 END), 0)
           ,      NVL(SUM(CASE WHEN T3.LOS_MLG_YN  = 'N' THEN T3.SAV_MLG                                                                ELSE 0 END), 0)
           ,      NVL(SUM(CASE WHEN T3.LOS_MLG_YN  = 'N' AND ADD_MONTHS(TO_DATE(LOS_MLG_DT), -3) <= TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 1 ELSE 0 END), 0)
           ,      NVL(SUM(T3.SAV_MLG                                                                                                              ), 0)
      INTO   v_free_coupon_cnt
           , v_store_crown
           , v_los_crown
           , v_tot_crown
      FROM   C_CUST              T1
           , C_CARD              T2
           , C_CARD_SAV_USE_HIS  T3
      WHERE  T1.COMP_CD = P_COMP_CD
      AND    T1.CUST_ID = P_CUST_ID
      AND    T1.COMP_CD = T2.COMP_CD
      AND    T1.CUST_ID = T2.CUST_ID
      AND    T2.COMP_CD = T3.COMP_CD
      AND    T2.CARD_ID = T3.CARD_ID
      ;
      
      -- 다음등급까지 남은 CROWN
      SELECT CASE WHEN T2.LVL_CD = '103'                  THEN 0
                  WHEN T2.LVL_STD_END - v_store_crown < 0 THEN 0
                  ELSE T2.LVL_STD_END - v_store_crown
             END
           , T2.LVL_NM
      INTO   v_next_lvl_cnt
           , v_now_grade
      FROM   C_CUST     T1
           , C_CUST_LVL T2
      WHERE T1.COMP_CD  = P_COMP_CD
        AND T1.BRAND_CD = P_BRAND_CD
        AND T1.CUST_ID  = P_CUST_ID
        AND T1.LVL_CD   = T2.LVL_CD
      ;

      -- 회원 포인트       
      SELECT SUM(T3.SAV_PT)                                                                            SAV_PT
           , SUM(T3.USE_PT)                                                                            USE_PT
           , SUM(T3.LOS_PT_UNUSE)                                                                      LOS_PT
           , SUM(CASE WHEN T3.LOS_PT_YN = 'N' THEN T3.SAV_PT - T3.USE_PT - T3.LOS_PT_UNUSE ELSE 0 END) TOT_SAV_PT
      INTO   v_sav_pt
           , v_use_pt
           , v_los_pt
           , v_tot_sav_pt     
      FROM   C_CUST                 T1
           , C_CARD                 T2
           , C_CARD_SAV_USE_PT_HIS  T3
      WHERE  T1.COMP_CD = P_COMP_CD
      AND    T1.CUST_ID = P_CUST_ID
      AND    T1.COMP_CD = T2.COMP_CD
      AND    T1.CUST_ID = T2.CUST_ID
      AND    T2.COMP_CD = T3.COMP_CD
      AND    T2.CARD_ID = T3.CARD_ID
      ;
      
      --쿠폰 카운트
      SELECT COUNT(T1.COUPON_CD) AS  COUPON_CNT
      INTO v_coupon_cnt
      FROM PROMOTION_COUPON   T1
            ,C_CUST           T2
      WHERE   T1.CUST_ID = T2.CUST_ID
      AND     T2.COMP_CD = P_COMP_CD
      AND     T2.CUST_ID = P_CUST_ID
      AND     T1.START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD')
      AND     T1.END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD')
      ;
    
      O_NEXT_LVL_CNT      := v_next_lvl_cnt;
      O_FREE_COUPON_STAND := v_free_coupon_stand;
      O_FREE_COUPON_CNT   := v_free_coupon_cnt;
      O_STORE_CROWN       := v_tot_crown;
      O_LOS_CROWN         := v_los_crown;    
      O_NOW_GRADE         := v_now_grade;

      O_SAV_PT            := v_sav_pt;
      O_USE_PT            := v_use_pt;
      O_LOS_PT            := v_los_pt;
      O_TOT_SAV_PT        := v_tot_sav_pt;
      O_COUPON_CNT        := v_coupon_cnt;
      O_RTN_CD            := v_result_cd;
      
      
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2';
        dbms_output.put_line(SQLERRM);
        
END API_C_CUST_SAV_MLG_POINT_SEL;

/
