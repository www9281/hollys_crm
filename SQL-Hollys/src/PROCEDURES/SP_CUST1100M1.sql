--------------------------------------------------------
--  DDL for Procedure SP_CUST1100M1
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1100M1" (
    PSV_COMP_CD     IN VARCHAR2,
    PSV_LANG_CD     IN VARCHAR2,
    PSV_CUST_ID     IN VARCHAR2,
    PSV_COUPON_CD   IN VARCHAR2,
    PSV_CERT_NO     IN VARCHAR2,
    PR_RTN_CD       OUT VARCHAR2,                -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2                  -- 처리Message
   )
IS
--------------------------------------------------------------------------------
--  Procedure Name   : SP_C_CUST_CARD_STAT
--  Description      : 쿠폰 선물하기 내역 삭제
--  Ref. Table       :
--------------------------------------------------------------------------------
--  Create Date      : 2015-04-16 엠즈씨드 CRM PJT
--  Modify Date      : 2015-04-16
--------------------------------------------------------------------------------
    vNEW_CERT_NO    C_COUPON_CUST.CERT_NO%TYPE  := NULL;
    vUSE_STAT       C_COUPON_CUST.USE_STAT%TYPE := NULL;
    vCUST_STAT      C_CUST.CUST_STAT%TYPE       := NULL;
    vRTN_CD         VARCHAR2(2000) := NULL;
    vRTN_MSG        VARCHAR2(2000) := NULL;
    nREC_CNT        NUMBER         := 0;
BEGIN
    SELECT  MAX(CUST_STAT), MAX(USE_STAT), COUNT(*) 
    INTO    vCUST_STAT    , vUSE_STAT    , nREC_CNT
    FROM    C_COUPON_CUST  CCC
          , C_CUST         CST
    WHERE   CCC.COMP_CD  = CST.COMP_CD
    AND     CCC.CUST_ID  = CST.CUST_ID
    AND     CCC.COMP_CD  = PSV_COMP_CD
    AND     CCC.CUST_ID  = PSV_CUST_ID
    AND     CCC.COUPON_CD= PSV_COUPON_CD
    AND     CCC.CERT_NO  = PSV_CERT_NO
    AND     CCC.USE_YN   = 'Y';
    
    IF nREC_CNT = 0 OR vUSE_STAT NOT IN ('01','11') THEN
        ROLLBACK;
        
        PR_RTN_CD  := '1010001593';
        PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_CD, PR_RTN_CD);
    ELSE 
        vNEW_CERT_NO := PCRM.FN_GET_COUPON_CERT (PSV_COMP_CD, vCUST_STAT, vRTN_CD, vRTN_MSG);
        
        DELETE  FROM C_COUPON_CUST_GIFT
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     COUPON_CD= PSV_COUPON_CD
        AND     CERT_NO  = PSV_CERT_NO;
        
        UPDATE  C_COUPON_CUST
        SET     CERT_NO = vNEW_CERT_NO
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     CUST_ID  = PSV_CUST_ID
        AND     COUPON_CD= PSV_COUPON_CD
        AND     CERT_NO  = PSV_CERT_NO;
    END IF;

   COMMIT;
   
   PR_RTN_CD  := '0';
   PR_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_CD, '1001000416');
   
   RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PR_RTN_CD  := TO_CHAR(SQLCODE);
        PR_RTN_MSG := SQLERRM;
        
        RETURN;
END;

/
