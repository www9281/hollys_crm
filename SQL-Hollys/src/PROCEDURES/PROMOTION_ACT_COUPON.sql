--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_COUPON
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_COUPON" (
    N_START_DT  IN  VARCHAR2,
    N_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    N_PRMT_TYPE IN  VARCHAR2,
    N_PRMT_ID   IN  VARCHAR2,
    N_COUPON_CD IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN  

    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-21
    -- Description	:	프로모션 쿠폰별 할인액  조회
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    /*
    WITH C_LIST AS
    (SELECT DISTINCT A.PRMT_ID AS CODE_CD
                ,REGEXP_REPLACE(GET_PROMOTION_NM(A.PRMT_ID,'016'), '서브_')  AS CODE_NM
         FROM   PROMOTION A
         JOIN   PROMOTION_COUPON_PUBLISH B
         ON     A.PRMT_ID = B.PRMT_ID
         WHERE  A.PRMT_COUPON_YN = 'Y' 
         AND    A.PRMT_TYPE <> 'C6015' 
         AND    A.PRMT_TYPE <> 'C6018'
         AND    (TRIM(N_PRMT_TYPE) IS NULL OR B.PUBLISH_TYPE = N_PRMT_TYPE))
    SELECT
      ROW_NUMBER() OVER (ORDER BY A.INST_DT ASC) AS RNUM
      ,A.STOR_CD
      ,(SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD AND BRAND_CD = '100') AS STOR_NM
      ,(SELECT GET_COMMON_CODE_NM('00565', STOR_TP) FROM STORE WHERE STOR_CD = A.STOR_CD AND BRAND_CD = '100') AS STOR_TP
      ,(SELECT H.USER_NM FROM STORE S, HQ_USER H WHERE S.STOR_CD = A.STOR_CD AND S.BRAND_CD = '100' AND S.SV_USER_ID = H.USER_ID) AS STOR_SC
      ,(SELECT GET_COMMON_CODE_NM('00605', TEAM_CD) FROM STORE WHERE STOR_CD = A.STOR_CD AND BRAND_CD = '100') AS TEAM_NM
      ,DECRYPT(A.CARD_ID) AS CARD_ID
      ,(SELECT DECRYPT(CUST_NM) FROM C_CUST WHERE CUST_ID = A.CUST_ID) AS CUST_NM
      ,TO_CHAR(A.INST_DT, 'YYYY-MM-DD HH24:MI:SS') AS INST_DT
      ,REGEXP_REPLACE(GET_PROMOTION_NM(B.PRMT_ID,'016'), '서브_')  AS COUPON_NM 
      ,A.ITEM_CD
      ,(SELECT ITEM_NM FROM ITEM WHERE ITEM_CD = A.ITEM_CD) AS ITEM_NM
      ,A.SALE_QTY
      ,A.SALE_PRC
      ,A.SALE_AMT
      ,CASE WHEN DC_RATE > 0 THEN A.DC_AMT
            ELSE A.ENR_AMT
       END AS TOTAL_DC_AMT
      ,A.GRD_AMT
      ,A.DC_AMT_H
      ,(
            SELECT COUPON_CD 
            FROM   PROMOTION_COUPON 
            WHERE  POS_SALE_DT = A.SALE_DT 
            AND    POS_SEQ = A.SEQ
            AND    POS_NO = A.POS_NO
            AND    BILL_NO = A.BILL_NO
            AND    STOR_CD = A.STOR_CD
       ) AS COUPON_CD
    FROM SALE_DC A, PROMOTION B
    WHERE A.DC_DIV = B.PRMT_ID
      AND B.PRMT_ID IN (SELECT CODE_CD FROM C_LIST)
      AND (N_PRMT_ID IS NULL OR B.PRMT_ID = N_PRMT_ID)
      AND (N_START_DT IS NULL OR A.SALE_DT >= REPLACE(N_START_DT, '-', ''))
      AND (N_END_DT IS NULL OR A.SALE_DT <= REPLACE(N_END_DT, '-', ''))
      AND (N_STOR_CD IS NULL OR A.STOR_CD = N_STOR_CD)
    ORDER BY RNUM DESC
    ;
    */
           SELECT 
               ROWNUM AS NO
             , STOR_CD
             , STOR_NM
             , GET_COMMON_CODE_NM('00565', STOR_TP)        AS STOR_TP
             , SV_USER_ID
             , TEAM_CD
             , DECRYPT(CUST_NM) AS CUST_NM
             , ITEM_NM
             , DECRYPT(CARD_ID) AS CARD_ID
             , CUST_ID
             , TO_CHAR(INST_DT, 'YYYY-MM-DD HH24:MI:SS')  AS INST_DT
             , PUBLISH_ID
             , PRMT_NM          AS COUPON_NM
             , COUPON_CD
             , ITEM_CD
             , SALE_QTY
             , SALE_PRC
             , SALE_AMT
             , DC_AMT
             , TOTAL_DC_AMT
             , GRD_AMT
             , DC_AMT_H
        FROM 
        (
           SELECT 
                   D.STOR_CD
                 , ST.STOR_NM
                 , ST.STOR_TP
                 , ST.SV_USER_ID
                 , ST.TEAM_CD
                 , CU.CUST_NM
                 , IT.ITEM_NM
                 , D.CARD_ID
                 , D.CUST_ID
                 , D.INST_DT
                 , C.PUBLISH_ID
                 , P.PRMT_NM
                 , D.ORG_AUTH_NO AS COUPON_CD
                 , D.ITEM_CD
                 , D.SALE_QTY
                 , D.SALE_PRC
                 , D.SALE_AMT
                 , D.DC_AMT
                 ,CASE WHEN D.DC_RATE > 0 THEN D.DC_AMT
                       ELSE D.ENR_AMT
                  END AS TOTAL_DC_AMT
                 , D.GRD_AMT
                 , D.DC_AMT_H
            FROM  SALE_DC D, PROMOTION_COUPON C,  PROMOTION_COUPON_PUBLISH U , PROMOTION P  , STORE ST, ITEM IT, C_CUST CU 
            WHERE  1 = 1
            AND    D.STOR_CD      = C.STOR_CD
            AND    D.POS_NO       = C.POS_NO 
            AND    D.BILL_NO      = C.BILL_NO
            AND    D.ORG_AUTH_NO  = C.COUPON_CD
            AND    D.DC_DIV       = P.PRMT_ID
            AND    C.COUPON_STATE = 'P0301'
            AND    D.COMP_CD      = P.COMP_CD
            AND    D.COMP_CD      = '016'
            AND    D.BRAND_CD     = '100'
            AND    U.PUBLISH_ID   = C.PUBLISH_ID 
            AND    U.PRMT_ID      = P.PRMT_ID 
            AND    P.PRMT_TYPE NOT IN ('C6015', 'C6018')
            AND    (N_START_DT  IS NULL OR D.SALE_DT >= REPLACE(N_START_DT, '-', ''))
            AND    (N_END_DT    IS NULL OR D.SALE_DT <= REPLACE(N_END_DT  , '-', ''))
            AND    (N_STOR_CD   IS NULL OR D.STOR_CD = N_STOR_CD)
            AND    (N_PRMT_ID   IS NULL OR P.PRMT_ID = N_PRMT_ID)
            AND    (N_COUPON_CD IS NULL OR C.COUPON_CD = N_COUPON_CD)
            AND    D.STOR_CD = ST.STOR_CD(+)
            AND    D.ITEM_CD = IT.ITEM_CD(+)
            AND    D.CUST_ID = CU.CUST_ID(+)
            ORDER  BY ST.STOR_TP, ST.SV_USER_ID, D.STOR_CD ,D.INST_DT, D.CUST_ID,   C.COUPON_CD
        ) Z
        ORDER BY ROWNUM DESC
            ;
    
END PROMOTION_ACT_COUPON;

/
