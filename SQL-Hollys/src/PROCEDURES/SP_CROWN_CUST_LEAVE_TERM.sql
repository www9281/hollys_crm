--------------------------------------------------------
--  DDL for Procedure SP_CROWN_CUST_LEAVE_TERM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_CUST_LEAVE_TERM" 
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
        SELECT  CST.COMP_CD
              , CST.CUST_ID
              , CRD.CARD_ID
        FROM    C_CUST            CST
              , C_CARD            CRD
        WHERE   CST.COMP_CD     = CRD.COMP_CD
        AND     CST.CUST_ID     = CRD.CUST_ID
        AND     CST.COMP_CD     = PSV_COMP_CD  
        AND     CST.CUST_STAT   = '9'
        AND     CST.LEAVE_DT   >= TO_CHAR(SYSDATE-7, 'YYYYMMDDHH24MISS');
      --AND     CRD.CARD_STAT  IN ('00','10','20', '90')
    
    
    CURSOR CUR_2(vCOMP_CD IN VARCHAR2, vCARD_ID IN VARCHAR2) IS
        SELECT  CRD.COMP_CD
              , CRD.CARD_ID
              , HIS.USE_DT
              , HIS.USE_SEQ
              , HIS.SAV_MLG
              , HIS.LOS_MLG
        FROM    C_CARD            CRD
              , C_CARD_SAV_HIS    HIS
        WHERE   HIS.COMP_CD     = CRD.COMP_CD
        AND     HIS.CARD_ID     = CRD.CARD_ID  
        AND     CRD.COMP_CD     = vCOMP_CD
        AND     CRD.CARD_ID     = vCARD_ID
        AND     HIS.LOS_MLG_YN  = 'N';
            
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
    FOR MYREC1 IN CUR_1 LOOP
        FOR MYREC2 IN CUR_2(MYREC1.COMP_CD, MYREC1.CARD_ID) LOOP
            -- 탈퇴 회원의 마일리지 소멸
            UPDATE  C_CARD_SAV_HIS
            SET     LOS_MLG    = MYREC2.SAV_MLG -  MYREC2.LOS_MLG
                 ,  LOS_MLG_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')  
                 ,  LOS_MLG_YN = 'Y'
                 ,  UPD_DT     = SYSDATE
                 ,  UPD_USER   = 'SYS'
            WHERE   COMP_CD = MYREC2.COMP_CD
            AND     CARD_ID = MYREC2.CARD_ID
            AND     USE_DT  = MYREC2.USE_DT
            AND     USE_SEQ = MYREC2.USE_SEQ;
        END LOOP;
        
        -- 탈퇴 회원 카드 해지 처리
        UPDATE  C_CARD
        SET     CARD_STAT  = '91'
             ,  CANCEL_DT  = TO_CHAR(SYSDATE, 'YYYYMMDD')  
             ,  UPD_DT     = SYSDATE
             ,  UPD_USER   = 'SYS'
        WHERE   COMP_CD = MYREC1.COMP_CD
        AND     CARD_ID = MYREC1.CARD_ID;            
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
