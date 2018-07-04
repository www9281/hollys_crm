--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_SURVEY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_SURVEY" 
(  
    PSV_COMP_CD       IN    VARCHAR2,               -- 회사코드  
    PSV_LANG_TP       IN    VARCHAR2,               -- 언어타입  
    PSV_CUST_ID       IN    VARCHAR2,               -- 고객번호  
    PSV_PRT_DIV       IN    VARCHAR2,               -- 01:등업, 02:첫충전, 03:가입, 04:생일, 05:12+1, 06:구매, 07:첫충전, 08:자동충전, 09:설문조사      
    PSV_RTN_CD        OUT   NUMBER,                 -- 처리코드  
    PSV_RTN_MSG       OUT   VARCHAR2                -- 처리Message  
)  
---------------------------------------------------------------------------------------------------  
--  Procedure Name   : SP_SURVEY_COUPON_BLD  
--  Description      : 설문조사 참여 후 쿠폰 발행  
--  Ref. Table       :   
---------------------------------------------------------------------------------------------------  
IS  
                   
    ERR_HANDLER     EXCEPTION;      
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;     
    nARG_RTN_CD     NUMBER;  
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;  
BEGIN  
    PSV_RTN_CD := 0;  
    PSV_RTN_MSG := 'OK';  
      
    SP_CROWN_COUPON_BLD(PSV_COMP_CD, PSV_LANG_TP, PSV_CUST_ID, PSV_PRT_DIV, ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);  
     
    PSV_RTN_CD := nARG_RTN_CD; 
    PSV_RTN_MSG := vARG_RTN_MSG; 
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
