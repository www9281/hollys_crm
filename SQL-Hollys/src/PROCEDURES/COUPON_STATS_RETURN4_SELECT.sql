--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN4_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN4_SELECT" 
(
    P_COMP_CD     IN  VARCHAR2,
    N_BRAND_CD    IN  VARCHAR2,
    N_PRMT_ID     IN  VARCHAR2,
    N_PRMT_NM     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
)
IS

BEGIN
   OPEN O_CURSOR FOR
       
    SELECT T2.LVL_CD
         , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = P_COMP_CD AND LVL_CD = T2.LVL_CD) AS LVL_NM
         , SUM(T1.CUST_M_CNT+T1.CUST_F_CNT)  CUST_CNT
         , ROUND(SUM(T1.GRD_I_AMT+T1.GRD_O_AMT - T1.VAT_I_AMT-T1.VAT_O_AMT)  / NULLIF(SUM(T1.CUST_M_CNT+T1.CUST_F_CNT), 0) ,0)   CUST_AMT
         , SUM(T1.GRD_I_AMT+T1.GRD_O_AMT       -T1.VAT_I_AMT-T1.VAT_O_AMT)    SALE_AMT
    FROM   SALE_HD  T1
         , (
            SELECT CUST_ID
                 , LVL_CD
                 , CRM_STOR_CD   STOR_CD
                 , POS_SALE_DT   SALE_DT
                 , POS_POS_NO    POS_NO
                 , POS_BILL_NO   BILL_NO
                 , COMP_CD
                 , BRAND_CD
            FROM   (
                    SELECT 
                           C.COMP_CD
                         , C.BRAND_CD
                         , A.COUPON_CD
                         , A.COUPON_SEQ
                         , A.CUST_ID
                         , B.LVL_CD
                         , A.POS_SALE_DT    CRM_SALE_DT
                         , A.STOR_CD        CRM_STOR_CD
                         , A.POS_NO         CRM_POS_NO
                         , A.BILL_NO        CRM_BILL_NO
                         , C.SALE_DT        POS_SALE_DT
                         , C.POS_NO         POS_POS_NO
                         , C.BILL_NO        POS_BILL_NO
                    FROM   PROMOTION_COUPON  A
                         , C_CUST            B
                         , MOBILE_LOG@HPOSDB C
                    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
                    AND    A.BILL_NO IS NOT NULL
                    AND    A.CUST_ID     = B.CUST_ID
                    AND    C.COMP_CD     = P_COMP_CD
                    AND    C.BRAND_CD    = N_BRAND_CD
                    AND    A.STOR_CD     = C.STOR_CD
                    AND    A.POS_SALE_DT = C.SALE_DT
                    AND    A.POS_NO      = C.POS_NO
                    AND    A.BILL_NO     = C.BILL_NO
                    AND    A.COUPON_CD   = C.APPR_NO
                    AND    C.USE_YN      = 'Y'
                   UNION
                    SELECT 
                           C.COMP_CD
                         , C.BRAND_CD 
                         , A.COUPON_CD
                         , A.COUPON_SEQ
                         , A.CUST_ID
                         , B.LVL_CD
                         , A.POS_SALE_DT    CRM_SALE_DT
                         , A.STOR_CD        CRM_STOR_CD
                         , A.POS_NO         CRM_POS_NO
                         , A.BILL_NO        CRM_BILL_NO
                         , C.SALE_DT        POS_SALE_DT
                         , C.POS_NO         POS_POS_NO
                         , C.BILL_NO        POS_BILL_NO
                    FROM   PROMOTION_COUPON  A
                         , C_CUST            B
                         , MOBILE_LOG@HPOSDB C
                    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
                    AND    A.BILL_NO IS NOT NULL
                    AND    A.CUST_ID     = B.CUST_ID
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
           )        T2
    WHERE  T1.COMP_CD  = T2.COMP_CD
    AND    T1.BRAND_CD = T2.BRAND_CD
    AND    T1.SALE_DT  = T2.SALE_DT
    AND    T1.STOR_CD  = T2.STOR_CD
    AND    T1.POS_NO   = T2.POS_NO
    AND    T1.BILL_NO  = T2.BILL_NO
    AND    T1.GIFT_DIV = '0'
    GROUP BY T2.LVL_CD
    ORDER BY 1 DESC
    ;
  
END COUPON_STATS_RETURN4_SELECT;

/
