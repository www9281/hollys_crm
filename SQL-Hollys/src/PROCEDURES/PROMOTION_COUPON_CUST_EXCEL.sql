--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_CUST_EXCEL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_CUST_EXCEL" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-11-16
-- Description    :    프로모션 쿠폰 및 대상고객 목록 조회
-- Test            :    exec PROMOTION_COUPON_CUST_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_PUBLISH_ID    IN   VARCHAR2,    
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR      
           SELECT  
                     COUPON_CD
                   , A.PUBLISH_ID
                   , CUST_ID
                   , DECRYPT(CUST_NM)                     AS CUST_NM
                   , FN_GET_FORMAT_HP_NO(DECRYPT(MOBILE)) AS MOBILE
                   , CASE WHEN  SEX_DIV = 'M' THEN '남성'  
                          WHEN  SEX_DIV = 'F' THEN '여성'  
                         ELSE   ''
                    END                                   AS SEX_DIV 
                   , TO_CHAR(TO_DATE(USE_DT,'YYYYMMDD'),'YYYY-MM-DD')     AS USE_DT
                   , TO_CHAR(TO_DATE(DESTROY_DT,'YYYYMMDD'),'YYYY-MM-DD') AS DESTROY_DT
                   , COUPON_STATE
                   , SUBSTR(START_DT,1,4) || '-' || SUBSTR(START_DT,5,2) || '-' || SUBSTR(START_DT,7,2) AS START_DT
                   , SUBSTR(END_DT,1,4) || '-' || SUBSTR(END_DT,5,2) || '-' || SUBSTR(END_DT,7,2)       AS END_DT
                   , STOR_NM
                   , A.INST_DT
                   , DEVICE_DIV
              FROM(
                   SELECT /*+ INDEX(A PROMOTION_COUPON_PK) */ 
                            A.COUPON_CD
                          , A.PUBLISH_ID
                          , A.CUST_ID
                          , C.CUST_NM
                          , C.MOBILE
                          , C.SEX_DIV
                          , A.USE_DT
                          , A.DESTROY_DT
                          , A.COUPON_STATE        
                          , A.START_DT
                          , A.END_DT
                          , A.INST_DT
                          , A.STOR_CD
                          , D.DEVICE_DIV
                   FROM PROMOTION_COUPON A ,  C_CUST C , C_CUST_DEVICE D 
                   WHERE 1 = 1 
                   AND A.CUST_ID = C.CUST_ID
                   AND A.CUST_ID = D.CUST_ID(+)
                   AND C.COMP_CD = '016'
                   AND A.PUBLISH_ID  = P_PUBLISH_ID 
              )A , PROMOTION_COUPON_PUBLISH B  , STORE S 
              WHERE 1 = 1 
              AND   A.PUBLISH_ID  = B.PUBLISH_ID
              AND   A.STOR_CD = S.STOR_CD(+) 
              AND   B.PRMT_ID     = P_PRMT_ID
              AND   B.PUBLISH_ID  = P_PUBLISH_ID
              ;
END PROMOTION_COUPON_CUST_EXCEL;

/
