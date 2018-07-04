--------------------------------------------------------
--  DDL for Procedure SP_CUST1100M0
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CUST1100M0" 
  (   
    PSV_COMP_CD           IN   VARCHAR2, -- 1. 회사코드   
    PSV_LANG_TP           IN   VARCHAR2, -- 2. 언어코드   
    PSV_CARD_ID_SEND      IN   VARCHAR2, -- 3. 카드번호(양도)   
    PSV_CARD_ID_RECV      IN   VARCHAR2, -- 4. 카드번호(양수)   
    PSV_CRG_DT            IN   VARCHAR2, -- 5. 결제일자   
    PSV_CRG_FG            IN   VARCHAR2, -- 6. 결제구분[3:환불, 4:이전]   
    PSV_CRG_DIV           IN   VARCHAR2, -- 7. 결제방법[9:조정]   
    PSV_CRG_AMT           IN   NUMBER,   -- 8. 결제금액   
    PSV_ACC_USER_NM       IN   VARCHAR2, -- 9. 예금주명   
    PSV_ACC_BANK          IN   VARCHAR2, -- 10.은행코드   
    PSV_ACC_NUM           IN   VARCHAR2, -- 11.계좌번호   
    PSV_CHANNEL           IN   VARCHAR2, -- 12.경로구분[2:WEB, 3:MOBILE]   
    asRetVal              OUT  VARCHAR2, -- 13.결과코드[1:정상  그외는 오류]   
    asRetMsg              OUT  VARCHAR2  -- 14.결과메시지
  ) IS   
    /***************************************************************************
    WEBPOS 호출 용으로 암호화를 소스상에서 처리
    ***************************************************************************/
    lsCardIdSend    PCRM.C_CARD.CARD_ID%TYPE;                    -- 카드 ID 양도
    lsCardIdRecv    PCRM.C_CARD.CARD_ID%TYPE;                    -- 카드 ID 양수
    lsissue_div     PCRM.C_CARD.ISSUE_DIV%TYPE;                  -- 발급구분[0:신규, 1:재발급]   
    lscard_div      PCRM.C_CARD.CARD_DIV%TYPE;                   -- 카드관리범위[1:회사, 2:영업조직, 3:점포]   
    lsbrand_cd      PCRM.C_CARD.BRAND_CD%TYPE;                   -- 영업조직   
    lsstor_cd       PCRM.C_CARD.STOR_CD%TYPE;                    -- 점포코드   
    lsCustId        PCRM.C_CARD.CUST_ID%TYPE;                    -- 회원 ID   
    lsCard_stat     PCRM.C_CARD.CARD_STAT%TYPE;                  -- 카드상태[00:대기, 10:정상, 90:분실신고, 91:해지, 99:폐기]   
    lsRefundStat    PCRM.C_CARD.REFUND_STAT%TYPE;                -- 환불 상태
    lsAccNo         PCRM.C_CARD.ACC_NO%TYPE;                     -- 환불 계좌번호
    lsBankUserNm    PCRM.C_CARD.BANK_USER_NM%TYPE;               -- 환불 예금주명
    lsRepCardYn     PCRM.C_CARD.REP_CARD_YN%TYPE;                -- 회원 ID   
    llstamp_tax     PCRM.C_CARD_CHARGE_HIS.STAMP_TAX%TYPE := 0;  -- 인지세   
    llsav_cash      PCRM.C_CARD.SAV_CASH%TYPE;                   -- 충전금액   
    lluse_cash      PCRM.C_CARD.USE_CASH%TYPE;                   -- 사용금액   
    nRecCnt         NUMBER(7) := 0;   
   
    ERR_HANDLER     EXCEPTION;   
   
  BEGIN   
    asRetVal    := '0' ;   
    asRetMsg    := 'OK'   ;   
    
    /***************************************************************************
    WEBPOS 호출 용으로 암호화를 소스상에서 처리
    ***************************************************************************/
    lsCardIdSend := encrypt(PSV_CARD_ID_SEND);
    lsCardIdRecv := encrypt(PSV_CARD_ID_RECV);
    lsAccNo      := encrypt(PSV_ACC_NUM    );
    lsBankUserNm := encrypt(PSV_ACC_USER_NM);
    /***************************************************************************/
    
    IF PSV_CRG_FG NOT IN ('3', '4') THEN -- 결제구분[3:환불, 4:이전]   
       asRetVal := '1000';   
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001411'); -- 결제구분 입력 오류 입니다.   
   
       RAISE ERR_HANDLER;   
    END IF;   
   
    IF PSV_CRG_FG =  '3' THEN -- 결제구분[3:환불]   
       IF PSV_ACC_USER_NM IS NULL OR PSV_ACC_BANK IS NULL OR PSV_ACC_NUM IS NULL THEN   
          asRetVal := '1001';   
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001413'); -- 환불시 은행코드. 예금주, 계좌번호는 필수 입력항목입니다.   
   
          RAISE ERR_HANDLER;   
       END IF;   
    ELSE   
       SELECT COUNT(DISTINCT CRD.CUST_ID)   
         INTO nRecCnt   
         FROM PCRM.C_CARD CRD   
        WHERE CRD.COMP_CD  = PSV_COMP_CD   
          AND CRD.CARD_ID IN (lsCardIdSend, lsCardIdRecv);   
   
       IF nRecCnt != 1 THEN   
          asRetVal := '1002';   
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001417'); -- 양수, 양도자의 고객번호가 일치하지 않습니다.   
   
          RAISE ERR_HANDLER;   
       END IF;   
    END IF;   
   
    -- 양도카드 체크   
    SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV), MAX(REFUND_STAT)   
      INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div,    lsRefundStat   
      FROM PCRM.C_CARD -- 멤버십카드 마스터   
     WHERE COMP_CD    = PSV_COMP_CD   
       AND CARD_ID    = lsCardIdSend   
       AND USE_YN     = 'Y'; -- 사용여부[Y:사용, N:사용안함]   
   
    IF nRecCnt = 0 THEN   
       asRetVal := '1003';   
       asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다.   
   
       RAISE ERR_HANDLER;   
    ELSE   
        IF PSV_CRG_FG =  '3' THEN   
            IF (ABS(PSV_CRG_AMT) != (llsav_cash - lluse_cash)) THEN   
                asRetVal := '1004';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001426'); -- 환불금액이 잔액과 일치하지 않습니다.   
   
                RAISE ERR_HANDLER;   
            END IF;   
            
            /*
            IF ((lluse_cash / llsav_cash * 100) < 60 ) THEN   
                asRetVal := '1005';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001427'); -- 충전금액의 60%이상 사용 시 환불이 가능합니다.   
   
                RAISE ERR_HANDLER;   
            END IF;
            */   
        ELSE   
            IF MOD(PSV_CRG_AMT, 1) != 0 THEN   
                asRetVal := '1006';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1001149105'); -- 금액 입력형식이 올바르지 않습니다.   
   
                RAISE ERR_HANDLER;   
            END IF;   
   
            IF (PSV_CRG_AMT > (llsav_cash - lluse_cash)) THEN   
                asRetVal := '1006';   
                asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001416'); -- 잔액이 이전금액보다 작습니다.   
   
                RAISE ERR_HANDLER;   
            END IF;   
       END IF;   
   
       -- 2015/02/10 해지, 폐기된 카드는 환불 불가(환불된 카드는 재 환부 신청이 가능하여 환불 체크 CUT)   
       CASE WHEN lscard_stat = '92' AND lsRefundStat != '99' THEN -- 환불(환불 오류는 제외)   
                 asRetVal := '1007';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '81' THEN -- 해지신청   
                 asRetVal := '1008';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001558'); -- 해지 신청된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '91' THEN -- 해지   
                 asRetVal := '1008';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '99' THEN -- 폐기   
                 asRetVal := '1009';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            ELSE   
                 asRetVal := '0';   
       END CASE;   
   
       BEGIN   
         SELECT CP.CARD_DIV, BM.BRAND_CD, '0000000'   
           INTO lscard_div , lsbrand_cd , lsstor_cd   
           FROM COMPANY_PARA CP   
              , BRAND_MEMB   BM   
          WHERE CP.COMP_CD  = BM.COMP_CD   
            AND BM.COMP_CD  = PSV_COMP_CD   
            AND BM.BRAND_CD = (   
                                SELECT TSMS_BRAND_CD   
                                  FROM PCRM.C_CARD_TYPE     CCT   
                                     , PCRM.C_CARD_TYPE_REP CTR   
                                 WHERE CCT.COMP_CD   = CTR.COMP_CD   
                                   AND CCT.CARD_TYPE = CTR.CARD_TYPE   
                                   AND CTR.COMP_CD   = PSV_COMP_CD   
                                   AND decrypt(lsCardIdSend) BETWEEN decrypt(CTR.START_CARD_CD) AND decrypt(CTR.CLOSE_CARD_CD)   
                                   AND ROWNUM        = 1   
                              )   
            AND USE_YN      = 'Y'; -- 사용여부[Y:사용, N:사용안함]   
       EXCEPTION   
         WHEN OTHERS THEN   
              lscard_div := '1';   
              lsbrand_cd := '0000';   
              lsstor_cd  := '0000000';   
       END;   
    END IF;   
   
    -- 양수카드 체크   
    IF PSV_CRG_FG = '4' THEN   
       SELECT COUNT(*), MAX(CARD_STAT), MAX(CUST_ID), MAX(SAV_CASH), MAX(USE_CASH), MAX(ISSUE_DIV)   
         INTO nRecCnt,  lscard_stat,    lsCustId,     llsav_cash,    lluse_cash,    lsissue_div   
         FROM PCRM.C_CARD -- 멤버십카드 마스터   
        WHERE COMP_CD    = PSV_COMP_CD   
          AND CARD_ID    = lsCardIdRecv   
          AND USE_YN     = 'Y'; -- 사용여부[Y:사용, N:사용안함]   
   
       IF nRecCnt = 0 THEN   
          asRetVal := '1020';   
          asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001394'); -- 등록하지 않은 카드번호 입니다.   
   
          RAISE ERR_HANDLER;   
       END IF;   
   
       -- 2015/02/10 분신된 카드는 충전, 취소, 조정 불가   
       CASE WHEN lscard_stat = '90' THEN -- 분실신고   
                 asRetVal := '1021';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001396'); -- 분실신고된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '81' THEN -- 해지신청   
                 asRetVal := '1022';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지 신청된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '91' THEN -- 해지   
                 asRetVal := '1022';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001397'); -- 해지된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '92' THEN -- 환불   
                 asRetVal := '1023';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001414'); -- 환불된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            WHEN lscard_stat = '99' THEN -- 폐기   
                 asRetVal := '1024';   
                 asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001398'); -- 폐기된 카드번호 입니다.   
   
                 RAISE ERR_HANDLER;   
            ELSE   
                 asRetVal := '0';   
       END CASE;   
   
       IF llsav_cash = 0 AND lluse_cash = 0 THEN       -- 충전금액과 사용금액이 0이면   
          SELECT COUNT(*)   
            INTO nRecCnt   
            FROM PCRM.C_CARD_CHARGE_HIS A           -- 멤버십카드 충전이력   
           WHERE COMP_CD      = PSV_COMP_CD   
             AND CARD_ID      = lsCardIdRecv   
             AND CRG_FG       IN('1', '4', '9')     -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정]   
             AND USE_YN       = 'Y'                 -- 사용여부[Y:사용, N:사용안함]   
             AND NOT EXISTS (                       -- 취소내역이 있을 경우 제외   
                             SELECT 1   
                               FROM PCRM.C_CARD_CHARGE_HIS B   
                              WHERE B.COMP_CD     = A.COMP_CD   
                                AND B.CARD_ID     = A.CARD_ID   
                                AND B.ORG_CRG_DT  = A.CRG_DT   
                                AND B.ORG_CRG_SEQ = A.ORG_CRG_SEQ   
                                AND B.CRG_FG      = '2' -- 결제구분[1:충전, 2:취소, 3:환불, 4:이전, 9:조정]   
                                AND B.USE_YN      = 'Y' -- 사용여부[Y:사용, N:사용안함]   
                             );   
   
          IF nRecCnt = 0 THEN -- 카드단위로 최초충전 시   
             BEGIN   
               SELECT TO_NUMBER(VAL_C1)   
                 INTO llstamp_tax   
                 FROM COMMON   
                WHERE CODE_TP     = '01711' -- 선불카드 인지세 금액구간   
                  AND PSV_CRG_AMT BETWEEN VAL_N1 AND VAL_N2   
                  AND USE_YN      = 'Y';    -- 사용여부[Y:사용, N:사용안함]   
             EXCEPTION   
               WHEN OTHERS THEN   
                    llstamp_tax := 0;   
             END;   
          END IF;   
       END IF;   
    END IF;   
   
    -- 양도/환불 이력 작성   
    INSERT INTO PCRM.C_CARD_CHARGE_HIS   
    (   
        COMP_CD     ,       CARD_ID     ,   
        CRG_DT      ,   
        CRG_SEQ     ,   
        CRG_FG      ,       CRG_DIV     ,   
        CRG_AMT     ,   
        CHANNEL     ,   
        BRAND_CD    ,       STOR_CD     ,   
        REMARKS     ,   
        TRN_CARD_ID ,   
        POS_NO      ,   
        CARD_NO     ,       CARD_NM     ,   
        APPR_DT     ,       APPR_TM     ,   
        APPR_VD_CD  ,       APPR_VD_NM  ,   
        APPR_IS_CD  ,       APPR_COM    ,   
        ALLOT_LMT   ,   
        READ_DIV    ,       APPR_DIV    ,   
        APPR_NO     ,   
        ORG_CRG_DT  ,       ORG_CRG_SEQ ,   
        STAMP_TAX   ,       USE_YN      ,   
        SAP_IF_YN   ,       SAP_IF_DT   ,   
        CRG_SCOPE   ,       CRG_AUTO_DIV,   
        DC_AMT      ,       SELF_CRG_YN ,   
        DST_CRG_DT  ,       DST_CRG_SEQ ,   
        INST_DT     ,       INST_USER   ,   
        UPD_DT      ,       UPD_USER   
    )   
    VALUES   
    (   
        PSV_COMP_CD ,       lsCardIdSend,   
        PSV_CRG_DT  ,   
        SQ_PCRM_SEQ.NEXTVAL             ,   
        PSV_CRG_FG  ,       PSV_CRG_DIV ,   
        CASE WHEN PSV_CRG_FG = '3' THEN PSV_CRG_AMT ELSE PSV_CRG_AMT * (-1) END,   
        PSV_CHANNEL ,   
        lsbrand_cd  ,       lsstor_cd   ,   
        GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),   
        lsCardIdRecv,   
        NULL        ,   
        NULL        ,     NULL  ,   
        TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS'),   
        NULL        ,     NULL  ,   
        NULL        ,     NULL  ,   
        NULL        ,   
        NULL        ,     NULL  ,   
        NULL        ,   
        NULL        ,     NULL  ,   
        0           ,     'Y'   ,  -- 양수자 인지세 NG   
        'N'         ,     NULL  ,   
        '1'         ,     '1'   , -- 개별충전, 자동충전여부   
        0           ,     'N'   , -- 할인금액, 셀프충전여부   
        NULL        ,     0     , -- 멀티충전일, 멀티충전일련번호   
        SYSDATE     ,     'SYS' ,   
        SYSDATE     ,     'SYS'   
    );   
   
    -- 양수이력 작성(결제구분[3:환불, 4:이전]이 4:이전 일때만)   
    IF PSV_CRG_FG = '4' THEN   
       INSERT INTO PCRM.C_CARD_CHARGE_HIS   
       (   
           COMP_CD     ,       CARD_ID     ,   
           CRG_DT      ,   
           CRG_SEQ     ,   
           CRG_FG      ,       CRG_DIV     ,   
           CRG_AMT     ,   
           CHANNEL     ,   
           BRAND_CD    ,       STOR_CD     ,   
           REMARKS     ,   
           TRN_CARD_ID ,   
           POS_NO      ,   
           CARD_NO     ,       CARD_NM     ,   
           APPR_DT     ,       APPR_TM     ,   
           APPR_VD_CD  ,       APPR_VD_NM  ,   
           APPR_IS_CD  ,       APPR_COM    ,   
           ALLOT_LMT   ,   
           READ_DIV    ,       APPR_DIV    ,   
           APPR_NO     ,   
           ORG_CRG_DT  ,       ORG_CRG_SEQ ,   
           STAMP_TAX   ,       USE_YN      ,   
           SAP_IF_YN   ,       SAP_IF_DT   ,   
           CRG_SCOPE   ,       CRG_AUTO_DIV,   
           DC_AMT      ,       SELF_CRG_YN ,   
           DST_CRG_DT  ,       DST_CRG_SEQ ,   
           INST_DT     ,       INST_USER   ,   
           UPD_DT      ,       UPD_USER   
       )   
       VALUES   
       (   
           PSV_COMP_CD ,       lsCardIdRecv,   
           PSV_CRG_DT  ,   
           SQ_PCRM_SEQ.NEXTVAL             ,   
           PSV_CRG_FG  ,       PSV_CRG_DIV ,   
           PSV_CRG_AMT ,   
           PSV_CHANNEL ,   
           lsbrand_cd  ,       lsstor_cd   ,   
           GET_COMMON_CODE_NM('01735', PSV_CRG_FG, PSV_LANG_TP),   
           lsCardIdSend,   
           NULL        ,   
           NULL        ,     NULL  ,   
           TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS'),   
           NULL        ,     NULL  ,   
           NULL        ,     NULL  ,   
           NULL        ,   
           NULL        ,     NULL  ,   
           NULL        ,   
           NULL        ,     NULL  ,   
           llstamp_tax ,     'Y'   ,        -- 양수자 최초 중전이 경우 인지세 OK   
           'N'         ,    NULL   ,   
           '1'         ,     '1'   ,        -- 개별충전, 자동충전여부   
            0          ,     'N'   ,        -- 할인금액, 셀프충전여부   
            NULL       ,     0     ,        -- 멀티충전일, 멀티충전일련번호   
           SYSDATE     ,     'SYS' ,   
           SYSDATE     ,     'SYS'   
       );   
    END IF;   
   
    -- 환불 시 카드번호 은행정보 SET   
    IF PSV_CRG_FG = '3' THEN   
        -- 회원 현재 정보 취득   
        SELECT  CUST_ID    ,   
                CARD_STAT  ,   
                REP_CARD_YN   
        INTO    lsCustId, lsCard_stat, lsRepCardYn   
        FROM    C_CARD   
        WHERE   COMP_CD = PSV_COMP_CD   
        AND     CARD_ID = lsCardIdSend;   
   
        IF lsCustId IS NOT NULL THEN   
            SELECT  COUNT(*) INTO nRecCnt   
            FROM    C_CARD   
            WHERE   COMP_CD  = PSV_COMP_CD   
            AND     CUST_ID  = lsCustId   
            AND     CARD_ID != lsCardIdSend   
            AND     CARD_STAT IN ('00', '10')   
            AND     USE_YN   = 'Y';   
        END IF;   
   
        UPDATE PCRM.C_CARD   
           SET CARD_STAT     = '92'   
            ,  REFUND_REQ_DT = PSV_CRG_DT||TO_CHAR(SYSDATE, 'HH24MISS')   
            ,  BANK_CD       = PSV_ACC_BANK   
            ,  ACC_NO        = lsAccNo   
            ,  BANK_USER_NM  = lsBankUserNm   
            ,  REFUND_STAT   = '01'   
            ,  REFUND_CASH   = PSV_CRG_AMT   
            ,  REFUND_CD     = NULL   
            ,  REFUND_MSG    = NULL   
            ,  REP_CARD_YN   = CASE WHEN lsRepCardYn = 'Y' THEN 'N' ELSE 'N' END   
            ,  UPD_DT        = SYSDATE   
            ,  UPD_USER      = CASE WHEN PSV_CHANNEL = '1' THEN 'POS USER'   
                                    WHEN PSV_CHANNEL = '2' THEN 'WEB USER'   
                                    WHEN PSV_CHANNEL = '3' THEN 'APP USER'   
                                    ELSE                        'ADMIN'   
                               END   
       WHERE   COMP_CD       = PSV_COMP_CD   
         AND   CARD_ID       = lsCardIdSend;   
   
   
       IF nRecCnt > 0 AND lsRepCardYn = 'Y' THEN   
            UPDATE  C_CARD   
            SET     REP_CARD_YN = 'Y'   
            WHERE   COMP_CD = PSV_COMP_CD   
            AND     CARD_ID = (   
                                SELECT  CARD_ID   
                                FROM   (   
                                        SELECT  CARD_ID   
                                             ,  ROW_NUMBER() OVER(PARTITION BY CUST_ID ORDER BY ISSUE_DT DESC) R_NUM   
                                        FROM    C_CARD   
                                        WHERE   COMP_CD  = PSV_COMP_CD   
                                        AND     CUST_ID  = lsCustId   
                                        AND     CARD_ID != lsCardIdSend   
                                        AND     CARD_STAT IN ('00', '10')   
                                        AND     USE_YN   = 'Y'   
                                       )   
                               WHERE    R_NUM = 1   
                              );   
        END IF;   
    END IF;   
   
    COMMIT;   
   
    asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392'); -- 정상처리 되었습니다.   
   
    RETURN;   
  EXCEPTION   
    WHEN ERR_HANDLER THEN   
        ROLLBACK;   
        RETURN;   
    WHEN OTHERS THEN   
        asRetVal := '2001';   
        asRetMsg := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')||'['||SQLERRM||']'; -- 오류가 발생하였습니다.   
   
        ROLLBACK;   
        RETURN;   
  END SP_CUST1100M0;

/
