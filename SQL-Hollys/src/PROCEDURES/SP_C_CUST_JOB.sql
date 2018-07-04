--------------------------------------------------------
--  DDL for Procedure SP_C_CUST_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_C_CUST_JOB" 
( 
  v_comp_cd        IN  VARCHAR2 -- 회사코드
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_C_CUST_JOB
--  Description      : 회원수 집계테이블 이월
--  Ref. Table       : C_CUST_MAC  [CRM]회원 연령대별 월고객수
--                     C_CUST_MSC  [CRM]회원 등급별 월고객수
--                     C_CUST_MLVL [CRM]회원 월 등급
--------------------------------------------------------------------------------
--  Create Date      : 2015-05-22
--  Modify Date      : 2015-05-22 엠즈씨드 CRM PJT
--------------------------------------------------------------------------------
BEGIN
  --IF TO_CHAR(SYSDATE, 'DD') = '01' THEN -- 매월 1일 새벽 00시에 이월
     -- [CRM]회원 연령대별 월고객수
     MERGE INTO C_CUST_MAC A
     USING (SELECT COMP_CD, TO_CHAR(SYSDATE, 'YYYYMM') SALE_YM, BRAND_CD,
                   CUST_LVL, CUST_AGE, CUST_CNT
              FROM C_CUST_MAC
             WHERE COMP_CD      = v_comp_cd
               AND SALE_YM      = TO_CHAR(SYSDATE - 1, 'YYYYMM')
           ) B
     ON (
             A.COMP_CD      = B.COMP_CD
         AND A.SALE_YM      = B.SALE_YM
         AND A.BRAND_CD     = B.BRAND_CD
         AND A.CUST_LVL     = B.CUST_LVL
         AND A.CUST_AGE     = B.CUST_AGE
        )
     WHEN MATCHED THEN
          UPDATE
             SET A.CUST_CNT     = A.CUST_CNT + B.CUST_CNT -- 전체 회원수
     WHEN NOT MATCHED THEN
          INSERT
            (
               COMP_CD
             , SALE_YM
             , BRAND_CD
             , CUST_LVL
             , CUST_AGE
             , CUST_CNT
            )
          VALUES
            (
               B.COMP_CD
             , B.SALE_YM
             , B.BRAND_CD
             , B.CUST_LVL
             , B.CUST_AGE
             , B.CUST_CNT
            );
            
     -- [CRM]회원 등급별 월고객수
     MERGE INTO C_CUST_MSC A
     USING (SELECT COMP_CD, TO_CHAR(SYSDATE, 'YYYYMM') SALE_YM, BRAND_CD,
                   CUST_LVL, CUST_CNT
              FROM C_CUST_MSC
             WHERE COMP_CD      = v_comp_cd
               AND SALE_YM      = TO_CHAR(SYSDATE - 1, 'YYYYMM')
           ) B
     ON (
             A.COMP_CD      = B.COMP_CD
         AND A.SALE_YM      = B.SALE_YM
         AND A.BRAND_CD     = B.BRAND_CD
         AND A.CUST_LVL     = B.CUST_LVL
        )
     WHEN MATCHED THEN
          UPDATE
             SET A.CUST_CNT     = A.CUST_CNT + B.CUST_CNT -- 전체 회원수
     WHEN NOT MATCHED THEN
          INSERT
            (
               COMP_CD
             , SALE_YM
             , BRAND_CD
             , CUST_LVL
             , CUST_CNT
            )
          VALUES
            (
               B.COMP_CD
             , B.SALE_YM
             , B.BRAND_CD
             , B.CUST_LVL
             , B.CUST_CNT
            );
            
     -- C_CUST_MLVL 회원 점포별 월집계 삭제
     MERGE INTO C_CUST_MLVL A
     USING (SELECT COMP_CD
                 , TO_CHAR(SYSDATE, 'YYYYMM') SALE_YM
                 , BRAND_CD
                 , CUST_ID
                 , LVL_CD CUST_LVL
              FROM C_CUST
             WHERE COMP_CD   = v_comp_cd
               AND CUST_STAT IN ('2', '8')
               AND USE_YN    = 'Y'
           ) B
     ON (
             A.COMP_CD      = B.COMP_CD
         AND A.SALE_YM      = B.SALE_YM
         AND A.BRAND_CD     = B.BRAND_CD
         AND A.CUST_ID      = B.CUST_ID
        )
     WHEN MATCHED THEN
          UPDATE
             SET A.CUST_LVL = B.CUST_LVL -- 회원등급
     WHEN NOT MATCHED THEN
          INSERT
            (
               COMP_CD
             , SALE_YM
             , BRAND_CD
             , CUST_ID
             , CUST_LVL
            )
          VALUES
            (
               B.COMP_CD
             , B.SALE_YM
             , B.BRAND_CD
             , B.CUST_ID
             , B.CUST_LVL
            );
            
     COMMIT;
  --END IF;
EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
END ;

/
