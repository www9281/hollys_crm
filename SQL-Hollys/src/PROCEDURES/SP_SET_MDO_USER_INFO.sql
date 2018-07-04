--------------------------------------------------------
--  DDL for Procedure SP_SET_MDO_USER_INFO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_MDO_USER_INFO" 
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PR_RTN_CD           OUT VARCHAR2, -- 6. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 7. 처리Message      
   ) IS   
    CURSOR CUR_1 IS
        SELECT  *
        FROM    MDO_USER_INFO
        WHERE   PROC_YN = 'N';
    
    CURSOR CUR_2(vUNFY_MMB_NO IN VARCHAR2) IS
        SELECT  *
        FROM    MDO_USER_CARD
        WHERE   UNFY_MMB_NO = vUNFY_MMB_NO
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
    
    nCHKCRDCNT      NUMBER := 0;
    nCHKRECCNT      NUMBER := 0;
    
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
            
            -- 통합회원이 & 전환회원 모두 있는지 체크 
            SELECT  MAX(CUST_ID), MAX(UNFY_MMB_NO), COUNT(*)
            INTO    vCMP_CUST_ID, vCMP_MMB_NO     , nCMPCSTCNT
            FROM    C_CUST
            WHERE   COMP_CD = PSV_COMP_CD
            AND     CUST_ID = MYCUST.COOPCO_MMB_ID;
            
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
                    WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != NVL(vCST_UNFY_MMB_NO, 'X') THEN
                        vRTNVAL := 'E0257030';
                        vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                    WHEN vCST_CUST_STAT IN ('3', '7') THEN
                        vRTNVAL := 'E0437030';
                        vRTNMSG := '이미 등록된 ID 입니다.';
                    WHEN nCSTRECCNT = 0 THEN
                        vRTNVAL := 'N0127030';
                        vRTNMSG := '엠즈씨드 전환회원이 아닙니다.';
                    WHEN vCST_CUST_ID != MYCUST.COOPCO_MMB_ID THEN
                        vRTNVAL := 'N0057030';
                        vRTNMSG := MYCUST.COOPCO_MMB_ID||'는 존재 하지 않는 회원 입니다.' ;
                    WHEN MYCUST.BTDY IS NULL OR bDateCheck = false THEN
                        vRTNVAL := 'E0177030';
                        vRTNMSG := '(생일) 데이터의 값 또는 형식이 올바르지 않습니다.' ;
                    ELSE
                        vRTNVAL := 'S0017030';   
                        vRTNMSG := '성공적으로 수행 되었습니다.';
                END CASE;
            ELSE
                CASE WHEN nCSTRECCNT != 0 THEN
                        vRTNVAL := 'N0187030';
                        vRTNMSG := '기존 회원정보가 존재합니다.';
                     WHEN nCMPCSTCNT !=0 AND NVL(vCMP_MMB_NO, 'X') != NVL(vCST_UNFY_MMB_NO, 'X') THEN
                        vRTNVAL := 'E0257030';
                        vRTNMSG := '(폴바셋)에서 사용 중인 ID입니다.';
                     WHEN MYCUST.BTDY IS NULL OR bDateCheck = false THEN
                        vRTNVAL := 'E0177030';
                        vRTNMSG := '(생일) 데이터의 값 또는 형식이 올바르지 않습니다.' ;
                     ELSE
                        vRTNVAL := 'S0017030';   
                        vRTNMSG := '성공적으로 수행 되었습니다.';   
                END CASE;
            END IF;
            
            
            IF nCSTRECCNT = 0 THEN
                vCST_CUST_ID := MYCUST.UNFY_MMB_NO;
            ELSE
                SELECT COUNT(*) INTO nCHKCRDCNT
                FROM    MDO_USER_CARD
                WHERE   UNFY_MMB_NO = MYCUST.UNFY_MMB_NO
                AND     PROC_YN     = 'N';
                
                IF nCHKCRDCNT = 0 THEN
                    vRTNVAL := 'N0287030';
                    vRTNMSG := '폴바셋 전환회원은 선불카드와 함께 이전해야 합니다.';
                END IF;
            END IF;
            
            IF vRTNVAL = 'S0017030' THEN   
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
                        ROLLBACK;
                        
                        vRTNVAL  := 'E0227030';
                        vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행도중 ('||SQLERRM||')에러';
                        
                        -- 에러처리
                        GOTO ERROR_CST; 
                END;
                
                FOR MYCARD IN CUR_2(MYCUST.UNFY_MMB_NO) LOOP
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
                            WHEN vCRD_MEMB_DIV = '1' THEN
                                vRTNVAL := 'E0917030';
                                vRTNMSG := '이미 이전된 상태 입니다.' ;
                            WHEN vCRD_CARD_STAT = '92' AND vCRD_REF_STAT IN ('01','99') THEN
                                vRTNVAL := 'E1017030';
                                vRTNMSG := '(환불상태) 이용동의를 처리할 수 없습니다.' ;
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
                            ROLLBACK;
                            
                            vRTNVAL := 'E00227030';
                            vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';
                            
                            GOTO ERROR_CRD;
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
                                ROLLBACK;
                                   
                                vRTNVAL := 'E00227030';
                                vRTNMSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행 도중 ('||SQLERRM||') 에러';
                                
                                -- 에러처리
                                GOTO ERROR_CRD; 
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
                    
                    -- MDO_USER_CARD 마감처리
                    UPDATE  MDO_USER_CARD
                    SET     PROC_YN = 'Y'
                          , ERR_CD  = vRTNVAL
                          , ERR_MSG = vRTNMSG
                    WHERE   UNFY_MMB_NO  = MYCARD.UNFY_MMB_NO
                    AND     CRD_ID       = MYCARD.CRD_ID
                    AND     PROC_YN = 'N';
                    
                    CONTINUE;
                    
                    <<ERROR_CRD>>                        
                    -- MDO_USER_CARD 마감처리
                    UPDATE  MDO_USER_CARD
                    SET     PROC_YN = 'E'
                          , ERR_CD  = vRTNVAL
                          , ERR_MSG = vRTNMSG
                    WHERE   UNFY_MMB_NO  = MYCARD.UNFY_MMB_NO
                    AND     CRD_ID       = MYCARD.CRD_ID
                    AND     PROC_YN = 'N';
                END LOOP;
                
                -- MDO_USER_INFO 마감처리
                UPDATE  MDO_USER_INFO
                SET     PROC_YN = 'Y'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   UNFY_MMB_NO  = MYCUST.UNFY_MMB_NO
                AND     PROC_YN = 'N';
                
                CONTINUE;
                
                <<ERROR_CST>>
                -- MDO_USER_INFO 마감처리
                UPDATE  MDO_USER_INFO
                SET     PROC_YN = 'E'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   UNFY_MMB_NO  = MYCUST.UNFY_MMB_NO
                AND     PROC_YN = 'N';
            ELSE
                -- MDO_USER_INFO 마감처리
                UPDATE  MDO_USER_INFO
                SET     PROC_YN = 'E'
                      , ERR_CD  = vRTNVAL
                      , ERR_MSG = vRTNMSG
                WHERE   UNFY_MMB_NO  = MYCUST.UNFY_MMB_NO
                AND     PROC_YN = 'N';
            END IF;
            
            --건별 COMMIT
            COMMIT;
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
            RETURN;   
        WHEN OTHERS THEN   
            PR_RTN_CD  := 'E0227030';
            PR_RTN_MSG := '엠즈씨드 서비스사이트 RXCreateUser API 수행도중 ('||SQLERRM||')에러';
   
            ROLLBACK;   
            RETURN;   
    END SP_SET_MDO_USER_INFO;

/
