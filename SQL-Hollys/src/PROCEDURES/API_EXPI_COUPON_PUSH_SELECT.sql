--------------------------------------------------------
--  DDL for Procedure API_EXPI_COUPON_PUSH_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_EXPI_COUPON_PUSH_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	App 만료쿠폰PUSH 전송(할리스콘)
-- Test			:	exec API_EXPI_COUPON_PUSH_SELECT '002', 'Y', 'C5001', 'C6002'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_EXPI_DT       IN   VARCHAR2, 
        P_USER_ID       IN   VARCHAR2,
        O_RTN_CD        OUT   VARCHAR2, 
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)
BEGIN  
        OPEN       O_CURSOR  FOR 
        SELECT     A.COUPON_CD AS COUPON_CD 
                   ,A.CUST_ID AS CUST_ID
                   ,C.CUST_WEB_ID AS CUST_WEB_ID
                   ,DECRYPT(C.MOBILE) AS MOBILE  
                   ,D.DEVICE_DIV AS DEVICE_DIV
                   ,D.DEVICE_NM AS DEVICE_NM
                   ,D.AUTH_ID AS AUTH_ID
                   ,D.AUTH_TOKEN AS AUTH_TOKEN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'couponEnd') AS COUPON_END_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'membershipCoupon') AS MEMBERSHIP_COUPON_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'promotion') AS PROMOTION_EVENT_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_YN
                   ,(SELECT TO_CHAR(INST_DT, 'YYYYMMDD') FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_INST_DT
                   ,(SELECT TO_CHAR(UPD_DT, 'YYYYMMDD') FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = C.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_UPD_DT
                   /*,(
                        SELECT E.PRMT_ID || '_' || E.ITEM_CD
                        FROM   PROMOTION_BNFIT_MN E
                        JOIN   PROMOTION_COUPON_PUBLISH F 
                        ON     E.PRMT_ID = F.PRMT_ID 
                        WHERE  A.PUBLISH_ID = F.PUBLISH_ID  
                   )AS PRMT_ITEM_CD*/
        FROM       PROMOTION_COUPON A
        JOIN       PROMOTION_COUPON_PUBLISH B
        ON         A.PUBLISH_ID = B.PUBLISH_ID
        JOIN       C_CUST C
        ON         A.CUST_ID = C.CUST_ID
        JOIN       C_CUST_DEVICE D
        ON         A.CUST_ID = D.CUST_ID
        WHERE      B.PUBLISH_TYPE = 'C6503'
        AND        A.USE_DT IS NULL
        AND        A.DESTROY_DT IS NULL
        AND        A.COUPON_STATE = 'P0303'
        AND        (A.START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD') OR A.END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
        AND        A.END_DT = P_EXPI_DT
        ORDER BY 
                   A.INST_DT DESC;
        
        dbms_output.put_line(SQLERRM);           
        O_RTN_CD := v_result_cd;
                   
EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
        
END API_EXPI_COUPON_PUSH_SELECT;

/
