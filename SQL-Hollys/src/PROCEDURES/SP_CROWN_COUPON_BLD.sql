--------------------------------------------------------
--  DDL for Procedure SP_CROWN_COUPON_BLD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_COUPON_BLD" 
(
    PSV_COMP_CD       IN    VARCHAR2,               -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,               -- 언어타입
    PSV_CUST_ID       IN    VARCHAR2,               -- 고객번호
    PSV_PRT_DIV       IN    VARCHAR2,               -- 01:등업, 02:첫충전, 03:가입, 04:생일, 05:12+1, 06:구매, 07:첫충전
    PSV_SALE_HD       IN    PKG_TYPE.TRG_SALE_HD,   -- SALE_HD 구조체
    PSV_RTN_CD        OUT   NUMBER,                 -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2                -- 처리Message
)
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_COUPON_MAK
--  Description      : C_COUPON_CUST 생성( 매일 AM:5시 실행)
--  Ref. Table       : C_COUPON_CUST
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
    -- 고객 등급에 맞는 쿠폰(할인) 발행 종류 취득
    CURSOR CUR_1 (ARG_LVL_CD IN VARCHAR2) IS
        SELECT  GRP.COMP_CD
              , GRP.LVL_CD
              , GRP.COUPON_CD
              , GRP.GRP_SEQ
              , GRP.BRAND_CD
              , GRP.DC_DIV
              , MST.RESTRI_YN
              , MST.MAX_PROM_CNT
              , MST.CUST_CNT
        FROM    C_COUPON_ITEM_GRP   GRP
              , C_COUPON_MST        MST
        WHERE   GRP.COMP_CD     = MST.COMP_CD
        AND     GRP.COUPON_CD   = MST.COUPON_CD  
        AND     GRP.LVL_CD      = ARG_LVL_CD
        AND     GRP.PRT_DIV     = PSV_PRT_DIV  -- 발행구분
        AND     MST.START_DT   <= TO_CHAR(SYSDATE    , 'YYYYMMDD')
        AND     1               =(
                                  CASE WHEN PSV_PRT_DIV  = '02' AND MST.CLOSE_DT >= TO_CHAR(SYSDATE - 7, 'YYYYMMDD') THEN 1
                                       WHEN PSV_PRT_DIV != '02' AND MST.CLOSE_DT >= TO_CHAR(SYSDATE - 1, 'YYYYMMDD') THEN 1
                                       ELSE 0
                                  END
                                 )
        AND     1               =(
                                  CASE WHEN PSV_PRT_DIV = '02' THEN (
                                                                     CASE WHEN NVL(PSV_SALE_HD.GRD_I_AMT, 0) >= 100000 THEN 1
                                                                          WHEN NVL(PSV_SALE_HD.GRD_I_AMT, 0) BETWEEN GRP.SAV_CASH_FR AND GRP.SAV_CASH_TO THEN 1
                                                                          ELSE 0
                                                                     END
                                                                    )
                                       ELSE 1 
                                  END
                                 )
        AND     MST.COUPON_STAT = '2' 
        AND     MST.CERT_YN     = 'Y'
        AND     GRP.USE_YN      = 'Y';
    
    -- 반품에 따른 원거래 발행 쿠폰 취소 처리
    CURSOR CUR_2 IS
        SELECT  CST.COMP_CD
              , CST.COUPON_CD
              , CST.CERT_NO
              , ROW_NUMBER() OVER(PARTITION BY CST.CUST_ID ORDER BY CST.CERT_NO) R_NUM
        FROM    C_COUPON_ITEM_GRP   GRP
              , C_COUPON_MST        MST
              , C_COUPON_CUST       CST
        WHERE   GRP.COMP_CD     = MST.COMP_CD
        AND     GRP.COUPON_CD   = MST.COUPON_CD
        AND     GRP.COMP_CD     = CST.COMP_CD
        AND     GRP.COUPON_CD   = CST.COUPON_CD
        AND     GRP.LVL_CD      = CST.PRT_LVL_CD
        AND     GRP.GRP_SEQ     = CST.GRP_SEQ
        AND     GRP.PRT_DIV     = PSV_PRT_DIV  -- 발행구분
        AND     CST.COMP_CD     = PSV_COMP_CD
        AND     CST.PRT_BRAND_CD= PSV_SALE_HD.BRAND_CD
        AND     CST.PRT_STOR_CD = PSV_SALE_HD.STOR_CD
        AND     CST.PRT_POS_NO  = PSV_SALE_HD.POS_NO
        AND     CST.PRT_SALE_DT = PSV_SALE_HD.VOID_BEFORE_DT
        AND     CST.PRT_BILL_NO = PSV_SALE_HD.VOID_BEFORE_NO
        AND     CST.CUST_ID     = PSV_CUST_ID
        AND     CST.USE_YN      = 'Y'
        AND     CST.USE_STAT   IN ('00', '01', '11')
        AND     MST.COUPON_STAT = '2' 
        AND     MST.CERT_YN     = 'Y'
        AND     GRP.USE_YN      = 'Y';
                      
    ERR_HANDLER     EXCEPTION;
    
    vMLG_DIV        C_CUST.MLG_DIV%TYPE         := NULL;
    vLVL_CD         C_CUST.LVL_CD%TYPE          := NULL;
    vCUST_STAT      C_CUST.CUST_STAT%TYPE       := NULL;
    vBIRTH_DT1      C_CUST.BIRTH_DT%TYPE        := NULL;
    vBIRTH_DT2      C_CUST.BIRTH_DT%TYPE        := NULL;
    vBIRTH_DT3      C_CUST.BIRTH_DT%TYPE        := NULL;
    vCERTNO         C_COUPON_CUST.CERT_NO%TYPE  := NULL;
    
    nRECCNT         NUMBER(7)                   := NULL;
    nRTNCODE        NUMBER(7)                   := NULL;
    vRTNMSG         VARCHAR2(2000)              := NULL;
BEGIN
    BEGIN
        -- 고객 상태, 등급 취득
        SELECT  LVL_CD
              , CUST_STAT
              , DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE-365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4))
              , DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE    , 'YYYY')||SUBSTR(BIRTH_DT, 5, 4))
              , DECODE(LUNAR_DIV, 'L', UF_LUN2SOL(TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4), '0'), TO_CHAR(SYSDATE+365, 'YYYY')||SUBSTR(BIRTH_DT, 5, 4))
        INTO    vLVL_CD, vCUST_STAT, vBIRTH_DT1, vBIRTH_DT2, vBIRTH_DT3
        FROM    C_CUST
        WHERE   COMP_CD = PSV_COMP_CD
        AND     CUST_ID = PSV_CUST_ID;
        
        -- 고객 상태 비교        
        IF vCUST_STAT NOT IN ('2', '3') THEN
            PSV_RTN_CD  := CASE WHEN vCUST_STAT = '1' THEN 1001
                                WHEN vCUST_STAT = '9' THEN 1002
                                ELSE 999
                           END;
            PSV_RTN_MSG := CASE WHEN vCUST_STAT = '1' THEN FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001405')
                                WHEN vCUST_STAT = '9' THEN FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001404')
                                ELSE FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001187')
                           END;   
                           
            RETURN;
        END IF;
        
        -- 생일이 NULL인 경우 SKIP(정상종료)
        IF PSV_PRT_DIV = '04' THEN
            IF vBIRTH_DT1 IS NULL OR vBIRTH_DT2 IS NULL OR vBIRTH_DT3 IS NULL THEN
                PSV_RTN_CD  := 1011;
                PSV_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001424'); -- 생일이 NULL입니다.   
                               
                RETURN;
            ELSE
                IF  (vBIRTH_DT1 >= TO_CHAR(SYSDATE-7, 'YYYYMMDD') AND vBIRTH_DT1 <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD'))
                     OR
                    (vBIRTH_DT2 >= TO_CHAR(SYSDATE-7, 'YYYYMMDD') AND vBIRTH_DT2 <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD'))
                     OR
                    (vBIRTH_DT3 >= TO_CHAR(SYSDATE-7, 'YYYYMMDD') AND vBIRTH_DT3 <= TO_CHAR(SYSDATE + 7, 'YYYYMMDD'))
                THEN
                    -- 생일 일주일전 ~ 생일 까지 이면 정상
                    PSV_RTN_CD := 0;
                ELSE
                    -- 그외는 에러
                    PSV_RTN_CD  := 1021;
                    PSV_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001425'); -- 생일쿠폰 발행 기간이 아닙니다.   
                               
                    RETURN;
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            PSV_RTN_CD  := SQLCODE;
            PSV_RTN_MSG := FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001403');
                            
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            PSV_RTN_CD  := SQLCODE;
            PSV_RTN_MSG := SQLERRM;
                            
            ROLLBACK;
            RETURN;
    END;

    -- 구매쿠폰인 경우 매출 / 반품 구분하여 처리
    IF PSV_PRT_DIV = '06' AND PSV_SALE_HD.SALE_DIV = '2' THEN
        FOR MYREC2 IN CUR_2 LOOP
            IF MYREC2.R_NUM = 1 THEN
                BEGIN
                    UPDATE  C_COUPON_CUST
                    SET     USE_STAT  = '32' -- 폐기
                          , USE_YN    = 'N'
                    WHERE   COMP_CD   = MYREC2.COMP_CD  
                    AND     COUPON_CD = MYREC2.COUPON_CD
                    AND     CERT_NO   = MYREC2.CERT_NO;
                EXCEPTION
                    WHEN OTHERS THEN
                        PSV_RTN_CD  := SQLCODE;
                        PSV_RTN_MSG := SQLERRM;
                        
                        ROLLBACK;
                        
                        RETURN;
                END;
            END IF; 
        END LOOP;
    ELSE
        -- 고객쿠폰 발행     
        FOR MYREC1 IN CUR_1(vLVL_CD) LOOP
            -- 첫충전 / 가입 / 생일쿠폰/첫구매 발생인 경우 재발행 체크
            IF PSV_PRT_DIV IN ('02', '03', '04', '07') THEN
                SELECT  COUNT(*) INTO nRECCNT
                FROM    C_COUPON_CUST       CCC
                      , C_COUPON_ITEM_GRP   CCI
                WHERE   CCC.COMP_CD   = CCI.COMP_CD
                AND     CCC.COUPON_CD = CCI.COUPON_CD
                AND     CCC.GRP_SEQ   = CCI.GRP_SEQ
                AND     CCC.COMP_CD   = MYREC1.COMP_CD
                AND     CCC.COUPON_CD = MYREC1.COUPON_CD
                --AND     CCC.GRP_SEQ   = MYREC1.GRP_SEQ
                AND     1 = (
                             CASE WHEN PSV_PRT_DIV = '02' AND CCC.CERT_FDT = TO_CHAR(SYSDATE, 'YYYYMMDD') AND CCC.GRP_SEQ != MYREC1.GRP_SEQ THEN 0 
                                --WHEN PSV_PRT_DIV = '04' AND CCC.CERT_FDT = TO_CHAR(SYSDATE, 'YYYYMMDD') AND CCC.GRP_SEQ != MYREC1.GRP_SEQ THEN 0
                                  WHEN PSV_PRT_DIV = '04' AND CCC.GRP_SEQ != MYREC1.GRP_SEQ THEN 0 
                                  ELSE 1 
                             END
                            )     
                AND     CCC.CUST_ID   = PSV_CUST_ID
                --AND     CCI.LVL_CD    = MYREC1.LVL_CD
                AND    (
                        1 = (
                             CASE WHEN PSV_PRT_DIV = '02' THEN 1
                                  WHEN PSV_PRT_DIV = '03' THEN 1
                                  WHEN PSV_PRT_DIV = '07' THEN 1
                                  WHEN PSV_PRT_DIV = '04' AND CCC.CERT_FDT BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + 45, - 12), 'YYYYMMDD') AND TO_CHAR(SYSDATE, 'YYYYMMDD') THEN 1
                                  ELSE 0
                             END
                            )
                       )    
                AND     CCI.PRT_DIV   = PSV_PRT_DIV
                AND     CCC.USE_STAT  != '32';
                
                -- 가입, 생일쿠폰이 이미 발급되어 있으면 SKIP                               
                CONTINUE WHEN nRECCNT != 0; 
            END IF;
            
            IF MYREC1.RESTRI_YN = 'Y' THEN
                SELECT  COUNT(*) INTO nRECCNT
                FROM    C_COUPON_CUST
                WHERE   COMP_CD   = MYREC1.COMP_CD
                AND     COUPON_CD = MYREC1.COUPON_CD
                AND     CUST_ID   = PSV_CUST_ID
                AND     USE_STAT  != '32';
                
                -- 제한발생 대상일때 이미 발급되어 있으면 SKIP                               
                CONTINUE WHEN nRECCNT != 0;
            END IF;
            
            -- 발행 건수 제한 체크
            CONTINUE WHEN MYREC1.MAX_PROM_CNT > 0 AND MYREC1.MAX_PROM_CNT <= MYREC1.CUST_CNT;
            
            -- 인증번호    
            vCERTNO := FN_GET_COUPON_CERT(PSV_COMP_CD, vCUST_STAT, nRTNCODE, vRTNMSG);
            
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
                    WHERE   COMP_CD = PSV_COMP_CD
                    AND     CUST_ID = PSV_CUST_ID
                   ) CST
            ON     (        
                            CCC.COMP_CD   = CST.COMP_CD
                    AND     CCC.COUPON_CD = MYREC1.COUPON_CD
                    AND     CCC.CERT_NO   = vCERTNO
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
                      , MYREC1.COUPON_CD
                      , vCERTNO
                      , CST.CUST_ID
                      , CST.LVL_CD
                      , MYREC1.GRP_SEQ
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
                      , PSV_SALE_HD.SALE_DT
                      , PSV_SALE_HD.BRAND_CD
                      , PSV_SALE_HD.STOR_CD
                      , PSV_SALE_HD.POS_NO
                      , PSV_SALE_HD.BILL_NO
                      , 'Y'
                      , SYSDATE
                      , 'SYS'
                      , SYSDATE
                      , 'SYS'
                      , CASE WHEN vCUST_STAT IN ('2', '8') THEN '0'
                             WHEN vCUST_STAT IN ('3', '7') THEN '1'
                        END 
                       );
        END LOOP;
    END IF;
    
    -- 첫구매의 경우 리턴 메시지에 인증번호 리턴
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := CASE WHEN PSV_PRT_DIV = '07' THEN vCERTNO ELSE FC_GET_WORDPACK_MSG(PSV_LANG_TP, '1010001392')END;
            
    COMMIT;
    RETURN;
EXCEPTION
    WHEN OTHERS THEN
        PSV_RTN_CD  := SQLCODE;
        PSV_RTN_MSG := SQLERRM;
                        
        ROLLBACK;
        RETURN;
END;

/
