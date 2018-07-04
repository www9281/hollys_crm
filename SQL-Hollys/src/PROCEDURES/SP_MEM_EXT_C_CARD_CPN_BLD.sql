--------------------------------------------------------
--  DDL for Procedure SP_MEM_EXT_C_CARD_CPN_BLD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_MEM_EXT_C_CARD_CPN_BLD" 
(
    PSV_COMP_CD   IN VARCHAR2,
    PSV_LVL_CD    IN VARCHAR2,
    PSV_CUST_STAT IN VARCHAR2,
    PSV_CPN_CD    IN VARCHAR2,
    PSV_RTN_CD   OUT NUMBER,
    PSV_RTN_MSG  OUT VARCHAR2
) IS
    CURSOR CUR_1 IS
        SELECT  CC1.CUST_ID, CC1.CUST_STAT
        FROM    C_CUST      CC1
        WHERE   CC1.COMP_CD = PSV_COMP_CD 
        AND     CC1.LVL_CD  = PSV_LVL_CD
        AND     1           =(
                              CASE WHEN PSV_CUST_STAT = 'A' AND  CC1.CUST_STAT IN ('2', '3') THEN 1
                                   WHEN CC1.CUST_STAT = PSV_CUST_STAT                        THEN 1
                                   ELSE 0 
                              END
                             )
        AND     NOT EXISTS (
                            SELECT 1
                            FROM   C_COUPON_CUST CC2
                            WHERE  CC2.COMP_CD   = CC1.COMP_CD
                            AND    CC2.CUST_ID   = CC1.CUST_ID
                            AND    CC2.COUPON_CD = PSV_CPN_CD
                           );
        
    vCERT_NO    C_COUPON_CUST.CERT_NO%TYPE;
    vRTNMSG     VARCHAR2(2000)  := 'OK';
    nRTNCODE    NUMBER          := 0; 
    nLOOPCNT    NUMBER          := 0;
    nRECCNT     NUMBER          := 0;
    nBLDCNT     NUMBER          := 0;
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
                
                EXIT WHEN nLOOPCNT > 50;
            END LOOP;
            
            -- 인증번호    
            vCERT_NO := FN_GET_COUPON_CERT('000', MYREC.CUST_STAT, nRTNCODE, vRTNMSG);
                
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
                          , MEMB_DIV
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
                          , CASE WHEN MYREC.CUST_STAT IN ('2','8') THEN '0' ELSE '1' END
                           );
            
            nBLDCNT := nBLDCNT + 1;
            
            IF MOD(nBLDCNT, 1000) = 0 THEN
                COMMIT;
            END IF;
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
