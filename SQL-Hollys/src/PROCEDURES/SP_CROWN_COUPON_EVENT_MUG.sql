--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_EVENT_MUG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_EVENT_MUG" 
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
    -- 머그증정(기간 크라운 5개 적립 시 고객당 1회 제공)
    CURSOR CUR_1(vPRM_STR_DT IN VARCHAR2, vPRM_END_DT IN VARCHAR2) IS
        SELECT  CSH.COMP_CD
              , CSH.CUST_ID
              , CSH.USE_DT
              , CSH.BRAND_CD
        FROM   (
                SELECT  HIS.COMP_CD
                      , CRD.CUST_ID
                      , HIS.BRAND_CD
                      , MAX(USE_DT)              AS USE_DT
                      , NVL(SUM(HIS.SAV_MLG), 0) AS SAV_MLG
                FROM    C_CARD_SAV_HIS HIS
                      , C_CARD         CRD
                WHERE   CRD.COMP_CD = HIS.COMP_CD
                AND     CRD.CARD_ID = HIS.CARD_ID
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     HIS.USE_DT >= vPRM_STR_DT
                AND     HIS.USE_DT <= vPRM_END_DT
                AND     NOT EXISTS (
                                    SELECT  1
                                    FROM    C_COUPON_ITEM_GRP  GRP
                                          , C_COUPON_CUST      CST
                                    WHERE  CST.COMP_CD   = GRP.COMP_CD
                                    AND    CST.COUPON_CD = GRP.COUPON_CD
                                    AND    CST.COMP_CD   = CRD.COMP_CD
                                    AND    CST.CUST_ID   = CRD.CUST_ID
                                    AND    GRP.PRT_DIV   = '11'
                                   )
                GROUP BY
                        HIS.COMP_CD
                      , CRD.CUST_ID
                      , HIS.BRAND_CD
               ) CSH
        WHERE   SAV_MLG >= 5;
                         
    ERR_HANDLER     EXCEPTION;
    
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;
    
    nARG_RTN_CD     NUMBER;
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
    
    vSTD_BLD_DT     VARCHAR2(8)    := NULL;                 -- 처리 기준일자
    vPRM_STR_DT     VARCHAR2(8)    := NULL;                 -- 프로모션 시작일자
    vPRM_END_DT     VARCHAR2(8)    := NULL;                 -- 프로모션 종료일자
BEGIN
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := 'OK';
    
    vSTD_BLD_DT := NVL(PSV_STD_DT, TO_CHAR(SYSDATE - 1, 'YYYYMMDD'));
    
    /***********************************/
    /* 소사이어티 머그컵 증정 프로모션 */
    BEGIN
        SELECT  VAL_D1     , VAL_D2
        INTO    vPRM_STR_DT, vPRM_END_DT
        FROM   (
                SELECT  VAL_D1     , VAL_D2
                      , ROW_NUMBER() OVER(PARTITION BY CODE_TP ORDER BY VAL_D1) R_NUM
                FROM    COMMON
                WHERE   CODE_TP = '02015'
                AND     USE_YN  = 'Y'
                AND     VAL_D1 <= vSTD_BLD_DT
                AND     VAL_D2 >= vSTD_BLD_DT
               )
        WHERE   R_NUM = 1;
    EXCEPTION 
        WHEN OTHERS THEN
            vPRM_STR_DT  := NULL; 
            vPRM_END_DT  := NULL;
    END;
    
    IF vPRM_STR_DT IS NOT NULL THEN
        -- 크라운 5개 적립 시 쿠폰 증정
        FOR MYREC1 IN CUR_1(vPRM_STR_DT, vPRM_END_DT) LOOP
            SP_CROWN_COUPON_BLD(MYREC1.COMP_CD, PSV_LANG_TP, MYREC1.CUST_ID, '11', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
        END LOOP;
    END IF;
    
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
