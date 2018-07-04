--------------------------------------------------------
--  DDL for Package Body PKG_MDO_IF
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "CRMDEV"."PKG_MDO_IF" AS   
--------------------------------------------------------------------------------   
--  Procedure Name   : SET_USE_MLG   
--  Description      : 크라운 -> 포인트 전환   
--  Ref. Table       : C_CUST 회원 마스터   
--                     C_CARD 멤버십카드 마스터
--                     C_CARD_SAV_USE_PNT   
--------------------------------------------------------------------------------   
--  Create Date      : 2017-05-29 엠즈씨드 CRM PJT   
--  Modify Date      :   
--------------------------------------------------------------------------------   
    PROCEDURE SET_USE_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRSC_TYP_CD     IN  VARCHAR2, -- 3. 거래유형코드                
    PSV_TRSC_BIZ_DV_CD  IN  VARCHAR2, -- 4. 업무구분코드
    PSV_COOPCO_CD       IN  VARCHAR2, -- 5. 제휴사코드
    PSV_TRSC_NO         IN  VARCHAR2, -- 8. 거래고유번호
    PSV_CHNL_TYP_CD     IN  VARCHAR2, -- 7. 채널유형
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2, -- 9. 처리Message         
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    CURSOR CUR_1 IS
        SELECT  MMP.*
              , ROWID RID 
        FROM    MDO_MLG_PNT MMP
        WHERE   TRSC_TYP_CD     = PSV_TRSC_TYP_CD
        AND     TRSC_BIZ_DV_CD  = PSV_TRSC_BIZ_DV_CD
        AND     COOPCO_CD       = PSV_COOPCO_CD
        AND     TRSC_NO         = PSV_TRSC_NO
        AND     PROC_YN = 'N';
    
    vCST_CUST_ID        C_CUST.CUST_ID%TYPE;
    vCST_UNFY_MMB_NO    C_CUST.UNFY_MMB_NO%TYPE;
    vCST_CUST_STAT      C_CUST.CUST_STAT%TYPE;
    vAPPR_DT            C_CARD_SAV_USE_PNT.USE_DT%TYPE;
    vLCL_APV_DT         MDO_MLG_PNT.LCL_APV_DT%TYPE;
    vLCL_APV_NO         MDO_MLG_PNT.LCL_APV_NO%TYPE;
    
    nCSTRECCNT      NUMBER := 0;
    nRECCNT1        NUMBER := 0;
    nUSESEQ         C_CARD_SAV_USE_PNT.USE_SEQ%TYPE := 0;
    nREMMLG         C_CARD_SAV_USE_PNT.USE_MLG%TYPE := 0;
    nCNCMLG         C_CARD_SAV_USE_PNT.USE_MLG%TYPE := 0;
    nUSEMLG         C_CARD_SAV_USE_PNT.USE_MLG%TYPE := 0;
    nLSTMLG         C_CARD_SAV_USE_PNT.USE_MLG%TYPE := 0;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        FOR MYREC IN CUR_1 LOOP
            -- 회원 정보 취득
            SELECT  CUST_ID, UNFY_MMB_NO, CUST_STAT, COUNT(*) OVER()
            INTO    vCST_CUST_ID, vCST_UNFY_MMB_NO, vCST_CUST_STAT, nCSTRECCNT
            FROM   (
                    SELECT  DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                          , ROW_NUMBER() OVER(ORDER BY DATA_DIV) R_NUM
                    FROM   (
                            SELECT  '1' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD     = PSV_COMP_CD
                            AND     UNFY_MMB_NO = MYREC.UNFY_MMB_NO
                            UNION ALL
                            SELECT  '2' DATA_DIV, CUST_ID, UNFY_MMB_NO, CUST_STAT
                            FROM    C_CUST
                            WHERE   COMP_CD = PSV_COMP_CD
                            AND     CUST_ID = MYREC.UNFY_MMB_NO
                           )
                   )
            WHERE   R_NUM = 1;
            
            -- TR 고유 번호로 중복 처리 체크
            SELECT  MAX(LCL_APV_DT), MAX(LCL_APV_NO), COUNT(*) 
            INTO    vLCL_APV_DT, vLCL_APV_NO, nRECCNT1
            FROM    MDO_MLG_PNT
            WHERE   TRSC_TYP_CD     = MYREC.TRSC_TYP_CD
            AND     TRSC_BIZ_DV_CD  = MYREC.TRSC_BIZ_DV_CD
            AND     COOPCO_CD       = MYREC.COOPCO_CD
            AND     TRSC_NO         = MYREC.TRSC_NO
            AND     ROWID          != MYREC.RID
            AND     PROC_YN         = 'Y';
            
            IF nRECCNT1 != 0 THEN
                -- 사용카드 크라운, 사용취소 크라운 체크
                SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)  -- 사용가능 크라운
                      , SUM(HIS.SAV_MLG - HIS.LOS_MLG)                      -- 취소가능 크라운
                      , SUM(HIS.USE_MLG)                                    -- 사용한 크라운
                INTO    nREMMLG, nCNCMLG, nUSEMLG
                FROM    C_CARD CRD
                      , C_CARD_SAV_USE_HIS HIS
                WHERE   CRD.COMP_CD  = HIS.COMP_CD
                AND     CRD.CARD_ID  = HIS.CARD_ID
                AND     CRD.COMP_CD  = PSV_COMP_CD
                AND     CRD.CUST_ID  = vCST_CUST_ID
                AND     HIS.LOS_MLG_YN  = 'N';
                
                vRTNVAL := '00001';
                vRTNMSG := '중복자료가 있습니다.';
                
                RAISE ERR_HANDLER;
            END IF;
            
            -- 사용취소 - 원 승인번호로 체크
            IF MYREC.TRSC_BIZ_DV_CD = 'R4' THEN
                SELECT  COUNT(*) INTO nRECCNT1
                FROM    C_CARD_SAV_USE_PNT
                WHERE   COMP_CD = PSV_COMP_CD
                AND     CUST_ID = vCST_CUST_ID
                AND     USE_DT  = MYREC.ORG_APV_DT
                AND     USE_SEQ = MYREC.ORG_APV_NO;
                
                IF nRECCNT1 = 0 THEN
                    vRTNVAL := '00641';
                    vRTNMSG := '취소할 원 거래가 존재하지 않습니다.';
                                
                    RAISE ERR_HANDLER;
                END IF;
            END IF;
            
            -- 사용카드 크라운, 사용취소 크라운 체크
            SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE)  -- 사용가능 크라운
                  , SUM(HIS.SAV_MLG - HIS.LOS_MLG)                      -- 취소가능 크라운
                  , SUM(HIS.USE_MLG)                                    -- 사용한 크라운
            INTO    nREMMLG, nCNCMLG, nUSEMLG
            FROM    C_CARD CRD
                  , C_CARD_SAV_USE_HIS HIS
            WHERE   CRD.COMP_CD  = HIS.COMP_CD
            AND     CRD.CARD_ID  = HIS.CARD_ID
            AND     CRD.COMP_CD  = PSV_COMP_CD
            AND     CRD.CUST_ID  = vCST_CUST_ID
            AND     HIS.LOS_MLG_YN  = 'N';
            
            CASE 
                WHEN vCST_CUST_STAT IN ('1', '7', '8', '9') THEN
                    vRTNVAL := '30001';
                    vRTNMSG := '회원상태가 정상이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN vCST_CUST_STAT = '2' THEN
                    vRTNVAL := '00148';
                    vRTNMSG := '제휴사의 상태가 정상이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN nCSTRECCNT = 0 THEN
                    vRTNVAL := '00148';
                    vRTNMSG := '제휴사의 상태가 정상이 아닙니다.';
                            
                    RAISE ERR_HANDLER;
                WHEN MYREC.TRSC_BIZ_DV_CD = 'R3' AND nREMMLG < MYREC.USE_CRW THEN
                    vRTNVAL := '00317';
                    vRTNMSG := '사용 가능한 크라운이 부족합니다.' ;
                            
                    RAISE ERR_HANDLER;
                WHEN MYREC.TRSC_BIZ_DV_CD = 'R4' AND (nCNCMLG < MYREC.USE_CRW OR nUSEMLG < MYREC.USE_CRW) THEN
                    vRTNVAL := '00634';
                    vRTNMSG := '크라운 입력 오류입니다.' ;
                            
                    RAISE ERR_HANDLER;
                ELSE
                    vRTNVAL := '00000';   
                    vRTNMSG := '성공적으로 수행 되었습니다.';
            END CASE;
            
            vAPPR_DT := MYREC.TRSC_DT;
            
            -- C_CARD_SAV_USE_PNT 작성
            BEGIN
                nUSESEQ := SQ_PCRM_SEQ.NEXTVAL;
                
                INSERT INTO C_CARD_SAV_USE_PNT
               (
                COMP_CD, CUST_ID, USE_DT, USE_SEQ, 
                USE_FG, 
                USE_MLG,
                ORG_USE_DT, ORG_USE_SEQ, USE_YN, 
                INST_DT, INST_USER, UPD_DT, UPD_USER, SAP_IF_YN, SAP_IF_DT
               )
                VALUES
               (
                PSV_COMP_CD, vCST_CUST_ID, MYREC.TRSC_DT, nUSESEQ, 
                CASE WHEN MYREC.TRSC_BIZ_DV_CD = 'R3' THEN '1' ELSE '2' END, MYREC.USE_CRW,
                MYREC.ORG_APV_DT, MYREC.ORG_APV_NO, 'Y', 
                SYSDATE, 'USE CWN', SYSDATE, 'USE CWN', 'N', NULL
               );
            EXCEPTION
                WHEN OTHERS THEN
                    PR_RTN_CD  := '00200';
                    PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
                    ROLLBACK;   
                    RETURN;   
            END;
            
            -- IM_CRT_USER_INFO 마감처리
            UPDATE  MDO_MLG_PNT
            SET     PROC_YN    = 'Y'
                  , LCL_APV_DT = vAPPR_DT
                  , LCL_APV_NO = nUSESEQ
                  , ERR_CD     = vRTNVAL
                  , ERR_MSG    = vRTNMSG
            WHERE   TRSC_TYP_CD     = MYREC.TRSC_TYP_CD
            AND     TRSC_BIZ_DV_CD  = MYREC.TRSC_BIZ_DV_CD
            AND     COOPCO_CD       = MYREC.COOPCO_CD
            AND     TRSC_NO         = MYREC.TRSC_NO
            AND     ROWID           = MYREC.RID;
            
            -- 잔여 크라운 조회
            SELECT  SUM(HIS.SAV_MLG - HIS.USE_MLG - HIS.LOS_MLG_UNUSE) INTO nLSTMLG
            FROM    C_CARD CRD
                  , C_CARD_SAV_USE_HIS HIS
            WHERE   CRD.COMP_CD = HIS.COMP_CD
            AND     CRD.CARD_ID = HIS.CARD_ID
            AND     CRD.COMP_CD = PSV_COMP_CD
            AND     CRD.CUST_ID = vCST_CUST_ID
            AND     HIS.SAV_MLG != HIS.USE_MLG
            AND     HIS.LOS_MLG_YN  = 'N';
                
        END LOOP;
        
        OPEN PR_RESULT FOR
            SELECT  vAPPR_DT        APV_DT
                  , nUSESEQ         APV_NO
                  , NVL(nLSTMLG, 0) RMND_CRW
            FROM    DUAL;
                
        COMMIT;   
        
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN ERR_HANDLER THEN
            OPEN PR_RESULT FOR
                SELECT  CASE WHEN vRTNVAL = '00001' THEN vLCL_APV_DT          ELSE '' END  APV_DT
                      , CASE WHEN vRTNVAL = '00001' THEN TO_CHAR(vLCL_APV_NO) ELSE '' END  APV_NO
                      , CASE WHEN vRTNVAL = '00001' THEN TO_CHAR(nREMMLG)     ELSE '' END  RMND_CRW
                FROM DUAL;
                
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
    
            ROLLBACK;
            
            -- 처리결과 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRSC_TYP_CD, PSV_TRSC_BIZ_DV_CD, PSV_COOPCO_CD, PSV_TRSC_NO, PSV_CHNL_TYP_CD, 'MDO_MLG_PNT', vRTNVAL, vRTNMSG);
   
            RETURN;   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  ''    APV_DT
                      , ''    APV_NO
                      , ''    RMND_CRW
                FROM DUAL;
            
            vRTNVAL  := '00200';
            vRTNMSG  := '기타오류가 발생되었습니다. ('||SQLERRM||')';
                
            PR_RTN_CD  := vRTNVAL;
            PR_RTN_MSG := vRTNMSG;
   
            ROLLBACK;   
            
            -- 처리결과 SET
            DEL_TABLE_ERR_SET(PSV_COMP_CD, PSV_LANG_TP, PSV_TRSC_TYP_CD, PSV_TRSC_BIZ_DV_CD, PSV_COOPCO_CD, PSV_TRSC_NO, PSV_CHNL_TYP_CD, 'MDO_MLG_PNT', vRTNVAL, vRTNMSG);
            
            RETURN;   
    END SET_USE_MLG;
    
    PROCEDURE DEL_USE_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRSC_TYP_CD     IN  VARCHAR2, -- 3. 거래유형코드                
    PSV_TRSC_BIZ_DV_CD  IN  VARCHAR2, -- 4. 업무구분코드
    PSV_COOPCO_CD       IN  VARCHAR2, -- 5. 제휴사코드
    PSV_TRSC_NO         IN  VARCHAR2, -- 8. 거래고유번호
    PSV_CHNL_TYP_CD     IN  VARCHAR2, -- 7. 채널유형
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message      
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  MDO_MLG_PNT
        SET     PROC_YN = 'X'
        WHERE   TRSC_TYP_CD     = PSV_TRSC_TYP_CD
        AND     TRSC_BIZ_DV_CD  = PSV_TRSC_BIZ_DV_CD
        AND     COOPCO_CD       = PSV_COOPCO_CD
        AND     TRSC_NO         = PSV_TRSC_NO
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
    END DEL_USE_MLG; 
    
    PROCEDURE GET_ADD_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_CARD_SAV_USE_MDO MDO
        SET     MDO_IF_YN = 'R'
              , MDO_IF_ID = PSV_SEND_DTM
        WHERE   COMP_CD   = PSV_COMP_CD
        AND     MEMB_DIV  = '1'                 -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN = 'N'
        AND     MOD_DIV   = '1';                -- 적립
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  'R10'               AS TRSC_TYP_CD
                  , CASE WHEN MDO.MOD_DIV = '1' AND MDO.SAV_USE_DIV IN ('201', '203', '901', '903') THEN 'R1'
                         WHEN MDO.MOD_DIV = '1' AND MDO.SAV_USE_DIV IN ('202')                      THEN 'R2'
                         WHEN MDO.MOD_DIV = '2' AND SIGN(MDO.MOD_MLG) >= 0                          THEN 'R3'
                         WHEN MDO.MOD_DIV = '2' AND SIGN(MDO.MOD_MLG) <  0                          THEN 'R4'
                         WHEN MDO.MOD_DIV = '3'                                                     THEN 'R5'
                    END                 AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , MDO.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , MDO.SAV_USE_DIV     AS ACML_USE_KIND
                  , '2'                 AS MMB_CERT_DV_CD
                  , CST.UNFY_MMB_NO     AS MMB_CERT_DV_VLU
                  , NVL(SHD.GRD_I_AMT, 0) + NVL(SHD.GRD_O_AMT, 0) AS TOT_SEL_AMT
                  , MDO.MOD_MLG         AS ACML_CRW
                  , HIS.LOS_MLG_DT      AS XTNCT_DT
                  , CASE WHEN MDO.SAV_USE_DIV IN ('201','202') THEN HIS.STOR_CD||HIS.POS_NO||HIS.USE_DT||HIS.BILL_NO -- TO_CHAR(MDO.MDO_IF_SEQ)
                         ELSE TO_CHAR(MDO.MDO_IF_SEQ)
                    END                 AS UNIQ_RCGN_NO 
                  , NULL                AS PRO_NM
                  , HIS.REMARKS         AS ADJ_RSN
                  ,(
                    SELECT  ORG.MDO_APV_DT||','||ORG.MDO_APV_NO||','||OSH.STOR_CD||OSH.POS_NO||OSH.USE_DT||OSH.BILL_NO --//ORG.MDO_IF_SEQ
                    FROM    C_CARD_SAV_USE_MDO ORG
                          , C_CARD_SAV_HIS     OSH 
                    WHERE   ORG.COMP_CD = OSH.COMP_CD
                    AND     ORG.CARD_ID = OSH.CARD_ID
                    AND     ORG.USE_DT  = OSH.USE_DT
                    AND     ORG.USE_SEQ = OSH.USE_SEQ
                    AND     ORG.COMP_CD = MDO.COMP_CD
                    AND     ORG.CARD_ID = MDO.CARD_ID
                    AND     ORG.USE_DT  = MDO.ORG_USE_DT
                    AND     ORG.USE_SEQ = MDO.ORG_USE_SEQ
                    AND     ORG.MOD_DIV = '1'
                   )                    AS ORG_APV_INFO
                  , ROWIDTOCHAR(MDO.ROWID) RID
            FROM    C_CUST  CST
                  , C_CARD  CRD
                  , C_CARD_SAV_USE_MDO MDO
                  , C_CARD_SAV_HIS     HIS
                  , SALE_HD            SHD
                  , BRAND_COND         BCD
            WHERE   MDO.COMP_CD   = CRD.COMP_CD
            AND     MDO.CARD_ID   = CRD.CARD_ID
            AND     CRD.COMP_CD   = CST.COMP_CD
            AND     CRD.CUST_ID   = CST.CUST_ID
            AND     MDO.COMP_CD   = HIS.COMP_CD
            AND     MDO.CARD_ID   = HIS.CARD_ID
            AND     MDO.USE_DT    = HIS.USE_DT
            AND     MDO.USE_SEQ   = HIS.USE_SEQ
            AND     HIS.COMP_CD   = BCD.COMP_CD
            AND     HIS.BRAND_CD  = BCD.BRAND_CD
            AND     HIS.USE_DT    = SHD.SALE_DT (+)
            AND     HIS.BRAND_CD  = SHD.BRAND_CD(+)
            AND     HIS.STOR_CD   = SHD.STOR_CD (+)
            AND     HIS.POS_NO    = SHD.POS_NO  (+)
            AND     HIS.BILL_NO   = SHD.BILL_NO (+)
            AND     MDO.COMP_CD   = PSV_COMP_CD
            AND     MDO.MDO_IF_ID = PSV_SEND_DTM
            AND     MDO.MEMB_DIV  = '1'
            AND     MDO.MOD_DIV   = '1'
            AND     MDO.MDO_IF_YN = 'R'
            ORDER BY
                    MDO.UPD_DT;
                            
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_ADD_MLG;
    
    PROCEDURE GET_ADD_MLG_VOID   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_ROWID           IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        PR_RTN_CD  := '00000';
        PR_RTN_MSG := 'OK';
        
        OPEN PR_RESULT FOR
            SELECT  MDO_APV_DT          AS ORG_APV_DT
                  , MDO_APV_NO          AS ORG_APV_NO
                  , ORG_UNIQ_RCGN_NO    AS ORG_UNIQ_RCGN_NO
            FROM   (      
                    SELECT  W01.MDO_APV_DT
                          , W01.MDO_APV_NO
                          , W02.STOR_CD||W02.POS_NO||W02.USE_DT||W02.BILL_NO AS ORG_UNIQ_RCGN_NO
                          , ROW_NUMBER() OVER(ORDER BY W01.PRC_SEQ DESC) R_NUM 
                    FROM    C_CARD_SAV_USE_MDO W01
                          , C_CARD_SAV_HIS     W02
                          ,(
                            SELECT  *
                            FROM    C_CARD_SAV_USE_MDO
                            WHERE   ROWID = PSV_ROWID
                           ) W03
                    WHERE   W01.COMP_CD   = W02.COMP_CD
                    AND     W01.CARD_ID   = W02.CARD_ID
                    AND     W01.USE_DT    = W02.USE_DT
                    AND     W01.USE_SEQ   = W02.USE_SEQ
                    AND     W01.COMP_CD   = W03.COMP_CD
                    AND     W01.CARD_ID   = W03.CARD_ID
                    AND     W01.USE_DT    = W03.ORG_USE_DT
                    AND     W01.USE_SEQ   = W03.ORG_USE_SEQ
                    AND     W01.MOD_DIV   = '1'
                   )
            WHERE   R_NUM = 1;
    END GET_ADD_MLG_VOID;
    
    PROCEDURE GET_USE_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_CARD_SAV_USE_MDO MDO
        SET     MDO_IF_YN = 'R'
              , MDO_IF_ID = PSV_SEND_DTM
        WHERE   COMP_CD   = PSV_COMP_CD
        AND     MEMB_DIV  = '1'                     -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN = 'N'
        AND    (
                (MOD_DIV = '3')                     -- 소멸
                OR 
                (MOD_DIV = '2' AND USE_DIV = '1')   -- 크라운 사용 : 쿠폰만
               );
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  'R20'               AS TRSC_TYP_CD
                  , CASE WHEN V01.MOD_DIV = '2' AND SIGN(V01.MOD_MLG) >= 0  THEN 'R3'
                         WHEN V01.MOD_DIV = '2' AND SIGN(V01.MOD_MLG) <  0  THEN 'R4'
                         WHEN V01.MOD_DIV = '3'                             THEN 'R5'
                    END                 AS TRSC_BIZ_DV_CD
                  , V01.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , V01.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , V01.MDO_BRAND_CD    AS BRND_CD
                  , V01.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , CASE WHEN V01.MOD_DIV = '2' AND SIGN(V01.MOD_MLG) >= 0  THEN '301'
                         WHEN V01.MOD_DIV = '2' AND SIGN(V01.MOD_MLG) <  0  THEN '302'
                         WHEN V01.MOD_DIV = '3'                             THEN '801'
                    END                 AS ACML_USE_KIND
                  , '2'                 AS MMB_CERT_DV_CD
                  , V01.UNFY_MMB_NO     AS MMB_CERT_DV_VLU
                  , V01.MOD_MLG         AS USE_CRW
                  , V01.MDO_IF_SEQ      AS UNIQ_RCGN_NO 
                  , CASE WHEN V01.USE_DIV = '1' THEN '12+1 쿠폰 발행' 
                         WHEN V01.USE_DIV = '2' THEN '포인트전환' 
                         ELSE '기타사용'
                    END                 AS RMK
                  ,(
                    SELECT  ORG.MDO_APV_DT||','||ORG.MDO_APV_NO||','||ORG.MDO_IF_SEQ
                    FROM    C_CARD_SAV_USE_MDO ORG
                          , C_CARD             CRD
                    WHERE   ORG.COMP_CD = CRD.COMP_CD
                    AND     ORG.CARD_ID = CRD.CARD_ID
                    AND     CRD.CUST_ID = V01.CUST_ID
                    AND     ORG.COMP_CD = V01.COMP_CD
                    AND     ORG.USE_DT  = V01.ORG_USE_DT
                    AND     ORG.USE_SEQ = V01.ORG_USE_SEQ
                    AND     ORG.MOD_DIV IN ('2','3')
                   )                    AS ORG_APV_INFO
            FROM   (
                    SELECT  MDO.COMP_CD
                          , CST.CUST_ID
                          , MDO.MOD_DIV
                          , MDO.MDO_IF_SEQ          AS MDO_IF_SEQ
                          , CST.UNFY_MMB_NO         AS UNFY_MMB_NO
                          , SUM(MDO.MOD_MLG)        AS MOD_MLG
                          , MDO.MDO_IF_SEQ          AS UNIQ_RCGN_NO 
                          , MDO.USE_DIV             AS USE_DIV
                          , BCD.POINT_COOP_CD       AS POINT_COOP_CD
                          , BCD.MDO_BRAND_CD        AS MDO_BRAND_CD
                          , BCD.MDO_STOR_CD         AS MDO_STOR_CD
                          , MAX(MDO.ORG_USE_DT)     AS ORG_USE_DT
                          , MAX(MDO.ORG_USE_SEQ)    AS ORG_USE_SEQ
                    FROM    C_CUST  CST
                          , C_CARD  CRD
                          , C_CARD_SAV_USE_MDO MDO
                          , C_CARD_SAV_HIS     HIS
                          , BRAND_COND         BCD
                    WHERE   MDO.COMP_CD   = CRD.COMP_CD
                    AND     MDO.CARD_ID   = CRD.CARD_ID
                    AND     CRD.COMP_CD   = CST.COMP_CD
                    AND     CRD.CUST_ID   = CST.CUST_ID
                    AND     MDO.COMP_CD   = HIS.COMP_CD
                    AND     MDO.CARD_ID   = HIS.CARD_ID
                    AND     MDO.USE_DT    = HIS.USE_DT
                    AND     MDO.USE_SEQ   = HIS.USE_SEQ
                    AND     HIS.COMP_CD   = BCD.COMP_CD
                    AND     HIS.BRAND_CD  = BCD.BRAND_CD
                    AND     MDO.COMP_CD   = PSV_COMP_CD
                    AND     MDO.MDO_IF_ID = PSV_SEND_DTM
                    AND     MDO.MEMB_DIV  = '1'
                    AND     MDO.MOD_DIV  IN ('2','3')
                    AND     MDO.MDO_IF_YN = 'R'
                    GROUP BY
                            MDO.COMP_CD
                          , CST.CUST_ID
                          , MDO.MOD_DIV
                          , MDO.MDO_IF_SEQ
                          , CST.UNFY_MMB_NO
                          , MDO.MDO_IF_SEQ 
                          , MDO.USE_DIV
                          , BCD.POINT_COOP_CD
                          , BCD.MDO_BRAND_CD
                          , BCD.MDO_STOR_CD
                   ) V01;
                            
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_USE_MLG;
    
    PROCEDURE RST_ADD_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_CARD_SAV_USE_MDO
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_ADD_MLG; 
    
    PROCEDURE RST_USE_MLG   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_MDO_IF_SEQ      IN  VARCHAR2, -- 4. 처리고유일련번호
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_CARD_SAV_USE_MDO
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X' 
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     MDO_IF_ID  = PSV_SEND_DTM
        AND     MDO_IF_SEQ = PSV_MDO_IF_SEQ;
        
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
    END RST_USE_MLG; 
    
    PROCEDURE GET_ADD_CPN   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_COUPON_CUST_HIS MDO
        SET     MDO_IF_YN    = 'R'
              , MDO_IF_ID    = PSV_SEND_DTM
        WHERE   COMP_CD      = PSV_COMP_CD
        AND     MEMB_DIV     = '1'  -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN    = 'N'
        AND     USE_STAT     = 'X'         
        AND     USE_STAT_AFT = '01'
        AND     ROWNUM      <= 300
        AND     EXISTS (
                        SELECT  1
                        FROM    C_COUPON_MST MST
                        WHERE   MST.COMP_CD   = MDO.COMP_CD
                        AND     MST.COUPON_CD = MDO.COUPON_CD
                        AND     MST.COUPON_DIV= '1'
                       );           -- 정기 쿠폰 대상
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  '6A0'               AS TRSC_TYP_CD
                  , '63'                AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , HIS.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , HIS.MDO_IF_SEQ      AS UNIQ_RCGN_NO
                  , HIS.COUPON_CD       AS CPN_CD
                  , CASE WHEN CCC.GRP_SEQ IN (1,2) THEN CCC.GRP_SEQ ELSE 1 END AS GRP_CD
                  , HIS.CERT_NO         AS CPN_ISSU_CD
                  , CST.UNFY_MMB_NO     AS UNFY_MMB_NO
                  , CCC.CERT_FDT        AS VALD_STR_DT
                  , CCC.CERT_TDT        AS VALD_END_DT
                  , CCC.MEMB_DIV        AS MEMB_DIV
                  , NULL                AS ORG_APV_INFO
                  , ROWIDTOCHAR(HIS.ROWID) RID
            FROM    C_COUPON_CUST_HIS HIS
                  , C_COUPON_CUST     CCC
                  , C_CUST            CST
                  , BRAND_COND        BCD
            WHERE   HIS.COMP_CD      = CCC.COMP_CD
            AND     HIS.COUPON_CD    = CCC.COUPON_CD
            AND     HIS.CERT_NO      = CCC.CERT_NO
            AND     CCC.COMP_CD      = CST.COMP_CD
            AND     CCC.CUST_ID      = CST.CUST_ID
            AND     CCC.COMP_CD      = BCD.COMP_CD
            AND     CCC.BRAND_CD     = BCD.BRAND_CD
            AND     HIS.COMP_CD      = PSV_COMP_CD
            AND     HIS.MDO_IF_ID    = PSV_SEND_DTM
            AND     HIS.MEMB_DIV     = '1'
            AND     HIS.MDO_IF_YN    = 'R'
            AND     HIS.USE_STAT     = 'X'         
            AND     HIS.USE_STAT_AFT = '01';

        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_ADD_CPN;
    
    PROCEDURE GET_USE_CPN   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_COUPON_CUST_HIS MDO
        SET     MDO_IF_YN    = 'R'
              , MDO_IF_ID    = PSV_SEND_DTM
        WHERE   COMP_CD      = PSV_COMP_CD
        AND     MEMB_DIV     = '1'  -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN    = 'N'
        AND   ((USE_STAT     IN ('01', '11') AND USE_STAT_AFT = '10')
                OR
               (USE_STAT     IN ('10')       AND USE_STAT_AFT = '11'));
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  '600'               AS TRSC_TYP_CD
                  , CASE WHEN USE_STAT_AFT = '10' THEN '61' ELSE '62' END AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , HIS.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , 0                   AS TOT_SEL_AMT
                  , HIS.STOR_CD_AFT||HIS.POS_NO_AFT||HIS.USE_DT_AFT||HIS.BILL_NO_AFT AS UNIQ_RCGN_NO
                  ,(
                    SELECT HIS.CERT_NO||','||IT.M_CLASS_CD||','||IT.ITEM_CD||','||TO_CHAR(IT.SALE_PRC)||','||TO_CHAR(IT.SALE_PRC)
                    FROM   ITEM_CHAIN   IT
                         , DC_ITEM      DI
                    WHERE  IT.BRAND_CD = DI.BRAND_CD
                    AND    IT.ITEM_CD  = DI.ITEM_CD
                    AND    IT.STOR_TP  = '10'
                    AND    DI.BRAND_CD = CCM.BRAND_CD
                    AND    DI.DC_DIV   = CCM.DC_DIV 
                    AND    DI.USE_YN   = 'Y'
                    AND    ROWNUM      = 1
                   )                    AS ITEM_INFO
                  , CASE WHEN USE_STAT_AFT = '10' THEN '쿠폰사용' ELSE '쿠폰사용취소' END AS RMK
                  , USE_STAT_AFT        AS USE_STAT_AFT
                  , ROWIDTOCHAR(HIS.ROWID) RID
            FROM    C_COUPON_CUST_HIS HIS
                  , C_COUPON_CUST     CCC
                  , C_COUPON_MST      CCM
                  , BRAND_COND        BCD
            WHERE   HIS.COMP_CD      = CCC.COMP_CD
            AND     HIS.COUPON_CD    = CCC.COUPON_CD
            AND     HIS.CERT_NO      = CCC.CERT_NO
            AND     CCC.COMP_CD      = CCM.COMP_CD
            AND     CCC.COUPON_CD    = CCM.COUPON_CD
            AND     CCC.COMP_CD      = BCD.COMP_CD
            AND     CCC.BRAND_CD     = BCD.BRAND_CD
            AND     HIS.COMP_CD      = PSV_COMP_CD
            AND     HIS.MDO_IF_ID    = PSV_SEND_DTM
            AND     HIS.MEMB_DIV     = '1'
            AND     HIS.MDO_IF_YN    = 'R'
            AND   ((HIS.USE_STAT     IN ('01', '11') AND HIS.USE_STAT_AFT = '10')
                    OR
                   (HIS.USE_STAT     IN ('10')       AND HIS.USE_STAT_AFT = '11'))
            ORDER BY
                    HIS.INST_DT;

        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_USE_CPN;
    
    PROCEDURE GET_USE_VOID   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_ROWID           IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        PR_RTN_CD  := '00000';
        PR_RTN_MSG := 'OK';
        
        OPEN PR_RESULT FOR
            SELECT  MDO_APV_DT          AS ORG_APV_DT
                  , MDO_APV_NO          AS ORG_APV_NO
                  , ORG_UNIQ_RCGN_NO    AS ORG_UNIQ_RCGN_NO
            FROM   (      
                    SELECT  W01.MDO_APV_DT
                          , W01.MDO_APV_NO
                          , W02.STOR_CD||W02.POS_NO||W02.USE_DT||W02.BILL_NO AS ORG_UNIQ_RCGN_NO
                          , ROW_NUMBER() OVER(ORDER BY W01.CHG_SEQ DESC) R_NUM 
                    FROM    C_COUPON_CUST_HIS W01
                          ,(
                            SELECT  *
                            FROM    C_COUPON_CUST_HIS
                            WHERE   ROWID = PSV_ROWID
                           ) W02
                    WHERE   W01.COMP_CD   = W02.COMP_CD
                    AND     W01.COUPON_CD = W02.COUPON_CD
                    AND     W01.CERT_NO   = W02.CERT_NO
                    AND     W01.CHG_SEQ   < W02.CHG_SEQ
                    AND     W01.USE_STAT_AFT  = '10'
                   )
            WHERE   R_NUM = 1;
    END GET_USE_VOID;
    
    PROCEDURE GET_MIS_CPN   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_COUPON_CUST_HIS MDO
        SET     MDO_IF_YN    = 'R'
              , MDO_IF_ID    = PSV_SEND_DTM
        WHERE   COMP_CD      = PSV_COMP_CD
        AND     MEMB_DIV     = '1'  -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN    = 'N'
        AND     USE_STAT     IN ('01','11')        
        AND     USE_STAT_AFT IN ('30','31','32','99') -- 유효기간만료(33)는 미전송
        AND     EXISTS (
                        SELECT  1
                        FROM    C_COUPON_MST MST
                        WHERE   MST.COMP_CD   = MDO.COMP_CD
                        AND     MST.COUPON_CD = MDO.COUPON_CD
                        AND     MST.COUPON_DIV= '1'
                       );           -- 정기 쿠폰 발행취소(34:탈퇴폐기는 안보냄)
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  '6A0'               AS TRSC_TYP_CD
                  , '64'                AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , HIS.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , HIS.MDO_IF_SEQ      AS UNIQ_RCGN_NO
                  , HIS.COUPON_CD       AS CPN_CD
                  , HIS.CERT_NO         AS CPN_ISSU_CD
                  , CST.UNFY_MMB_NO     AS UNFY_MMB_NO
                  , CCC.CERT_FDT        AS VALD_STR_DT
                  , CCC.CERT_TDT        AS VALD_END_DT
                  , CCC.MEMB_DIV        AS MEMB_DIV 
                  ,(
                    SELECT  ORG.MDO_APV_DT||','||ORG.MDO_APV_NO||','||ORG.MDO_IF_SEQ
                    FROM    C_COUPON_CUST_HIS ORG
                    WHERE   ORG.COMP_CD      = HIS.COMP_CD
                    AND     ORG.COUPON_CD    = HIS.COUPON_CD
                    AND     ORG.CERT_NO      = HIS.CERT_NO
                    AND     ORG.USE_STAT     = 'X'
                    AND     ORG.USE_STAT_AFT = '01'
                    AND     HIS.USE_STAT     IN ('01','11') 
                    AND     HIS.USE_STAT_AFT IN ('30','31','32','99') -- 유효기간만료(33)는 미전송
                   )                    AS ORG_APV_INFO
                  , ROWIDTOCHAR(HIS.ROWID) RID
            FROM    C_COUPON_CUST_HIS HIS
                  , C_COUPON_CUST     CCC
                  , C_CUST            CST
                  , BRAND_COND        BCD
            WHERE   HIS.COMP_CD      = CCC.COMP_CD
            AND     HIS.COUPON_CD    = CCC.COUPON_CD
            AND     HIS.CERT_NO      = CCC.CERT_NO
            AND     CCC.COMP_CD      = CST.COMP_CD
            AND     CCC.CUST_ID      = CST.CUST_ID
            AND     CCC.COMP_CD      = BCD.COMP_CD
            AND     CCC.BRAND_CD     = BCD.BRAND_CD
            AND     HIS.COMP_CD      = PSV_COMP_CD
            AND     HIS.MDO_IF_ID    = PSV_SEND_DTM
            AND     HIS.MEMB_DIV     = '1'
            AND     HIS.MDO_IF_YN    = 'R'
            AND     HIS.USE_STAT     IN ('01','11')        
            AND     HIS.USE_STAT_AFT IN ('30','31','32','33', '99');
                            
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_MIS_CPN;
    
    PROCEDURE RST_ADD_CPN
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_COUPON_CUST_HIS
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_ADD_CPN;
    
    PROCEDURE RST_USE_CPN
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_COUPON_CUST_HIS
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_USE_CPN;
    
    PROCEDURE RST_MIS_CPN
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_COUPON_CUST_HIS
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_MIS_CPN;
    
    PROCEDURE GET_ADD_CPN_EXT
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_COUPON_CUST_HIS MDO
        SET     MDO_IF_YN    = 'R'
              , MDO_IF_ID    = PSV_SEND_DTM
        WHERE   COMP_CD      = PSV_COMP_CD
        AND     MEMB_DIV     = '1'  -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN    = 'N'
        AND     USE_STAT     = 'X'         
        AND     USE_STAT_AFT = '01'
        AND     ROWNUM      <= 300
        AND     EXISTS (
                        SELECT  1
                        FROM    C_COUPON_MST MST
                        WHERE   MST.COMP_CD   = MDO.COMP_CD
                        AND     MST.COUPON_CD = MDO.COUPON_CD
                        AND     MST.COUPON_DIV= '2'
                       );           -- 추출 쿠폰 대상
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  '6A0'               AS TRSC_TYP_CD
                  , '63'                AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , HIS.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , HIS.MDO_IF_SEQ      AS UNIQ_RCGN_NO
                  , HIS.COUPON_CD       AS CPN_CD
                  , CASE WHEN CCC.GRP_SEQ IN (1,2) THEN CCC.GRP_SEQ ELSE 1 END AS GRP_CD
                  , HIS.CERT_NO         AS CPN_ISSU_CD
                  , CST.UNFY_MMB_NO     AS UNFY_MMB_NO
                  , CCC.CERT_FDT        AS VALD_STR_DT
                  , CCC.CERT_TDT        AS VALD_END_DT
                  , CCC.MEMB_DIV        AS MEMB_DIV
                  , NULL                AS ORG_APV_INFO
                  , ROWIDTOCHAR(HIS.ROWID) RID
            FROM    C_COUPON_CUST_HIS HIS
                  , C_COUPON_CUST     CCC
                  , C_CUST            CST
                  , BRAND_COND        BCD
            WHERE   HIS.COMP_CD      = CCC.COMP_CD
            AND     HIS.COUPON_CD    = CCC.COUPON_CD
            AND     HIS.CERT_NO      = CCC.CERT_NO
            AND     CCC.COMP_CD      = CST.COMP_CD
            AND     CCC.CUST_ID      = CST.CUST_ID
            AND     CCC.COMP_CD      = BCD.COMP_CD
            AND     CCC.BRAND_CD     = BCD.BRAND_CD
            AND     HIS.COMP_CD      = PSV_COMP_CD
            AND     HIS.MDO_IF_ID    = PSV_SEND_DTM
            AND     HIS.MEMB_DIV     = '1'
            AND     HIS.MDO_IF_YN    = 'R'
            AND     HIS.USE_STAT     = 'X'         
            AND     HIS.USE_STAT_AFT = '01';
                            
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_ADD_CPN_EXT;
    
    PROCEDURE GET_MIS_CPN_EXT
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PR_RTN_CD           OUT VARCHAR2, -- 4. 처리코드
    PR_RTN_MSG          OUT VARCHAR2, -- 5. 처리Message
    PR_RESULT           OUT REC_SET.M_REFCUR
   ) IS   
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '정상적으로 처리 되었습니다.';
    
    ERR_HANDLER     EXCEPTION;   
   
    BEGIN
        -- 실행 일시기준으로 예약 처리
        UPDATE  C_COUPON_CUST_HIS MDO
        SET     MDO_IF_YN    = 'R'
              , MDO_IF_ID    = PSV_SEND_DTM
        WHERE   COMP_CD      = PSV_COMP_CD
        AND     MEMB_DIV     = '1'  -- 멤버십구분[0:엠즈씨드, 1:통합멤버십]
        AND     MDO_IF_YN    = 'N'
        AND     USE_STAT     IN ('01','11')        
        AND     USE_STAT_AFT IN ('30','31','32','99') -- 유효기간만료(33)는 미전송 
        AND     EXISTS (
                        SELECT  1
                        FROM    C_COUPON_MST MST
                        WHERE   MST.COMP_CD   = MDO.COMP_CD
                        AND     MST.COUPON_CD = MDO.COUPON_CD
                        AND     MST.COUPON_DIV= '2'
                       );           -- 추출 쿠폰 발행취소(34:탈퇴폐기는 안보냄)
                
        COMMIT;
        
        OPEN PR_RESULT FOR
            SELECT  '6A0'               AS TRSC_TYP_CD
                  , '64'                AS TRSC_BIZ_DV_CD
                  , BCD.POINT_COOP_CD   AS COOPCO_CD
                  , TO_CHAR(SYSDATE, 'YYYYMMDD') AS TRSC_DT
                  , TO_CHAR(SYSDATE, 'HH24MISS') AS TRSC_HR
                  , HIS.MDO_IF_SEQ      AS TRC_NO
                  , '2'                 AS CHNL_TYP_CD
                  , BCD.MDO_BRAND_CD    AS BRND_CD
                  , BCD.MDO_STOR_CD     AS STOR_NO
                  , '10'                AS TRSC_ORGN_DV_CD
                  , HIS.MDO_IF_SEQ      AS UNIQ_RCGN_NO
                  , HIS.COUPON_CD       AS CPN_CD
                  , HIS.CERT_NO         AS CPN_ISSU_CD
                  , CST.UNFY_MMB_NO     AS UNFY_MMB_NO
                  , CCC.CERT_FDT        AS VALD_STR_DT
                  , CCC.CERT_TDT        AS VALD_END_DT
                  , CCC.MEMB_DIV        AS MEMB_DIV
                  ,(
                    SELECT  ORG.MDO_APV_DT||','||ORG.MDO_APV_NO||','||ORG.MDO_IF_SEQ
                    FROM    C_COUPON_CUST_HIS ORG
                    WHERE   ORG.COMP_CD      = HIS.COMP_CD
                    AND     ORG.COUPON_CD    = HIS.COUPON_CD
                    AND     ORG.CERT_NO      = HIS.CERT_NO
                    AND     ORG.USE_STAT     = 'X'
                    AND     ORG.USE_STAT_AFT = '01'
                    AND     HIS.USE_STAT     IN ('01','11') 
                    AND     HIS.USE_STAT_AFT IN ('30','31','32','99') -- 유효기간만료(33)는 미전송
                   )                    AS ORG_APV_INFO
                  , ROWIDTOCHAR(HIS.ROWID) RID
            FROM    C_COUPON_CUST_HIS HIS
                  , C_COUPON_CUST     CCC
                  , C_CUST            CST
                  , BRAND_COND         BCD
            WHERE   HIS.COMP_CD      = CCC.COMP_CD
            AND     HIS.COUPON_CD    = CCC.COUPON_CD
            AND     HIS.CERT_NO      = CCC.CERT_NO
            AND     CCC.COMP_CD      = CST.COMP_CD
            AND     CCC.CUST_ID      = CST.CUST_ID
            AND     CCC.COMP_CD      = BCD.COMP_CD
            AND     CCC.BRAND_CD     = BCD.BRAND_CD
            AND     HIS.COMP_CD      = PSV_COMP_CD
            AND     HIS.MDO_IF_ID    = PSV_SEND_DTM
            AND     HIS.MEMB_DIV     = '1'
            AND     HIS.MDO_IF_YN    = 'R'
            AND     HIS.USE_STAT     IN ('01','11')        
            AND     HIS.USE_STAT_AFT IN ('30','31','32','33', '99');
                            
        -- 정상처리
        PR_RTN_CD  := vRTNVAL;
        PR_RTN_MSG := vRTNMSG;
            
        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            OPEN PR_RESULT FOR
                SELECT  NULL
                FROM    DUAL;
                
            PR_RTN_CD  := '00200';
            PR_RTN_MSG := '기타오류가 발생되었습니다. ('||SQLERRM||')';
   
            ROLLBACK;   
            RETURN;   
    END GET_MIS_CPN_EXT;
    
    PROCEDURE RST_ADD_CPN_EXT
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_COUPON_CUST_HIS
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_ADD_CPN_EXT;
    
    PROCEDURE RST_MIS_CPN_EXT
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드
    PSV_SEND_DTM        IN  VARCHAR2, -- 3. 실행일시
    PSV_ROWID           IN  VARCHAR2, -- 4. 테이블ROWID
    PSV_APV_DT          IN  VARCHAR2, -- 5. 승인일자
    PSV_APV_NO          IN  VARCHAR2, -- 6. 승인번호
    PSV_RES_CD          IN  VARCHAR2, -- 7. 승인결과
    PR_RTN_CD           OUT VARCHAR2, -- 8. 처리코드 
    PR_RTN_MSG          OUT VARCHAR2  -- 9. 처리Message    
   ) IS
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := '00000';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        UPDATE  C_COUPON_CUST_HIS
        SET     MDO_IF_YN  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN 'Y'
                                  WHEN PSV_RES_CD IN ('99998', '99999')          THEN 'N'
                                  ELSE                                                'X'
                             END
              , MDO_IF_DT  = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN SYSDATE    ELSE NULL END
              , MDO_APV_DT = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_DT ELSE NULL END
              , MDO_APV_NO = CASE WHEN PSV_RES_CD IN ('00000', '00151', '00041') THEN PSV_APV_NO ELSE NULL END
        WHERE   ROWID = PSV_ROWID;
   
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
    END RST_MIS_CPN_EXT;
    
    PROCEDURE DEL_TABLE_ERR_SET   
   (   
    PSV_COMP_CD         IN  VARCHAR2, -- 1. 회사코드                
    PSV_LANG_TP         IN  VARCHAR2, -- 2. 언어코드                
    PSV_TRSC_TYP_CD     IN  VARCHAR2, -- 3. 거래유형코드                
    PSV_TRSC_BIZ_DV_CD  IN  VARCHAR2, -- 4. 업무구분코드
    PSV_COOPCO_CD       IN  VARCHAR2, -- 5. 제휴사코드
    PSV_TRSC_NO         IN  VARCHAR2, -- 8. 거래고유번호
    PSV_CHNL_TYP_CD     IN  VARCHAR2, -- 7. 채널유형
    PSV_TABLE_NM        IN  VARCHAR2, -- 8. 테이블명
    PSV_RTN_CD          IN  VARCHAR2, -- 9. 처리코드 
    PSV_RTN_MSG         IN  VARCHAR2  -- 10.처리Message
   ) IS   
    
    ERR_HANDLER     EXCEPTION;
    
    vRTNVAL         VARCHAR2(2000) := 'S0017030';   
    vRTNMSG         VARCHAR2(2000) := '성공적으로 수행 되었습니다.';
    
    BEGIN
        IF PSV_TABLE_NM = 'MDO_MLG_PNT' THEN
            UPDATE  MDO_MLG_PNT
            SET     ERR_CD          = PSV_RTN_CD
                  , ERR_MSG         = PSV_RTN_MSG
            WHERE   TRSC_TYP_CD     = PSV_TRSC_TYP_CD
            AND     TRSC_BIZ_DV_CD  = PSV_TRSC_BIZ_DV_CD
            AND     COOPCO_CD       = PSV_COOPCO_CD
            AND     TRSC_NO         = PSV_TRSC_NO
            AND     PROC_YN         = 'N';
        END IF;
        
        COMMIT;   

        RETURN;   
    EXCEPTION   
        WHEN OTHERS THEN
            ROLLBACK;   
            RETURN;   
    END DEL_TABLE_ERR_SET; 
    
END PKG_MDO_IF;

/
