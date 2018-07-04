--------------------------------------------------------
--  DDL for Function TO_WORK_TIME
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."TO_WORK_TIME" 
(
  A_WORK_MINUTES           NUMBER            -- 분 단위 작업시간
) RETURN                   VARCHAR
---------------------------------------------------------------------------------------------------
--  Function Name    : TO_WORK_TIME
--  Description      : 분 단위 시간을 "HH24:MI" 형태로 변환 후 반환하는 함수
--  Ref. Table       :
---------------------------------------------------------------------------------------------------
--  Create Date      : 2013-03-22
--  Create Programer : 정수환
--  Modify Date      :
--  Modify Programer :
---------------------------------------------------------------------------------------------------
IS
BEGIN

  RETURN CASE
           WHEN A_WORK_MINUTES IS NULL THEN
             NULL
           ELSE
             LPAD(TRUNC(A_WORK_MINUTES / 60), 2, '0')
             || ':'
             || LPAD(A_WORK_MINUTES MOD 60, 2, '0')
         END;

END TO_WORK_TIME;

/
