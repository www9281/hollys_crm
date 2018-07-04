--------------------------------------------------------
--  DDL for Procedure SP_SURV_CREATE_CDR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SURV_CREATE_CDR" 
                ( asCompCd     IN  VARCHAR2, -- 회사코드
                  asBrandCd    IN  VARCHAR2, -- 영업조직
                  asStorCd     IN  VARCHAR2, -- 점포코드
                  asSurvDt     IN  VARCHAR2, -- 실사일자
                  asSurvGrp    IN  VARCHAR2, -- 실사구분
                  asMngDiv     IN  VARCHAR2, -- 품목구분
                  asLClassCd   IN  VARCHAR2, -- 대분류코드
                  asMClassCd   IN  VARCHAR2, -- 중분류코드
                  asSClassCd   IN  VARCHAR2, -- 소분류코드
                  asItemDiv    IN  VARCHAR2, -- 제상품구분
                  asUserId     IN  VARCHAR2, -- 담당자 ID
                  PSV_LANG_CD  IN  VARCHAR2, -- 언어코드
                  anRetVal     OUT VARCHAR2,
                  asRetMsg     OUT VARCHAR2
                ) IS

---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_SURV_CREATE_CDR               [STCK4223M0.jsp]
--  Description      : 재고 현황에 등록된 상품만 재고 실사 가능
--  Ref. Table       : SURV_STOCK
---------------------------------------------------------------------------------------------------
--  Create Date      : 2015-06-01
--  Create Programer : SWCHOI
--  Modify Date      : 2015-06-01
--  Modify Programer :
---------------------------------------------------------------------------------------------------

lsStorTp          STORE.STOR_TP%TYPE;
lnConfirmCnt      Number := 0 ; -- 재고실사 확정 건수
lsLine            varchar2(3) := '000';

L_CNT99           NUMBER;

CURSOR C_Stock IS
   WITH ST AS
             ( SELECT   COMP_CD 
                     ,  ITEM_CD                                 AS ITEM_CD
                     ,  BOF_STOCK_QTY + STOCK_QTY - ADJ_QTY     AS END_QTY
                 FROM TABLE(CAST ( FC_GET_STOCK_EQTY_CD_DAY (asCompCd, 'KOR', asBrandCd, asStorCd, asSurvDt) AS TBL_STOCK_EQTY_CD_DAY ) )
             )
   SELECT  I.ITEM_CD                    AS ITEM_CD
         , I.ORD_UNIT_QTY               AS ORD_UNIT_QTY
         , NVL(I.SALE_UNIT_QTY, 1)      AS SALE_UNIT_QTY
         , NVL(S.END_QTY     , 0)       AS INVENTORY_QTY
     FROM ( SELECT I.*
              FROM ITEM_CHAIN   I
                 , ITEM_CLASS   IC
             WHERE I.COMP_CD    = IC.COMP_CD(+)
               AND I.ITEM_CD    = IC.ITEM_CD(+)
               AND I.COMP_CD    = asCompCd
               AND I.BRAND_CD   = asBrandCd
               AND I.STOR_TP    = lsStorTp
               AND (asLClassCd IS NULL OR NVL(IC.L_CLASS_CD, I.L_CLASS_CD) = asLClassCd)
               AND (asMClassCd IS NULL OR NVL(IC.M_CLASS_CD, I.M_CLASS_CD) = asMClassCd)
               AND (asSClassCd IS NULL OR NVL(IC.S_CLASS_CD, I.S_CLASS_CD) = asSClassCd)
               AND (asItemDiv IS NULL OR I.ITEM_DIV = asItemDiv)
               AND I.USE_YN     = 'Y'
               AND IC.ORG_CLASS_CD(+) = '00'
          )                 I
         , STORE_PROD_ITEM  M
         , ST     S
    WHERE I.COMP_CD  = S.COMP_CD(+)
      AND I.ITEM_CD  = S.ITEM_CD(+)
      AND I.COMP_CD  = M.COMP_CD
      AND I.ITEM_CD  = M.ITEM_CD
      AND M.COMP_CD  = asCompCd
      AND M.BRAND_CD = asBrandCd
      AND M.STOR_CD  = asStorCd
      AND M.MNG_DIV  = asMngDiv
      AND M.USE_YN   = 'Y'  ;

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

   BEGIN
      SELECT COUNT(*)
        INTO L_CNT99
        FROM SURV_STOCK_HD
       WHERE COMP_CD  = asCompCd
         AND SURV_DT  = asSurvDt
         AND BRAND_CD = asBrandCd
         AND STOR_CD  = asStorCd
         AND SURV_GRP = '99';

      IF L_CNT99 > 0 THEN
         asRetMsg := FC_GET_WORDPACK(asCompCd, '1010001280', PSV_LANG_CD);       -- 이미 생성된 실사 자료가 존재합니다.
         anRetVal := '0';
         GOTO ErrRtn ;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
      WHEN OTHERS THEN
         asRetMsg := SQLERRM;
         anRetVal := TO_CHAR(SQLCODE);
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
   /* 실사한 자료가 있어도 실사 할 수 있게 수정 함 , 아래의 PASS처리한 부분 포함
   BEGIN
      SELECT COUNT(*) INTO lnConfirmCnt
        FROM  SURV_STOCK_DT  S
            , ( SELECT  BRAND_CD
                      , ITEM_CD
                  FROM ITEM_CHAIN
                 WHERE BRAND_CD = asBrandCd
                   AND STOR_TP  = lsStorTp
                   AND USE_YN   = 'Y'
                MINUS
                SELECT  BRAND_CD
                      , TOUCH_CD  AS ITEM_CD
                  FROM TOUCH_STORE_UI
                 WHERE BRAND_CD = asBrandCd
                   AND STOR_CD  = asStorCd
                   AND USE_YN   = 'Y'
              )    I
       WHERE S.BRAND_CD     = I.BRAND_CD
         AND S.ITEM_CD      = I.ITEM_CD
         AND S.SURV_DT      = asSurvDt
         AND S.BRAND_CD     = asBrandCd
         AND S.STOR_CD      = asStorCd
         AND S.S_CONFIRM_YN = 'Y' ;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      lnConfirmCnt := 0 ;
   END;

   lsLine := '030';
   If ( lnConfirmCnt > 0 ) Then
      asRetMsg := '이미 확정된 실사 자료가 있습니다.' ;
      anRetVal := '1541003' ;
      GOTO ErrRtn ;
   End If;
   */

   IF ( TO_CHAR(SYSDATE, 'DD') = '01' ) THEN
      SP_MSTOCK_STORE(asCompCd, TO_CHAR(SYSDATE ,'YYYYMM'), asBrandCd, asStorCd);                                -- 당월
      SP_MSTOCK_STORE(asCompCd, TO_CHAR( ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), asBrandCd, asStorCd);               -- 전월
      SP_END_MSTOCK(asCompCd, TO_CHAR( ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), asBrandCd, asStorCd, '0'); -- 전월 기말수량을 당월기초수량을로 생성한다.
   END IF;

   lsLine := '040';
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
            lsLine := '050';
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
