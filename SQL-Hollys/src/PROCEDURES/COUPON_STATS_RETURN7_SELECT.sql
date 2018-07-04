--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN7_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN7_SELECT" 
(
    P_COMP_CD     IN  VARCHAR2,
    N_BRAND_CD    IN  VARCHAR2,
    N_PRMT_ID     IN  VARCHAR2,
    N_PRMT_NM     IN  VARCHAR2,
    N_START_DATE          IN  VARCHAR2,
    N_END_DATE            IN  VARCHAR2,
    N_COMPARE_START_DATE  IN  VARCHAR2,
    N_COMPARE_END_DATE    IN  VARCHAR2,
    O_CURSOR       OUT SYS_REFCURSOR
)
IS
    
    V_PRMT_DT_START  VARCHAR(8);
    V_PRMT_DT_END    VARCHAR(8);
BEGIN

    SELECT 
           PRMT_DT_START    , PRMT_DT_END
    INTO   V_PRMT_DT_START  , V_PRMT_DT_END
    FROM PROMOTION P
    WHERE 1 = 1 
    AND   COMP_CD  = P_COMP_CD
    AND   BRAND_CD = N_BRAND_CD
    AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
    AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
    ;


OPEN O_CURSOR FOR
SELECT 
      CASE 
        WHEN DIV = '1' THEN '기준일자'
        WHEN DIV = '2' THEN '대비기간1'
        WHEN DIV = '3' THEN '대비기간2'
      ELSE ''
      END AS DIV_NM
     ,DIV
     ,PRMT_DT
     ,DATES
     ,RR
     ,GG
     ,SS
     ,PP
     ,TT
FROM 
(
    SELECT 
           1 AS DIV
         , C.LVL_CD
         , TO_DATE(V_PRMT_DT_START,'YYYY.MM.DD') ||'~'|| TO_DATE(V_PRMT_DT_END,'YYYY.MM.DD')              AS  PRMT_DT
         , TO_DATE(V_PRMT_DT_END) - TO_DATE(V_PRMT_DT_START)  AS  DATES    
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN V_PRMT_DT_START AND V_PRMT_DT_END
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
    GROUP BY C.LVL_CD
    UNION
    SELECT 
           1 AS DIV
         , 'TOT'    LVL_CD
         , TO_DATE(V_PRMT_DT_START,'YYYY.MM.DD') ||'~'|| TO_DATE(V_PRMT_DT_END ,'YYYY.MM.DD')             AS  PRMT_DT 
         , TO_DATE(V_PRMT_DT_END) - TO_DATE(V_PRMT_DT_START)  AS  DATES
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN V_PRMT_DT_START AND V_PRMT_DT_END
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
    UNION ALL -- 2 
    SELECT 
           2 AS DIV
         , C.LVL_CD
         , TO_DATE(N_START_DATE,'YYYY.MM.DD') ||'~'||TO_DATE( N_END_DATE ,'YYYY.MM.DD')                  AS  PRMT_DT
         , TO_DATE(N_END_DATE) - TO_DATE(N_START_DATE)       AS  DATES    
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN N_START_DATE AND N_END_DATE
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
    GROUP BY C.LVL_CD
    UNION
    SELECT 
           2 AS DIV
         , 'TOT'    LVL_CD
         , TO_DATE(N_START_DATE,'YYYY.MM.DD') ||'~'|| TO_DATE(N_END_DATE ,'YYYY.MM.DD')                  AS  PRMT_DT 
         , TO_DATE(N_END_DATE) - TO_DATE(N_START_DATE)       AS  DATES
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN N_START_DATE AND N_END_DATE
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
    
    UNION ALL
     
    SELECT 
           3 AS DIV
         , C.LVL_CD
         , TO_DATE(N_COMPARE_START_DATE ,'YYYY.MM.DD')||'~'||TO_DATE( N_COMPARE_END_DATE ,'YYYY.MM.DD')            AS  PRMT_DT
         , TO_DATE(N_COMPARE_END_DATE) - TO_DATE(N_COMPARE_START_DATE) AS  DATES    
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN N_COMPARE_START_DATE AND N_COMPARE_END_DATE
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
    GROUP BY C.LVL_CD
    UNION
    SELECT 
           3 AS DIV
         , 'TOT'    LVL_CD
         , TO_DATE(N_COMPARE_START_DATE ,'YYYY.MM.DD')||'~'|| TO_DATE(N_COMPARE_END_DATE   ,'YYYY.MM.DD')           AS  PRMT_DT 
         , TO_DATE(N_COMPARE_END_DATE) - TO_DATE(N_COMPARE_START_DATE)  AS  DATES
         , ROUND(COUNT(*) / NULLIF(COUNT(DISTINCT A.CUST_ID),0),1)        AS CNT
    FROM   PROMOTION_COUPON  A
         , SALE_HD           B
         , C_CUST            C
    WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
    AND    A.BILL_NO IS NOT NULL
    AND    B.COMP_CD  = P_COMP_CD
    AND    B.BRAND_CD = N_BRAND_CD
    AND    B.SALE_DT BETWEEN N_COMPARE_START_DATE AND N_COMPARE_END_DATE
    AND    A.CUST_ID  = B.CUST_ID
    AND    A.CUST_ID  = C.CUST_ID
)PIVOT(
    MAX(CNT) FOR(LVL_CD) IN ('103'  RR ,'102' GG ,'101' SS,'000' PP, 'TOT'  TT)
)A
ORDER BY DIV 
    ;
       

  
END COUPON_STATS_RETURN7_SELECT;

/
