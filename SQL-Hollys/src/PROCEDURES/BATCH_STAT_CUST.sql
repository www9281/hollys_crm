--------------------------------------------------------
--  DDL for Procedure BATCH_STAT_CUST
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."BATCH_STAT_CUST" (
  PI_ST_YM  IN   VARCHAR2,   --기준년월
  PI_FR_YM  IN   VARCHAR2,   --기준년월 분기 시작년월
  PI_TO_YM  IN   VARCHAR2,   --기준년월 분기 종료년월
  PO_RETC   OUT  VARCHAR2
)
IS
  V_LAST_ST  VARCHAR2(8  );   --기준일자 월의 마지막 일자
  V_LAST_TO  VARCHAR2(8  );   --기준일자 분기월의 마지막 일자
  V_LAST_YR  VARCHAR2(8  );   --기준일자 분기월의 마지막 일자
  
  V_MSG      VARCHAR2(100);
  V_RETC     VARCHAR2(100);
BEGIN
  -- ==========================================================================================
  -- Author        :   이춘승
  -- Create date   :   2018-06-29
  -- Description   :   고객 연령/상태 정보 구하기...
  -- ==========================================================================================
  --기준월의 마지막일자 구하기...
  SELECT TO_CHAR(LAST_DAY(TO_DATE(PI_ST_YM||'01','YYYYMMDD')),'YYYYMMDD')
       , TO_CHAR(LAST_DAY(TO_DATE(PI_TO_YM||'01','YYYYMMDD')),'YYYYMMDD')
       , SUBSTR(PI_ST_YM,1,4)||'1231'
  INTO   V_LAST_ST
       , V_LAST_TO
       , V_LAST_YR
  FROM   DUAL
  ;

  V_RETC := NULL;

  IF PI_ST_YM IS NULL OR
     PI_FR_YM IS NULL OR
     PI_TO_YM IS NULL THEN
    STAT_LOG_SAVE('BATCH_STAT_CUST', '고객 연령/상태 정보 구하기', PI_ST_YM||'('||SQLERRM||')', 'NG', V_RETC);
    V_RETC := 'NG';
  END IF;     

  IF V_RETC IS NULL THEN 
    BEGIN
      EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_CUST_STAT1';
      INSERT INTO TEMP_CUST_STAT1
           ( COMP_CD      , CUST_ID    , SEX_DIV    , LUNAR_DIV  , BIRTH_DT       -- 1, 2, 3, 4, 5
           , C_BIRTH_DT   , AGE_M      , AGE_RANGE_M, LVL_CD_M   , CUST_STAT_M    -- 6, 7, 8, 9,10
           , APP_INST_DT_M, AGE_Q      , AGE_RANGE_Q, LVL_CD_Q   , CUST_STAT_Q    --11,12,13,14,15
           , APP_INST_DT_Q, AGE_Y      , AGE_RANGE_Y, LVL_CD_Y   , CUST_STAT_Y    --16,17,18,19,20
           , APP_INST_DT_Y, BRAND_CD   , STOR_CD    , JOIN_DT    , STD_YMD        --21,22,23,24,25
           , MAK_YMD                                                           )  --26
      SELECT COMP_CD                      COMP_CD                                 -- 1
           , CUST_ID                      CUST_ID                                 -- 2
           , MAX(SEX_DIV      )           SEX_DIV                                 -- 3
           , MAX(LUNAR_DIV    )           LUNAR_DIV                               -- 4
           , MAX(BIRTH_DT     )           BIRTH_DT                                -- 5
           , MAX(C_BIRTH_DT   )           C_BIRTH_DT                              -- 6

           , MIN(AGE_M        )           AGE_M                                   -- 7
           , MIN(AGE_RANGE_M  )           AGE_RANGE_M                             -- 8
           , MAX(LVL_CD_M     )           LVL_CD_M                                -- 9 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다.
           , MAX(CUST_STAT_M  )           CUST_STAT_M                             --10 *과거의 자료 집계시에는 변경이력이 있으면 대체 사용한다.
           , MAX(APP_INST_DT_M)           APP_INST_DT_M                           --11

           , MIN(AGE_Q        )           AGE_Q                                   --12
           , MIN(AGE_RANGE_Q  )           AGE_RANGE_Q                             --13
           , MAX(LVL_CD_Q     )           LVL_CD_Q                                --14
           , MAX(CUST_STAT_Q  )           CUST_STAT_Q                             --15
           , MAX(APP_INST_DT_Q)           APP_INST_DT_Q                           --16

           , MIN(AGE_Y        )           AGE_Y                                   --17
           , MIN(AGE_RANGE_Y  )           AGE_RANGE_Y                             --18
           , MAX(LVL_CD_Y     )           LVL_CD_Y                                --19
           , MAX(CUST_STAT_Y  )           CUST_STAT_Y                             --20
           , MAX(APP_INST_DT_Y)           APP_INST_DT_Y                           --21

           , MAX(BRAND_CD     )           BRAND_CD                                --22
           , MAX(STOR_CD      )           STOR_CD                                 --23
           , MAX(JOIN_DT      )           JOIN_DT                                 --24
           , PI_ST_YM                     STD_YMD                                 --25
           , TO_CHAR(SYSDATE,'YYYYMMDD')  MAK_YMD                                 --26
      FROM   (--월별 집계...
              SELECT T1.COMP_CD                                                             COMP_CD
                   , T1.CUST_ID                                                             CUST_ID
                   , T1.SEX_DIV                                                             SEX_DIV
                   , T1.LUNAR_DIV                                                           LUNAR_DIV
                   , T1.BIRTH_DT                                                            BIRTH_DT
                   , T1.C_BIRTH_DT                                                          C_BIRTH_DT

                   , T1.CUST_AGE                                                            AGE_M
                   , X1.CODE_CD                                                             AGE_RANGE_M
                   , CASE WHEN T2.LVL_CD IS NULL
                          THEN DECODE(PI_ST_YM,TO_CHAR(SYSDATE,'YYYYMM'),T1.LVL_CD,'000')
                          ELSE T2.LVL_CD
                     END                                                                    LVL_CD_M
                   , CASE WHEN T3.CUST_STAT IS NULL
                          THEN DECODE(PI_ST_YM,TO_CHAR(SYSDATE,'YYYYMM'),T1.CUST_STAT,'1')
                          ELSE T3.CUST_STAT
                     END                                                                    CUST_STAT_M
                   , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_ST 
                          THEN TO_CHAR(T4.INST_DT,'YYYYMMDD') 
                          ELSE NULL
                     END                                                                    APP_INST_DT_M

                   , 999                                                                    AGE_Q
                   , '08'                                                                   AGE_RANGE_Q
                   , '000'                                                                  LVL_CD_Q
                   , '1'                                                                    CUST_STAT_Q
                   , NULL                                                                   APP_INST_DT_Q

                   , 999                                                                    AGE_Y
                   , '08'                                                                   AGE_RANGE_Y
                   , '000'                                                                  LVL_CD_Y
                   , '1'                                                                    CUST_STAT_Y
                   , NULL                                                                   APP_INST_DT_Y

                   , T1.BRAND_CD                                                            BRAND_CD
                   , T1.STOR_CD                                                             STOR_CD      
                   , T1.JOIN_DT                                                             JOIN_DT
              FROM   (--고객 성별, 나이, 연령대, 등급 등을 구한다.
                      SELECT COMP_CD                                                   COMP_CD
                           , CUST_ID                                                   CUST_ID
                           , NVL(SEX_DIV  ,'?')                                        SEX_DIV
                           , NVL(LUNAR_DIV,'S')                                        LUNAR_DIV
                           , BIRTH_DT                                                  BIRTH_DT
                           , LVL_CD                                                    LVL_CD
                           , DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT)  C_BIRTH_DT
                           , CASE WHEN BIRTH_DT = '99999999'
                                  THEN 999
                                  ELSE TRUNC((PI_ST_YM - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                             END                                                       CUST_AGE
                           , JOIN_DT
                           , CUST_STAT
                           , BRAND_CD
                           , STOR_CD
                      FROM   (
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST     C1
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= PI_ST_YM||'31'
                              AND    NOT EXISTS (
                                                    SELECT  '1'
                                                      FROM  C_CUST
                                                     WHERE  COMP_CD   = C1.COMP_CD
                                                       AND  CUST_ID   = C1.CUST_ID
                                                       AND  LEAVE_DT <= PI_ST_YM||'01'
                                                  )
                             UNION ALL
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , '8'        CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST_REST
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= PI_ST_YM||'31'
                             )
                     )                   T1
                   , (--고객의 집계년월의 등급변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    LVL_CD
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= PI_ST_YM||'31'
                              AND    CHG_DIV = '15'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '15'
                     )                   T2
                   , (--고객의 집계년월의 상태변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    CUST_STAT
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= PI_ST_YM||'31'
                              AND    CHG_DIV = '13'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '13'
                     )                   T3
                   , C_CUST_DEVICE       T4
                   , COMMON              X1
              WHERE  T1.CUST_ID = T2.CUST_ID(+)
              AND    T1.CUST_ID = T3.CUST_ID(+)
              AND    T1.CUST_ID = T4.CUST_ID(+)
              AND    'Y'        = T4.USE_YN(+)
              AND    X1.CODE_TP = '01760'
              AND    T1.CUST_AGE BETWEEN X1.VAL_N1 AND X1.VAL_N2
             UNION ALL
              --분기별 집계...
              SELECT T1.COMP_CD                                                             COMP_CD
                   , T1.CUST_ID                                                             CUST_ID
                   , T1.SEX_DIV                                                             SEX_DIV
                   , T1.LUNAR_DIV                                                           LUNAR_DIV
                   , T1.BIRTH_DT                                                            BIRTH_DT
                   , T1.C_BIRTH_DT                                                          C_BIRTH_DT

                   , 999                                                                    AGE_M
                   , '08'                                                                   AGE_RANGE_M
                   , '000'                                                                  LVL_CD_M
                   , '1'                                                                    CUST_STAT_M
                   , NULL                                                                   APP_INST_DT_M

                   , T1.CUST_AGE                                                            AGE_Q
                   , X1.CODE_CD                                                             AGE_RANGE_Q
                   , CASE WHEN T2.LVL_CD IS NULL
                          THEN CASE WHEN TO_CHAR(SYSDATE,'YYYYMM') BETWEEN PI_FR_YM AND PI_TO_YM
                                    THEN T1.LVL_CD
                                    ELSE '000'
                               END
                          ELSE T2.LVL_CD
                     END                                                                    LVL_CD_Q
                   , CASE WHEN T3.CUST_STAT IS NULL
                          THEN CASE WHEN TO_CHAR(SYSDATE,'YYYYMM') BETWEEN PI_FR_YM AND PI_TO_YM
                                    THEN T1.CUST_STAT
                                    ELSE '1'
                               END
                          ELSE T3.CUST_STAT
                     END                                                                    CUST_STAT_Q
                   , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_TO 
                          THEN TO_CHAR(T4.INST_DT,'YYYYMMDD') 
                          ELSE NULL
                     END                                                                    APP_INST_DT_Q

                   , 999                                                                    AGE_Y
                   , '08'                                                                   AGE_RANGE_Y
                   , '000'                                                                  LVL_CD_Y
                   , '1'                                                                    CUST_STAT_Y
                   , NULL                                                                   APP_INST_DT_Y

                   , T1.BRAND_CD                                                            BRAND_CD
                   , T1.STOR_CD                                                             STOR_CD
                   , T1.JOIN_DT                                                             JOIN_DT
              FROM   (--고객 성별, 나이, 연령대, 등급 등을 구한다.
                      SELECT COMP_CD                                                   COMP_CD
                           , CUST_ID                                                   CUST_ID
                           , NVL(SEX_DIV  ,'?')                                        SEX_DIV
                           , NVL(LUNAR_DIV,'S')                                        LUNAR_DIV
                           , BIRTH_DT                                                  BIRTH_DT
                           , LVL_CD                                                    LVL_CD
                           , DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT)  C_BIRTH_DT
                           , CASE WHEN BIRTH_DT = '99999999'
                                  THEN 999
                                  ELSE TRUNC((PI_TO_YM - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                             END                                                       CUST_AGE
                           , JOIN_DT
                           , CUST_STAT
                           , BRAND_CD
                           , STOR_CD
                      FROM   (
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST     C1
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= PI_TO_YM||'31'
                              AND    NOT EXISTS (
                                                    SELECT  '1'
                                                      FROM  C_CUST
                                                     WHERE  COMP_CD   = C1.COMP_CD
                                                       AND  CUST_ID   = C1.CUST_ID
                                                       AND  LEAVE_DT <= PI_FR_YM||'01'
                                                  )
                             UNION ALL
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , '8'        CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST_REST
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= PI_TO_YM||'31'
                             )
                     )                   T1
                   , (--고객의 집계년월의 등급변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    LVL_CD
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= PI_TO_YM||'31'
                              AND    CHG_DIV = '15'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '15'
                     )                   T2
                   , (--고객의 집계년월의 상태변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    CUST_STAT
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= PI_TO_YM||'31'
                              AND    CHG_DIV = '13'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '13'
                     )                   T3
                   , C_CUST_DEVICE       T4
                   , COMMON              X1
              WHERE  T1.CUST_ID = T2.CUST_ID(+)
              AND    T1.CUST_ID = T3.CUST_ID(+)
              AND    T1.CUST_ID = T4.CUST_ID(+)
              AND    'Y'        = T4.USE_YN(+)
              AND    X1.CODE_TP = '01760'
              AND    T1.CUST_AGE BETWEEN X1.VAL_N1 AND X1.VAL_N2
             UNION ALL
              --년도별 집계...
              SELECT T1.COMP_CD                                                             COMP_CD
                   , T1.CUST_ID                                                             CUST_ID
                   , T1.SEX_DIV                                                             SEX_DIV
                   , T1.LUNAR_DIV                                                           LUNAR_DIV
                   , T1.BIRTH_DT                                                            BIRTH_DT
                   , T1.C_BIRTH_DT                                                          C_BIRTH_DT

                   , 999                                                                    AGE_M
                   , '08'                                                                   AGE_RANGE_M
                   , '000'                                                                  LVL_CD_M
                   , '1'                                                                    CUST_STAT_M
                   , NULL                                                                   APP_INST_DT_M

                   , 999                                                                    AGE_Q
                   , '08'                                                                   AGE_RANGE_Q
                   , '000'                                                                  LVL_CD_Q
                   , '1'                                                                    CUST_STAT_Q
                   , NULL                                                                   APP_INST_DT_Q

                   , T1.CUST_AGE                                                            AGE_Y
                   , X1.CODE_CD                                                             AGE_RANGE_Y
                   , CASE WHEN T2.LVL_CD IS NULL
                          THEN DECODE(SUBSTR(PI_ST_YM,1,4),TO_CHAR(SYSDATE,'YYYY'),T1.LVL_CD,'000')
                          ELSE T2.LVL_CD
                     END                                                                    LVL_CD_Y
                   , CASE WHEN T3.CUST_STAT IS NULL
                          THEN DECODE(SUBSTR(PI_ST_YM,1,4),TO_CHAR(SYSDATE,'YYYY'),T1.CUST_STAT,'1')
                          ELSE T3.CUST_STAT
                     END                                                                    CUST_STAT_Y
                   , CASE WHEN TO_CHAR(T4.INST_DT,'YYYYMMDD') <= V_LAST_YR
                          THEN TO_CHAR(T4.INST_DT,'YYYYMMDD') 
                          ELSE NULL
                     END                                                                    APP_INST_DT_Y

                   , T1.BRAND_CD                                                            BRAND_CD
                   , T1.STOR_CD                                                             STOR_CD
                   , T1.JOIN_DT                                                             JOIN_DT
              FROM   (--고객 성별, 나이, 연령대, 등급 등을 구한다.
                      SELECT COMP_CD                                                   COMP_CD
                           , CUST_ID                                                   CUST_ID
                           , NVL(SEX_DIV  ,'?')                                        SEX_DIV
                           , NVL(LUNAR_DIV,'S')                                        LUNAR_DIV
                           , BIRTH_DT                                                  BIRTH_DT
                           , LVL_CD                                                    LVL_CD
                           , DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT)  C_BIRTH_DT
                           , CASE WHEN BIRTH_DT = '99999999'
                                  THEN 999
                                  ELSE TRUNC((SUBSTR(PI_ST_YM,1,4)||'12' - SUBSTR(DECODE(LUNAR_DIV,'L',UF_LUN2SOL(BIRTH_DT, '0'),BIRTH_DT),1,6)) / 100 + 1)
                             END                                                       CUST_AGE
                           , JOIN_DT
                           , CUST_STAT
                           , BRAND_CD
                           , STOR_CD
                      FROM   (
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST     C1
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= SUBSTR(PI_ST_YM,1,4)||'1231'
                              AND    NOT EXISTS (
                                                    SELECT  '1'
                                                      FROM  C_CUST
                                                     WHERE  COMP_CD   = C1.COMP_CD
                                                       AND  CUST_ID   = C1.CUST_ID
                                                       AND  LEAVE_DT <= SUBSTR(PI_ST_YM,1,4)||'0101'
                                                  )
                             UNION ALL
                              SELECT COMP_CD
                                   , CUST_ID
                                   , SEX_DIV
                                   , LUNAR_DIV
                                   , BIRTH_DT
                                   , LVL_CD
                                   , JOIN_DT
                                   , '8'        CUST_STAT
                                   , BRAND_CD
                                   , STOR_CD
                              FROM   C_CUST_REST
                              WHERE  COMP_CD  = '016'
                              AND    JOIN_DT <= SUBSTR(PI_ST_YM,1,4)||'1231'
                             )
                     )                   T1
                   , (--고객의 집계년월의 등급변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    LVL_CD
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= SUBSTR(PI_ST_YM,1,4)||'1231'
                              AND    CHG_DIV = '15'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '15'
                     )                   T2
                   , (--고객의 집계년월의 상태변경내역을 구한다.
                      SELECT CUST_ID
                           , CHG_TO    CUST_STAT
                      FROM   C_CUST_HIS
                      WHERE  (CUST_ID,CHG_DT||LPAD(CHG_SEQ,3,'0'))
                          IN (SELECT CUST_ID
                                   , MAX(CHG_DT||LPAD(CHG_SEQ,3,'0'))  CHG_DT_SEQ
                              FROM   C_CUST_HIS
                              WHERE  COMP_CD = '016'
                              AND    CHG_DT <= SUBSTR(PI_ST_YM,1,4)||'1231'
                              AND    CHG_DIV = '13'
                              GROUP BY CUST_ID
                             )
                      AND    COMP_CD = '016'
                      AND    CHG_DIV = '13'
                     )                   T3
                   , C_CUST_DEVICE       T4
                   , COMMON              X1
              WHERE  T1.CUST_ID = T2.CUST_ID(+)
              AND    T1.CUST_ID = T3.CUST_ID(+)
              AND    T1.CUST_ID = T4.CUST_ID(+)
              AND    'Y'        = T4.USE_YN(+)
              AND    X1.CODE_TP = '01760'
              AND    T1.CUST_AGE BETWEEN X1.VAL_N1 AND X1.VAL_N2
             )
      GROUP BY COMP_CD,CUST_ID
      ;
      COMMIT; 
      STAT_LOG_SAVE('BATCH_STAT_CUST', '고객 연령/상태 정보 구하기', PI_ST_YM, 'OK', V_RETC);
      V_RETC := NULL;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        STAT_LOG_SAVE('BATCH_STAT_CUST', '고객 연령/상태 정보 구하기', PI_ST_YM||'('||SQLERRM||')', 'NG', V_RETC);
        V_RETC := 'NG';
    END;
  END IF;

  PO_RETC := V_RETC;

END BATCH_STAT_CUST;

/
