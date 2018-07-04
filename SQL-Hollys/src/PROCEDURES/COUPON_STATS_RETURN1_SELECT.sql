--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN1_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN1_SELECT" 
(
    P_COMP_CD     IN  VARCHAR2,
    N_BRAND_CD    IN  VARCHAR2,
    N_PRMT_ID     IN  VARCHAR2,
    N_PRMT_NM     IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
)
IS
tmpVar NUMBER;
BEGIN
    OPEN O_CURSOR FOR 
    
    SELECT B.LVL_CD
         , (SELECT LVL_NM FROM C_CUST_LVL WHERE COMP_CD = P_COMP_CD AND LVL_CD = B.LVL_CD) AS LVL_NM
         , COUNT(*)                         TOT_CNT
         , SUM(DECODE(A.BILL_NO,NULL,0,1))  USE_CNT
         , ROUND(SUM(DECODE(A.BILL_NO,NULL,0,1)) / NULLIF(COUNT(*),0), 2) AS R_RATE  
    FROM   PROMOTION_COUPON  A
         , C_CUST            B
    WHERE  A.PUBLISH_ID IN (
                            SELECT PUBLISH_ID 
                            FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                            WHERE B.PRMT_ID = P.PRMT_ID 
                            AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                            AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                            )
    AND    A.CUST_ID = B.CUST_ID
    GROUP BY B.LVL_CD
    ORDER BY B.LVL_CD DESC
    ;
  
END COUPON_STATS_RETURN1_SELECT;

/
