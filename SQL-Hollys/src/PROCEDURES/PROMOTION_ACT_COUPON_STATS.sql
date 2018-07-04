--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_COUPON_STATS
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_COUPON_STATS" (
    N_START_DT  IN  VARCHAR2,
    N_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    N_PRMT_TYPE IN  VARCHAR2,
    N_PRMT_ID   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN  

    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-25
    -- Description	:	프로모션 쿠폰할인 집계
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    WITH C_LIST AS
    (SELECT DISTINCT A.PRMT_ID AS CODE_CD
                ,REGEXP_REPLACE(GET_PROMOTION_NM(A.PRMT_ID,'016'), '서브_')  AS CODE_NM
                ,B.PUBLISH_TYPE
         FROM   PROMOTION A
         JOIN   PROMOTION_COUPON_PUBLISH B
         ON     A.PRMT_ID = B.PRMT_ID
         WHERE  A.PRMT_COUPON_YN = 'Y' 
         AND    A.PRMT_TYPE <> 'C6015' 
         AND    A.PRMT_TYPE <> 'C6018'
         AND    (TRIM(N_PRMT_TYPE) IS NULL OR B.PUBLISH_TYPE = N_PRMT_TYPE)
    )
    SELECT 
        ROW_NUMBER() OVER (ORDER BY A.INST_DT ASC) AS RNUM, A.* 
    FROM 
    (
      SELECT
             A.STOR_CD
           , (SELECT STOR_NM FROM STORE WHERE STOR_CD = A.STOR_CD AND ROWNUM = 1)      AS STOR_NM
           , GET_COMMON_CODE_NM('00565', ST.STOR_TP)                                   AS STOR_TP
           , (SELECT H.USER_NM FROM  HQ_USER H WHERE ST.SV_USER_ID = H.USER_ID)        AS STOR_SC
           , (SELECT GET_COMMON_CODE_NM('00605', ST.TEAM_CD) FROM STORE WHERE STOR_CD = A.STOR_CD AND BRAND_CD = '100') AS TEAM_NM
           , REGEXP_REPLACE(GET_PROMOTION_NM(B.PRMT_ID,'016'), '서브_')                                              AS COUPON_NM 
           , DECODE(C.PUBLISH_TYPE, 'C6501', '멤버쉽쿠폰', 'C6502', '프로모션쿠폰', 'C6503', '할리스콘')             AS PRMT_TYPE
--D.20180504 LCS           , SUM(DECODE(A.SALE_DIV,1,1,-1))         AS USE_QTY
           , COUNT(DISTINCT A.BILL_NO)                 USE_QTY  --R.20180504 LCS *당장은 이렇게...영수증당 1개로 간주
           , MAX(A.INST_DT)                         AS INST_DT
           , SUM(A.SALE_AMT)                        AS SALE_AMT
           , SUM(A.DC_AMT + A.ENR_AMT)              AS DC_AMT
           , SUM(A.GRD_AMT)                         AS GRD_AMT
           , TO_CHAR(SUM(DC_AMT_H), 'FM9,999,999')  AS DC_AMT_H
      FROM   SALE_DC A, PROMOTION B, C_LIST C , STORE ST
      WHERE  A.DC_DIV   = B.PRMT_ID
        AND  B.PRMT_ID  = C.CODE_CD
        AND  A.STOR_CD  = ST.STOR_CD
        AND (N_PRMT_ID IS NULL OR B.PRMT_ID = N_PRMT_ID)
        AND (N_START_DT IS NULL OR A.SALE_DT >= REPLACE(N_START_DT, '-', ''))
        AND (N_END_DT IS NULL OR A.SALE_DT <= REPLACE(N_END_DT, '-', ''))
        AND (N_STOR_CD IS NULL OR A.STOR_CD = N_STOR_CD)
      GROUP BY ST.STOR_TP ,ST.SV_USER_ID,ST.TEAM_CD,  A.STOR_CD, B.PRMT_ID, C.PUBLISH_TYPE
      ORDER BY ST.STOR_TP ,ST.SV_USER_ID,ST.TEAM_CD,  A.STOR_CD, B.PRMT_ID, C.PUBLISH_TYPE
    ) A
    ORDER BY RNUM DESC
    ;
    
END PROMOTION_ACT_COUPON_STATS;

/
