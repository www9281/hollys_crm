--------------------------------------------------------
--  DDL for Function FN_LOOP_TEST
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."FN_LOOP_TEST" RETURN NUMBER IS
    CURSOR CUR_1 IS
        SELECT  CARD_ID1,
                CARD_ID2,
                CARD_ID3,
                CARD_ID4,
                ROWID RID
        FROM    TEMP_CARD_LIST
        WHERE   PRC_YN = 'N';
    
    ARGCODE VARCHAR2(200)  := NULL;
    RTNCODE VARCHAR2(200)  := NULL;
    RTNMSG  VARCHAR2(2000) := NULL;
    RTNCUR  SYS_REFCURSOR;
        
BEGIN
    FOR MYREC IN CUR_1 LOOP 
        PKG_POS_CUST_REQ.SET_CUST_INFO_10('000','KOR','0',encrypt(MYREC.CARD_ID4),'','20150531','001','', RTNCODE, RTNMSG, RTNCUR);
        
        DBMS_OUTPUT.PUT_LINE('['||RTNCODE||']['||RTNMSG||']');
        
        UPDATE TEMP_CARD_LIST
        SET    PRC_YN = 'Y'
        WHERE  ROWID = MYREC.RID;
    END LOOP;
    
    COMMIT;
    
    RETURN 0;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        
        RETURN SQLCODE;
END FN_LOOP_TEST;

/
