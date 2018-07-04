--------------------------------------------------------
--  DDL for Procedure SP_CROWN_POINT_CHG_PTIME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_POINT_CHG_PTIME" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_STD_DT        IN    VARCHAR2,       -- 변경일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
--------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_POINT_CHG_PTIME
--  Description      : C_CUST.LVL_CD 산정( 매일 AM:5시 실행 )
--  Ref. Table       : C_CARD_SAV_HIS
--------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer : 
--------------------------------------------------------------------------------
IS
    CURSOR CUR_1 IS
        SELECT  V01.COMP_CD
              , V01.CUST_ID
              , V01.CARD_ID
              , V01.USE_DT
              , V01.USE_SEQ
              , V01.STD_DT
              , V01.LOS_PT_DT
              , V01.SAV_USE_DIV
              , V01.MEM_SAV_YN
              , V01.C_LOS_DIV
              , V01.SAV_PT
              , V01.USE_PT
              , V01.C_SAV_PT
              , V01.C_USE_PT
              , CASE WHEN V01.LOS_PT_DT < V01.STD_DT THEN V01.SAV_MLG ELSE 0 END
                                                                        AS CARD_LOS_MLG     -- 카드기준 소멸예정크라운
              , SUM(V01.C_SAV_PT) 
                    OVER(PARTITION BY V01.CUST_ID)                      AS CUST_TOT_SAV_PT  -- 고객기준 총 적립포인트
              , SUM(V01.C_SAV_PT) 
                    OVER(PARTITION BY V01.CUST_ID ORDER BY V01.ROW_NUM) AS CUST_ACC_SAV_PT  -- 고객기준 누적 적립포인트
              , SUM(CASE WHEN V01.LOS_PT_DT < V01.STD_DT THEN V01.C_SAV_PT ELSE 0 END) 
                    OVER(PARTITION BY V01.CUST_ID)                      AS CUST_TOT_LOS_PT  -- 고객기준 총 소멸포인트
              , SUM(V01.C_USE_PT) 
                    OVER(PARTITION BY V01.CUST_ID)                      AS CUST_TOT_USE_PT  -- 고객기준 총 사용포인트
              , V01.ROW_NUM
        FROM   (      
                SELECT  /*+ NO_MERGE LEADING(CRD) 
                            INDEX(CSH PK_C_CARD_SAV_HIS)
                            INDEX(CST PK_C_CUST        ) */
                        CRD.COMP_CD
                      , NVL(CST.CUST_ID, CSH.CARD_ID)                       AS CUST_ID
                      , CSH.CARD_ID
                      , CSH.USE_DT
                      , CSH.USE_TM
                      , CSH.USE_SEQ
                      , CSH.LOS_PT_DT
                      , CSH.SAV_USE_DIV
                      , CASE WHEN CST.MLG_DIV = 'N'AND CST.CUST_STAT = '2' THEN 'Y' ELSE 'N' END AS MEM_SAV_YN -- 가입여부
                      , NVL(PSV_STD_DT, TO_CHAR(SYSDATE - 1, 'YYYYMMDD'))   AS STD_DT           -- 기준일자
                      , CSH.SAV_MLG                                         AS SAV_MLG          -- 적립마일리지
                      , CSH.SAV_PT                                                              -- 적립포인트
                      , CSH.USE_PT                                                              -- 사용포인트
                      , CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN ABS(CSH.USE_PT)
                             ELSE 0
                        END                                                 AS C_SAV_PT         -- 실제 적립포인트
                      , CASE WHEN CSH.SAV_USE_DIV IN ('102', '202')                  THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) < 0 THEN ABS(CSH.SAV_PT)
                             WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) > 0 THEN ABS(CSH.USE_PT)
                             ELSE 0
                        END                                                 AS C_USE_PT         -- 실제 사용포인트
                      , CASE WHEN CSH.SAV_USE_DIV IN ('101', '201')                  THEN 'Y'   -- 101 회원가입, 201 적립
                             WHEN CSH.SAV_USE_DIV = '203'   AND SIGN(CSH.SAV_PT) > 0 THEN 'Y'   -- 203 적립누락
                             WHEN CSH.SAV_USE_DIV LIKE '9%' AND SIGN(CSH.SAV_PT) > 0 THEN 'Y'   -- 901 조정, 092 이전, 903 기타
                             WHEN CSH.SAV_USE_DIV LIKE '3%' AND SIGN(CSH.USE_PT) < 0 THEN 'Y'   -- 301 사용, 301 사용반품, 303 사용누락
                             ELSE 'N'
                        END                                                 AS C_LOS_DIV        -- 소멸 대상 구분
                      , ROW_NUMBER() OVER(PARTITION BY NVL(CST.CUST_ID, CSH.CARD_ID) ORDER BY CSH.USE_DT, CSH.USE_TM) AS ROW_NUM
                FROM    C_CARD_SAV_HIS CSH
                      , C_CUST         CST
                      , C_CARD         CRD
                WHERE   CRD.COMP_CD    = CST.COMP_CD (+)
                AND     CRD.CUST_ID    = CST.CUST_ID (+)
                AND     CRD.COMP_CD    = CSH.COMP_CD
                AND     CRD.CARD_ID    = CSH.CARD_ID
                AND     CRD.COMP_CD    = PSV_COMP_CD
                AND     CSH.LOS_PT_YN  = 'N'
               ) V01
        ORDER BY 
                V01.CUST_ID
              , V01.ROW_NUM;

    ERR_HANDLER     EXCEPTION;
    vNEW_LVL_CD     C_CUST.LVL_CD%TYPE;
    vNEW_LVL_RANK   C_CUST_LVL.LVL_RANK%TYPE;
    vLVL_START_DT   C_CUST.LVL_START_DT%TYPE;
    vLVL_CLOSE_DT   C_CUST.LVL_CLOSE_DT%TYPE;
    nCUR_LOS_PT     C_CUST.LOS_PT%TYPE := 0;         -- 현재 소멸 대상
    nACC_LOS_PT     C_CUST.LOS_PT%TYPE := 0;         -- 누적 소멸 대상
    nCUST_BILL_CNT  NUMBER(5)          := 0;         -- 고객 매입 건수
BEGIN
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := 'OK';

    FOR MYREC IN CUR_1 LOOP
        -- 소멸 처리 계산
        IF MYREC.LOS_PT_DT < MYREC.STD_DT THEN
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

            -- 기준일자 경과한 경우 소멸처리
            BEGIN
                -- 적립이력 소멸처리
                UPDATE  C_CARD_SAV_HIS
                SET     LOS_MLG    = MYREC.CARD_LOS_MLG
                      , LOS_PT     = nCUR_LOS_PT
                      , LOS_PT_YN = 'Y'
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
