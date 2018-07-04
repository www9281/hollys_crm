--------------------------------------------------------
--  DDL for Procedure BATCH_STAT_STOR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_STAT_STOR" (
  PI_CUR_YM  IN   VARCHAR2,   --기준년월
  PI_CFR_YM  IN   VARCHAR2,   --기준년월        분기 시작년월
  PI_CTO_YM  IN   VARCHAR2,   --기준년월        분기 종료년월
  PI_LST_YM  IN   VARCHAR2,   --기준년월-12개월
  PI_LFR_YM  IN   VARCHAR2,   --기준년월-12개월 분기 시작년월
  PI_LTO_YM  IN   VARCHAR2,   --기준년월-12개월 분기 종료년월
  PO_RETC    OUT  VARCHAR2
)
IS
  V_RETC     VARCHAR2(100);    
  
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-06-29
  -- Description   :   매장 SSS구분 정보 구하기...
  -- ==========================================================================================

  V_RETC := NULL;


  IF PI_CUR_YM IS NULL OR
     PI_CFR_YM IS NULL OR
     PI_CFR_YM IS NULL OR
     PI_LST_YM IS NULL OR
     PI_LFR_YM IS NULL OR
     PI_LFR_YM IS NULL THEN
    STAT_LOG_SAVE('BATCH_STAT_STOR', '매장 SSS구분 정보 구하기', PI_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
    V_RETC := 'NG';
  END IF;     

  IF V_RETC IS NULL THEN 
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_STORE';
      INSERT INTO TEMP_STORE
           ( COMP_CD , BRAND_CD  , STOR_CD  , STOR_TP  , TRAD_AREA    -- 1, 2, 3, 4, 5
           , SIDO_CD , SV_USER_ID, STOR_TG  , APP_DIV  , OPEN_DT      -- 6, 7, 8, 9,10
           , CLOSE_DT, SSS_DIV_M , SSS_DIV_Q, SSS_DIV_Y, INST_DT   )  --11,12,13,14,15
      SELECT COMP_CD                                                  -- 1.COMP_CD
           , BRAND_CD                                                 -- 2.BRAND_CD
           , STOR_CD                                                  -- 3.STOR_CD
           , STOR_TP                                                  -- 4.STOR_TP
           , TRAD_AREA                                                -- 5.TRAD_AREA
           , SIDO_CD                                                  -- 6.SIDO_CD
           , SV_USER_ID                                               -- 7.SV_USER_ID
           , STOR_TG                                                  -- 8.STOR_TG
           , APP_DIV                                                  -- 9.APP_DIV
           , OPEN_DT                                                  --10.OPEN_DT
           , CLOSE_DT                                                 --11.CLOSE_DT
           , CASE WHEN (APP_DIV IN ('01','05') AND NVL(OPEN_DT ,PI_CUR_YM||'01') BETWEEN PI_LST_YM ||'01'              AND PI_LST_YM ||'31'             ) OR
                       (APP_DIV IN ('01','05') AND NVL(OPEN_DT ,PI_CUR_YM||'01') BETWEEN PI_CUR_YM ||'01'              AND PI_CUR_YM ||'31'             ) OR
                       (APP_DIV IN ('03'     ) AND NVL(CLOSE_DT,PI_CUR_YM||'01') <= PI_CUR_YM||'31'                                     )
                  THEN 'NOT'
                  ELSE 'SSS'
             END                                                      --12.SSS_DIV_M
           , CASE WHEN (APP_DIV IN ('01','05') AND NVL(OPEN_DT ,PI_CUR_YM||'01') BETWEEN PI_LFR_YM||'01'               AND PI_LTO_YM||'31'              ) OR
                       (APP_DIV IN ('01','05') AND NVL(OPEN_DT ,PI_CUR_YM||'01') BETWEEN PI_CFR_YM||'01'               AND PI_CTO_YM||'31'              ) OR
                       (APP_DIV IN ('03'     ) AND NVL(CLOSE_DT,PI_CUR_YM||'01') <= PI_CUR_YM||'31'                                                     )
                  THEN 'NOT'
                  ELSE 'SSS'
             END                                                      --13.SSS_DIV_Q
           , CASE WHEN (APP_DIV IN ('01','05') AND NVL(OPEN_DT ,PI_CUR_YM||'01') BETWEEN SUBSTR(PI_LST_YM,1,4)||'0101' AND SUBSTR(PI_LST_YM,1,4)||'1231') OR
                       (APP_DIV IN ('03'     ) AND NVL(CLOSE_DT,PI_CUR_YM||'01') <= SUBSTR(PI_CUR_YM,1,4)||'1231'                                       )
                  THEN 'NOT'
                  ELSE 'SSS'
             END                                                      --14.SSS_DIV_Y
           , SYSDATE                                                  --15.INST_DT
      FROM   STORE
      WHERE  COMP_CD = '016'
      AND    STOR_TP IN ('10','20')
      ;
      COMMIT;
      STAT_LOG_SAVE('BATCH_STAT_STOR', 'SSS매장구분 생성', PI_CUR_YM, 'OK', V_RETC);
      V_RETC := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        STAT_LOG_SAVE('BATCH_STAT_STOR', 'SSS매장구분 생성', PI_CUR_YM||'('||SQLERRM||')', 'NG', V_RETC);
        V_RETC := 'NG';
    END;
  END IF;

  PO_RETC := V_RETC;

END BATCH_STAT_STOR;

/
