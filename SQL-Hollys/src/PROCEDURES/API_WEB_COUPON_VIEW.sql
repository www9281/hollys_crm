--------------------------------------------------------
--  DDL for Procedure API_WEB_COUPON_VIEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_WEB_COUPON_VIEW" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰정보 목록 조회
-- Test			:	exec API_WEB_COUPON_VIEW '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2,
        P_COUPON_CD     IN   VARCHAR2, 
        P_USER_ID       IN   VARCHAR2,
        O_RTN_CD        OUT  VARCHAR2, 
        O_CURSOR        OUT  SYS_REFCURSOR
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공 
BEGIN  
        OPEN    O_CURSOR  FOR  
        SELECT
                B.PRMT_ID AS PRMT_ID  
                ,REGEXP_REPLACE(GET_PROMOTION_NM(C.PRMT_ID,'016'), '서브_')  AS PRMT_NM 
                ,A.COUPON_CD  AS COUPON_CD  
                ,A.START_DT  AS START_DT  
                ,A.END_DT  AS END_DT
                ,A.COUPON_STATE AS COUPON_STATE
                ,B.PUBLISH_TYPE AS COUPON_DIV
                ,A.COUPON_IMG AS COUPON_IMG,
                (
                    CASE WHEN (SELECT COUPON_CD FROM PROMOTION_COUPON_HIS WHERE COUPON_CD = A.COUPON_CD AND TO_CUST_ID = P_CUST_ID) IS NOT NULL THEN 1
                         ELSE 0
                    END
                ) AS IS_RECEIVE,
                (CASE WHEN C.COUPON_NOTICE_PRINT = 'Y' THEN C.COUPON_NOTICE
                      ELSE ''
                 END
                ) AS COUPON_NOTICE
                ,(SELECT STOR_NM FROM STORE WHERE A.TG_STOR_CD = STOR_CD) AS STOR_NM
        FROM    PROMOTION_COUPON A
        JOIN    PROMOTION_COUPON_PUBLISH B
        ON      A.PUBLISH_ID = B.PUBLISH_ID 
        JOIN    PROMOTION C
        ON      C.COMP_CD = P_COMP_CD
        AND     C.BRAND_CD = P_BRAND_CD 
        AND     C.PRMT_ID = B.PRMT_ID
        LEFT OUTER JOIN   STORE D
        ON      A.STOR_CD = D.STOR_CD
        WHERE   A.CUST_ID = P_CUST_ID
        AND     A.COUPON_CD = P_COUPON_CD

        UNION ALL
        
        SELECT  E.PRMT_ID AS PRMT_ID
                ,REGEXP_REPLACE(GET_PROMOTION_NM(E.PRMT_ID,'016'), '서브_')  AS PRMT_NM 
                ,D.COUPON_CD AS COUPON_CD
                ,D.START_DT AS START_DT
                ,D.END_DT AS END_DT
                ,D.COUPON_STATE AS COUPON_STATE 
                ,E.PUBLISH_TYPE AS COUPON_DIV
                ,D.COUPON_IMG
                ,0 AS IS_RECEIVE
                ,(CASE WHEN F.COUPON_NOTICE_PRINT = 'Y' THEN F.COUPON_NOTICE
                      ELSE ''
                 END
                ) AS COUPON_NOTICE
                ,(SELECT STOR_NM FROM STORE WHERE D.PUB_STOR_CD = STOR_CD) AS STOR_NM
        FROM    PROMOTION_COUPON_HIS D
        JOIN    PROMOTION_COUPON_PUBLISH E
        ON      D.PUBLISH_ID = E.PUBLISH_ID 
        JOIN    PROMOTION F
        ON      F.COMP_CD = P_COMP_CD
        AND     F.BRAND_CD = P_BRAND_CD
        AND     F.PRMT_ID = E.PRMT_ID
        LEFT OUTER JOIN    STORE G
        ON      D.STOR_CD = G.STOR_CD
        WHERE   D.FROM_CUST_ID = P_CUST_ID
        AND     D.COUPON_CD = P_COUPON_CD;
        
        dbms_output.put_line(SQLERRM);
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
END API_WEB_COUPON_VIEW;

/
