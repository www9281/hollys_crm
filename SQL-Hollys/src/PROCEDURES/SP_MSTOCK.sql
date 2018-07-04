--------------------------------------------------------
--  DDL for Procedure SP_MSTOCK
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MSTOCK" 
(
  psv_comp_cd   IN  STRING, -- 회사코드
  psv_ym        IN  STRING  -- 작업년월
) IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_MSTOCK
--  Description      : 월수불 테이블에 기초재고를 이월함(SP_MSTOCK_JOB에서 호출)
--  Ref. Table       : MSTOCK[IU], DSTOCK[S]
--------------------------------------------------------------------------------
--  Create Date      : 2013-11-01
--  Modify Date      : 2014-12-29 모스버거 TSMS PJT
--------------------------------------------------------------------------------
BEGIN
  MERGE INTO MSTOCK A
  USING (
            SELECT  COMP_CD
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  ITEM_CD
                 ,  SUM(ORD_QTY)      ORD_QTY
                 ,  SUM(ADD_SOUT_QTY) ADD_SOUT_QTY
                 ,  SUM(ADD_MOUT_QTY) ADD_MOUT_QTY
                 ,  SUM(INS_MOUT_QTY) INS_MOUT_QTY
                 ,  SUM(INS_SOUT_QTY) INS_SOUT_QTY
                 ,  SUM(MV_IN_QTY)    MV_IN_QTY
                 ,  SUM(MV_OUT_QTY)   MV_OUT_QTY
                 ,  SUM(RTN_QTY)      RTN_QTY
                 ,  SUM(DISUSE_QTY)   DISUSE_QTY
                 ,  SUM(ADJ_QTY)      ADJ_QTY
                 ,  SUM(SALE_QTY)     SALE_QTY
                 ,  SUM(PROD_IN_QTY)  PROD_IN_QTY
                 ,  SUM(PROD_OUT_QTY) PROD_OUT_QTY
                 ,  SUM(NOCHARGE_QTY) NOCHARGE_QTY
                 ,  SUM(ETC_IN_QTY)   ETC_IN_QTY
                 ,  SUM(ETC_OUT_QTY)  ETC_OUT_QTY
                 ,  SUM(SURV_QTY)     SURV_QTY
                 ,  SUM(DSA_QTY)      DSA_QTY
              FROM  (
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  ITEM_CD
                             ,  SUM(ORD_QTY)      ORD_QTY
                             ,  SUM(ADD_SOUT_QTY) ADD_SOUT_QTY
                             ,  SUM(ADD_MOUT_QTY) ADD_MOUT_QTY
                             ,  SUM(INS_MOUT_QTY) INS_MOUT_QTY
                             ,  SUM(INS_SOUT_QTY) INS_SOUT_QTY
                             ,  SUM(MV_IN_QTY)    MV_IN_QTY
                             ,  SUM(MV_OUT_QTY)   MV_OUT_QTY
                             ,  SUM(RTN_QTY)      RTN_QTY
                             ,  SUM(DISUSE_QTY)   DISUSE_QTY
                             ,  SUM(ADJ_QTY)      ADJ_QTY
                             ,  SUM(SALE_QTY)     SALE_QTY
                             ,  SUM(PROD_IN_QTY)  PROD_IN_QTY
                             ,  SUM(PROD_OUT_QTY) PROD_OUT_QTY
                             ,  0                 NOCHARGE_QTY
                             ,  SUM(ETC_IN_QTY)   ETC_IN_QTY
                             ,  SUM(ETC_OUT_QTY)  ETC_OUT_QTY
                             ,  SUM(CASE WHEN PRC_DT = (SELECT MAX(SURV_DT) FROM SURV_STOCK_DT WHERE COMP_CD = D.COMP_CD AND BRAND_CD = D.BRAND_CD AND STOR_CD = D.STOR_CD AND ITEM_CD = D.ITEM_CD AND SURV_DT BETWEEN psv_ym ||'01' AND psv_ym || '31') THEN SURV_QTY ELSE 0 END) SURV_QTY
                             ,  0                 DSA_QTY
                          FROM  DSTOCK  D
                         WHERE  COMP_CD = psv_comp_cd
                           AND  PRC_DT  BETWEEN psv_ym ||'01' AND psv_ym || '31'
                         GROUP  BY COMP_CD, BRAND_CD, STOR_CD, ITEM_CD
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  ITEM_CD
                             ,  0                 ORD_QTY
                             ,  0                 ADD_SOUT_QTY
                             ,  0                 ADD_MOUT_QTY
                             ,  0                 INS_MOUT_QTY
                             ,  0                 INS_SOUT_QTY
                             ,  0                 MV_IN_QTY
                             ,  0                 MV_OUT_QTY
                             ,  0                 RTN_QTY
                             ,  0                 DISUSE_QTY
                             ,  0                 ADJ_QTY
                             ,  0                 SALE_QTY
                             ,  0                 PROD_IN_QTY
                             ,  0                 PROD_OUT_QTY
                             ,  SUM(SALE_QTY)     NOCHARGE_QTY
                             ,  0                 ETC_IN_QTY
                             ,  0                 ETC_OUT_QTY
                             ,  0                 SURV_QTY
                             ,  0                 DSA_QTY
                          FROM  SALE_JDF  D
                         WHERE  COMP_CD = psv_comp_cd
                           AND  SALE_DT BETWEEN psv_ym ||'01' AND psv_ym || '31'
                         GROUP  BY COMP_CD, BRAND_CD, STOR_CD, ITEM_CD
                        UNION ALL
                        SELECT  COMP_CD
                             ,  BRAND_CD
                             ,  STOR_CD
                             ,  C_ITEM_CD
                             ,  0                 ORD_QTY
                             ,  0                 ADD_SOUT_QTY
                             ,  0                 ADD_MOUT_QTY
                             ,  0                 INS_MOUT_QTY
                             ,  0                 INS_SOUT_QTY
                             ,  0                 MV_IN_QTY
                             ,  0                 MV_OUT_QTY
                             ,  0                 RTN_QTY
                             ,  0                 DISUSE_QTY
                             ,  0                 ADJ_QTY
                             ,  0                 SALE_QTY
                             ,  0                 PROD_IN_QTY
                             ,  0                 PROD_OUT_QTY
                             ,  0                 NOCHARGE_QTY
                             ,  0                 ETC_IN_QTY
                             ,  0                 ETC_OUT_QTY
                             ,  0                 SURV_QTY
                             ,  SUM(DO_QTY)       DSA_QTY
                          FROM  SALE_CDR  D
                         WHERE  COMP_CD = psv_comp_cd
                           AND  SALE_DT BETWEEN psv_ym ||'01' AND psv_ym || '31'
                         GROUP  BY COMP_CD, BRAND_CD, STOR_CD, C_ITEM_CD
                    )
             GROUP  BY COMP_CD, BRAND_CD, STOR_CD, ITEM_CD
        ) B
     ON ( 
          A.COMP_CD  = B.COMP_CD   AND
          A.BRAND_CD = B.BRAND_CD  AND
          A.STOR_CD  = B.STOR_CD   AND
          A.PRC_YM   = psv_ym      AND
          A.ITEM_CD  = B.ITEM_CD
        )
   WHEN MATCHED THEN
        UPDATE 
           SET A.ORD_QTY      = B.ORD_QTY
             , A.ADD_SOUT_QTY = B.ADD_SOUT_QTY
             , A.ADD_MOUT_QTY = B.ADD_MOUT_QTY
             , A.INS_MOUT_QTY = B.INS_MOUT_QTY
             , A.INS_SOUT_QTY = B.INS_SOUT_QTY
             , A.MV_IN_QTY    = B.MV_IN_QTY
             , A.MV_OUT_QTY   = B.MV_OUT_QTY
             , A.RTN_QTY      = B.RTN_QTY
             , A.DISUSE_QTY   = B.DISUSE_QTY
             , A.ADJ_QTY      = B.ADJ_QTY
             , A.SALE_QTY     = B.SALE_QTY
             , A.PROD_IN_QTY  = B.PROD_IN_QTY
             , A.PROD_OUT_QTY = B.PROD_OUT_QTY
             , A.NOCHARGE_QTY = B.NOCHARGE_QTY
             , A.ETC_IN_QTY   = B.ETC_IN_QTY
             , A.SURV_QTY     = NVL(B.SURV_QTY, 0)
             , A.END_QTY      = A.BEGIN_QTY
                              + B.ORD_QTY     + B.ADD_SOUT_QTY - B.ADD_MOUT_QTY - B.INS_MOUT_QTY + B.INS_SOUT_QTY
                              + B.MV_IN_QTY   - B.MV_OUT_QTY   - B.RTN_QTY      - B.DISUSE_QTY   + B.ADJ_QTY       - B.SALE_QTY
                              + B.PROD_IN_QTY - B.PROD_OUT_QTY - B.NOCHARGE_QTY + B.ETC_IN_QTY   - B.ETC_OUT_QTY   - B.DSA_QTY
   WHEN NOT MATCHED THEN
        INSERT 
          (
             COMP_CD
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
           , BEGIN_STOCK_DT
           , SURV_QTY
          )
        VALUES
          (  B.COMP_CD
           , psv_ym
           , B.BRAND_CD
           , B.STOR_CD
           , B.ITEM_CD
           , 0
           , B.ORD_QTY
           , B.ADD_SOUT_QTY
           , B.ADD_MOUT_QTY
           , B.INS_MOUT_QTY
           , B.INS_SOUT_QTY
           , B.MV_IN_QTY
           , B.MV_OUT_QTY
           , B.RTN_QTY
           , B.DISUSE_QTY
           , B.ADJ_QTY
           , B.SALE_QTY
           , B.PROD_IN_QTY
           , B.PROD_OUT_QTY
           , B.NOCHARGE_QTY
           , B.ETC_IN_QTY
           , B.ETC_OUT_QTY
           , B.ORD_QTY     + B.ADD_SOUT_QTY - B.ADD_MOUT_QTY - B.INS_MOUT_QTY + B.INS_SOUT_QTY
           + B.MV_IN_QTY   - B.MV_OUT_QTY   - B.RTN_QTY      - B.DISUSE_QTY   + B.ADJ_QTY      - B.SALE_QTY
           + B.PROD_IN_QTY - B.PROD_OUT_QTY - B.NOCHARGE_QTY + B.ETC_IN_QTY   - B.ETC_OUT_QTY  - B.DSA_QTY
           , NULL
           , NVL(B.SURV_QTY, 0)
          );

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
END;

/
