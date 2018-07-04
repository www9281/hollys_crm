--------------------------------------------------------
--  DDL for Procedure SP_C_CARD_SAV_USE_LOS_RECV
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_C_CARD_SAV_USE_LOS_RECV" 
(
    PSV_COMP_CD   IN  VARCHAR2,
    PSV_RTN_CD    OUT NUMBER,
    PSV_RTN_MSG   OUT VARCHAR2
) IS
    CURSOR CUR_1 IS
        SELECT  *
        FROM    C_CARD_SAV_HIS
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     LOS_MLG_YN = 'Y' 
        AND     USE_YN     = 'Y'
        ORDER BY 
                INST_DT;
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        UPDATE  C_CARD_SAV_USE_HIS
        SET     LOS_MLG_UNUSE = SAV_MLG - USE_MLG
             ,  LOS_MLG       = MYREC1.LOS_MLG
             ,  LOS_MLG_YN    = MYREC1.LOS_MLG_YN
        WHERE   COMP_CD = MYREC1.COMP_CD
        AND     CARD_ID = MYREC1.CARD_ID
        AND     USE_DT  = MYREC1.USE_DT
        AND     USE_SEQ = MYREC1.USE_SEQ;
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
