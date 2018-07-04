--------------------------------------------------------
--  DDL for Procedure SP_CREATE_ATTD_PAY_A
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CREATE_ATTD_PAY_A" 
/******************************************************************************
   NAME     : SP_CREATE_ATTD_PAY_A
   PURPOSE  : 계약직 급여정보 재생성 배치

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_CREATE_ATTD_PAY_A
      Sysdate:         
      Date and Time:   
      Username:         (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
(    
    PSV_COMP_CD     IN  VARCHAR2,
    PSV_BRAND_CD    IN  VARCHAR2,
    PSV_STOR_CD     IN  VARCHAR2,
    PSV_ATTD_YM     IN  VARCHAR2,
    PR_RTN_CD       OUT VARCHAR2,   -- 처리코드
    PR_RTN_MSG      OUT VARCHAR2    -- 처리Message
)
IS
    lsv_msg_code    NUMBER(9) := 0;
    lsv_msg_text    VARCHAR2(200);

    ERR_HANDLER     EXCEPTION;
BEGIN
    lsv_msg_code    := '0';
    lsv_msg_text    := '';

    -- 집계데이터 삭제
    DELETE  ATTD_PAY_006
     WHERE  COMP_CD     = PSV_COMP_CD
       AND  BRAND_CD    = PSV_BRAND_CD
       AND  STOR_CD     = PSV_STOR_CD
       AND  ATTD_YM     = PSV_ATTD_YM
       AND  USER_ID     IN (
                                SELECT  USER_ID
                                  FROM  STORE_USER  U
                                     ,  COMMON      C
                                 WHERE  U.COMP_CD   = C.COMP_CD
                                   AND  U.EMP_DIV   = C.CODE_CD
                                   AND  U.COMP_CD   = PSV_COMP_CD
                                   AND  U.BRAND_CD  = PSV_BRAND_CD
                                   AND  U.STOR_CD   = PSV_STOR_CD
                                   AND  C.CODE_TP   = '00765'
                                   AND  C.VAL_C1    = 'A'
                                   AND  C.USE_YN    = 'Y'
                            );

    -- 계약직 급여 산출
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
                                 ,  SUM((TO_DATE(WORK_C_DT||WORK_C_HM, 'YYYYMMDDHH24MI') - TO_DATE(WORK_S_DT||WORK_S_HM, 'YYYYMMDDHH24MI')) * 24 * 60 * 60) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT)   AS DAY_OF_SEC
                                 ,  SUM(FN_GET_MIDNIGHT_WT(WORK_S_DT||WORK_S_HM, WORK_C_DT||WORK_C_HM)) OVER (PARTITION BY COMP_CD, BRAND_CD, STOR_CD, USER_ID, ATTD_DT)                                                       AS MID_OF_SEC
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
                                                       AND  A.COMP_CD   = PSV_COMP_CD
                                                       AND  A.BRAND_CD  = PSV_BRAND_CD
                                                       AND  A.STOR_CD   = PSV_STOR_CD
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
    COMMIT;

    PR_RTN_CD   := lsv_msg_code;
    PR_RTN_MSG  := lsv_msg_text;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        PR_RTN_CD  := '4999999' ;
        PR_RTN_MSG := SQLERRM ;
END;

/
