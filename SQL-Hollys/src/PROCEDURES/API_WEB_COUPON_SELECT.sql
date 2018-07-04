--------------------------------------------------------
--  DDL for Procedure API_WEB_COUPON_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."API_WEB_COUPON_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	쿠폰정보 목록 조회
-- Test			:	exec API_WEB_COUPON_SELECT '016', '102', '13'
-- ==========================================================================================
        P_COMP_CD       IN   VARCHAR2,
        P_BRAND_CD      IN   VARCHAR2,
        P_CUST_ID       IN   VARCHAR2, 
        N_COUPON_DIV    IN   VARCHAR2,
        P_COUPON_STATE  IN   VARCHAR2, 
        P_USER_ID       IN   VARCHAR2,   
        O_RTN_CD        OUT  VARCHAR2, 
        O_CURSOR        OUT  SYS_REFCURSOR 
) AS
        v_result_cd VARCHAR2(7) := '1'; --성공
BEGIN  
        OPEN    O_CURSOR  FOR 
        SELECT  X.*
        FROM (
            SELECT
                    B.PRMT_ID AS PRMT_ID
                    ,REGEXP_REPLACE(GET_PROMOTION_NM(B.PRMT_ID,'016'), '서브_')  AS PRMT_NM 
                    ,A.COUPON_CD  AS COUPON_CD
                    ,A.START_DT  AS START_DT
                    ,A.END_DT  AS END_DT
                    ,A.COUPON_STATE AS COUPON_STATE
                    ,B.PUBLISH_TYPE AS COUPON_DIV
                    ,A.COUPON_IMG,
                    (
                        CASE WHEN (SELECT COUPON_CD FROM PROMOTION_COUPON_HIS WHERE COUPON_CD = A.COUPON_CD AND TO_CUST_ID = P_CUST_ID) IS NOT NULL THEN 1
                             ELSE 0
                        END
                    ) AS IS_RECEIVE
                    ,A.UPD_DT AS UPD_DT
                    ,(SELECT STOR_NM FROM STORE WHERE A.TG_STOR_CD = STOR_CD) AS STOR_NM
            FROM    PROMOTION_COUPON A
            JOIN    PROMOTION_COUPON_PUBLISH B
            ON      A.PUBLISH_ID = B.PUBLISH_ID
           LEFT OUTER JOIN  STORE C
            ON      A.STOR_CD = C.STOR_CD
            WHERE   A.CUST_ID = P_CUST_ID
            AND     (TRIM(N_COUPON_DIV) IS NULL OR B.PUBLISH_TYPE = N_COUPON_DIV)
            AND     (
                       (P_COUPON_STATE = '301' AND A.COUPON_STATE = 'P0303' AND A.USE_DT IS NULL AND A.DESTROY_DT IS NULL AND A.END_DT >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
                    OR (P_COUPON_STATE = '302' AND A.COUPON_STATE = 'P0301')
                    OR (P_COUPON_STATE = '302' AND A.USE_DT IS NULL AND A.DESTROY_DT IS NULL AND A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD'))
                    )
            AND     A.START_DT <= TO_CHAR(SYSDATE  ,'YYYYMMDD')
            UNION ALL            
            SELECT  E.PRMT_ID AS PRMT_ID
                    ,REGEXP_REPLACE(GET_PROMOTION_NM(E.PRMT_ID,'016'), '서브_') AS PRMT_NM
                    ,D.COUPON_CD AS COUPON_CD
                    ,D.START_DT AS START_DT
                    ,D.END_DT AS END_DT
                    ,D.COUPON_STATE AS COUPON_STATE
                    ,E.PUBLISH_TYPE AS COUPON_DIV
                    ,D.COUPON_IMG AS COUPON_IMG
                    ,0 AS IS_RECEIVE
                    ,D.INST_DT AS UPD_DT
                    ,(SELECT STOR_NM FROM STORE WHERE D.PUB_STOR_CD = STOR_CD) AS STOR_NM
            FROM    PROMOTION_COUPON_HIS D
            JOIN    PROMOTION_COUPON_PUBLISH E  
            ON      D.PUBLISH_ID = E.PUBLISH_ID
            LEFT OUTER JOIN    STORE G
            ON      D.STOR_CD = G.STOR_CD
            WHERE   D.FROM_CUST_ID = P_CUST_ID
            AND     (P_COUPON_STATE = '302' AND (D.USE_DT IS NULL AND D.DESTROY_DT IS NULL AND D.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD')) OR (P_COUPON_STATE = '302' AND D.COUPON_STATE = 'P0305'))
        ) X
        ORDER BY X.UPD_DT DESC;
        
        O_RTN_CD := v_result_cd;

EXCEPTION
    WHEN OTHERS THEN
        O_RTN_CD  := '2'; --실패
        dbms_output.put_line(SQLERRM);
END API_WEB_COUPON_SELECT;

/
