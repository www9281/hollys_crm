--------------------------------------------------------
--  DDL for Procedure PROMOTION_ACT_FREEQUEN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."PROMOTION_ACT_FREEQUEN" (
    P_START_DT  IN  VARCHAR2,
    P_END_DT    IN  VARCHAR2,
    N_STOR_CD   IN  VARCHAR2,
    N_PRMT_ID   IN  VARCHAR2,
    O_CURSOR    OUT SYS_REFCURSOR
) AS 
BEGIN  

    -- ==========================================================================================
    -- Author		:	박동수
    -- Create date	:	2018-02-21
    -- Description	:	프로모션 프리퀀시 정산조회
    -- ==========================================================================================
    
    OPEN O_CURSOR FOR
    SELECT
      DT.SALE_DT
      ,A.STOR_COUPON_QTY      -- 우리매장에서 증정한판촉물\r\n증정 건 수
      ,A.OT_STOR_COUPON_QTY   -- 우리매장에서 적립한 고객이 타매장에서 증정받은 판촉물 건 수(묶음)
      ,B.STOR_QTY             -- 판촉물 증정 고객이 우리 매장에서 적립한 잔 수(묶음)
      ,B.OT_STOR_QTY          -- 타매장 판촉물 증정 고객이 우리매장에서 적립한 잔 수
      ,C.QTY                  -- 적립 잔수
      ,C.OT_QTY               -- 타매장 적립 잔수
    FROM 
        (SELECT TO_CHAR(TO_DATE(REPLACE(P_START_DT, '-', ''), 'YYYYMMDD')+LEVEL-1, 'YYYYMMDD') AS SALE_DT
            FROM DUAL
          CONNECT BY LEVEL <= (TO_DATE(REPLACE(P_END_DT, '-', ''), 'YYYYMMDD')-TO_DATE(REPLACE(P_START_DT, '-', ''), 'YYYYMMDD')+1)
        ) DT,
        ( -- 판촉물 건수 
          SELECT
            C.USE_DT AS SALE_DT
            ,COUNT(*) AS STOR_QTY
            ,SUM(CASE WHEN C.STOR_CD = N_STOR_CD THEN 1 ELSE 0 END) AS STOR_COUPON_QTY       -- 우리매장에서 증정한판촉물\r\n증정 건 수
            ,SUM(CASE WHEN C.STOR_CD <> N_STOR_CD AND C.CUST_ID IN (SELECT                   
                                                                     CUST_ID
                                                                   FROM PROMOTION_FREQUENCY A
                                                                   WHERE A.PRMT_ID = A.PRMT_ID
                                                                     AND A.STOR_CD = N_STOR_CD
                                                                     AND A.FRQ_DIV = '101'
                                                                     AND A.PUBLISH_YN = 'N'
                                                                   GROUP BY CUST_ID) THEN 1 ELSE 0 END) AS OT_STOR_COUPON_QTY -- 우리매장에서 적립한 고객이 타매장에서 증정받은 판촉물 건 수(묶음)
          FROM PROMOTION A, PROMOTION_COUPON_PUBLISH B, PROMOTION_COUPON C
          WHERE A.PRMT_ID = N_PRMT_ID
            AND A.SUB_PRMT_ID = B.PRMT_ID
            AND B.PUBLISH_ID = C.PUBLISH_ID
            AND C.USE_DT IS NOT NULL
            AND C.USE_DT >= REPLACE(P_START_DT, '-', '')
            AND C.USE_DT <= REPLACE(P_END_DT, '-', '')
          GROUP BY C.USE_DT
        ) A,
        (-- 잔수 
          SELECT
            A.POS_SALE_DT AS SALE_DT
            ,SUM(CASE WHEN EXISTS (SELECT 1 
                                   FROM PROMOTION AA, PROMOTION_COUPON_PUBLISH BB, PROMOTION_COUPON CC
                                   WHERE AA.PRMT_ID = A.PRMT_ID
                                     AND AA.SUB_PRMT_ID = BB.PRMT_ID
                                     AND BB.PUBLISH_ID = CC.PUBLISH_ID
                                     AND A.STOR_CD = CC.STOR_CD
                                     AND A.CUST_ID = CC.CUST_ID
                                     AND CC.USE_DT IS NOT NULL) THEN A.QTY ELSE 0 END) AS STOR_QTY  -- 판촉물 증정 고객이 우리 매장에서 적립한 잔 수(묶음)
            ,SUM(CASE WHEN EXISTS (SELECT 1 
                                   FROM PROMOTION AA, PROMOTION_COUPON_PUBLISH BB, PROMOTION_COUPON CC
                                   WHERE AA.PRMT_ID = A.PRMT_ID
                                     AND AA.SUB_PRMT_ID = BB.PRMT_ID
                                     AND BB.PUBLISH_ID = CC.PUBLISH_ID
                                     AND A.STOR_CD <> CC.STOR_CD
                                     AND A.CUST_ID = CC.CUST_ID
                                     AND CC.USE_DT IS NOT NULL) THEN A.QTY ELSE 0 END) AS OT_STOR_QTY  -- 타매장 판촉물 증정 고객이 우리매장에서 적립한 잔 수
          FROM PROMOTION_FREQUENCY A
          WHERE A.PRMT_ID = N_PRMT_ID
            AND A.STOR_CD = N_STOR_CD
            AND A.FRQ_DIV = '101'
            AND A.POS_SALE_DT >= REPLACE(P_START_DT, '-', '')
            AND A.POS_SALE_DT <= REPLACE(P_END_DT, '-', '')
          GROUP BY A.POS_SALE_DT
        ) B,
        ( -- 적립잔수
          SELECT
            A.POS_SALE_DT AS SALE_DT
            ,SUM(CASE WHEN A.STOR_CD = N_STOR_CD THEN 1 ELSE 0 END) AS QTY       -- 적립 잔수
            ,SUM(CASE WHEN A.STOR_CD <> N_STOR_CD THEN 1 ELSE 0 END) AS OT_QTY   -- 타매장 적립 잔수
          FROM PROMOTION_FREQUENCY A
          WHERE A.PRMT_ID = N_PRMT_ID
            AND A.POS_SALE_DT >= REPLACE(P_START_DT, '-', '')
            AND A.POS_SALE_DT <= REPLACE(P_END_DT, '-', '')
            AND A.FRQ_DIV = '101'
          GROUP BY A.POS_SALE_DT
        ) C
    WHERE DT.SALE_DT = A.SALE_DT(+)
      AND DT.SALE_DT = B.SALE_DT(+)
      AND DT.SALE_DT = C.SALE_DT(+)
    ORDER BY DT.SALE_DT DESC
    ;
    
END PROMOTION_ACT_FREEQUEN;

/
