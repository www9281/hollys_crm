--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_BUY_MENU_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_BUY_MENU_SELECT" 
(
    P_COMP_CD     IN  VARCHAR2,
    N_BRAND_CD    IN  VARCHAR2,
    N_PRMT_ID     IN  VARCHAR2,
    N_PRMT_NM     IN  VARCHAR2,
    O_CURSOR      OUT SYS_REFCURSOR
)
IS

BEGIN
   
    OPEN O_CURSOR FOR
        
    --구매메뉴현황
    SELECT MAX(T3.L_CLASS_CD)                          L
         , MAX(T3.M_CLASS_CD)                          M
         , MAX(T3.S_CLASS_CD)                          S
         , MAX(T3.D_CLASS_CD)                          D
         , MAX(X1.L_CLASS_NM)                          L_CLASS
         , MAX(X2.M_CLASS_NM)                          M_CLASS
         , MAX(X3.S_CLASS_NM)                          S_CLASS
         , MAX(X4.D_CLASS_NM)                          D_CLASS
         , T1.ITEM_CD                                  ITEM_CD
         , MAX(T3.ITEM_NM)                             ITEM_NM
         , MAX(T1.SALE_PRC)                            SALE_PRC
         , SUM(DECODE(T4.LVL_CD,'103',T1.SALE_QTY,0))  RED_SALE_QTY
         , SUM(DECODE(T4.LVL_CD,'102',T1.SALE_QTY,0))  GLD_SALE_QTY
         , SUM(DECODE(T4.LVL_CD,'101',T1.SALE_QTY,0))  SIL_SALE_QTY
         , SUM(T1.SALE_QTY                          )  SUM_SALE_QTY
         , SUM(DECODE(T4.LVL_CD,'103',T1.NET_AMT ,0))  RED_SALE_AMT
         , SUM(DECODE(T4.LVL_CD,'102',T1.NET_AMT ,0))  GLD_SALE_AMT
         , SUM(DECODE(T4.LVL_CD,'101',T1.NET_AMT ,0))  SIL_SALE_AMT
         , SUM(T1.NET_AMT                           )  SUM_SALE_AMT
    FROM   SALE_DT       T1
         , (
            SELECT CUST_ID
                 , CRM_STOR_CD   STOR_CD
                 , POS_SALE_DT   SALE_DT
                 , POS_POS_NO    POS_NO
                 , POS_BILL_NO   BILL_NO
                 , COMP_CD
                 , BRAND_CD
            FROM   (
                    
                    SELECT C.COMP_CD
                         , C.BRAND_CD
                         , A.CUST_ID
                         , A.POS_SALE_DT    CRM_SALE_DT
                         , A.STOR_CD        CRM_STOR_CD
                         , A.POS_NO         CRM_POS_NO
                         , A.BILL_NO        CRM_BILL_NO
                         , C.SALE_DT        POS_SALE_DT
                         , C.POS_NO         POS_POS_NO
                         , C.BILL_NO        POS_BILL_NO
                    FROM   PROMOTION_COUPON  A
                         , MOBILE_LOG@HPOSDB C
                    WHERE  A.PUBLISH_ID IN (
                                            SELECT PUBLISH_ID 
                                            FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                            WHERE B.PRMT_ID = P.PRMT_ID 
                                            AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                            AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                            )
                    AND    A.BILL_NO IS NOT NULL
                    AND    C.COMP_CD     = P_COMP_CD
                    AND    C.BRAND_CD    = N_BRAND_CD
                    AND    A.STOR_CD     = C.STOR_CD
                    AND    A.POS_SALE_DT = C.SALE_DT
                    AND    A.POS_NO      = C.POS_NO
                    AND    A.BILL_NO     = C.BILL_NO
                    AND    A.COUPON_CD   = C.APPR_NO
                    AND    C.USE_YN      = 'Y'
                   UNION
                    SELECT C.COMP_CD
                         , C.BRAND_CD
                         , A.CUST_ID
                         , A.POS_SALE_DT    CRM_SALE_DT
                         , A.STOR_CD        CRM_STOR_CD
                         , A.POS_NO         CRM_POS_NO
                         , A.BILL_NO        CRM_BILL_NO
                         , C.SALE_DT        POS_SALE_DT
                         , C.POS_NO         POS_POS_NO
                         , C.BILL_NO        POS_BILL_NO
                    FROM   PROMOTION_COUPON  A
                         , MOBILE_LOG@HPOSDB C
                    WHERE  A.PUBLISH_ID IN (
                                            SELECT PUBLISH_ID 
                                            FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                            WHERE B.PRMT_ID = P.PRMT_ID 
                                            AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                            AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                            )
                    AND    A.BILL_NO IS NOT NULL
                    AND    C.COMP_CD(+)  = P_COMP_CD
                    AND    C.BRAND_CD(+) = N_BRAND_CD
                    AND    A.STOR_CD     = C.STOR_CD(+)
                    AND    A.POS_SALE_DT = C.SALE_DT(+)
                    AND    A.COUPON_CD   = C.APPR_NO(+)
                    AND    C.USE_YN(+)   = 'Y'
                    AND    A.BILL_NO    <> C.BILL_NO
                    AND    A.COUPON_CD NOT IN (
                                               SELECT APPR_NO
                                               FROM   MOBILE_LOG@HPOSDB
                                               WHERE  COMP_CD  = P_COMP_CD
                                               AND    SALE_DT  = A.POS_SALE_DT
                                               AND    BRAND_CD = N_BRAND_CD
                                               AND    STOR_CD  = A.STOR_CD
                                               AND    POS_NO   = A.POS_NO
                                               AND    BILL_NO  = A.BILL_NO
                                               AND    USE_YN   = 'Y'
                                              )
                   )

           )             T2
         , ITEM          T3
         , C_CUST        T4
         , ITEM_L_CLASS  X1
         , ITEM_M_CLASS  X2
         , ITEM_S_CLASS  X3
         , ITEM_D_CLASS  X4
    WHERE  T1.COMP_CD    = T2.COMP_CD
    AND    T1.BRAND_CD   = T2.BRAND_CD
    AND    T1.SALE_DT    = T2.SALE_DT
    AND    T1.STOR_CD    = T2.STOR_CD
    AND    T1.POS_NO     = T2.POS_NO
    AND    T1.BILL_NO    = T2.BILL_NO
    AND    T1.GIFT_DIV   = '0'
    AND    T1.FREE_DIV   = '0'
    AND    (T1.T_SEQ = '0'
           OR
            T1.SUB_TOUCH_DIV IN('2', '3')
           )
    AND    T1.COMP_CD    = T3.COMP_CD
    AND    T1.ITEM_CD    = T3.ITEM_CD
    AND    T1.CUST_ID    = T4.CUST_ID
    AND    T3.COMP_CD    = X1.COMP_CD(+)
    AND    T3.L_CLASS_CD = X1.L_CLASS_CD(+)
    AND    T3.COMP_CD    = X2.COMP_CD(+)
    AND    T3.L_CLASS_CD = X2.L_CLASS_CD(+)
    AND    T3.M_CLASS_CD = X2.M_CLASS_CD(+)
    AND    T3.COMP_CD    = X3.COMP_CD(+)
    AND    T3.L_CLASS_CD = X3.L_CLASS_CD(+)
    AND    T3.M_CLASS_CD = X3.M_CLASS_CD(+)
    AND    T3.S_CLASS_CD = X3.S_CLASS_CD(+)
    AND    T3.COMP_CD    = X4.COMP_CD(+)
    AND    T3.L_CLASS_CD = X4.L_CLASS_CD(+)
    AND    T3.M_CLASS_CD = X4.M_CLASS_CD(+)
    AND    T3.S_CLASS_CD = X4.S_CLASS_CD(+)
    AND    T3.D_CLASS_CD = X4.D_CLASS_CD(+)
    GROUP BY T1.ITEM_CD
    ORDER BY 1,2,3,4
    ;
  
END COUPON_STATS_BUY_MENU_SELECT;

/
