--------------------------------------------------------
--  DDL for Function GET_WORK_HOURS
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_WORK_HOURS" 
(
  A_START_TIME             VARCHAR                        -- 시작시간
 ,A_FINISH_TIME            VARCHAR                        -- 종료시간
 ,A_APPLY_HALF_HOUR        VARCHAR := 'Y'                 -- 30분 단위로 0.5시간을 적용할지 여루
 ,A_WHEN_EXCEPTION_RESULT  VARCHAR := NULL                -- 오류 발생시 리턴할 값
 ,A_START_TIME_FORMAT      VARCHAR := 'YYYYMMDDHH24MI'    -- 시작시간의 데이트 포맷
 ,A_FINISH_TIME_FORMAT     VARCHAR := 'YYYYMMDDHH24MI'    -- 종료시간의 데이트 포맷
) RETURN                   NUMBER
---------------------------------------------------------------------------------------------------
--  Function Name    : GET_WORK_HOURS
--  Description      : 작업시간을 반환하는 함수
--  Ref. Table       :
---------------------------------------------------------------------------------------------------
--  Create Date      : 2013-03-21
--  Create Programer : 정수환
--  Modify Date      :
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
  L_ELAPSED_MINUTES        NUMBER;
BEGIN

  L_ELAPSED_MINUTES := GET_ELAPSED_MINUTES(
                         A_START_TIME
                        ,A_FINISH_TIME
                        ,A_WHEN_EXCEPTION_RESULT
                        ,A_START_TIME_FORMAT
                        ,A_FINISH_TIME_FORMAT
                       );

  RETURN TRUNC(L_ELAPSED_MINUTES / 60) + CASE
                                           WHEN A_APPLY_HALF_HOUR = 'Y' AND (L_ELAPSED_MINUTES MOD 60) >= 30 THEN
                                             0.5
                                           ELSE
                                             0
                                         END;

END GET_WORK_HOURS;

/
