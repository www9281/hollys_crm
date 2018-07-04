--------------------------------------------------------
--  DDL for Function DIVIDE_ZERO_DEF
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "CRMDEV"."DIVIDE_ZERO_DEF" 
(
  A_DIVIDEND      NUMBER  -- 피제수
 ,A_DIVISOR       NUMBER  -- 제수
 ,A_DEF_VALUE     NUMBER  -- 제수가 0 또는 NULL일때 리턴 할 값
) RETURN          NUMBER
IS
BEGIN

  RETURN CASE NVL(A_DIVISOR, 0)
           WHEN 0 THEN A_DEF_VALUE
           ELSE        A_DIVIDEND / A_DIVISOR
         END;

END DIVIDE_ZERO_DEF;

/
