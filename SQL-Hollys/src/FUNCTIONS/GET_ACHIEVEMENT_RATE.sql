--------------------------------------------------------
--  DDL for Function GET_ACHIEVEMENT_RATE
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."GET_ACHIEVEMENT_RATE" 
(
  A_DIVIDEND      NUMBER         -- 피제수
 ,A_DIVISOR       NUMBER         -- 제수
 ,A_DIGITS        NUMBER         -- 반올림 자리수
 ,A_SHOW_ZERO     CHAR    := 'N' -- 0일때 표시여부
) RETURN          VARCHAR
IS
  L_NUM_GR        NUMBER;
BEGIN

  L_NUM_GR := DIVIDE_ZERO_DEF(A_DIVIDEND, A_DIVISOR, 0);

  RETURN CASE L_NUM_GR
           WHEN 0 THEN CASE A_SHOW_ZERO WHEN 'Y' THEN '0%' ELSE NULL END
           ELSE        ROUND((L_NUM_GR) * 100, 1) || '%'
         END;

END GET_ACHIEVEMENT_RATE;

/
