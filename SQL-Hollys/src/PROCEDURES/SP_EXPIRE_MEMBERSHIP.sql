--------------------------------------------------------
--  DDL for Procedure SP_EXPIRE_MEMBERSHIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_EXPIRE_MEMBERSHIP" 
(
    PSV_COMP_CD       IN    VARCHAR2        -- 회사코드
)
--------------------------------------------------------------------------------
--  Procedure Name   : SP_EXPIRE_MEMBERSHIP
--  Description      : 유효기간 만료 회원권 상태 변경(매일 새벽 5시)
--  Ref. Table       : CS_MEMBERSHIP_SALE
--------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer : 
--------------------------------------------------------------------------------
IS
    CURSOR CUR_1 IS
        SELECT  MS.COMP_CD
             ,  MS.PROGRAM_ID
             ,  MS.MBS_NO
             ,  MS.CERT_NO
             ,  MS.MBS_DIV
             ,  DECRYPT(MS.MOBILE)          AS MOBILE
             ,  MS.CERT_TDT
             ,  MS.OFFER_TM  - MS.USE_TM    AS REMAIN_TM
             ,  MS.OFFER_CNT - MS.USE_CNT   AS REMAIN_CNT
             ,  MS.OFFER_AMT - MS.USE_AMT   AS REMAIN_AMT
          FROM  CS_MEMBERSHIP_SALE  MS
             ,  CS_MEMBERSHIP       M
         WHERE  MS.COMP_CD      = M.COMP_CD
           AND  MS.PROGRAM_ID   = M.PROGRAM_ID
           AND  MS.MBS_NO       = M.MBS_NO
           AND  MS.COMP_CD      = PSV_COMP_CD
           AND  MS.MBS_STAT     = '10'
           AND  MS.SALE_DIV     = '1'
           AND  MS.USE_YN       = 'Y'
           AND  MS.CERT_TDT     < TO_CHAR(SYSDATE, 'YYYYMMDD')
           AND  (
                    (MS.MBS_DIV = '1' AND MS.OFFER_TM - MS.USE_TM   > 0)
                    OR
                    (MS.MBS_DIV = '2' AND MS.OFFER_CNT - MS.USE_CNT > 0)
                    OR
                    (MS.MBS_DIV = '3' AND MS.OFFER_AMT - MS.USE_AMT > 0)
                );

    ERR_HANDLER     EXCEPTION;
BEGIN

    FOR MYREC IN CUR_1 LOOP
        -- 회원권 상태 변경
        UPDATE  CS_MEMBERSHIP_SALE
           SET  MBS_STAT    = '90'
             ,  UPD_DT      = SYSDATE
             ,  UPD_USER    = 'JOB'
         WHERE  COMP_CD     = MYREC.COMP_CD
           AND  PROGRAM_ID  = MYREC.PROGRAM_ID
           AND  MBS_NO      = MYREC.MBS_NO
           AND  CERT_NO     = MYREC.CERT_NO;

    END LOOP;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN;
END;

/
