--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_EVENT2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_EVENT2" 
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
    -- 생일쿠폰
    CURSOR CUR_1 IS
        SELECT  COMP_CD
              , CUST_ID
              , BIRTH_DT
        FROM    C_CUST CST
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CUST_STAT IN ('2', '3')
        AND   (
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               )
                OR
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               ) 
                OR
               (
                        DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') 
                AND     DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4)) <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD')
               )
              )
        AND     EXISTS(SELECT   1
                       FROM     C_CARD CRD
                       WHERE    CRD.COMP_CD = CST.COMP_CD
                       AND      CRD.CUST_ID = CST.CUST_ID);
                            
    ERR_HANDLER     EXCEPTION;
    
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;
    
    nARG_RTN_CD     NUMBER;
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
BEGIN
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := 'OK';
    
    -- 생일쿠폰 발생
    FOR MYREC1 IN CUR_1 LOOP
        -- 생일쿠폰 발생 오류는 체크 없음.
        SP_CROWN_COUPON_BLD(MYREC1.COMP_CD, PSV_LANG_TP, MYREC1.CUST_ID, '04', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
    END LOOP;

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
