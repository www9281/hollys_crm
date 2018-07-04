--------------------------------------------------------
--  DDL for Procedure SP_CREATE_ATTD_PAY_E
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "CRMDEV"."SP_CREATE_ATTD_PAY_E" 
/******************************************************************************
   NAME     : SP_CREATE_ATTD_PAY_E
   PURPOSE  : 정규직 급여정보 재생성 배치

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_CREATE_ATTD_PAY_E
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
                                   AND  C.VAL_C1    = 'E'
                                   AND  C.USE_YN    = 'Y'
                            );

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
                   AND  U.COMP_CD   = PSV_COMP_CD
                   AND  U.BRAND_CD  = PSV_BRAND_CD
                   AND  U.STOR_CD   = PSV_STOR_CD
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
