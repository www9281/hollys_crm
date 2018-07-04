--------------------------------------------------------
--  DDL for Procedure SP_APPLY_ITEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_APPLY_ITEM" IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_APPLY_ITEM
--  Description      : 단가 이력을 상품 마스터에 적용
--  Ref. Table       : SURV_STOCK
--------------------------------------------------------------------------------
--  Create Date      : 2010-03-22
--  Modify Date      : 2010-03-22
--------------------------------------------------------------------------------
  
  lsStorTp          STORE.STOR_TP%TYPE;
  lnConfirmCnt      NUMBER := 0 ; -- 재고실사 확정 건수
  lsLine            VARCHAR2(3) := '000';

  CURSOR C_ITEM IS
  SELECT *
    FROM ITEM_CHAIN_HIS
   WHERE (START_DT = TO_CHAR(SYSDATE, 'YYYYMMDD') AND USE_YN = 'Y')
     OR  ( 
           (TO_CHAR(UPD_DT, 'YYYYMMDDHH24') >= TO_CHAR(SYSDATE-1, 'YYYYMMDDHH24') AND TO_CHAR(UPD_DT, 'YYYYMMDDHH24') < TO_CHAR(SYSDATE, 'YYYYMMDDHH24'))
           AND
           (COMP_CD, BRAND_CD, STOR_TP, ITEM_CD, START_DT) IN(SELECT COMP_CD
                                                                   , BRAND_CD
                                                                   , STOR_TP
                                                                   , ITEM_CD
                                                                   , MAX(START_DT)
                                                                FROM ITEM_CHAIN_HIS
                                                               WHERE START_DT <= TO_CHAR(SYSDATE, 'YYYYMMDD')
                                                               GROUP BY COMP_CD
                                                                      , BRAND_CD
                                                                      , STOR_TP
                                                                      , ITEM_CD
                                                             )
           AND USE_YN = 'Y'
         );

  -- 점포별 판매가
  CURSOR C_ITEM_STORE IS
  SELECT COMP_CD
       , BRAND_CD
       , ITEM_CD
    FROM ITEM_STORE
   WHERE SALE_START_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')
     AND USE_YN        = 'Y'
   GROUP BY COMP_CD, BRAND_CD, ITEM_CD;

BEGIN

  lsLine := '040';
  FOR R IN C_ITEM LOOP
      UPDATE ITEM_CHAIN
         SET SALE_PRC    = R.SALE_PRC
           , COST        = R.COST
           , INST_DT     = R.INST_DT
           , INST_USER   = R.INST_USER
           , UPD_DT      = SYSDATE
           , UPD_USER    = R.UPD_USER
       WHERE COMP_CD     = R.COMP_CD
         AND BRAND_CD    = R.BRAND_CD
         AND STOR_TP     = R.STOR_TP
         AND ITEM_CD     = R.ITEM_CD;

  END LOOP;
  lsLine := '100';

  FOR RS IN C_ITEM_STORE LOOP
      UPDATE ITEM_CHAIN
         SET UPD_DT   = SYSDATE
       WHERE COMP_CD  = RS.COMP_CD
         AND BRAND_CD = RS.BRAND_CD
         AND ITEM_CD  = RS.ITEM_CD;
  END LOOP;

  COMMIT;

  <<ErrRtn>>
    NULL;

EXCEPTION
  WHEN OTHERS THEN
       dbms_output.put_line(SQLERRM);
       ROLLBACK;
END SP_APPLY_ITEM ;

/
