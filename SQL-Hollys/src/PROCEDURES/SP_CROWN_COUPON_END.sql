--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_END
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_END" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_END_DT        IN    VARCHAR2,       -- 마감일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_COUPON_END
--  Description      : C_COUPON_CUST 유효기간 마료( 매일 AM:5시 실행)
--  Ref. Table       : C_COUPON_CUST
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
    -- 유효기간 만료된 쿠폰 취득 
    CURSOR CUR_1 IS
        SELECT  CCC.COMP_CD
              , CCC.COUPON_CD
              , CCC.CERT_NO
        FROM    C_COUPON_CUST   CCC
              , C_COUPON_MST    MST
        WHERE   CCC.COMP_CD     = MST.COMP_CD
        AND     CCC.COUPON_CD   = MST.COUPON_CD  
        AND     CCC.CERT_TDT    < NVL(PSV_END_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'))
        AND     MST.COUPON_STAT = '2' 
        AND     MST.CERT_YN     = 'Y'
        AND     CCC.USE_STAT   IN ('00','01','11');
        
    ERR_HANDLER     EXCEPTION;
    
    vMLG_DIV        C_CUST.MLG_DIV%TYPE         := NULL;
    vLVL_CD         C_CUST.LVL_CD%TYPE          := NULL;
    vCUST_STAT      C_CUST.CUST_STAT%TYPE       := NULL;
    vBIRTH_DT       C_CUST.BIRTH_DT%TYPE        := NULL;
    vCERTNO         C_COUPON_CUST.CERT_NO%TYPE  := NULL;
    nRECCNT         NUMBER(7)                   := NULL;
    nRTNCODE        NUMBER(7)                   := NULL;
    vRTNMSG         VARCHAR2(2000)              := NULL;
BEGIN
    -- 고객쿠폰 발행     
    FOR MYREC IN CUR_1 LOOP
        MERGE INTO C_COUPON_CUST CCC
        USING DUAL
        ON    (        
                   CCC.COMP_CD   = MYREC.COMP_CD
               AND CCC.COUPON_CD = MYREC.COUPON_CD
               AND CCC.CERT_NO   = MYREC.CERT_NO
              )
        WHEN MATCHED THEN
            UPDATE 
            SET   USE_STAT = '33'
                , USE_DT   = TO_CHAR(SYSDATE, 'YYYYMMDD')
                , UPD_DT   = SYSDATE
                , UPD_USER = 'END JOB';
    END LOOP;
    
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392');
            
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
