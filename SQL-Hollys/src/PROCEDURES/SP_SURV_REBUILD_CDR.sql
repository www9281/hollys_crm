--------------------------------------------------------
--  DDL for Procedure SP_SURV_REBUILD_CDR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SURV_REBUILD_CDR" 
                ( asCompCd     IN  VARCHAR2, -- 회사코드
                  asBrandCd    IN  VARCHAR2, -- 영업조직
                  asStorCd     IN  VARCHAR2, -- 점포코드
                  asSurvDt     IN  VARCHAR2, -- 실사일자
                  asSurvGrp    IN  VARCHAR2, -- 실사구분
                  asMngDiv     IN  VARCHAR2, -- 품목구분
                  asUserId     IN  VARCHAR2, -- 담당자 ID
                  PSV_LANG_CD  IN  VARCHAR2, -- 언어코드
                  anRetVal     OUT VARCHAR2,
                  asRetMsg     OUT VARCHAR2
                ) IS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_SURV_REBUILD_CDR               [STCK4223M0.jsp]
--  Description      : 재고실사 조정 배치
--  Ref. Table       : SURV_STOCK
---------------------------------------------------------------------------------------------------
--  Create Date      : 2016-05-06
--  Create Programer : SWCHOI
--  Modify Date      : 2016-05-06
--  Modify Programer :
---------------------------------------------------------------------------------------------------

lsStorTp          STORE.STOR_TP%TYPE;
lnConfirmCnt      Number := 0 ; -- 재고실사 확정 건수
lsLine            varchar2(3) := '000';

L_CNT99           NUMBER;

CURSOR C_Stock IS
    WITH ST AS ( 
                    SELECT  COMP_CD
                         ,  YMD
                         ,  BRAND_CD
                         ,  STOR_CD 
                         ,  ITEM_CD                                 AS ITEM_CD
                         ,  BOF_STOCK_QTY + STOCK_QTY - ADJ_QTY     AS END_QTY
                      FROM  TABLE(CAST ( FC_GET_STOCK_EQTY_CD_DAY (asCompCd, 'KOR', asBrandCd, asStorCd, asSurvDt) AS TBL_STOCK_EQTY_CD_DAY ) )
               )
    SELECT  I.ITEM_CD                    AS ITEM_CD
         ,  I.ORD_UNIT_QTY               AS ORD_UNIT_QTY
         ,  NVL(I.SALE_UNIT_QTY, 1)      AS SALE_UNIT_QTY
         ,  NVL(S.END_QTY     , 0)       AS INVENTORY_QTY
      FROM  ITEM_CHAIN  I
         ,  (
                SELECT  M.COMP_CD
                     ,  M.ITEM_CD
                     ,  S.END_QTY
                  FROM  SURV_STOCK_DT   M
                     ,  ST              S
                 WHERE  M.COMP_CD   = S.COMP_CD
                   AND  M.SURV_DT   = S.YMD
                   AND  M.BRAND_CD  = S.BRAND_CD
                   AND  M.STOR_CD   = S.STOR_CD
                   AND  M.ITEM_CD   = S.ITEM_CD
                   AND  M.COMP_CD   = asCompCd
                   AND  M.SURV_DT   = asSurvDt
                   AND  M.BRAND_CD  = asBrandCd
                   AND  M.STOR_CD   = asStorCd
                   AND  M.SURV_GRP  = asSurvGrp
            )   S  
     WHERE  I.COMP_CD  = S.COMP_CD
       AND  I.ITEM_CD  = S.ITEM_CD
       AND  I.COMP_CD  = asCompCd
       AND  I.BRAND_CD = asBrandCd
       AND  I.STOR_TP  = lsStorTp;

BEGIN

   BEGIN
      SELECT STOR_TP INTO lsStorTp
        FROM STORE
       WHERE COMP_CD  = asCompCd
         AND BRAND_CD = asBrandCd
         AND STOR_CD  = asStorCd
         AND USE_YN   = 'Y' ;
   EXCEPTION WHEN NO_DATA_FOUND THEN
      asRetMsg := FC_GET_WORDPACK(asCompCd, '1004000002', PSV_LANG_CD);       -- 미등록 점포입니다.
      anRetVal := '0' ;
      GOTO ErrRtn ;
   END;

   lsLine := '010';
   BEGIN
      INSERT INTO SURV_STOCK_HD
                 ( COMP_CD
                 , SURV_DT
                 , BRAND_CD
                 , STOR_CD
                 , SURV_GRP
                 , S_CONFIRM_YN
                 , H_CONFIRM_YN
                 , TRANS_YN
                 , INST_DT
                 , INST_USER
                 , UPD_DT
                 , UPD_USER
                  )
          VALUES
                (  asCompCd
                 , asSurvDt
                 , asBrandCd
                 , asStorCd
                 , asSurvGrp
                 , 'N'
                 , 'N'
                 , 'N'
                 , SYSDATE
                 , asUserId
                 , SYSDATE
                 , asUserId
                ) ;
   EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
      null;
   END ;

   lsLine := '020';
   FOR r IN C_Stock LOOP
      Begin
         Begin
              INSERT INTO SURV_STOCK_DT
                      (      COMP_CD
                           , SURV_DT
                           , BRAND_CD
                           , STOR_CD
                           , SURV_GRP
                           , ITEM_CD
                           , ORD_UNIT_QTY
                           , SALE_UNIT_QTY
                           , BASE_QTY
                           , ORD_SURV_QTY
                           , SALE_SURV_QTY
                           , SURV_QTY
                           , SURV_REASON_CD
                           , ADJ_QTY
                           , S_CONFIRM_YN
                           , INST_DT
                           , INST_USER
                           , UPD_DT
                           , UPD_USER
                         )
                VALUES
                      (  asCompCd
                       , asSurvDt
                       , asBrandCd
                       , asStorCd
                       , asSurvGrp
                       , r.item_cd
                       , r.ord_unit_qty
                       , r.sale_unit_qty
                       , r.inventory_qty
                       , 0
                       , 0
                       , 0
                       , ''
                       , -1 * r.inventory_qty
                       , 'Y'
                       , SYSDATE
                       , asUserId
                       , SYSDATE
                       , asUserId
                       ) ;

         Exception When DUP_VAL_ON_INDEX Then
            lsLine := '030';
            UPDATE  SURV_STOCK_DT
               SET  ORD_UNIT_QTY   = r.ord_unit_qty
                 ,  SALE_UNIT_QTY  = r.sale_unit_qty
                 ,  BASE_QTY       = r.inventory_qty
                 ,  ADJ_QTY        = (CASE WHEN ORD_SURV_QTY = 0 AND SALE_SURV_QTY = 0 AND SURV_QTY = 0 THEN -1 * r.inventory_qty ELSE (ORD_UNIT_QTY*ORD_SURV_QTY + SALE_UNIT_QTY*SALE_SURV_QTY + SURV_QTY) - (r.inventory_qty) END)
                 ,  S_CONFIRM_YN   = 'Y'
                 ,  UPD_USER       = asUserId
                 ,  UPD_DT         = SYSDATE
             WHERE COMP_CD   = asCompCd
               AND SURV_DT   = asSurvDt
               AND BRAND_CD  = asBrandCd
               AND STOR_CD   = asStorCd
               AND SURV_GRP  = asSurvGrp
               AND ITEM_CD   = r.item_cd  ;
         End;

      Exception When OTHERS Then
         dbms_output.put_line( '[' || r.item_cd || '] [' || to_char(r.ord_unit_qty) || '] [' || to_char(r.sale_unit_qty) || '] [' || to_char(r.inventory_qty) || ']' || SQLERRM(SQLCODE));
         asRetMsg := '[' || r.item_cd || '] [' || to_char(r.ord_unit_qty) || '] [' || to_char(r.sale_unit_qty) || '] [' || to_char(r.inventory_qty) || ']' || SQLERRM(SQLCODE);
         RollBack;
         GoTo ErrRtn;
      End ;

   END LOOP;
   lsLine := '100';

   anRetVal := 1 ;
   asRetMsg := 'OK';
   Commit;

   <<ErrRtn>>
   NULL;

Exception When OTHERS Then
   asRetMsg := '[' || lsLine || '] ' || SQLERRM(SQLCODE);
   anRetVal := SQLCODE ;
   RollBack;
END  ;

/
