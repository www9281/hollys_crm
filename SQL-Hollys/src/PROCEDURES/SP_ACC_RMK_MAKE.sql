--------------------------------------------------------
--  DDL for Procedure SP_ACC_RMK_MAKE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ACC_RMK_MAKE" (PSV_RTN_CODE OUT VARCHAR2) IS
    CURSOR CUR_1 IS
        SELECT  MST.COMP_CD
             ,  MST.ETC_CD
             ,  MST.STOR_TP
             ,  RMK.RMK_DESC
        FROM   ACC_MST      MST
             , TMP_ACC_RMK  RMK
        WHERE  MST.ETC_CD = RMK.ETC_CD
        AND    RMK.USE_YN ='Y';

    nRECCNT     NUMBER :=0;
    vRMK_NM     VARCHAR2(2000) := NULL;
BEGIN
    FOR MYREC IN CUR_1 LOOP
        nRECCNT := 0;
        vRMK_NM := MYREC.RMK_DESC;
        LOOP
            nRECCNT := nRECCNT + 1;

            IF INSTRB(vRMK_NM, ',', 1, 1) = 0 THEN
                INSERT INTO ACC_RMK
                VALUES (MYREC.COMP_CD
                      , MYREC.ETC_CD
                      , MYREC.STOR_TP
                      , TO_CHAR(nRECCNT, 'FM000')
                      , vRMK_NM
                      , NULL
                      , nRECCNT
                      , 'Y'
                      , SYSDATE
                      , 'SYS'
                      , SYSDATE
                      , 'SYS'
                       );
                EXIT;
            ELSE
                INSERT INTO ACC_RMK
                VALUES (MYREC.COMP_CD
                      , MYREC.ETC_CD
                      , MYREC.STOR_TP
                      , TO_CHAR(nRECCNT, 'FM000')
                      , SUBSTRB(vRMK_NM, 1, INSTRB(vRMK_NM, ',', 1, 1) - 1)
                      , NULL
                      , nRECCNT
                      , 'Y'
                      , SYSDATE
                      , 'SYS'
                      , SYSDATE
                      , 'SYS'
                       );

                vRMK_NM := LTRIM(SUBSTRB(vRMK_NM, INSTRB(vRMK_NM, ',', 1, 1)+1, LENGTHB(vRMK_NM) - INSTRB(vRMK_NM, ',', 1, 1)));
            END IF;
        END LOOP;
    END LOOP;

    PSV_RTN_CODE := 'OK';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PSV_RTN_CODE := SQLERRM;
END SP_ACC_RMK_MAKE;

/
