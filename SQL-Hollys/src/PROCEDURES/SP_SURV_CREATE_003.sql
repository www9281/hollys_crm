--------------------------------------------------------
--  DDL for Procedure SP_SURV_CREATE_003
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SURV_CREATE_003" 
( 
    PI_COMP_CD      IN  VARCHAR2, -- 회사코드
    PI_BRAND_CD     IN  VARCHAR2, -- 영업조직
    PI_STOR_CD      IN  VARCHAR2, -- 점포코드
    PI_SURV_DT      IN  VARCHAR2, -- 실사일자
    PI_SURV_GRP     IN  VARCHAR2, -- 실사구분
    PI_MNG_DIV      IN  VARCHAR2, -- 품목구분
    PI_L_CLASS_CD   IN  VARCHAR2, -- 대분류코드
    PI_M_CLASS_CD   IN  VARCHAR2, -- 중분류코드
    PI_S_CLASS_CD   IN  VARCHAR2, -- 소분류코드
    PI_ITEM_DIV     IN  VARCHAR2, -- 제상품구분
    PI_USER_ID      IN  VARCHAR2, -- 담당자 ID
    PI_LANG_CD      IN  VARCHAR2, -- 언어코드
    PO_RET_VAL      OUT VARCHAR2,
    PO_RET_MSG      OUT VARCHAR2
) IS
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_SURV_CREATE_003               [STCK4225M0.jsp]
--  Description      : 카츠야 전용 재고실사 자료 생성
--  Ref. Table       : SURV_STOCK
---------------------------------------------------------------------------------------------------
--  Create Date      : 2014-05-16
--  Create Programer : 최세원
--  Modify Date      :
--  Modify Programer :
---------------------------------------------------------------------------------------------------

lsStorTp          STORE.STOR_TP%TYPE;
lnConfirmCnt      Number        := 0 ;      -- 재고실사 확정 건수
lsLine            varchar2(3)   := '000';

L_CNT99           NUMBER;

CURSOR C_Stock IS
    WITH ST AS
    ( 
        SELECT  COMP_CD 
             ,  ITEM_CD                                         AS ITEM_CD
             ,  ROUND(BOF_STOCK_QTY + STOCK_QTY - ADJ_QTY, 2)   AS END_QTY
          FROM TABLE(CAST ( FC_GET_STOCK_FQTY_CD_DAY (PI_COMP_CD, PI_LANG_CD, PI_BRAND_CD, PI_STOR_CD,PI_SURV_DT) AS TBL_STOCK_FQTY_CD_DAY ) )
    )
    SELECT  I.ITEM_CD                    AS ITEM_CD
         ,  I.ORD_UNIT_QTY               AS ORD_UNIT_QTY
         ,  NVL(I.SALE_UNIT_QTY, 1)      AS SALE_UNIT_QTY
         ,  NVL(S.END_QTY     , 0)       AS INVENTORY_QTY
      FROM  ( 
                SELECT  I.*
                  FROM  ITEM_CHAIN  I
                     ,  ITEM_CLASS  IC
                 WHERE  I.COMP_CD   = IC.COMP_CD(+)
                   AND  I.ITEM_CD   = IC.ITEM_CD(+)
                   AND  I.COMP_CD   = PI_COMP_CD
                   AND  I.BRAND_CD  = PI_BRAND_CD
                   AND  I.STOR_TP   = lsStorTp
                   AND  (PI_L_CLASS_CD IS NULL OR NVL(IC.L_CLASS_CD, I.L_CLASS_CD) = PI_L_CLASS_CD)
                   AND  (PI_M_CLASS_CD IS NULL OR NVL(IC.M_CLASS_CD, I.M_CLASS_CD) = PI_M_CLASS_CD)
                   AND  (PI_S_CLASS_CD IS NULL OR NVL(IC.S_CLASS_CD, I.S_CLASS_CD) = PI_S_CLASS_CD)
                   AND  (PI_ITEM_DIV   IS NULL OR I.ITEM_DIV = PI_ITEM_DIV)
                   AND  I.USE_YN        = 'Y'
                   AND  IC.ORG_CLASS_CD(+) = '00'
            )                 I
         ,  STORE_PROD_ITEM M
         ,  ST              S
     WHERE  I.COMP_CD  = S.COMP_CD(+)
       AND  I.ITEM_CD  = S.ITEM_CD(+)
       AND  I.COMP_CD  = M.COMP_CD
       AND  I.ITEM_CD  = M.ITEM_CD
       AND  M.COMP_CD  = PI_COMP_CD
       AND  M.BRAND_CD = PI_BRAND_CD
       AND  M.STOR_CD  = PI_STOR_CD
       AND  M.MNG_DIV  = PI_MNG_DIV
       AND  M.USE_YN   = 'Y';

BEGIN

    BEGIN
        SELECT  STOR_TP INTO lsStorTp
          FROM  STORE
         WHERE  COMP_CD  = PI_COMP_CD
           AND  BRAND_CD = PI_BRAND_CD
           AND  STOR_CD  = PI_STOR_CD
           AND  USE_YN   = 'Y' ;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        PO_RET_MSG := FC_GET_WORDPACK(PI_COMP_CD, '1004000002', PI_LANG_CD);       -- 미등록 점포입니다.
        PO_RET_VAL := '0' ;
        GOTO ErrRtn ;
    END;

    BEGIN
        SELECT  COUNT(*)
          INTO  L_CNT99
          FROM  SURV_STOCK_HD
         WHERE  COMP_CD  = PI_COMP_CD
           AND  SURV_DT  = PI_SURV_DT
           AND  BRAND_CD = PI_BRAND_CD
           AND  STOR_CD  = PI_STOR_CD
           AND  SURV_GRP = '99';

        IF L_CNT99 > 0 THEN
            PO_RET_MSG := FC_GET_WORDPACK(PI_COMP_CD, '1010001280', PI_LANG_CD);       -- 이미 생성된 실사 자료가 존재합니다.
            PO_RET_VAL := '0';
            GOTO ErrRtn ;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            PO_RET_MSG := SQLERRM;
            PO_RET_VAL := TO_CHAR(SQLCODE);
            GOTO ErrRtn ;
    END;

    lsLine := '010';
    BEGIN
        INSERT INTO SURV_STOCK_HD
        ( 
                COMP_CD
            ,   SURV_DT
            ,   BRAND_CD
            ,   STOR_CD
            ,   SURV_GRP
            ,   S_CONFIRM_YN
            ,   H_CONFIRM_YN
            ,   TRANS_YN
            ,   INST_DT
            ,   INST_USER
            ,   UPD_DT
            ,   UPD_USER
        ) VALUES (  
                PI_COMP_CD
            ,   PI_SURV_DT
            ,   PI_BRAND_CD
            ,   PI_STOR_CD
            ,   PI_SURV_GRP
            ,   'Y'
            ,   'N'
            ,   'N'
            ,   SYSDATE
            ,   PI_USER_ID
            ,   SYSDATE
            ,   PI_USER_ID
        ) ;
        EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            null;
    END ;

    lsLine := '020';

    IF ( TO_CHAR(SYSDATE, 'DD') = '01' ) THEN
        SP_MSTOCK_STORE(PI_COMP_CD, TO_CHAR(SYSDATE ,'YYYYMM'), PI_BRAND_CD, PI_STOR_CD);                                -- 당월
        SP_MSTOCK_STORE(PI_COMP_CD, TO_CHAR( ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), PI_BRAND_CD, PI_STOR_CD);               -- 전월
        SP_END_MSTOCK(PI_COMP_CD, TO_CHAR( ADD_MONTHS(SYSDATE, -1), 'YYYYMM'), PI_BRAND_CD, PI_STOR_CD, '0'); -- 전월 기말수량을 당월기초수량을로 생성한다.
    END IF;

    lsLine := '040';
    FOR r IN C_Stock LOOP
        Begin
            Begin
                INSERT INTO SURV_STOCK_DT
                (      
                        COMP_CD
                    ,   SURV_DT
                    ,   BRAND_CD
                    ,   STOR_CD
                    ,   SURV_GRP
                    ,   ITEM_CD
                    ,   ORD_UNIT_QTY
                    ,   SALE_UNIT_QTY
                    ,   BASE_QTY
                    ,   ORD_SURV_QTY
                    ,   SALE_SURV_QTY
                    ,   SURV_QTY
                    ,   SURV_REASON_CD
                    ,   ADJ_QTY
                    ,   S_CONFIRM_YN
                    ,   INST_DT
                    ,   INST_USER
                    ,   UPD_DT
                    ,   UPD_USER
                ) VALUES (  
                        PI_COMP_CD
                    ,   PI_SURV_DT
                    ,   PI_BRAND_CD
                    ,   PI_STOR_CD
                    ,   PI_SURV_GRP
                    ,   r.item_cd
                    ,   r.ord_unit_qty
                    ,   r.sale_unit_qty
                    ,   r.inventory_qty
                    ,   0
                    ,   0
                    ,   0
                    ,   ''
                    ,   -1 * r.inventory_qty
                    ,   'N'
                    ,   SYSDATE
                    ,   PI_USER_ID
                    ,   SYSDATE
                    ,   PI_USER_ID
                ) ;

                Exception When DUP_VAL_ON_INDEX Then
                    lsLine := '050';
                    UPDATE  SURV_STOCK_DT
                       SET  ORD_UNIT_QTY    = r.ord_unit_qty
                         ,  SALE_UNIT_QTY   = r.sale_unit_qty
                         ,  BASE_QTY        = r.inventory_qty
                         ,  ADJ_QTY         = (CASE WHEN ORD_SURV_QTY = 0 AND SURV_QTY = 0 THEN -1 * r.inventory_qty ELSE ADJ_QTY END)
                         ,  UPD_USER        = PI_USER_ID
                         ,  UPD_DT          = SYSDATE
                     WHERE  COMP_CD         = PI_COMP_CD
                       AND  SURV_DT         = PI_SURV_DT
                       AND  BRAND_CD        = PI_BRAND_CD
                       AND  STOR_CD         = PI_STOR_CD
                       AND  SURV_GRP        = PI_SURV_GRP
                       AND  ITEM_CD         = r.item_cd  ;
            End;

        Exception When OTHERS Then
            dbms_output.put_line( '[' || r.item_cd || '] [' || to_char(r.ord_unit_qty) || '] [' || to_char(r.sale_unit_qty) || '] [' || to_char(r.inventory_qty) || ']');
            PO_RET_MSG := '[' || r.item_cd || '] [' || to_char(r.ord_unit_qty) || '] [' || to_char(r.sale_unit_qty) || '] [' || to_char(r.inventory_qty) || ']' ;
            RollBack;
            GoTo ErrRtn;
        End ;

    END LOOP;
    lsLine := '100';

    PO_RET_VAL := 1 ;
    PO_RET_MSG := '';
    Commit;

    <<ErrRtn>>
        NULL;

Exception When OTHERS Then
   PO_RET_MSG := '[' || lsLine || '] ' || SQLERRM(SQLCODE);
   PO_RET_VAL := SQLCODE ;
   RollBack;
END  ;

/
