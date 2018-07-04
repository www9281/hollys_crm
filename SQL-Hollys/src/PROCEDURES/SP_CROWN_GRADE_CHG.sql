--------------------------------------------------------
--  DDL for Procedure SP_CROWN_GRADE_CHG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_GRADE_CHG" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_STD_DT        IN    VARCHAR2,       -- 변경일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
---------------------------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_GRADE_CHG
--  Description      : C_CUST.LVL_CD 산정( 매일 AM:5시 실행)
--  Ref. Table       : C_CARD_SAV_HIS
---------------------------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
    CURSOR CUR_1 IS
        SELECT  V02.COMP_CD                           , V02.CUST_ID
              , V02.CARD_ID                           , V02.USE_DT
              , V02.USE_SEQ                           , V02.BIRTH_DT
              , V02.LVL_CD                            , V02.LVL_RANK
              , V02.LVL_START_DT                      , V02.LVL_CLOSE_DT
              , V02.JOIN_DT                           , V02.LAST_USE_DT -- 최종 적립 일자
              , V02.STD_DT                            , V02.CST_SAV_MLG
              , V02.LOS_MLG_DT                        , V02.C_LOS_DIV
              , V02.SAV_PT                            , V02.USE_PT
              , V02.C_SAV_PT                          , V02.C_USE_PT
              , V02.CUST_KEEP_SAV_MLG                 , V02.LVL_STD_STR
              , CASE WHEN V02.LOS_MLG_DT < V02.STD_DT THEN V02.SAV_MLG ELSE 0 END       AS CARD_LOS_MLG     -- 카드기준 소멸예정크라운
              , SUM(CASE WHEN V02.LOS_MLG_DT < V02.STD_DT THEN V02.SAV_MLG ELSE 0 END) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_LOS_MLG     -- 고객기준 소멸예정크라운
              , SUM(CASE WHEN V02.LOS_MLG_DT < TO_CHAR(TO_DATE(V02.STD_DT, 'YYYYMMDD')-1, 'YYYYMMDD') THEN 0 ELSE V02.SAV_MLG END) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_SAV_MLG     -- 고객기준 적립크라운
              , SUM(V02.REM_MLG) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_REM_MLG     -- 고객기준 잔여크라운(12+1 쿠폰발급 후)
              , SUM(V02.C_SAV_PT) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_TOT_SAV_PT  -- 고객기준 총 적립포인트
              , SUM(V02.C_SAV_PT) 
                    OVER(PARTITION BY V02.CUST_ID ORDER BY V02.ROW_NUM)                 AS CUST_ACC_SAV_PT  -- 고객기준 누적 적립포인트
              , SUM(CASE WHEN V02.LOS_MLG_DT < V02.STD_DT THEN V02.C_SAV_PT ELSE 0 END) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_TOT_LOS_PT  -- 고객기준 총 소멸포인트
              , SUM(V02.C_USE_PT) 
                    OVER(PARTITION BY V02.CUST_ID)                                      AS CUST_TOT_USE_PT  -- 고객기준 총 사용포인트      
              , V02.ROW_NUM
        FROM   (
                SELECT  V01.COMP_CD                           , V01.CUST_ID
                      , V01.CARD_ID                           , V01.USE_DT
                      , V01.USE_SEQ                           , V01.BIRTH_DT
                      , V01.LVL_CD                            , LVL.LVL_RANK
                      , V01.LVL_START_DT                      , V01.LVL_CLOSE_DT
                      , V01.JOIN_DT
                      , LAST_VALUE(LAST_USE_DT) 
                            OVER(PARTITION BY V01.CUST_ID ORDER BY USE_DT, USE_SEQ RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_USE_DT -- 최종 적립 일자
                      , V01.STD_DT                            , V01.CST_SAV_MLG
                      , V01.SAV_MLG                           , V01.REM_MLG
                      /*▼▼▼ 등급 유지조건이 기준일자보다 작은 경우 유지조건(등업 후 30개)을 만족하는지 체크 ▼▼▼*/
                      , V01.LOS_MLG_DT
                      , V01.C_LOS_DIV                         , LVL.LVL_STD_STR
                      , V01.SAV_PT                            , V01.USE_PT
                      , V01.C_SAV_PT                          , V01.C_USE_PT
                      , V01.CUST_KEEP_SAV_MLG                 , V01.ROW_NUM
                FROM    C_CUST_LVL LVL
                      ,(
                        SELECT  COMP_CD
                              , MAX(LVL_STD_STR) LVL_STD_STR
                        FROM    C_CUST_LVL
                        WHERE   COMP_CD = PSV_COMP_CD
                        AND     USE_YN  = 'Y'
                        GROUP BY
                                COMP_CD
                       ) CL1
                      ,(      
                        SELECT  /*+ LEADING(CST) USE_NL(CST CRD CSH SUL) 
                                    INDEX(CSH PK_C_CARD_SAV_HIS)
                                    INDEX(SUL PK_C_CARD_SAV_USE_HIS) */
                                CST.COMP_CD                                       , CST.CUST_ID
                              , CSH.CARD_ID                                       , CSH.USE_DT
                              , CSH.USE_TM                                        , CSH.USE_SEQ
                              , CSH.LOS_MLG_DT                                    , CST.BIRTH_DT
                              , CST.SAV_MLG                                         AS CST_SAV_MLG      -- 총 적립 마일리지
                              , CST.LVL_CD                                                              -- 현재등급
                              , CST.LVL_START_DT                                                        -- 등급 유효기간 시작일
                              , CST.LVL_CLOSE_DT                                                        -- 등급 유효기간 종료일
                              , CST.JOIN_DT                                                             -- 가입일자
                              , NVL(PSV_STD_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'))       AS STD_DT           -- 기준일자
                              , CSH.SAV_MLG                                         AS SAV_MLG          -- 적립마일리지
                              , SUL.SAV_MLG - SUL.USE_MLG - SUL.LOS_MLG_UNUSE       AS REM_MLG          -- 잔여마일리지(쿠폰발급 후)
                              , SUM(CASE WHEN CSH.USE_DT BETWEEN CST.LVL_START_DT AND CST.LVL_CLOSE_DT THEN CSH.SAV_MLG ELSE 0 END) OVER(PARTITION BY CST.CUST_ID) AS CUST_KEEP_SAV_MLG
                              , CSH.SAV_PT                                          AS SAV_PT           -- 적립포인트
                              , CSH.USE_PT                                          AS USE_PT           -- 사용포인트
                              , CASE WHEN CSH.SAV_MLG > 0 THEN CSH.USE_DT ELSE NULL END AS LAST_USE_DT  -- 최종 적립 일자
                              , CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN ABS(CSH.SAV_PT)
                                     WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT)
                                     WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT) 
                                     WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN ABS(CSH.USE_PT)
                                     ELSE 0
                                END                                                 AS C_SAV_PT           -- 실제 적립포인트
                              , CASE WHEN CSH.SAV_USE_DIV IN ('102', '202')                  THEN ABS(CSH.SAV_PT)
                                     WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT)
                                     WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT) 
                                     WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) > 0 THEN ABS(CSH.USE_PT)
                                     ELSE 0
                                END                                                 AS C_USE_PT           -- 실제 사용포인트
                              , CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN 'Y'
                                     WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN 'Y'
                                     WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN 'Y' 
                                     WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN 'Y'
                                     ELSE 'N'
                                END                                                 AS C_LOS_DIV            -- 소멸 대상 구분
                              , ROW_NUMBER() OVER(PARTITION BY CST.CUST_ID ORDER BY CSH.USE_DT, CSH.USE_TM) AS ROW_NUM
                        FROM   (
                                SELECT  /*+ LEADING(CST)
                                            INDEX(CST IDX05_C_CUST) 
                                            INDEX(CRD PK_C_CARD) */
                                        CST.COMP_CD
                                      , CST.CUST_ID
                                      , CRD.CARD_ID
                                      , CST.SAV_MLG
                                      , CST.LVL_CD                                                              -- 현재등급
                                      , CST.LVL_START_DT                                                        -- 등급 유효기간 시작일
                                      , CST.LVL_CLOSE_DT                                                        -- 등급 유효기간 종료일
                                      , CST.JOIN_DT                                                             -- 가입일자
                                      , CST.BIRTH_DT
                                FROM    C_CUST             CST
                                      , C_CARD             CRD
                                WHERE   CRD.COMP_CD    = CST.COMP_CD
                                AND     CRD.CUST_ID    = CST.CUST_ID
                                AND     CST.COMP_CD    = PSV_COMP_CD
                                AND     CST.MLG_DIV    = 'N'
                                AND     CST.CUST_STAT  IN ('2', '3', '7', '8')  -- 메버십 가입 고객
                               ) CST  
                              , C_CARD_SAV_HIS     CSH
                              , C_CARD_SAV_USE_HIS SUL                        
                        WHERE   CST.COMP_CD    = CSH.COMP_CD
                        AND     CST.CARD_ID    = CSH.CARD_ID
                        AND     CSH.COMP_CD    = SUL.COMP_CD
                        AND     CSH.CARD_ID    = SUL.CARD_ID
                        AND     CSH.USE_DT     = SUL.USE_DT
                        AND     CSH.USE_SEQ    = SUL.USE_SEQ
                        AND     CSH.LOS_MLG_YN = 'N'
                        AND     CSH.SAV_USE_FG = '1'          -- 마일리지 적립
                       ) V01
                WHERE   V01.COMP_CD = LVL.COMP_CD
                AND     V01.LVL_CD  = LVL.LVL_CD
                AND     V01.COMP_CD = CL1.COMP_CD
                AND     LVL.USE_YN  = 'Y'
                ORDER BY 
                        V01.CUST_ID
                      , V01.ROW_NUM
            ) V02;
              
    ERR_HANDLER     EXCEPTION;
    
    ARR_SALE_HD     PKG_TYPE.TRG_SALE_HD;
    
    vNEW_LVL_CD     C_CUST.LVL_CD%TYPE;
    vNEW_LVL_RANK   C_CUST_LVL.LVL_RANK%TYPE;
    vMAX_LVL_RANK   C_CUST_LVL.LVL_RANK%TYPE;
    vLVL_START_DT   C_CUST.LVL_START_DT%TYPE;
    vLVL_CLOSE_DT   C_CUST.LVL_CLOSE_DT%TYPE;
    nCUR_LOS_PT     C_CUST.LOS_PT%TYPE;         -- 현재 소멸 대상
    nACC_LOS_PT     C_CUST.LOS_PT%TYPE;         -- 누적 소멸 대상
    
    nARG_RTN_CD     NUMBER;
    nCPN_PRT_CNT    NUMBER;                     -- 12+1 적립쿠폰 발행건수
    nDEF_CPN_CNT    NUMBER;                     -- 쿠폰 발행 차이 수량
    vARG_RTN_MSG    VARCHAR2(2000) := NULL;
BEGIN
    PSV_RTN_CD := 0;
    PSV_RTN_MSG := 'OK';
    
    FOR MYREC IN CUR_1 LOOP
        -- 고객번호 기분
        IF MYREC.ROW_NUM = 1 THEN
            /******** 등급 취득 방번 변경 ****************************************************
            -- 새로운 등급/순위
            vNEW_LVL_CD   := CASE WHEN MYREC.CUST_SAV_MLG >= 30 THEN '103' -- PLATINUM(구 RED)
                                  WHEN MYREC.CUST_SAV_MLG >= 5  THEN '102' -- GOLD(구 BLACK)
                                  ELSE '101'                               -- RED(구 BROWN)
                             END;
            vNEW_LVL_RANK := CASE WHEN MYREC.CUST_SAV_MLG >= 30 THEN 3
                                  WHEN MYREC.CUST_SAV_MLG >= 5  THEN 2
                                  ELSE 1
                             END;
            ********* 등급 취득 방번 변경 ***************************************************/
            
            -- 새로운 등급/순위
            SELECT  LVL_CD     , LVL_RANK     , MAX_LVL_RANK
            INTO    vNEW_LVL_CD, vNEW_LVL_RANK, vMAX_LVL_RANK
            FROM   (
                    SELECT  CASE WHEN (CASE WHEN MYREC.CUST_SAV_MLG < 0 THEN 0 ELSE MYREC.CUST_SAV_MLG END) BETWEEN LVL_STD_STR AND LVL_STD_END THEN LVL_CD
                                 ELSE NULL
                            END  AS LVL_CD, 
                            CASE WHEN (CASE WHEN MYREC.CUST_SAV_MLG < 0 THEN 0 ELSE MYREC.CUST_SAV_MLG END) BETWEEN LVL_STD_STR AND LVL_STD_END THEN LVL_RANK
                                 ELSE NULL
                            END  AS LVL_RANK,
                            MAX(LVL_RANK) OVER() MAX_LVL_RANK
                    FROM    C_CUST_LVL
                    WHERE   COMP_CD = MYREC.COMP_CD
                    AND     USE_YN = 'Y'
                   )
            WHERE   LVL_RANK IS NOT NULL;
                
            -- 레벨 UP/DOWN               
            IF MYREC.LVL_RANK > vNEW_LVL_RANK THEN
                -- 고객등급 하향 일때 회원유지 조건 체크
                vNEW_LVL_CD   := CASE WHEN MYREC.STD_DT BETWEEN MYREC.LVL_START_DT AND MYREC.LVL_CLOSE_DT THEN MYREC.LVL_CD
                                      ELSE vNEW_LVL_CD
                                 END;
                vNEW_LVL_RANK := CASE WHEN MYREC.STD_DT BETWEEN MYREC.LVL_START_DT AND MYREC.LVL_CLOSE_DT THEN MYREC.LVL_RANK
                                      ELSE vNEW_LVL_RANK
                                 END;
                -- 등급 유지 시작/종료 일자
                vLVL_START_DT := MYREC.LVL_START_DT;
                vLVL_CLOSE_DT := MYREC.LVL_CLOSE_DT;
                
            ELSIF MYREC.LVL_RANK < vNEW_LVL_RANK THEN
                vLVL_START_DT := TO_CHAR(SYSDATE, 'YYYYMMDD');
                vLVL_CLOSE_DT := TO_CHAR(ADD_MONTHS(SYSDATE - 1, 12), 'YYYYMMDD');
                
                -- 등업
                IF vNEW_LVL_RANK >= vMAX_LVL_RANK AND MYREC.LOS_MLG_DT = TO_CHAR(TO_DATE(MYREC.STD_DT, 'YYYYMMDD')-1, 'YYYYMMDD') THEN
                    MYREC.LOS_MLG_DT   := vLVL_CLOSE_DT;
                    MYREC.CARD_LOS_MLG := 0;
                END IF;
            ELSE
                -- 등급 재산정 시점에 최종 등급 이면서 최종 적립일이 기준일자 이상인 경우 유효기간 연장 
                IF vNEW_LVL_RANK >= vMAX_LVL_RANK AND MYREC.CUST_KEEP_SAV_MLG >= MYREC.LVL_STD_STR THEN
                    vLVL_START_DT := TO_CHAR(SYSDATE, 'YYYYMMDD');
                    vLVL_CLOSE_DT := TO_CHAR(ADD_MONTHS(SYSDATE - 1, 12), 'YYYYMMDD');
                ELSE
                    vLVL_START_DT := MYREC.LVL_START_DT;
                    vLVL_CLOSE_DT := MYREC.LVL_CLOSE_DT;
                END IF;
            END IF;
            
            IF vNEW_LVL_RANK < vMAX_LVL_RANK THEN
                vLVL_START_DT := NULL;
                vLVL_CLOSE_DT := NULL;
            END IF;
                
            -- 회원정보 UPDATE(소멸포인트는 C_CARD_SAV_HIS 트리거에서 처리)
            -- C_CARD_SAV_HIS -> C_CARD, C_CUST
            BEGIN
                UPDATE  C_CUST
                SET     LVL_CD       = vNEW_LVL_CD
                      , LVL_START_DT = vLVL_START_DT
                      , LVL_CLOSE_DT = vLVL_CLOSE_DT
                      , UPD_DT       = SYSDATE
                      , UPD_USER     = 'SYSB'
                WHERE   COMP_CD      = MYREC.COMP_CD
                AND     CUST_ID      = MYREC.CUST_ID;
            EXCEPTION
                WHEN OTHERS THEN
                    PSV_RTN_CD  := SQLCODE;
                    PSV_RTN_MSG := SQLERRM;
                    
                    ROLLBACK;
                    
                    RETURN;
            END;
            
            /*** 고객등급이 상향 되면 쿠폰을 발급 ***
            IF MYREC.LVL_RANK < vNEW_LVL_RANK THEN
                SP_CROWN_COUPON_BLD(MYREC.COMP_CD, PSV_LANG_TP, MYREC.CUST_ID, '01', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
              
                IF nARG_RTN_CD != 0 THEN
                    ROLLBACK;
                
                    PSV_RTN_CD  := nARG_RTN_CD;
                    PSV_RTN_MSG := vARG_RTN_MSG;
                    
                    RETURN;
                END IF;
            END IF;
            ********************************************/
            
            -- 생일쿠폰 발생/가입쿠폰은 별도 처리
            /**** 생일 쿠폰은 크라운 발생과 관계없이 생성(CUT) ***
            IF SUBSTR(MYREC.BIRTH_DT, 5, 4) >= TO_CHAR(SYSDATE - 7, 'MMDD') AND SUBSTR(MYREC.BIRTH_DT, 5, 4) <= TO_CHAR(SYSDATE, 'MMDD') THEN
                SP_CROWN_COUPON_BLD(MYREC.COMP_CD, PSV_LANG_TP, MYREC.CUST_ID, '4', nARG_RTN_CD, vARG_RTN_MSG);
                
                -- 생일쿠폰 발생 오류는 체크 없음.
            END IF;
            *****************************************************/
            
            -- 크라운이 12개 적립되면 음표쿠폰 발행
            IF MYREC.CUST_REM_MLG > 0 AND TRUNC(MYREC.CUST_REM_MLG / 12) > 0 THEN
                nDEF_CPN_CNT := TRUNC(MYREC.CUST_REM_MLG / 12);
                
                IF nDEF_CPN_CNT > 0 THEN
                    FOR i IN 1..nDEF_CPN_CNT LOOP
                        SP_CROWN_COUPON_BLD(MYREC.COMP_CD, PSV_LANG_TP, MYREC.CUST_ID, '05', ARR_SALE_HD, nARG_RTN_CD, vARG_RTN_MSG);
                    END LOOP;
                END IF; 
            END IF;
            
            -- 고객이 바뀌면 소멸 대상을 초기화
            nCUR_LOS_PT := 0;
            nACC_LOS_PT := 0;
        END IF;
        
        -- 기준일자 경과한 경우 소멸처리
        IF MYREC.LOS_MLG_DT < MYREC.STD_DT THEN
            IF MYREC.C_LOS_DIV = 'Y' AND MYREC.CUST_TOT_LOS_PT > MYREC.CUST_TOT_USE_PT THEN
                IF MYREC.CUST_ACC_SAV_PT > MYREC.CUST_TOT_USE_PT THEN
                    nCUR_LOS_PT := MYREC.CUST_ACC_SAV_PT - MYREC.CUST_TOT_USE_PT - nACC_LOS_PT;
                ELSE 
                    nCUR_LOS_PT := 0;    
                END IF;
            ELSE
                nCUR_LOS_PT := 0;          
            END IF;
            
            -- 누적 소멸 포인트
            nACC_LOS_PT := nACC_LOS_PT + nCUR_LOS_PT;
            
            BEGIN
                -- 적립이력 소멸처리
                UPDATE  C_CARD_SAV_HIS
                SET     LOS_MLG    = MYREC.CARD_LOS_MLG
                      , LOS_PT     = nCUR_LOS_PT
                      , LOS_MLG_YN = 'Y'
                      , UPD_DT     = SYSDATE
                      , UPD_USER   = 'SYSB'
                WHERE   COMP_CD    = MYREC.COMP_CD
                AND     CARD_ID    = MYREC.CARD_ID
                AND     USE_DT     = MYREC.USE_DT
                AND     USE_SEQ    = MYREC.USE_SEQ;
            EXCEPTION
                WHEN OTHERS THEN
                    PSV_RTN_CD  := SQLCODE;
                    PSV_RTN_MSG := SQLERRM;
                    
                    ROLLBACK;
                    
                    RETURN;
            END;
        END IF;
    END LOOP;
    
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
