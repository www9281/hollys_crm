--------------------------------------------------------
--  DDL for Procedure C_COUPON_CUST_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."C_COUPON_CUST_SELECT" (
    P_COMP_CD     IN   VARCHAR2,
    N_CUST_ID     IN   VARCHAR2,
    N_START_DT    IN   VARCHAR2,
    N_END_DT      IN   VARCHAR2,
    N_LANGUAGE_TP IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) IS 
      v_query varchar2(20000);
BEGIN
    -- ==========================================================================================
    -- Author        :   박동수
    -- Create date   :   2017-10-01
    -- Description   :   멤버쉽 회원관리 [쿠폰발급내역] 정보 조회
    -- Test          :   C_CUST_SELECT_ONE ('000', 'level_10', 'KOR')
    -- ==========================================================================================
    OPEN O_CURSOR FOR
--          SELECT
--                  B.PRMT_ID AS PRMT_ID
--                  ,REGEXP_REPLACE(GET_PROMOTION_NM(B.PRMT_ID,'016'), '서브_')  AS PRMT_NM 
--                  ,A.COUPON_CD  AS COUPON_CD
--                  ,A.START_DT  AS START_DT
--                  ,A.END_DT  AS END_DT
--                  ,A.COUPON_STATE AS COUPON_STATE
--                  ,B.PUBLISH_TYPE AS COUPON_DIV
--                  ,A.COUPON_IMG,
--                  (
--                      CASE WHEN (SELECT COUPON_CD FROM PROMOTION_COUPON_HIS WHERE COUPON_CD = A.COUPON_CD AND TO_CUST_ID = P_CUST_ID) IS NOT NULL THEN 1
--                           ELSE 0
--                      END
--                  ) AS IS_RECEIVE
--                  ,A.UPD_DT AS UPD_DT
--          FROM    PROMOTION_COUPON A
--          JOIN    PROMOTION_COUPON_PUBLISH B
--          ON      A.PUBLISH_ID = B.PUBLISH_ID 
--          WHERE   A.CUST_ID = P_CUST_ID
--          AND     (A.USE_DT IS NULL AND A.DESTROY_DT IS NULL AND A.END_DT < TO_CHAR(SYSDATE, 'YYYYMMDD'))
--        ;
--        
    SELECT
      GET_COMMON_CODE_NM('C5000', B.PRMT_CLASS,'KOR') AS COUPON_DIV 
      ,A.COUPON_CD
      ,A.ISSUE_DT  
      ,A.START_DT 
      ,A.CLOSE_DT
      ,A.USE_YN
      ,A.COUPON_USE_TIME
      ,A.USE_STOR_NM
      ,A.ITEM_NM
      ,REGEXP_REPLACE(GET_PROMOTION_NM(A.PRMT_ID,'016'), '서브_')  AS COUPON_NM 
      ,A.DESTROY_DT
--      ,CASE WHEN PRMT_USE_DIV = 'C6921' THEN (SELECT PREFACE FROM PROMOTION_PRINT WHERE PRMT_ID = A.PRMT_ID)
--            WHEN PRMT_USE_DIV = 'C6922' THEN (SELECT PUSH_TITLE FROM PROMOTION_PUSH WHERE PRMT_ID = A.PRMT_ID)
--            WHEN PRMT_USE_DIV = 'C6923' THEN (SELECT SMS_TITLE FROM PROMOTION_SMS WHERE PRMT_ID = A.PRMT_ID)
--            WHEN PRMT_USE_DIV = 'C6924' THEN (SELECT PUSH_TITLE FROM PROMOTION_PUSH WHERE PRMT_ID = A.PRMT_ID)
--            ELSE ''
--       END AS COUPON_NM
    FROM (
          SELECT
            A.COUPON_CD
            ,TO_CHAR(A.INST_DT, 'YYYY-MM-DD') AS ISSUE_DT
            ,A.START_DT AS START_DT
            ,A.END_DT AS CLOSE_DT
            ,CASE WHEN A.USE_DT IS NULL THEN 'N'
                  ELSE 'Y'
             END AS USE_YN
            ,A.USE_DT AS COUPON_USE_TIME  
            ,CASE WHEN A.USE_DT IS NOT NULL THEN (SELECT STOR_NM FROM STORE WHERE STOR_CD = B.STOR_CD) ELSE '' END AS USE_STOR_NM
            ,CASE WHEN A.USE_DT IS NOT NULL THEN (SELECT ITEM_NM FROM ITEM WHERE ITEM_CD = B.ITEM_CD) ELSE '' END AS ITEM_NM
            ,C.PRMT_ID
            ,A.DESTROY_DT
          FROM PROMOTION_COUPON A
              ,(SELECT T.*, ROW_NUMBER() OVER(PARTITION BY COUPON_CD ORDER BY COUPON_HIS_SEQ DESC) AS SEQ_NO 
                FROM PROMOTION_COUPON_HIS T) B
              ,PROMOTION_COUPON_PUBLISH C
          WHERE A.CUST_ID = N_CUST_ID
            AND A.COUPON_CD = B.COUPON_CD (+)
            AND B.SEQ_NO (+) = '1'
            AND A.PUBLISH_ID = C.PUBLISH_ID
            AND (N_START_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') >= REPLACE(N_START_DT, '-', ''))
            AND (N_END_DT IS NULL OR TO_CHAR(A.INST_DT, 'YYYYMMDD') <= REPLACE(N_END_DT, '-', ''))) A
        , PROMOTION B
    WHERE A.PRMT_ID = B.PRMT_ID
    ORDER BY ISSUE_DT DESC
    ;
END C_COUPON_CUST_SELECT;

/
