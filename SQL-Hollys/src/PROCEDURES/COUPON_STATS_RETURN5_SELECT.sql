--------------------------------------------------------
--  DDL for Procedure COUPON_STATS_RETURN5_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_STATS_RETURN5_SELECT" 
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
    SELECT 
        A.*
        , ( A.RM_CNT + A.GM_CNT + SM_CNT) AS HAP_1
        , ( A.RF_CNT + A.GF_CNT + SF_CNT) AS HAP_2
        , ( A.RE_CNT + A.GE_CNT + SE_CNT) AS HAP_3
        , ( A.RM_HAP + A.GM_HAP + SM_HAP) AS HAP_4
    FROM 
    ( 
        SELECT 
               (SELECT T2.CODE_NM FROM COMMON@HPOSDB T2 WHERE T2.CODE_TP = '01760' AND T2.CODE_CD = NVL(Y.CODE_CD,X.CODE_CD))  AS DIV
             , NVL(Y.CODE_CD,X.CODE_CD)  AS CODE_CD
             , NVL(Y.LVL_CD,X.LVL_CD)    AS LVL_CD
             , NVL(Y.SEX,X.SEX)          AS SEX
             , NVL(CNT,0)                AS CNT
             , NVL(HAP,0)                AS HAP  
             , ROW_NUMBER() over (PARTITION BY  Y.CODE_CD ORDER BY Y.CODE_CD, Y.LVL_CD DESC ,Y.SEX DESC) RN 
        FROM(
            SELECT
                   MAX(T2.CODE_NM)   AS DIV
                 , T1.LVL_CD         AS LVL_CD
                 , NVL(T1.SEX,'E')   AS SEX
                 , CODE_CD           AS CODE_CD
                 ,  COUNT(*)         AS CNT
                 , SUM(COUNT(*))   OVER (PARTITION BY  T1.LVL_CD , T2.CODE_CD  ORDER BY  T2.CODE_CD) HAP
            FROM   (
                        SELECT B.LVL_CD         LVL_CD
                             , CASE WHEN B.BIRTH_DT = '99999999'
                                    THEN 999
                                    ELSE TRUNC(('201805' - SUBSTR(DECODE(B.LUNAR_DIV,'L',UF_LUN2SOL(B.BIRTH_DT, '0'),B.BIRTH_DT),1,6)) / 100 + 1)
                               END              AGE
                             , NVL(B.SEX_DIV,'E')        SEX
                        FROM   PROMOTION_COUPON  A
                             , C_CUST            B
                        WHERE  A.PUBLISH_ID IN (
                                SELECT PUBLISH_ID 
                                FROM  PROMOTION_COUPON_PUBLISH B, PROMOTION P 
                                WHERE B.PRMT_ID = P.PRMT_ID 
                                --AND   P.PRMT_ID = 882
                                AND   (N_PRMT_ID IS NULL OR P.PRMT_ID = N_PRMT_ID)
                                AND   (N_PRMT_NM IS NULL OR P.PRMT_NM = N_PRMT_NM)
                                )
                        AND    A.BILL_NO IS NOT NULL
                        AND    A.CUST_ID = B.CUST_ID
                   )              T1
                 , COMMON@HPOSDB  T2
            WHERE  T2.CODE_TP = '01760'
            AND    T1.AGE BETWEEN T2.VAL_N1 AND T2.VAL_N2
            GROUP BY T1.LVL_CD,T1.SEX,T2.CODE_CD
        ) X , (
              SELECT '01' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '101' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '101' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '101' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '102' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '102' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '102' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '01' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '02' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '03' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '04' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '05' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '06' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '07' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '103' AS LVL_CD, 'M' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '103' AS LVL_CD, 'F' AS SEX  FROM DUAL  UNION ALL
              SELECT '08' AS CODE_CD , '103' AS LVL_CD, 'E' AS SEX  FROM DUAL  
        ) Y
        WHERE X.SEX     (+)  = Y.SEX
        AND   X.LVL_CD  (+)  = Y.LVL_CD
        AND   X.CODE_CD (+)  = Y.CODE_CD
    )
    PIVOT
    ( 
     --MAX(LVL_CD) AS LVL_CD, MAX(SEX) AS SEX,  MAX(CNT) AS CNT ,MAX(HAP) AS HAP   FOR RN IN (1 ,2,3,4,5,6,7,8,9 )
     MAX(LVL_CD) AS LVL_CD, MAX(SEX) AS SEX,  MAX(CNT) AS CNT ,MAX(HAP) AS HAP   FOR RN IN (1 RM ,2 RF ,3 RE ,4 GM ,5 GF,6 GE,7 SM,8 SF,9 SE)
    )A
    ORDER BY  CODE_CD    
    ;
  
END COUPON_STATS_RETURN5_SELECT;

/
