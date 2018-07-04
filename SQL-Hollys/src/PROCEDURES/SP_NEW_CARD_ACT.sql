--------------------------------------------------------
--  DDL for Procedure SP_NEW_CARD_ACT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_NEW_CARD_ACT" 
   (
    PSV_CRD_TYP_SEQ   IN    VARCHAR2,               -- 카드TYPE발행순번    
    PSV_RTN_CD        OUT   VARCHAR2,               -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2                -- 처리Message
   ) 
IS
    CURSOR CUR_1 IS
        SELECT  *
        FROM    C_RANDOM_CARD
        WHERE   SEQ = PSV_CRD_TYP_SEQ;
    
    ARGCODE VARCHAR2(200)  := NULL;
    RTNCODE VARCHAR2(200)  := NULL;
    RTNMSG  VARCHAR2(2000) := NULL;
    RTNCUR  SYS_REFCURSOR;
        
BEGIN
    FOR MYREC IN CUR_1 LOOP 
        SP_SET_CUST_INFO_10('000','KOR','0',encrypt(MYREC.CARD_ID),TO_CHAR(SYSDATE, 'YYYYMMDD'),'001','', RTNCODE, RTNMSG);
    END LOOP;
    
    COMMIT;
    
    PSV_RTN_CD  := RTNCODE;
    PSV_RTN_MSG := RTNMSG;
    
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
        RETURN;
END SP_NEW_CARD_ACT;

/
