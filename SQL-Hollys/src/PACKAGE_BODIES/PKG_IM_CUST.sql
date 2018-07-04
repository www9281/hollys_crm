--------------------------------------------------------
--  DDL for Package Body PKG_IM_CUST
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_IM_CUST" AS   
--------------------------------------------------------------------------------   
--  Procedure Name   : SET_CRETE_USER_INFO   
--  Description      : 회원/카드정보 동기화   
--  Ref. Table       : C_CUST 회원 마스터   
--                     C_CARD 멤버십카드 마스터   
--------------------------------------------------------------------------------   
--  Create Date      : 2017-05-29 엠즈씨드 CRM PJT   
--  Modify Date      :   
--------------------------------------------------------------------------------   
    PROCEDURE SET_CREATE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_CRT_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    CURSOR CUR_2 IS
        SELECT  *
        FROM    IM_CRT_USER_CARD
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCRD_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCRD_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CARD_STAT      C_CARD.CARD_STAT%TYPE;
    vCRD_REF_STAT       C_CARD.REFUND_STAT%TYPE;
    vCRD_MEMB_DIV       C_CARD.MEMB_DIV%TYPE;
    vREF_CARD_ID        C_CARD.CARD_ID%TYPE;
    vCMP_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCMP_MMB_NO         C_CUST.UNFY_MMB_NO%TYPE;
    
    vCST_BIRTH_DT   DATE;
    
    nCSTRECCNT      NUMBER := 0;
    nCRDRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    nCRDCNT1        NUMBER := 0;
    nCRDEXISTS      NUMBER := 0;
    nREM_CASH       NUMBER := 0;
    nCMPCSTCNT      NUMBER := 0;
    
    bDateCheck      BOOLEAN := true;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '3' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.COOPCO_MMB_ID
                           )
                   )
            WHERE   R_NUM = 1;
            
            -- 통합회원이  모두 있는지 체크 
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), COUNT(*)
            INTO    vCMP_CUST_ID, vCMP_MMB_NO     , nCMPCSTCNT
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = MYCUST.COOPCO_MMB_ID;
            
            -- 생일이 오류이면 강제 '99991231' 세팅
            BEGIN
                vCST_BIRTH_DT := TO_DATE(MYCUST.BTDY, 'YYYYMMDD');
            EXCEPTION
                WHEN OTHERS THEN
                    MYCUST.BTDY := '99991231';
            END;
            
            IF MYCUST.COOPCO_MMB_ID IS NOT NULL AND MYCUST.UNFY_MMB_NO != MYCUST.COOPCO_MMB_ID THEN 
                CASE 
                    WHEN vCST_CUST_STAT IN ('1', '8', '9') THEN
                        vRTNVAL := 'E0347030';
                        vRTNMSG := '이용가능한 회원 상태가 아닙니다.';
                            
                        RAISE ERR_HANDLER;
                    WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != NVL(vCST_UNFY_MMB_NO, 'X') THEN
                        vRTNVAL := 'E0257030';
                        vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                            
                        RAISE ERR_HANDLER;
                    WHEN vCST_CUST_STAT IN ('3', '7') THEN
                        vRTNVAL := 'E0437030';
                        vRTNMSG := '이미 등록된 ID 입니다.';
                            
                        RAISE ERR_HANDLER;
                    WHEN nCSTRECCNT = 0 THEN
                        vRTNVAL := 'N0127030';
                        vRTNMSG := '엠즈씨드 전환회원이 아닙니다.';
                            
                        RAISE ERR_HANDLER;
                    WHEN vCST_CUST_ID != MYCUST.COOPCO_MMB_ID THEN
                        vRTNVAL := 'N0057030';
                        vRTNMSG := MYCUST.COOPCO_MMB_ID||'는 존재 하지 않는 회원 입니다.' ;
                            
                        RAISE ERR_HANDLER;
                    WHEN MYCUST.BTDY IS NULL OR bDateCheck = false THEN
                        vRTNVAL := 'E0177030';
                        vRTNMSG := '(생일) 데이터의 값 또는 형식이 올바르지 않습니다.' ;
                            
                        RAISE ERR_HANDLER;
                    ELSE
                        vRTNVAL := 'S0017030';   
                        vRTNMSG := '성공적으로 수행 되었습니다.';
                END CASE;
            ELSE
                CASE WHEN nCSTRECCNT != 0 THEN
                        vRTNVAL := 'N0187030';
                        vRTNMSG := '기존 회원정보가 존재합니다.';
                            
                        RAISE ERR_HANDLER;
                     WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != NVL(vCST_UNFY_MMB_NO, 'X') THEN
                        vRTNVAL := 'E0257030';
                        vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                            
                        RAISE ERR_HANDLER;
                     WHEN MYCUST.BTDY IS NULL OR bDateCheck = false THEN
                        vRTNVAL := 'E0177030';
                        vRTNMSG := '(생일) 데이터의 값 또는 형식이 올바르지 않습니다.' ;
                            
                        RAISE ERR_HANDLER;

                     ELSE
                        vRTNVAL := 'S0017030';   
                        vRTNMSG := '성공적으로 수행 되었습니다.';   
                END CASE;
            END IF;
            
            
            IF nCSTRECCNT = 0 THEN
                vCST_CUST_ID := MYCUST.UNFY_MMB_NO;
            END IF;
            
            -- C_CUST 작성
            BEGIN
                MERGE INTO C_CUST CST
                USING DUAL
                ON (
                        COMP_CD = PSV_COMP_CD
                    AND CUST_ID = vCST_CUST_ID
                   )
                WHEN MATCHED THEN
                    UPDATE
                    SET     CUST_NM       = encrypt(NVL(MYCUST.MMB_NM, '무명'))
                          , SEX_DIV       = CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                          , LUNAR_DIV     = CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                          , BIRTH_DT      = MYCUST.BTDY
                          , MOBILE        = encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                          , MOBILE_N3     = SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                          , PUSH_RCV_YN   = CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , SMS_RCV_YN    = CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , EMAIL         = MYCUST.EML_ADDR
                          , EMAIL_RCV_YN  = CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , ZIP_CD        = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                          , ADDR1         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                          , ADDR2         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                          , CUST_STAT     = '3'
                          , UPD_DT        = SYSDATE
                          , UPD_USER      = 'IM CRT'
                          , UNFY_MMB_NO   = MYCUST.UNFY_MMB_NO
                WHEN NOT MATCHED THEN
                    INSERT
                   (
                    COMP_CD,        CUST_ID,
                    CUST_NM,        CUST_PW,
                    PW_DIV,         SEX_DIV,
                    LUNAR_DIV,      BIRTH_DT,
                    MOBILE,         MOBILE_N3,
                    M_PIN_NO,       
                    PUSH_RCV_YN,    SMS_RCV_YN,     
                    EMAIL,          EMAIL_RCV_YN,
                    ADDR_DIV,       
                    ZIP_CD,
                    ADDR1,          ADDR2,
                    LVL_CD,         LVL_START_DT,   LVL_CLOSE_DT,   
                    SAV_MLG,        LOS_MLG,
                    MLG_DIV,        MLG_SAV_DT,
                    SAV_PT,         USE_PT,         LOS_PT,
                    SAV_CASH,       USE_CASH,
                    CASH_USE_DT,    CUST_STAT,
                    REMARKS,
                    JOIN_DT,        LEAVE_DT,
                    LEAVE_RMK,      CUST_DIV,
                    BRAND_CD,       STOR_CD,    
                    USE_YN,         DEVICE_TOKEN,    
                    OSKIND,         MOBILE_KIND,
                    IPIN,           CASH_BILL_DIV,
                    CRG_AUTO_DIV,   
                    ISSUE_MOBILE,   ISSUE_BUSI_NO,  
                    RCMD_CUST_ID,   RCMD_DT,
                    INST_DT,        INST_USER,
                    UPD_DT,         UPD_USER,
                    LAST_LOGIN_DT,
                    UNFY_MMB_NO
                   )
                    VALUES
                   (
                    PSV_COMP_CD
                  , vCST_CUST_ID
                  , encrypt(NVL(MYCUST.MMB_NM, '무명'))
                  , GET_SHA1_STR('1212')
                  , 'N'
                  , CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                  , CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                  , MYCUST.BTDY
                  , encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                  , SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                  , NULL
                  , CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , MYCUST.EML_ADDR
                  , CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , 'N'
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                  , '101'       , NULL      , NULL
                  , 0           , 0
                  , 'N'         , NULL
                  , 0           , 0         , 0
                  , 0           , 0
                  , NULL        , '3'
                  , NULL
                  , TO_CHAR(SYSDATE, 'YYYYMMDD')    , NULL
                  , NULL        , '1'
                  , '001'       , '0000000'    
                  , 'Y'         , NULL    
                  , NULL        , NULL
                  , NULL        , '4' 
                  , 'N'   
                  , NULL        , NULL  
                  , NULL        , NULL
                  , SYSDATE     , 'IM CRT'
                  , SYSDATE     , 'IM CRT'
                  , NULL
                  , MYCUST.UNFY_MMB_NO
                   );
            EXCEPTION
                WHEN OTHERS THEN
                    PR_RTN_CD  := 'E0227030';
                    PR_RTN_MSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행도중 ('||SQLERRM||')에러';
   
                    ROLLBACK;   
                    RETURN;   
            END;
            
            FOR MYCARD IN CUR_2 LOOP
                -- 잔여금액 변수
                nREM_CASH := 0;
                
                SELECT  MAX(CRD.CUST_ID), MAX(CST.UNFY_MMB_NO), MAX(CRD.CARD_STAT), MAX(CRD.MEMB_DIV)
                      , MAX(REFUND_STAT), COUNT(*), NVL(SUM(CRD.SAV_CASH - CRD.USE_CASH), 0) 
                INTO    vCRD_CUST_ID, vCRD_UNFY_MMB_NO, vCRD_CARD_STAT,vCRD_MEMB_DIV
                      , vCRD_REF_STAT, nCRDRECCNT, nREM_CASH
                FROM    C_CARD CRD
                      , C_CUST CST
                WHERE   CRD.COMP_CD = CST.COMP_CD(+)
                AND     CRD.CUST_ID = CST.CUST_ID(+) 
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     CRD.CARD_ID = encrypt(MYCARD.CRD_ID);
                
                IF nCRDRECCNT != 0 AND vCRD_UNFY_MMB_NO IS NOT NULL THEN
                    CASE 
                        WHEN  vCST_CUST_ID != vCRD_CUST_ID THEN
                            vRTNVAL := 'E0297030';
                            vRTNMSG := MYCUST.COOPCO_MMB_ID||'는 존재 하지 않는 회원 입니다.' ;
                            
                            RAISE ERR_HANDLER;
                        WHEN vCRD_MEMB_DIV = '1' THEN
                            vRTNVAL := 'E0917030';
                            vRTNMSG := '이미 이전된 상태 입니다.' ;
                            
                            RAISE ERR_HANDLER;
                        WHEN vCRD_CARD_STAT = '92' AND vCRD_REF_STAT IN ('01','99') THEN
                            vRTNVAL := 'E1017030';
                            vRTNMSG := '(환불상태) 이용동의를 처리할 수 없습니다.' ;
                            
                            RAISE ERR_HANDLER;
                        ELSE
                            vRTNVAL := 'S0017030';   
                            vRTNMSG := '성공적으로 수행 되었습니다.';
                    END CASE;
                END IF;
                
                -- 대표카드 여부 체크용
                SELECT  NVL(SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END), 0) INTO nCRDCNT1
                FROM    C_CARD
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = vCST_CUST_ID
                AND     CARD_STAT IN ('10', '20', '90');
                
                -- 충전 또는 이전 시 멤버십 카드가 없을 경우 등록 처리   
                BEGIN
                    MERGE INTO C_CARD
                    USING DUAL
                    ON (
                            COMP_CD = PSV_COMP_CD
                        AND CARD_ID = encrypt(MYCARD.CRD_ID)
                       )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     CARD_STAT       = MYCARD.CRD_ST
                              , REP_CARD_YN     = CASE WHEN MYCARD.CRD_ST != '10' THEN 'N'  ELSE REP_CARD_YN   END
                              , MEMB_DIV        = '1'
                              , UPD_DT          = SYSDATE
                              , UPD_USER        = 'IM CRT'
                    WHEN NOT MATCHED THEN
                        INSERT   
                       (   
                        COMP_CD         , CARD_ID
                      , PIN_NO          , CUST_ID
                      , CARD_STAT       , ISSUE_DIV
                      , IDLE_BRAND_CD   , IDLE_STOR_CD
                      , ISSUE_DT
                      , ISSUE_BRAND_CD  , ISSUE_STOR_CD
                      , LOST_DT         , CLOSE_DT
                      , REFUND_REQ_DT   , BANK_CD
                      , ACC_NO          , BANK_USER_NM
                      , REFUND_DT       , REFUND_STAT
                      , REFUND_CASH     , REFUND_CD     , REFUND_MSG
                      , CANCEL_DT       , DISUSE_DT
                      , REF_CARD_ID     
                      , SAV_MLG         , LOS_MLG
                      , SAV_PT          , USE_PT        , LOS_PT
                      , SAV_CASH        , USE_CASH
                      , REMARKS         , CARD_DIV
                      , BRAND_CD        , STOR_CD
                      , REP_CARD_YN     , USE_YN
                      , INST_DT         , INST_USER
                      , UPD_DT          , UPD_USER
                      , DISP_YN         , MEMB_DIV
                       )   
                        VALUES   
                       (   
                        PSV_COMP_CD     , encrypt(MYCARD.CRD_ID)
                      , NULL            , vCST_CUST_ID
                      , MYCARD.CRD_ST   , '0'
                      , NULL            , NULL
                      , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                      , '001'           , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , '00'
                      , 0               , NULL          , NULL
                      , NULL            , NULL
                      , NULL     
                      , 0               , 0
                      , 0               , 0             , 0
                      , 0               , 0
                      , NULL            , '1'
                      , '001'           , '0000000'
                      , CASE WHEN nCRDCNT1 = 0 THEN 'Y' ELSE 'N' END , 'Y'
                      , SYSDATE         , 'IM CRT'
                      , SYSDATE         , 'IM CRT'
                      , 'N'             , '1'   
                   );
                EXCEPTION   
                    WHEN OTHERS THEN   
                        vRTNVAL := 'E00227030';
                        vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';

                        ROLLBACK;   
                        RAISE ERR_HANDLER;   
                END;
                            
                -- 통합 멤버십으로 이전된 카드의 잔액을 이관 처리함 
                IF MYCUST.COOPCO_MMB_ID IS NOT NULL AND vCST_CUST_STAT = '2' AND vCRD_CARD_STAT IN ('10', '90') AND nREM_CASH != 0 THEN
                    BEGIN
                        --충전이력 작성
                        INSERT INTO C_CARD_CHARGE_HIS   
                       (   
                        COMP_CD     ,       CARD_ID     ,   
                        CRG_DT      ,       CRG_SEQ     ,   
                        CRG_FG      ,       CRG_DIV     ,   
                        CRG_AMT     ,       CHANNEL     ,   
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
                        PSV_COMP_CD                 , encrypt(MYCARD.CRD_ID)
                      , TO_CHAR(SYSDATE, 'YYYYMMDD'), SQ_PCRM_SEQ.NEXTVAL
                      , '6'         ,       '9'   
                      , nREM_CASH*(-1),     '9'   
                      , '001'       ,       '0000000'   
                      , GET_COMMON_CODE_NM('01735', '6', PSV_LANG_TP)
                      , NULL
                      , NULL   
                      , NULL        ,       NULL   
                      , TO_CHAR(SYSDATE, 'YYYYMMDD'), TO_CHAR(SYSDATE, 'HH24MISS')   
                      , NULL        ,       NULL   
                      , NULL        ,       NULL   
                      , NULL   
                      , NULL        ,       NULL   
                      , NULL   
                      , NULL        ,       NULL   
                      , 0           ,       'Y'   
                      , 'N'         ,       NULL   
                      , '1'             ,     '1'          -- 개별충전, 자동충전여부   
                      , 0               ,     'N'          -- 할인금액, 셀프충전여부   
                      , NULL            ,     0            -- 멀티충전일, 멀티충전일련번호   
                      , SYSDATE         ,     'SYS'          
                      , SYSDATE         ,     'SYS'   
                       ); 
                    EXCEPTION   
                        WHEN OTHERS THEN   
                            vRTNVAL := 'E00227030';
                            vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';

                            ROLLBACK;   
                            RAISE ERR_HANDLER;   
                    END;
                END IF;
                
                -- 대표카드 세팅여부 체크
                SELECT  MAX(CARD_ID), NVL(MAX(REP_EXIST_YN), 0)
                INTO    vREF_CARD_ID, nCRDEXISTS
                FROM   (
                        SELECT  CARD_ID
                              , SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END) OVER() REP_EXIST_YN
                              , ROW_NUMBER() OVER(ORDER BY CARD_STAT, INST_DT) R_NUM        
                        FROM    C_CARD
                        WHERE   COMP_CD = PSV_COMP_CD
                        AND     CUST_ID = vCST_CUST_ID
                        AND     CARD_STAT IN ('10', '20', '90')
                       )
                WHERE   R_NUM = 1;
                
                -- 대표카드 설정
                IF nCRDEXISTS = 0 THEN
                    UPDATE  C_CARD
                    SET     REP_CARD_YN = 'Y'
                    WHERE   COMP_CD     = PSV_COMP_CD
                    AND     CARD_ID     = vREF_CARD_ID;
                END IF;
                                        
                -- IM_CRT_USER_CARD 마감처리
                UPDATE  IM_CRT_USER_CARD
                SET     PROC_YN = 'Y'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   TRS_NO  = MYCARD.TRS_NO
                AND     OPN_MD  = MYCARD.OPN_MD
                AND     SST_CD  = MYCARD.SST_CD
                AND     PROC_YN = 'N';
            END LOOP;
            
            -- IM_CRT_USER_INFO 마감처리
            UPDATE  IM_CRT_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_CRT_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
        WHEN OTHERS THEN   
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
   
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_CRT_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_CREATE_USER_INFO;
    
    PROCEDURE DEL_CREATE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_CRT_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        UPDATE  IM_CRT_USER_CARD
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
   
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_CREATE_USER_INFO; 
    
    PROCEDURE SET_DELETE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_DEL_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
        
    CURSOR CUR_2(vCOMP_CD IN VARCHAR2, vCUST_ID IN VARCHAR2) IS
        SELECT  CRD.COMP_CD
              , CRD.CARD_ID
              , HIS.USE_DT
              , HIS.USE_SEQ
              , HIS.SAV_MLG
              , HIS.LOS_MLG
        FROM    C_CARD            CRD
              , C_CARD_SAV_HIS    HIS
        WHERE   HIS.COMP_CD     = CRD.COMP_CD
        AND     HIS.CARD_ID     = CRD.CARD_ID  
        AND     CRD.COMP_CD     = vCOMP_CD
        AND     CRD.CUST_ID     = vCUST_ID
        AND     HIS.LOS_MLG_YN  = 'N';
        
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            CASE 
                WHEN vCST_CUST_STAT IN ('2', '8') THEN
                    vRTNVAL := 'N0247030';
                    vRTNMSG := '폴바셋 회원은 폴바셋 홈페이지에서 탈퇴가 가능합니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT NOT IN ('3', '7') THEN
                    vRTNVAL := 'N0257030';
                    vRTNMSG := '이미 탈퇴한 회원 입니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            -- IM_CRT_USER_CARD 마감처리(트리거에서 카드 폐기함)
            UPDATE  C_CUST
            SET     CUST_STAT = '9'
                  , LEAVE_DT  = TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') 
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = vCST_CUST_ID;
            
            FOR MYCARD IN CUR_2(PSV_COMP_CD, vCST_CUST_ID) LOOP
                -- 탈퇴 회원의 마일리지 소멸
                UPDATE  C_CARD_SAV_HIS
                SET     LOS_MLG    = MYCARD.SAV_MLG -  MYCARD.LOS_MLG
                     ,  LOS_MLG_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')  
                     ,  LOS_MLG_YN = 'Y'
                     ,  UPD_DT     = SYSDATE
                     ,  UPD_USER   = 'IM DEL'
                WHERE   COMP_CD = MYCARD.COMP_CD
                AND     CARD_ID = MYCARD.CARD_ID
                AND     USE_DT  = MYCARD.USE_DT
                AND     USE_SEQ = MYCARD.USE_SEQ;
            END LOOP;
            
            -- IM_CRT_USER_INFO 마감처리
            UPDATE  IM_DEL_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;   
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_DEL_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
        WHEN OTHERS THEN
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXISDeleteUserRegister API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
   
            ROLLBACK;   
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_DEL_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_DELETE_USER_INFO;
    
    PROCEDURE DEL_DELETE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_DEL_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
   
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_DELETE_USER_INFO; 
    
    PROCEDURE SET_AGREE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_AGR_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    CURSOR CUR_2 IS
        SELECT  *
        FROM    IM_AGR_USER_CARD
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCRD_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCRD_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CARD_STAT      C_CARD.CARD_STAT%TYPE;
    vCRD_MEMB_DIV       C_CARD.MEMB_DIV%TYPE;
    vREF_CARD_ID        C_CARD.CARD_ID%TYPE;
    vCMP_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCMP_MMB_NO         C_CUST.UNFY_MMB_NO%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nCRDRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    nCRDCNT1        NUMBER := 0;
    nCRDEXISTS      NUMBER := 0;
    nCMPCSTCNT      NUMBER := 0;
    
    vCST_BIRTH_DT   DATE;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            -- 통합회원이  모두 있는지 체크 
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), COUNT(*)
            INTO    vCMP_CUST_ID, vCMP_MMB_NO     , nCMPCSTCNT
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = MYCUST.COOPCO_MMB_ID;
            
            -- 생일이 오류이면 강제 '99991231' 세팅
            BEGIN
                vCST_BIRTH_DT := TO_DATE(MYCUST.BTDY, 'YYYYMMDD');
            EXCEPTION
                WHEN OTHERS THEN
                    MYCUST.BTDY := '99991231';
            END;
            
            CASE 
                WHEN vCST_UNFY_MMB_NO IS NULL AND vCST_CUST_STAT IN ('1', '8', '9') THEN
                    vRTNVAL := 'E0347030';
                    vRTNMSG := '이용가능한 회원 상태가 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0127030';
                    vRTNMSG := '전환 회원이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != vCST_UNFY_MMB_NO THEN
                    vRTNVAL := 'E0257030';
                    vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT IN ('3', '7') THEN
                    vRTNVAL := 'E0417030';
                    vRTNMSG := '이미 동의한 서비스 사용자 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                WHEN MYCUST.MMB_ST_CD != '1' THEN
                    vRTNVAL := 'N0097030';
                    vRTNMSG := '회원 상태를 변경할 수 없습니다.' ;
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            -- C_CUST 작성
            BEGIN
                MERGE INTO C_CUST CST
                USING DUAL
                ON (
                        COMP_CD = PSV_COMP_CD
                    AND CUST_ID = vCST_CUST_ID
                   )
                WHEN MATCHED THEN
                    UPDATE
                    SET     CUST_NM       = encrypt(NVL(MYCUST.MMB_NM, '무명'))
                          , SEX_DIV       = CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                          , LUNAR_DIV     = CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                          , BIRTH_DT      = MYCUST.BTDY
                          , MOBILE        = encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                          , MOBILE_N3     = SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                          , PUSH_RCV_YN   = CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , SMS_RCV_YN    = CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , EMAIL         = MYCUST.EML_ADDR
                          , EMAIL_RCV_YN  = CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , ZIP_CD        = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                          , ADDR1         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                          , ADDR2         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                          , CUST_STAT     = CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                          , LVL_CD        = CASE WHEN CUST_STAT = '9' THEN '101' ELSE LVL_CD END
                          , LVL_START_DT  = CASE WHEN CUST_STAT = '9' THEN NULL  ELSE LVL_START_DT END
                          , LVL_CLOSE_DT  = CASE WHEN CUST_STAT = '9' THEN NULL  ELSE LVL_CLOSE_DT END
                          , UPD_DT        = SYSDATE
                          , UPD_USER      = 'IM ARG'
                          , UNFY_MMB_NO   = MYCUST.UNFY_MMB_NO
                WHEN NOT MATCHED THEN
                    INSERT
                   (
                    COMP_CD,        CUST_ID,
                    CUST_NM,        CUST_PW,
                    PW_DIV,         SEX_DIV,
                    LUNAR_DIV,      BIRTH_DT,
                    MOBILE,         MOBILE_N3,
                    M_PIN_NO,       
                    PUSH_RCV_YN,    SMS_RCV_YN,     
                    EMAIL,          EMAIL_RCV_YN,
                    ADDR_DIV,       
                    ZIP_CD,
                    ADDR1,          ADDR2,
                    LVL_CD,         LVL_START_DT,   LVL_CLOSE_DT,   
                    SAV_MLG,        LOS_MLG,
                    MLG_DIV,        MLG_SAV_DT,
                    SAV_PT,         USE_PT,         LOS_PT,
                    SAV_CASH,       USE_CASH,
                    CASH_USE_DT,    CUST_STAT,
                    REMARKS,
                    JOIN_DT,        LEAVE_DT,
                    LEAVE_RMK,      CUST_DIV,
                    BRAND_CD,       STOR_CD,    
                    USE_YN,         DEVICE_TOKEN,    
                    OSKIND,         MOBILE_KIND,
                    IPIN,           CASH_BILL_DIV,
                    CRG_AUTO_DIV,   
                    ISSUE_MOBILE,   ISSUE_BUSI_NO,  
                    RCMD_CUST_ID,   RCMD_DT,
                    INST_DT,        INST_USER,
                    UPD_DT,         UPD_USER,
                    LAST_LOGIN_DT,
                    UNFY_MMB_NO
                   )
                    VALUES
                   (
                    PSV_COMP_CD
                  , vCST_CUST_ID
                  , encrypt(NVL(MYCUST.MMB_NM, '무명'))
                  , GET_SHA1_STR('1212')
                  , 'N'
                  , CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                  , CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                  , MYCUST.BTDY
                  , encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                  , SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                  , NULL
                  , CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , MYCUST.EML_ADDR
                  , CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , 'N'
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                  , '101'       , NULL      , NULL
                  , 0           , 0
                  , 'N'         , NULL
                  , 0           , 0         , 0
                  , 0           , 0
                  , NULL        , CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                  , NULL
                  , TO_CHAR(SYSDATE, 'YYYYMMDD')    , NULL
                  , NULL        , '1'
                  , '001'       , '0000000'    
                  , 'Y'         , NULL    
                  , NULL        , NULL
                  , NULL        , '4' 
                  , 'N'   
                  , NULL        , NULL  
                  , NULL        , NULL
                  , SYSDATE     , 'IM AGR'
                  , SYSDATE     , 'IM AGR'
                  , NULL
                  , MYCUST.UNFY_MMB_NO
                   );
            EXCEPTION
                WHEN OTHERS THEN
                    PR_RTN_CD  := 'E0227030';
                    PR_RTN_MSG := '엠즈씨드 서비스사이트 RXAgreeUser API 수행도중 ('||SQLERRM||')에러';
   
                    ROLLBACK;   
                    RETURN;   
            END;
            
            FOR MYCARD IN CUR_2 LOOP
                SELECT  MAX(CRD.CUST_ID), MAX(CST.UNFY_MMB_NO), MAX(CRD.MEMB_DIV), COUNT(*)
                INTO    vCRD_CUST_ID, vCRD_UNFY_MMB_NO, vCRD_MEMB_DIV, nCRDRECCNT
                FROM    C_CARD CRD
                      , C_CUST CST
                WHERE   CRD.COMP_CD = CST.COMP_CD(+)
                AND     CRD.CUST_ID = CST.CUST_ID(+) 
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     CRD.CARD_ID = encrypt(MYCARD.CRD_ID); 
                
                IF nCRDRECCNT != 0 THEN
                    CASE 
                        WHEN  vCST_CUST_ID != vCRD_CUST_ID THEN
                            vRTNVAL := 'E0297030';
                            vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                                
                            RAISE ERR_HANDLER;
                        ELSE
                            vRTNVAL := 'S0017030';   
                            vRTNMSG := '성공적으로 수행 되었습니다.';
                    END CASE;
                END IF;
                
                -- 대표카드 여부 체크용
                SELECT  NVL(SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END), 0) INTO nCRDCNT1
                FROM    C_CARD
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = vCST_CUST_ID
                AND     CARD_STAT IN ('10', '20', '90');
                
                -- 충전 또는 이전 시 멤버십 카드가 없을 경우 등록 처리   
                BEGIN
                    MERGE INTO C_CARD
                    USING DUAL
                    ON (
                            COMP_CD = PSV_COMP_CD
                        AND CARD_ID = encrypt(MYCARD.CRD_ID)
                       )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     CARD_STAT       = MYCARD.CRD_ST
                              , REP_CARD_YN     = CASE WHEN MYCARD.CRD_ST != '10' THEN 'N'  ELSE REP_CARD_YN   END
                              , MEMB_DIV        = '1'
                              , UPD_DT          = SYSDATE
                              , UPD_USER        = 'IM AGR'
                    WHEN NOT MATCHED THEN
                        INSERT   
                       (   
                        COMP_CD         , CARD_ID
                      , PIN_NO          , CUST_ID
                      , CARD_STAT       , ISSUE_DIV
                      , IDLE_BRAND_CD   , IDLE_STOR_CD
                      , ISSUE_DT
                      , ISSUE_BRAND_CD  , ISSUE_STOR_CD
                      , LOST_DT         , CLOSE_DT
                      , REFUND_REQ_DT   , BANK_CD
                      , ACC_NO          , BANK_USER_NM
                      , REFUND_DT       , REFUND_STAT
                      , REFUND_CASH     , REFUND_CD     , REFUND_MSG
                      , CANCEL_DT       , DISUSE_DT
                      , REF_CARD_ID     
                      , SAV_MLG         , LOS_MLG
                      , SAV_PT          , USE_PT        , LOS_PT
                      , SAV_CASH        , USE_CASH
                      , REMARKS         , CARD_DIV
                      , BRAND_CD        , STOR_CD
                      , REP_CARD_YN     , USE_YN
                      , INST_DT         , INST_USER
                      , UPD_DT          , UPD_USER
                      , DISP_YN         , MEMB_DIV
                       )   
                        VALUES   
                       (   
                        PSV_COMP_CD     , encrypt(MYCARD.CRD_ID)
                      , NULL            , vCST_CUST_ID
                      , MYCARD.CRD_ST   , '0'
                      , NULL            , NULL
                      , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                      , '001'           , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , '00'
                      , 0               , NULL          , NULL
                      , NULL            , NULL
                      , NULL     
                      , 0               , 0
                      , 0               , 0             , 0
                      , 0               , 0
                      , NULL            , '1'
                      , '001'           , '0000000'
                      , CASE WHEN nCRDCNT1 = 0 THEN 'Y' ELSE 'N' END , 'Y'
                      , SYSDATE         , 'IM AGR'
                      , SYSDATE         , 'IM AGR'
                      , 'N'             , '1'
                   );
                EXCEPTION   
                    WHEN OTHERS THEN   
                        vRTNVAL := 'E00227030';
                        vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';

                        ROLLBACK;   
                        RAISE ERR_HANDLER;   
                END;
                
                -- IM_AGR_USER_CARD 마감처리
                UPDATE  IM_AGR_USER_CARD
                SET     PROC_YN = 'Y'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   TRS_NO  = MYCARD.TRS_NO
                AND     OPN_MD  = MYCARD.OPN_MD
                AND     SST_CD  = MYCARD.SST_CD
                AND     PROC_YN = 'N';
            END LOOP;
            
            -- 대표카드 세팅여부 체크
            SELECT  MAX(CARD_ID), NVL(MAX(REP_EXIST_YN), 0)
            INTO    vREF_CARD_ID, nCRDEXISTS
            FROM   (
                    SELECT  CARD_ID
                          , SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END) OVER() REP_EXIST_YN
                          , ROW_NUMBER() OVER(ORDER BY CARD_STAT, INST_DT) R_NUM        
                    FROM    C_CARD
                    WHERE   COMP_CD = PSV_COMP_CD
                    AND     CUST_ID = vCST_CUST_ID
                    AND     CARD_STAT IN ('10', '20', '90')
                   )
            WHERE   R_NUM = 1;
                
            -- 대표카드 설정
            IF nCRDEXISTS = 0 THEN
                UPDATE  C_CARD
                SET     REP_CARD_YN = 'Y'
                WHERE   COMP_CD     = PSV_COMP_CD
                AND     CARD_ID     = vREF_CARD_ID;
            END IF;
                
            -- IM_AGR_USER_INFO 마감처리
            UPDATE  IM_AGR_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_AGR_USER_INFO', vRTNVAL, vRTNMSG);
               
            RETURN;   
        WHEN OTHERS THEN
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXAgreeUser API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
   
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_AGR_USER_INFO', vRTNVAL, vRTNMSG);
               
            RETURN;   
    END SET_AGREE_USER_INFO;
    
    PROCEDURE DEL_AGREE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_AGR_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        UPDATE  IM_AGR_USER_CARD
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
   
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_AGREE_USER_INFO; 

    PROCEDURE SET_SST_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2, -- 7. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_SST_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
        
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            CASE 
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0247030';
                    vRTNMSG := '폴바셋 회원은 폴바셋 홈페이지에서 탈퇴가 가능합니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT NOT IN ('3', '7') THEN
                    vRTNVAL := 'N0367030';
                    vRTNMSG := '탈퇴 가능한 회원 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            -- IM_CRT_USER_INFO 마감처리
            UPDATE  IM_SST_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
            
            OPEN PR_RESULT FOR
                SELECT  'Y' ISDEL_YN
                      , '탈퇴 가능한 회원 입니다.'  ISDEL_MSG
                FROM DUAL;
        END LOOP;
   
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN
            OPEN PR_RESULT FOR
                SELECT  'N' ISDEL_YN
                      , '탈퇴 가능한 회원 아닙니다.'  ISDEL_MSG
                FROM DUAL;
                   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_SST_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  'N' ISDEL_YN
                      , '탈퇴 가능한 회원 아닙니다.'  ISDEL_MSG
                FROM DUAL;
            
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXISDisagreeAvailableSST API 수행도중 ('||SQLERRM||')에러';
            
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
                   
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_SST_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_SST_USER_INFO;
    
    PROCEDURE DEL_SST_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_SST_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_SST_USER_INFO; 

    PROCEDURE SET_DISAGREE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_DIS_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
        
    CURSOR CUR_2(vCOMP_CD IN VARCHAR2, vCUST_ID IN VARCHAR2) IS
        SELECT  CRD.COMP_CD
              , CRD.CARD_ID
              , HIS.USE_DT
              , HIS.USE_SEQ
              , HIS.SAV_MLG
              , HIS.LOS_MLG
        FROM    C_CARD            CRD
              , C_CARD_SAV_HIS    HIS
        WHERE   HIS.COMP_CD     = CRD.COMP_CD
        AND     HIS.CARD_ID     = CRD.CARD_ID  
        AND     CRD.COMP_CD     = vCOMP_CD
        AND     CRD.CUST_ID     = vCUST_ID
        AND     HIS.LOS_MLG_YN  = 'N';
        
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            CASE 
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0127030';
                    vRTNMSG := '전환 회원이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_UNFY_MMB_NO IS NULL AND vCST_CUST_STAT != '2' THEN
                    vRTNVAL := 'E0737030';
                    vRTNMSG := '이용 가능한 회원 상태가 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_UNFY_MMB_NO IS NOT NULL AND vCST_CUST_STAT NOT IN ('3', '7') THEN
                    vRTNVAL := 'N0427030';
                    vRTNMSG := '이미 철회한 시비스 사용자입니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            -- IM_CRT_USER_CARD 마감처리(트리거에서 카드 폐기함)
            UPDATE  C_CUST
            SET     CUST_STAT = '9'
                  , LEAVE_DT  = MYCUST.AGRM_END_DTM 
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = vCST_CUST_ID;
            
            FOR MYCARD IN CUR_2(PSV_COMP_CD, vCST_CUST_ID) LOOP
                -- 탈퇴 회원의 마일리지 소멸
                UPDATE  C_CARD_SAV_HIS
                SET     LOS_MLG    = MYCARD.SAV_MLG -  MYCARD.LOS_MLG
                     ,  LOS_MLG_DT = TO_CHAR(SYSDATE, 'YYYYMMDD')  
                     ,  LOS_MLG_YN = 'Y'
                     ,  UPD_DT     = SYSDATE
                     ,  UPD_USER   = 'IM DEL'
                WHERE   COMP_CD = MYCARD.COMP_CD
                AND     CARD_ID = MYCARD.CARD_ID
                AND     USE_DT  = MYCARD.USE_DT
                AND     USE_SEQ = MYCARD.USE_SEQ;
            END LOOP;
            
            -- IM_CRT_USER_INFO 마감처리
            UPDATE  IM_DIS_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_DIS_USER_INFO', vRTNVAL, vRTNMSG);
               
            RETURN;   
        WHEN OTHERS THEN
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXISDeleteUserRegister API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
            
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_DIS_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_DISAGREE_USER_INFO;

    PROCEDURE DEL_DISAGREE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_DIS_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_DISAGREE_USER_INFO; 
    
    PROCEDURE SET_UPDATE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_UPD_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    CURSOR CUR_2 IS
        SELECT  *
        FROM    IM_UPD_USER_CARD
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCRD_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCRD_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CARD_STAT      C_CARD.CARD_STAT%TYPE;
    vREF_CARD_ID        C_CARD.CARD_ID%TYPE;
    vCMP_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCMP_MMB_NO         C_CUST.UNFY_MMB_NO%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nCRDRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    nCRDCNT1        NUMBER := 0;
    nCRDEXISTS      NUMBER := 0;
    nCMPCSTCNT      NUMBER := 0;
    
    vCST_BIRTH_DT   DATE;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            -- 통합회원이  모두 있는지 체크 
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), COUNT(*)
            INTO    vCMP_CUST_ID, vCMP_MMB_NO     , nCMPCSTCNT
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = MYCUST.COOPCO_MMB_ID;
            
            -- 생일이 오류이면 강제 '99991231' 세팅
            BEGIN
                vCST_BIRTH_DT := TO_DATE(MYCUST.BTDY, 'YYYYMMDD');
            EXCEPTION
                WHEN OTHERS THEN
                    MYCUST.BTDY := '99991231';
            END;
            
            CASE 
                WHEN vCST_UNFY_MMB_NO IS NULL AND vCST_CUST_STAT IN ('1', '8', '9') THEN
                    vRTNVAL := 'E0347030';
                    vRTNMSG := '이용가능한 회원 상태가 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0127030';
                    vRTNMSG := '전환 회원이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != vCST_UNFY_MMB_NO THEN
                    vRTNVAL := 'E0257030';
                    vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                WHEN MYCUST.MMB_ST_CD = '0' THEN
                    vRTNVAL := 'N0097030';
                    vRTNMSG := '회원 상태를 변경할 수 없습니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            
            -- C_CUST 작성
            BEGIN
                MERGE INTO C_CUST CST
                USING DUAL
                ON (
                        COMP_CD = PSV_COMP_CD
                    AND CUST_ID = vCST_CUST_ID
                   )
                WHEN MATCHED THEN
                    UPDATE
                    SET     CUST_NM       = encrypt(NVL(MYCUST.MMB_NM, '무명'))
                          , SEX_DIV       = CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                          , LUNAR_DIV     = CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                          , BIRTH_DT      = MYCUST.BTDY
                          , MOBILE        = encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                          , MOBILE_N3     = SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                          , PUSH_RCV_YN   = CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , SMS_RCV_YN    = CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , EMAIL         = MYCUST.EML_ADDR
                          , EMAIL_RCV_YN  = CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , ZIP_CD        = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                          , ADDR1         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                          , ADDR2         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                          , CUST_STAT     = CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                          , UPD_DT        = SYSDATE
                          , UPD_USER      = 'IM CRT'
                          , UNFY_MMB_NO   = MYCUST.UNFY_MMB_NO
                WHEN NOT MATCHED THEN
                    INSERT
                   (
                    COMP_CD,        CUST_ID,
                    CUST_NM,        CUST_PW,
                    PW_DIV,         SEX_DIV,
                    LUNAR_DIV,      BIRTH_DT,
                    MOBILE,         MOBILE_N3,
                    M_PIN_NO,       
                    PUSH_RCV_YN,    SMS_RCV_YN,     
                    EMAIL,          EMAIL_RCV_YN,
                    ADDR_DIV,       
                    ZIP_CD,
                    ADDR1,          ADDR2,
                    LVL_CD,         LVL_START_DT,   LVL_CLOSE_DT,   
                    SAV_MLG,        LOS_MLG,
                    MLG_DIV,        MLG_SAV_DT,
                    SAV_PT,         USE_PT,         LOS_PT,
                    SAV_CASH,       USE_CASH,
                    CASH_USE_DT,    CUST_STAT,
                    REMARKS,
                    JOIN_DT,        LEAVE_DT,
                    LEAVE_RMK,      CUST_DIV,
                    BRAND_CD,       STOR_CD,    
                    USE_YN,         DEVICE_TOKEN,    
                    OSKIND,         MOBILE_KIND,
                    IPIN,           CASH_BILL_DIV,
                    CRG_AUTO_DIV,   
                    ISSUE_MOBILE,   ISSUE_BUSI_NO,  
                    RCMD_CUST_ID,   RCMD_DT,
                    INST_DT,        INST_USER,
                    UPD_DT,         UPD_USER,
                    LAST_LOGIN_DT,
                    UNFY_MMB_NO
                   )
                    VALUES
                   (
                    PSV_COMP_CD
                  , vCST_CUST_ID
                  , encrypt(NVL(MYCUST.MMB_NM, '무명'))
                  , GET_SHA1_STR('1212')
                  , 'N'
                  , CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                  , CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                  , MYCUST.BTDY
                  , encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                  , SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                  , NULL
                  , CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , MYCUST.EML_ADDR
                  , CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , 'N'
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                  , '101'       , NULL      , NULL
                  , 0           , 0
                  , 'N'         , NULL
                  , 0           , 0         , 0
                  , 0           , 0
                  , NULL        , CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                  , NULL
                  , TO_CHAR(SYSDATE, 'YYYYMMDD')    , NULL
                  , NULL        , '1'
                  , '001'       , '0000000'    
                  , 'Y'         , NULL    
                  , NULL        , NULL
                  , NULL        , '4' 
                  , 'N'   
                  , NULL        , NULL  
                  , NULL        , NULL
                  , SYSDATE     , 'IM CRT'
                  , SYSDATE     , 'IM CRT'
                  , NULL
                  , MYCUST.UNFY_MMB_NO
                   );
            EXCEPTION
                WHEN OTHERS THEN
                    PR_RTN_CD  := 'E0227030';
                    PR_RTN_MSG := '엠즈씨드 서비스사이트 RXAgreeUser API 수행도중 ('||SQLERRM||')에러';
   
                    ROLLBACK;   
                    RETURN;   
            END;
            
            FOR MYCARD IN CUR_2 LOOP
                SELECT  MAX(CRD.CUST_ID), MAX(CST.UNFY_MMB_NO), MAX(CRD.CARD_STAT), COUNT(*) 
                INTO    vCRD_CUST_ID, vCRD_UNFY_MMB_NO, vCRD_CARD_STAT, nCRDRECCNT
                FROM    C_CARD CRD
                      , C_CUST CST
                WHERE   CRD.COMP_CD = CST.COMP_CD(+)
                AND     CRD.CUST_ID = CST.CUST_ID(+) 
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     CRD.CARD_ID = encrypt(MYCARD.CRD_ID); 
                
                IF nCRDRECCNT != 0 THEN
                    CASE 
                        WHEN  vCST_CUST_ID != vCRD_CUST_ID THEN
                            vRTNVAL := 'E0297030';
                            vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                                
                            RAISE ERR_HANDLER;
                        WHEN vCRD_CARD_STAT IN ('81','91','92','99') AND MYCARD.CRD_ST NOT IN ('81','91','92','99') THEN
                            vRTNVAL := 'E0237030';
                            vRTNMSG := '해지, 환불, 폐기된 카드는 상태 변경이 불가능합니다.' ;
                                
                            RAISE ERR_HANDLER;
                        ELSE
                            vRTNVAL := 'S0017030';   
                            vRTNMSG := '성공적으로 수행 되었습니다.';
                    END CASE;
                END IF;
                
                -- 대표카드 여부 체크용
                SELECT  NVL(SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END), 0) INTO nCRDCNT1
                FROM    C_CARD
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = vCST_CUST_ID
                AND     CARD_STAT IN ('10', '20', '90');
                
                -- 충전 또는 이전 시 멤버십 카드가 없을 경우 등록 처리   
                BEGIN
                    MERGE INTO C_CARD
                    USING DUAL
                    ON (
                            COMP_CD = PSV_COMP_CD
                        AND CARD_ID = encrypt(MYCARD.CRD_ID)
                       )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     CARD_STAT       = MYCARD.CRD_ST
                              , REP_CARD_YN     = CASE WHEN MYCARD.CRD_ST != '10' THEN 'N'  ELSE REP_CARD_YN   END
                              , MEMB_DIV        = '1'
                              , UPD_DT          = SYSDATE
                              , UPD_USER        = 'IM UPD'
                    WHEN NOT MATCHED THEN
                        INSERT   
                       (   
                        COMP_CD         , CARD_ID
                      , PIN_NO          , CUST_ID
                      , CARD_STAT       , ISSUE_DIV
                      , IDLE_BRAND_CD   , IDLE_STOR_CD
                      , ISSUE_DT
                      , ISSUE_BRAND_CD  , ISSUE_STOR_CD
                      , LOST_DT         , CLOSE_DT
                      , REFUND_REQ_DT   , BANK_CD
                      , ACC_NO          , BANK_USER_NM
                      , REFUND_DT       , REFUND_STAT
                      , REFUND_CASH     , REFUND_CD     , REFUND_MSG
                      , CANCEL_DT       , DISUSE_DT
                      , REF_CARD_ID     
                      , SAV_MLG         , LOS_MLG
                      , SAV_PT          , USE_PT        , LOS_PT
                      , SAV_CASH        , USE_CASH
                      , REMARKS         , CARD_DIV
                      , BRAND_CD        , STOR_CD
                      , REP_CARD_YN     , USE_YN
                      , INST_DT         , INST_USER
                      , UPD_DT          , UPD_USER
                      , DISP_YN         , MEMB_DIV
                       )   
                        VALUES   
                       (   
                        PSV_COMP_CD     , encrypt(MYCARD.CRD_ID)
                      , NULL            , vCST_CUST_ID
                      , MYCARD.CRD_ST   , '0'
                      , NULL            , NULL
                      , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                      , '001'           , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , '00'
                      , 0               , NULL          , NULL
                      , NULL            , NULL
                      , NULL     
                      , 0               , 0
                      , 0               , 0             , 0
                      , 0               , 0
                      , NULL            , '1'
                      , '001'           , '0000000'
                      , CASE WHEN nCRDCNT1 = 0 THEN 'Y' ELSE 'N' END , 'Y'
                      , SYSDATE         , 'IM CRT'
                      , SYSDATE         , 'IM CRT'
                      , 'N'             , '1'
                   );
                EXCEPTION   
                    WHEN OTHERS THEN   
                        vRTNVAL := 'E00227030';
                        vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';

                        ROLLBACK;   
                        RAISE ERR_HANDLER;   
                END;
                
                -- IM_AGR_USER_CARD 마감처리
                UPDATE  IM_UPD_USER_CARD
                SET     PROC_YN = 'Y'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   TRS_NO  = MYCARD.TRS_NO
                AND     OPN_MD  = MYCARD.OPN_MD
                AND     SST_CD  = MYCARD.SST_CD
                AND     PROC_YN = 'N';
            END LOOP;
            
            -- 대표카드 세팅여부 체크
            SELECT  MAX(CARD_ID), NVL(MAX(REP_EXIST_YN), 0)
            INTO    vREF_CARD_ID, nCRDEXISTS
            FROM   (
                    SELECT  CARD_ID
                          , SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END) OVER() REP_EXIST_YN
                          , ROW_NUMBER() OVER(ORDER BY CARD_STAT, INST_DT) R_NUM        
                    FROM    C_CARD
                    WHERE   COMP_CD = PSV_COMP_CD
                    AND     CUST_ID = vCST_CUST_ID
                    AND     CARD_STAT IN ('10', '20', '90')
                   )
            WHERE   R_NUM = 1;
                
            -- 대표카드 설정
            IF nCRDEXISTS = 0 THEN
                UPDATE  C_CARD
                SET     REP_CARD_YN = 'Y'
                WHERE   COMP_CD     = PSV_COMP_CD
                AND     CARD_ID     = vREF_CARD_ID;
            END IF;
                
            -- IM_AGR_USER_INFO 마감처리
            UPDATE  IM_UPD_USER_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_UPD_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN; 
        WHEN OTHERS THEN
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXUpdateUserInfo API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
               
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_UPD_USER_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_UPDATE_USER_INFO;
    
    PROCEDURE DEL_UPDATE_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_UPD_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        UPDATE  IM_UPD_USER_CARD
        SET     PROC_YN = 'X'
              , ERR_CD  = PR_RTN_CD
              , ERR_MSG = PR_RTN_MSG
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
   
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_UPDATE_USER_INFO; 
    
    PROCEDURE SET_UPDATE_STAT_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_UPD_STAT_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    CURSOR CUR_2 IS
        SELECT  *
        FROM    IM_UPD_STAT_CARD
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCRD_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCRD_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vCRD_CARD_STAT      C_CARD.CARD_STAT%TYPE;
    vREF_CARD_ID        C_CARD.CARD_ID%TYPE;
    vCMP_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCMP_MMB_NO         C_CUST.UNFY_MMB_NO%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nCRDRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    nCRDCNT1        NUMBER := 0;
    nCRDEXISTS      NUMBER := 0;
    nCMPCSTCNT      NUMBER := 0;
    
    vCST_BIRTH_DT   DATE;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            -- 통합회원이  모두 있는지 체크 
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), COUNT(*)
            INTO    vCMP_CUST_ID, vCMP_MMB_NO     , nCMPCSTCNT
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = MYCUST.COOPCO_MMB_ID;
            
            -- 생일이 오류이면 강제 '99991231' 세팅
            BEGIN
                vCST_BIRTH_DT := TO_DATE(MYCUST.BTDY, 'YYYYMMDD');
            EXCEPTION
                WHEN OTHERS THEN
                    MYCUST.BTDY := '99991231';
            END;
            
            CASE 
                WHEN vCST_UNFY_MMB_NO IS NULL AND vCST_CUST_STAT IN ('1', '8', '9') THEN
                    vRTNVAL := 'E0347030';
                    vRTNMSG := '이용가능한 회원 상태가 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0127030';
                    vRTNMSG := '전환 회원이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != vCST_UNFY_MMB_NO THEN
                    vRTNVAL := 'E0257030';
                    vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                WHEN MYCUST.MMB_ST_CD = '0' THEN
                    vRTNVAL := 'N0097030';
                    vRTNMSG := '회원 상태를 변경할 수 없습니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            
            -- C_CUST 작성
            BEGIN
                MERGE INTO C_CUST CST
                USING DUAL
                ON (
                        COMP_CD = PSV_COMP_CD
                    AND CUST_ID = vCST_CUST_ID
                   )
                WHEN MATCHED THEN
                    UPDATE
                    SET     CUST_NM       = encrypt(NVL(MYCUST.MMB_NM, '무명'))
                          , SEX_DIV       = CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                          , LUNAR_DIV     = CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                          , BIRTH_DT      = MYCUST.BTDY
                          , MOBILE        = encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                          , MOBILE_N3     = SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                          , PUSH_RCV_YN   = CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , SMS_RCV_YN    = CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , EMAIL         = MYCUST.EML_ADDR
                          , EMAIL_RCV_YN  = CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                          , ZIP_CD        = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                          , ADDR1         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                          , ADDR2         = CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                          , CUST_STAT     = CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                          , UPD_DT        = SYSDATE
                          , UPD_USER      = 'IM UPD'
                          , UNFY_MMB_NO   = MYCUST.UNFY_MMB_NO
                WHEN NOT MATCHED THEN
                    INSERT
                   (
                    COMP_CD,        CUST_ID,
                    CUST_NM,        CUST_PW,
                    PW_DIV,         SEX_DIV,
                    LUNAR_DIV,      BIRTH_DT,
                    MOBILE,         MOBILE_N3,
                    M_PIN_NO,       
                    PUSH_RCV_YN,    SMS_RCV_YN,     
                    EMAIL,          EMAIL_RCV_YN,
                    ADDR_DIV,       
                    ZIP_CD,
                    ADDR1,          ADDR2,
                    LVL_CD,         LVL_START_DT,   LVL_CLOSE_DT,   
                    SAV_MLG,        LOS_MLG,
                    MLG_DIV,        MLG_SAV_DT,
                    SAV_PT,         USE_PT,         LOS_PT,
                    SAV_CASH,       USE_CASH,
                    CASH_USE_DT,    CUST_STAT,
                    REMARKS,
                    JOIN_DT,        LEAVE_DT,
                    LEAVE_RMK,      CUST_DIV,
                    BRAND_CD,       STOR_CD,    
                    USE_YN,         DEVICE_TOKEN,    
                    OSKIND,         MOBILE_KIND,
                    IPIN,           CASH_BILL_DIV,
                    CRG_AUTO_DIV,   
                    ISSUE_MOBILE,   ISSUE_BUSI_NO,  
                    RCMD_CUST_ID,   RCMD_DT,
                    INST_DT,        INST_USER,
                    UPD_DT,         UPD_USER,
                    LAST_LOGIN_DT,
                    UNFY_MMB_NO
                   )
                    VALUES
                   (
                    PSV_COMP_CD
                  , vCST_CUST_ID
                  , encrypt(NVL(MYCUST.MMB_NM, '무명'))
                  , GET_SHA1_STR('1212')
                  , 'N'
                  , CASE WHEN MYCUST.GNDR_DV_CD IN ('1','3') THEN 'M' ELSE 'F' END
                  , CASE WHEN MYCUST.BTDY_LUCR_SOCR_DV_CD = '1' THEN 'S' ELSE 'L' END
                  , MYCUST.BTDY
                  , encrypt(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''))
                  , SUBSTR(REPLACE(MYCUST.WRLS_TEL_NO, '-' ,''), -4)
                  , NULL
                  , CASE WHEN MYCUST.APP_PUSH_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , CASE WHEN MYCUST.SMS_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , MYCUST.EML_ADDR
                  , CASE WHEN MYCUST.EML_RECV_DV_CD = '1' THEN 'Y' ELSE 'N' END
                  , 'N'
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_NO ELSE MYCUST.ZIP_NO END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_BASE_ADDR ELSE MYCUST.ZIP_BASE_ADDR END
                  , CASE WHEN MYCUST.ADDR_FLAG = '1' THEN MYCUST.ROZIP_DTLS_ADDR ELSE MYCUST.ZIP_DTLS_ADDR END
                  , '101'       , NULL      , NULL
                  , 0           , 0
                  , 'N'         , NULL
                  , 0           , 0         , 0
                  , 0           , 0
                  , NULL        , CASE WHEN MYCUST.MMB_ST_CD = '1' THEN '3' WHEN MYCUST.MMB_ST_CD = '9' THEN '7' ELSE '9' END
                  , NULL
                  , TO_CHAR(SYSDATE, 'YYYYMMDD')    , NULL
                  , NULL        , '1'
                  , '001'       , '0000000'    
                  , 'Y'         , NULL    
                  , NULL        , NULL
                  , NULL        , '4' 
                  , 'N'   
                  , NULL        , NULL  
                  , NULL        , NULL
                  , SYSDATE     , 'IM UPD'
                  , SYSDATE     , 'IM UPD'
                  , NULL
                  , MYCUST.UNFY_MMB_NO
                   );
            EXCEPTION
                WHEN OTHERS THEN
                    PR_RTN_CD  := 'E0227030';
                    PR_RTN_MSG := '엠즈씨드 서비스사이트 RXAgreeUser API 수행도중 ('||SQLERRM||')에러';
   
                    ROLLBACK;   
                    RETURN;   
            END;
            
            FOR MYCARD IN CUR_2 LOOP
                SELECT  MAX(CRD.CUST_ID), MAX(CST.UNFY_MMB_NO), MAX(CRD.CARD_STAT), COUNT(*) 
                INTO    vCRD_CUST_ID, vCRD_UNFY_MMB_NO, vCRD_CARD_STAT, nCRDRECCNT
                FROM    C_CARD CRD
                      , C_CUST CST
                WHERE   CRD.COMP_CD = CST.COMP_CD(+)
                AND     CRD.CUST_ID = CST.CUST_ID(+) 
                AND     CRD.COMP_CD = PSV_COMP_CD
                AND     CRD.CARD_ID = encrypt(MYCARD.CRD_ID); 
                
                IF nCRDRECCNT != 0 THEN
                    CASE 
                        WHEN  vCST_CUST_ID != vCRD_CUST_ID THEN
                            vRTNVAL := 'E0297030';
                            vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                                
                            RAISE ERR_HANDLER;
                        WHEN vCRD_CARD_STAT IN ('81','91','92','99') AND MYCARD.CRD_ST NOT IN ('81','91','92','99') THEN
                            vRTNVAL := 'E0237030';
                            vRTNMSG := '해지, 환불, 폐기된 카드는 상태 변경이 불가능합니다.' ;
                                
                            RAISE ERR_HANDLER;
                        ELSE
                            vRTNVAL := 'S0017030';   
                            vRTNMSG := '성공적으로 수행 되었습니다.';
                    END CASE;
                END IF;
                
                -- 대표카드 여부 체크용
                SELECT  NVL(SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END), 0) INTO nCRDCNT1
                FROM    C_CARD
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = vCST_CUST_ID
                AND     CARD_STAT IN ('10', '20', '90');
                
                -- 충전 또는 이전 시 멤버십 카드가 없을 경우 등록 처리   
                BEGIN
                    MERGE INTO C_CARD
                    USING DUAL
                    ON (
                            COMP_CD = PSV_COMP_CD
                        AND CARD_ID = encrypt(MYCARD.CRD_ID)
                       )
                    WHEN MATCHED THEN
                        UPDATE
                        SET     CARD_STAT       = MYCARD.CRD_ST
                              , REP_CARD_YN     = CASE WHEN MYCARD.CRD_ST != '10' THEN 'N'  ELSE REP_CARD_YN   END
                              , MEMB_DIV        = '1'
                              , UPD_DT          = SYSDATE
                              , UPD_USER        = 'IM UPD'
                    WHEN NOT MATCHED THEN
                        INSERT   
                       (   
                        COMP_CD         , CARD_ID
                      , PIN_NO          , CUST_ID
                      , CARD_STAT       , ISSUE_DIV
                      , IDLE_BRAND_CD   , IDLE_STOR_CD
                      , ISSUE_DT
                      , ISSUE_BRAND_CD  , ISSUE_STOR_CD
                      , LOST_DT         , CLOSE_DT
                      , REFUND_REQ_DT   , BANK_CD
                      , ACC_NO          , BANK_USER_NM
                      , REFUND_DT       , REFUND_STAT
                      , REFUND_CASH     , REFUND_CD     , REFUND_MSG
                      , CANCEL_DT       , DISUSE_DT
                      , REF_CARD_ID     
                      , SAV_MLG         , LOS_MLG
                      , SAV_PT          , USE_PT        , LOS_PT
                      , SAV_CASH        , USE_CASH
                      , REMARKS         , CARD_DIV
                      , BRAND_CD        , STOR_CD
                      , REP_CARD_YN     , USE_YN
                      , INST_DT         , INST_USER
                      , UPD_DT          , UPD_USER
                      , DISP_YN         , MEMB_DIV
                       )   
                        VALUES   
                       (   
                        PSV_COMP_CD     , encrypt(MYCARD.CRD_ID)
                      , NULL            , vCST_CUST_ID
                      , MYCARD.CRD_ST   , '0'
                      , NULL            , NULL
                      , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                      , '001'           , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , NULL
                      , NULL            , '00'
                      , 0               , NULL          , NULL
                      , NULL            , NULL
                      , NULL     
                      , 0               , 0
                      , 0               , 0             , 0
                      , 0               , 0
                      , NULL            , '1'
                      , '001'           , '0000000'
                      , CASE WHEN nCRDCNT1 = 0 THEN 'Y' ELSE 'N' END , 'Y'
                      , SYSDATE         , 'IM UPD'
                      , SYSDATE         , 'IM UPD'
                      , 'N'             , '1'
                   );
                EXCEPTION   
                    WHEN OTHERS THEN   
                        vRTNVAL := 'E00227030';
                        vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';

                        ROLLBACK;   
                        RAISE ERR_HANDLER;   
                END;
                
                -- IM_AGR_USER_CARD 마감처리
                UPDATE  IM_UPD_STAT_CARD
                SET     PROC_YN = 'Y'
                WHERE   TRS_NO  = MYCARD.TRS_NO
                AND     OPN_MD  = MYCARD.OPN_MD
                AND     SST_CD  = MYCARD.SST_CD
                AND     PROC_YN = 'N';
            END LOOP;
            
            -- 대표카드 세팅여부 체크
            SELECT  MAX(CARD_ID), NVL(MAX(REP_EXIST_YN), 0)
            INTO    vREF_CARD_ID, nCRDEXISTS
            FROM   (
                    SELECT  CARD_ID
                          , SUM(CASE WHEN REP_CARD_YN = 'Y' THEN 1 ELSE 0 END) OVER() REP_EXIST_YN
                          , ROW_NUMBER() OVER(ORDER BY CARD_STAT, INST_DT) R_NUM        
                    FROM    C_CARD
                    WHERE   COMP_CD = PSV_COMP_CD
                    AND     CUST_ID = vCST_CUST_ID
                    AND     CARD_STAT IN ('10', '20', '90')
                   )
            WHERE   R_NUM = 1;
                
            -- 대표카드 설정
            IF nCRDEXISTS = 0 THEN
                UPDATE  C_CARD
                SET     REP_CARD_YN = 'Y'
                WHERE   COMP_CD     = PSV_COMP_CD
                AND     CARD_ID     = vREF_CARD_ID;
            END IF;
                
            -- IM_AGR_USER_INFO 마감처리
            UPDATE  IM_UPD_STAT_INFO
            SET     PROC_YN = 'Y'
                  , ERR_CD  = vRTNVAL
                  , ERR_MSG = vRTNMSG
            WHERE   TRS_NO  = MYCUST.TRS_NO
            AND     OPN_MD  = MYCUST.OPN_MD
            AND     SST_CD  = MYCUST.SST_CD
            AND     PROC_YN = 'N';
        END LOOP;
   
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_UPD_STAT_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
        WHEN OTHERS THEN
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXUpdateUserStatus API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
               
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_UPD_STAT_INFO', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_UPDATE_STAT_INFO;
    
    PROCEDURE DEL_UPDATE_STAT_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_UPD_STAT_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        UPDATE  IM_UPD_STAT_CARD
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
   
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_UPDATE_STAT_INFO;
    
    PROCEDURE SET_GET_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PSV_TBL_DIV         IN  VARCHAR2, -- 6. 테이블 목록
    PR_RTN_CD           OUT VARCHAR2, -- 7. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2, -- 8. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    IM_GET_USER_INFO
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
        
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    
    vQUERY          VARCHAR2(32000) := '';
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYCUST IN CUR_1 LOOP  
            -- 회원 정보 취득
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), MAX(CUST_STAT), COUNT(*)
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYCUST.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            CASE 
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := 'N0127030';
                    vRTNMSG := '전환 회원이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                    
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := 'N0057030';
                    vRTNMSG := MYCUST.UNFY_MMB_NO||'는 존재 하지 않는 회원 입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := 'S0017030';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            IF PSV_TBL_DIV = 'IM_SBC' THEN
                vQUERY  :=              '   SELECT  UNFY_MMB_NO             AS UNFY_MMB_NO  '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS CUST_NO      '
                    ||CHR(13)||CHR(10)||'         , decrypt(CUST_NM)        AS MMB_NM       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS MMB_ID       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS FRNR_DV_CD   '
                    ||CHR(13)||CHR(10)||'         , BIRTH_DT                AS BTDY         '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN LUNAR_DIV = ''L'' THEN ''2'' ELSE ''1'' END AS BTDY_LUCR_SOCR_DV_CD ' 
                    ||CHR(13)||CHR(10)||'         , CASE WHEN BIRTH_DT LIKE ''1%'' AND SEX_DIV   = ''M'' THEN ''1'''
                    ||CHR(13)||CHR(10)||'                WHEN BIRTH_DT LIKE ''2%'' AND SEX_DIV   = ''M'' THEN ''3'''
                    ||CHR(13)||CHR(10)||'                WHEN BIRTH_DT LIKE ''1%'' AND SEX_DIV   = ''W'' THEN ''2'''
                    ||CHR(13)||CHR(10)||'                WHEN BIRTH_DT LIKE ''2%'' AND SEX_DIV   = ''W'' THEN ''4'''
                    ||CHR(13)||CHR(10)||'           END                     AS GNDR_DV_CD       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SEF_CERT_DI      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SEF_CERT_CI_VER  '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SEF_CERT_CI      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SEF_CERT_DV_CD   '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS NTRY_COOPCO_CD   '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS NTRY_CHNL_CD     '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS NTRY_PATH        '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN CUST_STAT IN (''2'',''3'') THEN ''1'''
                    ||CHR(13)||CHR(10)||'                WHEN CUST_STAT IN (''7'',''8'') THEN ''9'''
                    ||CHR(13)||CHR(10)||'           ELSE ''0'' END          AS MMB_ST_CD        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SOC_ID           '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SOC_KIND_CD      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS SOC_MMB_YN       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS PREM_MMB_YN      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS PREM_MMB_NTRY_DTM'
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STFF_DV_CD       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STFF_EML_ADDR    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STFF_CERT_DT     '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS NTRY_TYP_CD      '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN CUST_ID = UNFY_MMB_NO THEN NULL ELSE CUST_ID END AS COOPCO_MMB_ID '
                    ||CHR(13)||CHR(10)||'         , MOBILE                  AS WRLS_TEL_NO   '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS CBL_TEL_NO       '
                    ||CHR(13)||CHR(10)||'         , EMAIL                   AS EML_ADDR         '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS CRD_NO           '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS CRD_REG_DTM      '
                    ||CHR(13)||CHR(10)||'         , JOIN_DT                 AS REG_DTM          '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS CT_MMB_NO        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STOR_CD          '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STOR_CRD_NO      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STOR_PINT_SWT_YN '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS TOTAL_AGRM_YN    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ADDR_FLAG        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ZIP_NO           '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ZIP_SEQ          '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ZIP_ZONE_NO      '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ZIP_BASE_ADDR    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ZIP_DTLS_ADDR    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_NO         '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_SEQ        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_ZONE_NO    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_BASE_ADDR  '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_DTLS_ADDR  '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_REFN_ADDR  '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_BLD_NO     '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ROZIP_PNU        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS STTR_DONG_CD     '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS ADMST_DONG_CD    '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS PSN_X_CORD       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS PSN_Y_CORD       '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS AGRM_YN          '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS AGRM_DTHR        '
                    ||CHR(13)||CHR(10)||'         , NULL                    AS AGRM_END_DTHR    '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN EMAIL_RCV_YN = ''Y'' THEN ''1'' ELSE ''2'' END AS EML_RECV_DV_CD '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN SMS_RCV_YN   = ''Y'' THEN ''1'' ELSE ''2'' END AS SMS_RECV_DV_CD '
                    ||CHR(13)||CHR(10)||'         , CASE WHEN PUSH_RCV_YN  = ''Y'' THEN ''1'' ELSE ''2'' END AS APP_PUSH_RECV_DV_CD '
                    ||CHR(13)||CHR(10)||'   FROM    C_CUST                  '
                    ||CHR(13)||CHR(10)||'   WHERE   COMP_CD = ''' || PSV_COMP_CD || ''''
                    ||CHR(13)||CHR(10)||'   AND     CUST_ID = ''' || vCST_CUST_ID|| '''';
            ELSIF PSV_TBL_DIV = 'SOC_INFO' THEN            
                vQUERY  :=              '   SELECT  NULL             AS SOC_UNFY_MMB_NO '
                    ||CHR(13)||CHR(10)||'         , NULL             AS SOC_KIND_CD     '
                    ||CHR(13)||CHR(10)||'         , NULL             AS USE_YN          '
                    ||CHR(13)||CHR(10)||'   FROM    DUAL                                ';
            ELSIF PSV_TBL_DIV = 'MMB_BABY' THEN            
                vQUERY  :=              '   SELECT  NULL             AS SEQ_NO              '
                    ||CHR(13)||CHR(10)||'         , NULL             AS BABY_NM             '
                    ||CHR(13)||CHR(10)||'         , NULL             AS BABY_SEQ            '
                    ||CHR(13)||CHR(10)||'         , NULL             AS TWIN_DV_CD          '
                    ||CHR(13)||CHR(10)||'         , NULL             AS BTDY                '
                    ||CHR(13)||CHR(10)||'         , NULL             AS BTDY_LUCR_SOCR_DV_CD'
                    ||CHR(13)||CHR(10)||'         , NULL             AS BABY_GNDR_DV_CD     '
                    ||CHR(13)||CHR(10)||'         , NULL             AS FEDG_TYP_CD         '
                    ||CHR(13)||CHR(10)||'         , NULL             AS USE_YN              '
                    ||CHR(13)||CHR(10)||'   FROM    DUAL                                    ';
            ELSIF PSV_TBL_DIV = 'GIFT_CARD' THEN            
                vQUERY  :=              '   SELECT  decrypt(CARD_ID) AS CRD_ID  '
                    ||CHR(13)||CHR(10)||'         , CARD_STAT        AS CRD_ST  '
                    ||CHR(13)||CHR(10)||'   FROM    C_CARD                      '
                    ||CHR(13)||CHR(10)||'   WHERE   COMP_CD = ''' || PSV_COMP_CD || ''''
                    ||CHR(13)||CHR(10)||'   AND     CUST_ID = ''' || vCST_CUST_ID|| '''';
            END IF;
            
            -- IM_GET_USER_INFO 마감처리
            IF PSV_TBL_DIV = 'GIFT_CARD' THEN
                UPDATE  IM_GET_USER_INFO
                SET     PROC_YN = 'Y'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   TRS_NO  = MYCUST.TRS_NO
                AND     OPN_MD  = MYCUST.OPN_MD
                AND     SST_CD  = MYCUST.SST_CD
                AND     PROC_YN = 'N';
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(vQUERY);
            
            OPEN PR_RESULT FOR vQUERY;
        END LOOP;
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN
            OPEN PR_RESULT FOR
                SELECT  0
                FROM DUAL;
                   
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_GET_USER_INFO', vRTNVAL, vRTNMSG);
               
            RETURN;   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  0
                FROM DUAL;
            
            vRTNVAL := 'E0227030';
            vRTNMSG := '엠즈씨드 서비스사이트 RXGetUserInfo API 수행도중 ('||SQLERRM||')에러';
        
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
                   
            ROLLBACK;
            
            -- 처리결과 메시지 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRS_NO, PSV_OPN_MD, PSV_SST_CD, 'IM_GET_USER_INFO', vRTNVAL, vRTNMSG);
            RETURN;   
    END SET_GET_USER_INFO;
    
    PROCEDURE DEL_GET_USER_INFO   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  IM_GET_USER_INFO
        SET     PROC_YN = 'X'
        WHERE   TRS_NO  = PSV_TRS_NO
        AND     OPN_MD  = PSV_OPN_MD
        AND     SST_CD  = PSV_SST_CD
        AND     PROC_YN = 'N';
    
        COMMIT;   
        
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
    
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            PR_RTN_CD  := SQLCODE;
            PR_RTN_MSG := SQLERRM;
           
            ROLLBACK;   
            RETURN;   
    END DEL_GET_USER_INFO; 
    
    PROCEDURE DEL_TABLE_ERR_SET   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRS_NO          IN  VARCHAR2, -- 3. 트랜잭션번호                
    PSV_OPN_MD          IN  VARCHAR2, -- 4. 운영모드
    PSV_SST_CD          IN  VARCHAR2, -- 5. 서비스사이트코드(7000:매일유업멤버십)
    PSV_TABLE_NM        IN  VARCHAR2, -- 6. 테이블 이름
    PSV_RTN_CD          IN  VARCHAR2, -- 7. 처리코드 
    PSV_RTN_MSG         IN  VARCHAR2  -- 8. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        IF PSV_TABLE_NM = 'IM_CRT_USER_INFO' THEN
            UPDATE  IM_CRT_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        
            UPDATE  IM_CRT_USER_CARD
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_DEL_USER_INFO' THEN
            UPDATE  IM_DEL_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_AGR_USER_INFO' THEN
            UPDATE  IM_AGR_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        
            UPDATE  IM_AGR_USER_CARD
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_SST_USER_INFO' THEN
            UPDATE  IM_SST_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_DIS_USER_INFO' THEN
            UPDATE  IM_DIS_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_UPD_USER_INFO' THEN
            UPDATE  IM_UPD_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        
            UPDATE  IM_UPD_USER_CARD
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_UPD_STAT_INFO' THEN
            UPDATE  IM_UPD_STAT_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        
            UPDATE  IM_UPD_STAT_CARD
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        ELSIF PSV_TABLE_NM = 'IM_GET_USER_INFO' THEN
            UPDATE  IM_GET_USER_INFO
            SET     ERR_CD  = PSV_RTN_CD
                  , ERR_MSG = PSV_RTN_MSG
            WHERE   TRS_NO  = PSV_TRS_NO
            AND     OPN_MD  = PSV_OPN_MD
            AND     SST_CD  = PSV_SST_CD
            AND     PROC_YN = 'N';
        END IF;
        
        COMMIT;   

        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            ROLLBACK;   
            RETURN;   
    END DEL_TABLE_ERR_SET; 
    
END PKG_IM_CUST;

/
