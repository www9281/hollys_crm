--------------------------------------------------------
--  DDL for Procedure SP_CREATE_ATTD_PAY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CREATE_ATTD_PAY" 
/******************************************************************************
   NAME     : SP_CREATE_ATTD_PAY
   PURPOSE  : 급여산출 프로시져(매달 1일 새벽 5시에 실행)

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_CREATE_ATTD_PAY
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    PSV_COMP_CD     IN   VARCHAR2,
    PSV_ATTD_YM     IN   VARCHAR2
)
IS
    -- 실적대상 점포 조회
    CURSOR CUR_S IS
        SELECT  S.COMP_CD
             ,  S.BRAND_CD
             ,  S.STOR_CD
          FROM  STORE       S
             ,  COMMON      C
         WHERE  S.COMP_CD   = C.COMP_CD
           AND  S.STOR_TP   = C.CODE_CD
           AND  S.COMP_CD   = PSV_COMP_CD
           AND  S.USE_YN    = 'Y'
           AND  C.CODE_TP   = '00565'
           AND  C.USE_YN    = 'Y'
           AND  INSTR('S', C.VAL_C1, 1) > 0
         ;

    MYREC1           CUR_S%ROWTYPE;
    liv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    liv_msg_code    := '0';
    lsv_msg_text    := '';

    FOR MYREC1 IN CUR_S LOOP

        -- 정사원 급여 산출
        INSERT  INTO ATTD_PAY_006
        SELECT  COMP_CD
             ,  BRAND_CD
             ,  STOR_CD
             ,  USER_ID
             ,  ATTD_YM
             ,  YEAR_PAY
             ,  ATTD_DAYS
             ,  HOUR_PAY
             ,  BASIC_HOUR                                  AS BASIC_HOUR
             ,  CASE WHEN PROB_YN = 'Y' THEN TRUNC(YEAR_PAY * PROB_RATE / 12 / MONTH_DAYS * ATTD_DAYS) - ROUND(OVER_PAY / MONTH_DAYS * ATTD_DAYS) - ROUND(NIGHT_PAY / MONTH_DAYS * ATTD_DAYS) - ROUND(HOLI_PAY / MONTH_DAYS * ATTD_DAYS)
                     ELSE TRUNC(YEAR_PAY / 12 / MONTH_DAYS * ATTD_DAYS) - ROUND(OVER_PAY / MONTH_DAYS * ATTD_DAYS) - ROUND(NIGHT_PAY / MONTH_DAYS * ATTD_DAYS) - ROUND(HOLI_PAY / MONTH_DAYS * ATTD_DAYS)
                END                                         AS BASIC_PAY
             ,  OVER_HOUR
             ,  ROUND(OVER_PAY / MONTH_DAYS * ATTD_DAYS)    AS OVER_PAY
             ,  NIGHT_HOUR
             ,  ROUND(NIGHT_PAY / MONTH_DAYS * ATTD_DAYS)   AS NIGHT_PAY
             ,  HOLI_HOUR
             ,  ROUND(HOLI_PAY / MONTH_DAYS * ATTD_DAYS)    AS HOLI_PAY
             ,  0           AS WEEK_HOUR
             ,  0           AS WEEK_PAY
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
          FROM  (
                    SELECT  U.COMP_CD
                         ,  U.BRAND_CD
                         ,  U.STOR_CD
                         ,  U.USER_ID
                         ,  PSV_ATTD_YM                                     AS ATTD_YM
                         ,  U.USER_NM
                         ,  CASE WHEN U.RETIRE_DT IS NOT NULL AND U.RETIRE_DT BETWEEN PSV_ATTD_YM||'01' AND PSV_ATTD_YM||'31' THEN TO_DATE(U.RETIRE_DT, 'YYYYMMDD') - TO_DATE(PSV_ATTD_YM||'01', 'YYYYMMDD') + 1
                                 ELSE TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(PSV_ATTD_YM, 'YYYYMM')), 'DD'))
                            END                                             AS ATTD_DAYS        -- 월 근무일수
                         ,  TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(PSV_ATTD_YM, 'YYYYMM')), 'DD'))  AS MONTH_DAYS       -- 월별 총일수
                         ,  CASE WHEN SUBSTR(U.PROB_FRDT, 1, 6) = PSV_ATTD_YM OR SUBSTR(U.PROB_TODT, 1, 6) = PSV_ATTD_YM THEN 'Y'
                                 ELSE 'N'
                            END                                             AS PROB_YN          -- 수습여부
                         ,  B.PAY_RATE                                      AS PROB_RATE        -- 수습사원 급여적용율
                         ,  P.ATTD_PAY_DIV
                         ,  B.MONTH_HOUR                                    AS BASIC_HOUR       -- 월 소정근로시간
                         ,  P.BASIC_PAY                                     AS YEAR_PAY         -- 연봉
                         ,  P.OVERTIME_PAY                                  AS HOUR_PAY         -- 통상시급
                         ,  P.OVER_HOUR                                                         -- 연장근무시간
                         ,  ROUND(P.OVERTIME_PAY * P.OVER_HOUR * 1.5)       AS OVER_PAY         -- 연장근로수당
                         ,  P.NIGHT_HOUR                                                        -- 야간근무시간
                         ,  ROUND(P.OVERTIME_PAY * P.NIGHT_HOUR * 0.5)      AS NIGHT_PAY        -- 야간근로수당
                         ,  P.HOLI_HOUR                                                         -- 휴일근무시간
                         ,  ROUND(P.OVERTIME_PAY * P.HOLI_HOUR * 1.5)       AS HOLI_PAY         -- 휴일근로수당
                      FROM  STORE_USER      U
                         ,  STORE_ATTD_PAY  P
                         ,  COMMON          C
                         ,  BRAND_PARA_PAY  B
                     WHERE  U.COMP_CD   = P.COMP_CD
                       AND  U.BRAND_CD  = P.BRAND_CD
                       AND  U.STOR_CD   = P.STOR_CD
                       AND  U.USER_ID   = P.USER_ID
                       AND  U.COMP_CD   = C.COMP_CD
                       AND  U.EMP_DIV   = C.CODE_CD
                       AND  U.COMP_CD   = B.COMP_CD
                       AND  U.BRAND_CD  = B.BRAND_CD
                       AND  U.COMP_CD   = MYREC1.COMP_CD
                       AND  U.BRAND_CD  = MYREC1.BRAND_CD
                       AND  U.STOR_CD   = MYREC1.STOR_CD
                       AND  U.USE_YN    = 'Y'
                       AND  U.USER_ID   <> U.STOR_CD||'000'
                       AND  NVL(U.RETIRE_DT, '99991231') >= PSV_ATTD_YM||'01'
                       AND  U.ENTER_DT  <= PSV_ATTD_YM||'31'
                       AND  P.ATTD_PAY_DT = (
                                                SELECT  MAX(ATTD_PAY_DT)
                                                  FROM  STORE_ATTD_PAY
                                                 WHERE  COMP_CD     = P.COMP_CD
                                                   AND  BRAND_CD    = P.BRAND_CD
                                                   AND  STOR_CD     = P.STOR_CD
                                                   AND  USER_ID     = P.USER_ID
                                                   AND  ATTD_PAY_DT <= PSV_ATTD_YM||'31'
                                                   AND  USE_YN      = 'Y'
                                            )
                       AND  P.USE_YN    = 'Y'
                       AND  C.CODE_TP   = '00765'
                       AND  C.VAL_C1    = 'E'
                       AND  C.USE_YN    = 'Y'
                )
        ;

        -- 계약직 급여산출
        INSERT  INTO ATTD_PAY_006
        SELECT  COMP_CD
             ,  BRAND_CD
             ,  STOR_CD
             ,  USER_ID
             ,  SUBSTR(ATTD_DT, 1, 6)       AS ATTD_YM
             ,  NULL                        AS YEAR_PAY
             ,  COUNT(ATTD_DT)              AS ATTD_DAYS
             ,  MAX(HOUR_PAY)               AS HOUR_PAY
             ,  SUM(BASIC_HOUR)             AS BASIC_HOUR
             ,  SUM(BASIC_PAY)              AS BASIC_PAY
             ,  SUM(OVER_HOUR)              AS OVER_HOUR
             ,  SUM(OVER_PAY)               AS OVER_PAY
             ,  SUM(NIGHT_HOUR)             AS NIGHT_HOUR
             ,  SUM(NIGHT_PAY)              AS NIGHT_PAY
             ,  0                           AS HOLI_HOUR
             ,  0                           AS HOLI_PAY
             ,  0                           AS WEEK_HOUR
             ,  0                           AS WEEK_PAY
             ,  SYSDATE
             ,  'SYSTEM'
             ,  SYSDATE
             ,  'SYSTEM'
          FROM  (
                    SELECT  COMP_CD
                         ,  BRAND_CD
                         ,  STOR_CD
                         ,  USER_ID
                         ,  ATTD_DT
                         ,  WORK_S_HM
                         ,  WORK_C_HM
                         ,  BASIC_PAY                                                                                       AS HOUR_PAY
                         ,  CASE WHEN R_NUM = 1 THEN DAY_OF_SEC / 60 / 60 - NVL(REST_HOUR, 0) ELSE 0 END                    AS BASIC_HOUR
                         ,  CASE WHEN R_NUM = 1 THEN (DAY_OF_SEC / 60 / 60 - NVL(REST_HOUR, 0)) * BASIC_PAY ELSE 0 END      AS BASIC_PAY
                         ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SEC > (WORK_HOUR * 60 * 60) THEN DAY_OF_SEC / 60 / 60 - NVL(WORK_HOUR, 0) * 60 * 60 - NVL(REST_HOUR, 0)
                                 ELSE 0 
                            END) OVER(PARTITION BY  COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT)                       AS OVER_HOUR
                         ,  SUM(CASE WHEN R_NUM = 1 AND DAY_OF_SEC > (WORK_HOUR * 60 * 60) THEN DAY_OF_SEC / 60 / 60 - NVL(WORK_HOUR, 0) * 60 * 60 - NVL(REST_HOUR, 0)
                                 ELSE 0 
                            END) OVER(PARTITION BY  COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT) * BASIC_PAY * 0.5     AS OVER_PAY
                         ,  CASE WHEN R_NUM = 1 THEN MID_OF_SEC / 60 / 60 ELSE 0 END                                        AS NIGHT_HOUR
                         ,  CASE WHEN R_NUM = 1 THEN MID_OF_SEC / 60 / 60 * BASIC_PAY * 0.5 ELSE 0 END                      AS NIGHT_PAY
                      FROM  (
                                SELECT  COMP_CD
                                     ,  BRAND_CD
                                     ,  STOR_CD
                                     ,  USER_ID
                                     ,  ATTD_DT
                                     ,  WORK_S_HM
                                     ,  WORK_C_HM
                                     ,  BASIC_PAY
                                     ,  WORK_HOUR
                                     ,  REST_HOUR
                                     ,  SUM((TO_DATE(WORK_C_DT||WORK_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(WORK_S_DT||WORK_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT)    AS DAY_OF_SEC
                                     ,  SUM(FN_GET_MIDNIGHT_WT(WORK_S_DT||WORK_S_HM, WORK_C_DT||WORK_C_HM)) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT)                                                        AS MID_OF_SEC
                                     ,  R_NUM
                                  FROM  (  
                                            SELECT  COMP_CD
                                                 ,  BRAND_CD
                                                 ,  STOR_CD
                                                 ,  USER_ID
                                                 ,  ATTD_DT
                                                 ,  WORK_START_DT
                                                 ,  WORK_CLOSE_DT
                                                 ,  BASIC_PAY
                                                 ,  WORK_HOUR
                                                 ,  REST_HOUR
                                                 ,  TO_CHAR(TO_DATE(WORK_START_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD')   AS WORK_S_DT
                                                 ,  TO_CHAR(TO_DATE(WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'YYYYMMDD')   AS WORK_C_DT
                                                 ,  TO_CHAR(TO_DATE(WORK_START_DT, 'YYYYMMDDHH24MI'), 'HH24MI')     AS WORK_S_HM
                                                 ,  TO_CHAR(TO_DATE(WORK_CLOSE_DT, 'YYYYMMDDHH24MI'), 'HH24MI')     AS WORK_C_HM
                                                 ,  ROW_NUMBER() OVER(PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT ORDER BY WORK_START_DT) AS R_NUM
                                              FROM  (
                                                        SELECT  A.COMP_CD
                                                             ,  A.BRAND_CD
                                                             ,  A.STOR_CD
                                                             ,  A.USER_ID
                                                             ,  A.ATTD_DT
                                                             ,  NVL(A.CONFIRM_START_DT, A.WORK_START_DT)    AS WORK_START_DT
                                                             ,  CASE WHEN NVL(A.CONFIRM_CLOSE_DT, A.WORK_CLOSE_DT) < NVL(A.CONFIRM_START_DT, A.WORK_START_DT) THEN NVL(A.CONFIRM_START_DT, A.WORK_START_DT)
                                                                     ELSE NVL(A.CONFIRM_CLOSE_DT, A.WORK_CLOSE_DT)
                                                                END                                         AS WORK_CLOSE_DT
                                                             ,  P.BASIC_PAY
                                                             ,  L.WORK_HOUR
                                                             ,  L.REST_HOUR
                                                          FROM  ATTD_CONFIRM_006    A
                                                             ,  STORE_USER          U
                                                             ,  STORE_ATTD_PAY      P
                                                             ,  STORE_LABOR_006     L
                                                             ,  COMMON              C
                                                         WHERE  A.COMP_CD   = U.COMP_CD
                                                           AND  A.BRAND_CD  = U.BRAND_CD
                                                           AND  A.STOR_CD   = U.STOR_CD
                                                           AND  A.USER_ID   = U.USER_ID
                                                           AND  A.COMP_CD   = P.COMP_CD
                                                           AND  A.BRAND_CD  = P.BRAND_CD
                                                           AND  A.STOR_CD   = P.STOR_CD
                                                           AND  A.USER_ID   = P.USER_ID
                                                           AND  A.COMP_CD   = L.COMP_CD(+)
                                                           AND  A.BRAND_CD  = L.BRAND_CD(+)
                                                           AND  A.STOR_CD   = L.STOR_CD(+)
                                                           AND  A.USER_ID   = L.USER_ID(+)
                                                           AND  TO_CHAR(TO_DATE(A.ATTD_DT, 'YYYYMMDD'), 'D') = L.WEEK_DAY(+)   
                                                           AND  U.COMP_CD   = C.COMP_CD
                                                           AND  U.EMP_DIV   = C.CODE_CD
                                                           AND  A.COMP_CD   = MYREC1.COMP_CD
                                                           AND  A.BRAND_CD  = MYREC1.BRAND_CD
                                                           AND  A.STOR_CD   = MYREC1.STOR_CD
                                                           AND  A.ATTD_DT   BETWEEN PSV_ATTD_YM||'01' AND PSV_ATTD_YM||'31'
                                                           AND  U.USER_ID   <> U.STOR_CD||'000'
                                                           AND  NVL(U.RETIRE_DT, '99991231') >= PSV_ATTD_YM||'01'
                                                           AND  U.ENTER_DT  <= PSV_ATTD_YM||'31'
                                                           AND  U.USE_YN    = 'Y'
                                                           AND  P.ATTD_PAY_DT = (
                                                                                    SELECT  MAX(ATTD_PAY_DT)
                                                                                      FROM  STORE_ATTD_PAY
                                                                                     WHERE  COMP_CD     = P.COMP_CD
                                                                                       AND  BRAND_CD    = P.BRAND_CD
                                                                                       AND  STOR_CD     = P.STOR_CD
                                                                                       AND  USER_ID     = P.USER_ID
                                                                                       AND  ATTD_PAY_DT <= PSV_ATTD_YM||'31'
                                                                                       AND  USE_YN      = 'Y'
                                                                                )
                                                           AND  P.USE_YN    = 'Y'
                                                           AND  C.CODE_TP   = '00765'
                                                           AND  C.VAL_C1    = 'A'
                                                           AND  C.USE_YN    = 'Y'
                                                    )
                                             WHERE  WORK_START_DT <> WORK_CLOSE_DT   
                                        )
                            )
                     WHERE  DAY_OF_SEC >= 0
                )
         GROUP  BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, SUBSTR(ATTD_DT, 1, 6)
        ;

    END LOOP;

    COMMIT;

    RETURN;
EXCEPTION
    WHEN ERR_HANDLER THEN
        ROLLBACK;
    WHEN OTHERS THEN
        ROLLBACK;
END;

/
