--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_RETURN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_RETURN" (

        P_COMP_CD       IN   VARCHAR2, 
        N_BRAND_CD      IN   VARCHAR2,
        N_USE_YN        IN   VARCHAR2,
        N_PRMT_CLASS    IN   VARCHAR2,
        N_PRMT_TYPE     IN   VARCHAR2,
        N_PRMT_NM       IN   VARCHAR2, 
        N_PRMT_DT_START IN   VARCHAR2,
        N_PRMT_DT_END   IN   VARCHAR2,  
        P_USER_ID       IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR 
) AS   
BEGIN    
        OPEN       O_CURSOR  FOR 
                  SELECT 
                          A.PRMT_ID
                       ,  A.PRMT_NM
                       ,  GET_PROMOTION_NM(A.SUB_PRMT_ID, A.COMP_CD) AS SUB_PRMT_NM
                       ,  TO_CHAR(TO_DATE(A.PRMT_DT_START,'YYYYMMDD'),'YYYY-MM-DD') ||' ~ ' ||TO_CHAR(TO_DATE(A.PRMT_DT_END,'YYYYMMDD'),'YYYY-MM-DD') AS PRMT_DT
                       ,  A.SUB_PRMT_ID  AS SUB_PRMT_ID
                       ,  NVL(B.TOT_PUB_COUNT, 0) AS TOT_PUB_COUNT
                       ,  NVL(B.TOT_USE_COUNT, 0) AS TOT_USE_COUNT
                       ,  NVL(B.REACT_RATE   , 0) AS REACT_RATE
                    FROM  PROMOTION A
                       ,  (
                              SELECT 
                                     X.PRMT_ID 
                                   , X.TOT_PUB_COUNT 
                                   , Y.TOT_USE_COUNT 
                                   , ROUND(TOT_USE_COUNT/ NULLIF(TOT_PUB_COUNT, 0) * 100, 2) AS REACT_RATE
                                FROM
                                (
                                    SELECT  B.PRMT_ID , COUNT(*) AS TOT_PUB_COUNT
                                    FROM   PROMOTION_COUPON C, PROMOTION_COUPON_PUBLISH B
                                    WHERE  C.PUBLISH_ID = B.PUBLISH_ID
                                    GROUP BY B.PRMT_ID
                                )X 
                                ,
                                (
                                    SELECT  B.PRMT_ID , COUNT(*) AS TOT_USE_COUNT
                                    FROM   PROMOTION_COUPON C, PROMOTION_COUPON_PUBLISH B
                                    WHERE  C.PUBLISH_ID = B.PUBLISH_ID
                                    AND    C.USE_DT IS NOT NULL
                                    AND    C.DESTROY_DT IS NULL
                                    GROUP BY B.PRMT_ID
                                )Y
                                WHERE X.PRMT_ID = Y.PRMT_ID
                           ) B
                   WHERE A.PRMT_ID = B.PRMT_ID(+)
                   /*  
                   AND  (A.BRAND_CD = N_BRAND_CD OR (N_BRAND_CD IS NULL AND EXISTS 
                                   (SELECT 1 FROM HQ_USER_BRAND WHERE USER_ID = P_USER_ID AND BRAND_CD = A.BRAND_CD AND USE_YN = 'Y'))
                         ) 
                   AND  (TRIM(N_PRMT_CLASS) IS NULL OR A.PRMT_CLASS = N_PRMT_CLASS)
                   AND  (TRIM(N_PRMT_TYPE) IS NULL OR A.PRMT_TYPE = N_PRMT_TYPE)
                   AND  ((TRIM(N_PRMT_DT_START) IS NULL OR A.PRMT_DT_END >= N_PRMT_DT_START) AND (TRIM(N_PRMT_DT_END) IS NULL OR A.PRMT_DT_START <= N_PRMT_DT_END))
                   AND  (TRIM(N_PRMT_NM) IS NULL OR UPPER(A.PRMT_NM) LIKE '%'|| UPPER(N_PRMT_NM)||'%')
                   AND  (TRIM(N_USE_YN) IS NULL OR A.USE_YN = N_USE_YN)
                   */
                   AND  PRMT_DT_START <= TO_CHAR(SYSDATE,'YYYYMMDD') 
                   AND  PRMT_DT_END   >= TO_CHAR(SYSDATE,'YYYYMMDD')
                   ORDER BY A.PRMT_ID DESC
           ;
        
END PROMOTION_COUPON_RETURN;

/
