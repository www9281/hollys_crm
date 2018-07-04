--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN3_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN3_SELECT" 
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
         
        SELECT
               B.LVL_CD       
             , C.TRAD_AREA               AS TRAD_AREA
             , MAX(D.CODE_NM)            AS DIV
             , COUNT(*)                  AS CNT
             --, COUNT(DISTINCT A.STOR_CD) AS HAP
        FROM   PROMOTION_COUPON  A
             , C_CUST            B
             , STORE             C
             , COMMON@HPOSDB     D
        WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
        AND    A.BILL_NO IS NOT NULL
        AND    A.CUST_ID    = B.CUST_ID
        AND    A.STOR_CD    = C.STOR_CD
        AND    D.CODE_TP(+) = '00595'
        AND    D.CODE_CD(+) = C.TRAD_AREA
        GROUP BY B.LVL_CD, C.TRAD_AREA
        ORDER BY 1 DESC, 3
    )
    PIVOT
    ( 
    MAX( CNT) FOR LVL_CD IN ('101' AS S ,'102' AS G ,'103' AS R)
    )A
    ORDER BY TRAD_AREA
    ;
  
END COUPON_STATS_RETURN3_SELECT;

/
