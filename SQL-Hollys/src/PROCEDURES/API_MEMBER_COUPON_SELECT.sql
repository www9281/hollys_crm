--------------------------------------------------------
--  DDL for Procedure API_MEMBER_COUPON_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_MEMBER_COUPON_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	멤버십쿠폰정보 목록 조회
-- Test			:	exec API_MEMBER_COUPON_SELECT '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2,
        P_STOR_CD       IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2, 
        O_RTN_CD        OUT  VARCHAR2, 
        O_CURSOR        OUT  SYS_REFCURSOR 
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
BEGIN  
        OPEN       O_CURSOR  FOR
        SELECT  
                   B.PRMT_ID AS PRMT_ID
                   ,C.PRMT_USE_DIV AS PRMT_USE_DIV 
                   ,C.PRMT_ID AS PRMT_ID2
                   , (CASE WHEN C.PRMT_USE_DIV = 'C6921' THEN (SELECT PREFACE FROM PROMOTION_PRINT WHERE PRMT_ID = C.PRMT_ID)
                           WHEN C.PRMT_USE_DIV = 'C6922' THEN (SELECT SMS_TITLE FROM PROMOTION_SMS WHERE PRMT_ID = C.PRMT_ID)
                           WHEN C.PRMT_USE_DIV = 'C6923' THEN (SELECT PUSH_TITLE FROM PROMOTION_PUSH WHERE PRMT_ID = C.PRMT_ID)
                           ELSE '' 
                      END
                   ) AS PRMT_NM 
                   , A.COUPON_CD  AS COUPON_CD
                   , A.START_DT  AS START_DT
                   , A.END_DT  AS END_DT
                   , (CASE WHEN A.USE_DT IS NULL AND A.DESTROY_DT IS NULL AND (A.START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD')) THEN 'Y' 
                           ELSE 'N'
                      END) AS USE_YN
                   , (CASE WHEN A.STOR_CD IS NOT NULL THEN A.STOR_CD
                           ELSE NULL
                      END
                   ) AS STOR_CD
                   , (CASE WHEN A.USE_DT IS NOT NULL THEN A.USE_DT
                           ELSE NULL 
                      END
                   ) AS USE_DT
                   , B.NOTES  AS NOTES
                   ,A.TG_STOR_CD
        FROM    PROMOTION_COUPON A 
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID 
        JOIN    PROMOTION C
        ON      C.COMP_CD = P_COMP_CD
        AND     C.BRAND_CD = P_BRAND_CD
        AND     C.PRMT_ID = B.PRMT_ID
        WHERE   A.CUST_ID = P_CUST_ID
        AND     A.USE_DT IS NULL
        AND     A.DESTROY_DT IS NULL
        AND     (A.START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD') 
        AND     A.END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD'))               --최인태 20180416 만료된 쿠폰 안 내려보내도록 수정
        AND     (A.TG_STOR_CD IS NULL OR A.TG_STOR_CD = P_STOR_CD);
        
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
END API_MEMBER_COUPON_SELECT;

/
