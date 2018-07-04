--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_CUST_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_CUST_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-11-16
-- Description	:	프로모션 쿠폰 및 대상고객 단건 조회
-- Test			:	exec PROMOTION_COUPON_CUST_VIEW '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_PUBLISH_ID    IN   VARCHAR2,
        P_COUPON_CD    IN   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     A.COUPON_CD AS COUPON_CD
                  ,A.PUBLISH_ID AS PUBLISH_ID
                  ,A.CUST_ID AS CUST_ID
                  ,(
                        SELECT DECRYPT(CUST_NM)
                        FROM   C_CUST
                        WHERE  CUST_ID = A.CUST_ID  
                  ) AS CUST_NM
                  ,( 
                        SELECT FN_GET_FORMAT_HP_NO(DECRYPT(MOBILE)) 
                        FROM   C_CUST
                        WHERE  CUST_ID = A.CUST_ID
                  ) AS MOBILE
                  ,(
                        SELECT CASE WHEN SEX_DIV = 'M' THEN '남성'  
                                    WHEN SEX_DIV = 'F' THEN '여성'  
                                    ELSE ''
                               END
                        FROM   C_CUST
                        WHERE  CUST_ID = A.CUST_ID
                  ) AS SEX_DIV
                  ,TO_CHAR(TO_DATE(A.USE_DT,'YYYYMMDD'),'YYYY-MM-DD') AS USE_DT
                  ,TO_CHAR(TO_DATE(A.DESTROY_DT,'YYYYMMDD'),'YYYY-MM-DD') AS DESTROY_DT
                  ,(
                        SELECT STOR_NM
                        FROM   STORE
                        WHERE  STOR_CD = A.STOR_CD
                  ) AS STOR_NM
                  ,A.COUPON_STATE AS COUPON_STATE
                  ,SUBSTR(A.START_DT,1,4) || '-' || SUBSTR(A.START_DT,5,2) || '-' || SUBSTR(A.START_DT,7,2) AS START_DT
                  ,SUBSTR(A.END_DT,1,4) || '-' || SUBSTR(A.END_DT,5,2) || '-' || SUBSTR(A.END_DT,7,2) AS END_DT
        FROM       PROMOTION_COUPON A
        JOIN       PROMOTION_COUPON_PUBLISH B
        ON         A.PUBLISH_ID = B.PUBLISH_ID
        AND        B.PRMT_ID = P_PRMT_ID
        WHERE      
--        B.PUBLISH_ID = P_PUBLISH_ID        AND                    20180425 최인태 (쿠폰 단건 검색 범위 확대 요청으로 인한 수정)
        (TRIM(P_COUPON_CD) IS NULL OR A.COUPON_CD LIKE '%' || P_COUPON_CD || '%')
        AND        ROWNUM <= 1000
        ORDER BY 
                   A.INST_DT DESC;
END PROMOTION_COUPON_CUST_VIEW;

/
