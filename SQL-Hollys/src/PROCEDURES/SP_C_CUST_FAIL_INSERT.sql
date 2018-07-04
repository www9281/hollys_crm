--------------------------------------------------------
--  DDL for Procedure SP_C_CUST_FAIL_INSERT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_C_CUST_FAIL_INSERT" 
(
    PSV_RTN_CODE OUT NUMBER,
    PSV_RTN_MSG  OUT VARCHAR2
) IS
    CURSOR CUR_1 IS
        SELECT  '000' COMP_CD, AA.CUST_ID, encrypt(AA.CUST_NM) CUST_NM, GET_SHA1_STR(SUBSTR(MOBILE, LENGTHB(MOBILE) -3, 4)) CUST_PW, 'Y' PW_DIV, 
                SEX_DIV, LUNAR_DIV, BIRTH_DT, encrypt(MOBILE) MOBILE, SUBSTR(MOBILE, LENGTHB(MOBILE) -3, 4) MOBILE_N3,
                 'Y' SMS_RCV_YN, EMAIL, 'Y' EMAIL_RCV_YN, 'H' ADDR_DIV, ZIP_CD, 
                ADDR1, ADDR2, '20150805' JOIN_DT,'0000000' STOR_CD,'001' BRAND_CD, 
                MOBILE_KIND, '101' LVL_CD, '1' CUST_STAT, NULL IPIN,
                AA.CARD_ID CARD_ID,
                ROW_NUMBER() OVER(PARTITION BY AA.MOBILE ORDER BY AA.DATA_FLG DESC) R_NUM
        FROM    TEMP_C_CUST       AA;
BEGIN
    PSV_RTN_CODE := 0;
    PSV_RTN_MSG  := 'OK';
        
    FOR MYREC IN CUR_1 LOOP
        PSV_RTN_CODE := 0;
        PSV_RTN_MSG  := 'OK';
    
        IF MYREC.R_NUM = 1 THEN
            INSERT INTO C_CUST
               (
                COMP_CD, CUST_ID, CUST_NM, CUST_PW, PW_DIV, SEX_DIV, LUNAR_DIV, BIRTH_DT, MOBILE, MOBILE_N3, 
                SMS_RCV_YN, EMAIL, EMAIL_RCV_YN, ADDR_DIV, ZIP_CD, ADDR1, ADDR2, JOIN_DT, STOR_CD, BRAND_CD, 
                MOBILE_KIND, LVL_CD,CUST_STAT,IPIN
               )
            VALUES
               (
                MYREC.COMP_CD, MYREC.CUST_ID, MYREC.CUST_NM, MYREC.CUST_PW, MYREC.PW_DIV, MYREC.SEX_DIV, MYREC.LUNAR_DIV, MYREC.BIRTH_DT, MYREC.MOBILE, MYREC.MOBILE_N3, 
                MYREC.SMS_RCV_YN, MYREC.EMAIL, MYREC.EMAIL_RCV_YN, MYREC.ADDR_DIV, MYREC.ZIP_CD, MYREC.ADDR1, MYREC.ADDR2, MYREC.JOIN_DT, MYREC.STOR_CD, MYREC.BRAND_CD, 
                MYREC.MOBILE_KIND, MYREC.LVL_CD, MYREC.CUST_STAT, MYREC.IPIN
               );
            
            UPDATE  C_CARD
            SET     REP_CARD_YN  = 'Y'
            WHERE   COMP_CD  = MYREC.COMP_CD
            AND     CARD_ID  = MYREC.CARD_ID;    
        END IF;
          
        UPDATE  C_CARD
        SET     CUST_ID  = MYREC.CUST_ID
        WHERE   COMP_CD  = MYREC.COMP_CD
        AND     CARD_ID  = MYREC.CARD_ID;      
    END LOOP;
    
    --COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
                     
        PSV_RTN_CODE := SQLCODE;
        PSV_RTN_MSG  := SQLERRM;
END;

/
