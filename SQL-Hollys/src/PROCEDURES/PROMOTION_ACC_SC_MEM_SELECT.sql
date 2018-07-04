--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACC_SC_MEM_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACC_SC_MEM_SELECT" (
    N_START_DT  IN  VARCHAR2,
    N_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN  

    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-03-28
    -- Description	:	프로모션 정산조회 SC별 멤버쉽실적 상세현황 조회
    -- ==========================================================================================
    OPEN O_CURSOR FOR
    SELECT 
      A.*
      , ROW_NUMBER() OVER (ORDER BY A.STOR_SC ASC) AS RNUM
      , (A.USE_PT*-1) AS SETTLE_AMT 
    FROM (
      SELECT
        A.SALE_DT
        ,A.STOR_CD
        ,A.BILL_NO
        ,S.STOR_NM
        ,(SELECT H.USER_NM FROM HQ_USER H WHERE S.SV_USER_ID = H.USER_ID) AS STOR_SC
        ,(SELECT CODE_NM FROM COMMON C WHERE C.CODE_TP = '00565' AND C.CODE_CD = S.STOR_TP) AS STOR_TP
        ,(SELECT CODE_NM FROM COMMON C WHERE C.CODE_TP = '00605' AND C.CODE_CD = S.TEAM_CD) AS TEAM_NM
        ,A.SALE_AMT AS SALE_AMT
        ,A.DC_AMT + A.ENR_AMT AS DC_AMT
        ,A.GRD_I_AMT + A.GRD_O_AMT AS GRD_AMT
        ,(SELECT SUM(SAV_MLG) FROM C_CUST_CROWN WHERE USE_DT = A.SALE_DT AND STOR_CD = A.STOR_CD AND POS_NO = A.POS_NO AND BILL_NO = A.BILL_NO) AS SAV_MLG
        ,(SELECT SUM(USE_PT) FROM C_CARD_SAV_HIS WHERE USE_DT = A.SALE_DT AND STOR_CD = A.STOR_CD AND POS_NO = A.POS_NO AND BILL_NO = A.BILL_NO) AS USE_PT
      FROM SALE_HD A, STORE S
      WHERE A.COMP_CD = '016'
      AND A.BRAND_CD = '100'
      AND A.SALE_DT >= REPLACE(N_START_DT, '-', '')
      AND A.SALE_DT <= REPLACE(N_END_DT, '-', '')
      AND A.STOR_CD = S.STOR_CD
      AND S.BRAND_CD = '100'
      AND NVL(A.CUST_ID, 'ISNULL') != 'ISNULL'
      AND (N_STOR_CD IS NULL OR A.STOR_CD = N_STOR_CD)
    )A
    ORDER BY RNUM DESC
    --ORDER BY STOR_SC DESC
    ;
    
END PROMOTION_ACC_SC_MEM_SELECT;

/
