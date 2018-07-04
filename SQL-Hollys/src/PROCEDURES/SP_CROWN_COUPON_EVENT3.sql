--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_EVENT3
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_EVENT3" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_STD_DT        IN    VARCHAR2,       -- 변경일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_GRADE_CHG
--  Description      : C_CUST.LVL_CD 산정( 매일 AM:5시 실행)
--  Ref. Table       : C_CARD_SAV_HIS
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
    -- 원두구매
    CURSOR CUR_2 IS
        SELECT  COMP_CD
             ,  SALE_DT
             ,  BRAND_CD
             ,  STOR_CD
             ,  POS_NO
             ,  BILL_NO
             ,  VOID_BEFORE_DT
             ,  VOID_BEFORE_NO
             ,  SALE_DIV
             ,  CUST_ID
             ,  ITEM_CD
             ,  ABS(SUM(SALE_QTY)) AS SALE_QTY
        FROM    C_CUST_BIT
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     COUPON_PRT = 'N'
        GROUP BY
                COMP_CD
             ,  SALE_DT
             ,  BRAND_CD
             ,  STOR_CD
             ,  POS_NO
             ,  BILL_NO
             ,  VOID_BEFORE_DT
             ,  VOID_BEFORE_NO
             ,  SALE_DIV
             ,  CUST_ID
             ,  ITEM_CD;

    ERR_HANDLER     EXCEPTION;
    
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;
    
    nARG_RTN_CD     NUMBER;
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
BEGIN
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := 'OK';
    
    -- 원두구매 대상 상품 작성
    SP_CROWN_BEAN_BUY(PSV_COMP_CD, PSV_LANG_TP, PSV_STD_DT, nARG_RTN_CD, vARG_RTN_MSG);
    
    -- 원두 할인
    FOR MYREC2 IN CUR_2 LOOP
        -- 생일쿠폰 발생 오류는 체크 없음.
        ARR_SALE_HD.SALE_DT  := MYREC2.SALE_DT;
        ARR_SALE_HD.BRAND_CD := MYREC2.BRAND_CD;
        ARR_SALE_HD.STOR_CD  := MYREC2.STOR_CD;
        ARR_SALE_HD.POS_NO   := MYREC2.POS_NO;
        ARR_SALE_HD.BILL_NO  := MYREC2.BILL_NO;
        ARR_SALE_HD.SALE_DIV := MYREC2.SALE_DIV;
        ARR_SALE_HD.VOID_BEFORE_DT := MYREC2.VOID_BEFORE_DT;
        ARR_SALE_HD.VOID_BEFORE_NO := MYREC2.VOID_BEFORE_NO;
         
        IF MYREC2.SALE_QTY != 0 THEN
            FOR i IN 1..MYREC2.SALE_QTY LOOP
                SP_CROWN_COUPON_BLD(MYREC2.COMP_CD, PSV_LANG_TP, MYREC2.CUST_ID, '06', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
                
                EXIT WHEN nARG_RTN_CD != 0;
            END LOOP;
            
            IF nARG_RTN_CD = 0 THEN
                UPDATE  C_CUST_BIT
                SET     COUPON_PRT = 'Y'
                WHERE   COMP_CD    = MYREC2.COMP_CD
                AND     BRAND_CD   = MYREC2.BRAND_CD
                AND     STOR_CD    = MYREC2.STOR_CD
                AND     POS_NO     = MYREC2.POS_NO
                AND     BILL_NO    = MYREC2.BILL_NO
                AND     ITEM_CD    = MYREC2.ITEM_CD;
            END IF;
        END IF; 
    END LOOP;
    
    ARR_SALE_HD := NULL;
    
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
                        
        ROLLBACK;
        RETURN;
END;

/
