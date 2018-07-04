--------------------------------------------------------
--  DDL for Procedure SP_CROWN_GRADE_CHG_PTIME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CROWN_GRADE_CHG_PTIME" 
(
    PSV_COMP_CD       IN    VARCHAR2,       -- 회사코드
    PSV_LANG_TP       IN    VARCHAR2,       -- 언어타입
    PSV_STD_DT        IN    VARCHAR2,       -- 변경일자
    PSV_RTN_CD        OUT   NUMBER,         -- 처리코드
    PSV_RTN_MSG       OUT   VARCHAR2        -- 처리Message
)
--------------------------------------------------------------------------------
--  Procedure Name   : SP_CROWN_GRADE_CHG
--  Description      : C_CUST.LVL_CD 산정( 매일 AM:5시 실행 )
--  Ref. Table       : C_CARD_SAV_HIS
--------------------------------------------------------------------------------
--  Create Date      : 
--  Create Programer : 
--  Modify Date      : 
--  Modify Programer : 
--------------------------------------------------------------------------------
IS
    CURSOR CUR_1(vSTD_DT IN VARCHAR2) IS
        SELECT  V01.COMP_CD
              , V01.CUST_ID
              , AVG(V01.GRD_AMT) AVG_GRD_AMT
              , AVG(V01.BRD_CNT) AVG_BRD_CNT
        FROM   (      
                SELECT  CST.COMP_CD
                      , CST.CUST_ID
                      , SUBSTR(ENT.ENTRY_DT, 1, 6)      AS ENTRY_YM
                      , SUM(ENT.GRD_AMT)                AS GRD_AMT
                      , COUNT(DISTINCT ENT.BRAND_CD)    AS BRD_CNT
                      , MIN(SUBSTR(ENT.ENTRY_DT, 1, 6)) AS MIN_ENTRY_YM
                      , MAX(SUBSTR(ENT.ENTRY_DT, 1, 6)) AS MAX_ENTRY_YM
                FROM    C_CUST         CST
                      , CS_ENTRY_HD    ENT
                WHERE   ENT.COMP_CD    = CST.COMP_CD
                AND     ENT.MEMBER_NO  = CST.MEMBER_NO
                AND     ENT.COMP_CD    = PSV_COMP_CD
                AND     ENT.ENTRY_DT  >= TO_CHAR(ADD_MONTHS(TO_DATE(vSTD_DT, 'YYYYMMDD'), -12), 'YYYYMM')
                AND     ENT.ENTRY_DT  <= TO_CHAR(ADD_MONTHS(TO_DATE(vSTD_DT, 'YYYYMMDD'), - 1), 'YYYYMM')
                GROUP BY
                        CST.COMP_CD
                      , CST.CUST_ID
                      , SUBSTR(ENT.ENTRY_DT, 1, 6)
               ) V01
        ORDER BY 
                V01.COMP_CD
              , V01.CUST_ID;

    ERR_HANDLER     EXCEPTION;
    vNEW_LVL_CD     C_CUST.LVL_CD%TYPE;
    vNEW_LVL_RANK   C_CUST_LVL.LVL_RANK%TYPE;
    vLVL_START_DT   C_CUST.LVL_START_DT%TYPE;
    vLVL_CLOSE_DT   C_CUST.LVL_CLOSE_DT%TYPE;
    nCUR_LOS_PT     C_CUST.LOS_PT%TYPE;         -- 현재 소멸 대상
    nACC_LOS_PT     C_CUST.LOS_PT%TYPE;         -- 누적 소멸 대상
    nCUST_BILL_CNT  NUMBER(5) := 0;             -- 고객 매입 건수
BEGIN
    PSV_RTN_CD  := 0;
    PSV_RTN_MSG := 'OK';

    FOR MYREC IN CUR_1(NVL(PSV_STD_DT, TO_CHAR(SYSDATE, 'YYYYMMDD'))) LOOP
        -- 새로운 등급 
        vNEW_LVL_CD   := CASE WHEN MYREC.AVG_GRD_AMT >= 200000 AND MYREC.AVG_BRD_CNT >= 3 THEN '105' --1등급
                              WHEN MYREC.AVG_GRD_AMT >= 200000 AND MYREC.AVG_BRD_CNT >= 1 THEN '104' --2등급
                              WHEN MYREC.AVG_GRD_AMT BETWEEN 100000 AND 199999            THEN '103' --3등급
                              WHEN MYREC.AVG_GRD_AMT BETWEEN  50000 AND  99999            THEN '102' --4등급
                              ELSE                                                             '101' --5등급
                         END;
        vNEW_LVL_RANK := CASE WHEN MYREC.AVG_GRD_AMT >= 200000 AND MYREC.AVG_BRD_CNT >= 3 THEN    5 --1등급
                              WHEN MYREC.AVG_GRD_AMT >= 200000 AND MYREC.AVG_BRD_CNT >= 1 THEN    4 --2등급
                              WHEN MYREC.AVG_GRD_AMT BETWEEN 100000 AND 199999            THEN    3 --3등급
                              WHEN MYREC.AVG_GRD_AMT BETWEEN  50000 AND  99999            THEN    2 --4등급
                              ELSE                                                                1 --5등급
                         END;

        -- 회원정보 UPDATE(소멸포인트는 C_CARD_SAV_HIS 트리거에서 처리)
        -- C_CARD_SAV_HIS -> C_CARD, C_CUST
        BEGIN
            UPDATE  C_CUST
            SET     LVL_CD       = vNEW_LVL_CD
            WHERE   COMP_CD      = MYREC.COMP_CD
            AND     CUST_ID      = MYREC.CUST_ID;
        EXCEPTION
            WHEN OTHERS THEN
                PSV_RTN_CD  := SQLCODE;
                PSV_RTN_MSG := SQLERRM;

                ROLLBACK;

                RETURN;
        END;
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
