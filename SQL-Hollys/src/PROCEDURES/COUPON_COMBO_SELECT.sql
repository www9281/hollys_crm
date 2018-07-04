--------------------------------------------------------
--  DDL for Procedure COUPON_COMBO_SELECT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."COUPON_COMBO_SELECT" (
    N_REQ_TEXT    IN   VARCHAR2,
    N_VAL_C1        IN   VARCHAR2,
    O_CURSOR      OUT  SYS_REFCURSOR
) AS
BEGIN
       ----------------------- 쿠폰 목록 조회 -----------------------
       OPEN O_CURSOR FOR
       SELECT
          A.CODE_CD     AS CODE_CD
          , A.CODE_NM   AS CODE_NM
       FROM (SELECT '' AS CODE_CD, N_REQ_TEXT AS CODE_NM FROM DUAL) A
       WHERE (N_REQ_TEXT IS NULL AND 1=0
              OR
              N_REQ_TEXT IS NOT NULL) 
       UNION ALL
       SELECT
          A.CODE_CD || '' AS CODE_CD
          ,A.CODE_NM 
       FROM (
         --멤버쉽
         SELECT DISTINCT A.PRMT_ID AS CODE_CD
                ,REGEXP_REPLACE(GET_PROMOTION_NM(A.PRMT_ID,'016'), '서브_')  AS CODE_NM
         FROM   PROMOTION A
         JOIN   PROMOTION_COUPON_PUBLISH B
         ON     A.PRMT_ID = B.PRMT_ID
         WHERE  A.PRMT_COUPON_YN = 'Y' 
         AND    A.PRMT_TYPE <> 'C6015' 
         AND    A.PRMT_TYPE <> 'C6018'
         AND    (TRIM(N_VAL_C1) IS NULL OR B.PUBLISH_TYPE = N_VAL_C1)
--         SELECT A.SUB_PRMT_ID AS CODE_CD
--               ,GET_PROMOTION_NM(A.SUB_PRMT_ID,'016') AS CODE_NM
--         FROM   PROMOTION A
--         WHERE  A.PRMT_TYPE <> 'C6015' 
--         AND    A.PRMT_TYPE <> 'C6018'
--         AND    A.PRMT_TYPE <> 'C6020'
--         AND    A.PRMT_TYPE <> 'C5002'
--         AND    (A.SUB_PRMT_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM PROMOTION WHERE PRMT_ID = A.SUB_PRMT_ID AND PRMT_TYPE = 'C5002'))
--         UNION ALL
--         SELECT B.PRMT_ID AS CODE_CD
--               ,B.PRMT_NM AS CODE_NM
--         FROM   PROMOTION B
--         WHERE  PRMT_CLASS = 'C5004'
--         UNION ALL
--         SELECT B.PRMT_ID AS CODE_CD
--               ,B.PRMT_NM AS CODE_NM
--         FROM   PROMOTION B
--         WHERE  B.PRMT_CLASS = 'C5006'
--           AND  EXISTS (
--                   SELECT PUBLISH_ID
--                   FROM   PROMOTION_COUPON_PUBLISH
--                   WHERE  PRMT_ID = B.PRMT_ID)
--                   
        ) A
        ORDER BY CODE_CD NULLS FIRST
      ;
END COUPON_COMBO_SELECT;

/
