--------------------------------------------------------
--  DDL for Procedure SP_C_CARD_SAV_USE_RECV
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_C_CARD_SAV_USE_RECV" 
(
    PSV_COMP_CD   IN  VARCHAR2,
    PSV_COUPON_CD IN  VARCHAR2,
    PSV_RTN_CD    OUT NUMBER,
    PSV_RTN_MSG   OUT VARCHAR2
) IS
    CURSOR CUR_1 IS
        SELECT  COMP_CD
              , CUST_ID
        FROM    C_COUPON_CUST
        WHERE   COMP_CD   = PSV_COMP_CD
        AND     COUPON_CD = PSV_COUPON_CD
        AND     USE_STAT != '32'
        ORDER BY 
                CUST_ID
              , CERT_FDT;
        
    CURSOR CUR_2(vCUST_ID IN VARCHAR2) IS
        SELECT  HIS.COMP_CD
              , HIS.CARD_ID
              , HIS.USE_DT
              , HIS.USE_SEQ
              , HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE AS REM_MLG
              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER(ORDER BY HIS.INST_DT) AS REM_MLG_ACC
              , SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) OVER() AS REM_MLG_TOT
        FROM    C_CUST              CST
              , C_CARD              CRD
              , C_CARD_SAV_USE_HIS  HIS
        WHERE   CST.COMP_CD  = CRD.COMP_CD
        AND     CST.CUST_ID  = CRD.CUST_ID
        AND     CRD.COMP_CD  = HIS.COMP_CD
        AND     CRD.CARD_ID  = HIS.CARD_ID
        AND     CRD.COMP_CD  = PSV_COMP_CD
        AND     CRD.CUST_ID  = vCUST_ID
        AND     HIS.SAV_MLG != HIS.USE_MLG;
    
    vPRT_DIV    C_COUPON_ITEM_GRP.PRT_DIV%TYPE;
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        FOR MYREC2 IN CUR_2(MYREC1.CUST_ID) LOOP
            UPDATE  C_CARD_SAV_USE_HIS
            SET     USE_MLG = USE_MLG + CASE WHEN MYREC2.REM_MLG_ACC > 12 THEN 12 - (MYREC2.REM_MLG_ACC - MYREC2.REM_MLG) ELSE MYREC2.REM_MLG END
            WHERE   COMP_CD = MYREC2.COMP_CD
            AND     CARD_ID = MYREC2.CARD_ID
            AND     USE_DT  = MYREC2.USE_DT
            AND     USE_SEQ = MYREC2.USE_SEQ;
                    
            -- 12개 단위로 사용처리
            EXIT WHEN MYREC2.REM_MLG_ACC >= 12;
        END LOOP;
    END LOOP;
    
    COMMIT;
    
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := 'OK';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
END;

/
