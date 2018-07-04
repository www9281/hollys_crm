--------------------------------------------------------
--  DDL for Procedure SP_MSTOCK_JOB
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MSTOCK_JOB" 
  IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_MSTOCK_JOB
--  Description      : 일수불을 월수불로 집계, 전월 기말재고수량을 당월 기초재고수량으로 생성, 월수불에 각 금액 컬럼 계산
--  Ref. Table       : MSTOCK[IU], DSTOCK[S]
--------------------------------------------------------------------------------
--  Create Date      : 2013-11-01
--  Modify Date      : 2014-12-29 모스버거 TSMS PJT
--------------------------------------------------------------------------------
BEGIN
  FOR MYREC IN (SELECT COMP_CD
                  FROM COMPANY
                 WHERE USE_YN = 'Y'
               )
  LOOP
    SP_MSTOCK(MYREC.COMP_CD, TO_CHAR(SYSDATE, 'YYYYMM'));                 -- 당월 집계
    SP_MSTOCK(MYREC.COMP_CD, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM')); -- 전월 집계

    SP_END_MSTOCK(MYREC.COMP_CD, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), '', '', '0'); -- 전월 기말재고수량을 당월 기초재고수량으로 생성

    SP_MSTOCK_CALC_AMOUNT(MYREC.COMP_CD, TO_CHAR(SYSDATE - 1, 'YYYYMM')); -- 월수불에 각 금액 컬럼 계산

    FOR R IN (SELECT BRAND_CD, PARA_VAL
                FROM PARA_BRAND
               WHERE COMP_CD = MYREC.COMP_CD
                 AND PARA_CD = '1007' -- 매입 부가세설정[1:부가세포함, 2:부가세미포함]
             )
    LOOP
      IF R.PARA_VAL = 'P' THEN -- 총평균법
         SP_MSTOCK_HQ(MYREC.COMP_CD, R.BRAND_CD, TO_CHAR(SYSDATE, 'YYYYMM'));                 -- 당월 집계
         SP_MSTOCK_HQ(MYREC.COMP_CD, R.BRAND_CD, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM')); -- 전월 집계

         SP_END_MSTOCK_HQ(MYREC.COMP_CD, TO_CHAR(ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), R.BRAND_CD, '0'); -- 전월 기말재고수량을 당월 기초재고수량으로 생성

         SP_MSTOCK_HQ_CALC_AMOUNT(MYREC.COMP_CD, R.BRAND_CD, TO_CHAR(SYSDATE - 1, 'YYYYMM')); -- 전월 월수불에 각 금액 컬럼 계산
      END IF;
    END LOOP;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
       NULL;
END ;

/
