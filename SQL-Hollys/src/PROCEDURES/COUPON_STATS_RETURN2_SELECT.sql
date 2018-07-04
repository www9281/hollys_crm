--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN2_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN2_SELECT" 
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
    SELECT A.*, (A.S + A.G + A.R ) AS HAP
    FROM
    (
         
        SELECT B.LVL_CD
             , A.POS_SALE_DT  AS SALE_DT 
             , COUNT(*)       AS CNT
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
        AND    A.BILL_NO IS NOT NULL
        GROUP BY B.LVL_CD,A.POS_SALE_DT
        ORDER BY 1 DESC,2
    )
    PIVOT
    ( 
    MAX( CNT) FOR LVL_CD IN ('101' AS S ,'102' AS G ,'103' AS R)
    )A
    ORDER BY SALE_DT
    ;
  
END COUPON_STATS_RETURN2_SELECT;

/
