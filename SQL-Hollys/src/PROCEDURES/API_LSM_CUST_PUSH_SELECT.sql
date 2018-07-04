--------------------------------------------------------
--  DDL for Procedure API_LSM_CUST_PUSH_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_LSM_CUST_PUSH_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	LSM 쿠폰PUSH 전송(고객 및 쿠폰목록)
-- Test			:	exec API_LSM_CUST_PUSH_SELECT '002', 'Y', 'C5001', 'C6002', '프로모션', '2017-10-01', '2017-10-31', 'ADMIN'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_START_DT      IN   VARCHAR2,
        P_END_DT        IN   VARCHAR2,
        P_USER_ID       IN   VARCHAR2,   
        O_RTN_CD        OUT   VARCHAR2,
        O_CURSOR        OUT  SYS_REFCURSOR
) AS 
        v_result_cd VARCHAR2(7) := '1'; -- 성공(전체결과)  
BEGIN  
        OPEN       O_CURSOR  FOR  
        SELECT     C.PRMT_ID AS PRMT_ID
                   ,( 
                        SELECT H.STOR_NM 
                        FROM   PROMOTION_CAN_STOR G 
                        JOIN   STORE H 
                        ON     G.STOR_CD = H.STOR_CD
                        WHERE  G.PRMT_ID = C.PRMT_ID
                   ) AS STOR_NM
                   ,E.CUST_ID AS CUST_ID
                   ,E.CUST_WEB_ID AS CUST_WEB_ID
                   ,DECRYPT(E.MOBILE) AS MOBILE
                   ,F.DEVICE_DIV AS DEVICE_DIV 
                   ,F.DEVICE_NM AS DEVICE_NM 
                   ,F.AUTH_ID AS AUTH_ID
                   ,F.AUTH_TOKEN AS AUTH_TOKEN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'couponEnd') AS COUPON_END_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'membershipCoupon') AS MEMBERSHIP_COUPON_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'promotion') AS PROMOTION_EVENT_YN
                   ,(SELECT DIV_YN FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_YN
                   ,(SELECT TO_CHAR(INST_DT, 'YYYYMMDD') FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_INST_DT
                   ,(SELECT TO_CHAR(UPD_DT, 'YYYYMMDD') FROM C_CUST_DEVICE_PUSH WHERE CUST_ID = E.CUST_ID AND DIV_NM = 'gpsAgree') AS GPS_AGREE_UPD_DT                   
        FROM       PROMOTION_PUSH A
        JOIN       PROMOTION B
        ON         A.PRMT_ID = B.PRMT_ID
        JOIN       PROMOTION_COUPON_PUBLISH C
        ON         A.PRMT_ID = C.PRMT_ID
        JOIN       PROMOTION_COUPON D
        ON         D.PUBLISH_ID = C.PUBLISH_ID
        JOIN       C_CUST E
        ON         E.CUST_ID = D.CUST_ID
        JOIN       C_CUST_DEVICE F
        ON         F.CUST_ID = E.CUST_ID
        WHERE      B.PRMT_CLASS = 'C5002'
        AND        (B.PRMT_USE_DIV = 'C6923' OR B.PRMT_USE_DIV = 'C6924')
        AND        (P_START_DT <= TO_CHAR(D.INST_DT,'YYYYMMDDHH24') AND P_END_DT >= TO_CHAR(D.INST_DT,'YYYYMMDDHH24'));

        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);

END API_LSM_CUST_PUSH_SELECT;

/
