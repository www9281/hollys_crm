--------------------------------------------------------
--  DDL for Procedure PROMOTION_COUPON_CUST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_COUPON_CUST_SELECT" (
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
    v_total_rows    NUMBER;
BEGIN

    SELECT 
    COUNT(*) INTO v_total_rows  
    FROM PROMOTION_COUPON
    WHERE PUBLISH_ID = P_PUBLISH_ID
    ;
    
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=FORCE';
    
  --  IF P_PAGE = '1' THEN         
        OPEN       O_CURSOR  FOR
            SELECT 
                   RNUM AS NO
                 , FLOOR((ROWNUM-1)/ TO_NUMBER(P_ROWS) +1) AS PAGE
                 , FLOOR((v_total_rows-1)/ TO_NUMBER(P_ROWS) +1) AS PAGECNT
                 , v_total_rows AS TOTAL 
                 , COUPON_CD
                 , PUBLISH_ID
                 , CUST_ID
                 , DECRYPT(CUST_NM) AS CUST_NM 
                 , FN_GET_FORMAT_HP_NO(DECRYPT(MOBILE)) AS MOBILE
                 , CASE WHEN SEX_DIV = 'M' THEN '남성'
                        WHEN SEX_DIV = 'F' THEN '여성'    
                        ELSE ''
                   END                                  AS SEX_DIV
                 , TO_CHAR(TO_DATE(USE_DT,'YYYYMMDD'),'YYYY-MM-DD')
                 , TO_CHAR(TO_DATE(DESTROY_DT,'YYYYMMDD'),'YYYY-MM-DD')
                 , COUPON_STATE
                 , SUBSTR(START_DT,1,4) || '-' || SUBSTR(START_DT,5,2) || '-' || SUBSTR(START_DT,7,2) AS START_DT
                 , SUBSTR(  END_DT,1,4) || '-' || SUBSTR(END_DT,5,2)   || '-' || SUBSTR(END_DT,7,2)   AS END_DT
                 , STOR_NM
                 , INST_DT
                 , DEVICE_DIV
            FROM ( 
                SELECT 
                    ROWNUM AS RNUM, Z.* 
                FROM (
                      SELECT
                             COUPON_CD
                           , A.PUBLISH_ID
                           , CUST_ID
                           , CUST_NM 
                           , MOBILE
                           , SEX_DIV 
                           , USE_DT
                           , DESTROY_DT
                           , COUPON_STATE
                           , START_DT
                           ,  END_DT
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
                           FROM PROMOTION_COUPON A ,  C_CUST C,  C_CUST_DEVICE D 
                           WHERE 1 = 1 
                           AND A.CUST_ID = C.CUST_ID(+)
                           AND A.CUST_ID = D.CUST_ID(+)
                           AND C.COMP_CD = '016'
                           AND A.PUBLISH_ID  = P_PUBLISH_ID 
                      )A , PROMOTION_COUPON_PUBLISH B   , STORE S 
                      WHERE 1 = 1 
                      AND   A.PUBLISH_ID  = B.PUBLISH_ID
                      AND   A.STOR_CD     = S.STOR_CD(+)  
                      AND   B.PRMT_ID     = P_PRMT_ID
                      AND   B.PUBLISH_ID  = P_PUBLISH_ID                      
                      ORDER BY A.COUPON_CD 
                  ) Z 
                  WHERE ROWNUM <= v_total_rows - (P_ROWS * (P_PAGE-1))
             )ZZ
             WHERE RNUM >= v_total_rows - (P_ROWS * P_PAGE) + 1 
             ORDER BY RNUM DESC
             ;
        
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING=SIMILAR';        
END PROMOTION_COUPON_CUST_SELECT;

/
