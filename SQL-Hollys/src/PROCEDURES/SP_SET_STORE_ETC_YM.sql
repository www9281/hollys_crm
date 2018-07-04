--------------------------------------------------------
--  DDL for Procedure SP_SET_STORE_ETC_YM
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_SET_STORE_ETC_YM" 
   (
    PSV_COMP_CD     IN  VARCHAR2,   -- 회사코드
    PSV_PRC_YM      IN  VARCHAR2,   -- 기준년월
    PSV_BRAND_CD    IN  VARCHAR2,   -- 영업조직
    PSV_STOR_CD     IN  VARCHAR2,   -- 점포코드
    PSV_RTN_CODE   OUT  VARCHAR2,   -- RETURN CODE
    PSV_RTN_MSG    OUT  VARCHAR2    -- RETURN MESSAGE
   ) IS
    CURSOR CUR_1 IS
        SELECT TO_CHAR(ADD_MONTHS(TO_DATE(PSV_PRC_YM, 'YYYYMM'), ROWNUM - 1), 'YYYYMM') PRC_YM
        FROM   TAB
        WHERE  ROWNUM <= (MONTHS_BETWEEN(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM'), 'YYYYMM'), TO_DATE(PSV_PRC_YM, 'YYYYMM')) + 1); 

    CURSOR CUR_2(vPRC_YM IN VARCHAR2) IS
        SELECT  DISTINCT 
                COMP_CD
              , BRAND_CD
              , STOR_CD
        FROM    STORE_ETC_AMT
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     PRC_DT  LIKE vPRC_YM||'%'
        AND     CONFIRM_YN = 'Y'
        AND    (PSV_BRAND_CD IS NULL OR BRAND_CD = PSV_BRAND_CD)
        AND    (PSV_STOR_CD  IS NULL OR STOR_CD  = PSV_STOR_CD )
        UNION
        SELECT  COMP_CD
              , BRAND_CD
              , STOR_CD
        FROM    STORE_ETC_YM
        WHERE   COMP_CD    = PSV_COMP_CD
        AND     PRC_YM     = TO_CHAR(ADD_MONTHS(TO_DATE(vPRC_YM, 'YYYYMM'), -1), 'YYYYMM')
        AND     DATA_DIV   = '2'
        AND    (PSV_BRAND_CD IS NULL OR BRAND_CD = PSV_BRAND_CD)
        AND    (PSV_STOR_CD  IS NULL OR STOR_CD  = PSV_STOR_CD );

    CURSOR CUR_3(
                 vCOMP_CD   IN VARCHAR2,
                 vBRAND_CD  IN VARCHAR2,
                 vSTOR_CD   IN VARCHAR2,
                 vPRC_YM    IN VARCHAR2
                ) IS
        SELECT  COMP_CD
              , BRAND_CD
              , STOR_CD
              , PRC_YM
              , SUM(ETC_AMT)   AS ETC_AMT
              , SUM(BEGIN_AMT) AS BEGIN_AMT
        FROM   (        
                SELECT  COMP_CD
                      , BRAND_CD
                      , STOR_CD
                      , vPRC_YM AS PRC_YM
                      , CASE WHEN ETC_DIV = '01' THEN ETC_AMT 
                             ELSE ETC_AMT * (-1)
                        END     AS ETC_AMT
                      , 0       AS BEGIN_AMT                                                                            
                FROM    STORE_ETC_AMT
                WHERE   COMP_CD    = vCOMP_CD
                AND     PRC_DT  LIKE vPRC_YM||'%'
                AND     BRAND_CD   = vBRAND_CD
                AND     STOR_CD    = vSTOR_CD
                AND     CONFIRM_YN = 'Y'
                UNION ALL
                SELECT  COMP_CD
                      , BRAND_CD
                      , STOR_CD
                      , vPRC_YM AS PRC_YM
                      , 0           AS ETC_AMT
                      , END_AMT     AS BEGIN_AMT                                                                            
                FROM    STORE_ETC_YM
                WHERE   COMP_CD    = vCOMP_CD
                AND     PRC_YM     = TO_CHAR(ADD_MONTHS(TO_DATE(vPRC_YM, 'YYYYMM'), -1), 'YYYYMM')
                AND     DATA_DIV   = '2'
                AND     BRAND_CD   = vBRAND_CD
                AND     STOR_CD    = vSTOR_CD
               )
        GROUP BY
                COMP_CD
              , BRAND_CD
              , STOR_CD
              , PRC_YM;

    nRECCNT     NUMBER :=0;
    vRMK_NM     VARCHAR2(2000) := NULL;
BEGIN
    FOR MYREC1 IN CUR_1 LOOP
        -- STORE_ETC_YM 테이블 초기화
        UPDATE  STORE_ETC_YM
        SET     BEGIN_AMT = 0
              , END_AMT   = 0
        WHERE   COMP_CD  = PSV_COMP_CD
        AND     PRC_YM   = MYREC1.PRC_YM
        AND     DATA_DIV = '2';

        FOR MYREC2 IN CUR_2(MYREC1.PRC_YM) LOOP
            FOR MYREC3 IN CUR_3(MYREC2.COMP_CD, MYREC2.BRAND_CD, MYREC2.STOR_CD, MYREC1.PRC_YM) LOOP
                MERGE INTO STORE_ETC_YM SEY
                USING DUAL
                ON (
                        SEY.COMP_CD  = MYREC3.COMP_CD
                    AND SEY.PRC_YM   = MYREC3.PRC_YM
                    AND SEY.BRAND_CD = MYREC3.BRAND_CD
                    AND SEY.STOR_CD  = MYREC3.STOR_CD
                    AND SEY.DATA_DIV = '2'
                   )
                WHEN MATCHED THEN
                    UPDATE  
                    SET     BEGIN_AMT = MYREC3.BEGIN_AMT
                          , END_AMT   = MYREC3.BEGIN_AMT + MYREC3.ETC_AMT
                          , UPD_DT    = SYSDATE
                          , UPD_USER  = 'SYS'
                WHEN NOT MATCHED THEN
                    INSERT
                   (          
                    COMP_CD         , PRC_YM
                  , BRAND_CD        , STOR_CD
                  , DATA_DIV        
                  , ETC_CD          , ETC_AMT
                  , BEGIN_AMT       , END_AMT
                  , ETC_DESC        , USE_YN
                  , INST_DT         , INST_USER
                  , UPD_DT          , UPD_USER
                   )
                    VALUES
                   (          
                    MYREC3.COMP_CD  , MYREC3.PRC_YM
                  , MYREC3.BRAND_CD , MYREC3.STOR_CD
                  , '2'        
                  , '133'           , 0
                  , MYREC3.BEGIN_AMT, MYREC3.BEGIN_AMT + MYREC3.ETC_AMT
                  , '전도금이월'    , 'Y'
                  , SYSDATE         , 'SYS'
                  , SYSDATE         , 'SYS'
                   ); 
            END LOOP;
        END LOOP;
    END LOOP;

    PSV_RTN_CODE := '0000';
    PSV_RTN_MSG  := 'OK';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;

        PSV_RTN_CODE := SQLCODE;
        PSV_RTN_MSG  := SQLERRM;
END SP_SET_STORE_ETC_YM;

/
