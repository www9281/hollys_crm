--------------------------------------------------------
--  DDL for Procedure SP_MEM_DAY_C_CARD_CPN_BLD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEM_DAY_C_CARD_CPN_BLD" 
(
    PSV_COMP_CD IN  VARCHAR2,
    PSV_CPN_CD  IN  VARCHAR2,
    PSV_RTN_CD  OUT NUMBER,
    PSV_RTN_MSG OUT VARCHAR2
) IS
    CURSOR CUR_1 IS
        SELECT  CC1.CUST_ID
              , decrypt(CC1.CUST_NM) CUST_NM
              , decrypt(CC1.MOBILE ) MOBILE
        FROM    C_CUST      CC1
              , TMP_C_CUST  TC1
        WHERE   CC1.CUST_ID = TC1.CUST_ID
        AND     CC1.COMP_CD = PSV_COMP_CD 
        AND     TC1.CPN_DIV = PSV_CPN_CD
        AND     CC1.CUST_STAT IN ('2', '3');
        
    vCERT_NO    C_COUPON_CUST.CERT_NO%TYPE;
    vRTNMSG     VARCHAR2(2000);
    nRTNCODE    NUMBER; 
    nLOOPCNT    NUMBER;
    nRECCNT     NUMBER;
BEGIN
    SELECT  COUNT(*) INTO nRECCNT
    FROM    C_COUPON_MST
    WHERE   COMP_CD   = PSV_COMP_CD
    AND     COUPON_CD = PSV_CPN_CD
    AND     USE_YN    = 'Y';
     
    IF nRECCNT = 0 THEN
        nRTNCODE := -1403;
        vRTNMSG  := '쿠폰코드 등록 오류 입니다.';
    ELSE
        FOR MYREC IN CUR_1 LOOP
            nLOOPCNT := 0;
            
            LOOP
                nLOOPCNT := nLOOPCNT + 1;
                
                EXIT WHEN nLOOPCNT > 1000;
            END LOOP;
            
            -- 인증번호    
            vCERT_NO := FN_GET_COUPON_CERT('000', nRTNCODE, vRTNMSG);
                
            IF nRTNCODE != 0 THEN
                PSV_RTN_CD  := nRTNCODE;
                PSV_RTN_MSG := vRTNMSG;
                    
                ROLLBACK;
                    
                RETURN;
            END IF;    

            MERGE INTO C_COUPON_CUST CCC
                USING  (
                        SELECT  COMP_CD
                              , CUST_ID
                              , LVL_CD
                              , BRAND_CD
                              , MOBILE
                        FROM    C_CUST
                        WHERE   COMP_CD = '000'
                        AND     CUST_ID = MYREC.CUST_ID
                       ) CST
                ON     (        
                                CCC.COMP_CD   = CST.COMP_CD
                        AND     CCC.COUPON_CD = PSV_CPN_CD
                        AND     CCC.CERT_NO   = vCERT_NO
                        AND     CCC.CUST_ID   = CST.CUST_ID
                       )
                WHEN NOT MATCHED THEN
                    INSERT (
                            COMP_CD
                          , COUPON_CD
                          , CERT_NO
                          , CUST_ID
                          , PRT_LVL_CD
                          , GRP_SEQ
                          , MOBILE
                          , CERT_FDT
                          , CERT_TDT
                          , USE_STAT
                          , USE_DT
                          , USE_TM
                          , BRAND_CD
                          , STOR_CD
                          , POS_NO
                          , BILL_NO
                          , PRT_SALE_DT
                          , PRT_BRAND_CD
                          , PRT_STOR_CD
                          , PRT_POS_NO
                          , PRT_BILL_NO
                          , USE_YN
                          , INST_DT
                          , INST_USER
                          , UPD_DT
                          , UPD_USER
                           )
                    VALUES (
                            CST.COMP_CD
                          , PSV_CPN_CD
                          , vCERT_NO
                          , CST.CUST_ID
                          , CST.LVL_CD
                          , 1
                          , CST.MOBILE
                          , TO_CHAR(SYSDATE     , 'YYYYMMDD')
                          , TO_CHAR(SYSDATE + 29, 'YYYYMMDD')
                          , '01'
                          , NULL
                          , NULL
                          , CST.BRAND_CD
                          , NULL
                          , NULL
                          , NULL
                          , ''
                          , ''
                          , ''
                          , NULL
                          , NULL
                          , 'Y'
                          , SYSDATE
                          , 'SYS'
                          , SYSDATE
                          , 'SYS'
                           );                       
        END LOOP;
        
        nRTNCODE := 0;
        vRTNMSG  := 'OK';
    END IF;
        
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN
        nRTNCODE := SQLCODE;
        vRTNMSG  := SQLERRM;
        ROLLBACK;
        
END;

/
