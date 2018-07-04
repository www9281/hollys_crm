--------------------------------------------------------
--  DDL for Procedure HOLLYS_CON_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."HOLLYS_CON_SELECT" (
-- ==========================================================================================
-- Author		:	권혁민
-- Create date	:	2017-10-31
-- Description	:	할리스콘조회
-- Test			:	exec HOLLYS_CON_SELECT 
-- ==========================================================================================
        P_COMP_CD     IN   VARCHAR2,
        P_BRAND_CD    IN   VARCHAR2,
        N_PRMT_ID     IN   VARCHAR2,
        N_COUPON_CD   IN   VARCHAR2,
        N_CUST_ID     IN   VARCHAR2,
        N_START_DT    IN   VARCHAR2,
        N_END_DT      IN   VARCHAR2, 
        O_CURSOR      OUT  SYS_REFCURSOR
) AS 
BEGIN  
        OPEN    O_CURSOR  FOR
        WITH    AA AS   (
                SELECT  A.CUST_ID,
                        A.COUPON_CD,
                        B.PUBLISH_ID,
                        C.PRMT_NM AS COUPON_NM,
                        TO_CHAR(TO_DATE(A.START_DT,'YYYYMMDD'),'YYYY-MM-DD') AS START_DT,
                        TO_CHAR(TO_DATE(A.END_DT,'YYYYMMDD'),'YYYY-MM-DD') AS END_DT,
                        TO_CHAR(TO_DATE(A.USE_DT,'YYYYMMDD'),'YYYY-MM-DD') AS USE_DT,
                        GET_STOR_NM(P_BRAND_CD,A.STOR_CD,'KOR') AS STOR_NM,
                        A.COUPON_STATE,
                        CASE  WHEN  A.COUPON_STATE = 'P0304'
                              THEN  '구매취소'
                              ELSE  GET_COMMON_CODE_NM('P0300',A.COUPON_STATE,'KOR') 
                        END AS COUPON_STATE_NM,
                        A.INST_DT
                FROM    PROMOTION_COUPON A
                JOIN    PROMOTION_COUPON_PUBLISH B
                ON      A.PUBLISH_ID = B.PUBLISH_ID 
                JOIN    PROMOTION C
                ON      B.PRMT_ID = C.PRMT_ID
                WHERE   C.COMP_CD = P_COMP_CD
                AND     C.BRAND_CD = P_BRAND_CD
                AND     C.PRMT_CLASS = 'C5004'
                AND     (TRIM(N_PRMT_ID) IS NULL OR C.PRMT_ID = N_PRMT_ID)
                AND     (TRIM(N_COUPON_CD) IS NULL OR A.COUPON_CD = N_COUPON_CD)
                AND     (TRIM(N_CUST_ID) IS NULL OR A.CUST_ID = N_CUST_ID)
                AND     (TRIM(N_START_DT) IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') >= N_START_DT)
                AND     (TRIM(N_END_DT) IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') >= N_END_DT)
        ),
                BB AS (
                SELECT  A.COUPON_CD,
                        DECRYPT(A.CARD_ID) AS CARD_ID,
                        --DECRYPT(A.CUST_NM) AS CUST_NM,
                        DECRYPT(A.CUST_NM) AS CUST_NM,
                        FN_GET_FORMAT_HP_NO(DECRYPT(A.MOBILE)) AS MOBILE,
                        A.COUPON_PRICE AS COUPON_PRICE,
                        A.CREDIT_PAYMENT AS CREDIT_PAYMENT,
                        A.PT_PAYMENT AS PT_PAYMENT,
                        A.MOBILE_PAYMENT AS MOBILE_PAYMENT,
                        A.ETC_PAYMENT AS ETC_PAYMENT,
                        TO_CHAR(TO_DATE(A.BUY_DT,'YYYYMMDD'),'YYYY-MM-DD') AS BUY_DT,
                        A.EXTENSION_COUNT AS EXTENSION_COUNT,
                        A.SEND_COUNT AS SEND_COUNT,
                        A.INST_DT AS INST_DT,
                        A.HOLLYS_CON_HIS_SEQ,
                        DECRYPT(A.TO_CUST_NM) AS TO_CUST_NM,
                        FN_GET_FORMAT_HP_NO(DECRYPT(A.RECEPTION_MOBILE)) AS RECEPTION_MOBILE
                FROM    HOLLYS_CON_HIS A
                WHERE   A.COUPON_CD IN    (
                                                  SELECT  COUPON_CD FROM AA
                        )
                AND     A.HOLLYS_CON_HIS_SEQ =  (
                                                        SELECT  MAX(HOLLYS_CON_HIS_SEQ)
                                                        FROM    HOLLYS_CON_HIS
                                                        WHERE   COUPON_CD = A.COUPON_CD
                                                )
        )
        SELECT  B.CARD_ID,
                A.CUST_ID,
                B.CUST_NM,
                B.MOBILE,
                A.COUPON_CD,
                A.COUPON_NM,
                A.PUBLISH_ID,
                B.COUPON_PRICE,
                B.CREDIT_PAYMENT,
                B.PT_PAYMENT,
                B.MOBILE_PAYMENT,
                B.ETC_PAYMENT,
                A.START_DT,
                A.END_DT,
                B.BUY_DT,
                A.USE_DT,
                A.STOR_NM,
                A.COUPON_STATE,
                A.COUPON_STATE_NM,
                B.EXTENSION_COUNT,
                B.SEND_COUNT,
                A.INST_DT,
                B.HOLLYS_CON_HIS_SEQ,
                B.TO_CUST_NM,
                B.RECEPTION_MOBILE
        FROM    AA A
        JOIN    BB B
        ON      A.COUPON_CD = B.COUPON_CD
        ORDER BY B.BUY_DT DESC;
                    
END HOLLYS_CON_SELECT;

/
