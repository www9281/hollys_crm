--------------------------------------------------------
--  DDL for Procedure SP_MAST4710L0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MAST4710L0" 
(
   PSV_COMP_CD              IN    VARCHAR2
,  PSV_BRAND_CD             IN    VARCHAR2
,  PSV_IN_DT                IN    VARCHAR2
,  PSV_IN_SEQ               IN    VARCHAR2
,  PSV_PRT_QTY              IN    VARCHAR2
,  PSV_USER_ID              IN    VARCHAR2
,  PSV_RTN_CD               OUT   VARCHAR2
,  PSV_RTN_MSG              OUT   VARCHAR2
)   IS
    ERR_HANDLER             EXCEPTION;

BEGIN
    PSV_RTN_CD    := '0';
    PSV_RTN_MSG   := '성공';

    -- 상품권 입고 상세 정보 생성
    FOR IDX IN 1 .. TO_NUMBER(PSV_PRT_QTY) LOOP
        INSERT INTO GIFT_IN_DT
            (
                  COMP_CD
            ,     IN_DT
            ,     IN_SEQ
            ,     GIFT_NO
            ,     GIFT_CREATE_FG
            ,     USE_YN
            ,     INST_DT
            ,     INST_USER
            ,     UPD_DT
            ,     UPD_USER
            )
            VALUES(
                  PSV_COMP_CD
            ,     PSV_IN_DT
            ,     PSV_IN_SEQ
            ,     FN_GET_GIFTNO_CREATE(PSV_COMP_CD, PSV_IN_DT, PSV_IN_SEQ)
            ,     '1'
            ,     'Y'
            ,     SYSDATE
            ,     PSV_USER_ID
            ,     SYSDATE
            ,     PSV_USER_ID
            );
    END LOOP;

    -- 상품권 입고 헤더 정보 갱신
    UPDATE  GIFT_IN_HD HD
    SET    (IN_QTY , IN_AMT) = 
           (
            SELECT  COUNT(*) IN_QTY
                  , COUNT(*) * HD.PRICE
            FROM    GIFT_IN_DT DT
            WHERE   DT.COMP_CD = HD.COMP_CD
            AND     DT.IN_DT   = HD.IN_DT
            AND     DT.IN_SEQ  = HD.IN_SEQ
            AND     DT.USE_YN  = 'Y'
           )
    WHERE   COMP_CD = PSV_COMP_CD
    AND     IN_DT   = PSV_IN_DT
    AND     IN_SEQ  = PSV_IN_SEQ;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM ;
        ROLLBACK;
        RETURN;
END;

/
