--------------------------------------------------------
--  DDL for Procedure SP_ALERT_EXPIRE_MEMBERSHIP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_ALERT_EXPIRE_MEMBERSHIP" 
(
    PSV_COMP_CD       IN    VARCHAR2        -- 회사코드
)
--------------------------------------------------------------------------------
--  Procedure Name   : SP_ALERT_EXPIRE_MEMBERSHIP
--  Description      : 회원권 유효기간 만료 알림(오전 9시)
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
             ,  MS.SALE_BRAND_CD BRAND_CD
             ,  MS.SALE_STOR_CD  STOR_CD
             ,  MS.PROGRAM_ID
             ,  MS.MBS_NO
             ,  MS.CERT_NO
             ,  MS.MEMBER_NO
             ,  MS.MBS_DIV
             ,  DECRYPT(CM.MOBILE)          AS MOBILE
             ,  TO_CHAR(TO_DATE(MS.CERT_TDT, 'YYYYMMDD'), 'YYYY-MM-DD') AS CERT_TDT
             ,  FN_GET_FROMAT_HHMM(MS.OFFER_TM  - MS.USE_TM)    AS REMAIN_TM
             ,  MS.OFFER_CNT - MS.USE_CNT   AS REMAIN_CNT
             ,  MS.OFFER_AMT - MS.USE_AMT   AS REMAIN_AMT
             ,  S.TEL_NO                    AS STOR_TEL_NO
          FROM  CS_MEMBERSHIP_SALE  MS
             ,  CS_MEMBERSHIP       M
             ,  STORE               S
             ,  CS_MEMBER_EXT       ME
             ,  CS_MEMBER           CM
         WHERE  MS.COMP_CD      = M.COMP_CD
           AND  MS.PROGRAM_ID   = M.PROGRAM_ID
           AND  MS.MBS_NO       = M.MBS_NO
           AND  MS.COMP_CD      = CM.COMP_CD
           AND  MS.MEMBER_NO    = CM.MEMBER_NO
           AND  MS.COMP_CD      = S.COMP_CD
           AND  MS.SALE_BRAND_CD= S.BRAND_CD
           AND  MS.SALE_STOR_CD = S.STOR_CD
           AND  MS.COMP_CD      = ME.COMP_CD(+)
           AND  MS.MEMBER_NO    = ME.MEMBER_NO(+)
           AND  MS.COMP_CD      = PSV_COMP_CD
           AND  MS.MBS_STAT     = '10'
           AND  MS.SALE_DIV     = '1'
           AND  MS.USE_YN       = 'Y'
           AND  MS.CERT_TDT     = TO_CHAR(SYSDATE + 31, 'YYYYMMDD')
           AND  (
                    (MS.MBS_DIV = '1' AND MS.OFFER_TM - MS.USE_TM   > 0)
                    OR
                    (MS.MBS_DIV = '2' AND MS.OFFER_CNT - MS.USE_CNT > 0)
                    OR
                    (MS.MBS_DIV = '3' AND MS.OFFER_AMT - MS.USE_AMT > 0)
                )
           AND  SMS_RCV_YN(+)   = 'Y';

    vSendDt         CS_CONTENT_SEND.SEND_DT%TYPE;               -- 전송일시
    --vSendMobile     SC_TRAN.TR_CALLBACK%TYPE := '0222260970';   -- 발신번호
    vContent        SC_TRAN.TR_MSG%TYPE;                        -- 전송메세지
    nSendSeq        CS_CONTENT_SEND.SEND_SEQ%TYPE;              -- 전송순번
    nScTranSeq      SC_TRAN.TR_NUM%TYPE;                        -- LG U+ 전송순번
    ERR_HANDLER     EXCEPTION;
BEGIN

    FOR MYREC IN CUR_1 LOOP
        IF MYREC.STOR_TEL_NO IS NOT NULL AND LENGTH(REPLACE(MYREC.STOR_TEL_NO, '-', '')) > 8 THEN
            vSendDt     := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
            nSendSeq    := SQ_SEND_SEQ.NEXTVAL;
            nScTranSeq  := SC_TRAN_SEQ.NEXTVAL;

            vContent := '보유하신 회원권의 사용이 만료됩니다.' || CHR(13) || CHR(10);
            IF MYREC.MBS_DIV = '1' THEN
                vContent := vContent
                         || '잔여:' || MYREC.REMAIN_TM || CHR(13) || CHR(10);
            ELSIF MYREC.MBS_DIV = '2' THEN
                vContent := vContent
                         || '잔여:' || MYREC.REMAIN_CNT || '회' || CHR(13) || CHR(10);
            ELSIF MYREC.MBS_DIV = '3' THEN
                vContent := vContent
                         || '잔여:' || MYREC.REMAIN_CNT || '원' || CHR(13) || CHR(10);
            END IF;

            vContent := vContent
                     || '만료:' || MYREC.CERT_TDT;

            -- 1. SMS전송테이블 저장
            INSERT  INTO CS_CONTENT_SEND
            (
                    COMP_CD
                 ,  SEND_DT
                 ,  SEND_SEQ
                 ,  SUBJECT
                 ,  CONTENT
                 ,  MEMBER_NO
                 ,  SEND_MOBILE
                 ,  MOBILE
                 ,  BRAND_CD
                 ,  STOR_CD
                 ,  SEND_DIV
                 ,  MSGKEY
                 ,  USE_YN
                 ,  INST_DT
                 ,  INST_USER
                 ,  UPD_DT
                 ,  UPD_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  vSendDt
                 ,  nSendSeq
                 ,  NVL(FC_GET_WORDPACK(PSV_COMP_CD, 'kor', 'NO_SUBJECT'), ' ')
                 ,  TRIM(vContent)
                 ,  MYREC.MEMBER_NO
                 ,  ENCRYPT(REPLACE(MYREC.STOR_TEL_NO, '-', ''))
                 ,  ENCRYPT(REPLACE(MYREC.MOBILE, '-', ''))
                 ,  MYREC.BRAND_CD
                 ,  MYREC.STOR_CD
                 ,  '1'
                 ,  nScTranSeq
                 ,  'Y'
                 ,  SYSDATE
                 ,  'SYSTEM'
                 ,  SYSDATE
                 ,  'SYSTEM'
            );

            -- 2. 문자메세지 발송처리
            INSERT INTO SC_TRAN
            (       TR_NUM
                 ,  TR_SENDDATE
                 ,  TR_SENDSTAT
                 ,  TR_MSGTYPE
                 ,  TR_CALLBACK
                 ,  TR_PHONE
                 ,  TR_MSG
            ) VALUES (
                    nScTranSeq
                 ,  TO_DATE(vSendDt, 'YYYYMMDDHH24MISS')
                 ,  '0'
                 ,  '0'
                 ,  REPLACE(MYREC.STOR_TEL_NO, '-', '')
                 ,  REPLACE(MYREC.MOBILE, '-', '')
                 ,  TRIM(vContent)
            );

            -- 3.전송로그
            INSERT  INTO CS_CONTENT_SEND_LOG
            (
                    COMP_CD
                 ,  SEND_DT
                 ,  SEND_SEQ
                 ,  MSGKEY
                 ,  INST_DT
                 ,  INST_USER
            ) VALUES (
                    PSV_COMP_CD
                 ,  vSendDt
                 ,  nSendSeq
                 ,  nScTranSeq
                 ,  SYSDATE
                 ,  'SYSTEM'
            );

            COMMIT;

        END IF;

    END LOOP;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN;
END;

/
