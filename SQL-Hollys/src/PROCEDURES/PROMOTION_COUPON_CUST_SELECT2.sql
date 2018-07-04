--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_CUST_SELECT2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_CUST_SELECT2" (
-- ==========================================================================================
-- Author        :    권혁민
-- Create date    :    2017-11-16
-- Description    :    프로모션 쿠폰 및 대상고객 목록 조회
-- Test            :    exec PROMOTION_COUPON_CUST_SELECT '002'
-- ==========================================================================================
        P_PRMT_ID       IN   VARCHAR2,
        P_PUBLISH_ID    IN   VARCHAR2,         
        P_ROWS          IN   VARCHAR2,
        P_PAGE          IN   VARCHAR2,
        O_CURSOR        OUT PKG_REPORT.REF_CUR
) AS 
    ls_sql          VARCHAR2(30000);
BEGIN  

    
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    OPEN       O_CURSOR  FOR
    SELECT * 
    FROM(
        SELECT 
               COUNT(*) OVER()  - ROWNUM + 1 AS NO
             , FLOOR((ROWNUM-1)/ TO_NUMBER(P_ROWS) +1) AS PAGE
             , FLOOR((COUNT(*) OVER()-1)/ TO_NUMBER(P_ROWS) +1) AS PAGECNT
             , COUNT(*) OVER() AS TOTAL
             , X.*
        FROM  
        (
              SELECT 
                     COUPON_CD
                   , A.PUBLISH_ID
                   , CUST_ID
                   , DECRYPT(CUST_NM) AS CUST_NM 
                   , MOBILE
                   , SEX_DIV
                   , USE_DT
                   , DESTROY_DT
                   , COUPON_STATE
                   , START_DT
                   , END_DT
                   , STOR_NM
                   , A.INST_DT
              FROM(
                   SELECT 
                            A.COUPON_CD                            AS COUPON_CD
                          , A.PUBLISH_ID                           AS PUBLISH_ID
                          , A.CUST_ID                              AS CUST_ID
                          , C.CUST_NM                              AS CUST_NM
                          , FN_GET_FORMAT_HP_NO(DECRYPT(C.MOBILE)) AS MOBILE
                          , CASE WHEN C.SEX_DIV = 'M' THEN '남성'  
                                            ELSE '여성'
                                       END                         AS SEX_DIV
                          , TO_CHAR(TO_DATE(A.USE_DT,'YYYYMMDD'),'YYYY-MM-DD')     AS USE_DT
                          , TO_CHAR(TO_DATE(A.DESTROY_DT,'YYYYMMDD'),'YYYY-MM-DD') AS DESTROY_DT
                          , A.COUPON_STATE                                         AS COUPON_STATE
                          , SUBSTR(A.START_DT,1,4) || '-' || SUBSTR(A.START_DT,5,2) || '-' || SUBSTR(A.START_DT,7,2) AS START_DT
                          , SUBSTR(A.END_DT,1,4)   || '-' || SUBSTR(A.END_DT,5,2)   || '-' || SUBSTR(A.END_DT,7,2)   AS END_DT
                          , S.STOR_NM
                          , A.INST_DT
                   FROM PROMOTION_COUPON A , STORE S , C_CUST C 
                   WHERE 1 = 1 AND A.CUST_ID = C.CUST_ID
                   AND A.STOR_CD = S.STOR_CD(+)
                   AND C.COMP_CD = '016'
                   AND A.PUBLISH_ID  = P_PUBLISH_ID
                   UNION  ALL
                   SELECT  
                            A.COUPON_CD                            AS COUPON_CD
                          , A.PUBLISH_ID                           AS PUBLISH_ID
                          , A.CUST_ID                              AS CUST_ID
                          , NULL                                   AS CUST_NM
                          , NULL                                   AS MOBILE
                          , NULL                                   AS SEX_DIV
                          , TO_CHAR(TO_DATE(A.USE_DT,'YYYYMMDD'),'YYYY-MM-DD')     AS USE_DT
                          , TO_CHAR(TO_DATE(A.DESTROY_DT,'YYYYMMDD'),'YYYY-MM-DD') AS DESTROY_DT
                          , A.COUPON_STATE                                         AS COUPON_STATE
                          , SUBSTR(A.START_DT,1,4) || '-' || SUBSTR(A.START_DT,5,2) || '-' || SUBSTR(A.START_DT,7,2) AS START_DT
                          , SUBSTR(A.END_DT,1,4)   || '-' || SUBSTR(A.END_DT,5,2)   || '-' || SUBSTR(A.END_DT,7,2)   AS END_DT
                          , S.STOR_NM
                          , A.INST_DT
                   FROM PROMOTION_COUPON A  , STORE S
                   WHERE 1 = 1 AND A.CUST_ID IS NULL
                   AND A.STOR_CD = S.STOR_CD(+)
                   AND A.PUBLISH_ID  = P_PUBLISH_ID
              )A , PROMOTION_COUPON_PUBLISH B  
              WHERE 1 = 1 
              AND   A.PUBLISH_ID  = B.PUBLISH_ID 
              AND   B.PRMT_ID     = P_PRMT_ID
              AND   B.PUBLISH_ID  = P_PUBLISH_ID
              ORDER BY A.INST_DT DESC
        )X 
    )WHERE PAGE = TO_NUMBER(P_PAGE)
    ;


        
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';        
END PROMOTION_COUPON_CUST_SELECT2;

/
