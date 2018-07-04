--------------------------------------------------------
--  DDL for Function GET_ELAPSED_MINUTES
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_ELAPSED_MINUTES" 
(
  A_START_TIME             VARCHAR                        -- 시작시간
 ,A_FINISH_TIME            VARCHAR                        -- 종료시간
 ,A_WHEN_EXCEPTION_RESULT  VARCHAR := NULL                -- 오류 발생시 리턴할 값
 ,A_START_TIME_FORMAT      VARCHAR := 'YYYYMMDDHH24MI'    -- 시작시간의 데이트 포맷
 ,A_FINISH_TIME_FORMAT     VARCHAR := 'YYYYMMDDHH24MI'    -- 종료시간의 데이트 포맷
) RETURN                   NUMBER
---------------------------------------------------------------------------------------------------
--  Function Name    : GET_ELAPSED_MINUTES
--  Description      : 경과시간을 분 단위로 반환하는 함수
--  Ref. Table       :
---------------------------------------------------------------------------------------------------
--  Create Date      : 2013-03-21
--  Create Programer : 정수환
--  Modify Date      :
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
  L_START_TIME             DATE;
  L_FINISH_TIME            DATE;
  L_RESULT                 NUMBER;
BEGIN

  BEGIN
    L_START_TIME := TO_DATE(A_START_TIME, A_START_TIME_FORMAT);
    L_FINISH_TIME := TO_DATE(A_FINISH_TIME, A_FINISH_TIME_FORMAT);

    L_RESULT := FLOOR((L_FINISH_TIME - L_START_TIME) * 24 * 60);
  EXCEPTION
    WHEN OTHERS THEN
      L_RESULT := A_WHEN_EXCEPTION_RESULT;
  END;

  RETURN L_RESULT;

END GET_ELAPSED_MINUTES;

/
