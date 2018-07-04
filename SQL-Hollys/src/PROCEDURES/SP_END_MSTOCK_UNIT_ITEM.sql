--------------------------------------------------------
--  DDL for Procedure SP_END_MSTOCK_UNIT_ITEM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_END_MSTOCK_UNIT_ITEM" 
( psv_comp_cd     IN      VARCHAR2, -- 회사코드
  psv_end_ym      IN      VARCHAR2, -- 마감년월
  psv_brand_cd    IN      VARCHAR2, -- 영업조직[값이 없으면 전 영업조직]
  psv_stor_cd     IN      VARCHAR2, -- 점포코드[값이 없으면 전 점포]
  psv_item_cd     IN      VARCHAR2, -- 아이템코드
  psv_flag        IN      VARCHAR2
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_END_MSTOCK
--  Description      : 기초 재고수량, 기말 재고수량 생성
--  Ref. Table       : MSTOCK[IUS]
--------------------------------------------------------------------------------
--  Create Date      : 2010-05-24
--  Modify Date      : 2014-12-29 모스버거 TSMS PJT
--------------------------------------------------------------------------------
  ls_next_ym     VARCHAR2(6);
BEGIN

  ls_next_ym := TO_CHAR( ADD_MONTHS(TO_DATE(psv_end_ym, 'YYYYMM'), 1), 'YYYYMM') ;

  IF (psv_flag = '1') THEN
     UPDATE MSTOCK
        SET  BEGIN_QTY    = 0
           , ORD_QTY      = 0
           , ADD_SOUT_QTY = 0
           , ADD_MOUT_QTY = 0
           , INS_MOUT_QTY = 0
           , INS_SOUT_QTY = 0
           , MV_IN_QTY    = 0
           , MV_OUT_QTY   = 0
           , RTN_QTY      = 0
           , DISUSE_QTY   = 0
           , ADJ_QTY      = 0
           , SALE_QTY     = 0
           , PROD_IN_QTY  = 0
           , PROD_OUT_QTY = 0
           , NOCHARGE_QTY = 0
           , ETC_IN_QTY   = 0
           , ETC_OUT_QTY  = 0
           , END_QTY      = 0
           , SURV_QTY     = 0
      WHERE PRC_YM        = ls_next_ym
        AND COMP_CD       = psv_comp_cd
        AND BRAND_CD      LIKE psv_brand_cd || '%'
        AND STOR_CD       LIKE psv_stor_cd  || '%'
        AND ITEM_CD       = psv_item_cd;
  END IF;

  FOR R IN (SELECT *
              FROM MSTOCK
             WHERE COMP_CD  = psv_comp_cd
               AND PRC_YM   = psv_end_ym
               AND BRAND_CD LIKE psv_brand_cd || '%'
               AND STOR_CD  LIKE psv_stor_cd  || '%'
               AND ITEM_CD       = psv_item_cd
           )
  LOOP
    UPDATE MSTOCK
       SET  BEGIN_QTY = R.END_QTY
          , END_QTY   = R.END_QTY
                      + ORD_QTY
                      + ADD_SOUT_QTY
                      - ADD_MOUT_QTY
                      - INS_MOUT_QTY
                      + INS_SOUT_QTY
                      + MV_IN_QTY
                      - MV_OUT_QTY
                      - RTN_QTY
                      - DISUSE_QTY
                      + ADJ_QTY
                      - SALE_QTY
                      + PROD_IN_QTY
                      - PROD_OUT_QTY
                      - NOCHARGE_QTY
                      + ETC_IN_QTY
                      - ETC_OUT_QTY
     WHERE PRC_YM     = ls_next_ym
       AND COMP_CD    = psv_comp_cd
       AND BRAND_CD   = R.BRAND_CD
       AND STOR_CD    = R.STOR_CD
       AND ITEM_CD    = R.ITEM_CD ;

    IF ( SQL%NOTFOUND ) THEN
       INSERT INTO MSTOCK
         (  COMP_CD
          , PRC_YM
          , BRAND_CD
          , STOR_CD
          , ITEM_CD
          , BEGIN_QTY
          , ORD_QTY
          , ADD_SOUT_QTY
          , ADD_MOUT_QTY
          , INS_MOUT_QTY
          , INS_SOUT_QTY
          , MV_IN_QTY
          , MV_OUT_QTY
          , RTN_QTY
          , DISUSE_QTY
          , ADJ_QTY
          , SALE_QTY
          , PROD_IN_QTY
          , PROD_OUT_QTY
          , NOCHARGE_QTY
          , ETC_IN_QTY
          , ETC_OUT_QTY
          , END_QTY
          , SURV_QTY
         )
       VALUES 
         (  R.COMP_CD
          , ls_next_ym
          , R.BRAND_CD
          , R.STOR_CD
          , R.ITEM_CD
          , R.END_QTY
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , 0
          , R.END_QTY
          , 0
         );
    END IF;
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
END SP_END_MSTOCK_UNIT_ITEM;

/
